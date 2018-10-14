@echo off

set rundir="%~dp0"

cls
echo.
echo.
echo This will run Grub2Win in a special EFI maintenance mode
echo.
echo It is possible to render your system unbootable
echo.
echo Please be sure you have good bootable backups of your Windows and EFI partitions
echo.
echo Do you want to continue? y or n
echo.
call :chooseit 
if "%choosereturn%" EQU "y" call :runefi
if "%choosereturn%" EQU "n" (
             echo.
             echo The Grub2Win EFI Maintenance run was cancelled
             call :sleeper 3
             exit)

:runefi
cd ..
if exist grub2win.exe (
   	echo Starting Grub2Win in EFI maintenance mode
        call :sleeper 2
        start grub2win.exe  EFIMaint
        exit)
echo.

echo   Grub2Win.exe was not found! 
echo.
echo.
pause
goto :eof

:chooseit
if "%xpsystem%" equ "y" (call :deciderxp choosereturn 
                         goto :eof
)
choice /n /c yn
if %errorlevel% equ 2 set choosereturn=n
if %errorlevel% equ 1 set choosereturn=y
goto :eof

:deciderxp
set /p decision=""
if /i NOT "%decision%" equ "n" (
    if /i NOT "%decision%" equ "y" (
	call :displayit 
    	goto deciderxp)
)
set   "%~1=%decision%"
goto :eof

:sleeper
set /a seconds = %1 + 1
ping -n %seconds% 127.0.0.1 >nul 2>&1 
goto :eof