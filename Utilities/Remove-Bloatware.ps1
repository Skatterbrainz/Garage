$apps = ('duolingo','photoshop','networkspeedtest','sway','eclipse','skype','bingweather','bingnews','remotedesktop')

foreach ($app in $apps) {
  write-host "removing: $app"
  try {
    Get-AppxPackage "*$app*" | Remove-AppxPackage | Out-Null
  }
  catch {
    write-error $_.Exception.Message
  }
}
