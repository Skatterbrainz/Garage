function Run-PsExec {
    param (
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string[]] $Computer,
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $PSexecPath,
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $Payload
    )
    Start-Transcript -Path "$($env:temp)\run-psexec.log" -Append
    $time1 = Get-Date -Format "hh:mm:ss"

    foreach ($CN in $Computer) {
        try {
            write-output "connecting to $CN"
            if (Test-Connection -ComputerName $CN -Quiet -Count:1) {
                $p = Start-Process -FilePath $PSexecPath -ArgumentList "-AcceptEula -s -c \\$CN $Payload" -Wait -PassThru
                $result = $p.ExitCode
                Write-Output "result: $result"
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
   
    Stop-Transcript
}
