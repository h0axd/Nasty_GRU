#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include-once
#include <g2xp.au3>
#include <g2guiefi.au3>
#include <g2common.au3>
#include <g2theme.au3>
#include <g2update.au3>
#include <g2language.au3>

If $setupcaller = "" Then
	CommonPrepareAll     ()
	LangSetup            ()
	SetupCheckExpiration ()
	If  CommonParms ($actionsilent) Then
		SetupSilent ()
	Else
		SetupByGUI  ()
	EndIf
EndIf

;MsgBox ($mbontop, "Path", $setupbasepath)

Func SetupSilent     ()
	Local $ssshortcut
	$ssdrive = $windowsdrive
	If StringLeft ($runparm2, 6) = "Drive="    Then $ssdrive    = StringRight ($runparm2, 2)
	If StringLeft ($runparm3, 9) = "Shortcut=" Then $ssshortcut = StringRight ($runparm3, 3)
	SetupPrepare     ($ssdrive)
	SetupCopyFiles   ($ssdrive, $ssshortcut)
	CommonInitialize ()
	If $firmwaremode = "EFI" Then
		BCDGetBootArray  ("yes")
		EFIPrepare       ("", "")
		$efipartarray    = UtilScanDisks ()
		EFIAssignAll     ()
		EFIUpdateParts   ("Install")
		EFICloseOut      ("Install", "", "")
	Else
		SetupBootBIOS    ()
	EndIf
	CommonAddFileToArray ($logfile, $setuplogarray)
	CommonSetupWriteLog ()
	CommonSetupCloseOut ()
	Exit
EndFunc

Func SetupByGUI ()
	SetupCreateGUI  ()
	SetupRefreshGUI ()
	While 1
		$sgstatus = GUIGetMsg ()
		Select
			Case $sgstatus = "" Or $sgstatus = 0
			Case $sgstatus = $GUI_EVENT_CLOSE Or $sgstatus = $setupbuttoncancel Or $sgstatus = $setupbuttonclose
				If $setupstatus <> "complete" Then CommonSetupWriteLog ("** Setup was cancelled by the user **")
				ExitLoop
			Case $sgstatus = $setuphandledrive
				$setuptargetdrive = GUICtrlRead ($setuphandledrive)
				GUICtrlSetState ($setuphandleefi, $GUI_UNCHECKED)
				SetupRefreshGUI ()
			Case $sgstatus = $setuphandleforce32
				SetupRefreshGUI ()
			Case $sgstatus = $setuphandleshort
			Case $sgstatus = $setuphandleefi
			Case $sgstatus = $setuphandleefiprm And $setupdisableprm = ""
				If CommonCheckBox ($setuphandleefi) Then
					GUICtrlSetState ($setuphandleefi, $GUI_UNCHECKED)
				Else
					GUICtrlSetState ($setuphandleefi, $GUI_CHECKED)
				EndIf
			Case $sgstatus = $setupbuttonhelp
				CommonHelp ($setuphelploc)
				ContinueLoop
			Case $sgstatus = $setupbuttonconfirm
				If $firmwaremode = "EFI" And SetupCheckLevel () <> "Accepted" Then ContinueLoop
				SetupRefreshGUI ("Confirmed")
				SetupPerformGUI ()
				ContinueLoop
			Case $sgstatus = $setupbuttoninstall
				If $firmwaremode = "EFI" And SetupCheckLevel () <> "Accepted" Then ContinueLoop
				SetupPerformGUI ()
				ContinueLoop
			Case Else
		EndSelect
	WEnd
	If $firmwaremode = "EFI" and $securebootstatus = "Enabled" Then
		$sgmsg  = '                          *** Note ***'            & @CR & @CR
		$sgmsg &= '"Secure Boot" is enabled in your EFI Firmware.'    & @CR & @CR
        $sgmsg &= 'It must be disabled for Grub2Win to run properly.' & @CR & @CR
		$sgmsg &= 'Consult your motherboard or PC documentation for further information.'
		MsgBox ($mbwarnok, "", $sgmsg)
	EndIf
	CommonSetupCloseOut ()
	If $setupstatus <> "complete" Then Exit
	$sgdelsetup = CommonCheckBox ($setuphandledel)
	If CommonCheckBox ($setuphandlerun) Then
		GUIDelete ($setuphandlegui)
		MsgBox ($mbinfook, "", "**  Now Starting Grub2Win  **", 1)
		Run    ($baseexe)
	Else
		CommonRunBat ("xxdeldir.txt",   "Grub2Win.DelDir.bat",    "set deldir="   & $windowstempgrub,        @SW_HIDE, "")
	EndIf
	If $setupdownload = "yes" And $sgdelsetup Then _
		CommonRunBat ("xxdelsetup.txt", "Setup.Grub2Win.Del.bat", "set setupdir=" & '"' & @ScriptDir & '\"', @SW_HIDE)
	Exit
EndFunc

Func SetupCreateGUI ()
	If $firmwaremode = "EFI" And $osbits = 32 And $procbits = 64 Then $setupforce32ok = "yes"
	$setuptargetdrive = $windowsdrive
	SetupPrepare       ($setuptargetdrive)
	$setuphandlegui     = GUICreate ("", 498, 550, -1, -1, -1)
	GUISetBkColor       ($mygreen, $setuphandlegui)
	SetupGetDrives      ()
	$setupbuttonhelp    = GUICtrlCreateButton   ("Help",                2,   5,  50,  20)
	GUICtrlSetBkColor  ($setupbuttonhelp, $mymedblue)
	$setuphandleefi     = GUICtrlCreateCheckbox ("",                  135,  80,  16,  20, $BS_LEFT)
	GUICtrlSetState    ($setuphandleefi,   $GUI_UNCHECKED)
	$setuphandleefiprm  = GUICtrlCreateLabel    ("",                  151,  82, 400,  40, $BS_LEFT)
	$ssshortmsg         = "Grub2Win desktop shortcut"
	$setuphandleshort   = GUICtrlCreateCheckbox ($ssshortmsg,         135, 120, 300,  20, $BS_LEFT)
	If FileExists ($shortcutfile) Or Not FileExists ($basepath) Then GUICtrlSetState ($setuphandleshort, $GUI_CHECKED)
	$setupbump = 40
	$ssforcemsg         = "Force Grub2Win to load 32 Bit EFI code"
	$setuphandleforce32 = GUICtrlCreateCheckbox ($ssforcemsg,         135, 160, 300,  20, $BS_LEFT)
	If $setupforce32ok = "" Then
		$setupbump = 0
		GUICtrlSetState ($setuphandleforce32, $guihideit)
	Else
		If $bootmanefi = $bootmanefi32 Then GUICtrlSetState ($setuphandleforce32, $GUI_CHECKED)
	EndIf
	$ssrunmsg           = "Run Grub2Win after setup finishes"
	$setuphandlerun     = GUICtrlCreateCheckbox ($ssrunmsg,           135, 160 + $setupbump, 200,  20, $BS_LEFT)
	GUICtrlSetState    ($setuphandlerun, $GUI_CHECKED)
	$setuphandlewarn    = GUICtrlCreateLabel    ("",                  105, 200 + $setupbump, 300, 180, $SS_Center)
	$setupbuttonconfirm = GUICtrlCreateButton   ("Confirm and Continue Install", 175, 400 + $setupbump, 160, 50, $SS_Center)
	$setupbuttoncancel  = GUICtrlCreateButton   ("Cancel",             50, 510,  50,  20)
	$setupbuttonclose   = GUICtrlCreateButton   ("Close The Setup Program", 170, 510, 150,  20)
	GUICtrlSetState ($setupbuttonclose, $guihideit)
	$setupbuttoninstall = GUICtrlCreateButton   ("Setup",             385, 510,  50,  20)
EndFunc

Func SetupRefreshGUI ($srstatus = "")
	SetupCheckDrive  ($setuptargetdrive)
	If $firmwaremode = "EFI" Then
		$srmode         = $bootmodeefi
		$efiforce32     = ""
		If $setupforce32ok = "yes" Then
			If CommonCheckBox ($setuphandleforce32) Then
				$efiforce32 = "yes"
				$srmode     = 32
			Else
				$efiforce32 = ""
				$srmode     = 64
			EndIf
		EndIf
		If  $efiforce32 = "yes" Or ($bootmanefi = $bootmanefi32 And $procbits = 64) Then
			GUICtrlSetState ($setuphandleefi,    $GUI_CHECKED)
			GUICtrlSetState ($setuphandleefi,    $guishowdis)
			$setupdisableprm  = "yes"
			GUICtrlSetColor   ($setuphandleefiprm,  $mymedgray)
		EndIf
		$efilevelinstalled = CommonGetEFILevel ($setuptargetdir & "\windata\storage")
		$ssefimsg = "Refresh the GNU Grub " & $srmode & " Bit modules in your EFI partitions"
		If $efilevelinstalled <> $latestefilevel Then $ssefimsg &= @CR & "From level " & $efilevelinstalled & " to level " & $latestefilevel
		If $efilevelinstalled = "none" Then $ssefimsg = "Install the GNU Grub " & $srmode & " Bit level " & $latestefilevel & " modules to your EFI partitions"
		If $efilevelinstalled <> $latestefilevel And $srstatus <> "Confirmed" Then GUICtrlSetState ($setuphandleefi, $GUI_CHECKED)
		GUICtrlSetData     ($setuphandleefiprm, $ssefimsg)
	Else
		GUICtrlSetState    ($setuphandleefi,    $guihideit)
		GUICtrlSetState    ($setuphandleefiprm, $guihideit)
	EndIf
	GUICtrlSetData ($setuphandlelabel, CommonGetLabel ($setuptargetdrive))
	;MsgBox ($mbontop, "EFI " & $setuptargetdir & "\windata\storage", $latestefilevel & @CR & $efilevelinstalled)
	SetUpCheckErrors ($srstatus)
	GUISetState      (@SW_SHOWNORMAL, $setuphandlegui)
EndFunc

Func SetupPerformGUI ()
	$setupinstallefi = ""
	$spmakeshortcut  = ""
	If CommonCheckBox ($setuphandleshort)   Then $spmakeshortcut  = "yes"
	If CommonCheckBox ($setuphandleefi)     Then $setupinstallefi = "yes"
	If $setupforce32ok = "yes" Then GUICtrlSetState ($setuphandleforce32, $guishowdis)
	If $firmwaremode   = "EFI" Then	GUICtrlSetState ($setuphandleefi,    $guishowdis)
	$setupdisableprm  = "yes"
	GUICtrlSetColor   ($setuphandleefiprm,  $mymedgray)
	GUICtrlSetColor   ($setuphandleprompt,  $mymedgray)
	GUICtrlSetColor   ($setuphandlelabel,   $mymedgray)
	GUICtrlSetState   ($setuphandleshort,   $guishowdis)
	GUICtrlSetState   ($setuphandledrive,   $guishowdis)
	GUICtrlSetState   ($setuphandlelist,    $guihideit)
	GUICtrlSetState   ($setupbuttoncancel , $guihideit)
	GUICtrlSetState   ($setupbuttonconfirm, $guihideit)
	GUICtrlSetState   ($setupbuttoninstall, $guihideit)
	$setuphandlelist  = GUICtrlCreateList ("", 40, 200 + $setupbump, 425, 280 - $setupbump, $WS_HSCROLL + $WS_VSCROLL)
	SetupCopyFiles    ($setuptargetdrive, $spmakeshortcut)
	GUICtrlSetState   ($setupbuttonclose, $guishowit + $GUI_FOCUS)
EndFunc

Func SetupBootEFI ()
	BCDGetBootArray  ("yes")
	CommonSetHeaders ()
	BCDCleanup       ()
	EFIMain          ("Install", $setuphandlegui, $setupstring)
EndFunc

Func SetupBootBIOS ()
	CommonSetupWriteLog ()
	CommonSetupWriteLog ("Starting the " & $systemmode & " boot code installation.")
	$sbbrc = ""
	If $bootos = $xpstring Then
		XPSetup       ()
		XPGetPrevious ()
		$sbbrc = XPUpdate     (30)
	Else
		BCDGetBootArray    ("yes")
		BCDGetPreviousBIOS ()
		$sbbrc = BCDSetupBIOS (30)
	EndIf
	If $sbbrc <> 0 Then SetupError ("** The BIOS boot code installation failed **", $sbbrc)
    CommonSetupWriteLog ("The " & $systemmode & " boot code installation is complete.")
EndFunc

Func SetupCheckLevel ()
	If $efilevelinstalled = $latestefilevel Or CommonCheckBox ($setuphandleefi) _
	    Or $setuplevelwarned = "yes" Then Return "Accepted"
	$sclmessage  = "                           ***  Warning  ***" & @CR & @CR
    If $efilevelinstalled = 0 Then
		$sclmessage &= "The Grub2Win modules have not yet been installed to your EFI partition" & @CR & @CR
	Else
		$sclmessage &= "The Grub2Win modules in your EFI partition are not current" & @CR & @CR
		$sclmessage &= "Current level = " & $latestefilevel & "       Your level = " & $efilevelinstalled & @CR & @CR
	EndIf
	$sclmessage &= "***  Grub2Win may not boot properly ***" & @CR & @CR
	$sclmessage &= 'Click "Yes" if you really want to skip the EFI module setup' & @CR & @CR
	$sclrc = MsgBox ($mbwarnyesno, "", $sclmessage)
	If $sclrc = $IDNO Then Return "Retry"
	$setuplevelwarned = "yes"
	Return "Accepted"
EndFunc

Func SetupCheckErrors ($scconfstatus)
	$scmsg        = ""
	$sctitle      = "Setup Grub2Win version " & $setupversion
	$setuphelploc = "TheGrub2WinSetupscreen"
	GUICtrlSetState ($setuphandlewarn,    $guihideit)
	GUICtrlSetState ($setupbuttonconfirm, $guihideit)
	GUICtrlSetState ($setupbuttoninstall, $guishowit)
	GUICtrlSetState ($setupbuttoninstall, $GUI_FOCUS)
	Select
		Case UtilCheckEncryption ($setuptargetdrive)
			$scmsg  = @CR & @CR & 'Drive ' & $setuptargetdrive & ' is encrypted with BitLocker.' & @CR & @CR
			$scmsg &= 'Grub2Win cannot be installed to an encrypted partition.'                  & @CR & @CR
			$scmsg &= 'Please click the blue  Help  button above and refer to the'               & @CR
			$scmsg &= '"Encrypted Disk Workaround"  topic for more information.'
			$setuphelploc = "EncryptedDiskWorkaround"
		Case $setupmbrequired > DriveSpaceFree ($setuptargetdrive)
			$scmsg  = @CR & @CR & "There is not enough free space" & @CR & @CR
			$scmsg &= "on drive " & $setuptargetdrive & @CR & @CR & $setupmbrequired & " MB is required."
		Case StringLeft (@ScriptDir, 9) = $setuptargetdir & "\"
			$scmsg  = @CR & @CR & "The setup program cannot be run" & @CR
			$scmsg &= "from the target directory." & @CR & @CR & $setuptargetdir
		Case FileExists ($setuptargetdir)
			$scoldversion = BasicFormatVersion ($setuptargetdir & "\" & $exestring)
			If $setupversion <> "0.0.0.0" Then $sctitle = "Upgrade Grub2Win version " & _
				$scoldversion & " to " & $setupversion
			$scmsgbody  = 'There is already a ' & $setuptargetdir & ' directory'  & @CR
			$scmsgbody &= 'on the drive you selected.'                            & @CR & @CR
			$scmsgbody &= 'Your current directory will be saved as ' & $setupolddir & @CR
			$scmsgbody &= 'Your settings and backup files will be migrated'       & @CR
			$scmsgbody &= 'to the new ' & $setuptargetdir & ' directory.'         & @CR & @CR & @CR
			If $scconfstatus = "Confirmed" Then
				$scmsg =  @CR & '***   Confirmed   ***' & @CR & @CR & $scmsgbody
				$scmsg &= 'The install of Grub2Win will now continue.'            & @CR
				GUICtrlSetState ($setupbuttoninstall, $guihideit)
			Else
				$scmsg =  @CR & '***   Note   ***' & @CR & @CR & $scmsgbody
				$scmsg &= 'Click the "Confirm" button below'                      & @CR
				$scmsg &= 'to continue the install.'
				GUICtrlSetState ($setupbuttonconfirm, $guishowit + $GUI_FOCUS)
			EndIf
	EndSelect
	If $runparmsdisplay <> "" Then $sctitle &= "   P=" & $runparmsdisplay
	If $scmsg    <> "" Then
		GUICtrlSetData    ($setuphandlewarn,    $scmsg)
		GUICtrlSetBKColor ($setuphandlewarn,    $myyellow)
		GUICtrlSetState   ($setuphandlewarn,    $guishowit)
		GUICtrlSetState   ($setupbuttoninstall, $guihideit)
	EndIf
	WinSetTitle ($setuphandlegui, "", $sctitle)
EndFunc

Func SetupPrepare ($spdrive)
	Dim         $setuplogarray [1]
	$setupdownload = "no"
	Select
		Case FileExists (@ScriptDir & "\WinSource\Grub2Win.exe")
			$setupbasepath = (@ScriptDir)
		Case FileExists (@ScriptDir & "\Grub2Win.exe")
			$setupbasepath = StringTrimRight (@ScriptDir, 10)
		Case Else
			$setupdownload = "yes"
			$setupbasepath = $windowstempgrub & "\install"
	EndSelect
	$setuplogfile  = $setupbasepath & $setuplogstring
	If $setupdownload = "yes" Then $setuplogfile = @ScriptDir & $setuplogstring
	FileDelete ($setuplogfile)
	CommonSetupWriteLog  ("Start Setup - " & BasicTimeLine ())
	SetupCheckDrive   ($spdrive)
	$setupversion     = BasicFormatVersion ($setupbasepath & "\winsource\" & $exestring)
	$latestefilevel   = CommonGetEFILevel ($setupbasepath & "\" & $bootmanstring)
	CommonSetupSysLines ($latestefilevel, "The setup ")
	$setupmbrequired  = Int ((DirGetSize ($setupbasepath) / $mega) * 1.1)
EndFunc

Func SetupCheckDrive ($cddrive)
	If DriveStatus    ($cddrive & "\") <> "Ready" Then SetupError ("The Target Drive Is Not Ready " & $cddrive)
	$setuptargetdir   = $cddrive & "\grub2"
	If StringLeft (@ScriptDir, 9) = $setuptargetdir & "\" Then SetupError ("Setup must not overwrite itself." _
	    & @CR & @CR & "Source = " & @scriptdir & @CR & @CR & "Target  = " & $setuptargetdir)
	$setupolddir      = $cddrive & "\grub2.old"
	$setuptempdir     = $cddrive & "\grub2.temp.rename.old"
EndFunc

Func SetupGetDrives ()
	$gdarray       = DriveGetDrive ("ALL")
	$gdstring      = ""
	$gddefault     = ""
	For $gdsub = 1 To Ubound ($gdarray) - 1
		$gddisk = $gdarray [$gdsub]
		$gddisk = BasicCapit ($gddisk)
		$gdtype = DriveGetType ($gddisk & "\")
		If $gdtype <> "Fixed" And $gdtype <> "Removable" Then ContinueLoop
		$gdfs   = DriveGetFileSystem ($gddisk & "\")
		If $gdfs <> "NTFS" And Not StringInStr ($gdfs, "Fat") Then ContinueLoop
		If $gddefault = "" And FileExists ($gddisk & "\" & $basestring) Then $gddefault = $gddisk
		$gdstring &= $gddisk & "|"
	Next
	If $gddefault <> "" Then $setuptargetdrive = $gddefault
	$gdmsg    = "Select the target drive" & @CR & "for the \grub2 directory"
	$setuphandleprompt = GUICtrlCreateLabel ($gdmsg,  130, 30, 160, 40)
	$setuphandledrive  = GUICtrlCreateCombo ("",      300, 36,  55, 40)
	$setuphandlelabel  = GUICtrlCreateLabel ("",      365, 42, 120, 20)
	GUICtrlSetData ($setuphandledrive,  $gdstring, $setuptargetdrive)
	GUICtrlSetFont ($setuphandledrive,  12)
	GUICtrlSetFont ($setuphandleprompt, 11)
EndFunc

Func SetupCopyFiles ($scdrive, $scmakeshortcut = "")
	CommonSetPaths  ($scdrive)
	$setupinprogress = "yes"
	If CommonParms ($actionsilent) Then CommonSetupWriteLog ("This is a Silent install to " & $basepath & "  " & $runparm3)
	CommonSetupWriteLog ()
	CommonSetupWriteLog ($langline1 & ".")
	If $langline2 <> "" Then CommonSetupWriteLog ($langline2 & ".")
	If $langline3 <> "" Then CommonSetupWriteLog ($langline3 & ".")
	If $langline4 <> "" Then CommonSetupWriteLog ($langline4 & ".")
	CommonSetupWriteLog ($syslineos & ".")
	If $syslinesecure   <> "" Then CommonSetupWriteLog ($syslinesecure & ".")
	CommonSetupWriteLog ($syslinepath, 1, "")
	If $runparmsdisplay <> "" Then CommonSetupWriteLog ("** Parms = " & $runparmsdisplay & " **")
	If FileExists ($basepath) Then SetupRenameCurr ()
	CommonSetupWriteLog ()
	DirCreate ($basepath)
	CommonSetupWriteLog  ("OK - The New Main Directory Was Created At " & $basepath & ".")
	If SetupCheckCompress ($basepath) Then CommonSetupWriteLog ("OK - Compression turned off for setup")
	DirCreate ($basepath & "\userfiles")
	DirCreate ($backuppath)
	DirCreate ($storagepath)
	DirCreate ($updatedatapath)
	SetupSubdirCopy ("fonts")
	SetupSubdirCopy ("i386-pc")
	SetupSubdirCopy ("i386-efi")
	SetupSubdirCopy ("x86_64-efi")
	SetupSubdirCopy ("locale")
	SetupSubdirCopy ("themes")
	ThemeStarterSetup ()
	SetupSubdirCopy ("winhelp")
	SetupSubdirCopy ("winsource")
	$sptargetbootmandir = $basepath & "\" & $bootmanstring
	DirCreate ($sptargetbootmandir)
	FileCopy  ($setupbasepath & "\" & $bootmanstring & "\" & $bootloaderbios,   $sptargetbootmandir & "\", 1)
	FileCopy  ($setupbasepath & "\" & $bootmanstring & "\" & $xpstubsource,     $sptargetbootmandir & "\", 1)
	FileCopy  ($setupbasepath & "\" & $bootmanstring & "\gnugrub.diskutil.cfg", $sptargetbootmandir & "\", 1)
	FileCopy  ($setupbasepath & "\" & $bootmanstring & "\gnugrub.efilevel.*",     $sptargetbootmandir & "\", 1)
	FileCopy  ($setupbasepath & "\" & $bootmanstring & "\gnugrub.efirescue.cfg",  $sptargetbootmandir & "\", 1)
	FileCopy  ($setupbasepath & "\" & $bootmanstring & "\gnugrub.kernel32.efi",   $sptargetbootmandir & "\", 1)
	FileCopy  ($setupbasepath & "\" & $bootmanstring & "\gnugrub.efisetup32.cfg", $sptargetbootmandir & "\", 1)
	FileCopy  ($setupbasepath & "\" & $bootmanstring & "\gnugrub.kernel64.efi",   $sptargetbootmandir & "\", 1)
	FileCopy  ($setupbasepath & "\" & $bootmanstring & "\gnugrub.efisetup64.cfg", $sptargetbootmandir & "\", 1)
	FileMove ($basepath & "\winsource\" & $exestring,  $baseexe,                    1)
	FileCopy ($basepath & "\winsource\basic.cfg",      $basepath & "\grub.cfg",     1)
	FileCopy ($basepath & "\winsource\grubenv",        $envfile,                    1)
	If FileExists ($basepath & "\setup.bat") Then FileDelete ($basepath & "\setup.bat")
	If FileExists ($setupolddir) Then SetupCopyPrevConfig ()
	If $bootos <> $xpstring Then UtilCreateSysInfo ()
	UpdateGetParms  ()
	If StringLeft ($progdate, 7) > StringLeft ($updatearray [$sUpLastCheck], 7) Then _
		$updatearray [$sUpLastCheck] = $progdate
	UpdateCalcDates ()
	$spnextremind = BasicFormatDate (StringLeft ($todaydate, 7) + 5)
	If $updatearray [$sUpLastCheckDays] < 26 Then _
		$spnextremind = BasicFormatDate (StringLeft ($progdate, 7) + $updatearray [$sUpToGoDays])
	UpdatePutParms ($spnextremind)
	$spshortmsg = CommonShortcut ($scmakeshortcut)
	CommonSetupWriteLog ()
	CommonSetupWriteLog ("OK - " & $spshortmsg)
	$cpmode = 64
	If $efiforce32 = "yes" Then $cpmode = 32
	CommonPutEFIMode ($cpmode)
	$bootmanefi = CommonGetEFIBootman ()
	If $firmwaremode =  "EFI" And $setupinstallefi = "yes" Then SetupBootEFI ()
	If $firmwaremode <> "EFI"                              Then SetupBootBIOS ()
	BCDCleanup          ("yes")
	CommonSetupWriteLog ()
	CommonSetupWriteLog ()
	CommonSetupWriteLog ("The Grub2Win setup completed successfully!")
	CommonSetupWriteLog ()
	If $setupdownload = "yes" Then
		$cfdelmsg     = "Delete the setup files - No longer needed"
						  GUICtrlSetPos         ($setuphandlerun, 40, 160 + $setupbump, 200, 20)
		$setuphandledel = GUICtrlCreateCheckbox ($cfdelmsg,      250, 160 + $setupbump, 220, 20, $BS_LEFT)
	EndIf
	_GUICtrlListBox_SetTopIndex ($setuphandlelist, _GUICtrlListBox_GetCount ($setuphandlelist) - 15)
	$setupstatus  = "complete"
	;MsgBox ($mbontop, "Setup Complete", $spmsg)
	Return
EndFunc

Func SetupSubdirCopy ($ssddir)
	$ssrcsubdircopy = DirCopy  ($setupbasepath & "\" & $ssddir, $basepath & "\" & $ssddir)
	If $ssrcsubdircopy <> 1 Then _
		SetupError ('Subdir Copy Failed "' & $setupbasepath  & "\" & $ssddir & '" to "' _
		                                   & $basepath       & "\" & $ssddir & '"', $ssrcsubdircopy)
EndFunc

Func SetupRenameCurr ()
	DirRemove     ($setuptempdir, 1)
	If FileExists ($setupolddir) Then SetupMoveCheck ($setupolddir, $setuptempdir, "delete")
	SetupMoveCheck ($basepath, $setupolddir, "rename")
	DirRemove ($setuptempdir, 1)
	If $firmwaremode = "EFI" And $efilevelinstalled <> $latestefilevel Then
		$srcmsg = " is currently at EFI level " & $efilevelinstalled
		If $efilevelinstalled = "none" Then $srcmsg = " - The Grub2Win EFI modules have not yet been installed."
		CommonSetupWriteLog ("Drive " & $setuptargetdrive & $srcmsg)
	EndIf
	CommonSetupWriteLog ()
	CommonSetupWriteLog ('OK - ' & $basepath & ' Was Renamed to ' & $setupolddir & '.')
EndFunc

Func SetupMoveCheck ($mcolddir, $mcnewdir, $mcmsgtype)
	$mcprompt = $MB_RETRYCANCEL
	For $mcretry = 1 To 3
		$mcrc = DirMove ($mcolddir, $mcnewdir)
		If $mcrc = 1 Then Return
		$mcmsg  = "The " & $mcmsgtype & " of " & $mcolddir & " failed." &                      @CR & @CR
		$mcmsg &= "Make sure no files are open in " & $mcolddir & " or it's subdirectories." & @CR & @CR
		$mcmsg &= "Also check for open command line widows."
		If $mcretry = 3 Then
			$mcprompt = $MB_OK
			$mcmsg = "The final attempt to " & $mcmsgtype & " " & $mcolddir & " failed."
        EndIf
		$mcmsgrc = MsgBox ($mbwarnok + $mcprompt, "Rename attempt " & $mcretry & " of 3 failed", $mcmsg)
		If $mcmsgrc <> $IDRETRY Then ExitLoop
	Next
	If $mcmsgtype = "rename" Then DirMove ($setuptempdir, $setupolddir)
	SetupError ('The ' & $mcmsgtype & ' of "' & $mcolddir & '" failed - Setup is cancelled')
EndFunc

Func SetupCopyPrevConfig ()
	$stoldversion = BasicFormatVersion ($setupolddir & "\" & $exestring)
	CommonSetupWriteLog ()
	CommonSetupWriteLog ("** Upgrading version " & $stoldversion & " to version " & $setupversion & " **")
	If FileExists ($setupolddir & "\grub.cfg") Then FileCopy ($setupolddir & "\grub.cfg", $basepath & "\grub.cfg", 1)
	If GetPrevEnvReboot ($setupolddir & "\grubenv") <> "" Then FileCopy ($setupolddir & "\grubenv",  $envfile,     1)
	If FileExists ($setupolddir & "\windata\storage")  Then _
		FileCopy  ($setupolddir & "\windata\storage\*.*",  $storagepath, 1)
	If FileExists ($setupolddir & "\windata\backup")   Then _
	    DirCopy   ($setupolddir & "\windata\backup",       $backuppath, 1)
	If FileExists ($setupolddir & "\windata\updatedata")   Then _
	    DirCopy   ($setupolddir & "\windata\updatedata",   $updatedatapath, 1)
	FileCopy ($setupolddir      & "\themes\icons\*.*",     $themepath & "\icons", 1)
	FileCopy ($setupbasepath    & "\themes\icons\*.*",     $themepath & "\icons", 1)
	Dircopy  ($setupolddir      & "\themes\options.local", $themepath & "\options.local", 1)
	If FileExists ($setupolddir & "\themes\common\colorcustom") Then SetupCustColor ()
	CommonSetupWriteLog  ("OK - Previous Settings And Backups Were Migrated.")
EndFunc

Func SetupCustColor ()
	Local $cctext, $ccclock
	$cchandle = FileOpen ($basepath & "\themes\custom.options.txt")
	$ccdata   = FileRead ($cchandle)
	FileClose ($cchandle)
	$cctextloc  = StringInStr ($ccdata, "coltext   =")
	$ccclockloc = StringInStr ($ccdata, "colclock  =")
	If $cctextloc  > 0 Then $cctext  = StringMid ($ccdata, $cctextloc  + 12, 6)
	If $ccclockloc > 0 Then $ccclock = StringMid ($ccdata, $ccclockloc + 12, 6)
	If $cctext <> "" Then _
		ThemeCopyColor ("coltext",  $cctext,  $themepath & "\common\colorsource", $themepath & "\common\colorcustom")
	If $ccclock <> "" Then _
		ThemeCopyColor ("colclock", $ccclock, $themepath & "\common\colorsource", $themepath & "\common\colorcustom")
EndFunc

Func SetupCheckCompress ($ccdir)
	If Not StringInStr (FileGetAttrib ($ccdir), "C") Then Return 0
	$ccstring = "compact /u /q /s:" & $ccdir
	ShellExecuteWait (@Comspec, " /c " & $ccstring, "", "", @SW_HIDE)  ;UnCompress the directory
	Return 1
EndFunc

Func SetupCheckExpiration ()
	$cescriptdate = FileGetTime (@ScriptFullPath, $FT_MODIFIED, 1)
	$ceyear       = StringLeft  ($cescriptdate, 4)
	$cemonth      = StringMid   ($cescriptdate, 5,  2)
	$ceday        = StringMid   ($cescriptdate, 7,  2)
	$cejul        = Int (_DateToDayValue (@YEAR, @MON, @MDAY)) - Int (_DateToDayValue ($ceyear, $cemonth, $ceday))
	; MsgBox ($mbontop, "Date", @ScriptFullPath & @CR & $cescriptdate & @CR & $cejul)
	If $cejul <= $downloadexpdays Then Return
	$cemsg   = 'This version of the Grub2Win installer is somewhat old.'            & @CR
	$cemsg  &= 'It may not be genuine.'                                             & @CR & @CR & @CR
	$cemsg  &= 'Grub2Win should only be downloaded from the official site'          & @CR
	$cemsg  &= '         https://sourceforge.net/projects/grub2win/'                & @CR & @CR
	$cemsg  &= 'Click "Cancel" to cancel the install, and go to the official site.' & @CR
	$cemsg  &= 'You should then download the latest version.'                       & @CR & @CR
    $cemsg  &= 'Click "OK" to continue the installation despite the warning.'       & @CR & @CR
	$cerc    = MsgBox ($mbwarnokcan, "** Warning - This Grub2Win installer is " & $cejul & " days old **", $cemsg)
	If $cerc = $IDOK Then Return
	Exit
EndFunc

Func SetupError ($semsg, $serc = "")
	$semsg = $semsg & @CR & @CR & "An error has occurred.    "
	If $serc <> "" Then $semsg &= "The return code is " & $serc & @CR & @CR
	$semsg &= "Grub2Win setup is cancelled"
	CommonSetupWriteLog ($semsg)
	MsgBox ($mberrorok, "*** Grub2Win Setup Error ***", $semsg, 120)
	CommonSetupCloseOut ()
	Exit
EndFunc