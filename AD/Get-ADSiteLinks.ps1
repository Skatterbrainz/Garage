#requires -modules ActiveDirectory
param ()
$ADX = Get-ADObject -Filter 'objectClass -eq "siteLink"' -SearchBase (Get-ADRootDSE).ConfigurationNamingContext -Property Options, Cost, ReplInterval, SiteList, Schedule | 
    Select-Object Name, @{Name="SiteCount";Expression={$_.SiteList.Count}}, Cost, ReplInterval, @{Name="Schedule";Expression={If($_.Schedule){If(($_.Schedule -Join " ").Contains("240")){"NonDefault"}Else{"24x7"}}Else{"24x7"}}}, Options
$ADX | Format-Table
#$ADX | Out-GridView -Title "Active Directory Site Links"
