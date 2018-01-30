<#
refer to: https://msdn.microsoft.com/en-us/library/cs50ebzk(v=vs.110).aspx
#>
function Set-RegistryPermissions {
    param (
        [parameter(Mandatory=$True)] [string] $KeyPath,
        [parameter(Mandatory=$True)] [string] $AccountName,
        [parameter(Mandatory=$False)] [string] $OwnerName = "Administrators",
        [parameter(Mandatory=$True)] [ValidateSet("FullControl","Read","Write","Delete")] [string] $Permissions,
        [parameter(Mandatory=$True)] [ValidateSet("Allow","Deny")] [string] $Grant
    )

    $AddACL = New-Object System.Security.AccessControl.RegistryAccessRule ("$AccountName","$Permissions","ObjectInherit,ContainerInherit","None","$Grant")
    $owner = [System.Security.Principal.NTAccount]$OwnerName

    $keyCR = [Microsoft.Win32.Registry]::ClassesRoot.OpenSubKey($KeyPath,[Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::takeownership)

    # Get a blank ACL since you don't have access and need ownership
    $aclCR = $keyCR.GetAccessControl([System.Security.AccessControl.AccessControlSections]::None)
    $aclCR.SetOwner($owner)
    $keyCR.SetAccessControl($aclCR)

    # Get the acl and modify it
    $aclCR = $keyCR.GetAccessControl()
    $aclCR.SetAccessRule($AddACL)
    $keyCR.SetAccessControl($aclCR)
    $keyCR.Close()
}

$testkey = "HKLM:SOFTWARE\Contoso"
$testval = "fubar"

if (!(Test-Path $testkey)) {
    Write-Host "registry key not found, creating it now..."
    New-Item -Path $testkey
    New-ItemProperty -Path $testkey -Name $testval -Value "Test 1" -PropertyType string
}
else {
    Write-Host "registry key verified"
}

Set-RegistryPermissions -KeyPath $testkey -AccountName "Users" -Permissions FullControl -Grant Allow
