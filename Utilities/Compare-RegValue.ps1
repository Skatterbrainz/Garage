<#
.DESCRIPTION
    Compares same registry key and value data between two computers
    Returns TRUE if both are non-null and are equal.
.PARAMETER Hive
    [required] (list) 'HKLM', 'HKCR', 'HKU'
.PARAMETER KeyPath
    [required] (string) Registry key path
.PARAMETER ValueName
    [required] (string) Name of value to query
.PARAMETER ComputerName1
    [required] (string) Name of first computer to query.
.PARAMETER ComputerName2
    [required] (string) Name of second computer to query.
.EXAMPLE
    Compare-RegValue -Hive HKLM -KeyPath "SOFTWARE\Microsoft\Windows\CurrentVersion" -ValueName "DevicePath" -ComputerName1 "FS1" -ComputerName2 "FS2"
.NOTES
    Author David Stein
    2017.10.14
#>


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
            [ValidateSet('HKLM','HKCR','HKU')]
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
                'HKU'  {$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::Users, $ComputerName); break;}
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
                'HKU'  {$reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::Users,'default'); break;}
            }
		    $RegSubKey = $Reg.OpenSubKey("$KeyPath")
		    $RegSubKey.GetValue("$ValueName")
        }
        catch {
            Write-Warning "error: unable to access remote registry key/value."
            Write-Output $null
        }
	}
}

function Compare-RegValue {
    param (
        [parameter(Mandatory=$True, HelpMessage="Name of first computer")]
            [ValidateNotNullOrEmpty()]
            [string] $ComputerName1,
        [parameter(Mandatory=$True, HelpMessage="Name of second computer or . for local computer")]
            [ValidateNotNullOrEmpty()]
            [string] $ComputerName2,
        [parameter(Mandatory=$False, HelpMessage="Registry hive")]
            [ValidateSet('HKLM','HKCR','HKU')]
            [string] $Hive = 'HKLM',
        [parameter(Mandatory=$True, HelpMessage="Registry key path")]
            [ValidateNotNullOrEmpty()]
            [string] $KeyPath,
        [parameter(Mandatory=$True, HelpMessage="Registry value name")]
            [string] $ValueName,
        [parameter(Mandatory=$False, HelpMessage="Show data values")]
            [switch] $ShowData
    )
    if ($ComputerName1 -eq $ComputerName2) {
        Write-Warning "Computer1 and Computer2 cannot be the same computer, you bonehead!"
        break
    }
    $v1 = Get-RegValue -Hive $Hive -KeyPath $KeyPath -ValueName $ValueName -ComputerName $Computer1
    $v2 = Get-RegValue -Hive $Hive -KeyPath $KeyPath -ValueName $ValueName -ComputerName $Computer2
    if ($v1 -and $v2) {
        Write-Output ($v1 -eq $v2)
    }
}
