Import-Module ActiveDirectory
Import-Csv "C:\Scripts\NewUsers.csv" | ForEach-Object {
	$userPrincinpal = $_."samAccountName" + "@contoso.com"
	New-ADUser -Name $_.Name `
		-Path $_."ParentOU" `
		-SamAccountName  $_."sAMAccountName" `
		-Cn $_."DisplayName" `
		-Department $_."Department" `
		-Company $_."Contoso" `
		-UserPrincipalName  $userPrincinpal `
		-AccountPassword (ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force) `
		-ChangePasswordAtLogon $true  `
		-EmailAddress $_."EmailAddress"
		-Enabled $true
	Add-ADGroupMember "Domain Admins" $_."samAccountName";
}
