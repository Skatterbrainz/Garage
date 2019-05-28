param (
    [string] $InstallFile = ".\windows_application\install_acs_64_allusers_silent.js",
    [string] $VendorName = 'Vectrus',
    [string] $AppName = 'iSeries',
    [string] $AppDir = "$($env:SystemDrive)\ProgramData\$VendorName",
    [string] $ActSetupDir = "$($AppDir)\ActiveSetup",
    [string] $iSeriesDir = "$($ActSetupDir)\$AppName"
)
$CurrentPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ErrorActionPreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'

if (!(Test-Path $AppDir)) {
    $null = New-Item -Path "$($env:SystemDrive)\ProgramData" -Name $VendorName -ItemType Directory
}
if (!(Test-Path $ActSetupDir)) {
    $null = New-Item -Path "$($AppDir)" -Name "ActiveSetup" -ItemType Directory
}
if (!(Test-Path $iSeriesDir)) {
    $null = New-Item -Path "$($ActSetupDir)" -Name "$AppName" -ItemType Directory
}

$null = Get-ChildItem -Path "$($CurrentPath)\ActiveSetup" -Recurse | Copy-Item -Destination "$($iSeriesDir)" -Force

$RegComponentPath = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components"
$RegKey1 = "$($RegComponentPath)\$AppName"

if (!(Test-Path $RegKey1)) {
    $null = New-Item -Path "$($RegComponentPath)" -Name "$AppName" -Force
}
$null = New-ItemProperty -Path "$($RegKey1)" -Name "(Default)" -value "V1R1" -Force
$null = New-ItemProperty -Path "$($RegKey1)" -Name "Version" -Value "1.1.1" -Force
$null = New-ItemProperty -Path "$($RegKey1)" -Name "StubPath" -Value "cmd /c %SYSTEMDRIVE%\ProgramData\$VendorName\ActiveSetup\$AppName\AS.bat" -Force

#$Processes = Get-Process "wscript"
$null = Start-Process "wscript.exe" -ArgumentList "`"$($InstallFile)`"" -NoNewWindow -PassThru -Wait
Start-Sleep -Seconds 5

$Date = (Get-Date -format 'MM/dd/yyyy').ToString()

$InstDir = "$($env:PUBLIC)\IBM"
$InstSize = (Get-ChildItem -Path "$($InstDir)" -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1KB
$PShellExe = "$($env:SystemRoot)\System32\WindowsPowerShell\v1.0\powershell.exe"
$UninstScript = "$($CurrentPath)\Uninstall-IBMiAccess.ps1"
$UninstKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$UninstKey = "$($UninstKeyPath)\$VendorName`_$AppName"
if (!(Test-Path -Path $UninstKey)) {
    $null = New-Item -Path "$($UninsKeyPath)" -Name "$VendorName`_$AppName" -Force
}
$null = New-ItemProperty -Path "$UninstKey" -Name "DisplayName" -Value "$VendorName - IBM $AppName Client" -Force
$null = New-ItemProperty -Path "$UninstKey" -Name "DisplayVersion" -Value "1.1.1" -Force
$null = New-ItemProperty -Path "$UninstKey" -Name "UninstallString" -Value "$($PShellExe) -noprofile -noninteractive -file `"$($UninstScript)`"" -Force
$null = New-ItemProperty -Path "$UninstKey" -Name "PackagedBy" -Value "Catapult Systems" -Force
$null = New-ItemProperty -Path "$UninstKey" -Name "Publisher" -Value "$VendorName" -Force
$null = New-ItemProperty -Path "$UninstKey" -Name "InstallDate" -Value "$($Date)" -Force
$null = New-ItemProperty -Path "$UninstKey" -Name "EstimatedSize" -Value "$($InstSize.ToString())" -PropertyType DWord -Force
$null = New-ItemProperty -Path "$UninstKey" -Name "InstallLocation" -Value "$($InstDir)" -Force
$null = New-ItemProperty -Path "$UninstKey" -Name "InstallSource" -Value "$($CurrentPath)" -Force