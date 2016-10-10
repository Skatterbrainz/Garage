$Servers = Get-Content "C:\Users\davidstein\Documents\Scripts\PowerShell\servers.txt"

$RunThis = "\\Server22\stuff\coolstuff.bat"

foreach ($Server in $Servers) {
    Write-Output "winrs -r:$Server -u:BigKahuna -p:P@ssw0rd $RunThis"
}
