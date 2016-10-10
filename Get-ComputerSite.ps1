function Get-ComputerSite ($ComputerName) {
    $site = nltest /server:$ComputerName /dsgetsite 2>$null
    if ($LASTEXITCODE -eq 0) {
        $site[0]
    }
    else {
        "DEFAULT"
    }
}

$sn = Get-ComputerSite $env:COMPUTERNAME

switch ($sn) {
    "NYC" {$ds = "\\NYCFS01\apps$\acad2016"; break;}
    "SFO" {$ds = "\\SFFS01\apps$\acad2016"; break;}
    "MIA" {$ds = "\\MIAFS01\apps$\acad2016"; break;}
    "CHI" {$ds = "\\CHIFS03\apps$\acad2016"; break;}
    default {$ds = "\\CORPFS04\apps$\acad2016"; break;}
}

$cmd = "`"$ds\img\setup.exe`" /I /Q /W `"$ds\img\acad2016.ini`" /Language en-us"

Write-Host $cmd 