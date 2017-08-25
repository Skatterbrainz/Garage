# works on physical and static-mem virtual guests

[math]::Round((Get-WmiObject -Class Win32_ComputerSystem | 
    Select-Object -ExpandProperty TotalPhysicalMemory | 
        Measure-Object -Sum).sum/1gb,0)

# works on all windows machines

[math]::Round((Get-WmiObject -Class Win32_PhysicalMemory | 
    Select-Object -ExpandProperty Capacity | 
        Measure-Object -Sum).sum/1gb,0)
