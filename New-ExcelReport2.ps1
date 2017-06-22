<#
.SYNOPSIS
	example using powershell with MS Excel
	
.PARAMETER ComputerName
	[string] Name of computer, or blank for local computer
	
.PARAMETER FilePath
	[string] (Required) Name of XLSX file to save
	
#>

param (
	[parameter(Mandatory=$False, HelpMessage="Name of computer to query")]
		[string] $ComputerName = $env:ComputerName,
	[parameter(Mandatory=$True, HelpMessage="Name of file to save with .xlsx extension")]
		[string] $FilePath
)

#get disk data
$disks = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $ComputerName -Filter "DriveType=3"

try {
	$xl = New-Object -ComObject "Excel.Application" 
}
catch {
	Write-Warning "Excel could not be initialized"
	break
}

$wb = $xl.Workbooks.Add()
$ws = $wb.ActiveSheet
$cells = $ws.Cells

$cells.item(1,1) = "{0} Disk Drive Report" -f $disks[0].SystemName
$cells.item(1,1).font.bold = $True
$cells.item(1,1).font.size = 18

#define some variables to control navigation

$row = 3
$col = 1

#insert column headings

"Drive","SizeGB","FreespaceGB","UsedGB","%Free","%Used" | foreach {
    $cells.item($row,$col) = $_
    $cells.item($row,$col).font.bold = $True
    $col++
}

foreach ($drive in $disks) {
	$row++
	$col = 1
	$cells.item($Row,$col) = $drive.DeviceID
	$col++

	$cells.item($Row,$col) = $drive.Size/1GB
	$cells.item($Row,$col).NumberFormat = "0"
	$col++
	
	$cells.item($Row,$col) = $drive.Freespace/1GB
	$cells.item($Row,$col).NumberFormat = "0.00"
	$col++
	
	$cells.item($Row,$col) = ($drive.Size - $drive.Freespace)/1GB
	$cells.item($Row,$col).NumberFormat = "0.00"
	$col++
	
	$cells.item($Row,$col) = ($drive.Freespace/$drive.size)
	$cells.item($Row,$col).NumberFormat = "0.00%"
	$col++
	
	$cells.item($Row,$col) = ($drive.Size - $drive.Freespace) / $drive.size
	$cells.item($Row,$col).NumberFormat = "0.00%"
}

$xl.Visible = $True

# $filepath = Read-Host "Enter a path and filename to save the file"

if ($filepath) {
    $wb.SaveAs($filepath)
}
