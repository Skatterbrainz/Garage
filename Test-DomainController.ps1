
function Test-DomainController {
    PARAM (
        [parameter(Mandatory=$False,Position=0)]
        [string] $ComputerName
    )
    if ($ComputerName.Length -gt 1) {
        $cs = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ComputerName -Filter "DomainRole > 4"
    }
    else {
        $cs = Get-WmiObject -Class Win32_ComputerSystem -Filter "DomainRole > 4"
    }
    if ($cs -ne $null) {
        Return $True
    }
}

if (Test-DomainController) {
    Write-Host "This is a DC"
}
else {
    Write-Host "This is NOT a DC"
}