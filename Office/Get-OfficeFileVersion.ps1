[CmdletBinding()]
param (
    [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $ComputerName,
    [parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string] $FileName = "WINWORD.exe"
)

$wdpath1 = "\\$ComputerName\C`$\Program Files\Microsoft Office\root\Office16\$FileName"
$wdpath2 = "\\$ComputerName\C`$\Program Files (x86)\Microsoft Office\Root\Office16\$FileName"

if (Test-Path $wdpath1 -ErrorAction SilentlyContinue) {
    $plat = 64
    $f = Get-Item -Path $wdpath1 -ErrorAction SilentlyContinue
    $wdver = $f.VersionInfo.ProductVersion
}
elseif (Test-Path $wdpath2 -ErrorAction SilentlyContinue) {
    $plat = 32
    $f = Get-Item -Path $wdpath2 -ErrorAction SilentlyContinue
    $wdver = $f.VersionInfo.ProductVersion
}
else {
    $plat  = $null
    $wdver = $null
}
Write-Verbose "office type  = $plat"
Write-Verbose "word version = $wdver"
$data = [ordered]@{
        Computer  = $ComputerName
        OfficePkg = $plat
        OfficeVer = $wdver
    }
New-Object -TypeName PSObject -Property $data
