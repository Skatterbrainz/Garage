[cmdletbinding()]
param()

$Sites = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites

foreach ($Site in $Sites) {

    $obj = New-Object -Type PSObject -Property (
        @{
            "SiteName"  = $site.Name;
            "SubNets" = $site.Subnets;
            "Servers" = $Site.Servers
        }
    )
    $Obj
}