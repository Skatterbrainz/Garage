#requires -version 2
<#
.SYNOPSIS
    Return AD ServicePrinciple names
.PARAMETER Name
    [string] (optional) filter object by name
.NOTES
    DS - 03/20/2015
#>
param (
    [parameter(Mandatory=$False, ValueFromPipeline=$True)]
    [string] $Name = ""
)
$search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
$search.filter = "(servicePrincipalName=*)"
$results = $search.Findall()

foreach($result in $results) {
    $userEntry = $result.GetDirectoryEntry()
    if (($Name -eq "") -or (($Name -ne "") -and ($userEntry.name -like "$Name"))) {
        $data = [ordered]@{
            Name = $userEntry.name
            DistinguishedName = $userEntry.distinguishedName.ToString()
            ObjectCategory = $userEntry.objectCategory
            SPNList = $userEntry.servicePrincipalName
        }
        Write-Output $data
    }
}
