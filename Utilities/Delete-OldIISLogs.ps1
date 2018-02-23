[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [parameter(Mandatory=$False, HelpMessage="IIS log folder path")]
        [ValidateNotNullOrEmpty()]
        [string] $LogPath = "c:\inetpub\logs",
    [parameter(Mandatory=$False, HelpMessage="How many days of log files to retain")]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1,366)]
        [int] $DaysToKeep = 30,
    [parameter(Mandatory=$False, HelpMessage="Output transaction log")]
        [ValidateNotNullOrEmpty()]
        [string] $TransactionLog = "c:\windows\temp\cleanup_old_iislogs.log"
)
$OldFiles = dir $LogPath -Recurse -File *.log | Where-Object {$_.LastWriteTime -lt ((Get-Date).AddDays(-$DaysToKeep))}

if ($OldFiles.Count -gt 0) {
    foreach ($file in $OldFiles) {
        "$($file.BaseName) is older than $((Get-Date).AddDays(-$DaysToKeep)) and will be deleted" | Add-Content $TransactionLog
        Get-Item $file | Remove-Item -Verbose
    }
}
else {
    "No items to be deleted on $($(Get-Date).DateTime)" | Add-Content $TransactionLog
}
Write-Output "cleanup of log files older than $((Get-Date).AddDays(-$DaysToKeep)) completed."
