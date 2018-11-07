<#
.DESCRIPTION
  Import global settings from a stupid, drunk, homeless little txt file
.EXAMPLE
  Set-Configuration.ps1
  
  example .txt file...
  
; global configuration settings for scripts in this folder and subfolders
SQLServerName=cm01.contoso.local
SiteCode=P01
ScriptsPath=\\fs1\scripts
ListFilesPath=\\fs1\scripts\lists
ReportFilesPath=\\fs2\scripts\reports
QueryFilesPath=\\fs1\scripts\queries
#>

param (
    [string] $FilePath = ".\Configuration.txt"
)
if (!(Test-Path $FilePath)) {
    Write-Warning "$FilePath not found!!"
    break
}
$filedata = Get-Content -Path $FilePath
$ServerName      = $filedata | ?{$_ -like "SQLServerName*"} | %{$_ -split '='} | Select -Last 1
$SiteCode        = $filedata | ?{$_ -like "SiteCode*"} | %{$_ -split '='} | Select -Last 1
$ListFilesPath   = $filedata | ?{$_ -like "ListFilesPath*"} | %{$_ -split '='} | Select -Last 1
$ReportFilesPath = $filedata | ?{$_ -like "ReportFilesPath*"} | %{$_ -split '='} | Select -Last 1
$QueryFilesPath  = $filedata | ?{$_ -like "QueryFilesPath*"} | %{$_ -split '='} | Select -Last 1
Write-Host "applying runtime configuration settings" -ForegroundColor Cyan
