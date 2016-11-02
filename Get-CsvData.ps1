<#
Get-CsvData.ps1
David M. Stein
09/20/2016
#>

param (
    [parameter(Mandatory=$True)] [string] $CsvFile,
    [parameter(Mandatory=$True)] [string] $Column
)

function Get-CsvColumns {
    param ($csvData)
    Get-Member -InputObject $csvdata[0] |
        Where-Object {$_.MemberType -eq "NoteProperty"} |
            Select-Object -ExpandProperty Name
}

function Get-CsvColumnIndex {
    param ($column, $array)
    $cols = Get-CsvColumns $array
    $cindex = [array]::IndexOf($cols,"$column")
    return $cindex
}

if (Test-Path $CsvFile) {
    $fdata = Import-Csv $CsvFile

    $colums = Get-CsvColumns -csvData $fdata
    $index = Get-CsvColumnIndex -column "$column" -array $fdata

    foreach ($row in $fdata) {
        $i = 0
        $v = $row.psobject.Properties.value[$index]
        write-output $v
    }
}
else {
    Write-Output "error: $CsvFile not found"
}
