$extlist = @('CHS','CHT','DEU','FRA','ITA','JPN','KOR','RUS')

Write-Host "You can go get some coffee, this will take a while..." -ForegroundColor Green
foreach ($mpext in $extlist) {
  Get-SCOMManagementPack | 
    ?{$_.Name -like "*.$mpext"} |
      Remove-SCOMManagementPack
}
