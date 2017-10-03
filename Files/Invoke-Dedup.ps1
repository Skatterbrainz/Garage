param (
  [parameter(Mandatory=$True)]
  [string] $Volume
)
While ((Get-DedupJob -Volume $Volume -ErrorAction SilentlyContinue | Select-Object -ExpandProperty State) -in ('Queued','Running')) {
    try {
        $x = (Get-DedupJob -Volume $Volume -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Progress)
        if ($x) {Write-Host $x}
    }
    catch {
    }
}
