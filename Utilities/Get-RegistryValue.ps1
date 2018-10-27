<#
.DESCRIPTION
    Returns value assignment for specified registry key
.PARAMETER Hive
    [required] (list) 'HKLM','HKCU', or 'HKCR'. Note that 'HKCU' is not
    allowed when $ComputerName is specified
.PARAMETER KeyPath
    [required] (string) Registry key path
.PARAMETER ValueName
    [required] (string) Name of value to query
.PARAMETER ComputerName
    [optional] (string(array)) Names of computers to query.
    If empty or $null, the local computer is assumed
.EXAMPLE
    Get-RegistryValue -Hive HKLM -KeyPath "SOFTWARE\Microsoft\Windows\CurrentVersion" -ValueName "DevicePath"
.EXAMPLE
    Get-RegistryValue -Hive HKLM -KeyPath "SOFTWARE\Microsoft\Windows\CurrentVersion" -ValueName "DevicePath" -ComputerName FS1
.NOTES
    Author David Stein
    07.26.2017
#>
[CmdletBinding()]
param (
	[parameter(Mandatory=$False, HelpMessage="Optional Computer Name")] 
        [string] $ComputerName = "",
	[parameter(Mandatory=$False, HelpMessage="Registry Hive, default is HKLM")]
        [ValidateSet('HKLM','HKCU','HKCR')]
        [string] $Hive = 'HKLM',
    [parameter(Mandatory=$True, HelpMessage="Registry Key path")] 
        [ValidateNotNullOrEmpty()]
        [string] $KeyPath,
	[parameter(Mandatory=$True, HelpMessage="Registry Key Value Name")] 
        [ValidateNotNullOrEmpty()]
        [string] $ValueName
)
if ($Hive -eq 'HKCU' -and (![string]::IsNullOrEmpty($ComputerName))) {
    Write-Warning "HKCU is not available when querying remote computers"
    break
}
if (![string]::IsNullOrEmpty($ComputerName)) {
	try {
        switch($Hive) {
            'HKLM' {$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ComputerName); break;}
            'HKCR' {$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::ClassesRoot, $ComputerName); break;}
            default {
                Write-Error "HKCU is not available when querying remote computers"
                break;
            }
        }
		$RegSubKey = $Reg.OpenSubKey("$KeyPath")
		Write-Output $RegSubKey.GetValue("$ValueName")
	}
	catch {
		Write-Verbose "error: unable to access registry key/value."
        Write-Output $null
	}
}
else {
    try {
        switch ($Hive) {
            'HKLM' {$reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,'default'); break;}
            'HKCR' {$reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::ClassesRoot,'default'); break;}
            'HKCU' {$reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::CurrentUser,'default'); break;}
        }
		$RegSubKey = $Reg.OpenSubKey("$KeyPath")
		$RegSubKey.GetValue("$ValueName")
    }
    catch {
        Write-Verbose "error: unable to access registry key/value."
    }
}
