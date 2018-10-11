[CmdletBinding()]
param (
    [parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName = "cm01.contoso.local",
    [parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode = "P01",
    [parameter(Mandatory=$False)]
        [string[]] $CollectionID = ("P010015E","P0100168","P010014C")
)

function Get-OfficeFileVersion {
    param (
        [string] $ComputerName,
        [string] $CollectionName
    )
    Write-Host $ComputerName -ForegroundColor Cyan
    $wdpath = "\\$ComputerName\C`$\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"
    if ((Test-NetConnection $ComputerName -WarningAction SilentlyContinue).PingSucceeded) {
        Write-Verbose "$ComputerName is ONLINE"
        $online = $True
        try {
            $f = Get-Item -Path $wdpath -ErrorAction SilentlyContinue
            $wdver = $f.VersionInfo.ProductVersion
            Write-Verbose "word version = $wdver"
        }
        catch {
            $wdver = 'NOTFOUND'
            Write-Verbose "word version = none"
        }
    }
    else {
        $wdver  = $null
        $online = $False
        Write-Verbose "$ComputerName is offline"
    }
    $data = [ordered]@{
        Computer    = $ComputerName
        Collection  = $CollectionName
        IsOnLine    = $online
        IsInstalled = $wdver
        RunDate     = $(Get-Date).ToShortDateString()+' '+$(Get-Date).ToLongTimeString()
    }
    New-Object PSObject -Property $data
}

$DatabaseName = "CM_$SiteCode"
$QueryTimeout = 120
$ConnectionTimeout = 30
$conn = New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
$conn.ConnectionString = $ConnectionString
try {
    $conn.Open()
    Write-Verbose "connection opened successfully"
}
catch {
    Write-Error $_.Exception.Message
    break
}

$ccount = 1
$ctotal = $CollectionID.Count

foreach ($CollID in $CollectionID) {
    $dcount = 1
    $query  = @"
SELECT DISTINCT 
    dbo.v_Collection.CollectionID, 
    dbo.v_Collection.Name as CollectionName, 
    dbo.v_CollectionRuleDirect.RuleName as DeviceName, 
    dbo.v_CollectionRuleDirect.ResourceID
FROM dbo.v_CollectionRuleDirect INNER JOIN
    dbo.v_Collection ON dbo.v_CollectionRuleDirect.CollectionID = dbo.v_Collection.CollectionID
WHERE 
    (dbo.v_CollectionRuleDirect.CollectionID = `'$CollID`')
ORDER BY DeviceName
"@
    $cmd = New-Object System.Data.SqlClient.SqlCommand($query,$conn)
    $cmd.CommandTimeout = $QueryTimeout
    $ds = New-Object System.Data.DataSet
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    try {
        [void]$da.Fill($ds)
    }
    catch {
        Write-Error $_.Exception.Message 
        $conn.Close()
        break
    }
    $rowcount = $($ds.Tables).Rows.Count
    Write-Host "$rowcount rows returned" -ForegroundColor Green
    if ($rowcount -gt 0) {
        Write-Verbose "collectionID: $CollID"
        foreach ($row in $($ds.Tables).Rows) {
            $DeviceName = $row.DeviceName
            $CollName   = $row.CollectionName
            Write-Progress -Activity "Collection: $CollID - $ccount of $ctotal" -Status "Querying: $DeviceName" -PercentComplete $(($dcount/$rowcount)*100)
            Get-OfficeFileVersion -ComputerName $DeviceName -CollectionName $CollName
            $dcount++
        } # foreach
    } # if 
    $ccount++
} # foreach

Write-Verbose "closing database connection"
$conn.Close()
[CmdletBinding()]
param (
    [parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName = "hcidalas37.hci.pvt",
    [parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode = "HHQ",
    [parameter(Mandatory=$False)]
        [string[]] $CollectionID = ("HHQ0015E","HHQ00168","HHQ0014C")
)

function Get-OfficeFileVersion {
    param (
        [string] $ComputerName,
        [string] $CollectionName
    )
    Write-Host $ComputerName -ForegroundColor Cyan
    $wdpath = "\\$ComputerName\C`$\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"
    if ((Test-NetConnection $ComputerName -WarningAction SilentlyContinue).PingSucceeded) {
        Write-Verbose "$ComputerName is ONLINE"
        $online = $True
        try {
            $f = Get-Item -Path $wdpath -ErrorAction SilentlyContinue
            $wdver = $f.VersionInfo.ProductVersion
            Write-Verbose "word version = $wdver"
        }
        catch {
            $wdver = 'NOTFOUND'
            Write-Verbose "word version = none"
        }
    }
    else {
        $wdver  = $null
        $online = $False
        Write-Verbose "$ComputerName is offline"
    }
    $data = [ordered]@{
        Computer    = $ComputerName
        Collection  = $CollectionName
        IsOnLine    = $online
        IsInstalled = $wdver
        RunDate     = $(Get-Date).ToShortDateString()+' '+$(Get-Date).ToLongTimeString()
    }
    New-Object PSObject -Property $data
}

$DatabaseName = "CM_$SiteCode"
$QueryTimeout = 120
$ConnectionTimeout = 30
$conn = New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
$conn.ConnectionString = $ConnectionString
try {
    $conn.Open()
    Write-Verbose "connection opened successfully"
}
catch {
    Write-Error $_.Exception.Message
    break
}

$ccount = 1
$ctotal = $CollectionID.Count

foreach ($CollID in $CollectionID) {
    $dcount = 1
    $query  = @"
SELECT DISTINCT 
    dbo.v_Collection.CollectionID, 
    dbo.v_Collection.Name as CollectionName, 
    dbo.v_CollectionRuleDirect.RuleName as DeviceName, 
    dbo.v_CollectionRuleDirect.ResourceID
FROM dbo.v_CollectionRuleDirect INNER JOIN
    dbo.v_Collection ON dbo.v_CollectionRuleDirect.CollectionID = dbo.v_Collection.CollectionID
WHERE 
    (dbo.v_CollectionRuleDirect.CollectionID = `'$CollID`')
ORDER BY DeviceName
"@
    $cmd = New-Object System.Data.SqlClient.SqlCommand($query,$conn)
    $cmd.CommandTimeout = $QueryTimeout
    $ds = New-Object System.Data.DataSet
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    try {
        [void]$da.Fill($ds)
    }
    catch {
        Write-Error $_.Exception.Message 
        $conn.Close()
        break
    }
    $rowcount = $($ds.Tables).Rows.Count
    Write-Host "$rowcount rows returned" -ForegroundColor Green
    if ($rowcount -gt 0) {
        Write-Verbose "collectionID: $CollID"
        foreach ($row in $($ds.Tables).Rows) {
            $DeviceName = $row.DeviceName
            $CollName   = $row.CollectionName
            Write-Progress -Activity "Collection: $CollID - $ccount of $ctotal" -Status "Querying: $DeviceName" -PercentComplete $(($dcount/$rowcount)*100)
            Get-OfficeFileVersion -ComputerName $DeviceName -CollectionName $CollName
            $dcount++
        } # foreach
    } # if 
    $ccount++
} # foreach

Write-Verbose "closing database connection"
$conn.Close()
