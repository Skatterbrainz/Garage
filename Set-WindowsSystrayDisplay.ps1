<#
.DESCRIPTION
    Toggle the systray icon display setting between show-all and show-selected

.PARAMETER Toggle
    [optional] [string] "On" or "Off"

.PARAMETER ForceUpdate
    [optional] [switch] Forces restart of the explorer shell process

.NOTES
    Author: David M. Stein
    Date: 03/18/2017
#>


param (
    [parameter(Mandatory=$False)]
    [ValidateSet("On","Off")]
    [string] $Toggle,
    [parameter(Mandatory=$False)]
    [switch] $ForceUpdate
)
$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
$RegistryName = "EnableAutoTray"
$RegistryType = "DWord"
switch ($Toggle){
    "on" {
        $RegistryValue = 0
        break
    }
    "off" {
        $RegistryValue = 1
        break
    }
}
try {
    $x = Get-ItemProperty -Path $RegistryPath -Name $RegistryName -ErrorAction Stop
    Set-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $RegistryValue -Force
}
catch {
    New-ItemProperty -Path $RegistryPath -Name $RegistryName -PropertyType $RegistryType -Value $RegistryValue
}
if ($ForceUpdate) {
    Stop-Process -Name "explorer"
    Write-Output "Saved. Restarting explorer process."
}
else {
    Write-Output "Saved. Restart explorer process to update the systray"
}

