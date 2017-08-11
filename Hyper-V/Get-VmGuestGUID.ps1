param (
	[parameter(Mandatory=$True)] [string] $HypervHost,
	[parameter(Mandatory=$False)] [string] $GuestName = ""
)
if ($GuestName -ne "") {
	Get-WmiObject -ComputerName $HypervHost -Namespace root\virtualization\v2 -class Msvm_VirtualSystemSettingData | 
		? {$_.elementName -eq $GuestName} |
			Select-Object -ExpandProperty InstanceID
}
else {
    Get-WmiObject -ComputerName $HypervHost -Namespace root\virtualization\v2 -class Msvm_VirtualSystemSettingData | 
        ? {$_.InstanceID -notlike 'Microsoft:Def*'} |
            Select-Object elementname, InstanceID | 
                Sort-Object elementName
}
