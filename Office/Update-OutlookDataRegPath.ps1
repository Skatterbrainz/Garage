
#requires -version 3
<#
.SYNOPSIS
    Update User Outlook 2016 Profile Data Path

.DESCRIPTION
    Compares OST folder path value stored in registry with
    actual user profile path.  If different, the registry
    value is updated to match the actual user profile path

.PARAMETER Commit
    [switch] If -Commit is invoked, the registry value is
    updated if the path values require correction.
    If not invoked, the registry value '0000TEST' is written
    to with the corrected path if required.

.NOTES
    If the registry path value is already correct, no changes
    are made, regardless of the -Commit parameter.

    If the registry path value is incorrect, and -Commit
    is used, the corrected path data is written to a test
    registry value '0000TEST', rather than the actual value
    which updates Outlook.

    If the registry path value is incorrect, and -Commit 
    is NOT used, the corrected path data is written to 
    the actual registry value which updates Outlook.

    Version: 2017.04.26.02
    Author: David Stein

#>
[CmdletBinding(
    SupportsShouldProcess=$True, 
    ConfirmImpact='Medium'
)]
param (
    [parameter(Mandatory=$False,HelpMessage="Commit to session environment")]
    [switch] $Commit
)

$HKEY_LOCAL_MACHINE = 2147483650 
$HKEY_CURRENT_USER  = 2147483649

# default registry key path for Outlook 2016 user profile data
$keyBase = "SOFTWARE\Microsoft\Office\16.0\Outlook\Profiles\Outlook"

# key which stores value that points to another key/value that holds actual path data
$key1 = "$keyBase\0a0d020000000000c000000000000046"
$val1 = '01023d15'

# value under other key which holds actual path data
$val2 = '001f6610'

if ($Commit) {
    $val3 = $val2
}
else {
    $val3 = '0000TEST'
}

function Get-RegBinaryValue {
    param ($Hive, $KeyPath, $ValueName, [switch]$Pack)
    $reg = [WMIClass]"ROOT\DEFAULT:StdRegProv"
    $dataval = $reg.GetBinaryValue($Hive, $KeyPath, $ValueName)
    $temp = @()
    foreach ($byte in $dataval.uValue) {
        $part = "{0}" -f $byte.ToString("x")
        if ($part -ne 0) {
            $temp += $part
        }
    }
    if ($Pack) {
        $temp = $temp -join ""
    }
    else {
        $temp = $temp -join ' '
    }
    Write-Output $temp
}

function Convert-HexToString {
    param (
        [parameter(Mandatory=$True, HelpMessage="Space-delimited string of Hex values to convert to ASCII string")]
        [ValidateNotNullOrEmpty()]
        [string] $HexString
    )
    # convert array of byte codes into an array of ASCII chars
    $chars = $HexString -split ' ' | ForEach-Object {[char][byte]"0x$_"}
    # join the array into a string
    $result = $chars -join ""
    Write-Output $result
}

function Convert-StringToHex {
    param (
        [parameter(Mandatory=$True, HelpMessage="String to convert to Hexadecimal")]
        [ValidateNotNullOrEmpty()]
        [string] $StringVal
    )
    $b = $StringVal.ToCharArray()
    $c = ""
    foreach ($element in $b) {
        $c = $c + " " + [System.String]::Format("{0:X}",[System.Convert]::ToUint32($element))
    }
    $c = $c.Trim()
    $chex = $c.Split(' ') | ForEach-Object {"0x$_"}
    Write-Output $chex
}

function Get-UserProfileDataPath {
    param (
        [parameter(Mandatory=$True, HelpMessage="Folder path string")]
        [ValidateNotNullOrEmpty()]
        [string] $Path
    )
    # compare path value in registry to actual user profile path
    $olduser = $($Path -split "\\")[2]
    $newuser = $env:USERNAME
    if ($olduser -ne $newuser) {
        # registry path and actual path are different!
        Write-Output = $Path -replace $olduser,$newuser
    }
    else {
        # registry path matches actual path
        Write-Output $Path
    }
}

# get key/value that holds the actual path value
$k2 = Get-RegBinaryValue -Hive $HKEY_CURRENT_USER -KeyPath $key1 -ValueName $val1 -Pack
$key2 = "$keyBase\$k2"

# query the key/value for the actual path value
$p1 = Get-RegBinaryValue -Hive $HKEY_CURRENT_USER -KeyPath $key2 -ValueName $val2

# convert path from hex data to string value
$path1 = Convert-HexToString -HexString $p1
write-verbose "registry path: $path1"

$newpath = Get-UserProfileDataPath -Path $path1
Write-Verbose "required path: $newpath"

if ($path1 -ne $newpath) {
    Write-Verbose "corrected path: $newpath"

    # convert string to hex data for registry storage
    $hpath = Convert-StringToHex -StringVal $newpath

    # write binary hex data to registry
    if (!($Commit)) {
        Write-Verbose "testmode: writing to value $val3"
    }
    try {
        Write-Verbose "updating registry value..."
        New-ItemProperty -Path "HKCU:\$key2" -Name $val3 -PropertyType Binary -Value ([byte[]]$hpath) -Force -ErrorAction Stop
        
        # query value and convert back to string to validate results
        $p2 = Get-RegBinaryValue -Hive $HKEY_CURRENT_USER -KeyPath $key2 -ValueName $val3
        $path2 = Convert-HexToString -HexString $p2
        write-output $path2
    }
    catch {
        write-output "error: $($error[0].Exception)"
    }
}
else {
    write-output "registry path is correct"
}
