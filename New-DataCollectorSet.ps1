<#
.SYNOPSIS
    Create a New Perfmon Data Collector Set from an XML input
.DESCRIPTION
    Create a New Perfmon Data Collector Set from an XML input
    Use PowerShell remoting to create these on a remote server.
    Remoting must be enabled on target servers
.NOTES
    Authors:  Jonathan Medd
    URL: http://www.jonathanmedd.net/2010/11/managing-perfmon-data-collector-sets-with-powershell.html
.PARAMETER CSVFilePath
    Path of CSV file to import
.PARAMETER XMLFilePath
    Path of XML file to import
.PARAMETER DataCollectorName
    Name of new Data Collector. This should match the name in the XML file
.EXAMPLE
    New-DataCollectorSet -CSVFilePath C:\Scripts\Servers.csv -XMLFilePath C:\Scripts\PerfmonTemplate.xml -DataCollectorName CPUIssue
#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$True, HelpMessage='Path of CSV file to import')] 
        [string] $CSVFilePath,
    [parameter(Mandatory=$True, HelpMessage='Path of XML file to import')] 
        [string] $XMLFilePath,
    [parameter(Mandatory=$True, HelpMessage='Name of new Data Collector')] 
        [string] $DataCollectorName
)

# Test for existence of supplied CSV and XML files
if (!(Test-Path $CSVFilePath)) {
    Write-Warning "Path to CSV file is invalid, exiting script"
    Exit
}
if (!(Test-Path $XMLFilePath)) {
    Write-Warning "Path to XML file is invalid, exiting script"
    Exit
}

# Generate list of servers to create Perfmon Data Collector Sets on
$servers = Get-Content $CSVFilePath

foreach ($server in $servers) {
    Write-Verbose "Creating Data Collector Set on $Server"

    if (Test-Path "\\$server\c`$\Temp") {
        Write-Verbose "Copying $XMLFilePath to a temp folder..."
        Copy-Item $XMLFilePath "\\$server\c`$\Temp"
        $pfname = "PerfmonTemplate.xml"
        # Use PowerShell Remoting to execute script block on target server
        Invoke-Command -ComputerName $server -ArgumentList $DataCollectorName -ScriptBlock {param($DataCollectorName)

            # Create a new DataCollectorSet COM object, read in the XML file,
            # use that to set the XML setting, create the DataCollectorSet, and start it.
            $datacollectorset = New-Object -COM Pla.DataCollectorSet
            $xml = Get-Content "C:\temp\$pfname"
            $datacollectorset.SetXml($xml)
            $datacollectorset.Commit("$DataCollectorName" , $null , 0x0003) | Out-Null
            $datacollectorset.start($false)
        }
        Write-Verbose "removing temp file $pfname"
        Remove-Item "\\$server\c`$\Temp\$pfname"
    }
    else {
        Write-Warning "Target Server does not contain the folder C:\Temp"
    }
}
