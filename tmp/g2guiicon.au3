#include-once
#include  <g2common.au3>

Func IconRunGUI($imsub)
	IconSetup($imsub)
	IconRefresh($imsub)
	While 1
		$imstatusarray = GUIGetMsg(1)
		If $imstatusarray[1] <> $iconhandlescroll and $imstatusarray[1] <> $iconhandlegui Then ContinueLoop
		$iconstatus = $imstatusarray[0]
		Select
			Case $iconstatus = "" Or $iconstatus = 0
			Case $iconstatus = $GUI_EVENT_CLOSE Or $iconstatus = $iconbuttoncancel
				$selectionarray [$imsub] [$sIcon] = $iconhold
				ExitLoop
			Case $iconstatus = $iconhelphandle
				CommonHelp ("changingtheicon")
				ContinueLoop
			Case $iconstatus = $iconbuttonapply
				ExitLoop
			Case Else
				For $imiconsub = 0 To Ubound ($iconarray) - 1
					If $iconstatus = $iconarray [$imiconsub] [0] Or $iconstatus = $iconarray [$imiconsub] [1] Then
						$selectionarray [$imsub] [$sIcon] = $iconarray [$imiconsub] [2]
						IconRefresh($imsub)
					EndIf
				Next
		EndSelect
	WEnd
	If $iconhandlegui <> "" Then GUIDelete($iconhandlegui)
EndFunc

Func IconSetup($issub)
	$iconhandlegui = GUICreate("Change Icon Menu Slot " & $issub, $scalehsize + 30, ($scalevsize * 0.95), -1, -1, -1, "", $edithandlegui)
	$iconhelphandle   = CommonScaleCreate("Button", "Help", 45, 2, 8, 4)
	$iconbuttoncancel = CommonScaleCreate("Button", "Cancel", 10, 86, 10, 4)
	$iconbuttonapply  = CommonScaleCreate("Button", "Apply",  82, 86, 10, 4)
	$iconhold = $selectionarray [$issub] [$sIcon]
	$istopvspace  = Int ($scalepctvert *  6)
	$isbotvspace  = Int ($scalepctvert * 17)
	$iconhandlescroll = GUICreate("", $scalehsize + 30, ($scalevsize * 0.95) - $isbotvspace, 0, $istopvspace, $WS_CHILD, "", _
		$iconhandlegui)
	GUISwitch($iconhandlescroll)
	GUICtrlSetBkColor ($iconhelphandle, $mymedblue)
	$isvert     = 5
	$ishor      = 7
	Dim $iconarray [1] [3]
	$isiconsub = -1
	$ishandledesc = ""
	FileChangeDir ($iconpath)
	$issearch = FileFindFirstFile ("*.png")
	While 1
		$isfile = FileFindNextFile ($issearch)
		If @error Then ExitLoop
		$isdesc = StringTrimLeft ($isfile, 5)
		$ishandlebutton = CommonBorderCreate _
			($iconpath & "\" & $isfile, $ishor - 1, $isvert - 1.5, 9, 11.5, $ishandledesc, StringTrimRight ($isdesc, 4), 1)
		$isiconsub += 1
		ReDim $iconarray [$isiconsub + 1] [3]
		$iconarray [$isiconsub] [0] = $ishandlebutton
		$iconarray [$isiconsub] [1] = $ishandledesc
		$iconarray [$isiconsub] [2] = StringTrimRight ($isfile, 4)
		$ishor += 20
		If $ishor > 90 Then
			$isvert += 20
			$ishor   = 7
		EndIf
	Wend
	FileClose ($issearch)
	$iconscrollpos = CommonControlGet ($iconhandlegui, $iconhandlescroll, $dummyparm)
	$icondescpos   = CommonControlGet ($iconhandlegui, $ishandledesc, $dummyparm)
	CommonScrollGenerate ($iconhandlescroll, $scalehsize, $icondescpos - $iconscrollpos + 10)
EndFunc

Func IconRefresh($irsub)
	Local $irhandlemove
	For $iriconsub = 0 To Ubound ($iconarray) - 1
		$irhandlebutton = $iconarray [$iriconsub] [0]
		$irhandledesc   = $iconarray [$iriconsub] [1]
		$irdesc         = $iconarray [$iriconsub] [2]
		GUICtrlSetBkColor ($irhandlebutton, $mygreen)
		If $selectionarray [$irsub] [$sIcon] = $irdesc Then
			GUICtrlSetBKColor ($irhandlebutton, $myred)
			$irhandlemove = $irhandledesc
		EndIf
	Next
    IconScrollMove ($iconhandlegui, $iconhandlescroll, $irhandlemove, 6)
	GUICtrlSetState($iconbuttonapply, $GUI_FOCUS)
	GUISetBkColor($mygreen, $iconhandlescroll)
	GUISetBkColor($mygreen, $iconhandlegui)
	GUISetState(@SW_SHOW, $iconhandlescroll)
	GUISetState(@SW_SHOW, $iconhandlegui)
EndFunc

Func IconScrollMove ($smhandlewindow, $smhandlescroll, $smhandlecontrol, $smminbumppos)
	$smtag         = _GUIScrollBars_GetScrollBarInfoEx($smhandlescroll, $OBJID_VSCROLL)
	$smscrollvtop  =  DllStructGetData ($smtag, "Top")
	$smscrollvbot  =  DllStructGetData ($smtag, "Bottom")
	If $smscrollvbot < 1 Then Return
	$smmaxpos      = _GUIScrollBars_GetScrollInfoMax  ($smhandlescroll, $SB_VERT)
	$smbumppos     = Int ($smmaxpos * .10)
	$smrangev      = $smscrollvbot - $smscrollvtop
	$smlimtopv     = Int (0.45 * $smrangev) + $smscrollvtop
	$smlimbotv     = Int (0.75 * $smrangev) + $smscrollvtop
	If $smbumppos  < $smminbumppos Then $smbumppos = $smminbumppos
	$smtoppos      = _GUIScrollBars_GetScrollInfoPos ($smhandlescroll, $SB_VERT)
	$smoldtoppos   = $smtoppos
	DO
		$smcontrolabs    = CommonControlGet ($smhandlewindow, $smhandlecontrol, $dummyparm)
		If $smcontrolabs > $smlimbotv Then $smtoppos += $smbumppos
		If $smcontrolabs < $smlimtopv Then $smtoppos -= $smbumppos
		;MsgBox ($mbontop, "Control " & $smcontrolabs, $smlimtopv & @CR & $smlimbotv & @CR & $smbumppos & @CR & $smpagepos & @CR & $smtoppos)
		If $smtoppos < $smminbumppos Then $smtoppos = 0
	    If $smtoppos = $smoldtoppos  Then ExitLoop
		$smoldtoppos = $smtoppos
	    _GUIScrollBars_SetScrollInfoPos ($smhandlescroll, $SB_VERT, $smtoppos)
	Until $smtoppos > $smmaxpos Or $smtoppos < 1
EndFunc