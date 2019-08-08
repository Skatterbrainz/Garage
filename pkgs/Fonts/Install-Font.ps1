<#
.NOTES
    Author: Robert Pearman
    https://4sysops.com/archives/install-fonts-with-a-powershell-script
#>
param (
    [Parameter(Mandatory=$true,Position=0)]
    [ValidateNotNull()]
    [array] $pcNames,
    [Parameter(Mandatory=$true,Position=1)]
    [ValidateNotNull()]
    [string] $fontFolder
)
$padVal = 20
$pcLabel = "Connecting To".PadRight($padVal," ")
$installLabel = "Installing Font".PadRight($padVal," ")
$errorLabel = "Computer Unavailable".PadRight($padVal," ")
$openType = "(Open Type)"
$regPath  = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
$objShell = New-Object -ComObject Shell.Application
if (!(Test-Path $fontFolder)) {
    Write-Warning "$fontFolder - Not Found"
}
else {
    $objFolder = $objShell.namespace($fontFolder)
    foreach ($pcName in $pcNames) {
        try {
            Write-Output "$pcLabel : $pcName"
            $null = Test-Connection $pcName -Count 1 -ErrorAction Stop
            $destination = "\\",$pcname,"\c$\Windows\Fonts" -join ""
            foreach ($file in $objFolder.items()) {
                $fileType = $($objFolder.getDetailsOf($file, 2))
                if (($fileType -eq "OpenType font file") -or ($fileType -eq "TrueType font file")) {
                    $fontName = $($objFolder.getDetailsOf($File, 21))
                    $regKeyName = $fontName,$openType -join " "
                    $regKeyValue = $file.Name
                    Write-Output "$installLabel : $regKeyValue"
                    Copy-Item $file.Path  $destination
                    Invoke-Command -ComputerName $pcName -ScriptBlock { $null = New-ItemProperty -Path $args[0] -Name $args[1] -Value $args[2] -PropertyType String -Force } -ArgumentList $regPath,$regKeyname,$regKeyValue
                }
            }
        }
        catch {
            Write-Warning "$errorLabel : $pcName"
        }
    }
}
