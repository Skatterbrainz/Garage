<#
.DESCRIPTION
    Convert CSV files to XLSX workbooks
.PARAMETER Path
    Folder path where CSV files reside
.PARAMETER Filename
    Filename to process from [Path] location, default is ""
    If [Filename] = "" then all CSV files in [Path] are processed
.PARAMETER DoNotKeep
    Remove CSV files after conversion
.PARAMETER Delimiter
    CSV column delimiter. Default = comma (",")
.EXAMPLE
    .\ConvertTo-Excel.ps1 -Path ".\reports\" -DoNotKeep -WhatIf -Verbose
.EXAMPLE
    .\ConvertTo-Excel.ps1 -Path ".\reports\" -Filename "test.csv"
.NOTES
    1.0.3 - DS - I don't know. I forgot what 1.0.1 and 1.0.2 did so I made 1.0.3
#>

[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [parameter(Mandatory=$True, HelpMessage="Folder Path to CSV files")]
        [ValidateNotNullOrEmpty()]
        [string] $Path,
    [parameter(Mandatory=$False, HelpMessage="Name of file to convert")]
        [string] $Filename = "",
    [parameter(Mandatory=$False, HelpMessage="Do not keep original CSV files")]
        [switch] $DoNotKeep,
    [parameter(Mandatory=$False)]
        [string] $Delimiter = ','
)
if (!(Test-Path $Path)) {
    Write-Error "$Path not found!"
    break
}
try {
    $csvfiles = Get-ChildItem -Path $Path -Filter "*.csv"
    Write-Verbose "$($csvfiles.count) files found"
}
catch {
    Write-Error $_.Exception.Message
    break
}
if (![string]::IsNullOrEmpty($Filename)) {
    Write-Verbose "filtering list on $Filename"
    $csvfiles = $csvfiles | ? {$_.Name -eq $Filename}
}

foreach ($csvfile in $csvfiles) {
    Write-verbose "Converting $($csvfile.Fullname)"
    $XlFile = $csvfile.Fullname -replace '.csv','.xlsx'
    Write-Verbose "opening an instance of microsoft excel"

    if (!$WhatIfPreference) {
        $excel = New-Object -ComObject Excel.Application 
        $workbook  = $excel.Workbooks.Add(1)
        $worksheet = $workbook.worksheets.Item(1)
        $TxtConnector = ("TEXT;" + $CsvFile.Fullname)
        Write-Verbose "connector: $TxtConnector"
        $Connector = $worksheet.QueryTables.Add($TxtConnector,$worksheet.Range("A1"))
        $query = $worksheet.QueryTables.Item($Connector.name)
        $query.TextFileOtherDelimiter = $delimiter
        $query.TextFileParseType  = 1
        $query.TextFileColumnDataTypes = ,1 * $worksheet.Cells.Columns.Count
        $query.AdjustColumnWidth = 1
        $query.Refresh()
        $query.Delete()
        Write-Verbose "saving content to $XlFile"
        try {
            if (Test-Path $XlFile) { Remove-Item -Path $XlFile -Force }
            $Workbook.SaveAs($XlFile,51) | Out-Null
            Write-Verbose "saved output successfully"
            $result = 0
        }
        catch {
            Write-Verbose "error: $($_.Exception.Message)"
            $result = -1
        }
        finally {
            $excel.Quit()
        }
        if ($excel) { 
            Get-Process -Name 'EXCEL' | Stop-Process -Confirm:$False -ErrorAction SilentlyContinue
        }
    }
    else {
        Write-Output $csvfile.fullname
    }
    if ($DoNotKeep) {
        Write-Verbose "deleting $($csvfile.Fullname)"
        try {
            Get-Item -Path $csvfile.Fullname | Remove-item -Force -Confirm:$False -ErrorAction SilentlyContinue
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
    Write-Output $result
} # foreach
