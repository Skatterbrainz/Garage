[CmdletBinding()]
# analyze computers from txt or csv file
# query SCCM client and inventory data
# query AD account data
# check if online
param (
    [string] $InputFile = ".\lists\computernames.txt",
    [string] $ServerName = "cm01.contoso.local",
    [string] $SiteCode = "P01",
    [string] $ReportFile = ".\reports\validated_computers.csv"
)
if (!(Test-Path $InputFile)) {
    Write-Warning "$InputFile not found!!"
    break
}
$computerList = Get-Content -Path $InputFile

if (!($computerList.Count -gt 0)) {
    Write-Warning "$InputFile contains no names"
    break
}
Write-Host "$($computerList.count) items imported from $InputFile"

function Get-ConfigMgrDeviceData {
    param (
        [string] $ServerName,
        [string] $SiteCode,
        [string[]] $ComputerNames
    )
    Write-Host "getting configmgr data"
    $DatabaseName = "CM_$SiteCode"
    $complist = ($ComputerNames | %{"'$_'"}) -join ','
    $complist
    $query = (Get-Content ".\test.sql") -join ' '
    $query += " WHERE (dbo.vWorkstationStatus.Name IN ($complist)) ORDER BY dbo.vWorkstationStatus.Name"  
    $QueryTimeout = 120
    $ConnectionTimeout = 30
    $conn = New-Object System.Data.SqlClient.SQLConnection
    $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
    $conn.ConnectionString = $ConnectionString
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($Query,$conn)
    $cmd.CommandTimeout = $QueryTimeout
    $ds = New-Object System.Data.DataSet
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    [void]$da.Fill($ds)
    $conn.Close()
    $rows = $($ds.Tables).Rows.Count
    $($ds.Tables).Rows
}

function Get-ADComputerData {
    [CmdletBinding()]
    param (
        [string] $ComputerName = ""
    )
    if (![string]::IsNullOrEmpty($ComputerName)) {
        $as = [adsisearcher]"(&(objectCategory=Computer)(name=$ComputerName))"
    }
    else {
        $as = [adsisearcher]"(objectCategory=Computer)"
    }
    $as.PropertiesToLoad.Add('cn') | Out-Null
    $as.PropertiesToLoad.Add('lastlogonTimeStamp') | Out-Null
    $as.PropertiesToLoad.Add('whenCreated') | Out-Null
    $as.PropertiesToLoad.Add('operatingSystem') | Out-Null
    $as.PropertiesToLoad.Add('operatingSystemVersion') | Out-Null
    $as.PropertiesToLoad.Add('distinguishedName') | Out-Null
    $as.PageSize = 200
    $as.FindAll() | 
        ForEach-Object {
            $cn = ($_.properties.item('cn') | Out-String).Trim()
            [datetime]$created = ($_.Properties.item('whenCreated') | Out-String).Trim()
            $llogon = ([datetime]::FromFiletime(($_.properties.item('lastlogonTimeStamp') | Out-String).Trim())) 
            $ouPath = ($_.Properties.item('distinguishedName') | Out-String).Trim() -replace $("CN=$cn,", "")
            $props = [ordered]@{
                Name       = $cn
                OS         = ($_.Properties.item('operatingSystem') | Out-String).Trim()
                OSVer      = ($_.Properties.item('operatingSystemVersion') | Out-String).Trim()
                DN         = ($_.Properties.item('distinguishedName') | Out-String).Trim()
                OU         = $ouPath
                Created    = $created
                LastLogon  = $llogon
            }
            New-Object psObject -Property $props
        }
}

# fetch recordset for all computers in one operation here
$cmdataset = Get-ConfigMgrDeviceData -ServerName $ServerName -SiteCode $SiteCode -ComputerNames $computerList
foreach ($cmdevice in $cmdataset) {
    if ($addataset = Get-ADComputerData -ComputerName $cmdevice.Name) {
        $LastLogon = $addataset.LastLogon
    }
    else {
        $LastLogon = $null
    }
    $data = [ordered]@{
        Name            = $cmdevice.Name
        UserName        = $cmdevice.UserName 
        OperatingSystem = $cmdevice.OperatingSystem 
        OsBuild         = $cmdevice.OsBuild
        SystemType      = $cmdevice.SystemType 
        ClientVersion   = $cmdevice.ClientVersion
        UserDomain      = $cmdevice.UserDomain
        ADSite          = $cmdevice.ADSite
        Model           = $cmdevice.Model
        SerialNumber    = $cmdevice.SerialNumber
        IsVM            = $cmdevice.IsVM
        LastHwScan      = $cmdevice.LastHwScan 
        InvAge          = $cmdevice.InvAge 
        LastLogon       = $LastLogon
    }
    New-Object PSObject -Property $data
}
    
#$dataset | FT

foreach ($row in $dataset) {
    #
}
