<#
.DESCRIPTION
  Query for MS Office add-ins

.PARAMETER ReportPath
  Folder path to save output file (computername + "_office-addins.txt")

.EXAMPLE
  .\Get-OfficeAddins.ps1 -ReportPath "\\server1\docs\reports"

.NOTES
  1809.04 - DS - First release
#>

[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [parameter(Mandatory=$False, ValueFromPipeline=$True, HelpMessage="Folder Path for Output File")]
    [ValidateNotNullOrEmpty()]
    [string] $ReportPath = "$($env:TEMP)"
)
$outfile = Join-Path -Path $ReportPath -ChildPath "$($env:COMPUTERNAME)_office-addins.txt"
$searchScopes = (
    "HKCU:\SOFTWARE\Microsfot\Office\Excel\Addins",
    "HKCU:\SOFTWARE\Microsfot\Office\OneNote\Addins",
    "HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins",
    "HKCU:\SOFTWARE\Microsfot\Office\PowerPoint\Addins",
    "HKCU:\SOFTWARE\Microsfot\Office\Word\Addins",
    "HKLM:\SOFTWARE\Microsoft\Office\Excel\Addins",
    "HKLM:\SOFTWARE\Microsoft\Office\OneNote\Addins",
    "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins",
    "HKLM:\SOFTWARE\Microsoft\Office\PowerPoint\Addins",
    "HKLM:\SOFTWARE\Microsoft\Office\Word\Addins"
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\Excel\Addins",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\OneNote\Addins",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\Outlook\Addins",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\PowerPoint\Addins",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\Word\Addins"
)
$names = $searchScopes | 
    Foreach-Object {Get-ChildItem -Path $_ -ErrorAction SilentlyContinue | 
        Foreach-Object {Get-ItemProperty -Path $_.PSPath} | 
            Select-Object @{n="Name";e={Split-Path $_.PSPath -leaf}},FriendlyName,Description} | 
                Sort-Object -Unique -Property name

if ($VerbosePreference) {
    $names | Format-Table
}
$names | Out-File -FilePath $outfile -Force
