#include-once
#include <Constants.au3>
#include <Date.au3>
#include <GUIConstantsEx.au3>

Const  $windowsdrive      = EnvGet ("SystemDrive")
Const  $windowstemp       = EnvGet ("TEMP")
Const  $windowstempgrub   = $windowstemp & "\grub2win"
Const  $zippedcode        = $windowstempgrub & "\install.7z"
Const  $basestring        = "grub2"
Const  $configstring      = "grub.cfg"
Const  $bootmanstring     = "g2bootmgr"
Const  $exestring         = "grub2win.exe"
Const  $customtempname    = "custom.temp.txt"
Const  $syntaxorigname    = "syntax.orig.txt"
Const  $filesuffixin      = ".in.txt"
Const  $filesuffixout     = ".out.txt"
Const  $backupdelim       = "<g2b>"
Const  $efitargetstring   = "\EFI\grub2win"
Const  $setuplogstring    = "\grub2win.setup.log.txt"
Const  $actionsilent      = "Silent"
Const  $advancedmode      = "AdvancedMode"
Const  $foundstring       = "Grub2Win-Found"
Const  $helptitle         = "Grub2Win User Manual"
Const  $mywhite           = 0xFFFFFF ; White       RGB
Const  $myblack           = 0x000000 ; Black       RGB
Const  $myred             = 0xFF0000 ; Red         RGB
Const  $myyellow          = 0xFFFF00 ; Yellow      RGB
Const  $mygreen           = 0x00DD00 ; Green       RGB
Const  $myblue            = 0x95DDFF ; Blue        RGB
Const  $mypurple          = 0xCC00CC ; Purple      RGB
Const  $myorange          = 0xFF7710 ; Orange      RGB
Const  $mymedblue         = 0x58A6D6 ; Medium Blue RGB
Const  $mylightgray       = 0xEEEEEE ; Light  Gray RGB
Const  $mymedgray         = 0x777777 ; Medium Gray RGB
Const  $mbontop           = 0x040000 ; MsgBox on top flag
Const  $mberrorok         = $mbontop  + $MB_ICONERROR
Const  $mbwarnok          = $mbontop  + $MB_ICONWARNING
Const  $mbwarnyesno       = $mbontop  + $MB_ICONWARNING     + $MB_YESNO
Const  $mbwarnokcan       = $mbontop  + $MB_ICONWARNING     + $MB_OKCANCEL
Const  $mbquestyesno      = $mbontop  + $MB_ICONQUESTION    + $MB_YESNO
Const  $mbquestyesnocan   = $mbontop  + $MB_ICONQUESTION    + $MB_YESNOCANCEL
Const  $mbinfook          = $mbontop  + $MB_ICONINFORMATION
Const  $mbinfookcan       = $mbontop  + $MB_ICONINFORMATION + $MB_OKCANCEL
Const  $guihideit         = $GUI_HIDE + $GUI_DISABLE
Const  $guishowit         = $GUI_SHOW + $GUI_ENABLE
Const  $guishowdis        = $GUI_SHOW + $GUI_DISABLE
Const  $kilo              = 2     ^ 10  ; 1024
Const  $mega              = $kilo ^  2  ; 1,048,576
Const  $giga              = $kilo ^  3  ; 1,073,741,824
Const  $tera              = 10    ^ 12  ; 1,000,000,000,000   Decimal by convention
Const  $lastbooted        = "** Last Booted OS **"
Const  $modepartaddress   = "Partition Address"
Const  $modepartlabel     = "Partition Search By Label"
Const  $modepartfile      = "Partition Search By File"
Const  $modebootdir       = "Search By Boot Directory"
Const  $selbootdir        = "Select Boot Directory"
Const  $selkernel         = "Select Kernel File"
Const  $selisofile        = "Select ISO File"
Const  $modechainloader   = "Chainloader"
Const  $modecustom        = "I Will Enter My Own Custom Configuration Code"
Const  $modewinauto       = "Windows Automatic"
Const  $biosdesc          = "Grub 2 For Windows"
Const  $bsdbootfile       = "/boot/loader"
Const  $graphsize         = @DesktopWidth & "x" & @DesktopHeight
Const  $autostring        = "** Auto **"
Const  $graphstring       = "800x600|1024x768|1152x864|1280x1024|1600x1200|" & $graphsize
Const  $graphautostring   = $autostring & "|" & $graphstring
Const  $graphdefault      = $autostring
Const  $graphconfigauto   = "1024x768,800x600,auto"
Const  $graphnotset       = "not set"
Const  $hotkeyalpha       = "|none|a|b|d|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|w|x|y|z"
Const  $hotkeystring      = $hotkeyalpha & "|0|1|2|3|4|5|6|7|8|9|backspace|delete|tab|"
Const  $nothemedesc       = "** No Theme - Text Only **"
Const  $notheme           = "notheme"
Const  $noface            = "** No Clock Face **"
Const  $ticksonly         = "** Clock Ticks Only **"
Const  $langspacer        = "  -  "
Const  $bcddashline       = "-----"
Const  $langenglish       = "English"
Const  $langdefcode       = "en"
Const  $efilevelfile      = "\gnugrub.efilevel"
Const  $efimodefile       = "\gnugrub.efimode"
Const  $firmgrub          = "firm-grub2win"
Const  $winbootmgr        = "bootmgfw.efi"
Const  $winloaderefi      = "winload.efi"
Const  $driverfilepath    = "\xupdate.paths.cfg"
Const  $driverfileata     = "\xdriver.ata.cfg"
Const  $driverfilecrypt   = "\xdriver.crypt.cfg"
Const  $driverfilelv      = "\xdriver.lv.cfg"
Const  $driverfileraid    = "\xdriver.raid.cfg"
Const  $driverfileusb     = "\xdriver.usb.cfg"
Const  $driverfilesleep   = "\xdriver.sleep.cfg"
Const  $shortcutfile      = @DesktopDir & "\Grub2Win.lnk"
Const  $customcodestart   = "start-custom-code"
Const  $customcodeend     = "end-custom-code"
Const  $androidbootdir    = "/android-7.1-r1"
Const  $remixbootkern     = "/RemixOS/kernel"
Const  $remixbootimg      = "/RemixOS/initrd.img"
Const  $remixparma        = "verbose androidboot.hardware=remix_x86_64 androidboot.selinux=permissive "
Const  $remixparmb        = "DATA= SRC=RemixOS CREATE_DATA_IMG=1"
Const  $parmnvidia        = "nouveau.modeset=1 i915.modeset=0"
Const  $xpstring          = "Windows XP"
Const  $xpsysinfo         = "C:\Program Files\Common Files\Microsoft Shared\MSInfo\msinfo32.exe"
Const  $regkeysysinfo     = "HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\BIOS"
Const  $regkeycpu         = "HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor"
Const  $regkeysecure      = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Secureboot\State"
Const  $downloadurlcode   = "https://sourceforge.net/projects/subproject.grub2win.p/files/GrubInst/download"
Const  $downloadurlquery  = "https://sourceforge.net/projects/subproject.grub2win.p/files/GrubQuery/download"
Const  $downloadurlzip    = "https://sourceforge.net/projects/subproject.grub2win.p/files/GrubZip/download"
Const  $downloadurlvisit  = "https://sourceforge.net/projects/grub2win/"
Const  $trackurl          = "https://sourceforge.net/projects/subproject.grub2win.p/files/GrubVersions"
Const  $downloadexpdays   = 60
Const  $downloadlog       = $windowstemp     & "\grub2win.download.log.txt"
Const  $wgetdiagfile      = $windowstemp     & "\grub2win.wgetdiag.txt"
Const  $wgetpath          = $windowstempgrub & "\WGet\wget.exe"
Const  $zippath           = $windowstempgrub & "\Zip\7za.exe"
Const  $firmwaremode      = BasicGetFirmMode   ()
Const  $firmwaremodelow   = StringLower        ($firmwaremode)
Const  $procbits          = BasicGetBits       ()
Const  $osbits            = BasicGetBits       ("OS")
Const  $bootos            = BasicGetOsVersion  ()
Const  $systemmode        = BasicGetSysMode    ()
Const  $securebootstatus  = BasicGetSecureBoot ()
Const  $sysutilpath       = BasicCapIt         (StringLower (BasicGetUtilPath ()))
Const  $bcdexec           = $sysutilpath     & "\bcdedit.exe"
Const  $efiutilexec       = $sysutilpath     & "\diskpart.exe"
Const  $notepadexec       = $sysutilpath     & "\notepad.exe"
Const  $encryptexec       = $sysutilpath     & "\manage-bde.exe"
Const  $encryptstring     = "\encryption.status.txt"
Const  $syslinepath       = "The utility run path is " & $sysutilpath
Const  $efimasterstring   = "\EFI\Boot\" & BasicGetMasterEFI () & ".efi"
Const  $bootmanefi32      = "gnugrub.kernel32.efi"
Const  $bootmanefi64      = "gnugrub.kernel64.efi"
Const  $bootloaderbios    = "gnugrub.kernel.bios"
Const  $biosbootstring    = $basestring      & "\" & $bootmanstring & "\" & $bootloaderbios
Const  $xpstubsource      = "gnugrub.stub.xp"
Const  $xptargetstub      = "g2xpstub"
Const  $xptargetload      = "g2ldr"
Const  $xptargetini       = "boot.ini"
Const  $xpstubfile        = $windowsdrive & "\" & $xptargetstub
Const  $xploadfile        = $windowsdrive & "\" & $xptargetload
Const  $xpinifile         = $windowsdrive & "\" & $xptargetini
Const  $partreserved      = "** Microsoft Reserved **"
Const  $templateuser      = "\template.user.cfg"
Const  $templatesearch    = "\template.getbootpartition.cfg"
Const  $templateiso       = "\template.isoboot.cfg"
Const  $templatefunctions = "\template.functions.cfg"
Const  $templatesetparms  = "\template.setparms.cfg"
Const  $templatewinauto   = "\template.windowsauto.cfg"
Const  $templatestring    = "\template."
Const  $templatetheme     = "\template.theme.cfg"
Const  $callermain        = "Main"
Const  $setupstring       = "Setup"
Const  $rebootstring      = "Reboot"
Const  $envparmreboot     = "grub2win_reboot="
Const  $startmilsec       = TimerInit ()
Const  $todaydate         = BasicFormatDate    ("", @YEAR & @MON & @MDAY)
Const  $progversion       = BasicFormatVersion (@ScriptFullPath)
Const  $progtimestamp     = FileGetTime        (@ScriptFullPath, $FT_MODIFIED, 1)
Const  $progdate          = BasicFormatDate    ("", StringLeft ($progtimestamp, 8), StringRight ($progtimestamp, 6))
Const  $progage           = StringLeft         ($todaydate, 7) - StringLeft  ($progdate, 7)
Const  $progtimestampdisp = StringLeft ($progtimestamp, 4) & " - " & StringMid ($progtimestamp, 5, 4) & " - " & _
							StringMid  ($progtimestamp, 9, 6) &	"   Age=" & $progage

Const  $selectionfieldcount = 20
Const  $sEntryTitle         =  1, $sOSType      =  2, $sBootBy   =  3, $sDiskAddress =  4, $sPartAddress =  5  ; Array subscripts
Const  $sSearchArg          =  6, $sSortSeq     =  7, $sFamily   =  8, $sBootParm    =  9, $sGraphMode   = 10
Const  $sUpdateFlag         = 11, $sAutoUser    = 12, $sHotKey   = 13, $sReviewPause = 14, $sIcon        = 15
Const  $sCustomFunc         = 16, $sMouseUpDown = 17, $sNvidia   = 18, $sDefaultOS   = 19, $sReboot      = 20

Const  $sCustRecordCount = 0, $sCustDescript = 1, $sCustStamp = 2

Func BasicGetBaseDrive ()
	$gbddrive = StringLeft (@ScriptDir, 2)
	If Not FileExists ($gbddrive & "\" & $basestring) Then $gbddrive = "C:"
	Return $gbddrive
EndFunc

Func BasicGetFirmMode ()
	DllCall ("kernel32.dll", "int", "GetFirmwareEnvironmentVariableA", "str", "",   "str", _
	                         "{00000000-0000-0000-0000-000000000000}", "ptr", Null, "dword", 0)
	$gfmmarray = DllCall    ("kernel32.dll", "dword", "GetLastError")
	If $gfmmarray [0] = 1 Then Return "BIOS"
	Return "EFI"
EndFunc

Func BasicGetBits ($gbtype = "")
	If @OSArch  = "X64" Then Return 64
	If @CPUArch = "X64" And $gbtype = "" Then Return 64
	Return 32
EndFunc

Func BasicGetOsVersion ()
	Local $govos
	Select
		Case @OSVersion = "WIN_2016"
			$govos = "Windows 2016 Server"
		Case @OSVersion = "WIN_2012" Or @OSVersion = "WIN_2012R2"
			$govos = "Windows 2012 Server"
		Case @OSVersion = "WIN_10"
			$govos = "Windows 10"
		Case @OSVersion = "WIN_81"
			$govos = "Windows 8.1"
		Case @OSVersion = "WIN_8"
			$govos = "Windows 8"
		Case @OSVersion = "WIN_7"
			$govos = "Windows 7"
		Case @OSVersion = "WIN_2008" Or @OSVersion = "WIN_2008R2"
			$govos = "Windows 2008 Server"
		Case @OSVersion = "WIN_VISTA"
			$govos = "Windows Vista"
		Case @OSVersion = "WIN_2003"
			$govos = "Windows 2003 Server"
		Case @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2003"
			$govos = $xpstring
	EndSelect
	Return $govos
EndFunc

Func BasicGetSysMode ()
	If $bootos = $xpstring Then Return "BIOS XP"
	Return $firmwaremode
EndFunc

Func BasicGetMasterEFI ()
	If $procbits = 64 Then Return "bootx64"
	Return "bootia32"
EndFunc

Func BasicGetSecureBoot ()
	If $firmwaremode = "EFI" And RegRead ($regkeysecure, "UEFISecureBootEnabled") = 1 Then Return "Enabled"
	Return "Not Enabled"
EndFunc

Func BasicGetUtilPath () ; Required for mixed 32/64 bit execution of utilities
	If StringInStr (@SystemDir, "SysWOW64") Then Return @WindowsDir & "\Sysnative"
	Return          @SystemDir
EndFunc

Func BasicFormatVersion ($fvfile)
	$fvver  = FileGetVersion ($fvfile)
	; Compat 6/29/17  Remove 12/31/2018
	If StringLeft ($fvver, 1) > 3 Then $fvver = "0." & StringLeft ($fvver, 6)
	Return $fvver
EndFunc

Func BasicFormatDate ($fdjul = "", $fddate = "", $fdtime = @HOUR & @MIN & @SEC)
	$fddate  = StringReplace ($fddate, "/", "")
	$fdyear  = StringLeft ($fddate, 4)
	$fdmonth = StringMid  ($fddate, 5, 2)
	$fdday   = StringMid  ($fddate, 7, 2)
	$fdhour  = StringLeft ($fdtime, 2)
	$fdmin   = Stringmid  ($fdtime, 3, 2)
	$fdsec   = Stringmid  ($fdtime, 5, 2)
	If $fdjul  = "" Then $fdjul = Int (_DateToDayValue _
		(StringLeft ($fddate, 4), StringMid ($fddate, 5, 2), StringMid ($fddate, 7, 2))) + 1
	If $fddate = "" Then _DayValueToDate (Number (StringLeft ($fdjul, 7)), $fdyear, $fdmonth, $fdday)
	$fddate = $fdyear & "/" & $fdmonth & "/" & $fdday
	$fdtime = $fdhour & ":" & $fdmin   & ":" & $fdsec
	Return Int ($fdjul) & " - " & $fddate & " - " & BasicTimeLine ($fdjul, $fdtime)
EndFunc

Func BasicTimeLine ($tljuldate = Int (_DateToDayValue (@YEAR, @MON, @MDAY)) + 1, $tltime =  @HOUR & ":" & @MIN & ":" & @SEC)
	Local $tlyear, $tlmonth, $tlday
	_DayValueToDate (Int ($tljuldate), $tlyear, $tlmonth, $tlday)
	$tllocaleday       = _DateToDayOfWeek ($tlyear, $tlmonth, $tlday) - 2
	If $tllocaleday    = -1 Then $tllocaleday = 6
	$tldayname         = _WinAPI_GetLocaleInfo ($LOCALE_USER_DEFAULT, Dec (Hex ($LOCALE_SDAYNAME1))   + $tllocaleday)
	$tlmonthname       = _WinAPI_GetLocaleInfo ($LOCALE_USER_DEFAULT, Dec (Hex ($LOCALE_SMONTHNAME1)) - 1 + $tlmonth)
	$tlstring          = $tlday & " " & BasicCapIt ($tlmonthname) & " " & $tlyear
	$tsdateformat      = _WinAPI_GetLocaleInfo ($LOCALE_USER_DEFAULT, $LOCALE_SSHORTDATE)
	If $tsdateformat   = "M/d/yyyy" Or $tsdateformat = "" Then _
		$tlstring = " " & BasicCapIt ($tlmonthname) & " "  & $tlday & ", " & $tlyear
	Return  $tltime & "  on  " & BasicCapIt ($tldayname)   & "  " & $tlstring
EndFunc

Func BasicCapIt ($cifield)
	Return StringUpper(StringLeft($cifield, 1)) & StringTrimLeft($cifield, 1)
EndFunc