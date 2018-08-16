#requires -version 3
<#
.SYNOPSIS

Searches for files by extension names

.DESCRIPTION

Search for files by extension across multiple locations

.PARAMETER Path

Starting or root-level path (or paths) to begin recursive search

.PARAMETER Extension

String comma-delimited list of extension labels

.PARAMETER OutputType

Output format type can be RAW, GRID, CSV, or HTML. Default is GRID (gridview)

.INPUTS

None.

.OUTPUTS

Raw data, CSV, HTML files, or Gridview output

.EXAMPLE

.\Find-Files.ps1 -Path F:\Users -Extension "docx,xlsx"

.EXAMPLE

.\Find-Files.ps1 -Path ("C:\users","F:\Users") -Extension "accdb" -OutputType HTML

.EXAMPLE

.\Find-Files.ps1 -Path ("C:\users","F:\Users") -Extension "accdb" -OutputType HTML -NoStyling

.EXAMPLE

.\Find-Files.ps1 -Path ("C:\users","F:\Users") -Extension "accdb" -OutputType CSV

.EXAMPLE

.\Find-Files.ps1 -Path ("C:\users","F:\Users") -Extension "accdb" -OutputType RAW
#>

param (
    [parameter(Mandatory=$True, HelpMessage="Search Path Root")]
        [ValidateNotNullOrEmpty()]
        [string[]] $Path,
    [parameter(Mandatory=$False, HelpMessage="File Extensions")]
        [ValidateNotNullOrEmpty()]
        [string] $Extension = "docx,doc,xlsx,xls",
    [parameter(Mandatory=$False, HelpMessage="Output Type")]
        [ValidateSet('GRID','CSV','HTML','RAW')]
        [string] $OutputType = 'GRID',
    [parameter(Mandatory=$False, HelpMessage="Do not apply CSS styling to HTML output")]
        [switch] $NoStyling
)
# reformat list elements to include dot prefix
$Time1 = Get-Date
$ExtList = $Extension.Split(',') | Foreach-Object {".$_"}
Write-Host "scanning $Path and child folders" -ForegroundColor Cyan
try {
    $DirList = Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue
}
catch {
    Write-Warning $_.Exception.Message
}
if ($DirList) {
    Write-Verbose "filtering for matching files"
    $Files = $DirList | Where-Object {$ExtList -contains $_.Extension}
    $fcount = $Files.count
    $result = @()
    $counter = 1
    foreach ($file in $Files) {
        if ($OutputType -eq 'HTML') {
            $obj = [pscustomobject][ordered] @{
                Item = $counter
                Name = $file.BaseName+$($file.Extension).ToLower()
                Path = $file.DirectoryName
                Size = $file.Length
                Created  = $file.CreationTime
                Modified = $file.LastWriteTime
                Accessed = $file.LastAccessTime
            }
        }
        else {
            $obj = [pscustomobject][ordered] @{
                Name = $file.BaseName+$($file.Extension).ToLower()
                Path = $file.DirectoryName
                Size = $file.Length
                Created  = $file.CreationTime
                Modified = $file.LastWriteTime
                Accessed = $file.LastAccessTime
            }
        }
        $result += $obj
        $counter++
    }
    switch ($OutputType) {
        'RAW' {
            $result | Format-Table
            break
        }
        'GRID' {
            $result | Out-GridView -Title "File Search: $Extension"
            break
        }
        'CSV' {
            $result | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath ".\FindFile.csv"
            Write-Host "results saved to: .\FindFile.csv" -ForegroundColor Cyan
            break
        }
        'HTML' {
            if (!$NoStyling) {
                $css = '<style type="text/css">'
                $css += 'body {font-family:verdana,helvetica,sans-serif;font-size:10pt;}'
                $css += 'td,th,tr {font-family:verdana,helvetica;font-size:10pt;padding:2px;}'
                $css += 'table {border:1px solid #eee;border-collapse:collapse;width:100%;}'
                $css += 'tr:nth-child(even){background-color:#f2f2f2;}'
                $css += 'tr:hover {background-color:#ddd;}'
                $css += 'th {padding-top:12px;padding-bottom:12px;text-align:left;background-color:#4CAF50;color:white;}'
                $css += '</style>'
            }
            else {
                $css = ''
            }
            $result | ConvertTo-Html -Title "Find File Results: $Extension" -Head $css | Out-File -FilePath ".\FindFile.htm"
            Write-Host "results saved to: .\FindFile.htm" -ForegroundColor Cyan
            break
        }
    }
    Write-Host "$fcount files found" -ForegroundColor Cyan
}
$StopTime = Get-Date
$Offset = [timespan]::FromSeconds(((New-TimeSpan -Start $Time1 -End $StopTime).TotalSeconds).ToString()).ToString("hh\:mm\:ss")
Write-Host "search completed. time: $Offset (hh:mm:ss)" -ForegroundColor Green
