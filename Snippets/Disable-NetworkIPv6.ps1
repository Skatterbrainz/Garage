<#
.DESCRIPTION
    Disables IPv6 on all active network adapter bindings
    
.NOTES
    Author: David M. Stein
    Date: 03/18/2017
#>

Start-Transcript -Path "$env:TEMP\disable_ipv6.log"
Get-NetAdapterBinding | 
    Where-Object {($_.ComponentId -eq 'ms_tcpip6') -and ($_.Enabled -eq $true)} | 
        Disable-NetAdapterBinding -ComponentID 'ms_tcpip6'
Stop-Transcript
