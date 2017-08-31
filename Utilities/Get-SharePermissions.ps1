[CmdletBinding()]
<#
.SYNOPSIS
    enumerate shares and share permissions
.DESCRIPTION
    enumerate all shares and share permissions on one or more computers
.PARAMETER Computers
    [string] (optional) Name(s) of computers to query. Default = "."
.NOTES
    David Stein 08/30/2017
.EXAMPLE
    Get-SharePermissions -Computers FS1,FS2,FS3
.EXAMPLE
    Get-SharePermissions -Computers FS1,FS2,FS3 | Where-Object {$_.ShareName -eq 'Docs'}
#>

param (
    [parameter(Mandatory=$False)]
        [string[]] $Computers = "."
)

function Get-ICaclsCode {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $AclString
    )
    # example: "CREATOR OWNER:(OI)(CI)(IO)(WDAC,WO,GR,GW,GE)"
    $baseString = $AclString.Split(':')[1]
    # result: "(OI)(CI)(IO)(WDAC,WO,GR,GW,GE)"
    if ($baseString -and ($baseString.Trim() -ne '')) {
        $codes = $baseString.Split(')(') | Where-Object {$_ -ne ''}
        foreach ($code in $codes) {
            switch ($code) {
                'OI' { 'object inherit'; break }
                'CI' { 'container inherit'; break }
                'IO' { 'inherit only'; break }
                'NP' { 'no propagate'; break }
                default {
                    foreach ($subcode in $code.Split(',')) {
                        switch ($subcode) {
                            'F'    { 'full access'; break }
                            'M'    { 'modify access'; break }
                            'RX'   { 'read and execute access'; break }
                            'R'    { 'read-only access'; break }
                            'W'    { 'write-only access'; break }
                            'D'    { 'delete'; break }
                            'RC'   { 'read control'; break }
                            'WDAC' { 'write DAC'; break }
                            'WO'   { 'write owner'; break }
                            'S'    { 'synchronize'; break }
                            'AS'   { 'access system security'; break }
                            'MA'   { 'maximum allowed'; break }
                            'GR'   { 'generic read'; break }
                            'GW'   { 'generic write'; break }
                            'GE'   { 'generic execute'; break }
                            'GA'   { 'generic all'; break }
                            'RD'   { 'read data/list directory'; break }
                            'WD'   { 'write data/add file'; break }
                            'AD'   { 'append data/add subdirectory'; break }
                            'REA'  { 'read extended attributes'; break }
                            'WEA'  { 'write extended attributes'; break }
                            'X'    { 'execute/traverse'; break }
                            'DC'   { 'delete child'; break }
                            'RA'   { 'read attributes'; break }
                            'WA'   { 'write attributes'; break }
                        } # switch
                    } # foreach
                }
            } # switch
        } # foreach
    }
}

foreach ($computer in $computers) {
    if ($computer -eq '.') {
        $computer = $env:COMPUTERNAME
    }
    $shares = Get-WmiObject -Class Win32_Share -ComputerName $computer
    foreach ($share in $shares) {
        $shareName  = $share.Name
        $shareComm  = $share.Description
        $sharePath  = $share.Path
        $basePath   = "\\$computer\"
        $localPath  = $($share.path.Replace(':','$'))
        $remotePath = "\\$computer\$localPath"
        
        Write-Verbose "share name.... $shareName"
        Write-Verbose "share comment. $shareComm"
        Write-Verbose "share path.... $sharePath"
        Write-Verbose "remotePath.... $remotePath"

        if ($basePath -ne $remotePath) {
            $cacls = icacls "$remotepath"
            $plist = $($cacls | %{$_.Replace("$remotePath","")}) | %{$_.Trim()}
            # write-verbose "-----------------------------------"
            # $plist
            # write-verbose "-----------------------------------"
            foreach ($descriptor in $plist) {
                if (($descriptor -ne "") -and (-not($descriptor.StartsWith("Successfully")))) {
                    $perms = Get-ICaclsCode -AclString $acl
                    $data  = [ordered]@{
                        ComputerName = $computer
                        ShareName    = $shareName
                        Description  = $shareComm
                        LocalPath    = $sharePath
                        Descriptor   = $acl
                        Permissions  = $perms
                    }
                    New-Object -TypeName PSObject -Property $data
                }
            } # foreach
        }
    } # foreach
}
