<#
.DESCRIPTION
  Weird bastardized script that reads computer names from a file and 
  queries each machine to identify WINWORD.exe and file version
#>
[CmdletBinding()]
param (
    [string] $InputFile = ".\lists\computers-win10.txt",
    [string] $ReportFile = ".\reports\DailyBatch\Office-Installs.csv"
)
if (!(Test-Path $InputFile)) {
    Write-Warning "$InputFile not found!!"
    break
}

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

$time1 = Get-Date
$computers = Get-Content $InputFile

$ctotal = $computers.Count
$ccount = 1

$officeInstalls = $computers | 
    Foreach-Object { 
        $elapsed = Get-ElapsedRunTime -StartTime $time1 -ItemCount $ctotal -EstimateCompletion
        #$elapsed = "$([math]::Round((new-timespan -Start $time1 -End $(Get-Date)).TotalMinutes,2)) minutes"
        Write-Progress -Activity "[$ccount of $ctotal] $_ ($elapsed)" -Status "Querying Office Files" -PercentComplete (($ccount / $ctotal)*100)
        .\Get-OfficeFileVersion.ps1 -ComputerName $_ 
        $ccount++
    }

Write-Host "writing results to $ReportFile" -ForegroundColor Cyan
$officeInstalls | Export-Csv -Path $ReportFile -NoTypeInformation -Force

$time2 = Get-Date

Write-Host "finished processing $($computers.count) computers" -ForegroundColor Green
New-TimeSpan -Start $time1 -End $time2
