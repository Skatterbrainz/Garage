function Get-AlphaList {
    $alphalist = @()
    $char1 = 65
    $char2 = $char1+25
    for ($i = $char1; $i -le $char2; $i++) {
        $alphalist += [char]$i
    }
    $alphalist
}
