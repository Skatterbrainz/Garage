param (
    [parameter(Mandatory=$False, HelpMessage="Source URL")]
    [ValidateNotNullOrEmpty()]
    [string] $WebPath = "https://raw.githubusercontent.com/OfficeDev/Office-IT-Pro-Deployment-Scripts/master/Office-ProPlus-Deployment/Remove-PreviousOfficeInstalls"
)

function Join-Url {
    param (
        [string] $Path,
        [string] $ChildPath
    )
    if ($Path.EndsWith('/')) {
        return "$Path"+"$ChildPath"
    }
    else {
        return "$Path/$ChildPath"
    }
}
$continue = $True

$files = @("OffScrub03.vbs","OffScrub07.vbs","OffScrub10.vbs","OffScrub_O15msi.vbs",
    "OffScrub_O16msi.vbs","OffScrubc2r.vbs","Remove-PreviousOfficeInstalls.ps1")

foreach ($f in $files) {
    $remoteFile = Join-Url -Path $WebPath -ChildPath $f
    $localFile  = Join-Path -Path $env:TEMP -ChildPath $f
    try {
        Write-Host "downloading: $remoteFile" -ForegroundColor Cyan
        $(New-Object System.Net.WebClient).DownloadFile($remoteFile, $localFile) | Out-Null
    }
    catch {
        Write-Warning $_.Exception.Message
    }
    if (Test-Path $localFile) {
        Write-Host "downloaded successfully" -ForegroundColor Cyan
    }
    else {
        Write-Warning "error: failed to download"
        $continue = $null
    }
}
if ($continue) {
    cd $env:TEMP
    .\Remove-PreviousOfficeInstalls.ps1
}
Write-Host "finished" -ForegroundColor Green
