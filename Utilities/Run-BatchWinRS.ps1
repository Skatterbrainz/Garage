param (
    [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $FilePath,
    [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $PayloadFile,
    [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $RunasUser,
    [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $RunasPassword
)
$Servers  = Get-Content $FilePath

foreach ($Server in $Servers) {
    Write-Output "winrs -r:$Server -u:$RunasUser -p:$RunasPassword $PayloadFile"
}
