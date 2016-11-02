<#
==============================================================================================
Name: Get-LargestFiles.ps1

Date: 09/27/2015

Author: David M. Stein

Usage: Get-LargestFiles.ps1 -StartPath "X" -Pattern "X" -MinSize N -MaxRows N

Parameters:
    
    StartPath (string) = denotes the path where the search begins and continues down into
        each sub-folder beneath.  This parameter is required.

    Pattern (string) = denotes the file pattern to search for.  The format is name.extension.
        use an asterisk (*) or question (?) for wildcard matching.  If not specified, 
        the default value is "*.exe"

    MinSize (integer) = size of files to include in search.  value indicates only files
        of that size, or larger, will be included.  Use standard byte suffixes to indicate
        megabytes, gigabytes, and so on. (e.g. 50MB, 100GB).  If not specified, the default is 100MB.

    MaxRows (integer) = number of matches to return, sorted by largest file first.
        if not specified, the default is 10.

Example:
    
    .\Get-LargestFiles.ps1 -StartPath "c:\users" -Pattern "*.*" -MinSize 50MB -MaxRows 20

==============================================================================================
#>

PARAM (
    [parameter(Mandatory=$True, Position=0)] [string] $StartPath,
    [parameter(Mandatory=$False, Position=1)] [string] $Pattern = "*.exe",
    [parameter(Mandatory=$False)] [int32] $MinSize = 100MB,
    [parameter(Mandatory=$False)] [int] $MaxRows = 10
)

if (Test-Path -Path "$StartPath") {
    Write-Host "Analyzing files under: $StartPath..." -ForegroundColor Cyan -BackgroundColor Black

    $LargeFiles = Get-ChildItem -Path "$StartPath" -Recurse -ErrorAction SilentlyContinue -Include $Pattern |
        ? {$_.GetType().Name -eq "FileInfo"} |
            Where-Object {$_.Length -gt $MinSize} |
                Sort-Object -Property length -Descending |
                    Select-Object Name, @{Name="SizeInMB";Expression={$_.Length/1MB}},@{Name="Path";Expression={$_.Directory}} -First $MaxRows

    if ($LargeFiles -ne $null) {
        $LargeFiles | Out-GridView -Title "$MaxRows Largest Files Under $StartPath"
    }
    else {
        Write-Host "No matching files found" -ForegroundColor Green -BackgroundColor Black
    }
}
else {
    Write-Host "Folder [$StartPath] not found." -ForegroundColor Red -BackgroundColor Black
}
