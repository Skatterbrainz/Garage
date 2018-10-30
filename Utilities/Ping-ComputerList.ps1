<#
.DESCRIPTION
  Ping and report details on devices from AD, SCCM
.PARAMETER InputFile
.PARAMETER GroupLabel
.PARAMETER DeployDate
.PARAMETER CollectionID
.PARAMETER Detailed
.PARAMETER ServerName
.PARAMETER SiteCOde
.NOTES
  Requires scripts: Get-CMDeviceInfo.ps1, Get-ADsComputers.ps1, Get-CmCollectionMember.ps1, Get-OfficeFileVersion.ps1
#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string] $InputFile,
    [parameter(Mandatory=$False)]
    [string] $GroupLabel = "",
    [string] $DeployDate = "",
    [string] $CollectionID = "",
    [switch] $Detailed,
    [string] $ServerName = "cm01.contoso.local",
    [string] $SiteCode = "P01"
)

if (!(Test-Path $InputFile)) {
    Write-Warning "$InputFile not found!!"
    break
}
$infile = Get-Item -Path $InputFile
if ($GroupLabel -eq "") {
    $GroupLabel = $infile.BaseName
}
if ($DeployDate -eq "") {
    $DeployDate = (Get-Date).ToShortDateString()
}

Write-Verbose "group label is $GroupLabel"
Write-Verbose "deploy date is $DeployDate"

$computers = Get-Content -Path $InputFile
Write-Host "$($computers.count) names imported from file"

if ($Detailed -and ($CollectionID -ne "")) {
    $cmem = .\tools\Get-CmCollectionMember.ps1 -CollectionID $CollectionID -ServerName $ServerName -SiteCode $SiteCode | Sort-Object ComputerName | Select -ExpandProperty ComputerName
}
else {
    $cmem = $null
}

foreach ($computer in $computers) {
    $stat = Test-NetConnection $computer
    $offx = .\tools\Get-OfficeFileVersion.ps1 -ComputerName $computer
    if ($Detailed) {
        $adlogin = .\tools\Get-ADsComputers.ps1 -ComputerName $computer | Select -ExpandProperty LastLogon
        <#
        example:
            Name      : L-L15272
            OS        : Windows 10 Enterprise
            OSVer     : 10.0 (14393)
            DN        : CN=DT-L15272,OU=Computers,OU=Corp,DC=contoso,DC=local
            OU        : OU=Computers,OU=Corp,DC=contoso,DC=local
            Created   : 7/17/2018 7:58:07 PM
            LastLogon : 10/29/2018 7:06:32 AM
        #>
        $cmdata  = .\tools\Get-CMDeviceInfo.ps1 -ServerName $ServerName -SiteCode $SiteCode -ComputerNames $computer
        if ($cmem -contains $computer) {
            $ismember = $True
        }
        else {
            $ismember = $False
        }
        <#
        example: 
            Name            : L-L15272
            UserName        : jsmith
            OperatingSystem : Microsoft Windows 10 Enterprise
            OsBuild         : 1607
            SystemType      : X64-based PC
            ClientVersion   : 5.00.8692.1008
            UserDomain      : CONTOSO
            ADSite          : Dallas
            Model           : Latitude E9000
            SerialNumber    : ABC123
            IsVM            : N
            LastHealthEval  : 7
            LastHwScan      : 10/25/2018 7:42:19 AM
            InvAge          : 5
            LastDDR         : 10/29/2018 9:50:43 PM
        #>
        $data = [ordered]@{
            ComputerName  = $computer 
            Online        = $(if($stat.PingSucceeded){$True} else {$False})
            IpAddress     = $($stat.RemoteAddress)
            "$CollectionID" = $ismember
            ADLastLogon   = $adlogin
            CMLastHwInv   = $cmdata.LastHwScan
            CMInvAge      = $cmdata.InvAge
            O365Version   = $($offx.OfficeVer)
            O365Package   = $($offx.OfficePkg)
            Group         = $GroupLabel
            Date          = $DeployDate

        }
    }
    else {
        $data = [ordered]@{
            ComputerName  = $computer 
            Online        = $(if($stat.PingSucceeded){$True} else {$False})
            IpAddress     = $(if($stat.RemoteAddress){$stat.RemoteAddress} else {"No DNS Record"})
            O365Version   = $($offx.OfficeVer)
            O365Package   = $($offx.OfficePkg)
            Group         = $ReportLabel
            Date          = $GroupLabel
        }
    }
    New-Object -TypeName PSObject -Property $data
}
