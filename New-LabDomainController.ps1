[CmdletBinding(SupportsShouldProcess)]
param (
  [parameter(Mandatory=$True, HelpMessage="FQDN domain name")]
    [ValidateNotNullOrEmpty()]
    [string] $DomainName,
  [parameter(Mandatory=$True, HelpMessage="NetBIOS hostname")]
    [ValidateNotNullOrEmpty()]
    [string] $HostName,
  [parameter(Mandatory=$True, HelpMessage="IPv4 Address")]
    [ValidateNotNullOrEmpty()]
    [string] $IpAddress,
  [parameter(Mandatory=$False, HelpMessage="IPv4 Gateway address")]
    [string] $IpGateway = ""
)

# if no gateway provided, default to .1 of guest vm address

if ($IpGateway -eq "") {
  Write-Verbose "configuring default IP gateway address"
  $IpGateway = $($IpAddress.split('.')[0..2] -join '.') + '.1'
  Write-Verbose "IP gateway is $IpGateway"
}

Import-Module ServerManager

Write-Verbose "configuring static network IP address and dns server list"

Get-NetIpAddress | 
  Where-Object {$_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -eq 'Ethernet'} | 
    New-NetIpAddress -IPAddress $IpAddress -PrefixLength 24 -DefaultGateway $IpGateway

Get-NetIpAddress | 
  Where-Object {$_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -eq 'Ethernet'} | 
    Set-DnsClientServerAddress -ServerAddresses $IpAddress

Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools
