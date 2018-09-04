<#
.SYNOPSIS
  super-based example of working with MS Excel

#>

$xl = New-Object -ComObject "Excel.Application"
$wb = $xl.Workbooks.Add()
$ws = $wb.ActiveSheet
$xl.Visible=$True

$ws.Cells.Item(1,1) = $env:ComputerName
$ws.Cells.Item(1,2) = $env:UserName
$ws.Cells.Item(2,1) = (Get-Date)

$ws.Cells.Item(1,1).Font.Bold = $True
$ws.Cells.Item(1,2).Font.Bold = $True
$ws.Cells.Item(1,1).Font.Size = 16
$ws.Cells.Item(1,2).Font.Size = 16

$ws.Name = "Computers"
$ws.Cells.EntireColumn.AutoFit()

# AutoFit Every Worksheet Column in a Workbook

foreach ($wsht in $wb.Worksheets) {
  $wsht.Cells.EntireColumn.AutoFit()
}

#$wb.Close()
#$xl.Quit()
