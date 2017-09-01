$Menu = [ordered]@{
    1 = 'Do something'
    2 = 'Do this instead'
    3 = 'Do whatever you  want'
}
  
$Result = $Menu | Out-GridView -PassThru  -Title 'Make a  selection'
Switch ($Result)  {
    {$Result.Name -eq 1} {'Do something'}
    {$Result.Name -eq 2} {'Do this instead'}
    {$Result.Name -eq 3} {'Do whatever you  want'}   
} 
