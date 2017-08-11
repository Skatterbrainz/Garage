#requires -Modules ADDSDeployment
<#
.NOTES
  quick and dirty / makes a 2016 forest/domain
#>
[CmdletBinding()]
param (
  [parameter(Mandatory=$True)]
  [ValidateNotNullOrEmpty()]
  [string] $ForestName
)
$NetBiosName = ($ForestName.Split('.')[0]).ToUpper()

Install-ADDSForest `
-CreateDnsDelegation:$False `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode Default `
-DomainName $ForestName `
-DomainNetbiosName $NetBiosName `
-ForestMode Default `
-InstallDns:$True `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$False `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$True
