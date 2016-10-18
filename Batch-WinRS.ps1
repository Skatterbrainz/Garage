$Servers = Get-Content "servers.txt"

$RunThis = "\\Server1\Apps\Scripts\whatev.bat"

foreach ($Server in $Servers) {
    Write-Output "winrs -r:$Server -u:BigKahuna -p:P@ssw0rd123 $RunThis"
}
