[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [parameter(Mandatory=$False, HelpMessage="Search Path root")]
    [ValidateNotNullOrEmpty()]
    [string] $Path = "c:\users",
    [parameter(Mandatory=$False, HelpMessage="Output File")]
    [string] $OutputFile = ""
)
$result = Get-ChildItem -Path $Path -Filter "*.vssx" -Recurse | 
    Where-Object {$_.Length -gt 0} | 
        Select FullName,LastWriteTime,Length

if ($OutputFile -ne "") {
    $result | Out-File -FilePath $OutputFile -Force
}
$result
