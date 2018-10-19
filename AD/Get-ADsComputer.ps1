[CmdletBinding()]
param (
    [parameter(Mandatory=$False, HelpMessage="Computer to filter on, or blank for all computers")]
    [string] $ComputerName = ""
)
if (![string]::IsNullOrEmpty($ComputerName)) {
    $as = [adsisearcher]"(&(objectCategory=Computer)(name=$ComputerName))"
}
else {
    $as = [adsisearcher]"(objectCategory=Computer)"
}
$as.PropertiesToLoad.Add('cn') | Out-Null
$as.PropertiesToLoad.Add('lastlogonTimeStamp') | Out-Null
$as.PropertiesToLoad.Add('whenCreated') | Out-Null
$as.PropertiesToLoad.Add('operatingSystem') | Out-Null
$as.PropertiesToLoad.Add('operatingSystemVersion') | Out-Null
$as.PropertiesToLoad.Add('distinguishedName') | Out-Null
$as.PageSize = 200
$as.FindAll() | 
    ForEach-Object {
        $cn = ($_.properties.item('cn') | Out-String).Trim()
        [datetime]$created = ($_.Properties.item('whenCreated') | Out-String).Trim()
        $llogon = ([datetime]::FromFiletime(($_.properties.item('lastlogonTimeStamp') | Out-String).Trim())) 
        $ouPath = ($_.Properties.item('distinguishedName') | Out-String).Trim() -replace $("CN=$cn,", "")
        $props = [ordered]@{
            Name       = $cn
            OS         = ($_.Properties.item('operatingSystem') | Out-String).Trim()
            OSVer      = ($_.Properties.item('operatingSystemVersion') | Out-String).Trim()
            DN         = ($_.Properties.item('distinguishedName') | Out-String).Trim()
            OU         = $ouPath
            Created    = $created
            LastLogon  = $llogon
        }
        New-Object PSObject -Property $props
    }
