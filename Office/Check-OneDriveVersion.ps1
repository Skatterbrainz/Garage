[CmdletBinding()]
param (
    [parameter(Mandatory = $False)]
    [string] $InputFile = "$($env:USERPROFILE)\Documents\pilot_computers.txt",
    [parameter(Mandatory = $False)]
    [string] $RequiredVersion = '18.151.0729.0012',
    [parameter(Mandatory = $False)]
    [switch] $ShowAll
)
$computers = Get-Content $InputFile

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
                        if ($ShowAll) {
                            $data = @{
                                HostName = $computer
                                UserName = $prof.Name
                                OneDrive = $item.VersionInfo.ProductVersion
                                Status   = "Good"
                            }
                        }
                    }
                    else {
                        $data = @{
                            HostName = $computer
                            UserName = $prof.Name
                            OneDrive = $item.VersionInfo.ProductVersion
                            Status   = "Outdated"
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
            if ($ShowAll) {
                $data = @{
                    HostName = $computer
                    UserName = $prof.Name
                    OneDrive = "Inaccessible"
                    Status   = $null
                }
                $result = New-Object PSobject -Property $data
            }
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
