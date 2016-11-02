$openshares = Get-WmiObject -Class Win32_Share -Filter "NOT name LIKE '%$'" -Property Path
$openshares | foreach {$_.Path}
$openshares.__PROPERTY_COUNT.count

