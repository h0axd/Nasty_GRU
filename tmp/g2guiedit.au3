#include-once
#include  <g2common.au3>
#include  <g2custom.au3>
#include  <g2genconfig.au3>
#include  <g2guiicon.au3>

Func EditRunGUI($emsub)
	EditSetup($emsub)
	Local $emlastdrva, $emlastprta, $emlastdrvc, $emlastprtc, $emlastentry, $emlastpause
	$emwinorderhold = $bcdwinorder
	EditRefresh($emsub)
	While 1
		$emstatusarray = GUIGetMsg (1)
		If $emstatusarray [1] <> $edithandlegui Then ContinueLoop
		$emstatus = $emstatusarray[0]
		If $emstatus < 1 And $emstatus <> $GUI_EVENT_CLOSE And $emstatus <> $GUI_EVENT_PRIMARYUP And _
		    $emstatus <> $GUI_EVENT_PRIMARYDOWN Then ContinueLoop
		Select
			Case $emstatus = $GUI_EVENT_CLOSE Or $emstatus = $editbuttoncancel
				$selectionarray = $editholdarray
				$custparsearray = $custparseholdarray
				$bcdwinorder    = $emwinorderhold
				$editnewentry   = 0
				ExitLoop
			Case $emstatus = $GUI_EVENT_PRIMARYUP
				$focushandle = EditCheckFocus ()
				Select
					Case $focushandle = $editpictureicon Or $focushandle = $editprompticon
						EditRefresh($emsub)
						If $editerrorok = "yes" Then
							IconRunGUI ($emsub)
							EditIcon   ($emsub)
						EndIf
					Case $focushandle <> 0
					Case CommonCheckUpDown ($edithandleentry, $emlastentry, 0, $selectionautohigh)
						$editnewentry = $emlastentry
					Case CommonCheckUpDown ($edithandledrva, $emlastdrva)
						EditRefresh ($emsub)
					Case CommonCheckUpDown ($edithandleprta, $emlastprta, 1)
						EditRefresh ($emsub)
					Case CommonCheckUpDown ($edithandledrvc, $emlastdrvc)
						EditRefresh ($emsub)
					Case CommonCheckUpDown ($edithandleprtc, $emlastprtc, 1)
						EditRefresh ($emsub)
					Case CommonCheckUpDown ($edithandlepause, $emlastpause)
						EditPause ($emsub)
				EndSelect
			Case $emstatus = $editpromptcust Or $emstatus = $editlistcustedit
				CustomEditData ($emsub)
				EditRefresh ($emsub)
			Case $emstatus = $editpromptsample
				EditLoadSample ($emsub)
				EditRefresh ($emsub)
			Case $emstatus = $edithelphandle
				If $selectionarray[$emsub][$sAutoUser] = "Custom" Then
					CommonHelp ("enteringcustomcode")
				Else
					CommonHelp ("editingosdetails")
				EndIf
				ContinueLoop
			Case $emstatus = $editbuttonok Or $emstatus = $editbuttonapply
				If $editnewentry <> $editholdentry Then $selectionarray [$editholdentry][$sSortSeq] = ($editnewentry * 100) + 10
				$selectionarray[$emsub][$sUpdateFlag] = "updated"
				EditRefresh($emsub)
				If $emstatus = $editbuttonok And $editerrorok = "yes" Then ExitLoop
			Case $emstatus = $edithandletitle
				EditTitle($emsub)
			Case $emstatus = $edithandletype
				EditRefresh($emsub)
			Case $emstatus = $edithandleradio1 And CommonCheckBox ($edithandleradio1)
				EditRadioButton  ($emsub, 1)
			Case $emstatus = $edithandleradio2 And CommonCheckBox ($edithandleradio2)
				EditRadioButton  ($emsub, 2)
			Case $emstatus = $edithandleradio3 And CommonCheckBox ($edithandleradio3)
				EditRadioButton  ($emsub, 3)
			Case $emstatus = $edithandleradio4 And CommonCheckBox ($edithandleradio4)
				EditRadioButton  ($emsub, 4)
			Case $emstatus = $editpromptauto
				CustomClearCode  ($emsub)
				$selectionarray  [$emsub] [$sAutoUser] = "Auto"
				EditRefreshRadio ($emsub, $selectionarray[$emsub][$sBootBy], "Auto")
				EditRefresh ($emsub)
			Case $emstatus = $edithandlechkc
				EditChainCheck ($emsub)
			Case $emstatus = $edithandlechknv
				EditAndroidParm ($emsub)
			Case $emstatus = $edithandleseland
				EditAndroidSelect ($emsub)
			Case $emstatus = $edithandleseliso
				EditISOSelect ($emsub)
			Case $emstatus = $edithandleparm
				EditParm($emsub)
			Case $emstatus = $editbuttonstand
				$emdefault = CommonParmCalc ($emsub, "Standard")
				GuiCtrlSetData ($edithandleparm, $emdefault)
				EditParm($emsub)
				If $selectionarray [$emsub] [$sFamily] = "linux-andremix" Then
					CommonAndroidArray ($emsub, $emdefault)
					EditAndroidGUI ($emsub)
				EndIf
				GUICtrlSetState ($editbuttonstand, $guihideit)
				GUICtrlSetState ($editmessageparm, $guishowit)
			Case $emstatus = $edithandlegraph
				EditGraph ($emsub)
			Case $emstatus = $edithandlehotkey
				EditHotkey ($emsub)
			Case Else
		EndSelect
		If $selectionarray [$emsub] [$sOSType] = "windows" And $firmwaremode = "EFI" Then EditCheckWinOrder ($emstatus, $emsub)
	WEnd
	If $edithandlegui <> "" Then GUIDelete($edithandlegui)
	GUICtrlSetState ($buttonselectionadd,  $guishowit)
	GUICtrlSetState ($selectionhelphandle, $guishowit)
EndFunc

Func EditSetup($essub)
	;_ArrayDisplay ($selectionarray)
	GUICtrlSetState ($buttonselectionadd,  $guihideit)
	GUICtrlSetState ($selectionhelphandle, $guihideit)
	$editholdentry    = $essub
	$editnewentry     = $essub
	$editerrorok      = ""
	$edittitleok      = ""
	$editparmok       = ""
	$editsearchfilled = ""
	$editsearchok     = ""
	$custmaxhoriz     = ""
	Dim $edithandlewinset   [6]
	Dim $edithandlewininst  [6]
	Dim $edithandlewintitle [6]
	$editlimit = UBound($selectionarray) - 1
	If $edithandlegui <> "" Then GUIDelete($edithandlegui)
	$edithandlegui = GUICreate("Editing Menu Entry " & $essub, $scalehsize, $scalevsize * 0.7, -1, -1, -1, "", $handleselectiongui)
	GUISwitch($edithandlegui)
	CommonScaleCreate("Label", "Menu Entry", 3, 4, 8, 3)
	$edithandleentry = CommonScaleCreate("Input", $essub, 13, 4, 5, 3)
	GUICtrlCreateUpdown($edithandleentry)
	$edithelphandle = CommonScaleCreate("Button", "Help", 90, 1, 8, 3.5)
	GUICtrlSetBkColor ($edithelphandle, $mymedblue)
	CommonScaleCreate("Label", "Title", 30, 4, 4, 3)
	$edithandletitle = CommonScaleCreate("Input", $selectionarray[$essub][$sEntryTitle], 37, 4, 50, 3)
	CommonScaleCreate("Label", "Type",  3, 10, 10, 3)
	$edithandletype = CommonScaleCreate("Combo", "", 13, 10, 13, 3, -1)
	$estypestring = $typestring
	If $firmwaremode = "EFI" And $windowstypecount > 0 And $selectionarray [$essub] [$sOSType] <> "windows" _
		Then $estypestring = StringReplace ($estypestring, "windows|", "")
	If $firmwaremode <> "EFI" Then $estypestring = StringReplace ($estypestring, "windows|", "")
	GUICtrlSetData ($edithandletype, $estypestring, $selectionarray[$essub][$sOSType])
	GUIStartGroup  ()
	$editpromptbootby = CommonScaleCreate("Group", "", 30, 13.0, 65, 20.5)
	$edithandleradio1 = CommonScaleCreate("Radio", "", 33, 18.0, 17, 3)
	$edithandleradio2 = CommonScaleCreate("Radio", "", 33, 23.0, 22, 3)
	$edithandleradio3 = CommonScaleCreate("Radio", "", 33, 28.0, 17, 3)
	$edithandleradio4 = CommonScaleCreate("Radio", "", 33, 34.5, 35, 3)
	EditRefreshRadio ($essub, $selectionarray[$essub][$sBootBy], $selectionarray[$essub][$sAutoUser])
	$editpromptdrva  = CommonScaleCreate("Label", "Drive", 55, 18, 8, 3)
	$edithandledrva  = CommonScaleCreate("Input", $selectionarray[$essub][$sDiskAddress], 60, 18, 5, 3)
	$editupdowndrva  = GUICtrlCreateUpdown($edithandledrva)
	$editpromptprta  = CommonScaleCreate("Label", "Partition", 76, 18, 9, 3)
	$edithandleprta  = CommonScaleCreate("Input", $selectionarray[$essub][$sPartAddress], 83, 18, 5, 3)
	$editupdownprta  = GUICtrlCreateUpdown($edithandleprta)
	$edithandlesearch = CommonScaleCreate("Input", $selectionarray[$essub][$sSearchArg], 60,   23,  25, 3)
	$esselandstring  = $selbootdir
	If $selectionarray[$essub][$sOSType] = "remix" Then $esselandstring = $selkernel
	$edithandleseland = CommonScaleCreate("Button", $esselandstring, 86.5, 20, 7, 9, $BS_MULTILINE)
	$edithandledev   = CommonScaleCreate("Label", "", 3, 54.5, 50, 3)
	$editpromptdrvc  = CommonScaleCreate("Label", "Drive", 55, 28, 8, 3)
	$edithandledrvc  = CommonScaleCreate("Input", $selectionarray[$essub][$sDiskAddress], 60, 28, 5, 3)
	$editupdowndrvc  = GUICtrlCreateUpdown($edithandledrvc)
	$edithandlechkc  = CommonScaleCreate("Checkbox", "Partition", 74, 28, 9, 3)
	GUICtrlSetState ($edithandlechkc, $GUI_CHECKED)
	If $selectionarray[$essub][$sPartAddress] = 0 Then GUICtrlSetState ($edithandlechkc, $GUI_UNCHECKED)
	$edithandleprtc  = CommonScaleCreate("Input", $selectionarray[$essub][$sPartAddress], 83, 28, 5, 3)
	$editupdownprtc  = GUICtrlCreateUpdown($edithandleprtc)
	$editprompticon  = CommonScaleCreate("Label", "Click The Icon",  13.4, 19,   12, 3)
	$editpromptgraph = CommonScaleCreate("Label", "Graphics Payload", 3,   27.2, 10, 6)
	$edithandlegraph = CommonScaleCreate("Combo", "", 13, 27, 10, 3, -1)
	GUICtrlSetData($edithandlegraph, $graphnotset & "|any|" & $graphstring, $selectionarray[$essub][$sGraphMode])
	                   CommonScaleCreate("Label", "Pause" & @CR & "Seconds", 3, 33, 8, 6)
	$edithandlepause = CommonScaleCreate("Input", $selectionarray[$essub][$sReviewPause], 13, 34, 4.5, 3)
	$editupdownpause = GUICtrlCreateUpdown($edithandlepause)
	                    CommonScaleCreate("Label", "Hotkey", 3, 40, 8, 3)
	$edithandlehotkey = CommonScaleCreate("Combo", "", 13, 39.5, 10, 3, -1)
	$eshotkey     = $selectionarray[$essub][$sHotKey]
	$eshotkeywork = $edithotkeywork
	If Not StringInStr ($edithotkeywork, "|" & $eshotkey & "|") Then $eshotkeywork &= $eshotkey & "|"
	GUICtrlSetData($edithandlehotkey, $eshotkeywork, $eshotkey)
	$edithandlewarn = CommonScaleCreate("Label", "", 25, 54.5, 50, 8, $SS_CENTER)
	$editpromptparm = CommonScaleCreate("Label", "Linux Boot Parms",   43, 43, 12, 3)
	GUIStartGroup ()
	$edithandlechknv = CommonScaleCreate ("Checkbox", "Nvidia Support", 80, 43, 17, 3)
	If $selectionarray [$essub] [$sFamily] = "linux-andremix" Then EditAndroidGUI ($essub)
	$editbuttonstand = CommonScaleCreate("Button",   "Restore Standard Parms", 78, 54.5, 19, 3.5)
	GUICtrlSetBkColor ($editbuttonstand, $mygreen)
	$edithandleparm  = CommonScaleCreate("Edit", CommonParmCalc ($essub, "Previous", "Store"), 3, 46, 95, 8)
	$editmessageparm = CommonScaleCreate("Label", "Standard Parms Are In Use", 79, 54.5, 20, 3)
	GUICtrlSetColor   ($editmessageparm, $mymedblue)
	$editpromptcust     = CommonScaleCreate ("Button",  "  Edit Custom Code  ",  36.5, 10, 14.0, 4)
	GUICtrlSetBKColor   ($editpromptcust, $mygreen)
	$editpromptauto     = CommonScaleCreate ("Button",  " Abandon Custom Code ", 54.1, 10, 16.0, 4)
	GUICtrlSetBKColor   ($editpromptauto, $mygreen)
	$edithandleseliso   = CommonScaleCreate ("Button",  " Select ISO File ",     54.1, 10, 16.0, 4)
	GUICtrlSetBKColor   ($edithandleseliso, $mygreen)
	$editpromptsample   = CommonScaleCreate ("Button",  "  Load Sample Code ",  73.4, 10, 14.0, 4)
	GUICtrlSetBKColor   ($editpromptsample, $mygreen)
	$editlistcustedit   = CommonScaleCreate ("List", "", 37, 15, 50, 48, $WS_HSCROLL + $WS_VSCROLL)
	GUICtrlSetBkColor ($editlistcustedit, $mylightgray)
	CustomWriteList   ($essub)
	If $selectionarray [$essub] [$sOSType] = "windows" And $firmwaremode = "EFI" Then
		$eswinvert  = 13
		;_ArrayDisplay ($bcdwinorder)
		For $eswinsub = 0 To Ubound ($bcdwinorder) - 1
			If $eswinsub > 5 Then ExitLoop
			$edithandlewinset   [$eswinsub] = CommonScaleCreate ("Button", "Move To Top", 35, $eswinvert, 12, 3.5)
			$edithandlewininst  [$eswinsub] = CommonScaleCreate ("Label",  "", 49, $eswinvert + 0.6, 10, 3.5)
			$edithandlewintitle [$eswinsub] = CommonScaleCreate ("Input",  "", 59, $eswinvert + 0.6, 30, 3.5)
			$eswinvert += 8
		Next
		EditSetupWinOrder ()
	EndIf
	EditIcon          ($essub)
	$focushandle = $edithandletitle
	$editbuttoncancel = CommonScaleCreate("Button", "Cancel", 10, 63, 10, 3.8)
	$editbuttonapply  = CommonScaleCreate("Button", "Apply",  45, 63, 10, 3.8)
	$editbuttonok     = CommonScaleCreate("Button", "OK",     80, 63, 10, 3.8)
EndFunc

Func EditRefresh($ersub)
	EditType($ersub)
	Select
		Case $selectionarray[$ersub][$sBootBy] = $modepartaddress
			EditDrivePart($ersub, $edithandledrva, $edithandleprta)
		Case $selectionarray[$ersub][$sBootBy] = $modepartlabel Or $selectionarray[$ersub][$sBootBy] = $modepartfile Or $selectionarray[$ersub][$sBootBy] = $modebootdir
			EditSearchPart($ersub)
		Case $selectionarray[$ersub][$sBootBy] = $modechainloader
			EditDrivePart($ersub, $edithandledrvc, $edithandleprtc)
			If GUICtrlRead ($edithandlechkc) = $GUI_UNCHECKED Then $selectionarray [$ersub] [$sPartAddress] = 0
	EndSelect
	EditGraph($ersub)
	EditPause($ersub)
	EditCheckErrors($ersub)
	If $focushandle > 0 And $focushandle <> $focushandlelast Then
		ControlFocus ($edithandlegui, "", $focushandle)
		$focushandlelast = $focushandle
	EndIf
	If $custmaxhoriz > 55 Then GUICtrlSetLimit ($editlistcustedit, Int ($custmaxhoriz * 6))
	GUISetBkColor($myorange, $edithandlegui)
	GUISetState(@SW_SHOW, $edithandlegui)
EndFunc

Func EditCheckFocus ()
	Select
		Case CommonControlCheckClick ($edithandlegui, $edithandletitle)  = 1
			Return $edithandletitle
		Case CommonControlCheckClick ($edithandlegui, $edithandleparm)   = 1
			Return $edithandleparm
		Case CommonControlCheckClick ($edithandlegui, $edithandlesearch) = 1
			Return $edithandlesearch
		Case CommonControlCheckClick ($edithandlegui, $editpictureicon)  = 1
			Return $editpictureicon
		Case CommonControlCheckClick ($edithandlegui, $editprompticon)   = 1
			Return $editprompticon
	EndSelect
	Return 0
EndFunc

Func EditSetupWinOrder ($eswstate = $guihideit)
	;_ArrayDisplay ($bcdwinorder, "Edit Setup")
	If $eswstate = $guihideit Then GUICtrlSetState ($edithandletitle, $guishowit)
	For $eswwinsub = 0 To Ubound ($bcdwinorder) - 1
		If $eswwinsub > 5 Then ExitLoop
		$bcdwinorder [$eswwinsub] [6] = $eswwinsub * 100
		GUICtrlSetState ($edithandlewinset   [$eswwinsub], $eswstate)
		GUICtrlSetState ($edithandlewininst  [$eswwinsub], $eswstate)
		GUICtrlSetState ($edithandlewintitle [$eswwinsub], $eswstate)
		If $eswwinsub = 0 Then GUICtrlSetState ($edithandlewinset [$eswwinsub], $guihideit)
		If $eswstate  = $guihideit Then ContinueLoop
		GUICtrlSetData ($edithandlewininst  [$eswwinsub], "Instance " & $eswwinsub + 1)
		GUICtrlSetData ($edithandlewintitle [$eswwinsub], $bcdwinorder [$eswwinsub] [1])
	Next
EndFunc

Func EditCheckWinOrder ($ecwstatus, $ecwsub)
	For $ecwwinsub = 0 To Ubound ($bcdwinorder) - 1
		If $ecwwinsub > 5 Then ExitLoop
		If $ecwstatus = $edithandlewinset [$ecwwinsub] Then
			$bcdwinorder [$ecwwinsub] [6] = 0
			_ArraySort ($bcdwinorder, 0, 0, 0, 6)
			GUICtrlSetBkColor ($edithandlewintitle [0], $mygreen)
			EditRefresh ($ecwsub)
		Endif
		If $ecwstatus = $edithandlewintitle [$ecwwinsub] Then
			$ecwtitle = GUICtrlRead ($edithandlewintitle [$ecwwinsub])
			If StringLen (StringStripWS ($ecwtitle, 8)) > 1 Then
				$bcdwinorder [$ecwwinsub] [1] = $ecwtitle
				GUICtrlSetBkColor ($edithandlewintitle [$ecwwinsub], $mygreen)
			EndIf
		EndIf
	Next
EndFunc

Func EditTitle($etitlesub)
	$edittitleok = ""
	$etstring = CommonContentStringCheck ($edithandletitle, $edittitleok, 50)
	$selectionarray [$etitlesub][$sEntryTitle] = $etstring
EndFunc

Func EditLoadSample ($elssub)
	$elssamptype = $selectionarray [$elssub] [$sOSType]
	CommonUpdateMessage ("Loading Sample Code", "For " & BasicCapIt ($elssamptype) & " Systems")
	Dim $elsstandarray [1]
	If $selectionarray [$elssub] [$sReviewPause] < 1 And $elssamptype <> "submenu" Then
		GUICtrlSetData ($edithandlepause, 2)
		$selectionarray [$elssub] [$sReviewPause] = 2
	EndIf
	GenGetOsFields ($elssub, $elsstandarray, "sample")
	CommonArrayWrite ($customtempstand, $elsstandarray)
	If $elssamptype = "other"   Then FileCopy ($samplecustcode, $customtempstand, 1)
	If $elssamptype = "isoboot" Then FileCopy ($sampleisocode,  $customtempstand, 1)
	If $elssamptype = "submenu" Then FileCopy ($samplesubcode,  $customtempstand, 1)
	$selectionarray   [$elssub] [$sCustomFunc] = ""
	CustomReadfile    ($customtempstand, $elssub)
	CustomWriteList   ($elssub)
	GUICtrlSetBkColor ($editpromptcust,   $mygreen)
	GUICtrlSetBkColor ($editpromptsample, $mygreen)
	CommonUpdateMessage ("", "", "", 1000)
EndFunc

Func EditType($etsub)
	$edittype = GUICtrlRead ($edithandletype)
	If $edittype = "" Then $edittype = "unknown"
	$etstatus = "Previous"
	If $edittype <> $selectionarray[$etsub][$sOSType] Then $etstatus = "New"
	$selectionarray[$etsub][$sOSType] = $edittype
	GuiCtrlSetData ($editpromptbootby, " Automatically Generate Configuration Code For " & _
		BasicCapIt ($selectionarray[$etsub][$sOSType]))
	$etparmloc = CommonGetOSParms ($etsub)
	$etfamily  = $osparmarray [$etparmloc] [$pFamily]
	$etttitle  = $osparmarray [$etparmloc] [$pTitle]
	$selectionarray [$etsub] [$sFamily] = $etfamily
	If $etstatus = "New" Then
		$selectionarray [$etsub] [$sEntryTitle] = $etttitle
		$selectionarray [$etsub] [$sIcon]    = "icon-" & $selectionarray [$etsub] [$sOSType]
		EditIcon ($etsub)
		$etparmcalctype = "Held"
		If $selectionarray [$etsub][$sBootParm] = "" Then $etparmcalctype = "Standard"
		$selectionarray [$etsub][$sBootParm] = CommonParmCalc ($etsub, $etparmcalctype)
		If $selectionarray [$etsub][$sOSType]    = "isoboot" Then _
			GuiCtrlSetData ($edithandlegraph,      "1024x768")
		If  $selectionarray[$etsub][$sOSType] = "android" Then
			$selectionarray[$etsub][$sBootBy] = $modebootdir
			GuiCtrlSetData ($edithandlesearch, $androidbootdir)
			GuiCtrlSetData ($edithandleseland, $selbootdir)
		ElseIf $selectionarray[$etsub][$sOSType] = "remix" Then
			$selectionarray[$etsub][$sBootBy] = $modepartfile
			GuiCtrlSetData ($edithandlesearch, $remixbootkern)
			GuiCtrlSetData ($edithandleseland, $selkernel)
		ElseIf StringInStr ($etfamily, "linux") Then
			$selectionarray[$etsub][$sBootBy] = $modepartaddress
			GuiCtrlSetData ($edithandlegraph, "1024x768")
		ElseIf $selectionarray [$etsub] [$sOSType] = "freebsd" Then
			$selectionarray[$etsub][$sSearchArg] = $bsdbootfile
			GuiCtrlSetData ($edithandlesearch, $bsdbootfile)
		Else
			$selectionarray[$etsub][$sBootBy] = ""
			$selectionarray[$etsub][$sSearchArg] = ""
			GuiCtrlSetData ($edithandlesearch, "")
		EndIf
		CommonArraySetDefaults ($etsub)
		;_ArrayDisplay ($selectionarray, $etsub)
		If $selectionarray [$etsub] [$sFamily] = "linux-andremix" Then
			$selectionarray [$etsub] [$sEntryTitle] &= " 64 Bit"
			EditAndroidGUI  ($etsub)
		EndIf
		If ($selectionarray [$etsub][$sAutoUser]  = "Custom" And $selectionarray[$etsub][$sOSType] <> "submenu") Or _
			$selectionarray [$etsub] [$sFamily]   = "template" Then
				$selectionarray[$etsub][$sReviewPause] = 2
				GuiCtrlSetData ($edithandlepause, 2)
		EndIf
	EndIf
	EditSetAttribs ($etsub, $selectionarray[$etsub][$sBootBy])
	$etnewparm = CommonParmCalc ($etsub, "Previous", "Store")
	GuiCtrlSetData ($edithandletitle, $selectionarray[$etsub][$sEntryTitle])
	GuiCtrlSetData ($edithandleparm, $etnewparm)
EndFunc

Func EditSetAttribs ($esasub, $esabootby = $modepartaddress)
	$esasearch      = $guihideit
	$esaaddressa    = $guihideit
	$esaaddressc    = $guihideit
	$esaparm        = $guihideit
	$esaparmandroid = $guihideit
	$esacust        = $guihideit
	$esapartc       = $guihideit
	$esaiso         = $guihideit
	$esafamily      = $selectionarray [$esasub][$sFamily]
	If StringInStr ($esafamily, "linux") Then $esaparm = $guishowit
	EditRefreshRadio ($esasub, $esabootby, $selectionarray[$esasub][$sAutoUser])
	;If $firmwaremode = "EFI" Then EditSetupWinOrder ($guihideit)
	Select
		Case $selectionarray [$esasub] [$sOSType] = "" Or $selectionarray [$esasub] [$sOSType] = "unknown"
		Case $selectionarray [$esasub] [$sAutoUser] = "Custom"
			$esacust = $guishowit
			$esaparm = $guihideit
		Case $selectionarray [$esasub] [$sOSType] = "windows" And $firmwaremode = "EFI"
			EditSetupWinOrder ($guishowit)
		Case $esabootby = $modepartlabel Or $esabootby = $modepartfile Or $esabootby = $modebootdir
			$esasearch  = $guishowit
		Case $esabootby = $modepartaddress
			If GUICtrlRead ($edithandleprta) < 1 Then GUICtrlSetData ($edithandleprta, 1)
			EditDrivePart ($esasub, $edithandledrva, $edithandleprta)
			$esaaddressa = $guishowit
		Case $esabootby = $modechainloader
			$esaaddressc = $guishowit
			If CommonCheckBox ($edithandlechkc) Then $esapartc = $guishowit
			$esaparm     = $guihideit
	EndSelect
	If $esafamily = "linux-andremix" Then $esaparmandroid = $guishowit
	If $esaparm = $guihideit Then $esaparmandroid = $guihideit
	If $selectionarray [$esasub] [$sOSType] = "isoboot"	Then $esaiso = $guishowit
	GUICtrlSetState ($editpromptdrva,     $esaaddressa)
	GUICtrlSetState ($edithandledrva,     $esaaddressa)
	GUICtrlSetState ($editupdowndrva,     $esaaddressa)
	GUICtrlSetState ($editpromptprta,     $esaaddressa)
	GUICtrlSetState ($edithandleprta,     $esaaddressa)
	GUICtrlSetState ($editupdownprta,     $esaaddressa)
	GUICtrlSetState ($edithandledev,      $esaaddressa)
	GUICtrlSetState ($editpromptdrvc,     $esaaddressc)
	GUICtrlSetState ($edithandledrvc,     $esaaddressc)
	GUICtrlSetState ($editupdowndrvc,     $esaaddressc)
	GUICtrlSetState ($edithandlechkc,     $esaaddressc)
	GUICtrlSetState ($edithandleprtc,     $esapartc)
	GUICtrlSetState ($editupdownprtc,     $esapartc)
	GUICtrlSetState ($edithandlesearch,   $esasearch)
	GUICtrlSetState ($edithandleseliso,   $esaiso)
	GUICtrlSetState ($edithandleseland,   $esasearch)
	If $esafamily <> "linux-andremix" Then GUICtrlSetState ($edithandleseland, $guihideit)
	GUICtrlSetState ($edithandlechknv,    $esaparmandroid)
	GUICtrlSetState ($editpromptparm,     $esaparm)
	GUICtrlSetState ($edithandleparm,     $esaparm)
	GUICtrlSetState ($editbuttonstand,    $esaparm)
	GUICtrlSetState ($editpromptcust,     $esacust)
	GUICtrlSetState ($editpromptauto,     $esacust)
	GUICtrlSetState ($editpromptsample,   $esacust)
	GUICtrlSetState ($editlistcustedit,   $esacust)
	GUICtrlSetState ($editbuttoncustdel,  $esacust)
	GUICtrlSetState ($editmessageparm,    $guihideit)
	If $esafamily = "freebsd" Then GUICtrlSetState ($edithandlechkc, $guihideit)
	If Not StringInStr ($esafamily, "linux") Then GUICtrlSetState ($edithandledev, $guihideit)
	If $selectionarray [$esasub] [$sOSType] = "other" Or $selectionarray [$esasub] [$sOSType] = "isoboot" Or _
	   $selectionarray [$esasub] [$sOSType] = "submenu" Then GUICtrlSetState ($editpromptauto, $guihideit)
	If $esaparm = $guihideit Then Return
	If $selectionarray [$esasub] [$sBootParm] = CommonParmCalc ($esasub, "Standard") Then
		GUICtrlSetState ($editbuttonstand, $guihideit)
		GUICtrlSetState ($editmessageparm, $guishowit)
	EndIf
EndFunc

Func EditRadioButton ($erbsub, $erbnumber)
	If $erbnumber = 1 Then $erbselection = $radioname1
	If $erbnumber = 2 Then $erbselection = $radioname2
	If $erbnumber = 3 Then $erbselection = $radioname3
	If $erbnumber = 4 Then
		$erbselection = $radioname4
		$selectionarray[$erbsub][$sAutoUser] = "Custom"
	EndIf
	If $erbselection <> $modecustom Then $selectionarray [$erbsub] [$sBootBy] = $erbselection
	EditSetAttribs ($erbsub, $erbselection)
	EditCheckErrors($erbsub)
EndFunc

Func EditRefreshRadio ($rrsub, $rrtext = "", $rrautouser = "")
	Local $rrbuttons
	$rrtype    = $selectionarray [$rrsub] [$sOSType]
	$rrfamily  = $selectionarray [$rrsub] [$sFamily]
	If $rrfamily = "template" Or $rrautouser = "Custom" Or $rrtype = "unknown" Then $rrbuttons = "no"
	If $rrtype = "" Or ($rrtype = "windows" And $firmwaremode = "EFI") Then $rrbuttons = "no"
	$rrstatus1 = $guishowit
	$rrstatus2 = $guishowit
	$rrstatus3 = $guishowit
	$rrstatus4 = $guishowit
	$rrchecked = $guishowit + $GUI_CHECKED
	Select
		Case $rrbuttons = "no"
			$rrstatus1 = $guihideit
			$rrstatus2 = $guihideit
			$rrstatus3 = $guihideit
			$rrstatus4 = $guihideit
		Case $rrtype = "windows"
			$radioname1 = $modewinauto
			$rrstatus2  = $guihideit
			$rrstatus3  = $guihideit
			$rrstatus4  = $guihideit
		Case $rrtype = "android"
			$rrstatus1  = $guihideit
			$radioname2 = $modebootdir
			$radioname3 = $modechainloader
		Case $rrtype = "remix"
			$rrstatus1  = $guihideit
			$radioname2 = $modepartfile
			$radioname3 = $modechainloader
		Case $rrtype = "freebsd"
			$radioname1 = $modepartaddress
			$radioname2 = $modepartfile
			$radioname3 = $modechainloader
		Case Else
			$radioname1 = $modepartaddress
			$radioname2 = $modepartlabel
			$radioname3 = $modechainloader
	EndSelect
	If $firmwaremode = "EFI" Then $rrstatus3 = $guihideit
	$radioname4 = $modecustom
	GuiCtrlSetData  ($edithandleradio1, $radioname1)
	GuiCtrlSetData  ($edithandleradio2, $radioname2)
	GuiCtrlSetData  ($edithandleradio3, $radioname3)
	GuiCtrlSetData  ($edithandleradio4, $radioname4)
	GUICtrlSetState ($editpromptbootby, $rrstatus2)
	GUICtrlSetState ($edithandleradio1, $rrstatus1)
	GUICtrlSetState ($edithandleradio2, $rrstatus2)
	GUICtrlSetState ($edithandleradio3, $rrstatus3 + $GUI_UNCHECKED)
	GUICtrlSetState ($edithandleradio4, $rrstatus4 + $GUI_UNCHECKED)
	If $rrbuttons = "no" Then Return
	Select
		Case $rrtext = $radioname1
			GUICtrlSetState ($edithandleradio1, $rrchecked)
		Case $rrtext = $radioname2
			GUICtrlSetState ($edithandleradio2, $rrchecked)
		Case $rrtext = $radioname3
			GUICtrlSetState ($edithandleradio3, $rrchecked)
		Case $rrtext = $radioname4
			GUICtrlSetState ($edithandleradio4, $rrchecked)
	EndSelect
EndFunc

Func EditAndroidGUI ($egsub)
	CommonAndroidArray ($egsub)
	GUICtrlSetState ($edithandlechknv, $GUI_UNCHECKED)
	If $selectionarray[$egsub][$sNvidia] = "yes" Then GUICtrlSetState ($edithandlechknv, $GUI_CHECKED)
EndFunc

Func EditAndroidParm ($epsub)
	$epparm = StringStripWS ($selectionarray [$epsub] [$sBootParm], 2)
	$selectionarray [$epsub] [$sNvidia] = "no"
	$epparm = StringReplace ($epparm, $parmnvidia, " ")
	If CommonCheckBox ($edithandlechknv) Then
		$epparm &= " " & $parmnvidia
		$selectionarray [$epsub] [$sNvidia] = "yes"
	EndIf
	$selectionarray [$epsub] [$sbootparm] = $epparm
	GuiCtrlSetData ($edithandleparm, $epparm)
	CommonAndroidArray ($epsub)
EndFunc

Func EditAndroidSelect ($easub)
	$eatype = $selectionarray [$easub] [$sOSType]
	If $eatype = "android" Then
		$easearch = FileSelectFolder ("Select the " & $eatype & " boot directory",  "C:\")
		If @error Then Return
	Else
		$easearch = FileOpenDialog   ("Select the " & $eatype & " kernel file", "", "(*.*)", $FD_FILEMUSTEXIST)
		If @error Then Return
	EndIf
	If StringLen ($easearch) < 4 Then Return
	$easearch = StringReplace  ($easearch, "\", "/")
	$easearch = StringTrimLeft ($easearch, 2)
	GuiCtrlSetData ($edithandlesearch, $easearch)
EndFunc

Func EditISOSelect ($eisub)
	$eisearch = FileOpenDialog ($selisofile, "", "(*.iso)", $FD_FILEMUSTEXIST)
	If @error Or StringLen ($eisearch) < 4 Then Return
	$eisearch = StringReplace (StringTrimLeft ($eisearch, 2), "\", "/")
	StringReplace ($eisearch, " ", "")
	If @extended > 0 Then
		MsgBox ($mbontop, "", "*** Error - The ISO file path must not contain embedded spaces ***" & @CR & @CR & $eisearch)
		Return
	EndIf
	$eisearch = "'" & $eisearch & "'"
	If CustomGetData ($eisub) = "" Then
		EditLoadSample ($eisub)
		EditRefresh    ($eisub)
	EndIf
	$eiloc    = _ArraySearch ($custparsearray, $selectionarray [$eisub] [$sCustomFunc], 0, 0, 0, 0, 0, $sCustStamp)
	$eilimit  = $custparsearray [$eiloc] [$sCustRecordCount]
	$eifound  = ""
	$eisearch = "    set isopath=" & $eisearch
	For $eirecordno = 3 To $eilimit
		$eirecord = $custparsearray [$eiloc] [$eirecordno]
		If StringLeft  (StringStripWS ($eirecord, 1), 1) = "#" Then ContinueLoop
		If StringInStr ($eirecord, "isopath=") Then
			$custparsearray [$eiloc] [$eirecordno] = $eisearch
			$eifound = "yes"
			ExitLoop
		EndIf
	Next
	If $eifound <> "yes" Then $custparsearray [$eiloc] [3] = $eisearch
	CustomWriteList ($eisub)
	CommonUpdateMessage ("Updating the isopath variable", $eisearch)
	CommonUpdateMessage ("", "", "", 3000)
EndFunc

Func EditDrivePart ($edpsub, $edpdrivehandle, $edpparthandle)
	Local $edpdigit
	CommonCheckUpDown ($edpdrivehandle, $edpdigit, 0,  9)
	$selectionarray [$edpsub] [$sDiskAddress] = $edpdigit
	CommonCheckUpDown ($edpparthandle,  $edpdigit, 1, 99)
	$selectionarray [$edpsub] [$sPartAddress] = $edpdigit
	EditDisplayDev($edpsub)
EndFunc

Func EditChainCheck ($eccsub)
	If CommonCheckBox ($edithandlechkc) Then
		GUICtrlSetData ($edithandleprtc, 1)
	Else
		$selectionarray[$eccsub][$sPartAddress] = 0
	EndIf
	EditSetAttribs ($eccsub, $modechainloader)
EndFunc

Func EditSearchPart($espsub)
	$editsearchok     = ""
	$editsearchfilled = ""
	Select
		Case $selectionarray[$espsub][$sBootBy] = $modepartlabel
			$espsearch = CommonContentStringCheck($edithandlesearch, $editsearchok, 16)
		Case $selectionarray[$espsub][$sBootBy] = $modebootdir
			$espsearch = CommonContentStringCheck($edithandlesearch, $editsearchok, 60, "yes")
			If $selectionarray [$espsub][$sSearchArg] = "" Then GuiCtrlSetData ($edithandlesearch, $androidbootdir)
			GuiCtrlSetData ($edithandleseland, $selbootdir)
		Case $selectionarray[$espsub][$sBootBy] = $modepartfile
			If $selectionarray [$espsub][$sSearchArg] = "" Then
				GuiCtrlSetData ($edithandleseland, $selkernel)
				If $selectionarray[$espsub][$sOSType] = "freebsd" Then GuiCtrlSetData ($edithandlesearch, $bsdbootfile)
				If $selectionarray[$espsub][$sOSType] = "remix"   Then GuiCtrlSetData ($edithandlesearch, $remixbootkern)
			EndIf
			$espsearch = CommonContentStringCheck($edithandlesearch, $editsearchok, 60, "yes")
		Case Else
			Return
	EndSelect
	$espsearch = StringReplace($espsearch, " ", "")
	If @extended > 0 Then $editsearchok = "embedded"
	If StringLen ($espsearch) = 0 Then $editsearchfilled = "no"
	$selectionarray[$espsub][$sSearchArg] = $espsearch
EndFunc

Func EditParm($epsub)
	$epparm = GUICtrlRead($edithandleparm)
	$editparmok     = "yes"
	$editparmlength = StringLen($epparm)
	If $editparmlength > 120 Then $editparmok = "no"
	If $editparmlength = 0 Then
		$epparm = "NullParm"
		GUICtrlSetData($edithandleparm, "")
	EndIf
	$selectionarray[$epsub][$sBootParm] = $epparm
	CommonParmCalc ($epsub, "Held", "Store")
EndFunc

Func EditGraph($egsub)
	$eggraph = GUICtrlRead($edithandlegraph)
	$selectionarray[$egsub][$sGraphMode] = $eggraph
EndFunc

Func EditHotkey($ehsub)
	$ehhotkey = GUICtrlRead($edithandlehotkey)
	$selectionarray[$ehsub][$sHotKey] = $ehhotkey
EndFunc

Func EditPause($epentrysub)
	Local $eppause
	CommonCheckUpDown ($edithandlepause, $eppause, 0, 120)
	$selectionarray[$epentrysub][$sReviewPause] = $eppause
EndFunc

Func EditDisplayDev($eddsub)
	$eddaddress = "Linux Root Device Address  =  " & CommonConvDevAddr($selectionarray[$eddsub][$sDiskAddress], $selectionarray[$eddsub][$sPartAddress])
	GUICtrlSetData($edithandledev, $eddaddress)
EndFunc

Func EditIcon ($eisub)
	GUISwitch ($edithandlegui)
	If $editpictureicon <> "" Then GuiCtrlDelete ($editpictureicon)
	$ediconpath      = $iconpath & "\" & $selectionarray [$eisub] [$sIcon] & ".png"
	$editpictureicon = CommonScaleCreate ("PicturePNG", $ediconpath, 3, 15, 8, 10)
EndFunc

Func EditCheckErrors($ecesub)
	$editerrorok = "no"
	$ececolor    = $myred
	$ecebootby   = $selectionarray [$ecesub] [$sBootBy]
	Select
		Case $selectionarray [$ecesub] [$sOSType] = "" Or $selectionarray [$ecesub] [$sOSType] = "unknown"
			$editwarnmessage = 'Please select an OS Type.'
			$ececolor        = $mypurple
		Case $edittitleok = "no"
			$editwarnmessage = 'The menu title must be 1 to 50 characters and alphanumeric' & @CR & '"." and "-" are allowed.'
		Case $selectionarray [$ecesub] [$sAutoUser] = "Custom" And CustomGetData ($ecesub) = ""
		   	$editwarnmessage = 'Custom code has not yet been entered'
			$ececolor        = $myyellow
			GUICtrlSetState   ($editpromptauto,   $guihideit)
			GUICtrlSetState   ($editlistcustedit, $guihideit)
			GUICtrlSetState   ($editpromptcust,   $guishowit)
			GUICtrlSetBkColor ($editpromptcust,   $myyellow)
			GUICtrlSetBkColor ($editpromptsample, $myyellow)
		Case $selectionarray [$ecesub] [$sAutoUser] = "Custom"
			$editerrorok = "yes"
		Case $editparmok = "no" And ($ecebootby = $modepartlabel Or $ecebootby = $modepartaddress)
			$editwarnmessage = 'The Linux Boot Parm contains ' & $editparmlength & ' characters.   It should have 120 characters or less.'
		Case $ecebootby <> $modepartlabel And $ecebootby <> $modepartfile And $ecebootby <> $modebootdir
			$editerrorok = "yes"
		Case $editsearchfilled = "no"
			$editwarnmessage = 'Please fill in the  "Partition Search By"  field ' & @CR _
			& 'Then click the Apply button below.'
			$ececolor        = $myyellow
		Case $editsearchok = "embedded"
			$editwarnmessage = 'The search field must not contain embedded spaces.'
		Case $editsearchok = "no" And $selectionarray [$ecesub] [$sBootBy] = $modepartlabel
			$editwarnmessage  = 'The partition search label must be 1 to 16 characters and alphanumeric' & @CR
			$editwarnmessage &= '"." and "-" are allowed.'
		Case $editsearchok = "no" And $selectionarray [$ecesub] [$sBootBy] = $modepartfile
			$editwarnmessage  = 'The partition search file name must be 1 to 60 characters and alphanumeric' & @CR
			$editwarnmessage &= '"."  "-" and "/" are allowed.'
		Case $editsearchok = "no" And $selectionarray [$ecesub] [$sBootBy] = $modebootdir
			$editwarnmessage  = 'The boot directory name must be 1 to 60 characters and alphanumeric' & @CR
			$editwarnmessage &= '"."  "-" and "/" are allowed.'
		Case Else
			$editerrorok = "yes"
	EndSelect
	If $editerrorok = "yes" Then
		GUICtrlSetData  ($edithandlewarn, "")
		GUICtrlSetState ($edithandlewarn, $guihideit)
		GUICtrlSetState ($editbuttonok,   $guishowit)
		GUICtrlSetState ($editprompticon, $guishowit)
	Else
		If $ececolor = $myred Then $editwarnmessage &= @CR & 'Please correct the error, then click the "Apply" button below.'
		GUICtrlSetData    ($edithandlewarn, $editwarnmessage)
		GUICtrlSetBkColor ($edithandlewarn, $ececolor)
		GUICtrlSetState   ($edithandlewarn, $guishowit)
		GUICtrlSetState   ($editbuttonok,   $guishowdis)
		GUICtrlSetState   ($editprompticon, $guihideit)
		$focushandle      = $edithandlesearch
	EndIf
EndFunc