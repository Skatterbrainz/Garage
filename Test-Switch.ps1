function Test-Switch {
    param ($Val)
    switch -Regex ($Val) {
        "RED" { Write-Output "Red"; break}
        "^APP|SINGLE" { write-output 1; break }
        "^SQL|SINGLE" { write-output 2; break }
        "^WEB|SINGLE" { write-output 3; break }
#        "^[13579]$" { Write-Output "ODD"; break }
#        "^[2468]$" { Write-Output "EVEN"; break }
        { $_ % 2 -eq 1 } { Write-Output "ODD"; break }
        { $_ % 2 -eq 0 } { Write-Output "EVEN"; break }
        default { write-output 0 }
    }
}
