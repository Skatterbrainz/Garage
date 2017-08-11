param (
    [parameter(Mandatory=$True)] $DataSet,
    [parameter(Mandatory=$True)] [string] $Section,
    [parameter(Mandatory=$True)] [string] $FilePath,
    [parameter(Mandatory=$False)] [string] $Heading = "GENERAL",
    [parameter(Mandatory=$False)] [switch] $Append
)
$result = 0
try {
    if ($Append) {
        "`[$Heading`]" | Out-File $FilePath -Append
    }
    else {
        "`[$Heading`]" | Out-File $FilePath
    }
    $DataSet.$Section.Keys | ForEach-Object {$_ + '=' + $DataSet.$Section.$_} | Out-File $FilePath -Append
}
catch {
    $result = -1
}
Write-Output $result
