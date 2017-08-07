
function Run-PsExec {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [parameter(Mandatory=$True, HelpMessage="Name(s) of Computers to execute")]
            [ValidateNotNullOrEmpty()]
            [string[]] $Computer,
        [parameter(Mandatory=$True, HelpMessage="Path to Psexec.exe")]
            [ValidateNotNullOrEmpty()]
            [string] $PSexecPath,
        [parameter(Mandatory=$True, HelpMessage="Path to script or command to invoke on remote clients")]
            [ValidateNotNullOrEmpty()]
            [string] $Payload
    )

    $time1 = Get-Date -Format "hh:mm:ss"
    Start-Transcript -Path "$($env:temp)\run-psexec.log"
    If ($WhatIfPreference -eq $True) { Write-Output "WHAT IF???" }
    foreach ($CN in $Computer) {
        try {
            write-output "connecting to $CN"
            if (Test-Connection -ComputerName $CN -Quiet -Count:1) {
                If ($WhatIfPreference -ne $True) { 
                    $p = Start-Process -FilePath $PSexecPath -ArgumentList "-AcceptEula -s -c \\$CN $Payload" -Wait -PassThru
                    $result = $p.ExitCode
                    Write-Output "result: $result"
                }
                else {
                    Write-Output "WHAT-IF: (would have run) start-process -FilePath $PSexecPath -ArgumentList `-AcceptEula -s -c \\$CN $Payload`" -Wait -PassThru"
                }
            }
            else {
                Write-Output "$CN is offline"
            }
        }
        catch {
            write-output "failed to connect to $CN"
        }
    }
    $time2   = Get-Date -Format "hh:mm:ss"
    $RunTime = New-TimeSpan $time1 $time2
    $Difference = "{0:g}" -f $RunTime
    Write-Output "completed in (HH:MM:SS) $Difference"
    if ($WhatIfPreference -ne $True) { Stop-Transcript }
}
