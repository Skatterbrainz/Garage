#----------------------------------------------------------------
# Filename...: excel_sample2.ps1
# Author.....: 
# Date.......: 
# Purpose....: 
#----------------------------------------------------------------

Param([string]$computer=$env:computername)

#get disk data
$disks=Get-WmiObject -Class Win32_LogicalDisk -ComputerName $computer -Filter "DriveType=3"

$xl=New-Object -ComObject "Excel.Application" 

$wb=$xl.Workbooks.Add()
$ws=$wb.ActiveSheet

$cells=$ws.Cells

$cells.item(1,1)="{0} Disk Drive Report" -f $disks[0].SystemName
$cells.item(1,1).font.bold=$True
$cells.item(1,1).font.size=18

#define some variables to control navigation

$row=3
$col=1

#insert column headings

"Drive","SizeGB","FreespaceGB","UsedGB","%Free","%Used" | foreach {
    $cells.item($row,$col)=$_
    $cells.item($row,$col).font.bold=$True
    $col++
}

foreach ($drive in $disks) {
	
	$row++
	$col=1

	$cells.item($Row,$col)=$drive.DeviceID
	
	$col++
	
	$cells.item($Row,$col)=$drive.Size/1GB
	$cells.item($Row,$col).NumberFormat="0"
	
	$col++
	
	$cells.item($Row,$col)=$drive.Freespace/1GB
	$cells.item($Row,$col).NumberFormat="0.00"
	
	$col++
	
	$cells.item($Row,$col)=($drive.Size - $drive.Freespace)/1GB
	$cells.item($Row,$col).NumberFormat="0.00"
	
	$col++
	
	$cells.item($Row,$col)=($drive.Freespace/$drive.size)
	$cells.item($Row,$col).NumberFormat="0.00%"
	
	$col++
	
	$cells.item($Row,$col)=($drive.Size - $drive.Freespace) / $drive.size
	$cells.item($Row,$col).NumberFormat="0.00%"
}

$xl.Visible=$True

$filepath=Read-Host "Enter a path and filename to save the file"

if ($filepath) {
    $wb.SaveAs($filepath)
}
