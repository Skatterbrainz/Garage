#requires -module ActiveDirectory
#requires -RunAsAdministrator

<#
.SYNOPSIS
    Returns last login timestamp for all users

.DESCRIPTION
    Returns last login timestamp for all users in 
    the current AD forest/domain by querying all
    domain controllers

.PARAMETER UserName
    [string] SAM Account Name value
    
.EXAMPLE
    Get-ADUserLastLogon -UserName "jsmith"

.EXAMPLE
    Get-ADUser -Filter * | Select-Object -ExpandProperty sAMAccountName | Get-ADUserLastLogon

.NOTES
    Author: David Stein
    Date created: 04/01/2017
#>

function Get-ADUserLastLogon {
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory=$True, 
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage="User ID"
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('sAMAccountName','cn')]
        [string] $UserName
    )
    BEGIN {}
    PROCESS {
        $dcs  = Get-ADDomainController -Filter {Name -like "*"}
        $time = 0
        foreach($dc in $dcs) { 
            $hostname = $dc.HostName
            try {
                $user = Get-ADUser "$userName" | Get-ADObject -Properties lastLogon -ErrorAction Stop
                if ($user.LastLogon -gt $time) {
                    $time = $user.LastLogon
                    $props = @{
                        "sAMAccountName" = $userName;
                        "DC" = $hostname;
                        "LastLogon" = [DateTime]::FromFileTime($time);
                        "Status" = 1;
                    }
                    $obj = New-Object -TypeName PSObject -Property $props
                }
                else {
                    $props = @{
                        "sAMAccountName" = $userName;
                        "DC" = $hostname;
                        "LastLogon" = 'Never';
                        "Status" = 2;
                    }
                    $obj = New-Object -TypeName PSObject -Property $props
                }
            }
            catch {
                $props = @{
                    "sAMAccountName" = $userName;
                    "DC" = $hostname;
                    "LastLogon" = 'Never';
                    "Status" = 0;
                }
                $obj = New-Object -TypeName PSObject -Property $props
            }
            Write-Output $obj
        }
    }
    END {}
}

Get-ADUser -Filter * | 
    Select-Object -ExpandProperty sAMAccountName | 
        Get-ADUserLastLogon
