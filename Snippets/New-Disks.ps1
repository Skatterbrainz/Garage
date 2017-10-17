<#
.DESCRIPTION
  Iterate all attached but offline/unformatted disks and bring them into the keg party!
#>
param (
  [parameter(Mandatory=$False)]
  [ValidateNotNullOrEmpty()]
  [string] $StartLetter = 'F'
)
$Disks = Get-Disk | ? {$_.PartitionStyle -eq 'RAW'}
$NextLetter = $StartLetter
$NextAscii  = [byte][char]$NextLetter
$Label  = "DATAFILES"
foreach ($Disk in $Disks) {
    Set-Disk -InputObject $Disk -IsOffline $False
    Initialize-Disk -InputObject $Disk
    New-Partition $Disk.Number -UseMaximumSize -DriveLetter $NextLetter
    Format-Volume -DriveLetter $NextLetter -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel $Label -Confirm:$False
    $NextAscii++
    $NextLetter = [char]$NextAscii
}
<#
for testing purposes only...
$disknums = @(2,3,4)
foreach ($disknum in $disknums) {
  Clear-Disk -Number $disknum -RemoveData -RemoveOEM -Confirm:$False
}
#>
