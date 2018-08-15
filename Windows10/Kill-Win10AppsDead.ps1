param (
    [parameter(Mandatory=$False, HelpMessage="Source URL")]
    [ValidateNotNullOrEmpty()]
    [string] $Source = "https://raw.githubusercontent.com/Sycnex/Windows10Debloater/master/Windows10SysPrepDebloater.ps1"
)

$baseName  = "Windows10SysPrepDebloater.ps1"
$localFile = Join-Path -Path $env:TEMP -ChildPath $baseName

try {
    Write-Host "downloading: $Source" -ForegroundColor Cyan
    $(New-Object System.Net.WebClient).DownloadFile($Source, $localFile) | Out-Null
}
catch {
    Write-Warning $_.Exception.Message
}
if (Test-Path $localFile) {
    Write-Host "downloaded successfully" -ForegroundColor Cyan
    cd $env:TEMP
    .\Windows10SysPrepDebloater.ps1 -Debloat -Sysprep -StopEdgePDF -Privacy
    Write-Host "finished" -ForegroundColor Green
}
else {
    Write-Warning "failed to download script"
}
