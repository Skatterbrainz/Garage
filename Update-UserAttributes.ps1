#requires -version 2
#requires -modules ActiveDirectory
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Update AD User Attribute values using CSV input file.

.DESCRIPTION
    Reads an input CSV (comma-separated value) data file to update
    specified attributes of Active Directory user accounts contained
    in the file.

.PARAMETER Filename
    [string] [required] Full path and filename of CSV input file
    IMPORTANT: The left-most column MUST contain the sAmAccountName values!

.PARAMETER Attributes
    [string/array] [optional] Name of individual attribute(s) to 
    process within the input CSV file.  If the CSV contains multiple
    columns (attribute assignments), this allows for selective
    processing rather than updating all attributes identified in
    the CSV input file.  If this parameter is omitted, or assigned to ""
    it implies the default action = process all columns/attributes.

.PARAMETER RowLimit
    [integer] [optional] Limit processing of CSV to top N rows only.
    If omitted or set to 0 (zero) all rows are processed.

.NOTES
    Version 2017.04.12.01 - David Stein - Initial release

.EXAMPLE
    Update-UserAttributes.ps1 -Filename "users.csv"

.EXAMPLE
    Update-UserAttributes.ps1 -Filename "users.csv" -Attributes mail

.EXAMPLE
    Update-UserAttributes.ps1 -Filename "users.csv" -Attributes mail,sn,l

#>

[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact="Medium")]
param (
    [parameter(Mandatory=$True,ValueFromPipeline=$True, HelpMessage="Path and filename of CSV input file")]
    [ValidateNotNullOrEmpty()]
    [Alias("CsvFile","InputFile")]
    [string] $Filename,
    
    [parameter(Mandatory=$False, HelpMessage="Attribute names or leave empty for all")]
    [string[]] $Attributes = "",

    [parameter(Mandatory=$False, HelpMessage="Limit processing to top N rows of CSV file")]
    [int] $RowLimit = 0
)

if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
    $bVerbose = $True
    Write-Host "Mode: Verbose" -ForegroundColor Magenta
}
else {
    Write-Host "Mode: Normal" -ForegroundColor Magenta
}

if ($PSCmdlet.MyInvocation.BoundParameters["WhatIf"].IsPresent) {
    $bWhatIf = $True
    Write-Verbose "WhatIf: True"
}
<#
.DESCRIPTION
    Show a progress bar during script execution
.PARAMETER Caption 
.PARAMETER Message 
.PARAMETER CurrentIndex 
.PARAMETER TotalCount 
.EXAMPLE 
.NOTES
#>

Function Show-Progress {
    param (
        [parameter(Mandatory=$True)] [string] $Caption = "Progress",
        [parameter(Mandatory=$False)] [string] $Message = "Please wait...",
        [parameter(Mandatory=$True)] [int] $CurrentIndex,
        [parameter(Mandatory=$True)] [int] $TotalCount
    )
    $pct = ($CurrentIndex / $TotalCount) * 100
    Write-Progress -Activity $Caption -Status "$Message" -PercentComplete $pct -Id 1
    #Start-Sleep 1
}

<#
.DESCRIPTION
Returns an array of column names from a specified CSV file
Ignores column headings which have an underscore prefix "_"

.PARAMETER InputFile
[string] path and filename of input CSV file
#>

function Get-UserAttributes {
    param (
        [parameter(Mandatory=$True)] [string] $InputFile 
    )
    $result = @()
	$csvRaw = Get-Content -Path $InputFile -TotalCount 1
    $csvRaw = $csvRaw -replace " ",""
	$result = $csvRaw.ToLower().Split(",") | Where-Object {$_ -notlike "_*"} | Where-Object {$_ -ne ""}
	$result = $result | Where-Object {$_ -ne "samaccountname"} | Where-Object {$_ -ne "name"} | Where-Object {$_ -ne "path"}
    return $result
}

if (!(Test-Path $Filename)) {
    Write-Warning "Input file not found: $Filename"
    break
}
Write-Verbose "info: reading input data file..."
$csvData = Import-Csv -Path $Filename
if ($RowLimit -gt 0) {
    $csvData = $csvData[0..$($RowLimit-1)]
}
$csvRows = $csvData.Count
Write-Verbose "info: loaded $csvRows entries"

if ($Attributes -ne "") {
    Write-Verbose "info: processing explicit attributes"
    $attnum = $Attributes.Count
}
else {
    Write-Verbose "info: processing all attributes"
    $Attributes = Get-UserAttributes -InputFile $Filename
    $attnum = $Attributes.Count
}
Write-Verbose "info: $attnum attributes were retrieved"

$counter = 0
foreach ($row in $csvData) {
    $sam = $row.samaccountname
    if ($bVerbose = $True) {
        Write-Host "Updating $($counter+1) of $csvRows`: $sam" -ForegroundColor Green
    }
    else {
        Show-Progress -Caption "Updating Accounts" `
            -Message "Updating $($counter+1) of $csvRows`: $sam" `
            -CurrentIndex $counter+1 `
            -TotalCount $csvRows
    }
    
    foreach ($att in $Attributes) {
        $val = $csvData[$counter]."$att"
        if ($val -ilike '*;*') {
            Write-Verbose "`tattribute: $att"
            Write-Verbose "`tvalue (multi-valued): $val"
            $nval = $val.Split(";")
        }
        else {
            Write-Verbose "`tattribute: $att"
            Write-Verbose "`tvalue (single-value): $val"
            $nval = $val
        }
        try {
            if ($bWhatIf -eq $True) {
                Set-ADUser -Identity $sam -replace @{"$att"=$nval} -WhatIf
            }
            else {
                Set-ADUser -Identity $sam -replace @{"$att"=$nval} -Confirm:$False
            }
            
        }
        catch {
            Write-Warning "[$($counter+1)] $sam -- $att could not be updated"
        }
    }
    $counter++
}
