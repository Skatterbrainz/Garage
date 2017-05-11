function Test-EvenOdd {
    param ($Val)
    if ($Val % 2 -eq 1) {
        Write-Output "ODD"
    }
    else {
        Write-Output "EVEN"
    }
}
