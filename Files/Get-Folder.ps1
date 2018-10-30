function Get-Folder {
    param (
        $DefaultPath = "C:\",
        $Caption = "Select Folder"
    )
    [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $Browse = New-Object System.Windows.Forms.FolderBrowserDialog
    $Browse.SelectedPath = $DefaultPath
    $Browse.ShowNewFolderButton = $False
    $Browse.Description = $Caption 
    $Loop = $True
    While ($Loop) {
        if ($Browse.ShowDialog() -eq "OK") {
            $Loop = $False
            $Result = $Browse.SelectedPath
        }
        else {
            $Loop = $False
        }
    }
    $Browse.Dispose()
    Write-Output $Result
}
