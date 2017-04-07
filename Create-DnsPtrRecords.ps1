<#
.SYNOPSIS
    Create-DnsPtrRecords.ps1 creates PTR records in DNS for each A record in the forward lookup zone

.PARAMETER DnsServer (Server, ServerName, cn)
    Name of DNS server (e.g. "dc1.contoso.com")

.PARAMETER DnsDomainName (Domain, DomainName)
    FQDN of domain DNS zone (e.g. "contoso.com")

.EXAMPLE
    Create-DnsPtrRecords.ps1 -DnsServer 'dc01.contoso.com' -DnsDomainName 'sales.contoso.com'

.NOTES
    Based on original script: https://www.pickysysadmin.ca/2014/09/19/powershell-script-to-create-reverse-lookups-in-microsoft-dns/
    Modified by David Stein
        added params to script input
#>


param (
    [parameter(Mandatory=$True,HelpMessage="FQDN of DNS Server")]
    [ValidateNotNullOrEmpty()]
    [Alias('Server','ServerName','cn')]
    [string] $DnsServer,

    [parameter(Mandatory=$True,HelpMessage="Domain full name")]
    [ValidateNotNullOrEmpty()]
    [Alias('Domain','DomainName')]
    [string] $DnsDomainName
)

function New-PTR ($dnsServer,$reverse_zone,$reverse_ip,$hostname) {
	Invoke-WmiMethod -Name CreateInstanceFromPropertyData -Class MicrosoftDNS_PTRType `
	-Namespace root\MicrosoftDNS `
    -ArgumentList "$reverse_zone","$dnsServer","$reverse_ip","$hostname" `
	-ComputerName $dnsServer
}
 
$record_R_list = Get-WmiObject -Namespace "root\MicrosoftDNS" `
    -Class MicrosoftDNS_PTRtype -ComputerName $dnsServer | 
        ForEach-Object {$_.recorddata}
$record_A_list = Get-WmiObject -Namespace "root\MicrosoftDNS" `
    -Class MicrosoftDNS_Atype -ComputerName $dnsServer | 
        Select-Object ownername,IPaddress | 
            Where-Object { $_.ownername -like "*.$dnsDomainName" }
$reverse_zone_list = Get-WmiObject MicrosoftDNS_Zone `
    -Namespace 'root\MicrosoftDNS' -Filter "reverse=true" `
    -Computer $dnsServer | ForEach-Object {$_.name}
 
foreach ($a_record in $record_A_list) {
	$hostname  = $a_record.ownername+"."
	$ipaddress = $a_record.IPaddress
	if ($record_R_list -notcontains $hostname) {
		Write-Host -NoNewline "The following host does not have a valid reverse record in DNS : " $hostname
 
		$PingStatus = Get-WmiObject Win32_PingStatus -Filter "Address = '$hostname'" | Select-Object StatusCode
		
        If ($PingStatus.StatusCode -eq 0){
			Write-Host " (online)" -Fore "Green"
			$arr = $ipaddress.split(".")
			[array]::Reverse($arr)
			$reverse_ip = ($arr -join '.') + ".in-addr.arpa"
 
			#detect the correct dns reverse lookup zone
			$arr_rvr = $reverse_ip.Split(".")
			$arr_rvr1 = $arr_rvr[1] + "." + $arr_rvr[2] + "." + $arr_rvr[3] + ".in-addr.arpa"
			$arr_rvr2 = $arr_rvr[2] + "." + $arr_rvr[3] + ".in-addr.arpa"
			$arr_rvr3 = $arr_rvr[3] + ".in-addr.arpa"
			if ($reverse_zone_list -contains $arr_rvr1){
				Write-Host $arr_rvr1 " exists in DNS reverse lookup zones"
				Write-Host $reverse_ip
				New-PTR $dnsServer $arr_rvr1 $reverse_ip $hostname
			}
			elseif ($reverse_zone_list -contains $arr_rvr2){
				Write-Host $arr_rvr2 " exists in DNS reverse lookup zones"
				Write-Host $reverse_ip
				New-PTR $dnsServer $arr_rvr2 $reverse_ip $hostname
			}
			elseif ($reverse_zone_list -contains $arr_rvr3) {
				Write-Host $arr_rvr3 " exists in DNS reverse lookup zones"
				Write-Host $reverse_ip
				New-PTR $dnsServer $arr_rvr3 $reverse_ip $hostname
			}
			else {
				Write-Host "Reverse lookup zone does not exist. Cannot create the PTR record"
			}
		}
		Else {
			Write-Host " (offline)"  -Fore "Red"
		}
	}
}
