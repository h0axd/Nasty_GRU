#include-once
#include  <g2common.au3>
#include  <g2bcd.au3>

Func FirmOrderRunGUI ($omheader, ByRef $omarray, ByRef $omdisplay)
	If $handlemaingui <> "" Then WinSetState ($handlemaingui, "", @SW_MINIMIZE)
	$omholdarray = $omarray
	FirmOrderRefresh ($omheader, $omarray, $omdisplay, "no")
	$ordercurrentstring = $omdisplay
	While 1
		$omstatusarray = GUIGetMsg (1)
		If $omstatusarray[1] <> $handleordergui And $omstatusarray[1] <> $handleorderscroll Then ContinueLoop
		$omstatus = $omstatusarray[0]
		Select
			Case $omstatus = $buttonorderreturn
				$omarray = $omholdarray
				If $handleordergui <> "" Then GUIDelete   ($handleordergui)
				If $handlemaingui  <> "" Then WinSetState ($handlemaingui, "", @SW_RESTORE)
				$handleordergui     = ""
				Return
			Case $omstatus = $buttonorderapply
				If $omarray [0] [$bItemType] = $firmgrub Then $bcdtestboot = ""
				$omholdarray = BCDSetFirmOrder ()
			Case $omstatus = "" Or $omstatus < 1
				ContinueLoop
			Case $omstatus = $orderhelphandle
				CommonHelp ("EFIfirmwareorder")
				ContinueLoop
			Case Else
				For $omlinecount = 0 To Ubound ($omarray) - 1
					$omtitle = $omarray[$omlinecount][$bItemTitle]
					Select
						Case $omstatus = $handleorderup   [$omlinecount]
							$omarray[$omlinecount][$bSortSeq]     -= 110
							$omarray[$omlinecount][$bUpdateFlag]   = "moved"
							$omarray[$omlinecount][$bMouseUpDown]  = "up"     ; Mouse Up
						Case $omstatus = $handleorderdown [$omlinecount]
							$omarray[$omlinecount][$bSortSeq]     += 110
							$omarray[$omlinecount][$bUpdateFlag]   = "moved"
							$omarray[$omlinecount][$bMouseUpDown]  = "down"   ; Mouse Down
						Case $omstatus = $handleorderdefault [$omlinecount]
							$omarray[$omlinecount][$bSortSeq]  = 99
							$omarray[$omlinecount][$bUpdateFlag]  = "default"
							$omdefmsg  = 'When you click "OK" your firmware default will be' & @CR
							$omdefmsg &= 'set to run ' & $omtitle & ' every time you boot your PC' & @CR & @CR
							$omdefrc  = MsgBox ($mbinfookcan, "Set " & $omtitle & " As Default", $omdefmsg)
							If $omdefrc <> $IDOK Then
								MsgBox ($mbinfook, "", "Set " & $omtitle & " as default has been cancelled", 5)
								$omarray = $omholdarray
								ContinueLoop
							EndIF
							$orderfirmdisplay = BCDOrderSort    ($omarray)
							$omholdarray      = BCDSetFirmOrder ()
						Case $omstatus =  $handleordertest   [$omlinecount]
							$omtestmsg  = 'When you click "OK" your firmware will be set to' & @CR
							$omtestmsg &= 'run  ' & $omtitle & ' the next time you boot your PC.' & @CR & @CR
							$omtestmsg &= 'This is a one time boot test. Your PC will then' & @CR
							$omtestmsg &= 'return to the normal firmware boot order.' & @CR
							$omtestrc  = MsgBox ($mbinfookcan, $omtitle & " Firmware Test", $omtestmsg)
							If $omtestrc <> $IDOK Then
								MsgBox ($mbinfook, "", "The " & $omtitle & " firware test was cancelled", 5)
								ContinueLoop
							EndIF
							$omholdarray = $omarray
							BCDSetupTest ()
						Case $omstatus =  $handleordernotest [$omlinecount]
							BCDCancelTest ()
						Case Else
							ContinueLoop
					EndSelect
				Next
		EndSelect
		FirmOrderRefresh ($omheader, $omarray, $omdisplay)
	WEnd
EndFunc

Func FirmSetupParent ($spheader, ByRef $sparray)
	If $handleordergui <> "" Then GuiDelete ($handleordergui)
	$spheader &= "                           Slots = " & Ubound ($sparray)
	$handleordergui = GUICreate ($spheader , $scalehsize + 38, $scalevsize + 33, -1, -1, $WS_EX_STATICEDGE, -1, $handlemaingui)
	$orderhelphandle   = CommonScaleCreate ("Button", "Help", 90, 2, 8, 3.5)
	GUICtrlSetBkColor ($orderhelphandle, $mymedblue)
	$buttonorderreturn = CommonScaleCreate ("Button", "",  7, 92, 22, 3.5)
	$buttonorderapply  = CommonScaleCreate ("Button", "Apply Updates", 70, 92, 22, 3.5)
	;Msgbox ($mbontop, "Compare", "Original - " & $ordercurrentstring & @CR & "New - " & $spdisplay)
	GUISetBkColor ($mymedblue, $handleordergui)
	GUISetState   (@SW_SHOW,   $handleordergui)
	GUISwitch     ($handleorderscroll)
EndFunc

Func FirmOrderRefresh ($orheader, ByRef $orarray, ByRef $ordisplay, $orapplybutton = "yes")
	;_ArrayDisplay ($orarray)
	;MsgBox ($mbontop, "Refresh", "")
	$ordisplay = BCDOrderSort ($orarray)
	$ormovehandle       = ""
	$ormoveupdown       = ""
	$ortopvspace        = Int ($scalepctvert *  8)
	$orbotvspace        = Int ($scalepctvert * 20)
	If $handleordergui  = "" Then FirmSetupParent ($orheader, $orarray)
	If $orapplybutton = "no" Or $ordercurrentstring = $ordisplay Then
		GUICtrlSetState ($buttonorderapply,  $guihideit)
		GUICtrlSetState ($buttonorderreturn, $GUI_FOCUS)
		GuiCtrlSetData  ($buttonorderreturn, "Return To The Main Menu")
	Else
		GUICtrlSetState ($buttonorderapply,  $guishowit)
		GuiCtrlSetData  ($buttonorderreturn, "Cancel Pending Updates")
		GUICtrlSetState ($buttonorderapply,  $GUI_FOCUS)
	EndIf
	$scrolltoppos = CommonScrollDelete ($handleorderscroll)
	$handleorderscroll = GUICreate("" , $scalehsize + 30, $scalevsize - $orbotvspace, 0, $ortopvspace, $WS_CHILD, "", _
		$handleordergui)
	$orlimit = Ubound ($orarray)
	Dim $orhandlelocup      [$orlimit]
	Dim $orhandlelocdown    [$orlimit]
	Dim $handleorderup      [$orlimit]
	Dim $handleorderdown    [$orlimit]
	Dim $handleorderdesc    [$orlimit]
	Dim $handleorderpath    [$orlimit]
	Dim $handleorderdefault [$orlimit]
	Dim $handleordertest    [$orlimit]
	Dim $handleordernotest  [$orlimit]
	Dim $handleordergroup   [$orlimit]
	#forceref $handleorderpath
	$orlimit -= 1
	;_ArrayDisplay ($orarray)
	For $orlinecount = 0 To $orlimit
		If $orlinecount > $orlimit Or $orarray [$orlinecount] [$bItemType] = "" Then ExitLoop
		$orgrouphighlight = ""
		$orvert   = ($orlinecount * 10) + 5
		$orgroup  = "Windows instance "
		$orgroup  = "EFI firmware slot "
		$orgroup &= $orlinecount + 1
		$ordesc   = $orarray[$orlinecount][$bItemTitle] & @TAB
		$orpath   = "  Path = " & $orarray[$orlinecount][$bDrive] & StringLeft ($orarray[$orlinecount][$bPath], 40)
		If $orarray [$orlinecount] [$bItemType] = "firm-bootdevice" Then $orpath = "  Boot = Disk device"
		$handleorderpath [$orlinecount] = CommonScaleCreate ("Label", $orpath,   48, $orvert - 1.0 , 50, 3)
		If $orlinecount <> 0 And $orarray [$orlinecount] [$bItemType] = $firmgrub Then
			$handleorderdesc    [$orlinecount] = CommonScaleCreate ("Label", $ordesc,  18, $orvert - 1.0 , 14,  3)
			$handleorderdefault [$orlinecount] = CommonScaleCreate ("Button", "Set Grub2Win As Default", 32.5, $orvert + 0.4 , 16, 3.1)
			GUICtrlSetBkColor($handleorderdefault [$orlinecount], $myyellow)
			GUICtrlSetFont   ($handleorderdefault [$orlinecount], $scalefontsize * 0.8)
			If $bcdtestboot = "yes" Then
				$orgroup &= "          ** Grub2Win Test Will Run One Time On The Next Boot **   "
				$orgrouphighlight = "yes"
				$handleordernotest [$orlinecount] = CommonScaleCreate ("Button", "Cancel The Test Boot",  2, $orvert + 0.4 , 15, 3.1)
				GUICtrlSetBkColor($handleordernotest [$orlinecount], $myyellow)
				GUICtrlSetFont   ($handleordernotest [$orlinecount], $scalefontsize * 0.8)
			Else
				$handleordertest [$orlinecount] = CommonScaleCreate ("Button", "Request A Test Boot",     2, $orvert + 0.4 , 15, 3.1)
				GUICtrlSetBkColor($handleordertest [$orlinecount], $mygreen)
				GUICtrlSetFont   ($handleordertest [$orlinecount], $scalefontsize * 0.8)
			EndIf
		Else
			$handleorderdesc [$orlinecount] = CommonScaleCreate ("Label", $ordesc, 18, $orvert - 1.0 , 27, 4.5)
		EndIf
		If $orlinecount = 0 Then
			$orgroup &= "          " & BasicCapIt ($orarray[$orlinecount][1]) & " Is The Default Firmware Boot Manager   "
			If $orarray [0] [0] = $firmgrub Then $orgrouphighlight = "yes"
		EndIf
		If $orarray [$orlinecount] [$bItemType] = $firmgrub Then $orderfirmboot = $orarray [$orlinecount] [$bGUID]
		If $orarray [$orlinecount] [$bUpdateFlag] = "moved"   Then  GUICtrlSetBkColor($handleorderdesc [$orlinecount], $myorange)
		If $orarray [$orlinecount] [$bUpdateFlag] = "default" Then	GUICtrlSetBkColor($handleorderdesc [$orlinecount], $mygreen)
		$orarray    [$orlinecount] [$bUpdateHold] = $orarray [$orlinecount] [$bUpdateFlag]
		                 $handleorderup   [$orlinecount] = CommonScaleCreate("Label", "↑", 92, $orvert - 3.9, 2, 3.9)
		GUICtrlSetFont  ($handleorderup   [$orlinecount], $scalefontsize * 1.7, 100)
		GUICtrlSetColor ($handleorderup   [$orlinecount], $mylightgray) ; Move Up
		$orhandlelocup  [$orlinecount] = CommonScaleCreate("Label", "", 92.6, $orvert - 1.7, 0, 0)
		;GUICtrlSetGraphic ($orhandlelocup  [$orlinecount], $GUI_GR_Pixel, 1,1)
		;GUICtrlSetBkColor ($orhandlelocup  [$orlinecount], $myred) ; Move Up Pixel
		GUICtrlSetState ($orhandlelocup [$orlinecount], $guihideit)
		                 $handleorderdown  [$orlinecount] = CommonScaleCreate("Label", "↓", 92, $orvert + 0.2, 2, 3.9)
		GUICtrlSetFont  ($handleorderdown  [$orlinecount], $scalefontsize * 1.7, 100)
		GUICtrlSetColor ($handleorderdown  [$orlinecount], $mylightgray) ; Move Down
		$orhandlelocdown  [$orlinecount] = CommonScaleCreate("Label", "", 92.6, $orvert +2.3, 0, 0)
		;GUICtrlSetGraphic ($orhandlelocdown  [$orlinecount], $GUI_GR_Pixel, 1,1)
		;GUICtrlSetBkColor ($orhandlelocdown  [$orlinecount], $myred) ; Move Down Pixel
		GUICtrlSetState   ($orhandlelocdown  [$orlinecount], $guihideit)
		If $orlinecount < 1 Then GUICtrlSetState ($handleorderup [$orlinecount], $guihideit)
		If $orlinecount >= $orlimit Then GUICtrlSetState ($handleorderdown [$orlinecount], $guihideit)
		If $orarray [$orlinecount] [$bMouseUpDown] =  "up"   Then $ormovehandle = $orhandlelocup          [$orlinecount]
		If $orarray [$orlinecount] [$bMouseUpDown] =  "down" Then $ormovehandle = $orhandlelocdown        [$orlinecount]
		If $orarray [$orlinecount] [$bMouseUpDown] <> ""     Then $ormoveupdown = $orarray [$orlinecount] [$bMouseUpDown]
		   $orarray [$orlinecount] [$bMouseUpDown] =  ""
		$handleordergroup [$orlinecount] = CommonScaleCreate ("Group", $orgroup,  1, $orvert - 4, 88, 8)
		If $orgrouphighlight = "yes" Then GUICtrlSetBkColor ($handleordergroup [$orlinecount], $mygreen)
		$orarray [$orlinecount][$bSortSeq] = ($orlinecount + 1) * 100
	Next
	;_ArrayDisplay ($orarray, $ormovehandle & "  " & $orhandlelocdown  [1])
	CommonControlGet ($handleordergui, $ormovehandle, $dummyparm)
	$scrollmaxvsize = Int ($scalepctvert * ($orvert) + 25)
	CommonScrollGenerate ($handleorderscroll, $scalehsize, $scrollmaxvsize)
	If $ormovehandle <> "" Then _
		CommonScrollMove ($handleordergui, $handleorderscroll, $ormovehandle, $ormoveupdown, 4)
	GUISetBkColor ($mymedblue, $handleorderscroll)
	GUISetState   (@SW_SHOW,    $handleorderscroll)
EndFunc