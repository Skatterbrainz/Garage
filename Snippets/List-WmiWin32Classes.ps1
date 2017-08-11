$managementClass = New-Object System.Management.ManagementClass

$enumOptions = New-Object System.Management.EnumerationOptions
$enumOptions.EnumerateDeep = $true

$managementClass.PSBase.GetSubclasses( $enumOptions ) | 
    Where-Object {$_.Name -like "Win32*"} |
        Sort-Object | 
            Select-Object -ExpandProperty Name |
                Out-GridView -Title "Win32 Classes"
