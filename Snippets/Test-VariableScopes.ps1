$test1 = "ABC"
$test2 = "ABC"

Function Set-VX {
    param ()
    Set-Variable -Name Test1 -Value "BBB" -Scope Script
    Set-Variable -Name Test2 -Value "CCC" -Option AllScope
}

Write-Output "Test1 before: $test1"

Set-VX

Write-Output "Test1 after: $test1"
Write-Output "Test2 after: $test2"
