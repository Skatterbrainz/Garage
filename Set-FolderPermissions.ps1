
function Set-FolderPermissions {
    <#
    .SYNOPSIS
      This piece of code is probably going to make your eyeballs hurt.

    .DESCRIPTION
      Set-FolderPermissions is a low-budget, caffeine-restricted, duct-taped
      wrapper approach to using iCACLS for screwing up permissions on files
      and folders on a Windows system.

    .PARAMETER FolderPath
      The name of the poor, hapless folder or file you wish to ruin.

    .PARAMETER AccountName
      The user ID name of someone you don't like, whom can be blamed for
      the incorrect permissions you've applied while testing this out.

    .PARAMETER Permissions
      Can be Read, Write, Delete, Modify, or Full

    .PARAMETER Inherit
      Switch parameter to control inheritance to sub-folders and files

    .PARAMETER Traverse
      Switch parameter to force permissions on all matching sub-folders and files
      I'm still confused about Inherit vs Traverse, but I just pretend to understand
      them with a straight face and all is good.

    .LINK
      http://skatterbrainz.wordpress.com

    .EXAMPLE
      Set-FolderPermissions -FolderPath c:\testfolder1 -AccountName "USERS" -Permissions Full -Inherit -Traverse

    .EXAMPLE
      Set-FolderPermissions -FolderPath c:\testfolder2 -AccountName "USERS" -Permissions Modify

    #>
    param (
        [parameter(Mandatory=$True)] [string] $FolderPath,
        [parameter(Mandatory=$True)] [string] $AccountName,
        [parameter(Mandatory=$True)] [ValidateSet("Read","Write","Delete","Modify","Full")] [string] $Permissions,
        [parameter(Mandatory=$False)] [switch] $Inherit,
        [parameter(Mandatory=$False)] [switch] $Traverse
    )
    switch ($Permissions) {
        "Read"   {$pset = "(R)"; break}
        "Write"  {$pset = "(W)"; break}
        "Modify" {$pset = "(M)"; break}
        "Delete" {$pset = "(D)"; break}
        "Full"   {$pset = "(F)"; break}
    }

    if (!($Inherit)) {
        $inh = ""
    }
    else {
        $inh = "(OI)(CI)"
    }
    if (!($Traverse)) {
        icacls "$FolderPath" /grant "USERS:$inh$Pset" /C /Q
    }
    else {
        icacls "$FolderPath" /grant "USERS:$inh$pset" /T /C /Q
    }
}

md c:\testfolder1\sub1\sub2
md c:\testfolder2\sub1\sub2

Set-FolderPermissions -FolderPath c:\testfolder1 -AccountName "USERS" -Permissions Full -Inherit -Traverse

Set-FolderPermissions -FolderPath c:\testfolder2 -AccountName "USERS" -Permissions Modify
