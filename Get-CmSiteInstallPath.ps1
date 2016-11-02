function Get-CmSiteInstallPath {
	$x = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\SMS\setup"
	$x.'Installation Directory'
}
