@echo off
rem ------------------------------------------------------------------
rem filename.... install_project.bat
rem author...... David Stein
rem date........ 2018.09.25
rem purpose..... offline installation of Project Client for Office 365 ProPlus for remote devices
rem ------------------------------------------------------------------
cls
title Project for Office 365 ProPlus Offline Installation
SET LOG=%TEMP%\install_project365.log
SET EXITCODE=0
echo %DATE% %TIME% info: installing Microsoft Project O365 64bit >%LOG%
echo %DATE% %TIME% info: username......... %USERNAME% >>%LOG%
echo %DATE% %TIME% info: computername..... %COMPUTERNAME% >>%LOG%
echo %DATE% %TIME% info: domain........... %USERDNSDOMAIN% >>%LOG%
echo %DATE% %TIME% info: logonserver...... %LOGONSERVER% >>%LOG%
echo %DATE% %TIME% info: script version... 2018.10.19 Rev 0 >>%LOG%
echo --------------------------------------------------------- >>%LOG%
if exist "%~dp0setup.exe" goto CHECKSETUP
goto NOTFOUND

:CHECKSETUP
echo Searching for Office 2016 or Office 365 ProPlus 64bit...
echo %DATE% %TIME% info: Searching for Office 2016 or Office 365 ProPlus 64bit >>%LOG%
if exist "%programfiles%\Microsoft Office\root\Office16\EXCEL.exe" goto PREINSTALL
if exist "%programfiles(x86)%\Microsoft Office\root\Office16\EXCEL.exe" goto FAILPREREQ
echo %DATE% %TIME% info: Office 365 ProPlus products not found / aborting >>%LOG%
rem pause
goto DONE

:PREINSTALL
echo --------------------------------------------------------- >>%LOG%
echo %DATE% %TIME% info: searching for "%ProgramFiles%\Microsoft Office\root\Office16\WINPROJ.EXE" >>%LOG%
if not exist "%ProgramFiles%\Microsoft Office\root\Office16\WINPROJ.EXE" goto INSTALL
rem pause
goto DONE

:INSTALL
echo --------------------------------------------------------- >>%LOG%
echo %DATE% %TIME% info: installing Project for Office 365 Pro 64bit >>%LOG%
echo Installing Project for Office 365 Professional 64 bit...
echo %DATE% %TIME% info: command is %~dp0setup.exe /configure %~dp0install.xml >>%LOG%
"%~dp0setup.exe" /configure "%~dp0install.xml"
SET EXITCODE=%ERRORLEVEL%
echo %DATE% %TIME% info: exit code is %EXITCODE% >>%LOG%
if %ERRORLEVEL% == 0 goto SUCCESS
goto FAIL

:SUCCESS
echo %DATE% %TIME% info: installation completed successfully >>%LOG%
echo Installation completed successfully!
echo Review log file at %LOG%
rem pause
goto POSTCONFIG

:POSTCONFIG
echo --------------------------------------------------------- >>%LOG%
echo %DATE% %TIME% info: performing post installation configuration tasks >>%LOG%
echo Configuring Office options and settings...
rem ----
rem add more if needed
rem ----
echo %DATE% %TIME% info: post install tasks completed >>%LOG%
goto FINISH

:NOTFOUND
SET EXITCODE=1
echo %DATE% %TIME% error: setup.exe was not found in %~dp0 >>%LOG%
echo Installation Failed! setup.exe was not found in script path %~dp0.
goto END

:FAILPREREQ
echo %DATE% %TIME% info: 32-bit Office 365 ProPlus products are already installed >>%LOG%
echo ###########################################################################################
echo ###                                                                                     ###
echo ###                    32-bit Office 365 ProPlus is installed                           ###
echo ###         Project 64-bit cannot be installed with Office 32-bit products              ###
echo ###                                                                                     ###
echo ###########################################################################################
goto END

:DONE
echo %DATE% %TIME% info: Project for Office 365 ProPlus 64bit are already installed >>%LOG%
echo ###########################################################################################
echo ###                                                                                     ###
echo ###         Project Client for Office 365 ProPlus 64bit is already installed            ###
echo ###                                                                                     ###
echo ###########################################################################################
goto END

:FAIL
echo %DATE% %TIME% error: installation failed with exit code %EXITCODE% >>%LOG%
echo ###########################################################################################
echo ###                                                                                     ###
echo ###               Project for Office 365 installation Failed! %EXITCODE%                ###
echo ###                                                                                     ###
echo ###########################################################################################
echo Review log file at %LOG%
goto END

:FINISH
echo %DATE% %TIME% info: Project for Office 365 installation successful. >>%LOG%
echo ###########################################################################################
echo ###                                                                                     ###
echo ###                Project for Office 365 installation was successful!                  ###
echo ###                                                                                     ###
echo ###########################################################################################
echo Review log file at %LOG%
goto END

:END
exit /B %EXITCODE%
