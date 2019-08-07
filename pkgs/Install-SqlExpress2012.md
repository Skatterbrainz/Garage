# Install: SQL Server 2012 Express 64-bit

## Files

* SQLEXPR_x64_ENU.exe
* Install-SqlExpress2012.ps1
* install.ini
* uninstall.ini

## Instructions

* Drop all of the above files into a common location.
* Run the Install-SqlExpress2012.ps1 script
  * Installation: nothing else required (or change -CfgFile to your own)
  * Uninstall: specify -CfgFile "uninstall.ini" (or change to your own file)

## Notes

* Included .ini files are for x64 ENU version only.  Do not use with x86 or other languages unless you edit the settings.
