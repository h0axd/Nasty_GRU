#include-once
#include  <g2common.au3>
#include  <g2guiedit.au3>
#include  <g2theme.au3>

Func SelectionRunGUI()
	;_ArrayDisplay ($selectionarray, "Before")
	SelectionRefresh()
	While 1
		$mmstatusarray = GUIGetMsg(1)
		If $mmstatusarray[1] <> $handleselectiongui And $mmstatusarray[1] <> $handleselectionscroll Then ContinueLoop
		$selectionstatus = $mmstatusarray[0]
		Select
			Case $selectionstatus = $GUI_EVENT_CLOSE Or $selectionstatus = $buttonselectioncancel Or $selectionstatus = $buttonselectionapply
				If $handleselectiongui <> "" Then GUIDelete($handleselectiongui)
				If $selectionstatus = $buttonselectionapply Then
					ThemeMainScreenShot ()
					CommonSetupDefault (58, 62.3, 39, 15)
				Else
					$selectionarray    = $selectionholdarray
					$defaultlastbooted = $selectionholdlastbooted
					$bcdwinorder       = $bcdwinmenuhold
				EndIf
				$handleselectiongui = ""
				Return
			Case $selectionstatus = "" Or $selectionstatus = 0 Or $selectionstatus < 0
				ContinueLoop
			Case $selectionstatus = $selectionhelphandle
				CommonHelp ("managingthebootmenu")
				ContinueLoop
			Case $selectionstatus = $handlelastbooted
				SelectionLastBooted ()
			Case $selectionstatus = $buttonselectionadd
				SelectionAdd ()
			Case Else
				For $mmentrysub = 0 To $selectionarraysize - 1
					;_ArrayDisplay ($selectiontransarray)
					If $mmentrysub > $selectionlimit Then ExitLoop
					Select
						Case $selectionstatus = $handleselectiondefault [$mmentrysub]
							$defaultos = $mmentrysub
							CommonDefaultSync ()
						Case $selectionarray [$mmentrysub] [$sAutoUser] = "User"
							ExitLoop
						Case $selectionstatus = $handleselectionup  [$mmentrysub]
							$selectionarray[$mmentrysub][$sSortSeq] -= 110
							$selectionarray[$mmentrysub][$sUpdateFlag]  = "updated"
							$selectionarray[$mmentrysub][$sMouseUpDown] = "up"    ; Mouse Up
						Case $selectionstatus = $handleselectiondown[$mmentrysub]
							$selectionarray[$mmentrysub][$sSortSeq] += 110
							$selectionarray[$mmentrysub][$sUpdateFlag]  = "updated"
							$selectionarray[$mmentrysub][$sMouseUpDown] = "down"  ; Mouse Down
						Case $selectionstatus = $handleselectiondel [$mmentrysub]
							SelectionDelete ($mmentrysub)
						Case $selectionstatus = $handleselectionbox [$mmentrysub]
								$editholdarray = $selectionarray
								$custparseholdarray = $custparsearray
								EditRunGUI ($mmentrysub)
						Case Else
							ContinueLoop
					EndSelect
					SelectionRefresh ()
				Next
				ContinueLoop
		EndSelect
		SelectionRefresh ()
	WEnd
EndFunc

Func SelectionSetupParent ()
	If $handleselectiongui <> "" Then GuiDelete   ($handleselectiongui)
	$selectionheader ="Grub2Win Menu Configuration     Total Entries = " & $selectionentrycount
	$handleselectiongui = GUICreate($selectionheader , $scalehsize + 30, $scalevsize, -1, -1, -1, "", $handlemaingui)
	$selectionhelphandle  = CommonScaleCreate ("Button",   "Help",                           90, 2,  8, 3.5)
	$handlelastbooted     = CommonScaleCreate ("Checkbox", " Default = The Last Booted OS",  28, 2, 47, 3.5)
	GUICtrlSetFont ($handlelastbooted, $scalefontsize * 1.1)
	$defaultlastbooted    = "no"
	If $envreboot <> "none" Then
		GUICtrlSetState ($handlelastbooted, $guishowdis)
		GUICtrlSetData  ($handlelastbooted, " ** Grub Next Boot =" & StringFormat ("%4d", $envreboot) & _
			" - " & $selectionarray [$envreboot] [$sEntryTitle] & " **")
	EndIf
	If $defaultselect     = $lastbooted Then $defaultlastbooted = "yes"
	If $defaultlastbooted = "yes" Then GuiCtrlSetState ($handlelastbooted, $GUI_CHECKED)
	GUICtrlSetBkColor ($selectionhelphandle, $mymedblue)
	If  $selectionentrycount < 40 Then
		$buttonselectionadd = CommonScaleCreate("Button", "Add A New Entry", 76, 2, 13, 3.5)
		GUICtrlSetBkColor($buttonselectionadd, $myorange)
	EndIf
	$buttonselectioncancel = CommonScaleCreate ("Button", "Cancel", 10, 95, 10, 3.8)
	$speditmessage         = CommonScaleCreate ("Label",  "To customize an entry - Click it", 39.5, 96, 20, 2.5, $SS_Center)
	GUICtrlSetBkColor     ($speditmessage, $mygreen)
	$buttonselectionapply  = CommonScaleCreate ("Button", "Apply",  80, 95, 10, 3.8)
	$scrolltoppos = 0
	GUISetBkColor($myblue,  $handleselectiongui)
	GUISetState  (@SW_SHOW, $handleselectiongui)
	GUISwitch              ($handleselectionscroll)
EndFunc

Func SelectionRefresh()
	;_ArrayDisplay ($selectionarray)
	_ArraySort($selectionarray, 0, 0, 0, 7)
	SelectionSequenceUpdate ()
	$selectionentrycount = UBound ($selectionarray)
	$selectionlimit     = $selectionentrycount - 1
	$srtopvspace        = Int ($scalepctvert *  6)
	$srbotvspace        = Int ($scalepctvert * 12)
	$edithotkeywork     = $hotkeystring
	Local $srmovehandle, $srmoveupdown
	If $handleselectiongui = "" Then SelectionSetupParent ()
	$scrolltoppos = CommonScrollDelete ($handleselectionscroll)
	$handleselectionscroll = GUICreate("" , $scalehsize + 30, $scalevsize - $srbotvspace, 0, $srtopvspace, $WS_CHILD, "", _
		$handleselectiongui)
	CommonParmCalc (0, "Reset")
	$selectionarraysize = Ubound ($selectionarray)
	Dim $handleselectiondefault [$selectionarraysize]
	Dim $handleselectionup      [$selectionarraysize]
	Dim $handleselectiondown    [$selectionarraysize]
	Dim $srhandlelocup          [$selectionarraysize]
	Dim $srhandlelocdown        [$selectionarraysize]
	Dim $handleselectiondel     [$selectionarraysize]
	Dim $handleselectiongroup   [$selectionarraysize]
	Dim $handleselectionbox     [$selectionarraysize]
	Dim $handleselectionuser    [$selectionarraysize]
	$windowstypecount = 0
	$srvert           = 0
	For $srlinecount = 0 To $selectionarraysize
		;MsgBox ($mbontop, $srlinecount, $selectionarraysize)
		If $srlinecount > $selectionlimit Then ExitLoop
		$srvert = ($srlinecount * 15) + 5
		CommonArraySetDefaults($srlinecount)
		;_ArrayDisplay ($selectionarray)
		$srtitle = $selectionarray[$srlinecount][$sEntryTitle]
		$sriconpath   = $iconpath & "\" & $selectionarray [$srlinecount] [$sIcon] & ".png"
		$handleselectionbox     [$srlinecount] = CommonScaleCreate ("Label", "",                 10, $srvert - 3.2, 83, 11.2)
		                                         CommonScaleCreate ("LabelPicture", $sriconpath, 12, $srvert + 0.1, 4,   5)
		$handleselectiondefault [$srlinecount] = CommonScaleCreate ("Checkbox", "",               8, $srvert - 4.4, 3,   3)
		GuiCtrlSetState ($handleselectiondefault [$srlinecount], $GUI_UNCHECKED)
		$srdefstring = ""
		If $defaultlastbooted = "yes" Or $selectionarray[$srlinecount] [$sReboot] <> "" Then
			GuiCtrlSetState ($handleselectiondefault [$srlinecount], $guihideit)
			$selectionarray[$srlinecount][$sDefaultOS] = ""
		EndIf
		If $selectionarray[$srlinecount][$sDefaultOS] = "DefaultOS"  Then
			GuiCtrlSetState ($handleselectiondefault [$srlinecount], $GUI_CHECKED)
			$srdefstring = "       ** Grub Default OS **         "
		EndIf
			If $defaultlastbooted = "no" And $selectionarray[$srlinecount][$sReboot] = "Reboot" Then _
				$srdefstring = "       ** Grub Next Boot **"
		$srentrystring = StringMid ($srdefstring & " " & $srtitle & " ", 1, 100)
		$handleselectiongroup [$srlinecount] = CommonScaleCreate ("Group", $srentrystring, 10, $srvert - 4, 83, 12)
		If $selectionarray[$srlinecount][$sUpdateFlag] = "updated" Then GUICtrlSetBkColor ($handleselectiongroup[$srlinecount], $myorange)
		If $srdefstring <> "" Then GUICtrlSetBkColor($handleselectiongroup[$srlinecount], $mygreen)
		If $selectionarray [$srlinecount] [$sAutoUser] = "User" Then
			$handleselectionuser [$srlinecount] = CommonScaleCreate("Label", "** Entry " & $srlinecount & " ** " & @CR & "Is In The User Section", 0.6 , $srvert - 1, 9, 9, $SS_Center)
			GUICtrlSetBkColor ($handleselectiongroup [$srlinecount], $mylightgray)
			GUICtrlSetBkColor ($handleselectionuser  [$srlinecount], $mylightgray)
		EndIf
		If $selectionarray[$srlinecount][$sHotKey] <> "none" Then
			$srhklen = 7.4 + (StringLen ($selectionarray[$srlinecount][$sHotKey]) * 0.75)
			CommonScaleCreate("Label", "  Hotkey = " & $selectionarray[$srlinecount][$sHotKey], 78, $srvert - 4, $srhklen, 3)
			$edithotkeywork = StringReplace ($edithotkeywork, "|" & $selectionarray[$srlinecount][$sHotKey] & "|", "|")
		EndIf
		CommonScaleCreate("Label", $srlinecount, 92.8 - (Stringlen ($srlinecount) * .4), $srvert + 1.2, Stringlen ($srlinecount), 2.8)
		CommonScaleCreate("Label", "Type = "   & $selectionarray[$srlinecount][$sOSType], 18, $srvert + 0.0, 15, 5)
		$srdisk = $modepartaddress & " = Drive  " & $selectionarray[$srlinecount][$sDiskAddress]
		$srdisk &= "  Partition " & $selectionarray[$srlinecount][$sPartAddress]
		Local $srparmprompt = "", $srparmdisplay = ""
		If StringInStr ($selectionarray[$srlinecount][$sFamily], "linux") Then
			If  $selectionarray[$srlinecount][$sBootBy] = $modepartlabel Then
				$srdisk = "Partition Label = " & $selectionarray[$srlinecount][$sSearchArg]
			ElseIf $selectionarray[$srlinecount][$sBootBy] = $modebootdir Then
				$srdisk = "Boot Directory = " & $selectionarray[$srlinecount][$sSearchArg]
			Else
				$srdisk &= "     ( " & CommonConvDevAddr($selectionarray[$srlinecount][$sDiskAddress], $selectionarray[$srlinecount][$sPartAddress]) & " )"
			EndIf
			If $selectionarray[$srlinecount][$sBootBy] <> $modechainloader Then
				$srparm = CommonParmCalc ($srlinecount, "Previous")
				$srparmprompt  = "Parm = "
				$srparmdisplay = StringLeft ($srparm, 60)
				$srparmextra   = StringMid  ($srparm, 61, 60)
				If $srparmextra <> "" Then $srparmdisplay &= @CR & $srparmextra
				$srparmdisplay = '"' & $srparmdisplay & '"'
			EndIf
		EndIf
						CommonScaleCreate ("Label", $srparmprompt,  32, $srvert + 3,  5, 3.3)
		$srhandleparm = CommonScaleCreate ("Label", $srparmdisplay, 37, $srvert + 3, 42, 3.9)
		If StringLen ($srparmdisplay) > 62 Then GUICtrlSetFont ($srhandleparm, 7)
		If $selectionarray[$srlinecount][$sBootBy] = $modechainloader Then
			$srdisk = "Chainloader = Drive " & $selectionarray[$srlinecount][$sDiskAddress]
			If $selectionarray[$srlinecount][$sPartAddress] <> 0 Then $srdisk &= "   Partition " & $selectionarray[$srlinecount][$sPartAddress]
			$srdisk &= "  MBR"
		EndIf
		If $selectionarray[$srlinecount][$sBootBy] = $modepartfile Then
			$srdisk = $modepartfile & " = " & $selectionarray[$srlinecount][$sSearchArg]
		EndIf
		If $selectionarray[$srlinecount][$sOSType]   = "windows"  Then
			$windowstypecount += 1
			If $firmwaremode = "EFI" Then $selectionarray[$srlinecount][$sBootBy] = $modewinauto
		EndIf
		If $selectionarray[$srlinecount][$sBootBy] = $modewinauto Then $srdisk = "Partition Boot Address = Automatic"
		If $selectionarray[$srlinecount][$sFamily] = "template"   Then $srdisk = ""
		If $selectionarray[$srlinecount][$sBootBy] = $modewinauto And $firmwaremode = "EFI" Then
			SelectionWinEFI ($srvert)
		ElseIf $selectionarray[$srlinecount][$sAutoUser] = "Custom" Then
			$srcust = CommonScaleCreate("Label", "**  Custom Configuration **", 32, $srvert, 25, 2.8, $SS_Center)
		    GUICtrlSetBkColor ($srcust, $mymedblue)
		Else
			CommonScaleCreate("Label", $srdisk, 32, $srvert, 40, 3.3)
		EndIf
		CommonScaleCreate ("Label", "Graph = " & $selectionarray[$srlinecount][$sGraphMode],  79, $srvert, 13, 3)
		$srpause = "Pause = " &  $selectionarray[$srlinecount][$sReviewPause]
		If $selectionarray[$srlinecount][$sReviewPause] = 0 Then $srpause = "Pause Is Off"
		CommonScaleCreate ("Label", $srpause, 79, $srvert + 3, 13, 3.3)
		If $selectionarray [$srlinecount] [$sAutoUser] <> "User" Then
			If $srlinecount > 0 Then $handleselectionup [$srlinecount] = CommonScaleCreate("Label", "↑", 97, $srvert - 3.0, 2, 5)
			GUICtrlSetFont    ($handleselectionup [$srlinecount], $scalefontsize * 2, 100)
			GUICtrlSetColor   ($handleselectionup [$srlinecount], $mymedgray)                ; Move Up
			$srhandlelocup [$srlinecount] = CommonScaleCreate("Label", "", 97.6, $srvert - 0.5, 0, 0)
			GUICtrlSetState ($srhandlelocup [$srlinecount], $guihideit)
			If $selectionlimit > 0 Then $handleselectiondel[$srlinecount] = CommonScaleCreate("Button", "Delete", 2, $srvert + 0.8, 6, 3.3)
			GUICtrlSetBkColor($handleselectiondel[$srlinecount], $myblue)
			$srmovelimit = $srlinecount + 1
			If $srmovelimit > $selectionlimit Then $srmovelimit = $srlinecount
			If $selectionarray [$srmovelimit] [$sAutoUser] = "User" Then $srmovelimit = $srlinecount
			If $srlinecount < $srmovelimit Then $handleselectiondown[$srlinecount] = CommonScaleCreate("Label", "↓", 97, $srvert + 3.0, 2, 5)
			GUICtrlSetFont    ($handleselectiondown [$srlinecount], $scalefontsize * 2, 100)
			GUICtrlSetColor   ($handleselectiondown [$srlinecount], $mymedgray)              ; Move Down
			$srhandlelocdown [$srlinecount] = CommonScaleCreate ("Label", "", 97.6, $srvert + 5.5, 0, 0)
			GUICtrlSetState ($srhandlelocdown [$srlinecount], $guihideit)
		EndIf
		If $selectionarray [$srlinecount] [$sMouseUpDown] =  "up"   Then $srmovehandle = $srhandlelocup   [$srlinecount]
		If $selectionarray [$srlinecount] [$sMouseUpDown] =  "down" Then $srmovehandle = $srhandlelocdown [$srlinecount]
		If $selectionarray [$srlinecount] [$sMouseUpDown] <> ""     Then $srmoveupdown = $selectionarray [$srlinecount] [$sMouseUpDown]
    	$selectionarray    [$srlinecount] [$sMouseUpDown] =  ""
	Next
	CommonControlGet ($handleselectiongui, $srmovehandle, $dummyparm)
	$scrollmaxvsize = Int($scalepctvert * ($srvert + 10))
	CommonScrollGenerate ($handleselectionscroll, $scalehsize, $scrollmaxvsize)
	If $srmovehandle <> "" Then _
		CommonScrollMove ($handleselectiongui, $handleselectionscroll, $srmovehandle, $srmoveupdown, 7)
	GUICtrlSetState($buttonselectionapply, $GUI_FOCUS)
	GUISetBkColor($myblue,  $handleselectionscroll)
	GUISetState  (@SW_SHOW, $handleselectionscroll)
	;_Arraydisplay ($selectionarray)
EndFunc

Func SelectionDelete($mdsub)
	If $selectionarray [$mdsub] [$sOSType] = "windows" Then
		$sdrc = MsgBox ($mbwarnyesno, "*** Warning ***", "This will delete your Windows boot entry!" & @CR & @CR & _
			"Are you absolutely sure?")
	    If $sdrc <> $IDYES Then Return
	Else
		$sdrc = MsgBox ($mbinfookcan, '', 'Deleting menu entry number   ' & $mdsub & '   "' &      _
			$selectionarray [$mdsub] [$sEntryTitle] & '"' & @CR & @CR & 'Click OK or Cancel')
		If $sdrc <> $IDOK Then Return
	EndIf
	If $selectionarray [$mdsub] [$sDefaultOS] = "DefaultOS" Then $selectionarray[0][$sDefaultOS] = "DefaultOS"
	_ArrayDelete($selectionarray, $mdsub)
	;SelectionRefresh ()
EndFunc

Func SelectionAdd()
	$editholdarray = $selectionarray
	$custparseholdarray = $custparsearray
	$malimit = UBound($selectionarray)
	If $malimit = 0 Then Dim $selectionarray[1][$selectionfieldcount + 1]
	ReDim $selectionarray[$malimit + 1][$selectionfieldcount + 1]
	$selectionarray[$malimit][$sAutoUser] = "Auto"
	CommonArraySetDefaults($malimit)
	$selectionarray [$malimit] [$sBootParm] = CommonParmCalc ($malimit, "Standard", "Reset")
	SelectionRefresh ()
	EditRunGUI($selectionautohigh)
	$sabump = Int ((Ubound ($selectionarray) / 2))
	If $editnewentry < 6 Then $sabump = 0
	$sanewpos = $sabump * ($editnewentry - 3)
	If $sanewpos < 9 Then $sanewpos = 0
	If _GUIScrollBars_GetScrollInfoPage ($handleselectionscroll, $SB_VERT) < 1 Then Return
	_GUIScrollBars_SetScrollInfoPos     ($handleselectionscroll, $SB_VERT, $sanewpos)
EndFunc

Func SelectionSequenceUpdate ()
	For $msusub = 0 To Ubound ($selectionarray) -1
		If $selectionarray[$msusub][$sAutoUser] = "User" Then
			$selectionarray[$msusub][$sSortSeq] = 9000 + $msusub
		Else
			$selectionarray[$msusub][$sSortSeq] = ($msusub * 100) + 10
			$selectionautohigh  = $msusub
			$selectionautocount = $msusub + 1
		EndIf
	Next
EndFunc

Func SelectionLastBooted ()
	If CommonCheckBox ($handlelastbooted) Then
		$defaultlastbooted = "yes"
	Else
		$defaultlastbooted = "no"
		CommonDefaultSync  ()
	EndIf
	;MsgBox ($mbontop, "Last Booted", $defaultlastbooted)
EndFunc

Func SelectionWinEFI ($mwvertstart)
	_ArraySort ($bcdwinorder, 0, 0, 0, 6)
	$mwlimit = Ubound ($bcdwinorder) - 1
	$mwvert  = ($mwvertstart + 2) - ($mwlimit * 2)
	For $mwsub = 0 To $mwlimit
		$mwline  = "     Instance " & $mwsub + 1 & "     Drive - " & $bcdwinorder [$mwsub] [3]
		$mwline &= "       "           & $bcdwinorder [$mwsub] [1]
		CommonScaleCreate("Label", $mwline, 31, $mwvert, 40, 3)
		$mwvert += 2.5
		If $mwvert - $mwvertstart > 6 Then ExitLoop
	Next
	;_ArrayDisplay ($bcdwinorder, "Win Order   Timeout = " & $bcdprevtime & "  " & $mwvert)
EndFunc