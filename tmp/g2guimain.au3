#include-once
#include  <g2common.au3>
#include  <g2guiselection.au3>
#include  <g2backrest.au3>
#include  <g2guifirmorder.au3>
#include  <g2guiefi.au3>
#include  <g2syntax.au3>
#include  <g2theme.au3>
#include  <g2language.au3>
#include  <g2update.au3>
#include  <g2xp.au3>

Func MainRunGUI()
	If $langfound = "no" And $langselectedcode = "" Then LangWarn ()
	MainGUISetup()
	MainGUIRefresh()
	Local $mrlastbt
	GUICtrlSetState($buttonok, $GUI_FOCUS)
	GUISetState(@SW_SHOW, $handlemaingui)
	While 1
		$mrgreturn = GUIGetMSG  (1)
		$mrgstatus = $mrgreturn [0]
		$mrghandle = $mrgreturn [1]
		If $mrgstatus < 1 And $mrgstatus <> $GUI_EVENT_CLOSE And $mrgstatus <> $GUI_EVENT_PRIMARYUP And _
		    $mrgstatus <> $GUI_EVENT_PRIMARYDOWN Then ContinueLoop
		Select
			Case $upautohandle <> "" And InetGetInfo ($upautohandle, $INET_DOWNLOADCOMPLETE)
				InetClose ($upautohandle)
				Local $mrgcolor, $mrgmessage
				$mrgnewraw = UpdateGetVersion ($mrgcolor, $mrgmessage)
				If $mrgcolor <> $mygreen Then UpdateRunGUI ($mrgnewraw, $mrgmessage, $mrgcolor)
				$upautohandle = ""
				ContinueLoop
			Case $mrghandle <> $handlemaingui
			Case $mrgstatus = $GUI_EVENT_CLOSE Or $mrgstatus = $buttoncancel
				ThemeRestoreHold ()
				Return 1
			Case $mrgstatus = $GUI_EVENT_PRIMARYUP
				If CommonCheckUpDown ($updowngt, $timeloader, 0, 999) Then
					ThemeMainScreenShot ()
					MainGUIRefresh     ()
				EndIf
			Case $mrgstatus = $buttonok
				BackupMake ()
				Return 0
			Case $mrgstatus = $mainhelphandle
				CommonHelp ("Themainconfigurationscreen")
				ContinueLoop
			Case $mrgstatus = $buttonsysinfo
				MainSysInfo ()
				ContinueLoop
			Case $mrgstatus = $buttondiag
				$mrgrc = MsgBox ($mbquestyesno, "Diagnostics", _
					"Do you want to run the Grub2Win diagnostics?" & @CR & @CR & "This may take up to 60 seconds")
				If $mrgrc <> $IDYES Then ContinueLoop
				$diagcomplete  = ""
				UtilScanDisks  ()
				CommonDiagnose ("OnRequest")
				If $utillogguihandle <> "" Then GUIDelete ($utillogguihandle)
				Return 3
			Case $mrgstatus = $mainresthandle
				BackupChoose ()
				ContinueLoop
			Case $mrgstatus = $mainsynhandle
				SynChoose ()
				ContinueLoop
			Case $mrgstatus = $mainupdhandle
				If $bootos = $xpstring Then
					$mgrxp = MsgBox ($mbinfookcan, _
						"XP Update", "Windows XP users must manually download the latest version." & @CR & @CR & _
						"          Click OK to go to the official download site." & @CR & @CR)
					If $mgrxp = $IDOK Then
						MsgBox ($mbontop, "Closing Grub2Win", @CR & _
							"You will now be directed to the Grub2Win download site." & @CR, 3)
						ShellExecute ($downloadurlvisit)
						CommonEndIt ("XPClose")
					EndIf
				Else
					UpdateRunGUI ()
				EndIf
				ContinueLoop
			Case $mrgstatus = $buttonrunefi
				EFIMain ("Install", $handlemaingui, $callermain)
				MainGUIRefresh ()
			Case $mrgstatus = $buttonsetorder
				FirmOrderRunGUI ("Set EFI Firmware order", $bcdfirmorder, $orderfirmdisplay)
				MainGUIRefresh ()
			Case $mrgstatus = $mainuninsthandle
				MainUninstallIt ()
				MainGUIRefresh ()
			Case $mrgstatus = $buttonselection
				$selectionholdarray      = $selectionarray
				$selectionholdlastbooted = $defaultlastbooted
				$bcdwinmenuhold = $bcdwinorder
				SelectionRunGUI()
				MainGUIRefresh()
			Case $mrgstatus = $buttondrivers
				$selectionholdarray = $selectionarray
				MainDriver()
				MainGUIRefresh()
			Case $mrgstatus = $handlegrubtimeout
				MainRefreshTimeout ()
				ThemeMainScreenShot ()
				MainGUIRefresh     ()
			Case $mrgstatus = $checkshortcut
				MainRefreshShortcut ()
				MainGUIRefresh      ()
			Case $mrgstatus = $screenpreviewhandle Or $mrgstatus = $screenshothandle
				$mrgthemerc = ThemeEdit ()
				If $mrgthemerc = "OK" Then ThemeMainScreenShot ()
				MainGUIRefresh()
			Case $mrgstatus = $langhandle Or $mrgstatus = $checkdrivers
				MainGUIRefresh()
			Case $mrgstatus = $updownbt
				CommonCheckUpDown ($updownbt, $mrlastbt)
				MainGUIRefresh()
			Case $mrgstatus = $graphhandle
				MainGUIRefresh()
			Case $mrgstatus = $defaulthandle
				MainRefreshDefault ()
				ThemeMainScreenShot ()
				MainGUIRefresh  ()
			Case Else
		EndSelect
	WEnd
EndFunc

Func MainGUISetup()
	$handlemaingui = GUICreate ($headermessage & "      L=" & $langheader, $scalehsize, $scalevsize, -1, -1, -1)
	GUISetBkColor  ($mylightgray, $handlemaingui)
	$origgraphset   = $graphset
	$origlangset    = $langfullselector
	If $langauto    = "yes" Then $origlangset = $langautostring
	$origtimeloader = $timeloader
	$origdefault    = $defaultset
	$mgbootstyle    = "BCD"
	If $bootos      = $xpstring Then $mgbootstyle = $xptargetini
	$mainhelphandle = CommonScaleCreate ("Button", "Help",                1,   1.5,  8, 3.5)
	GUICtrlSetBkColor ($mainhelphandle, $mymedblue)
	$mainresthandle = CommonScaleCreate ("Button", "Restore",            11.0, 1.5,  6, 3.5)
	GUICtrlSetBkColor ($mainresthandle, $mymedblue)
	$mainuninsthandle = CommonScaleCreate ("Button", "Uninstall",        18.0, 1.5,  7, 3.5)
	GUICtrlSetBkColor ($mainuninsthandle, $mymedblue)
	$mainsynhandle  = CommonScaleCreate ("Button", "Syntax",             26.0, 1.5,  6, 3.5)
	GUICtrlSetBkColor ($mainsynhandle, $mymedblue)
	$mainupdhandle  = CommonScaleCreate ("Button", "Updates",            33.7, 1.5,  7, 3.5)
	GUICtrlSetBkColor ($mainupdhandle, $mymedblue)
	$mgbiosbump     = 14
	If $firmwaremode = "EFI" Then
		$buttonrunefi   = CommonScaleCreate ("Button",  "Manage EFI Partition Modules",   9, 36.5, 21, 4)
	    $buttonsetorder = CommonScaleCreate ("Button",  "Set EFI Firmware Boot Order",    9, 45.5, 22, 4)
		$mgbiosbump = 0
	EndIf
	$mainloghandle  = CommonScaleCreate  ("List", "",                      2,    7 + $mgbiosbump, 41,  29, 0x00200000)
                      GUICtrlSetBKColor  ($mainloghandle, $mylightgray)
					  GUICtrlSetFont     ($mainloghandle, 9)
	$checkdrivers    = CommonScaleCreate ("Checkbox", "Additional Drivers (advanced)", 4,   69.3, 22, 3)
	$buttondrivers   = CommonScaleCreate ("Button",   "Choose",                       27,   68.8,  7, 3.5)
	ThemeMainScreenShot ()
	$promptd = CommonScaleCreate("Label", "Grub default OS", 44, 62.7, 20, 3)
	CommonSetupDefault (58, 62.3, 39, 15)
	$promptg = CommonScaleCreate("Label", "Grub graphics mode", 44, 70.3, 20, 3)
	$graphhandle = CommonScaleCreate("Combo", "", 58, 70, 39, 15, -1)
	GUICtrlSetData ($graphhandle, $graphautostring, $graphset)
	$promptl = CommonScaleCreate("Label", "Grub locale language", 44, 76.7, 20, 3)
	$langhandle = CommonScaleCreate ("Combo", "", 58, 76.3, 39, 15, -1)
	GUICtrlSetData ($langhandle, $langcombo, $origlangset)
	$checkshortcut     = CommonScaleCreate ("Checkbox", "Desktop Shortcut",      4, 77.2, 15,   3)
	If FileExists ($shortcutfile) Then GUICtrlSetState ($checkshortcut, $GUI_CHECKED)
	$handlegrubtimeout = CommonScaleCreate ("Checkbox", "Enable Grub timeout",   4, 85.5, 15,   3)
	$updowngt = CommonScaleCreate("Input", $timeloader,                       19.5, 86,    4.5, 3, $ES_RIGHT)
	$labelgt1 = CommonScaleCreate("Label", "seconds",                         24.5, 86,    8,   3)
	$buttonsysinfo = CommonScaleCreate("Button",   "System Info",             40,   86,   10,  3.5)
	GUICtrlSetBkColor ($buttonsysinfo, $mymedblue)
	$buttondiag    = CommonScaleCreate("Button",   "Diagnostics",             54,   86,   10,  3.5)
	GUICtrlSetBkColor ($buttondiag,    $mymedblue)
	$labelbt1 = CommonScaleCreate("Label", "Windows boot timeout", 70, 86,  14, 3)
	$updownbt = CommonScaleCreate("Input", $timewinboot,           84, 86, 4.5, 3, $ES_RIGHT)
	$labelbt2 = CommonScaleCreate("Label", "seconds",              89, 86,  30, 3)
	$arrowbt  = GUICtrlCreateUpdown ($updownbt, $UDS_ALIGNLEFT)
	$buttoncancel    = CommonScaleCreate("Button", "Cancel", 11, 95, 10, 3.5)
	$buttonselection = CommonScaleCreate("Button", "Manage Boot Menu", 43, 95, 18, 3.5)
	GUICtrlSetBkColor($buttonselection, $myyellow)
	$buttonok = CommonScaleCreate("Button", "OK", 77, 95, 10, 3.5)
EndFunc

Func MainGUIRefresh()
	CommonDisplayLog ()
	MainRefreshCheckDrv ()
	CommonCheckUpDown   ($updowngt, $timeloader, 0, 999)
	CommonCheckUpDown   ($updownbt, $timewinboot)
	$timeoutok    = ""
	$grlanghold   = ""
	If $timewinboot = 0 Then                           $timeoutok = "Windows boot"
	If $timeloader  < 2 And $timerenabled = "yes" Then $timeoutok = "Grub"
	MainRefreshLanguage()
	$efilevelinstalled = CommonGetEFILevel ($storagepath, "yes")
    MainRefreshDefault ()
	$graphset = GUICtrlRead($graphhandle)
	MainCheckErrors()
	$grdispwin  = $guishowit
	$grdispgrub = $guishowit
	GUICtrlSetState($promptd, $grdispgrub)
	GUICtrlSetState($defaulthandle, $grdispgrub)
	GUICtrlSetState($promptbt, $grdispgrub)
	GUICtrlSetState($promptg, $grdispgrub)
	GUICtrlSetState($graphhandle, $grdispgrub)
	GUICtrlSetState($promptl, $grdispgrub)
	$grlanghold = $grdispgrub
	GUICtrlSetState($checkdrivers, $grdispgrub)
	If CommonCheckBox ($checkdrivers) And $grdispgrub = $guishowit Then
		GUICtrlSetState($buttondrivers, $grdispgrub)
	Else
		GUICtrlSetState($buttondrivers, $guihideit)
	EndIf
	If $timerenabled = "yes" Then
		GUICtrlSetState ($handlegrubtimeout, $GUI_CHECKED)
	Else
		GUICtrlSetState ($handlegrubtimeout, $GUI_UNCHECKED)
	EndIf
	MainRefreshTimeout ()
	GUICtrlSetState($promptt,  $grdispwin)
	GUICtrlSetState($updownbt, $grdispwin)
	GUICtrlSetState($arrowbt,  $grdispwin)
	GUICtrlSetState($labelbt1, $grdispwin)
	GUICtrlSetState($labelbt2, $grdispwin)
	If CommonThemeGetOption ("name") = $notheme Then
		GUICtrlSetState($promptg, $GUI_HIDE + $GUI_ENABLE)
		GUICtrlSetState($graphhandle, $GUI_HIDE + $GUI_ENABLE)
		$graphset = "None"
	EndIf
	GUISetState (@SW_SHOW, $handlemaingui)
EndFunc

Func MainRefreshLanguage ()
	$rllang = GUICtrlRead ($langhandle)
	$langauto  = ""
	If $rllang = $langautostring Then
		$langauto         = "yes"
        $langselectedcode = $langcode
		$langfullselector = $langautostring
		Return
	EndIf
	$rlsub = _ArraySearch ($langcomboarray, $rllang)
	If $rlsub < 0 Then
		$langselectedcode = $langdefcode
	Else
		$langselectedcode = $langcomboarray [$rlsub] [1]
	EndIf
	$langfullselector  = LangGetFullSelector ($langselectedcode)
EndFunc

Func MainRefreshTimeout ()
	If CommonCheckBox ($handlegrubtimeout) Then
		GUICtrlSetState ($updowngt, $guishowit)
		If $arrowgt <> "" Then GUICtrlDelete ($arrowgt)
		$arrowgt = GUICtrlCreateUpdown ($updowngt, $UDS_ALIGNLEFT)
		GUICtrlSetState ($arrowgt,  $guishowit)
		GUICtrlSetState ($labelgt1, $guishowit)
		$timerenabled = "yes"
	Else
		GUICtrlSetState ($updowngt, $guihideit)
		GUICtrlSetState ($arrowgt,  $guihideit)
		GUICtrlSetState ($labelgt1, $guihideit)
		$timerenabled = "no"
	EndIf
EndFunc

Func MainRefreshDefault ()
	$defaultselect = GUICtrlRead ($defaulthandle)
	$defaultos = StringSplit ($defaultselect, " ")
	$defaultos = $defaultos [1]
	If $defaultos = "" Then $defaultos = 0
	$defaultlastbooted = "no"
	If $defaultselect  = $lastbooted Then $defaultlastbooted = "yes"
	CommonDefaultSync ()
EndFunc

Func MainRefreshShortcut ()
	$rsmakeshortcut = ""
	If CommonCheckBox ($checkshortcut) Then $rsmakeshortcut = "yes"
	$rsmsg          = CommonShortcut  ($rsmakeshortcut)
	CommonWriteLog  ("    " & $rsmsg)
EndFunc

Func MainRefreshCheckDrv()
	If $driversprevious = "yes" Then GUICtrlSetState ($checkdrivers, $GUI_CHECKED)
	$driversprevious = "no"
	If GUICtrlRead ($checkdrivers) = $GUI_UNCHECKED Then CommonDriversClearUse ()
EndFunc

Func MainCheckErrors()
	GUICtrlDelete($warnhandle)
	GUICtrlSetState($buttonok, $guishowit)
	GUICtrlSetState($buttonselection, $guishowit)
	GUICtrlSetBkColor($buttonrunefi, $mymedblue)
	GUICtrlSetBkColor($buttonsetorder, $mymedblue)
	Select
		Case $firmwaremode = "EFI" And $securebootstatus = "Enabled"
			$cewarn =  'Error - "Secure Boot" is enabled' & @CR
			$cewarn &= 'in your EFI firmware settings' & @CR
			$cewarn &= 'Grub2Win will not boot properly' & @CR
			GUICtrlSetState($buttonrunefi, $guishowdis)
			$cecolor = $myred
		Case $firmwaremode = "EFI" And ($efilevelinstalled <> $latestefilevel Or $efilevelinstalled = "none")
			$cewarn =  'The GNU Grub EFI modules are not current' & @CR
			If $efilevelinstalled = "none" Then $cewarn =  'The GNU Grub EFI modules are not installed' & @CR
			$cewarn &= 'Please click "Manage EFI Partition Modules" above' & @CR
			$celevelinstalled = $efilevelinstalled
			If $celevelinstalled < 1 Then $celevelinstalled = "none"
			$cewarn &= 'New level = ' & $latestefilevel & "   Installed level = " & $celevelinstalled
			GUICtrlSetBkColor ($buttonrunefi, $myyellow)
			$cecolor = $myred
		Case $firmwaremode = "EFI" And $efierrorsfound = "yes"
			$cewarn =  'No EFI partitions were found' & @CR
			$cewarn &= 'Grub2Win cannot continue'     & @CR
			$cecolor = $myred
		Case CommonCheckBox ($checkdrivers) And Not CommonDriversInUse ()
			$cewarn =  'No additional drivers were selected.'     & @CR
			$cewarn &= 'If you wish to select additional drivers' & @CR
			$cewarn &= 'click "Choose" below' & @CR
			$cecolor = $myred
		Case $timeoutok <> ""
			$cewarn =  @CR & 'Caution - Setting the ' & $timeoutok & ' timeout too low' & @CR
			$cewarn &=       'may prevent menus from displaying' & @CR
			$cecolor = $myyellow
		Case $firmwaremode = "EFI" And $bcdfirmorder [0] [0] = $firmgrub
			$cewarn  = @CR & 'Grub2Win is correctly set as the' & @CR
			$cewarn &=       'default EFI boot manager' & @CR
			$cecolor = $mygreen
		Case $firmwaremode = "EFI" And $bcdtestboot = "yes"
			$cewarn  = @CR & 'Note - A one-time test of Grub2Win' & @CR
			$cewarn &=       'will happen when you boot your PC'  & @CR
			$cecolor = $myorange
		Case $firmwaremode = "EFI"
			$cewarn =  'Caution - Your EFI firmware slot 1' & @CR
			$cewarn &= 'is not set to boot Grub2Win'        & @CR
			$cewarn &= 'Please click "Set EFI Firmware Boot Order" above' & @CR
			GUICtrlSetBkColor ($buttonsetorder, $myyellow)
			$cecolor = $myyellow
		Case Else
			Return
	EndSelect
	$warnhandle = CommonScaleCreate("Label", $cewarn, 3, 54, 36, 9, $SS_CENTER)
	GUICtrlSetBkColor($warnhandle, $cecolor)
	If $cecolor = $myred Then
		GUICtrlSetState($buttonok, $guishowdis)
		GUICtrlSetState($buttonselection, $guishowdis)
	EndIf
EndFunc

Func MainDriver()
	MainDriverSetup()
	MainDriverRefresh()
	While 1
		$dmstatusarray = GUIGetMsg(1)
		If $dmstatusarray[1] <> $driverhandlegui Then ContinueLoop
		$dmgetmsg = $dmstatusarray[0]
		Select
			Case $dmgetmsg = "" Or $dmgetmsg = 0
			Case $dmgetmsg = $GUI_EVENT_CLOSE Or $dmgetmsg = $driverbuttoncancel
				ExitLoop
			Case $dmgetmsg = $driverhelphandle
				CommonHelp ("choosingadditionaldrivers")
				ContinueLoop
			Case $dmgetmsg = $drivercheckata Or $dmgetmsg = $drivercheckraid  Or $dmgetmsg = $drivercheckusb Or _
				$dmgetmsg  = $driverchecklv  Or	$dmgetmsg = $drivercheckcrypt Or $dmgetmsg = $driverchecksleep
				MainDriverRefresh ()
			Case $dmgetmsg = $driverbuttonapply
				If Not CommonDriversInUse () Then	GUICtrlSetState ($checkdrivers, $GUI_UNCHECKED)
				ExitLoop
			Case Else
		EndSelect
	WEnd
	If $driverhandlegui <> "" Then GUIDelete($driverhandlegui)
EndFunc

Func MainDriverSetup ()
	If $driverhandlegui <> "" Then GUIDelete($driverhandlegui)
	$driverhandlegui = GUICreate("Choose Additional Drivers ", $scalehsize, $scalevsize * 0.8, -1, -1, -1, "", $handlemaingui)
	GUISwitch ($driverhandlegui)
	$driverhelphandle = CommonScaleCreate("Button", "Help", 45, 2, 8, 3.5)
	GUICtrlSetBkColor ($driverhelphandle, $mymedblue)
	$dsmessage  = "Note: Most modern motherboards do not require additional Grub drivers" & @CR
	$dsmessage &= "These drivers should be used only if they are required for your specific hardware" & @CR
	$dsmessage &= "They may cause lockups or other conflicts that prevent your system from booting properly"
	$dswarn = CommonScaleCreate("Label", $dsmessage, 5, 8, 90, 11,  $SS_CENTER)
	GUICtrlSetColor ($dswarn, $myyellow)
	GUICtrlSetFont  ($dswarn, $scalefontsize * 1.5)
	$drivercheckata   = CommonScaleCreate("Checkbox", "  ATA  controller support", 38, 21, 40, 3)
	$drivercheckraid  = CommonScaleCreate("Checkbox", "  RAID controller support", 38, 30, 40, 3)
	$drivercheckusb   = CommonScaleCreate("Checkbox", "  USB  disk support",       38, 39, 40, 3)
	$driverchecklv    = CommonScaleCreate("Checkbox", "  Logical Volume  support", 38, 48, 40, 3)
	$drivercheckcrypt = CommonScaleCreate("Checkbox", "  Encrypted disk  support", 38, 57, 40, 3)
	$driverchecksleep = CommonScaleCreate("Checkbox", "  Include 30 second sleep (diagnostic)", 38, 66, 40, 3)
	If $driveruseata   = "yes" Then GUICtrlSetState($drivercheckata,   $GUI_CHECKED)
	If $driveruseraid  = "yes" Then GUICtrlSetState($drivercheckraid,  $GUI_CHECKED)
	If $driveruseusb   = "yes" Then GUICtrlSetState($drivercheckusb,   $GUI_CHECKED)
	If $driveruselv    = "yes" Then GUICtrlSetState($driverchecklv,    $GUI_CHECKED)
	If $driverusecrypt = "yes" Then GUICtrlSetState($drivercheckcrypt, $GUI_CHECKED)
	If $driverusesleep = "yes" Then GUICtrlSetState($driverchecksleep, $GUI_CHECKED)
	$driverbuttoncancel = CommonScaleCreate("Button", "Cancel", 10, 73, 10, 3.5)
	$driverbuttonapply  = CommonScaleCreate("Button", "Apply",  82, 73, 10, 3.5)
EndFunc

Func MainDriverRefresh()
	CommonDriversClearUse ()
	If CommonCheckBox ($drivercheckata)   Then $driveruseata   = "yes"
	If CommonCheckBox ($drivercheckraid)  Then $driveruseraid  = "yes"
	If CommonCheckBox ($drivercheckusb)   Then $driveruseusb   = "yes"
	If CommonCheckBox ($driverchecklv)    Then $driveruselv    = "yes"
	If CommonCheckBox ($drivercheckcrypt) Then $driverusecrypt = "yes"
	If CommonDriversInUse () Then
		GUICtrlSetState ($driverchecksleep, $guishowit)
	Else
		GUICtrlSetState ($driverchecksleep, $guihideit + $GUI_UNCHECKED)
	EndIf
	If CommonCheckBox ($driverchecksleep) Then $driverusesleep = "yes"
	GUICtrlSetState($driverbuttonapply, $GUI_FOCUS)
	GUISetBkColor($mypurple, $driverhandlegui)
	GUISetState(@SW_SHOW, $driverhandlegui)
EndFunc

Func MainUninstallIt ()
	Local $uninstmsg
	If $handlemaingui <> "" Then WinSetState ($handlemaingui, "", @SW_MINIMIZE)
	If $firmwaremode = "EFI" And $efilevelinstalled <> "none" Then
		$msgrc = MsgBox ($mbwarnokcan, "GNU Grub EFI Deletion", "Please confirm deletion of the GNU Grub EFI modules")
		If $msgrc <> $IDOK Then
			MsgBox ($mbinfook, "Grub2Win Uninstall", "Grub2Win EFI module deletion was cancelled", 5)
			If $handlemaingui <> "" Then WinSetState ($handlemaingui, "", @SW_RESTORE)
			Return
		Else
			EFIMain ($actionuninstall, $handlemaingui, $callermain)
			If $utillogguihandle <> "" Then GUIDelete ($utillogguihandle)
			$uninstmsg  = "The GNU Grub modules have been deleted from all EFI partitions" & @CR & @CR
		EndIf
	EndIf
	$uninstmsg &= "Are you sure you want to completely remove Grub2Win from your system?"
	$msgrc = MsgBox ($mbquestyesno, "Grub2Win Uninstall", $uninstmsg)
	If $msgrc <> $IDYES Then
		MsgBox ($mbontop + $MB_ICONINFORMATION, "Grub2Win Uninstall", "The Uninstall Was Cancelled By The User", 5)
		If $handlemaingui <> "" Then WinSetState ($handlemaingui, "", @SW_RESTORE)
		Return
	EndIf
	If $handlemaingui <> "" Then GUIDelete ($handlemaingui)
	MsgBox    ($mbinfook, "", "Now completely uninstalling Grub2Win", 2)
	If $firmwaremode = "BIOS" And $bootos <> $xpstring Then BCDCleanup ()
	If $bootos       = $xpstring Then
		XPIniCleanup ("uninstall")
		CommonArrayWrite ($xpinifile, $xpiniarray)
		FileDelete       ($xpstubfile)
		FileDelete       ($xploadfile)
	EndIf
	If FileExists ($shortcutfile) Then FileDelete ($shortcutfile)
	FileClose ($handlelog)
	CommonRunBat ("xxuninstall.txt", "Grub2win.UnInst.bat")
EndFunc

Func MainSysInfo ()
	$msrc = $IDYES
	If $sysinfomessage <> "" Then
		UtilCreateSysInfo ()
		$msrc = MsgBox ($mbquestyesnocan, _
			"", "                        ***  System Information  ***  " & @CR & $sysinfomessage & _
			@CR & @CR & @CR & @CR & "****    Do you want to run the Disk Report?    ****")
	Else
		Run  ('"' & $xpsysinfo & '"')
		If @error Then MsgBox ($mberrorok, _
			"** Error **", "The MSInfo32.exe program is missing from this system")
		WinWaitActive ("System Information", "", 2)
		WinWaitClose  ("System Information", "")
		$msrc = MsgBox ($mbquestyesno, "", "** Do you also want to run the Disk Report? **")
	EndIf
	If $msrc = $IDYES Then
		UtilScanDisks   ("", $handlemaingui, "Main")
		CommonNotepad   ($diskreportpath)
		GUICtrlSetState ($utillogreturnhandle, $guishowit + $GUI_FOCUS)
		UtilDiskGUIWait ($handlemaingui, "Main")
	EndIf
EndFunc