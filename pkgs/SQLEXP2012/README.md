# Install: SQL Server 2012 Express 64-bit

## Files

* SQLEXPR_x64_ENU.exe
* Install-SqlExpress2012.ps1
* install.ini
* uninstall.ini

## Instructions

* Drop all of the above files into a common location.
* Run the Install-SqlExpress2012.ps1 script

```powershell
Install-SqlExpress2012.ps1 -Verbose
# or
Install-SqlExpress2012.ps1 -CfgFile "install.ini" -Verbose
```

```powershell
Install-SqlExpress2012.ps1 -CfgFile "uninstall.ini" -Verbose
```

## Notes

* Included .ini files are for x64 ENU version only.  Do not use with x86 or other languages unless you edit the settings.
