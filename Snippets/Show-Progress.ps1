function Show-Progress {
    param (
        [parameter(Mandatory=$True,Position=0)] [int] $DelaySeconds,
        [parameter(Mandatory=$False)] [string] $Caption = "Doing Something",
        [parameter(Mandatory=$False)] [string] $Message = "Please wait..."
    )
    if ($DelaySeconds -gt 1) {
        $x = 1
        Do {
            $pct = ($x / $DelaySeconds) * 100
            Write-Progress -Activity $Caption -Status "$Message ($DelaySeconds seconds)..." -PercentComplete $pct -Id 1
            Start-Sleep 1
            $x++
        } While ($x -le $DelaySeconds)
        Write-Host "Continuing..." -ForegroundColor Green -BackgroundColor Black
    }
}

Show-Progress -DelaySeconds 10 -Caption "Waiting for Server"
