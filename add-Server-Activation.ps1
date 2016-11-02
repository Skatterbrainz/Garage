Import-Module "ActiveDirectory"

$winkey = "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
$srvpat = "*scdp0*"
$TestOnly = $true

$servers = Get-ADComputer -Filter {(OperatingSystem -Like "Windows Server*") -and (Name -like $srvpat)} -Property * | Select-Object -Property Name

foreach ($Server in $Servers) {
    $ServerName = $Server.Name
    if (Test-Connection $ServerName -Count 1 -Quiet) {
        Write-Output "activating $ServerName..."
        if ($TestOnly -ne $true) {
            $service = Get-WmiObject -Query "select * from SoftwareLicensingService" -ComputerName $ServerName
            $service.InstallProductKey($winkey)
            $service.RefreshLicenseStatus()
        }
    }
    else {
        Write-Output "$ServerName is unavailable"
    }
}