#requires -Version 3.0
<#
.DESCRIPTION
    Query computer info from SMB, Registry and harrassing AD a bit
.PARAMETER InputFile
    File with list of computer names to query
.PARAMETER CheckAll
    Query all optional properties
.PARAMETER CheckSAP
    Query SAP analysis runtime version
.PARAMETER CheckSharedActivation
    Query Office 365 Shared Activation registry key value
.PARAMETER CheckAD
    Query AD for parsed name information
#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string] $InputFile,
    [switch] $CheckAll,
    [switch] $CheckSAP,
    [switch] $CheckSharedActivation,
    [switch] $CheckAD
)

if (!(Test-Path $InputFile)) {
    Write-Warning "$InputFile not found!"
    break
}

function Get-SAPBOx64Version {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $ComputerName
    )
    $k = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SAPExcelAddInx64"
    $v = "DisplayVersion"
    .\Get-RegistryValue.ps1 -Hive HKLM -KeyPath $k -ValueName $v -ComputerName $ComputerName
}

function Get-OfficeSharedActivationState {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $ComputerName
    )
    $k = "SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
    $v = "SharedComputerLicensing"
    Write-Output ($(.\Get-RegistryValue.ps1 -Hive HKLM -KeyPath $k -ValueName $v -ComputerName $ComputerName) -eq 1)
}

function Get-OfficeFileVersion {
    param (
        [string] $FileName = "WINWORD.exe",
        [string] $FilePath = "C`$\Program Files\Microsoft Office\root\Office16",
        [string] $ComputerName = ""
    )
    $fullpath = "\\$ComputerName\"+$(Join-Path -Path $FilePath -ChildPath $FileName)
    if (Test-Path $fullpath) {
        (Get-Item -Path $fullpath).VersionInfo.FileVersion
    }
    else {
        Write-Verbose "not found: $fullpath"
    }
}

function Get-ComputerUserName {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $ComputerName 
    )
    $part = $ComputerName -split '-'
    if ($part.Count -gt 1) {
        Write-Output $part[0]
    }
}

function Get-ComputerFormType {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $ComputerName 
    )
    $part = $ComputerName -split '-'
    if ($part.Count -gt 1) {
        switch ($($part[1]).Substring(0,1)) {
            'D' { Write-Output 'Desktop'; break}
            'L' { Write-Output 'Laptop'; break}
            'V' { Write-Output 'Virtual'; break}
            default { Write-Output 'Other'; break}
        }
    }
}

function Get-ADsUserProperty {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $PartialName,
        [parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string] $Attribute = 'name'
    )
    $strFilter = "(&(objectCategory=User)(sAMAccountName=$PartialName*))"
    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $objSearcher.Filter = $strFilter
    $objSearcher.PageSize = 1000
    $objPath = $objSearcher.FindAll()
    foreach ($obj in $objPath) {
        $obj.Properties."$Attribute"
    }
}

$computers = Get-Content -Path $InputFile

foreach ($computer in $computers) {
    if ((Test-NetConnection -ComputerName $computer -WarningAction SilentlyContinue).PingSucceeded) {
        $stat    = $True
        $wordver = Get-OfficeFileVersion -ComputerName $computer
        if ($CheckAll -or $CheckSharedActivation) {
            $shared  = Get-OfficeSharedActivationState -ComputerName $computer
        }
        else {
            $shared = "skipped"
        }
        if ($CheckAll -or $CheckSAP) {
            $sapver  = Get-SAPBOx64Version -ComputerName $computer
        }
        else {
            $sapver = "skipped"
        }
        if ($CheckAll -or $CheckAD) {
            $lastLogon = $(.\Get-ADsAccountLastLogon.ps1 -AccountName $computer -AccountType Computer).LastLogon
            if ($partname  = Get-ComputerUserName -ComputerName $computer) {
                $username  = Get-ADsUserProperty -PartialName $partname -Attribute name
                $formtype  = Get-ComputerFormType -ComputerName $computer 
            }
            else {
                $username = $null
                $formtype = $null
            }
        }
        else {
            $lastLogon = "skipped"
        }
    }
    else {
        $stat     = $False
        $wordver  = $null
        $shared   = $null
        $sapver   = $null
        if ($CheckAll -or $CheckAD) {
            $lastLogon = $(.\Get-ADsAccountLastLogon.ps1 -AccountName $computer -AccountType Computer).LastLogon
            if ($partname  = Get-ComputerUserName -ComputerName $computer) {
                $username  = Get-ADsUserProperty -PartialName $partname -Attribute name
                $formtype  = Get-ComputerFormType -ComputerName $computer 
            }
            else {
                $username = $null
                $formtype = $null
            }
        }
        else {
            $lastLogon = $null
            $formtype = $null
            $username = $null
        }
    }
    $data = [ordered]@{
        Computer      = $computer 
        FormFactor    = $formtype
        UserName      = $username 
        IsOnline      = $stat
        LastLogon     = $lastLogon
        OfficeVersion = $wordver
        SharedAct     = $shared
        SAPVersion64  = $sapver
    }
    New-Object PSObject -Property $data 
}

Write-Host "done!"
