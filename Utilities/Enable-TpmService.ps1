<#
.SYNOPSIS
   Enable BitLocker TPM services on client
.DESCRIPTION
   Check for current TPM status.  If not enabled, then attempt to enable it.
.PARAMETER ComputerName
   Name of remote computer, or "" (or omit parameter) for local computer
.EXAMPLE
   Enable-TpmService.ps1
   Enable-TpmService.ps1 -ComputerName "client123"
#>

param (
	[parameter(Mandatory=$False)] [string] $ComputerName = ""
)
if ($ComputerName -ne "") {
	$tpm = Get-WmiObject -Namespace ROOT\CIMV2\Security\MicrosoftTpm -Class Win32_Tpm -ComputerName $ComputerName
}
else {
	$tpm = Get-WmiObject -Namespace ROOT\CIMV2\Security\MicrosoftTpm -Class Win32_Tpm
}
if ($tpm.IsEnabled().isenabled -eq $false) {
    Write-Host "TPM is not enabled.  Enabling now..."
    $tpm.Enable()
    if ($tpm.IsEnabled().isenabled -eq $true) {
        Write-Host "TPM is now enabled."
    }
    else {
        Write-Host "Failed to enable TPM."
    }
}
else {
    Write-Host "TPM is already enabled."
}
