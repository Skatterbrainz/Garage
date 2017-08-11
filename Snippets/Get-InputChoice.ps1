<#
.SYNOPSIS
	Get-InputChoice.ps1
  
.NOTES
	Author: David Stein
	Date Created: 09/01/2013

.EXAMPLE
	Get-InputChoice.ps1 -Question "Do you want to continue?" -Options "Y,N"
#>

param (
	[parameter(Mandatory=$True)] [string] $Question,
	[parameter(Mandatory=$True)] [string] $Options
)

$choice = Read-Host `n "$Question.`nEnter your response? [$Options]"
Write-Output "You responded: $choice"
