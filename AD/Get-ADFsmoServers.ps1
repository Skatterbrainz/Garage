#requires -Modules ActiveDirectory

$Dom = Get-ADDomain
$ADF = Get-ADForest

$PDC = $Dom.PDCEmulator
$IFM = $Dom.InfrastructureMaster
$RID = $Dom.RIDMaster

$SCM = $ADF.SchemaMaster
$DNM = $ADF.DomainNamingMaster


Write-Output "Domain Naming.... $DNM"
Write-Output "Schema Master.... $SCM"

Write-Output "PDC Emulator..... $PDC"
Write-Output "Infastructure.... $IFM"
Write-Output "RID Master....... $RID"

Write-Output "Global Catalog Servers..."

foreach ($GC in $ADF.GlobalCatalogs) {
    Write-Output $GC 
}
