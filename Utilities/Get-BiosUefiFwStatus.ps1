<#
Get BIOS or UEFI Status and Write to WMI v1.0
Idea for using setupact.log from Chris Warwick
Created by Mark Godfrey @Geodesicz
#>

# BIOS or EFI
$fwtype = (Select-String 'Detected boot environment' C:\windows\panther\setupact.log).line -replace '.*:\s+'

# Image Date
$setupact = Get-Content C:\windows\panther\setupact.log
$remove = $setupact[0].Substring(10)
$ImageDate = $setupact[0].replace($remove,"")

# Set Vars for WMI Info
$Namespace = 'ITLocal'
$Class = 'Firmware'

# Does Namespace Already Exist?
Write-Verbose "Getting WMI namespace $Namespace"
$NSfilter = "Name = '$Namespace'"
$NSExist = Get-WmiObject -Namespace root -Class __namespace -Filter $NSfilter
# Namespace Does Not Exist
If($NSExist -eq $null){
    Write-Verbose "$Namespace namespace does not exist. Creating new namespace . . ."
    # Create Namespace
   	$rootNamespace = [wmiclass]'root:__namespace'
    $NewNamespace = $rootNamespace.CreateInstance()
	$NewNamespace.Name = $Namespace
	$NewNamespace.Put()
    }

# Does Class Already Exist?
Write-Verbose "Getting $Class Class"
$ClassExist = Get-CimClass -Namespace root/$Namespace -ClassName $Class -ErrorAction SilentlyContinue
# Class Does Not Exist
If($ClassExist -eq $null){
    Write-Verbose "$Class class does not exist. Creating new class . . ."
    # Create Class
    $NewClass = New-Object System.Management.ManagementClass("root\$namespace", [string]::Empty, $null)
	$NewClass.name = $Class
    $NewClass.Qualifiers.Add("Static",$true)
    $NewClass.Qualifiers.Add("Description","Firmware is a custom WMI Class created by Mark Godfrey(@geodesicz) to store data regarding UEFI vs BIOS status")
    $NewClass.Properties.Add("ComputerName",[System.Management.CimType]::String, $false)
    $NewClass.Properties.Add("ImageDate",[System.Management.CimType]::String, $false)
    $NewClass.Properties.Add("FirmwareType",[System.Management.CimType]::String, $false)
    $NewClass.Properties["ComputerName"].Qualifiers.Add("Key",$true)
    $NewClass.Put()
    }

# Write Class Attributes
$wmipath = 'root\'+$Namespace+':'+$class
$WMIInstance = ([wmiclass]$wmipath).CreateInstance()
$WMIInstance.ComputerName = $env:COMPUTERNAME
$WMIInstance.ImageDate = $ImageDate
$WMIInstance.FirmwareType = $fwtype
$WMIInstance.Put()
