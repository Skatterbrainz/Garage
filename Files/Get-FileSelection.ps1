function Get-FileSelection {
    param (
        [parameter(Mandatory=$True, HelpMessage="Path to files")]
        [ValidateNotNullOrEmpty()]
        [string] $FolderPath,
        [parameter(Mandatory=$False, HelpMessage="File extension (*.txt is default)")]
        [string] $FileType = "*.txt"
    )
    try {
        $files = Get-ChildItem -Path $FolderPath -Filter $FileType
        $select = $files | Sort-Object Name | Select -ExpandProperty Name | 
            Out-GridView -Title "Select File" -OutputMode Single
        if ($select) {
            $result = Get-Item -Path $(Join-Path -Path $FolderPath -ChildPath $select)
        }
    }
    catch {
        Write-Warning $Error[0].Exception.Message
    }
    $result
}
