iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
#SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

$coreapps = @(
'googlechrome'
'googledrive'
'googleearth'
'rdcman'
'wudt'
'7zip'
'vlc'
'notepadplusplus'
'paint.net'
'sysinternals'
'filezilla'
'keepass'
'azurepowershell'
'slack'
)

foreach ($app in $coreapps) {
    choco install $app -y
}