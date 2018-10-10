#requires -Version 3
<#
.DESCRIPTION
    Get OneDrive sync client version for each user on each computer in a list
.PARAMETER InputType
    List: AD or File
.PARAMETER InputFile
    File with computer names
.PARAMETER RequiredVersion
    Version to compare and show "Good" or not
.PARAMETER SelectComputers
    Displays computer names in gridview to select individually
.NOTES
    1.0.0 - DS - First release
    1.0.1 - DS - Added AD input option
    1.0.2 - DS - Added SelectComputers option
.EXAMPLE
    .\Get-OneDriveVersion.ps1 -InputType AD -SelectComputers
.EXAMPLE
    .\Get-OneDriveVersion.ps1 -InputType File -InputFile ".\computers.txt" -SelectComputers
#>

[CmdletBinding()]
param (
    [parameter(Mandatory = $False)]
        [ValidateSet('AD','File')]
        [string] $InputType = 'AD',
    [parameter(Mandatory = $False)]
        [string] $InputFile = "$($env:USERPROFILE)\Documents\pilot_computers.txt",
    [parameter(Mandatory = $False)]
        [string] $RequiredVersion = '18.151.0729.0012',
    [parameter(Mandatory = $False)]
        [switch] $SelectComputers,
    [parameter(Mandatory = $False)]
        [switch] $ShowAll
)
switch ($InputType) {
    'AD' {
        Write-Host "retrieving computers from Active Directory..." -ForegroundColor Cyan
        $strFilter = "(objectCategory=Computer)"
        $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
        $objSearcher.Filter = $strFilter
        $objSearcher.PageSize = 2000
        $objPath = $objSearcher.FindAll()
        $computers = @()

        foreach ($objItem in $objPath) {
            try {
                $objComputer = $objItem.GetDirectoryEntry()
                $computers += ($objComputer.name).ToString()
            }
            catch {
                # uh-oh, it's implosion time
                Write-Error $_.Exception.Message
            }
        }
        Write-Host "$($computers.count) computers found in AD" -ForegroundColor Cyan
        break
    }
    'File' {
        if (!(Test-Path -Path $InputFile)) {
            Write-Warning "$InputFile not found!"
            break
        }
        $computers = Get-Content $InputFile
        Write-Host "$($computers.count) computers imported from file" -ForegroundColor Cyan
        break
    }
} # switch

if ($SelectComputers) {
    $computers = $computers | Sort-Object | Out-GridView -Title "Select Computers" -OutputMode Multiple
    Write-Host "$($computers.count) selected for processing"
}
else {
    Write-Host "processing for $($computers.count) computers" -ForegroundColor Cyan
}

foreach ($computer in $computers) {
    if ((Test-NetConnection -ComputerName $computer -WarningAction SilentlyContinue).PingSucceeded) {
        #write-host "$computer is online" -ForegroundColor Cyan
        $tpath = "\\$computer\C`$\users"
        try {
            $profiles = Get-ChildItem -Path $tpath -ErrorAction SilentlyContinue
            $profiles = $profiles | 
                Where-Object {$_.BaseName -ne 'Public' -and $_.BaseName -notlike "Admin*"} | 
                    Sort-Object LastWriteTime -Descending
            #Write-Host "...$($profiles.Count) profiles found"
            foreach ($prof in $profiles) {
                #write-host "...$($prof.Name)" -ForegroundColor Green
                $opath = "$tpath\$($prof.Name)\AppData\Local\Microsoft\OneDrive\OneDrive.exe"
                Write-Verbose "...checking: $opath"
                try {
                    $item = Get-ChildItem -Path "$opath" -ErrorAction SilentlyContinue
                    if ($item.VersionInfo.ProductVersion -eq $RequiredVersion) {
                        $data = @{
                            HostName = $computer
                            UserName = $prof.Name
                            OneDrive = $item.VersionInfo.ProductVersion
                            Status   = "Good"
                        }
                    }
                    else {
                        $data = @{
                            HostName = $computer
                            UserName = $prof.Name
                            OneDrive = $item.VersionInfo.ProductVersion
                            Status   = $null
                        }
                        $result = New-Object PSobject -Property $data
                    }
                }
                catch {
                    $data = @{
                        HostName = $computer
                        UserName = $prof.Name
                        OneDrive = "Not Found"
                        Status   = $null
                    }
                    $result = New-Object PSobject -Property $data
                }
            }
        }
        catch {
            $data = @{
                HostName = $computer
                UserName = $prof.Name
                OneDrive = "Inaccessible"
                Status   = $null
            }
            $result = New-Object PSobject -Property $data
        }
    }
    else {
        $data = @{
            HostName = $computer
            UserName = $null
            OneDrive = $null
            Status   = "Offline"
        }
        $result = New-Object PSobject -Property $data
    }
    $profiles = $null
    , $result
}
