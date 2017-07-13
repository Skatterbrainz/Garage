@echo off
rem ****************************************************************
rem  Filename..: appinstall.bat
rem  Author....: David M. Stein
rem  Date......: 04/02/2015
rem  Purpose...: example BAT script for SCCM package
rem ****************************************************************
CLS
SETLOCAL
set APPNAME=ProductName
set PKGVER=2015.04.02.01
rem title Installing %APPNAME%
echo Installing %APPNAME% ...
set PFX=ABC
set LOG=%TMP%\%PFX%_%APPNAME%_install.log
set MSI=/quiet /norestart
echo %DATE% %TIME% installing... %APPNAME%... >%LOG%
echo %DATE% %TIME% scriptver.... %PKGVER% ... >>%LOG%
echo %DATE% %TIME% source....... %~dps0 >>%LOG%
echo %DATE% %TIME% target....... %COMPUTERNAME% >>%LOG%
echo %DATE% %TIME% windir....... %WINDIR% >>%LOG%
echo %DATE% %TIME% progfiles.... %PROGRAMFILES% >>%LOG%
echo %DATE% %TIME% temp......... %TMP% >>%LOG%
echo INSTALL LOG: %LOG%
echo ------------------------------------------------ >>%LOG%
echo %DATE% %TIME% info: checking if Fubar 2011 is already installed... >>%LOG%
if exist "%ProgramFiles%\Fubar 2011\fubar.exe" (
	echo %DATE% %TIME% info: ## Fubar 2011 is already installed >>%LOG%
) else (
	echo %DATE% %TIME% info: ## installing Fubar 2011 ... >>%LOG%
	if exist "%~dps0Fubar2011setup.MSI" (
		echo %DATE% %TIME% command = msiexec /i "%~dps0Fubar2011setup.MSI" >>%LOG%
		msiexec /i "%~dps0Fubar2011setup.MSI" %MSI%
		if %errorlevel% == 0 (
			echo %DATE% %TIME% info: installation SUCCESSFUL >>%LOG%
		) else (
			echo %DATE% %TIME% fail: exit code is %errorlevel% >>%LOG%
			exit %errorlevel%
		)
	) else (
		echo %DATE% %TIME% fail: source installer not found! >>%LOG%
		exit 1612
	)
)
echo ----------------------------------------------- >>%LOG%
echo %DATE% %TIME% completed! result code: %errorlevel% >>%LOG%
ENDLOCAL
exit %errorlevel%
