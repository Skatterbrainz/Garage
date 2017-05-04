function Get-RegValue {
	param (
		[parameter(Mandatory=$False)] [string] $ComputerName = "",
		[parameter(Mandatory=$True)] [string] $KeyPath,
		[parameter(Mandatory=$True)] [string] $ValueName,
	)
	if ($ComputerName -ne "") {
		try {
			$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,Server1) 
			$RegSubKey = $Reg.OpenSubKey("$KeyPath")
			$regKey.GetValue("$ValueName")
		}
		catch {
			Write-Output "error: unable to access registry key/value."
		}
	}
	else {
		$x = Get-ItemProperty -Path "HKLM:\$KeyPath"
		$x.'Service Name'
	}
}

 
