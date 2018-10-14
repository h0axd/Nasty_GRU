@echo off

if "%diagauto%" equ "yes" call :autorun
if "%diagauto%" equ ""    call :normalrun
goto :eof

:autorun
echo.
echo               Now running Grub2Win diagnostics
echo. 
echo.
call :sleeper 3
call :runit
call :sleeper 2
exit
goto :eof

:normalrun
call :checkadmin
if "%adminok%" equ "yes" call :checkbase
if "%baseok%"  equ "yes" call :runit
pause
goto :eof

:checkadmin
set adminok=
net session >nul 2>&1
if %errorLevel% == 0 (set adminok=yes
		      goto :EOF)
cls
echo.
echo.
echo.
echo           Note - This script must be run with administrator privileges
echo.
echo             You must right-click the script and "Run as administrator"
echo.
echo.
echo.                            ** Run Cancelled **
echo.
echo.
echo.
goto :eof

:checkbase
cls
set baseok=
set basedir=C:\grub2
echo.
echo.
echo               Starting Grub2Win diagnostic creation
echo.
echo.
echo.
set /p basedir= Please enter the Grub2Win base directory or press enter for default (%basedir%)   
if exist %basedir% (set baseok=yes
		    goto :EOF)
cls
echo.
echo.
echo.
echo               The base directory you entered (%basedir%) was not found
echo                               ** Run Cancelled **
echo.
echo.
echo.
goto :eof

:stampit
echo %~1  >  %~2
date /t   >> %~2
time /t   >> %~2
goto :eof

:sleeper
set /a seconds = %1 + 1
ping -n %seconds% 127.0.0.1 >nul 2>&1 
goto :eof

:runit
cls
echo.
echo               The Grub2Win base directory is %basedir%
set diagdir=%basedir%\diagnose
set partdir=%diagdir%\partitions
if  exist   %diagdir% rd /s /q %diagdir%
md          %diagdir%
md          %partdir%

echo.
echo               Copying files
echo.
echo.
if exist     %basedir%\windata               xcopy /y /q /s   %basedir%\windata        %diagdir%\
if exist     %diagdir%\storage\tempfiles     rd /s /q         %diagdir%\storage\tempfiles
if exist     %basedir%\grub.cfg              copy  /y         %basedir%\grub.cfg       %diagdir%\
if exist     %basedir%\windata\storage\diskreport.txt copy /y %basedir%\windata\storage\diskreport.txt   %partdir%\
if exist     %basedir%\update.log    (
   copy  /y        %basedir%\update.log            %diagdir%\
) else (
   call :stampit "Grub2Win has not yet been run"  %diagdir%\update.log)

md %diagdir%\themes
if exist     %basedir%\themes\*.txt    copy /y          %basedir%\themes\*.txt   %diagdir%\themes

set partin=%partdir%\part.input.txt
set partout=%partdir%\part.output.txt
set errorout=%diagdir%\error.code.txt

if defined errorcode call :stampit "The Grub2Win diagnostic error code is  -  %errorcode%" %errorout%

echo.
echo     Running the Diskpart diagnostics (This may take up to 60 seconds)
echo. 

call :stampit "DiskPart diagnostic starts" %partout%

echo   List   Disk		>>  %partin%
echo   List   Volume		>>  %partin%

echo   Select Disk 0		>>  %partin% 
echo   Detail Disk		>>  %partin%
echo   List   Partition		>>  %partin%

echo   Select Disk 1		>>  %partin% 
echo   Detail Disk		>>  %partin%
echo   List   Partition		>>  %partin%

echo   Select Disk 2		>>  %partin% 
echo   Detail Disk		>>  %partin%
echo   List   Partition		>>  %partin%

echo   Select Disk 3		>>  %partin% 
echo   Detail Disk		>>  %partin%
echo   List   Partition		>>  %partin%

echo   Select Disk 4		>>  %partin% 
echo   Detail Disk		>>  %partin%
echo   List   Partition		>>  %partin%

echo   Select Disk 5		>>  %partin% 
echo   Detail Disk		>>  %partin%
echo   List   Partition		>>  %partin%

echo   Select Disk 6		>>  %partin% 
echo   Detail Disk		>>  %partin%
echo   List   Partition		>>  %partin%

echo   Select Disk 7		>>  %partin% 
echo   Detail Disk		>>  %partin%
echo   List   Partition		>>  %partin%

echo   Select Disk 8		>>  %partin% 
echo   Detail Disk		>>  %partin%
echo   List   Partition		>>  %partin%

echo   Select Disk 9		>>  %partin% 
echo   Detail Disk		>>  %partin%
echo   List   Partition		>>  %partin%

echo   Exit			>>  %partin%

diskpart /s %partin%		>>  %partout%

rem If Not XP then run the BCD routines
ver | find "5.1" 2>nul
if "%errorlevel%" neq "0" call :bcdruns
dir /s /O:GN %basedir%           >  %diagdir%\dirlisting.txt

cls
echo.
echo.
echo.
echo.
echo                    The diagnostic files are in directory
echo.
echo                            %diagdir%
echo.
echo.
echo               ** Grub2Win diagnostic creation has completed **
echo.
echo.
echo.
goto :eof

:bcdruns
echo.
echo               Running the BCD diagnostics
echo. 

set bcddir=%diagdir%\bcdlists
set bcdeditout=%bcddir%\bcdedit.output.txt
set bcdfirmout=%bcddir%\bcdfirmware.output.txt
md %bcddir%

if exist %diagdir%\backup\*.bcd   erase /q          %diagdir%\backup\*.bcd

call :stampit "BCDEdit diagnostic starts"           %bcdeditout%
bcdedit.exe                                     >>  %bcdeditout%  2>nul
C:\windows\sysnative\bcdedit.exe                >>  %bcdeditout%  2>nul

call :stampit "BCD Firmware diagnostic starts"      %bcdfirmout%
bcdedit.exe /enum firmware                      >>  %bcdfirmout%  2>nul
C:\windows\sysnative\bcdedit.exe /enum firmware >>  %bcdfirmout%  2>nul
goto :eof