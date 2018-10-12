[CmdletBinding()]
param (
    [string] $inputFile = ".\offline.txt"
)

if (!(Test-Path $inputFile)) {
    Write-Warning "$inputFile was not found!"
    break
}

function Get-ADsComputer {
    param (
        $ComputerName
    )
    $strFilter = "(&(objectCategory=Computer)(name=$ComputerName))"
    $objDomain   = New-Object System.DirectoryServices.DirectoryEntry
    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $objSearcher.SearchRoot = $objDomain
    $objSearcher.Filter = $strFilter
    $objSearcher.PageSize = 2000
    $objPath = $objSearcher.FindOne()
    foreach ($objItem in $objPath) {
        try {
            $objComputer = $objItem.GetDirectoryEntry()
            $data = [ordered]@{
                Name    = ($objComputer.name).ToString()
                OS      = ($objComputer.operatingSystem).ToString()
                OSVer   = ($objComputer.operatingSystemVersion).ToString()
                DN      = ($objComputer.distinguishedName).ToString()
                Created = ($objComputer.whenCreated).ToString()
                PwdSet  = [datetime]::FromFileTime($objItem.Properties.pwdlastset[0])
            }
            New-Object PSObject -Property $data
        }
        catch {
            # uh-oh, it's implosion time
            Write-Error $_.Exception.Message
        }
    }
}

$computers = Get-Content $inputFile
$count1 = 0
$count2 = 0

Write-Verbose "$($computers.count) computers found in file"

foreach ($computer in $computers) {
    if (Get-ADsComputer -ComputerName $computer) {
        $adx = $True
    } 
    else {
        $adx = $False
    }
    if ((Test-NetConnection -ComputerName $computer -WarningAction SilentlyContinue).PingSucceeded) {
        Write-Verbose "$computer is online"
        $stat = "Online"
        $count1++
    }
    else {
        Write-Verbose "$computer is offline"
        $stat = "Offline"
        $count2++
    }
    $data = [ordered]@{
            Computer  = $computer
            ADAccount = $adx
            Status    = $stat
        }
    New-Object PSObject -Property $data
}
