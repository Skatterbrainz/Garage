$Servers  = Get-Content "servers.txt"
$RunThis  = "\\Server1\Apps\Scripts\whatev.bat"
$UserName = "AdminUser"
$Password = 'P@ssW0rd123'

foreach ($Server in $Servers) {
    Write-Output "winrs -r:$Server -u:$UserName -p:$Password $RunThis"
}
