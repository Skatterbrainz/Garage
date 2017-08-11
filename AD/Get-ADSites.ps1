[cmdletbinding()]
param()

$Sites = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites

foreach ($Site in $Sites) {
    $props = @{
        "SiteName" = $site.Name;
        "Subnets" = $site.Subnets;
        "Servers" = $site.Servers
        }
    $obj = New-Object -Type PSObject -Property $props
    Write-Output $Obj
}
