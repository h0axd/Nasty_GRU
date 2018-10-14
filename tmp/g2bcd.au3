#include-once
#include <g2common.au3>
#include <g2backrest.au3>
#include <g2language.au3>

Const  $bcdfieldcount =  10
Const  $bItemType     =  0, $bItemTitle    =  1, $bGUID       =  2, $bDrive      =  3, $bPath        =  4      ; Array subscripts
Const  $bWindefault   =  5, $bSortSeq      =  6, $bUpdateFlag =  7, $bItemTitle2 =  8, $bMouseUpDown =  9, $bUpdateHold = 10

Const  $oldloaderarray  [3] = ["grub2win.boot64.efi", "grub2win.boot32.efi", "grub2win.boot.bios"] ; Compat - Clear on 12/31/2018

Dim    $bcdcleanuparray [1]

Func BCDGetBootArray ($gbacheck = "")
	If $bootos = $xpstring Then Return
	$ordercurrentstring = $orderfirmdisplay
	Dim $bootarray [0] [$bcdfieldcount + 1]
	CommonBCDRun  ("/v", "detail")
	$bcdwinorder  = BCDParseBootArray ("winboot")
	CommonBCDRun  ("/enum firmware", "firmware")
	$bcdfirmorder = BCDParseBootArray ("firmware")
	If $gbacheck  = "" Then Return 0
	$bcdwindisplayorig = BCDOrderSort ($bcdwinorder)
EndFunc

Func BCDParseBootArray ($efityperun)
	Local $pbacurrid, $pbacurrpath, $pbacurrtype, $pbacurrdesc, $pbacurrletter
	Local $pbaskip, $pbaorderfound, $pbaworkorder, $pbadefault, $pbabootseq, $pbatranidfound
	Dim $pbaworkorder [0] [$bcdfieldcount + 1]
	$bcdtestboot   = ""
	$bcdgrubbootid = ""
	$pbaprevline   = ""
	$bcdarray = $runarray
	$bcdbound = UBound ($bcdarray) - 1
	For $bcdsub = 1 To $bcdbound
		$pbaline = $bcdarray [$bcdsub]
		If StringLeft  ($pbaline, 1) <> " " Then $pbaorderfound = "no"
		Select
			Case StringLeft   ($pbaprevline, 5) = $bcddashline And StringInStr ($pbaline, "{") And StringInStr ($pbaline, "}")
				$pbatranidfound = "yes"
				BCDBreak ($pbacurrtype, $pbacurrdesc, $pbacurrid, $pbacurrletter, $pbacurrpath)
				$pbacurrtype = "firm-os"
				If StringInStr ($pbaline, "{fwbootmgr}") Then $pbacurrtype = "firm-bootmgr"
				$pbacurrid   = BCDParseID ($pbaline)
				$pbacurrpath = ""
				$pbacurrdesc = ""
				$pbaskip     = ""
				If StringInStr ($pbaline, "{bootmgr}")   Then
					$pbaskip     = "yes"
					$pbacurrtype = ""
				EndIf
				;Msgbox ($mbontop, "ID", $pbaline & @CR & $pbacurrtype & @CR & $pbaskip)
			Case StringLeft ($pbaline, 11) = "description"
				$pbacurrdesc = BCDParseLine ($pbaline, "description")
			Case $pbaskip = "yes"
			Case StringLeft  ($pbaline, 12) = "displayorder"
				$pbaorderfound = "yes"
			Case StringLeft  ($pbaline,  6) = "device"
				$pbaline = BCDParseLine ($pbaline, "device")
				$pbaline = BCDParseLine ($pbaline, "partition=")
				If StringLen ($pbaline) = 2 Then $pbacurrletter = $pbaline
			Case StringLeft ($pbaline, 4)  = "path"
				$pbacurrpath = BCDParseLine ($pbaline, "path")
				If StringInStr ($pbacurrpath, $bootmanefi) Then
					$pbacurrtype   = $firmgrub
				    $bcdgrubbootid = $pbacurrid
				EndIf
				If StringInStr ($pbacurrpath, $winbootmgr) Then
					$pbacurrtype = "firm-winbootmgr"
					If $efityperun <> "firmware" Then $bcdwinbootid = $pbacurrid
				EndIf
				If StringInStr ($pbacurrpath, $winloaderefi) Then $pbacurrtype = "win-instance"
			Case StringLeft ($pbaline,  7)  = "default"
				$pbadefault = BCDParseID ($pbaline)
			Case StringLeft ($pbaline, 12)  = "bootsequence" And $pbacurrtype = "firm-bootmgr"
				$pbabootseq = BCDParseID ($pbaline)
			Case StringLeft  ($pbaline,  7) = "timeout" And $efityperun <> "firmware"
				$bcdprevtime = BCDParseLine ($pbaline, "timeout")
				$timewinboot = $bcdprevtime
		EndSelect
		;MsgBox ($mbontop, "Ord", $pbaline & @cr & $pbaorderfound)
		If $pbaorderfound = "yes" Then
			$pbaordersub = Ubound ($pbaworkorder)
			ReDim $pbaworkorder [$pbaordersub + 1] [$bcdfieldcount + 1]
			$pbaworkorder [$pbaordersub] [$bGUID] = BCDParseID ($pbaline)
		EndIf
		$pbaprevline = $pbaline
	Next
	If $pbabootseq = $bcdgrubbootid Then $bcdtestboot = "yes"
	;_ArrayDisplay ($pbaworkorder, "before " & $efityperun)
	BCDBreak    ($pbacurrtype, $pbacurrdesc, $pbacurrid, $pbacurrletter, $pbacurrpath)
	BCDPopulate ($efityperun,  $pbadefault,  $pbaworkorder)
	If $firmwaremode = "EFI" And $efityperun = "winboot" Then BCDWinOnly ($pbaworkorder)
	If $pbatranidfound = "" Then
		CommonDiagnose   ("BCD Ident not found " & $langheader)
		If $diagcomplete = "" Then MsgBox ($mbwarnok, _
			"BCD Ident Error", "** The Grub2Win Diagnostics output files are in " & $basepath & "\diagnose **")
		CommonWriteLog ("** Grub2Win Is Cancelled **", 1, "yes", "")
		Exit
	EndIf
	Return $pbaworkorder
EndFunc

Func BCDPopulate ($bptyperun, $bfpdefault, ByRef $bfparray)
	$bfpsub  = 0
	Local $bfpwinloc, $bfpgrubloc
	While Ubound ($bfparray) > 0 And $bfpsub <= Ubound ($bfparray) - 1
		If $bfparray [$bfpsub] [$bGUID] = "{bootmgr}" Then $bfparray [$bfpsub] [$bGUID] = $bcdwinbootid
		$bfploc = _ArraySearch ($bootarray, $bfparray [$bfpsub] [2], 0, 0, 0, 0, 1, 2)
		If $bfploc < 0 Then
			_ArrayDelete ($bfparray, $bfpsub)
			ContinueLoop
		EndIf
		$bfparray [$bfpsub] [$bItemType]   = $bootarray [$bfploc] [$bItemType]
		$bfparray [$bfpsub] [$bItemTitle]  = $bootarray [$bfploc] [$bItemTitle]
		$bfparray [$bfpsub] [$bItemTitle2] = $bootarray [$bfploc] [$bItemTitle]
		$bfparray [$bfpsub] [$bDrive]      = $bootarray [$bfploc] [$bDrive]
		$bfparray [$bfpsub] [$bPath]       = $bootarray [$bfploc] [$bPath]
		$bfparray [$bfpsub] [$bSortSeq]    = ($bfpsub + 1) * 100
		If $bfparray  [$bfpsub] [$bItemType]  = "firm-winbootmgr" Then
			$bfparray [$bfpsub] [$bItemTitle] = "Windows EFI Boot Manager"
			$bfpwinloc = $bfpsub
		EndIf
		If $bfparray  [$bfpsub] [$bItemType]   = $firmgrub Then $bfpgrubloc = $bfpsub
		If $bfparray  [$bfpsub] [$bGUID]       = $bfpdefault       Then
			$bfparray [$bfpsub] [$bWinDefault] = "win-default"
			$bfparray [$bfpsub] [$bSortSeq]    = 99
		EndIf
		If $bfparray [$bfpsub] [$bPath] = "" Then $bfparray [$bfpsub] [0] = "firm-bootdevice"
		$bfpsub += 1
	Wend
	If $bptyperun = "firmware" Then BCDFirmwareFloat ($bfpwinloc, $bfpgrubloc, $bfparray)
EndFunc

Func BCDFirmwareFloat ($bffwinloc, $bffgrubloc, ByRef $bfforder, $bffmaxslot = 6)
	;_ArrayDisplay ($bfforder, "Before   W " & $bffwinloc & "        G " & $bffgrubloc)
	$bfflimit = Ubound ($bfforder) -1
	If $bfflimit < $bffmaxslot Then Return
	$bffoffset = $bffmaxslot * 100
	Select
		Case $bffwinloc  >= $bffmaxslot And $bffgrubloc > $bffmaxslot
			$bfforder [$bffwinloc]  [$bSortSeq] = $bffoffset + 50
			$bfforder [$bffgrubloc] [$bSortSeq] = $bffoffset + 75
		Case $bffwinloc  >  $bffmaxslot
			$bfforder [$bffwinloc]  [$bSortSeq] = $bffoffset + 50
		Case $bffgrubloc >  $bffmaxslot
			$bfforder [$bffgrubloc] [$bSortSeq] = $bffoffset + 75
	EndSelect
	_ArraySort ($bfforder, 0, 0, 0, 6)
	;_ArrayDisplay ($bfforder, "After   W " & $bffwinloc & "        G " & $bffgrubloc)
	For $bffsub = 0 To $bfflimit
		$bfforder [$bffsub] [$bSortSeq] = ($bffsub + 1) * 100
	Next
EndFunc

Func BCDBreak ($bbtype, $bbdesc, $bbid, $bbletter, $bbpath)
	If $bbtype = "" Then Return
	$bbsub = Ubound ($bootarray)
	ReDim $bootarray [$bbsub + 1] [$bcdfieldcount + 1]
	$bootarray [$bbsub] [$bItemType]  = $bbtype
	$bootarray [$bbsub] [$bItemTitle] = $bbdesc
	$bootarray [$bbsub] [$bGUID]      = $bbid
	$bootarray [$bbsub] [$bDrive]     = $bbletter
	$bootarray [$bbsub] [$bPath]      = $bbpath
EndFunc

Func BCDOrderSort (ByRef $bosarray)
	$bosdisplay = ""
	_ArraySort ($bosarray, 0, 0, 0, $bSortSeq)
	For $boslinecount = 0 To Ubound ($bosarray) - 1
		If $bosarray [$boslinecount] [0] = "" Then ExitLoop
		If StringInStr ($bosdisplay, $bosarray [$boslinecount] [$bGUID]) Then ContinueLoop
		$bosdisplay &= " " & $bosarray [$boslinecount] [$bGUID]
	Next
	;MsgBox ($mbontop, "BOS", $bosdisplay)
	Return $bosdisplay
EndFunc

Func BCDGetUpdateMessage (ByRef $gumarray, $gumgetgrub = "")
	Local $gumgrubslot = "no", $gumupdateslot, $gummessage
	For $gumsub = 0 To Ubound ($gumarray) - 1
		If $gumgetgrub <> "" And $gumarray [$gumsub] [$bItemType] = $firmgrub Then $gumgrubslot = $gumsub
		If $gumarray [$gumsub] [$bUpdateHold] <> "" Then $gumupdateslot = $gumsub
	Next
	If $gumgrubslot <> "no" Then Return "Grub2Win Will Boot From EFI Firmware Slot " & $gumgrubslot + 1
	If $gumarray [$gumupdateslot] [$bUpdateHold] = "moved" Then _
	    $gummessage = "    Slot " & $gumupdateslot + 1 & ' Is Now "' & $gumarray [$gumupdateslot] [$bItemTitle] & '"'
	If $gumarray [$gumupdateslot] [$bUpdateFlag] = "default" Then _
	    $gummessage = "     ** " & $gumarray [$gumupdateslot] [$bItemTitle] & " In Now The Default **"
	Return $gummessage
EndFunc

Func BCDGetPreviousBIOS ()
	CommonBCDRun ("/v", "getdetail")
	$bgparray = $runarray
	Local $bgpcurrpath, $bgpcurrdrive
	For $sub = 1 To UBound($bgparray) - 1
		$bgpline = $bgparray[$sub]
		$bgpline = StringStripWS($bgpline, 3)
		Select
			Case StringLeft($bgpline, 7)  = "device "
				$bgpstring     = StringInStr($bgpline, "partition=")
				$bgpcurrdrive  = StringMid($bgpline, $bgpstring + 10, 2)
			Case StringLeft($bgpline, 5) = "path "
				$bgpstring    = StringTrimLeft ($bgpline, 5)
				$bgpcurrpath  = StringStripWS  ($bgpstring, 1)
				;MsgBox ($mbontop, "Path", $bgpcurrpath & @CR & $loadergrubbios & @CR & $bgpcurrdrive)
				If StringInStr ($bgpcurrpath, $bootloaderbios) And $bgpcurrdrive = $basedrive Then
					$biosprevfound = "yes"
					Return 0
				EndIf
			Case StringLeft($bgpline, 8) = "timeout "
				$bgpstring    = StringTrimLeft($bgpline, 8)
				$biosprevtime = StringStripWS($bgpstring, 1)
				$timewinboot  = $biosprevtime
		EndSelect
	Next
	Return 0
EndFunc

Func BCDSetupEFI ($bsbits)
	CommonBCDRun ('/copy {bootmgr} /d "Grub2Win EFI - ' & $bsbits & ' Bit"', "create")
	$bcdnewid = BCDParseID ($runarray [0])
    ;_ArrayDisplay ($runarray, "After Create")
	CommonBCDRun ('/set ' & $bcdnewid & ' path \EFI\grub2win\' & $bootmanefi, "path")
	;_ArrayDisplay ($runarray, "After path")
	CommonBCDRun ('/deletevalue ' & $bcdnewid & ' timeout',           "createtimeout", "")
	CommonBCDRun ('/deletevalue ' & $bcdnewid & ' locale',            "createlocale", "")
	CommonBCDRun ('/deletevalue ' & $bcdnewid & ' default',           "createdefault", "")
	CommonBCDRun ('/deletevalue ' & $bcdnewid & ' resumeobject',      "createresume", "")
	CommonBCDRun ('/deletevalue ' & $bcdnewid & ' displayorder',      "createdisplayorder", "")
	CommonBCDRun ('/deletevalue ' & $bcdnewid & ' toolsdisplayorder', "createtoolsdisplayorder", "")
	CommonBCDRun ('/deletevalue ' & $bcdnewid & ' displaybootmenu',   "createdisplaymenu", "")
	CommonBCDRun ('/deletevalue ' & $bcdnewid & ' integrityservices', "createintegrity", "")
	CommonBCDRun ('/deletevalue ' & $bcdnewid & ' flightsigning',     "createflightsigning", "")
	If CommonParms ($actionsilent) Then
		CommonBCDRun ('/set {fwbootmgr} displayorder ' & $bcdnewid & ' /addfirst', "createaddfirst")
	Else
	    CommonBCDRun ('/set {fwbootmgr} displayorder ' & $bcdnewid & ' /addlast',  "createaddlast")
	EndIF
	CommonBCDRun ('/set {fwbootmgr} bootsequence ' & $bcdnewid, "createbootseq")
	BCDGetBootArray ()
	Return $bcdnewid
EndFunc

Func BCDSetFirmOrder ()
	BackupMake ()
	GUICtrlSetState     ($buttonorderapply, $guihideit)
	CommonUpdateMessage ("Updating The EFI Firmware Order")
	$bsfmessage = BCDGetUpdateMessage ($bcdfirmorder)
	CommonBCDRun        ('/set {fwbootmgr} displayorder ' & $orderfirmdisplay, "setorder")
	If $bcdfirmorder [0] [0] = $firmgrub Then CommonBCDRun ('/deletevalue {fwbootmgr} bootsequence', "firmdelbootseq", "")
	BCDGetBootArray ()
	CommonUpdateMessage ()
	CommonWriteLog ()
	CommonWriteLog ("    The EFI Firmware Boot Order Slots Have Changed")
	If $bsfmessage <> "" Then CommonWriteLog ($bsfmessage)
	Return $bcdfirmorder
	;_ArrayDisplay ($bcdfirmorder, "After Firmware set displayorder")
EndFunc

Func BCDSetWinOrderEFI ()
	$bswdisplay = BCDOrderSort ($bcdwinorder)
	$bswdefault = $bcdwinorder [0] [$bGUID]
	If $bswdisplay = $bcdwindisplayorig Then Return
	;MsgBox ($mbontop, "WINORD", "Default " & $bswdefault & @CR & @CR & "Display Order " & $bswdisplay)
	CommonBCDRun   ('/set {bootmgr} displayorder ' & $bswdisplay, "setorder")
	CommonBCDRun   ('/set {bootmgr} default      ' & $bswdefault, "setdefault")
	CommonWriteLog ()
	CommonWriteLog ("                  The Windows Boot Order Has Been Updated")
EndFunc

Func BCDSetWinDescEFI ()
	;_ArrayDisplay ($bcdwinorder, "Desc")
	For $bswsub = 0 To Ubound ($bcdwinorder) - 1
		If $bcdwinorder [$bswsub] [$bItemTitle] = $bcdwinorder [$bswsub] [$bItemTitle2] Then ContinueLoop
		CommonBCDRun   ('/set ' & $bcdwinorder [$bswsub] [$bGUID] & ' description "' & _
		    $bcdwinorder [$bswsub] [$bItemTitle] & '"', "setwindesc")
		CommonWriteLog ('        The Windows Boot Description   "' & $bcdwinorder [$bswsub] [1] & '"  Has Been Updated')
	Next
EndFunc

Func BCDSetWinTimeout ($swtimeout)
	If $swtimeout = $bcdprevtime Then
		CommonWriteLog ()
		CommonWriteLog ("          The Windows boot timeout is " & $swtimeout & " seconds")
	Else
		CommonBCDRun   ("/timeout " & $swtimeout, "settimeout")
		CommonWriteLog ()
		CommonWriteLog ("          The Windows boot timeout is now " & $swtimeout & " seconds")
	EndIf
EndFunc

Func BCDSetupTest ()
	CommonUpdateMessage ("Setting Up A Grub2Win Boot Test")
	CommonBCDRun ('/set {fwbootmgr} displayorder ' & $orderfirmdisplay, "setuptest")
	BCDSetBootsequence ($bcdgrubbootid, "setuptest")
	CommonWriteLog ()
	CommonWriteLog ("                  A Grub2Win Boot Test Has Been Set Up")
	CommonUpdateMessage ()
	;_ArrayDisplay ($runarray, "After Firmware set displayorder")
EndFunc

Func BCDSetBootsequence ($bsbid, $bsbsource)
	If $bcdfirmorder [0] [$bItemType] = $firmgrub Then Return
	CommonBCDRun ('/set {fwbootmgr}  bootsequence ' & $bsbid, "bootseq-" & $bsbsource)
	BCDGetBootArray ()
EndFunc

Func BCDCancelTest ()
	CommonUpdateMessage ("Cancelling The Grub2Win Boot Test")
	CommonBCDRun ('/set {fwbootmgr} displayorder ' & $orderfirmdisplay, "resetorder")
	CommonBCDRun ('/deletevalue {fwbootmgr} bootsequence',            "canceldelbootseq", "")
	BCDGetBootArray ()
	CommonWriteLog ()
	CommonWriteLog ("                  The Grub2Win Boot Test Was Cancelled")
	CommonUpdateMessage ()
	;_ArrayDisplay ($runarray, "After Firmware set displayorder")
EndFunc

Func BCDSetupBIOS ($sbtimeout = $timewinboot, $sbsetup = "yes")
	BCDSetWinTimeout ($sbtimeout)
	If $biosprevfound = "yes" And $sbtimeout = $bcdprevtime Then
		If $sbsetup = "yes" Then CommonWriteLog ("          The Grub2Win BCD entry already exists. No BCD changes are required.", 2)
		Return 0
	EndIf
	If $biosprevfound = "yes" Then
		If $sbsetup = "yes" Then CommonWriteLog ("               The Grub2Win BCD entry already exists. No new entry is required.")
		Return 0
	EndIf
	BCDCleanup ()
	CommonWriteLog("                Adding the new Grub2Win entry to the BCD for " & $basedrive & "\" & $biosbootstring)
	CommonWriteLog('                  The title is -  "' & $biosdesc & '"')
	$bsbrc = CommonBCDRun(' /create /d "' & $biosdesc & '" /application bootsector', "biosentry")
	If $bsbrc <> 0 Then Return 1
	$newcheck = $runarray[0]
	$bcdnewid = BCDParseId($newcheck)
	If $bcdnewid <> "" Then
		CommonWriteLog ("                   BCD ID " & $bcdnewid & " was successfully created", 2)
		CommonBCDRun   ("/set " & $bcdnewid & " device partition=" & $basedrive, "biospart")
		CommonBCDRun   ("/set " & $bcdnewid & " path \" & $biosbootstring, "biospath")
		CommonBCDRun   ("/displayorder " & $bcdnewid & " /addlast", "biosadd")
		CommonBCDRun   ("/set {default} bootmenupolicy legacy", "legacy", "")
		Return 0
	Else
		CommonWriteLog("                *** The creation of BCD ID " & $bcdnewid & " failed ***", 2)
		Return 1
	EndIf
EndFunc

Func BCDCleanup ($bcoldrelease = "")
	$bccurrfound = ""
	If $bootos   = $xpstring Then Return
	If Not ISArray ($bootarray) Then BCDGetBootArray ()
	If Ubound ($bcdcleanuparray) = 1 Then _
		_ArrayAdd ($bcdcleanuparray, "Start BCD Cleanup Run " & BasicTimeLine ())
	For $bcsub = 0 To Ubound ($bootarray) - 1
		$bcpath   = $bootarray [$bcsub] [$bPath]
        If StringInStr ($bcpath, $bootmanefi32) Or StringInStr ($bcpath, $bootmanefi64) Or _
			StringInStr ($bcpath, $bootloaderbios) Then $bccurrfound = "yes"
	Next
	For $bcsub = 0 To Ubound ($bootarray) - 1
		$bcdelete = ""
		$bcpath   = $bootarray [$bcsub] [$bPath]
		If (StringInStr ($bcpath, $bootmanefi32) Or StringInStr ($bcpath, $bootmanefi64) _
			Or StringInStr ($bcpath, $bootloaderbios)) And $bcoldrelease = "" Then $bcdelete = "yes"
		For $bcoldsub = 0 To Ubound ($oldloaderarray) - 1
			If StringInStr ($bcpath, $oldloaderarray [$bcoldsub]) And $bccurrfound = "yes" Then $bcdelete = "yes"
		Next
		If $bcdelete = "" Then ContinueLoop
		_ArrayAdd ($bcdcleanuparray, "")
		_ArrayAdd ($bcdcleanuparray, 'Deleting BCD Entry  "' & $bootarray [$bcsub] [$bItemTitle] & '"   Path = ' & $bcpath)
		_ArrayAdd ($bcdcleanuparray, "ID =              "    & $bootarray [$bcsub] [$bGUID] & @CR)
		$bcrc = BCDDelete ($bootarray [$bcsub] [$bGUID])
		If $bcrc <> 0 Then MsgBox ($mbwarnok, "Delete Failed", $bootarray [$bcsub] [$bItemTitle])
	Next
	If $bcoldrelease = "yes" Then
		_ArrayAdd ($bcdcleanuparray, "End BCD Cleanup Run")
		If Ubound ($bcdcleanuparray) > 3 Then CommonArrayWrite ($storagepath & "\" & "bcdcleanup.log", $bcdcleanuparray)
		Return
	EndIf
	BCDGetBootArray ()
EndFunc

Func BCDDelete ($bootid)
	$bdrc = CommonBCDRun("/delete " & $bootid, "delete")
	If $bdrc <> 0 Then Return 1
EndFunc

Func BCDParseLine ($bplline, $bplparm)
	$bplresult = StringReplace ($bplline, $bplparm, "", 1)
	$bplresult = StringStripWS ($bplresult, 3)
	Return $bplresult
EndFunc

Func BCDParseID ($bpiline)
	$bpistart = StringInStr($bpiline, "{")
	If $bpistart = 0 Then Return
	$bpiend = StringInStr($bpiline, "}")
	$bpiresult = StringMid($bpiline, $bpistart, $bpiend - $bpistart + 1)
	Return $bpiresult
EndFunc

Func BCDWinOnly (ByRef $bwoarray)
	$bwosub = 0
	While 1
		$bwolimit = Ubound ($bwoarray) - 1
		If $bwosub > $bwolimit Then ExitLoop
		If $bwoarray [$bwosub] [0] <> "win-instance" Then
			_ArrayDelete ($bwoarray, $bwosub)
			ContinueLoop
		EndIf
		$bwosub += 1
	Wend
EndFunc