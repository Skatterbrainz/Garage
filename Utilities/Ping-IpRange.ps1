param (
	[parameter(Mandatory=$True, HelpMessage="Base subnet without a trailing period")] 
		[string] $SubnetBase = "192.168.0",
	[parameter(Mandatory=$True, HelpMessage="Enter range in parenthesis such as (2..10)")] 
		$SubnetRange,
    [parameter(Mandatory=$False)]
        [switch] $ResolveNames
)

Write-Host "pinging $SubnetBase.$($SubnetRange[0]) to $SubnetBase.$($SubnetRange[$SubnetRange.Length-1])" -ForegroundColor Green

$ping = New-Object System.Net.Networkinformation.Ping

$result = @()

Write-Output "IP Address`t`tHost Name`t`t`tResponse"
Write-Output "-------------`t-----------------`t----------"

foreach ($subx in $SubnetRange) {
    $addr = "$SubnetBase.$subx"
    $x    = $ping.Send($addr)
    if ($x.Status -eq 'Success') {
        if ($ResolveNames) {
            $CurrentEAP = $ErrorActionPreference
            $ErrorActionPreference = "SilentlyContinue"
            $dn = [System.Net.Dns]::GetHostEntry($addr)
            if ($dn) {
                Write-Output "$addr`t$($dn.HostName)`t$($x.RoundtripTime)"
            }
            $ErrorActionPrefernce = $CurrentEAP
        }
        else {
            Write-Output "$addr`t$($x.RoundtripTime)"
        }
    }
    else {
        if ($ResolveNames) {
            Write-Output "$addr`t----------------`toffline"
        }
        else {
            Write-Output "$addr`toffline"
        }
    }
}
