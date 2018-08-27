function Stop-CitrixReceiver {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param ()
    try {
        Stop-Process -Name "Receiver" -Force
        Write-Output "receiver stopped successfully"
    }
    catch {
        Write-Error $_.Exception.Message
    }
    try {
        Stop-Process -Name "redirector" -ErrorAction SilentlyContinue
        Write-Output "redirector stopped successfully"
    }
    catch {
        if (-not($_.Exception.Message -like "*Cannot find a process*")) {
            Write-Error $_.Exception.Message
        }
    }
}

function Start-CitrixReceiver {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        $receiver = "$(${env:ProgramFiles(x86)})\Citrix\ICA Client\Receiver\Receiver.exe",
        $redirector = "$(${env:ProgramFiles(x86)})\Citrix\ICA Client\Redirector.exe"
    )
    $arglist = "-autoupdate -startplugins -disableshowcontrolpanel"
    try {
        Start-Process -FilePath $receiver -ArgumentList $arglist
        Write-Output "receiver started successfully"
    }
    catch {
        Write-Error $_.Exception.Message
    }
    try {
        Start-Process -FilePath $redirector
        Write-Output "redirector started successfully"
    }
    catch {
        Write-Error $_.Exception.Message
    }
}

function Restart-CitrixReciever {
    [CmdletBinding(SupportsShouldProcess=$True)]
    param (
        [int] $WaitSeconds = 3
    )
    Stop-CitrixReceiver
    Start-Sleep -Seconds $WaitSeconds
    Start-CitrixReceiver
}
