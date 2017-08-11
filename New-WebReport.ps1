<#
.SYNOPSIS
	Create Web Report from Computer inventory data
.DESCRIPTION
	Create web report using computer inventory data obtained form CIM/WMI queries
.NOTES
	Based entirely on Jeff Hicks example at...
	https://www.petri.com/enhancing-html-reports-with-powershell
#>

param (
    [parameter(Mandatory=$True, HelpMessage="Path to export file")]
        [ValidateNotNullOrEmpty()]
        [string] $WebFile,
    [parameter(Mandatory=$False, HelpMessage="Path to image graphic file")]
        [ValidateNotNullOrEmpty()]
        [string] $ImagePath = ""
)

$fragments = @()

if ($ImagePath -ne "") {
	Write-Verbose "merging image file into report content"
	$ImageBits =  [Convert]::ToBase64String((Get-Content $ImagePath -Encoding Byte))
	$ImageFile = Get-Item $ImagePath
	$ImageType = $ImageFile.Extension.Substring(1) #strip off the leading .
	$ImageTag  = "<Img src='data:image/$ImageType;base64,$($ImageBits)' Alt='$($ImageFile.Name)' style='float:left' width='120' height='120' hspace=10>"
	$fragments += $ImageTag
}

#adjust spacing - takes trial and error
$fragments+= "<br/><br/>"

$fragments+= "<H2>Operating System</H2>"
$fragments+= Get-Ciminstance -ClassName Win32_OperatingSystem |
    Select @{Name="Operating System";Expression= {$_.Caption}},Version,InstallDate |
        ConvertTo-Html -Fragment -As List

Function Get-SystemInfo {
    [cmdletbinding()]
    Param([string]$Computername = $env:COMPUTERNAME)
    try {
        $cs = Get-CimInstance -ClassName Win32_ComputerSystem #-ComputerName $Computername  
        #this assumes a single processor
        $proc = Get-CimInstance -ClassName Win32_Processor #-ComputerName $Computername 
        $enc  = Get-CimInstance -ClassName Win32_SystemEnclosure
        $adp  = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq $True}
        $ipv4 = $adp | Select-Object -ExpandProperty IPAddress
        $gtwy = $adp | Select-Object -ExpandProperty DefaultIPGateway
        $adpn = $adp | Select-Object -ExpandProperty Description
    }
    catch {
        write-warning "get-systeminfo: unable to query WMI classes"
        break
    }
    $data = [ordered]@{
        ComputerName = $cs.Name
        Manufacturer = $cs.Manufacturer
        Model = $cs.Model
        SerialNumber = $enc.SerialNumber
        TotalPhysicalMemGB = $cs.TotalPhysicalMemory/1GB -as [int]
        NumProcessors = $cs.NumberOfProcessors
        NumLogicalProcessors = $cs.NumberOfLogicalProcessors
        NetworkAdapter = $adpn
        IPAddress = $ipv4
        Gateway = $gtwy
        HyperVisorPresent = $cs.HypervisorPresent
        DeviceID = $proc.DeviceID
        Name = $proc.Name
        MaxClock = $proc.MaxClockSpeed
        L2size = $proc.L2CacheSize
        L3Size = $proc.L3CacheSize
    }
    New-Object -TypeName PSObject -Property $data
}

$fragments+= "<H2>System Information</H2>"
$fragments+= Get-SystemInfo -Computername $env:COMPUTERNAME | ConvertTo-Html -Fragment -As List

$fragments+= "<H2>Logical Disks</H2>"
[xml]$html = Get-WmiObject -Class Win32_LogicalDisk | 
    Select @{Name="Drive";Expression = {$_.DeviceID}},
        @{Name="Label";Expression = {$_.VolumeName}},
        @{Name="Size";Expression = {"$("{0:N0}" -f $($_.Size/1GB)) GB"}},
        @{Name="FreeSpace";Expression = {"$("{0:N0}" -f $($_.FreeSpace/1GB)) GB"}} |
            ConvertTo-Html -Fragment
$fragments+= $html.InnerXml


$fragments+= "<H2>EventLog</H2>"
[xml]$html  = Get-Eventlog -List | 
    Select @{Name="Max(K)";Expression = {"{0:n0}" -f $_.MaximumKilobytes }},
        @{Name="Retain";Expression = {$_.MinimumRetentionDays }},
        OverFlowAction,@{Name="Entries";Expression = {"{0:n0}" -f $_.entries.count}},
        @{Name="Log";Expression = {$_.LogDisplayname}} | 
            ConvertTo-Html -Fragment
 
for ($i=1;$i -le $html.table.tr.count-1;$i++) {
    if ($html.table.tr[$i].td[3] -eq 0) {
        $class = $html.CreateAttribute("class")
        $class.value = 'alert'
        $html.table.tr[$i].attributes.append($class) | Out-Null
    }
}
$fragments+= $html.InnerXml
$fragments+= "<p class='footer'>$(Get-Date)</p>"

$convertParams = @{ 
  head = @"
 <Title>System Report - $($env:COMPUTERNAME)</Title>
<style>
body { background-color:#E5E4E2;
       font-family:Monospace;
       font-size:10pt; }
td, th { border:0px solid black; 
         border-collapse:collapse;
         white-space:pre; }
th { color:white;
     background-color:black; }
table, tr, td, th { padding: 2px; margin: 0px ;white-space:pre; }
tr:nth-child(odd) {background-color: lightgray}
table { width:95%;margin-left:5px; margin-bottom:20px;}
h2 {
 font-family:Tahoma;
 color:#6D7B8D;
}
.alert {
 color: red; 
 }
.footer 
{ color:green; 
  margin-left:10px; 
  font-family:Tahoma;
  font-size:8pt;
  font-style:italic;
}
</style>
"@
 body = $fragments
}
 
ConvertTo-Html @convertParams | Out-File $webfile
