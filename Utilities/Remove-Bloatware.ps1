<#
AppxList.txt

Duolingo
Photoshop
Networkspeedtest
Sway
Eclipse
Skype
Bingweather
Bingnews
Pandora
Remotedesktop
Xboxapp
OneConnect
Onenote
Netflix
# add more
#>

$error.Clear()

$apps = Get-Content “AppxList.txt”

foreach ($app in $apps) {
  Write-Host "removing: $app"
  try {
    Get-AppxPackage -AllUsers "*$app*" | Remove-AppxPackage | Out-Null
  }
  catch {
    Write-Error $_.Exception.Message
  }
  try {
    Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like “*$app*”} | Remove-AppxProvisionedPackage -Online | Out-Null
  }
  catch {
    Write-Error $_.Exception.Message
  }
}
Write-Output $($error.Count)
