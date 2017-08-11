#requires -RunAsAdministrator

function Test-DomainController {
    param (
        [parameter(Mandatory=$False, Position=0)]
        [string] $ComputerName = ""
    )
    if ($ComputerName -ne "") {
        try {
            $result = (!!(Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ComputerName -Filter "DomainRole > 4"))
        }
        catch {
            Write-Warning "unable to access WMI data"
            break
        }
    }
    else {
        try {
            $result = (!!(Get-WmiObject -Class Win32_ComputerSystem -Filter "DomainRole > 4"))
        }
        catch {
            Write-Warning "unable to access WMI data"
            break
        }
    }
    Write-Output $result
}

# examples

if (Test-DomainController) { Write-Host "This is a domain controller" }
if (Test-DomainController "DC3") { Write-Host "DC3 is a domain controller" }
