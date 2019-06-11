#requires -modules AzureAD,MSOnline,Az

[CmdletBinding()]
param (
    $GAUserName = 'dave@skatterbrainz.xyz'
)

function Connect-AzCloud {
    param (
        [ValidateSet('azuread','azure','exo','msonline')]
        [string] $Environment
    )
    try {
        switch ($Environment) {
            'azuread' {
                $result = Connect-AzureAD
                break
            }
            'azure'   {
                $result = Connect-AzAccount
                break
            }
            'msonline' {
                Connect-MsolService
                $result = 0
                break
            }
            'exo' {
                Write-Verbose "closing existing sessions"
                Get-PSSession | Where-Object { $_.ComputerName -eq 'outlook.office365.com' -and $_.ConfigurationName -eq 'Microsoft.Exchange' } | Remove-PSSession -Confirm:$false

            }
        }
    }
    catch {}
    finally {
        $result
    }
}
try {
    if (!$aad) {
        $aad = Connect-AzureAD
    }
    if (!$aad) {
        Write-Warning "credentials are required in order to continue."
        break
    }
}
catch { }