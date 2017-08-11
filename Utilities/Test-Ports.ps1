<#
.SYNOPSIS
    Test-Ports.ps1
    query availability of specific remote ports via TCP or UDP

.DESCRIPTION
    This script will return results of attempted query against
	specified TCP or UDP port for a remote host.
 
.PARAMETER ComputerName
    NetBIOS name or IP address of remote host
 
.PARAMETER PortNumber
    Number of TCP or UDP port to query

.PARAMETER Protocol
    TCP or UDP (default is TCP)

.PARAMETER Timeout
    milliseconds to wait for response (default = 1000)

.EXAMPLE
     
 .NOTES
    FileName:    Test-Ports.ps1
    Author:      David Stein
    Created:     2016-08-11
    Updated:     2016-10-08
    Version:     1.0.1

#>

param (
    [parameter(Mandatory=$True)] 
    	[string] $ComputerName,
    [parameter(Mandatory=$True)] 
    	[int64] $PortNumber,
    [parameter(Mandatory=$False)] 
        [ValidateSet('TCP','UDP')]
        [string] $Protocol = 'TCP',
    [parameter(Mandatory=$False)] 
    	[int64] $Timeout = 1000
)

if ($Protocol -eq 'TCP') {
    $tcpClient = New-Object System.Net.Sockets.TcpClient
}
else {
    $tcpClient = New-Object System.Net.Sockets.UdpClient
}
$iar = $tcpClient.BeginConnect($ComputerName,$PortNumber,$null,$null)
$wait = $iar.AsyncWaitHandle.WaitOne($Timeout,$False)
if (!$wait) {
    $tcpClient.Close()
    $failed = $True
}
else {
    $tcpClient.EndConnect($iar) | Out-Null
    if(!$?) {
        $failed = $True
    }
    else {
        $failed = $False
    }
    $tcpclient.Close()
}
if (-not($failed)) {
	Write-Output $True
}
