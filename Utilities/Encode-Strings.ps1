<#
.SYNOPSIS
    Contains functions to encode (obfuscate) and decode string values
    using classic "ASCII chunking" method. It's chunkatastic.

.NOTE
    Author: David M. Stein
    Date Created: 03/04/2014
    Date Modified: 10/17/2016
#>


<#
.SYNOPSIS
    Encode-String converts a readable string value into a semi-encoded
    parsable sequence of ASCII codes, where each is padded to a consistent
    length to enable decoding.  The output also appends a $Delimiter character
    followed by the integer value for the character length of the source string.

.PARAMETER InputString
    String value to be encoded. Required.

.PARAMETER ChunkSize
    The parsable character component length on which to break the
    input code into for converting each back to the original ASCII
    character.
    Default is 3.

.PARAMETER Delimiter
    The Character to use for appending the length onto the encoded output
    Default is "Z".

.EXAMPLE
    Encode-String "\\SERVER1\Apps"
    returns: "092092083069082086069082049092065112112115Z014"

.NOTE
    Notice in the example that the tail end includes "Z014".
    This is "Z" followed by "014" or 14 to indicate the original
    character length of the source string.
#>

function Encode-String {
    param (
        [parameter(Mandatory=$True)]
        [string] $InputString,
        [parameter(Mandatory=$False)]
        [int] $ChunkSize = 3,
        [parameter(Mandatory=$False)]
        [string] $Delimiter = "Z"
    )
    $len = $InputString.Length
    $output = ""
    for ($i = 0; $i -lt $len; $i++) {
        $c = $InputString.Substring($i,1)
        $a = [byte][char]$c
        $aa = Pad-String -StringVal $a -PadSize $ChunkSize
        $output += $aa
    }
    $output += "$Delimiter$(Pad-String -StringVal $len -PadSize 3)"
    $output
}

<#
.SYNOPSIS
    Decode-String parses an obfuscated string value which is 
    based on sub-strings which are $ChunkSize characters in length
    along with an appended source length value, separated by a 
    delination character.

.PARAMETER InputCode
    encoded string value consisting of chunked ASCII codes combined
    with the source value length.  Required.

.PARAMETER ChunkSize
    The parsable character component length on which to break the
    input code into for converting each back to the original ASCII
    character.
    Default is 3.

.PARAMETER Delimiter
    Character used to parse the input to separate the actual 
    encoded source value from the embedded source length value.
    Default is "Z".

.EXAMPLE
    Decode-String "092092082055049048045049" 3 "Z"
    returns: "\\R710-1"
#>

function Decode-String {
    param (
        [parameter(Mandatory=$True)]
        [string]$InputCode,
        [parameter(Mandatory=$False)]
        [int] $ChunkSize = 3,
        [parameter(Mandatory=$False)]
        [string] $Delimiter = "Z"
    )
    $temp = $InputCode.Split($Delimiter)
    $Source = $temp[0]
    $SrcLen = $temp[1]
    $output = ""
    $len = $Source.Length
    $chunks = $len
    for ($i = 0; $i -lt $chunks; $i+=$ChunkSize){
        $code = [int]$Source.Substring($i,$ChunkSize)
        $char = [char]$code
        $output += $char
    }
    $output
}

<#
.SYNOPSIS
    Pad-String returns a string value using the provided $StringVal input
    and pads a leading zero (0) character to the left until
    the total character length is equal to $PadSize

.PARAMETER StringVal
    String value to be padded. Required.

.PARAMETER PadSize
    Integer value to indicate the character length to be returned.
    Default is 3.

.EXAMPLE
    Pad-String 4 3
    returns: "004"

.EXAMPLE
    Pad-String -StringVal "33" -PadSize 4
    returns: "0033"
#>

function Pad-String {
    param (
        [parameter(Mandatory=$True)] [string] $StringVal,
        [parameter(Mandatory=$False)] [int] $PadSize = 3
    )
    if ($StringVal.GetType().Name -eq 'String') {
        $output = $StringVal
        while ($output.Length -lt $PadSize) {
            $output = "0$Output"
        }
    }
    elseif ($StringVal.GetType().Name -eq 'Int32') {
        if ($Stringval -lt 10) {
            $output = "00$StringVal"
        }
        elseif ($StringVal -lt 100) {
            $output = "0$StringVal"
        }
        else {
            $output = "$StringVal"
        }
    }
    $output
}

# ---------------------------------------------------------

$test = "\\SERVER1\Apps"

$encoded = Encode-String $test

$decoded = Decode-String $encoded

Write-Host "encoded: $encoded"

Write-Host "decoded: $decoded"
