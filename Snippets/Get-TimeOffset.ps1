$StartTime = Get-Date

# ... do something ...

$StopTime = Get-Date
$Offset = [timespan]::FromSeconds(((New-TimeSpan -Start $StartTime -End $StopTime).TotalSeconds).ToString()).ToString("hh\:mm\:ss")
Write-Output "Processing completed. Total runtime: $Offset (hh`:mm`:ss)"
