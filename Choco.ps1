#requires -version 3
#requires -RunAsAdministrator
<#
.SYNOPSIS
    Chocolatey Package Installer

.DESCRIPTION
    Installs Chocolatey packages using an input file

.PARAMETER InputFile
    [string] [optional] Path and Filename for input file
    contains names of Chocolatey packages (one name per line)
    default = choco_apps.txt

.NOTES
    Use -WhatIf to run a test

    Version: 2017.05.17.01
    Author: David Stein

.EXAMPLES
    Choco.ps1 -InputFile "pkglist.txt" -WhatIf -Verbose

#>

[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [parameter(
        Mandatory=$False,
        HelpMessage="Name of input file",
        ValueFromPipeline=$True
    )]
        [string] $InputFile = "choco_apps.txt",
    [parameter(Mandatory=$False,HelpMessage="Capture details to transaction log")]
        [switch] $CaptureLog
)

$error.Clear()

if ($CaptureLog) {Start-Transaction -RollbackPreference Error}

if (!(Test-Path "c:\ProgramData\chocolatey\choco.exe")) {
    Write-Verbose "installing chocolatey..."
    if ($WhatIfPreference) {
        Write-Output "Chocolatey is not installed. Bummer dude. This script would attempt to install it first."
    }
    else {
        Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
    }
    Write-Verbose "installation completed"
}
else {
    Write-Verbose "chocolatey is already installed"
}
if (-not (Test-Path "$InputFile")) {
    Write-Warning "unable to locate $InputFile"
}
$pkgs = Get-Content -Path $InputFile | 
    Where-Object {$_ -notlike ";*"}

foreach ($pkg in $pkgs) {
    if ($WhatIfPreference) {
        choco install $pkg --whatif
    }
    else {
        choco install $pkg -y
    }
}

if ($CaptureLog) {Stop-Transcript}
if ($error[0]) { $error[0].Exception } else { 0 }
