param (
    [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $FilePath,
    [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $PayloadFile
)
$Servers  = Get-Content $FilePath
$UserName = "AdminUser"
$Password = 'P@ssW0rd123'

foreach ($Server in $Servers) {
    Write-Output "winrs -r:$Server -u:$UserName -p:$Password $PayloadFile"
}
