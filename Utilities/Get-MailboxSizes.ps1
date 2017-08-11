<#
.SYNOPSIS
    Get-MailboxSizes.ps1

.DESCRIPTION
    Returns details about Office 365/Exchange 2016 mailboxes including
    total mailbox sizes, outputs to CSV file

.PARAMETER Office365Username
    Mandatory - String - Login name for Office 365 Admin account

.PARAMETER Office365UserPassword
    Mandatory - String - Login password for Office 365 Admin account

.PARAMETER UserIDFile
    Optional - String - Name of input CSV to limit search scope
    Default = ""

.PARAMETER OutputFile
    Optional - String - Name of output CSV file to create
    Default = "mailboxsizes.csv"

.PARAMETER LimitTo
    Optional - Integer - Number of accounts / mailboxes to limit search to
    Default = 10
    Set to 0 (zero) to specify all/unlimited

.INPUTS 
    None

.OUTPUTS
    CSV data file

.EXAMPLE
    .\Get-MailboxSizes.ps1 -Office365Username "foo.bar@******.onmicrosoft.com" -Office365Password "P@ssW0rd321"

.EXAMPLE
    .\Get-MailboxSizes.ps1 -Office365Username "foo.bar@******.onmicrosoft.com" -Office365Password "P@ssW0rd321" -LimitTo 25

.EXAMPLE
    .\Get-MailboxSizes.ps1 -Office365Username "foo.bar@******.onmicrosoft.com" -Office365Password "P@ssW0rd321" -UserIDFile "testusers.csv"

.EXAMPLE
    .\Get-MailboxSizes.ps1 -Office365Username "foo.bar@******.onmicrosoft.com" -Office365Password "P@ssW0rd321" -OutputFile "mailboxes.csv"

.NOTES
    Created by: David M. Stein
    Date Created: 03/03/2017
    Last Modified: N/A
#>


param ( 
    [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)] 
        [string] $Office365Username, 
    [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)] 
        [string] $Office365Password,
    [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)] 
        [string] $UserIDFile = "",
    [Parameter(Position=3, Mandatory=$False, ValueFromPipeline=$true)]
        [string] $OutputFile = "mailboxsizes.csv",
    [Parameter(Position=4, Mandatory=$False, ValueFromPipeline=$true)]
        [int] $LimitTo = 10
) 

Function Show-Progress {
    param (
        [parameter(Mandatory=$True)] [string] $Caption = "Progress",
        [parameter(Mandatory=$False)] [string] $Message = "Please wait...",
        [parameter(Mandatory=$True)] [int] $CurrentIndex,
        [parameter(Mandatory=$True)] [int] $TotalCount
    )
    $pct = ($CurrentIndex / $TotalCount) * 100
    Write-Progress -Activity $Caption -Status "$Message" -PercentComplete $pct -Id 1
    Start-Sleep 1
}

function ConnectTo-ExchangeOnline {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [String]$Office365AdminUsername,
        [Parameter(Mandatory=$true, Position=1)]
        [String]$Office365AdminPassword
    )
    $SecureOffice365Password = ConvertTo-SecureString -AsPlainText $Office365AdminPassword -Force
    $Office365Credentials  = New-Object System.Management.Automation.PSCredential $Office365AdminUsername, $SecureOffice365Password
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $Office365credentials -Authentication Basic -AllowRedirection
    Import-PSSession $Session -AllowClobber | Out-Null
}

# capture start time to calculate total runtime at the end
$startTime = Get-Date

Get-PSSession | Remove-PSSession 

ConnectTo-ExchangeOnline -Office365AdminUsername $Office365Username -Office365AdminPassword $Office365Password
Out-File -FilePath $OutputFile -InputObject "UserPrincipalName,SamAccountName,WhenCreated,Resource,ItemCount,MailboxSize" -Encoding utf8

Show-Progress -Caption "Getting Mailboxes" -Message "Reading Source..." -CurrentIndex 1 -TotalCount 100
if ($UserIDFile -ne "") {
    Write-Verbose "reading input file: $UserIDFile"
    $objUsers = Import-Csv -Header "UserPrincipalName" $UserIDFile
}
else {
    if ($LimitTo -gt 0) {
        Write-Verbose "reading $LimitTo mailbox users..."
        $objUsers = Get-Mailbox -ResultSize $LimitTo
    }
    else {
        Write-Verbose "reading all mailbox users..."
        $objUsers = Get-Mailbox -ResultSize Unlimited
    }
}
$tnum = $objUsers.Count
Write-Verbose "retrieved $tnum accounts"
$rownum = 1

foreach ($objUser in $objUsers) {
    # UserPrincipalName, SamAccountName, WhenCreated, ItemCount, MailboxSize
    $strUserPrincipalName = $objUser.UserPrincipalName 
    $sam = $objUser.SamAccountName

    Show-Progress -Caption "Checking Mailboxes" -Message "[$rownum] of [$tnum]: $strUserPrincipalName" -CurrentIndex $rownum -TotalCount $tnum
         
    Write-Verbose "getting mailbox: $strUserPrincipalName"
    $objUserMailbox = Get-MailboxStatistics -Identity $($objUser.UserPrincipalName)
    $DateCreated = $objUser.WhenMailboxCreated.ToShortDateString()
    $IsResource  = $objUser.IsResource
    $mailCount   = $objUserMailbox.ItemCount 
    $mailSpace   = $objUserMailbox.TotalItemSize
    $rowDetails  = "$strUserPrincipalName,$sam,$DateCreated,$IsResource,$mailCount,$mailSpace"
    Out-File -FilePath $OutputFile -InputObject $rowDetails -Encoding UTF8 -Append
    $rownum++
}
Get-PSSession | Remove-PSSession 

$StopTime = Get-Date

$RunSecs  = ((New-TimeSpan -Start $startTime -End $StopTime).TotalSeconds).ToString()
$ts = [timespan]::FromSeconds($RunSecs)
$RunTime = $ts.ToString("hh\:mm\:ss")

#Write-Host "------------------------------------------------"
Write-Output "info: $tnum rows were processed."
Write-Output "info: total runtime was $RunTime (hh:mm:ss)"
