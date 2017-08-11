#requires -Modules ActiveDirectory
param (
	[parameter(Mandatory=$True, HelpMessage="Path to input CSV file")]
	[ValidateNotNullOrEmpty()]
	[string] $FilePath
)
$DefPassword = 'P@ssw0rd123'

Import-Csv $FilePath | ForEach-Object {
	$userPrincinpal = $_."samAccountName" + "@contoso.com"
	New-ADUser -Name $_.Name `
		-Path $_."ParentOU" `
		-SamAccountName  $_."sAMAccountName" `
		-Cn $_."DisplayName" `
		-Department $_."Department" `
		-Company $_."Contoso" `
		-UserPrincipalName  $userPrincinpal `
		-AccountPassword (ConvertTo-SecureString $DefPassword -AsPlainText -Force) `
		-ChangePasswordAtLogon $true  `
		-EmailAddress $_."EmailAddress"
		-Enabled $true
	if ($_.sAMAccountName.Substring(0,5).ToLower() -eq 'admin') {
		Add-ADGroupMember "Domain Admins" $_."samAccountName";
	}
}
