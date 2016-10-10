Import-Module ActiveDirectory
Import-Csv "C:\Scripts\NewUsers.csv" | ForEach-Object {
	$userPrincinpal = $_."samAccountName" + "@vbgov.com"
	New-ADUser -Name $_.Name `
		-Path $_."ParentOU" `
		-SamAccountName  $_."sAMAccountName" `
		-Cn $_."DisplayName" `
		-Department $_."Department" `
		-Company $_."City of Virginia Beach" `
		-UserPrincipalName  $userPrincinpal `
		-AccountPassword (ConvertTo-SecureString "MyPassword123" -AsPlainText -Force) `
		-ChangePasswordAtLogon $true  `
		-EmailAddress $_."EmailAddress"
		-Enabled $true
	Add-ADGroupMember "Domain Admins" $_."samAccountName";
}