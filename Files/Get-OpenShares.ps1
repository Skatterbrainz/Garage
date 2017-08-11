
<#
.SYNOPSIS
    Returns not-hidden shares

.DESCRIPTION
    Returns the source paths of each share on one or more computers
    where the share is not hidden (has a "$" suffix)

.PARAMETER ComputerName
    [optional] [string] one or more computer name to query.  If not
    specified, the local computer is queried

.NOTES
    Author: David Stein
    Date created: 11/02/2015
    Date updated: 04/20/2017

.EXAMPLE
    Get-OpenShares -ComputerName fs1,fs2,fs3
    
#>

function Get-OpenShares {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$False, HelpMessage="Name of computer")]
        [string[]] $ComputerName
    )
    if (!($ComputerName)) { $ComputerName = "." }

    foreach ($Computer in $ComputerName) {
        try {
            $openshares = Get-WmiObject -ComputerName $Computer -Class Win32_Share -Filter "NOT name LIKE '%$'" -Property Path -ErrorAction Stop
            $props = @{
                "ComputerName" = $Computer;
                "Shares" = $openShares | Select-Object -ExpandProperty Path;
                "Status" = 1;
            }
        }
        catch {
            $props = @{
                "ComputerName" = $Computer;
                "Shares" = $null;
                "Status" = 0;
            }
        }
        $obj = New-Object -TypeName PSObject -Property $props
        Write-Output $obj
    }
}
