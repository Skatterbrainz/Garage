[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [parameter(Mandatory=$True, HelpMessage="Folder Path to CSV files")]
        [ValidateNotNullOrEmpty()]
        [string] $Path,
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
}
catch {
    Write-Error $_.Exception.Message
    break
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
            Get-Process -Name 'EXCEL' | Stop-Process -Confirm:$False
        }
        if ($DoNotKeep) {
          Write-Verbose "removing $($csvfile.fullname)"
          Get-Item -Path $csvFile.fullname | Remove-Item -Force
        }
    }
    else {
        Write-Output $csvfile.fullname
    }
    Write-Output $result
} # foreach
