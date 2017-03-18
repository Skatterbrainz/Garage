
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

