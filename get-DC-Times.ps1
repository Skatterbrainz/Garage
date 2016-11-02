Import-Module ActiveDirectory

$DClist = (Get-ADForest).Domains | %{Get-ADDomainController -Filter * -Server $_} | Select-Object Name
$dcn = $DClist.Length

Foreach ($DC in $DClist) {
    $DCName = $DC.Name
    if (Test-Connection -ComputerName $DCName -Count 1) {
        $LocalTime = Invoke-Command -ComputerName $DCName -ScriptBlock {get-date} 
        Write-Output "$DCName time = $LocalTime"
    }
    else {
        Write-Output "$DCName is unavailable"
    }
}

Write-Output "checked $dcn servers"