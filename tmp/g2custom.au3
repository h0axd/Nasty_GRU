#include-once
#include <g2common.au3>
#include <g2syntax.au3>

Func CustomStampIt ($csiselsub)
	$csisection = Ubound ($custparsearray, 1)
	$csimaxrec  = Ubound ($custparsearray, 2)
	If $csimaxrec < 3 Then $csimaxrec = 3
	ReDim $custparsearray [$csisection + 1] [$csimaxrec]
	$csidesc  = "** Menu Entry " & $csiselsub & "   " & $selectionarray [$csiselsub] [$sEntryTitle] & " **"
	$csistamp = "cust_temp_" & CommonStampUnique ()
	$custparsearray [$csisection] [$sCustRecordCount] = 2
	$custparsearray [$csisection] [$sCustDescript]    = $csidesc
	$custparsearray [$csisection] [$sCustStamp]       = $csistamp
	$selectionarray [$csiselsub]  [$sCustomFunc]      = $csistamp
	$custparselastloc = $csisection
EndFunc

Func CustomStoreRecord ($csrsub, $csrrecord)
	;_ArrayDisplay ($custparsearray, "Before")
	;If $csrrecord  = "" Then Return
	If $selectionarray [$csrsub] [$sCustomFunc] = "" Then CustomStampit ($csrsub)
	$csrkey = $selectionarray [$csrsub] [$sCustomFunc]
	If $custparselastloc = "" Or $csrkey <> $custparsearray [$custparselastloc] [$sCustStamp] Then
		$custparselastloc = _ArraySearch ($custparsearray, $csrkey, 0, 0, 0, 0, 0, $sCustStamp)
	EndIf
	If $custparselastloc < 0 Then CustomStampIt ($csrsub)
	$csrmaxsection = Ubound ($custparsearray, 1) - 1
	$csrmaxrec     = Ubound ($custparsearray, 2)
	$custparsearray [$csrmaxsection] [$sCustRecordCount] += 1
	$csrnextslot   = $custparsearray [$csrmaxsection] [$sCustRecordCount]
	If $csrnextslot >= $csrmaxrec Then ReDim $custparsearray [$csrmaxsection + 1] [$csrnextslot + 1]
	;_ArrayDisplay ($custparsearray, Ubound ($custparsearray, 1) & " " & Ubound ($custparsearray, 2) & " " & $custparselastloc & " " & $custparsenextrec)
	$csrrecord = StringStripCR ($csrrecord)
	$custparsearray [$custparselastloc] [$csrnextslot] = $csrrecord
	;_ArrayDisplay ($custparsearray)
EndFunc

Func CustomSync ($csmenusub)
	$csloc = _ArraySearch ($custparsearray, $selectionarray [$csmenusub] [$sCustomFunc], 0, 0, 0, 0, 0, $sCustStamp)
	If $csloc < 0 Then
		If $selectionarray [$csmenusub] [$sAutoUser] <> "Custom" Then Return
		;_ArrayDisplay ($selectionarray, "Sync " & $csmenusub)
		;_ArrayDisplay ($custparsearray, "Sync " & $csmenusub & $selectionarray [$csmenusub] [$sCustomFunc])
		CommonWriteLog ("     ** Warning. Custom code is missing for sync - Menu Entry " & $csmenusub & "    " & $selectionarray [$csmenusub] [$sEntryTitle])
		$selectionarray [$csmenusub] [$sCustomFunc] = ""
		Return
	EndIf
	$cscustid = "custom_" & StringFormat ("%03i", $csmenusub)
	$selectionarray [$csmenusub] [$sCustomFunc] = $cscustid
	$custparsearray [$csloc]     [$sCustStamp]   = $cscustid
	$csdesc = "** Menu Entry " & $csmenusub & "   " & $selectionarray [$csmenusub] [$sEntryTitle] & " **"
	$custparsearray [$csloc] [$sCustDescript] = $csdesc
	;_ArrayDisplay ($custparsearray, "Sync")
	;_ArrayDisplay ($selectionarray, "Sync")
EndFunc

Func CustomGenCode ($gcmenusub)
	$gcloc = _ArraySearch ($custparsearray, $selectionarray [$gcmenusub] [$sCustomFunc], 0, 0, 0, 0, 0, $sCustStamp)
	If $gcloc < 0 Then
		;_ArrayDisplay ($selectionarray, "Gen " & $gcmenusub)
		;_ArrayDisplay ($custparsearray, "Gen " & $gcmenusub & " " & $selectionarray [$gcmenusub] [$sCustomFunc])
		CommonWriteLog ("     ** Warning. Custom Code is missing for gen - Menu Entry " & $gcmenusub & "    " & $selectionarray [$gcmenusub] [$sEntryTitle])
		$selectionarray [$gcmenusub] [$sCustomFunc] = ""
		Return
	EndIf
	$gclimit = $custparsearray [$gcloc] [$sCustRecordCount]
	For $gcrecordno = $gclimit to 3 Step -1
		$gcrecord = $custparsearray [$gcloc] [$gcrecordno]
		If StringStripWS ($gcrecord, 8) <> "" Then ExitLoop
		$gclimit -= 1
	Next
	For $gcrecordno = 3 To $gclimit
		$gcrecord = $custparsearray [$gcloc] [$gcrecordno]
		;MsgBox ($mbontop, "Rec2", $gcsectionno & @CR & $gcrecordno & @CR & $gcrecord)
		_ArrayAdd ($autoarray, $gcrecord)
	Next
EndFunc

Func CustomGetData ($cgdsub, $cgdmakefile = "")
	$cgdoutput    = ""
	If $cgdmakefile <> "" Then $cgdhandle = FileOpen ($customtempfile, 2)
	$cgdloc    = _ArraySearch ($custparsearray, $selectionarray [$cgdsub] [$sCustomFunc], 0, 0, 0, 0, 0, $sCustStamp)
	If $cgdloc >= 0 And $selectionarray [$cgdsub] [$sCustomFunc] <> "" Then
		$cgdlimit = $custparsearray [$cgdloc] [$sCustRecordCount]
		For $cgdrecordno = 3 To $cgdlimit
			$cgdrecord = $custparsearray [$cgdloc] [$cgdrecordno]
			$cgdoutput &= $cgdrecord & @CR
			If Stringlen ($cgdrecord) > $custmaxhoriz Then $custmaxhoriz = Stringlen ($cgdrecord)
			If $cgdmakefile <> "" Then FileWriteLine ($cgdhandle, $cgdrecord)
		Next
	EndIf
	If $cgdmakefile <> "" Then FileClose ($cgdhandle)
	$cgdcheck = StringStripCR ($cgdoutput)
	$cgdcheck = StringStripWS ($cgdcheck, 8)
	If $cgdcheck = "" Then
		$cgdoutput = ""
		If $cgdloc > 0 Then $custparsearray [$cgdloc] [$sCustStamp] = ""
	EndIf
	Return $cgdoutput
EndFunc

Func CustomEditData ($cedselsub)
	CustomGetData ($cedselsub, "yes")
	If Not FileExists ($customtempfile) Then MsgBox ($mbwarnok, "Custom File Missing", $customtempfile)
	FileCopy  ($customtempfile, $syntaxorigfile, 1)
	$cedstampold  = FileGetTime ($customtempfile, $FT_MODIFIED, $FT_STRING)
	$cedtitle     = "Edit Grub2Win Custom Code For Menu Entry " & $cedselsub
	$cedtitle    &= "          The Title Is " & $selectionarray [$cedselsub] [$sEntryTitle]
	CommonNotepad ($customtempfile, $customtempname, $cedtitle, $edithandlegui)
	GUISetBkColor ($myorange, $edithandlegui)
	$cedstampnew  = FileGetTime ($customtempfile, $FT_MODIFIED, $FT_STRING)
	If $cedstampnew <> $cedstampold Then
		$cedsynrc = SynMain ($customtempfile, $cedselsub)
		If $cedsynrc = "Accepted" Then CommonWriteLog _
			("     ** Warning - Syntax check in menu entry " & $cedselsub & " custom code.")
	EndIf
	CustomReadFile    ($customtempfile, $cedselsub)
	If CustomGetData  ($cedselsub) = "" Then CustomClearCode ($cedselsub)
	CustomWriteList   ($cedselsub)
	GUICtrlSetBkColor ($editpromptcust,   $mygreen)
	GUICtrlSetBkColor ($editpromptsample, $mygreen)
	;_ArrayDisplay ($custparsearray, "After 2")
EndFunc

Func CustomClearCode ($ccsub)
	$ccloc = _ArraySearch ($custparsearray, $selectionarray [$ccsub] [$sCustomFunc], 0, 0, 0, 0, 0, $sCustStamp)
	$selectionarray [$ccsub] [$sCustomFunc] = ""
	If $ccloc < 0 Then Return
	_ArrayDelete ($custparsearray, $ccloc)
EndFunc

Func CustomReadFile ($crffilename, $crfselsub)
	$crftemparray = CommonFileReadToArray ($crffilename)
	CustomClearCode ($crfselsub)
	For $crfcustsub = 0 To Ubound ($crftemparray) - 1
		CustomStoreRecord ($crfselsub, $crftemparray [$crfcustsub])
	Next
EndFunc

Func CustomWriteList ($wlsub)
	If $selectionarray[$wlsub][$sAutoUser] <> "Custom" Then Return
	$wlcustdata    = CustomGetData ($wlsub)
	$wlcustdata    = StringReplace ($wlcustdata, @CR, "|")
	GuiCtrlSetData ($editlistcustedit, "")
	GuiCtrlSetData ($editlistcustedit, $wlcustdata)
EndFunc