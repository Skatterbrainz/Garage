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

  Write-Verbose "domain  = $DomainName"
  Write-Verbose "dcname  = $DCName"
  Write-Verbose "ipv4    = $IpAddress"

  # if no gateway provided, default to .1 of guest vm address

  if ($IpGateway -eq "") {
    Write-Verbose "configuring default IP gateway address"
    $IpGateway = $($IpAddress.split('.')[0..2] -join '.') + '.1'
  }
  Write-Verbose "gateway = $IpGateway"

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

  Write-Verbose "configuring static network IP address and dns server list"

  Get-NetIpAddress | 
    Where-Object {$_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -eq 'Ethernet'} | 
      New-NetIpAddress -IPAddress $IpAddress -PrefixLength 24 -DefaultGateway $IpGateway

  Get-NetIpAddress | 
    Where-Object {$_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -eq 'Ethernet'} | 
      Set-DnsClientServerAddress -ServerAddresses $IpAddress

  Write-Verbose "installing AD domain services role"
  Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools

  Write-Verbose "creating AD forest and domain"
  Install-ADDSForest -DomainName $DomainName -InstallDNS
  
  if ($InstallDHCP) {
    Write-Verbose "installing DHCP role and features"
    Install-WindowsFeature DHCP -IncludeAllSubFeature -IncludeManagementTools
  }
}
