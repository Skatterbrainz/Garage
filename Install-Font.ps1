<#
.SYNOPSIS
    Install TrueType or OpenType fonts
.DESCRIPTION
    Install all TrueType or OpenType fonts from a given folder path
.PARAMETER FontFolder
    Source path where font files reside
.EXAMPLE
    .\Install-Font.ps1 -FontFolder "x:\fonts"
.NOTES
    Derived from the following:
    Author: Robert Pearman
    https://4sysops.com/archives/install-fonts-with-a-powershell-script
#>
[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory=$true,Position=1,HelpMessage="Fonts source folder path")]
        [ValidateNotNull()]
        [string] $FontFolder
)
$openType   = "(Open Type)"
$regPath    = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
$objShell   = New-Object -ComObject Shell.Application
$destination = "c:\Windows\Fonts"
if (!(Test-Path $fontFolder)) {
    Write-Warning "$fontFolder - Not Found"
}
else {
    $objFolder = $objShell.namespace($fontFolder)
    try {
        foreach ($file in $objFolder.items()) {
            Write-Verbose "font: $file"
            $fileType = $($objFolder.getDetailsOf($file, 2))
            if (($fileType -eq "OpenType font file") -or ($fileType -eq "TrueType font file")) {
                $fontName    = $($objFolder.getDetailsOf($File, 21))
                $regKeyName  = $fontName,$openType -join " "
                $regKeyValue = $file.Name
                Write-Verbose "add regkey`: $regKeyValue"
                Copy-Item $file.Path  $destination
                Invoke-Command -ScriptBlock { $null = New-ItemProperty -Path $args[0] -Name $args[1] -Value $args[2] -PropertyType String -Force } -ArgumentList $regPath,$regKeyname,$regKeyValue
            }
        }
    }
    catch {
        Write-Warning $Error[0].Exception.Message
    }
}