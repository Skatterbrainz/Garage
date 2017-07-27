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
    Get-RegValue -Hive HKLM -KeyPath "SOFTWARE\Microsoft\Windows\CurrentVersion" -ValueName "DevicePath"
.EXAMPLE
    Get-RegValue -Hive HKLM -KeyPath "SOFTWARE\Microsoft\Windows\CurrentVersion" -ValueName "DevicePath" -ComputerName FS1,FS2,FS3
.NOTES
    Author David Stein
    07.26.2017
#>

function Get-RegValue {
	param (
		[parameter(Mandatory=$True)]
            [ValidateSet('HKLM','HKCU','HKCR')]
            [string] $Hive,
        [parameter(Mandatory=$True)] 
            [string] $KeyPath,
		[parameter(Mandatory=$True)] 
            [string] $ValueName,
		[parameter(Mandatory=$False)] 
            [string[]] $ComputerName = ""
	)
	if ($ComputerName -ne "") {
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
			Write-Warning "error: unable to access registry key/value."
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
            Write-Warning "error: unable to access registry key/value."
            Write-Output $null
        }
	}
}
