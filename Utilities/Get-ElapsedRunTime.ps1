function Get-ElapsedRunTime {
    [CmdletBinding()]
    param (
        $StartTime,
        [int] $CurrentItem,
        [int] $ItemCount,
        [switch] $EstimateCompletion
    )
    $elapsed  = New-TimeSpan -Start $StartTime -End $(Get-Date)
    $eminutes = $elapsed.TotalMinutes
    $eseconds = $elapsed.TotalSeconds
    $avgtime = [math]::Round($eseconds / $CurrentItem, 2)
    Write-Verbose "    total items....: $ItemCount"
    Write-Verbose "    current item...: $CurrentItem"
    Write-Verbose "    elapsed minutes: $eminutes"
    Write-Verbose "    elapsed seconds: $eseconds"
    Write-Verbose "    average seconds: $avgtime"
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
