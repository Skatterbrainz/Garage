$apps = ('duolingo','photoshop','networkspeedtest','sway','eclipse','skype','bingweather','bingnews','pandora','remotedesktop','xboxapp')

foreach ($app in $apps) {
  write-host "removing: $app"
  try {
    Get-AppxPackage "*$app*" | Remove-AppxPackage | Out-Null
  }
  catch {
    write-error $_.Exception.Message
  }
}
