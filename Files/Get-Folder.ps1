function Get-Folder {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$False, HelpMessage="Default Folder Path")]
        [ValidateNotNullOrEmpty()]
        [string] $DefaultPath = "C:\",
        [parameter(Mandatory=$False, HelpMessage="Dialog Caption text")]
        [ValidateNotNullOrEmpty()]
        [string] $Caption = "Select Folder"
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
            Write-Verbose "clicked ok button"
        }
        else {
            $Loop = $False
            Write-Verbose "clicked cancel or closed form"
        }
    }
    $Browse.Dispose()
    Write-Output $Result
}
