param (
	[parameter(Mandatory=$True,
		HelpMessage="Base subnet without a trailing period")] 
		[string] $SubnetBase = "192.168.0",
	[parameter(Mandatory=$True,
        HelpMessage="Enter range in parenthesis such as (2..10)")] $SubnetRange,
    [parameter(Mandatory=$False)]
        [switch] $ResolveNames
)

Write-Host "pinging $SubnetBase.$($SubnetRange[0]) to $SubnetBase.$($SubnetRange[$SubnetRange.Length-1])" -ForegroundColor Green
write-host

$ping = New-Object System.Net.Networkinformation.Ping

$result = @()

Write-Host "IP Address`t`tHost Name`t`t`tResponse"
Write-Host "-------------`t-----------------`t----------"

foreach ($subx in $SubnetRange) {
    $addr = "$SubnetBase.$subx"
    $x    = $ping.Send($addr)
    if ($x.Status -eq 'Success') {
        if ($ResolveNames) {
            $CurrentEAP = $ErrorActionPreference
            $ErrorActionPreference = "SilentlyContinue"
            $dn = [System.Net.Dns]::GetHostEntry($addr)
            if ($dn) {
                Write-Host "$addr`t$($dn.HostName)`t$($x.RoundtripTime)"
            }
            $ErrorActionPrefernce = $CurrentEAP
        }
        else {
            Write-Host "$addr`t$($x.RoundtripTime)"
        }
    }
    else {
        if ($ResolveNames) {
            Write-Host "$addr`t----------------`toffline"
        }
        else {
            Write-Host "$addr`toffline"
        }
    }
}
