$icon = "C:\WINDOWS\SoftwareDistribution\Download\7e25ae51952a4bd13880dade57080905\amd64_Microsoft-Windows-Client-Features-Package~~AMD64~~10.0.18234.1000\amd64_microsoft-windows-dxp-deviceexperience_31bf3856ad364e35_10.0.18234.1000_none_cbc9a9b037d94015\netfol.ico"

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$FrmMain = New-Object System.Windows.Forms.Form
$FrmMain.Text = "My Title"
$FrmMain.Size = New-Object System.Drawing.Size(600,400) 
$FrmMain.StartPosition = "CenterScreen"
$FrmMain.Icon = $icon
[void] $FrmMain.ShowDialog()
