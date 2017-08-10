<#
.SYNOPSIS

.PARAMETER UserBackup
	[string] [required] Path to where user profile will be backed up
	
.PARAMETER ExProfile
	[string] [required] Name of user account to ignore when clearing profiles

.PARAMETER DomainName

.PARAMETER OUPath

.NOTES

#>

[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [parameter(Mandatory=$False, HelpMessage="User profile backup location")]
		[ValidateNotNullOrEmpty()]
		[string] $UserBackup = "C:\UserTemp",
    [parameter(Mandatory=$False, HelpMessage="Profile to exclude from cleanup")]
		[ValidateNotNullOrEmpty()]
		[string] $ExProfile = "local1",
	[parameter(Mandatory=$False, HelpMessage="Name of domain to join")]
		[string] $DomainName = "contoso.com",
	[parameter(Mandatory=$False, HelpMessage="OU Path to join computer to active directory")]
		[string] $OuPath = "OU=Workstations,OU=Corporate,DC=contoso,DC=com"
)

Start-Transcript -Path "$($env:TEMP)\Reset-MachineProfile.log" -IncludeInvocationHeader
Write-Host "Reset-MachineProfile.ps1 - 2017.07.05.03" -ForegroundColor Green

function New-Shortcut {
    param (
        [string]$SourceExe, 
        [string]$ArgumentsToSourceExe, 
        [string]$DestinationPath
    )
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($DestinationPath)
    $Shortcut.TargetPath = $SourceExe
    $Shortcut.Arguments = $ArgumentsToSourceExe
    $Shortcut.Save()
}

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

if (($env:USERDOMAIN -eq $DomainName) -or ($env:USERDNSDOMAIN -eq $DomainName)) {
    Write-Verbose "Machine is domain joined. Shortcut will be created on Desktop to invoke after disjoining"
    New-Shortcut -SourceExe "powershell.exe" -ArgumentsToSourceExe "-ByPass -NoProfile -File \\$ScriptPath\Reset-MachinePolicy.ps1" -DestinationPath "$($env:ALLUSERSPROFILE)\Desktop\ResetMachine.lnk"
    Write-Output "Desktop shortcut has been created. Launch after reboot and local login."
	if ($(Get-WmiObject -Class Win32_OperatingSystem).Caption -like "%Windows 10%") {
		$cred = Get-Credential -Message "Credential for disjoining from domain"
		Remove-Computer -UnjoinDomainCredential $cred -Force -Restart
    break
}
else {
    Write-Verbose "Backing up $ExProfile"
    robocopy "c:\users\$exProfile" "c:\usertemp" /MIR /XA:SH /XD AppData /XJD /R:5 /W:15 /MT:32 /V /NP /LOG:"UserProfile-$exProfile-Backup.log"
    Write-Output "User profile has been backed up."
}

Write-Verbose "searching for $ScriptPath\delprof2.exe"

if (!(Test-Path "$ScriptPath\DelProf2.exe")) {
    Write-Warning "Unable to locate delprof2.exe"
    break
}

$argString = "`/ed:$ExProfile /l"
Write-Verbose "executing $ScriptPath\delprof2.exe $argString"
break

try {
    $p = Start-Process -FilePath "$ScriptPath\DelProf2.exe" -ArgumentList $argString -PassThru -Wait
    $result = $p.ExitCode
}
catch {
    $result = -1
}

Write-Verbose "Removing machine policy registry tree..."
Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft" -Recurse -Force
Write-Verbose "Registry has been cleaned"

Write-Output "Joining domain..."
$cred = Get-Credential
if ($(Get-WmiObject -Class Win32_OperatingSystem).Caption -like "%Windows 10%") {
-UnjoinDomainCredential
	Add-Computer -DomainName "$DomainName" -Credential $cred -OUPath "$OuPath" -Restart

Write-Output "Completed."
Stop-Transcript
Write-Output 0
