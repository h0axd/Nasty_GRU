@echo off
echo.
echo                   Starting Grub2Win silent install
echo.
echo       Note: For EFI systems, the install may run up to 2 minutes
echo.
cd "%~dp0"
if exist grub2win.exe (
   	start /wait grub2win.exe  Silent   Drive=C:  Shortcut=Yes
        if errorlevel 99 goto :setuperror
        goto :endit)
echo Grub2Win.exe was not found
pause
goto :endit

:setuperror
echo.
echo *** An error occured during Grub2Win silent install ***
echo.
pause
exit

:endit
echo.
echo       Grub2Win silent install is complete
echo.
pause