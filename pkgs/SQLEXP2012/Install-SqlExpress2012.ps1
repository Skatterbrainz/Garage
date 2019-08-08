<#
.SYNOPSIS
    Install or Uninstall SQL Express 2012 64-bit
.DESCRIPTION
    Did I stutter?
.PARAMETER InstFile
    Name of installation file (must match bitness and language of CfgFile)
.PARAMETER CfgFile
    INI file to invoke (must match bitness and language of InstFile)
.OUTPUT
    One of the following:
    0 (zero) if successful, or integer result from setup.exe exit code
    Error message (if it dies)
#>
[CmdletBinding()]
param (
    [string] $InstFile = "SQLEXPR_x64_ENU.exe",
    [string] $CfgFile = "config.ini"
)

$instpath = Join-Path -Path $PSScriptRoot -ChildPath $InstFile
$cfgpath  = Join-Path -Path $PSScriptRoot -ChildPath $CfgFile

if (!(Test-Path $instpath) -or !(Test-Path $cfgpath)) {
    Write-Warning "required files were not found!"
    break
}

try {
    Write-Verbose "running: $instpath /ConfigurationFile=`"$cfgpath`""
    $p = Start-Process -FilePath $instpath -ArgumentList "/ConfigurationFile=`"$cfgpath`"" -Wait -PassThru -ErrorAction SilentlyContinue
    $result = $p.ExitCode
    Write-Output $result
}
catch {
    Write-Output $Error[0].Exception.Message
}
