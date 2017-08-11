Get-WmiObject -NameSpace "root" -Class "__NAMESPACE" | 
  Select-Object -ExpandProperty Name | 
    Sort-Object
