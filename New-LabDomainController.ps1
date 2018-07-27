function New-LabDomainController {
  [CmdletBinding(SupportsShouldProcess)]
  param (
    [parameter(Mandatory=$True, HelpMessage="FQDN domain name")]
      [ValidateNotNullOrEmpty()]
      [string] $DomainName,
    [parameter(Mandatory=$False, HelpMessage="NetBIOS hostname")]
      [ValidateNotNullOrEmpty()]
      [string] $DCName = "DC01",
    [parameter(Mandatory=$False, HelpMessage="IPv4 Address")]
      [ValidateNotNullOrEmpty()]
      [string] $IpAddress = "192.168.1.10",
    [parameter(Mandatory=$False, HelpMessage="IPv4 Gateway address")]
      [string] $IpGateway = "",
    [parameter(Mandatory=$False, HelpMessage="Install DHCP role")]
      [switch] $InstallDHCP
  )
  Start-Transcript
  
  Write-Verbose "domain... $DomainName"
  Write-Verbose "dcname... $DCName"
  Write-Verbose "ipv4..... $IpAddress"

  # if no gateway provided, default to .1 of guest vm address

  if ($IpGateway -eq "") {
    Write-Verbose "configuring default IP gateway address"
    $IpGateway = $($IpAddress.split('.')[0..2] -join '.') + '.1'
  }
  Write-Verbose "gateway.. $IpGateway"

  if ($env:COMPUTERNAME -ne $DCName) {
    Write-Verbose "renaming computer to $DCName"
    Rename-Computer -NewName $DCName -Force
    Write-Verbose "computer has been renamed to $DCName"
    $choice = Read-Host -Prompt "Restart now? <Y/n>"
    if ($choice -eq 'Y') {
      Restart-Computer
    }
  }
  else {
    Write-Verbose "computer is already named $DCName"
  }

  Import-Module ServerManager

  if ((Get-NetIPAddress | Where-Object {$_.InterfaceAlias -eq 'Ethernet' -and $_.AddressFamily -eq 'IPv4'} | Select-Object -ExpandProperty IPAddress) -ne $IpAddress) {
    Write-Verbose "configuring static network IP address and dns server list"

    Get-NetIpAddress | 
      Where-Object {$_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -eq 'Ethernet'} | 
        New-NetIpAddress -IPAddress $IpAddress -PrefixLength 24 -DefaultGateway $IpGateway
  
    Get-NetIpAddress | 
      Where-Object {$_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -eq 'Ethernet'} | 
        Set-DnsClientServerAddress -ServerAddresses $IpAddress
  }
  else {
    Write-Verbose "ip address is already set to $IpAddress"
  }
  
  Write-Verbose "installing AD domain services role"
  Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools -Force -Confirm:$False

  Write-Verbose "creating AD forest and domain"
  Install-ADDSForest -DomainName $DomainName -InstallDNS -NoRebootOnCompletion
  
  if ($InstallDHCP) {
    Write-Verbose "installing DHCP role and features"
    Install-WindowsFeature DHCP -IncludeAllSubFeature -IncludeManagementTools
  }
  
  Write-Verbose "creating organizational unit structure"
  
  $LdapRoot = (Get-ADDomain).DistinguishedName
  New-ADOrganizationalUnit -Name "Corp" -Path $LdapRoot
  $NextRoot = "OU=Corp,$LdapRoot"
  New-ADOrganizationalUnit -Name "Servers" -Path $NextRoot
  New-ADOrganizationalUnit -Name "Workstations" -Path $NextRoot
  New-ADOrganizationalUnit -Name "Users" -Path $NextRoot
  New-ADOrganizationalUnit -Name "Groups" -Path $NextRoot
  New-ADOrganizationalUnit -Name "ServiceAccounts" -Path $NextRoot
  
  Write-Verbose "creating user accounts"
  $pwd = ConvertTo-SecureString -String "P@ssw0rd" -AsPlainText -Force

  $UserRoot = "OU=Users,$NextRoot"
  $normalusers = @("norfolk1=Norfolk User 1","norfolk2=Norfolk User 2","sccmadmin=SCCM Admin")
  
  foreach ($acct in $normalusers) {
    $ulist = $acct.Split('=')
    Write-Verbose "creating user: $($ulist[0])"
    New-ADUser -Name $ulist[0] -AccountPassword $pwd -ChangePasswordAtLogon:$False -DisplayName $ulist[1] -Enabled:$True -Path $UserRoot
  }
  
  $AcctRoot = "OU=ServiceAccounts,$NextRoot"
  $svcaccounts = @("cm-client=CM Client Install","cm-domjoin=CM Domain Join","cm-naa=CM Network Access","cm-svcsql=CM SQL Service")
  
  foreach ($acct in $svcaccounts) {
    $ulist = $acct.Split('=')
    Write-Verbose "creating user: $($ulist[0])"
    New-ADUser -Name $ulist[0] -AccountPassword $pwd -ChangePasswordAtLogon:$False -DisplayName $ulist[1] -Enabled:$True -Path $UserRoot
  }
  Write-Host "complete!" -ForegroundColor Green
  Stop-Transcript
}
