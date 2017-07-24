#Requires -RunAsAdministrator
#Requires -Version 5
<#
.DESCRIPTION
    Alternative to using GPO for enabling/configuring PS logging
.SYNOPSIS
    You heard me
.PARAMETER TranscriptPath
    [string] (optional) path for saving transcript logs
.EXAMPLE
    Enable-PowerShellLogging.ps1
.NOTES
    Configure ACLs on transcript folder to restrict write-only privs to users...
    and read/write/full for restricted admins only
#>

[CmdletBinding(SupportsShouldProcess)]

param (
    [parameter(Mandatory=$False)]
    [string] $TranscriptPath = ""
)

Write-Output "configuring registry for powershell logging"

if (!(Test-Path HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging)) {
    New-Item -Path HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging
}

New-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging -Name EnableModuleLogging -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging -Name ModuleNames -PropertyType string -Value "`* `= `*" -Force

if (!(Test-Path HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging)) {
    New-Item -Path HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging
}
New-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Name EnableScriptBlockLogging -PropertyType dword -Value 1 -Force

if (!(Test-Path HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\Transcription)) {
    New-Item -Path HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\Transcription
}
New-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription -Name EnableTranscripting -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription -Name EnableInvocationHeader -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription -Name OutputDirectory -PropertyType string -Value $TranscriptPath -Force

Write-Output "registry configuration complete."
