$test1 = "ABC"
$test2 = "ABC"
$test3 = "ABC"

Function Set-VX {
    param ()
    Set-Variable -Name Test1 -Value "BBB" -Scope Script
    Set-Variable -Name Test2 -Value "CCC" -Option AllScope
    $test3 = "123"
}

Write-Output "Test1 before: $test1"
Write-Output "Test2 before: $test2"
Write-Output "Test3 before: $test3"

Set-VX

Write-Output "Test1 after: $test1"
Write-Output "Test2 after: $test2"
Write-Output "Test3 after: $test3"
