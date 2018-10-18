function Get-ElapsedRunTime {
    param (
        $StartTime,
        [int] $ItemCount
    )
    $elapsed  = New-TimeSpan -Start $StartTime -End $(Get-Date)
    $eminutes = $elapsed.TotalMinutes
    $eseconds = $elapsed.TotalSeconds
    $avgtime = [math]::Round($eseconds / $ItemCount, 2)
    Write-Output "$([math]::Round($eminutes,1)) minutes ($avgtime seconds per item)"
}
