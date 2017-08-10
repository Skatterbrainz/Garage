param (
    [parameter(Mandatory=$False)]
    [switch] $ShowMethods
)

$cim1 = Get-CimClass | Where-Object {$_.CimClassName -like "Win32_*"}
$cim2 = $cim1 | Where-Object {$_.CimClassName -notlike "*Perf*"}

Write-Output "<classes>"
foreach ($cc in $cim2) {
    Write-Output "`<class name=`"$($cc.CimClassName)`">"
    $cp = $cc.CimClassProperties
    Write-Output "`t`<properties>"
    foreach ($p in $cp) {
        Write-Output "`t`t<property name=`"$($p.Name)`" />"
    }
    Write-Output "`t</properties>"
    if ($ShowMethods) {
        $cm = $cc.CimClassMethods
        Write-Output "`t`<methods>"
        foreach ($m in $cm) {
            Write-Output "`t`t<method name=`"$($m.Name)`" />"
        }
        Write-Output "`t`</methods>"
    }
    Write-Output "`</class>"
}
Write-Output "</classes>"
