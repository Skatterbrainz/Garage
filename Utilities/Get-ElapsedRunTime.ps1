function Get-ElapsedRunTime {
    param (
        $StartTime,
        [int] $ItemCount,
        [switch] $EstimateCompletion
    )
    $elapsed  = New-TimeSpan -Start $StartTime -End $(Get-Date)
    $eminutes = $elapsed.TotalMinutes
    $eseconds = $elapsed.TotalSeconds
    $avgtime = [math]::Round($eseconds / $ItemCount, 2)
    if ($EstimateCompletion) {
        $totalSeconds = [math]::Round($avgtime * $ItemCount,2)
        $estFinish = Get-Date($StartTime).AddSeconds($totalSeconds)
        $suffix = " (Estimated Finish: $estFinish)"
    }
    else {
        $suffix = ""
    }
    Write-Output "$([math]::Round($eminutes,1)) minutes ($avgtime seconds per item)$suffix"
}
