param (
	[parameter(Mandatory=$True)] [string] $HypervHost,
	[parameter(Mandatory=$False)] [string] $GuestName = ""
)
if ($GuestName -ne "") {
	Get-WmiObject -ComputerName $HypervHost -Namespace root\virtualization\v2 -class Msvm_VirtualSystemSettingData | 
		Where-Object {$_.elementName -eq $GuestName} |
			Select -ExpandProperty BIOSSerialNumber
}
else {
	Get-WmiObject -ComputerName $HypervHost -Namespace root\virtualization\v2 -class Msvm_VirtualSystemSettingData | 
        	Where-Object {$_.BIOSSerialNumber -ne $null} |
    		Select elementname, BIOSSerialNumber |
                	Sort-Object elementName
}
