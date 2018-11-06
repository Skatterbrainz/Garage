function Get-UniqueFiles {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True, HelpMessage="Root path to search")]
        [ValidateNotNullOrEmpty()]
        [string] $Path
    )
    if (!(Test-Path $Path)) {
        Write-Warning "Nope. Sorry. $Path only exists in your glue-sniffing dreams"
        break
    }
    $files1 = Get-ChildItem $Path -Recurse
    $files2 = @()
    foreach ($file in $files1) {
        if ($($files2 | Select-Object -ExpandProperty BaseName -Unique) -notcontains $file.Basename) {
            $files2 += $file
        }
        else {
            Write-Verbose "$($file.BaseName) - is a duplicate"
        }
    }
    $files2
}
