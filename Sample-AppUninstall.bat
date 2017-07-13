@echo off
:: ------------------------------------------------------------
:: filename..... uninstall-odyssey.bat
:: description.. uninstall script for Odyssey
:: created on... 04/08/2015
:: created by... David Stein
:: ------------------------------------------------------------
TITLE Software Removal Package
SET APPNAME=Odyssey
SET INSTMODE=Uninstall
SET PFX=ABC
SET LOG=%TEMP%\%PFX%-%APPNAME%-%INSTMODE%.LOG
:: ------------------------------------------------------------
echo %DATE% %TIME% info: computername... %COMPUTERNAME% >%LOG%
echo %DATE% %TIME% info: package name... %APPNAME% >>%LOG%
echo %DATE% %TIME% info: sourcepath..... %~dp0 >>%LOG%
echo %DATE% %TIME% info: user context... %USERNAME% >>%LOG%
echo %DATE% %TIME% info: windir......... %WINDIR% >>%LOG%
echo %DATE% %TIME% info: progfiles...... %PROGRAMFILES% >>%LOG%
echo %DATE% %TIME% info: script version. 2015.04.08.02 >>%LOG%
echo UNINSTALL LOG: %LOG% >>%LOG%
echo ------------------------------------------------ >>%LOG%
echo %DATE% %TIME% info: searching for installed components... >>%LOG%
if exist "%ProgramFiles(x86)%\Tyler Technologies\Odyssey Assistant\Odyssey.exe" GOTO REMOVE
GOTO NOTFOUND

:REMOVE
echo %DATE% %TIME% info: installation found. uninstalling software... >>%LOG%
echo %DATE% %TIME% info: command... msiexec /x {0A864B6A-DDDE-4739-A896-559F3E86487F} REBOOT=ReallySuppress /qb! >>%LOG%
msiexec /x {0A864B6A-DDDE-4739-A896-559F3E86487F} REBOOT=ReallySuppress /qb!
SET EXITCODE=%ERRORLEVEL%
if %EXITCODE% == 0 (
	echo %DATE% %TIME% info: uninstall was SUCCESSFUL >>%LOG%
	GOTO CONFIG
) else (
	echo %DATE% %TIME% error: exit code is %EXITCODE% >>%LOG%
	GOTO END
)

:NOTFOUND
echo %DATE% %TIME% info: installation not found. returning code 1605 >>%LOG%
SET EXITCODE=1605
GOTO END

:CONFIG
echo %DATE% %TIME% info: cleaning up registry... >>%LOG%
reg delete "HKLM\SOFTWARE\Wow6432Node\Tyler Technologies" /F >>%LOG%
echo %DATE% %TIME% info: cleaning up folders and files... >>%LOG%
del /S /F /Q "C:\Program Files (x86)\Tyler Technologies\Odyssey\*.*" >>%LOG%
rd /S /Q "C:\Program Files (x86)\Tyler Technologies\Odyssey" >>%LOG%
echo %DATE% %TIME% info: clean up complete. >>%LOG%
GOTO END

:END
EXIT %EXITCODE%
