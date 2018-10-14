#include-once
#include <g2common.au3>

Const $sOpenChar  = 0, $sOpenDesc      = 1
Const $sCloseChar = 2, $sCloseDesc     = 3
Const $sEvalType  = 4

Const $sOpenCount = 0, $sCloseCount    = 1
Const $sErrorMsg  = 2, $sErrorStart    = 3
Const $sErrorEnd  = 4, $sLastFound     = 5

Const $sScanTypes     = 6
Const $sSyntaxFields  = 5
Const $sWorkFields    = 6

Const $synquotes     = "'",                    $synquoted    = '"'
Const $synlitquotes  = '"' & $synquotes & '"', $synlitquoted = "'" & $synquoted & "'"
Const $synreportfile = $storagepath & "\syntax.report.txt"

Global $syninputarray, $synerrorcount, $synerrorarray, $synnotepadpid, $synguihandle
Global $synmaxlevel, $syncharactercount

Dim $synvaluearray [$sScanTypes] [$sSyntaxFields]
Dim $synworkarray  [$sScanTypes] [$sWorkFields]

$synvaluearray [0] [$sOpenChar]  = $synquotes
$synvaluearray [0] [$sOpenDesc]  = "Unmatched Single Quote"
$synvaluearray [0] [$sEvalType]  = "Line"
$synvaluearray [1] [$sOpenChar]  = $synquoted
$synvaluearray [1] [$sOpenDesc]  = 'Unmatched Double Quotes'
$synvaluearray [1] [$sEvalType]  = "Line"
$synvaluearray [2] [$sOpenChar]  = "["
$synvaluearray [2] [$sOpenDesc]  = "Unmatched Left Brace - ["
$synvaluearray [2] [$sCloseChar] = "]"
$synvaluearray [2] [$sCloseDesc] = "Unmatched Right Brace - ]"
$synvaluearray [2] [$sEvalType]  = "Line"
$synvaluearray [3] [$sOpenChar]  = "("
$synvaluearray [3] [$sOpenDesc]  = "Unmatched Left Parenthesis - ("
$synvaluearray [3] [$sCloseChar] = ")"
$synvaluearray [3] [$sCloseDesc] = "Unmatched Right Parenthesis - )"
$synvaluearray [3] [$sEvalType]  = "Line"
$synvaluearray [4] [$sOpenChar]  = "{"
$synvaluearray [4] [$sOpenDesc]  = "Unmatched Left Curly Bracket - {"
$synvaluearray [4] [$sCloseChar] = "}"
$synvaluearray [4] [$sCloseDesc] = "Unmatched Right Curly Bracket - }"
$synvaluearray [4] [$sEvalType]  = "Block"
$synvaluearray [5] [$sOpenChar]  = " if "
$synvaluearray [5] [$sOpenDesc]  = 'Extra Opening  "if"  Clause'
$synvaluearray [5] [$sCloseChar] = " fi "
$synvaluearray [5] [$sCloseDesc] = 'Extra Closing  "fi"  Clause'
$synvaluearray [5] [$sEvalType]  = "Block"

Func SynMain ($smfilein, $smmenuitem = "")
	$smtarget  = "File " & $smfilein
	If $smmenuitem <> "" Then $smtarget = "The Custom Code For Menu Item " & $smmenuitem
	While 1
		$smreturn = SynCheck ($smfilein, $smtarget, $smmenuitem)
		If $synguihandle <> "" Then GuiDelete ($synguihandle)
		If $smreturn = "NoErrors" Or $smreturn = "Empty" Or $smreturn = "Cancelled" Or $smreturn = "Accepted" Then ExitLoop
	Wend
	If $smreturn = "Cancelled" Then
		If $smmenuitem <> "" Or                                                _
				(FileGetTime ($smfilein,       $FT_MODIFIED, $FT_STRING) >     _
			 	 FileGetTime ($syntaxorigfile, $FT_MODIFIED, $FT_STRING)) Then
			MsgBox   ($mbinfook, "The changes have been cancelled","", 3)
			FileCopy ($syntaxorigfile, $smfilein, 1)
		EndIf
	EndIf
	If $smreturn = "NoErrors" Then
		$smgood  = @CR & @CR & @TAB & "No Syntax Errors Were Found In"
		$smgood &= @CR & @TAB & $smtarget
		$smgood &= @CR & @CR & @TAB &  Ubound ($syninputarray) - 1 & " Lines Were Scanned"
	    $smgood &= @CR & @CR & @TAB & "The Maximum Nesting Level Was " & $synmaxlevel
		$smgood &= @CR & @CR & @TAB & "The Time Is " & BasicTimeLine ()
		_ArrayAdd ($synerrorarray, $smgood)
		MsgBox ($mbinfook, "Syntax Check Succeeded", $smgood, 20)
	EndIf
	_ArrayAdd ($synerrorarray, @CR & @TAB & "Status is - " & $smreturn)
	CommonArrayWrite ($synreportfile, $synerrorarray)
	Return $smreturn
EndFunc

Func SynCheck ($scfilein, $sstarget, $scmenuitem)
	$synerrorcount     = 0
	$syncharactercount = 0
	$synmaxlevel       = 0
	Dim $synerrorarray [1]
	$syninputarray = CommonFileReadToArray ($scfilein)
    _ArrayInsert ($syninputarray, 0, "")
	For $scsub = 1 To Ubound ($syninputarray) - 1
	    $screcord = StringStripWS ($syninputarray [$scsub], 7)
	    If StringLeft  ($screcord, 13) = "# Menu Entry " Or StringLeft ($screcord, 9) = "function " Or _
			(StringInStr ($screcord, "end-") And StringInStr ($screcord, "-section")) Then SynEndBlock ($scsub - 1)
		$screcord = SynStrip ($screcord)
		If $screcord  = "" Then ContinueLoop
		$syncharactercount += StringLen ($screcord)
		SynCheckLine   ($screcord, $scsub)
		If $selectionarray [$scmenuitem] [$sOSType] = "isoboot" Then SynCheckISO ($screcord)
	Next
	Return SynShowErrors ($scfilein, $sstarget)
EndFunc

Func SynCheckLine ($sclrecord, $sclnumber)
	$sclrecord = StringReplace ($sclrecord, ";", " ")
	$sclrecord = CommonPadRight ("Line " & $sclnumber, 10) & $sclrecord
	For $sclsub = 0 To Ubound ($synvaluearray) - 1
		$sclopenchar = $synvaluearray [$sclsub] [$sOpenChar]
		If $sclopenchar = "" Then ContinueLoop
		StringReplace ($sclrecord, $sclopenchar, "")
		$sclopencount  = @extended
		StringReplace ($sclrecord, $synvaluearray [$sclsub] [$sCloseChar], "")
		$sclclosecount = @extended
		If $sclopencount > 0 Or $sclclosecount > 0 Then _
			SynCheckState ($sclsub, $sclnumber, $sclrecord, $sclopencount, $sclclosecount)
	Next
EndFunc

Func SynCheckState ($scssub, $scsnumber, $scsline, $scsopencount = 0, $scsclosecount = 0, $scscloseout = "")
	   	$synworkarray [$scssub] [$sOpenCount]  += $scsopencount
		$synworkarray [$scssub] [$sCloseCount] += $scsclosecount
		If $scsopencount  > 0 Or $scsclosecount > 0 Then $synworkarray [$scssub] [$sLastFound ] = $scsnumber
		If $synvaluearray [$scssub] [$sEvalType] <> "Line" Then
			$scslevel = Abs ($synworkarray [$scssub] [$sOpenCount] - $synworkarray [$scssub] [$sCloseCount])
			If $scslevel > $synmaxlevel Then $synmaxlevel = $scslevel
		EndIf
		Select
			Case $synvaluearray [$scssub] [$sEvalType] = "Line"
				$scslineok = ""
				If $synvaluearray [$scssub] [$sCloseChar] =  "" And Mod ($scsopencount + $scsclosecount, 2) <> 0 Then $scslineok = "no"
				If $synvaluearray [$scssub] [$sCloseChar] <> "" And      $scsopencount <> $scsclosecount         Then $scslineok = "no"
				If $scslineok = "no" Then
					If Not StringInStr ($scsline, $synlitquotes) And Not StringInStr ($scsline, $synlitquoted) Then
						If $scsopencount  > $scsclosecount Then $synworkarray [$scssub] [$sErrorMsg] = $synvaluearray [$scssub] [$sOpenDesc]
						If $scsclosecount > $scsopencount  Then $synworkarray [$scssub] [$sErrorMsg] = $synvaluearray [$scssub] [$sCloseDesc]
						$synworkarray [$scssub] [$sErrorEnd] = $scsnumber
					EndIf
				EndIf
			Case $scscloseout = "yes"
				If $synworkarray [$scssub] [$sOpenCount] > $synworkarray  [$scssub] [$sCloseCount] Then
					$synworkarray [$scssub] [$sErrorMsg] = $synvaluearray [$scssub] [$sOpenDesc]
					$synworkarray [$scssub] [$sErrorEnd] = $scsnumber
				EndIf
			Case $synworkarray [$scssub] [$sCloseCount] > $synworkarray [$scssub] [$sOpenCount]
				$synworkarray [$scssub] [$sErrorMsg] = $synvaluearray [$scssub] [$sCloseDesc]
				$synworkarray [$scssub] [$sErrorEnd] = $scsnumber
			Case $scsopencount <> $scsclosecount And $synworkarray [$scssub] [$sErrorStart] = ""
				$synworkarray [$scssub] [$sErrorStart] = $scsnumber
			Case $synworkarray [$scssub] [$sOpenCount] = $synworkarray [$scssub] [$sCloseCount]
				If $synworkarray [$scssub] [$sOpenCount]  > 0 Then $synworkarray [$scssub] [$sOpenCount]  -= 1
				If $synworkarray [$scssub] [$sCloseCount] > 0 Then $synworkarray [$scssub] [$sCloseCount] -= 1
		EndSelect
		If $synworkarray [$scssub] [$sErrorEnd] <> "" Then SynStoreError ()
EndFunc

Func SynStoreError ()
	For $ssesub = 0 To $sScanTypes - 1
		If $synworkarray [$ssesub] [$sErrorMsg] = "" Then ContinueLoop
		$ssestart = $synworkarray [$ssesub] [$sErrorStart]
		$sseend   = $synworkarray [$ssesub] [$sErrorEnd]
		$sselast  = $synworkarray [$ssesub] [$sLastFound]
		If $sselast <> "" And $sselast < $sseend Then $sseend = $sselast
		If $ssestart = "" Or $ssestart = $sseend Then
			$ssestart = $sseend
			$ssemsghdr1 = @TAB & @TAB & "*** Line  " & $sseend
		Else
			$ssemsghdr1 = @TAB & @TAB & "*** Lines " & $ssestart & "  To  " & $sseend
		EndIf
		$ssemsghdr2  = "Error Type        " & $synworkarray [$ssesub] [$sErrorMsg] & " ***" & @CRLF
		$ssesortinc  = 2
		$ssesortcode = StringFormat ("%05i", $ssestart) & "-" & $ssesub & "-"
		_ArrayAdd ($synerrorarray, $ssesortcode & StringFormat ("%05i", 1)& @CRLF & _
		    CommonPadRight ($ssemsghdr1, 35) & @TAB & $ssemsghdr2)
		For $sselinesub = $ssestart To $sseend
			_ArrayAdd ($synerrorarray, $ssesortcode & StringFormat ("%05i", $ssesortinc) & _
				"     " & $sselinesub & "     " & $syninputarray [$sselinesub])
			$ssesortinc += 1
		Next
		_ArrayAdd ($synerrorarray, $ssesortcode & StringFormat ("%05i", $ssesortinc) & @CRLF)
		$synerrorcount += 1
		If $synworkarray [$ssesub] [$sErrorEnd] <> "" Then
			For $sseworkfields = 0 To $sWorkFields - 1
				$synworkarray [$ssesub] [$sseworkfields] = ""
			Next
		EndIf
	Next
EndFunc

Func SynEndBlock ($sebline)
	For $sebsub = 0 To $sScanTypes - 1
		SynCheckState ($sebsub, $sebline, "", 0, 0, "yes")
	Next
	Dim $synworkarray [$sScanTypes] [$sWorkFields]
EndFunc

Func SynShowErrors ($ssefilein, $ssetarget)
	Local $ssebuttonedit, $ssebuttonrescan, $sseedithandle, $ssenotepadpid, $sserunningedit
	$ssepad = _StringRepeat (" ", 13)
	SynEndBlock (Ubound ($syninputarray) - 1)
	If $syncharactercount = 0 Then Return "Empty"
	If $synerrorcount     = 0 Then Return "NoErrors"
	_ArraySort    ($synerrorarray)
	$ssemessage = ""
	$sseheader  = "** Probable Syntax Errors In " & $ssetarget & "  **"
	$ssetrailer = $synerrorcount & "  Errors Were Found"
	If $synerrorcount = 1 Then $ssetrailer = "1 Error Was Found"
	_ArrayInsert ($synerrorarray, 1, $ssepad & @CRLF & @TAB & _
	     "** " & $ssetrailer & " at " & BasicTimeLine () & " **" & @CRLF)
	_ArrayInsert ($synerrorarray, 1, $ssepad & @CRLF & @TAB & $sseheader)
	_ArrayAdd    ($synerrorarray,    $ssepad & @CRLF & @TAB & _
	     "***   The Syntax Check Is Complete    ***  "   & @TAB & $ssetrailer)
	_ArrayAdd    ($synerrorarray,    $ssepad & @CRLF & @TAB & Ubound ($syninputarray) - 1 & " Lines Were Scanned")
	_ArrayAdd    ($synerrorarray,    $ssepad & @CRLF & @TAB & "The Maximum Nesting Level Was " & $synmaxlevel)
	For $ssesub = 0 To Ubound ($synerrorarray) - 1
		$synerrorarray [$ssesub] = StringTrimLeft ($synerrorarray [$ssesub], 13)
		$ssemessage &= $synerrorarray [$ssesub] & @CRLF
	Next
	$synguihandle = GUICreate ("  Syntax Scan Of " & $ssetarget, $scalehsize, $scalevsize, -1, -1, -1)
	GUISetBKColor ($mymedgray, $synguihandle)
	If Not ProcessExists ($ssenotepadpid) Then ProcessClose ($ssenotepadpid)
	$sseedithandle   = CommonScaleCreate ("Edit", $ssemessage,  0, 0, 100, 85, BitOr ($GUI_SS_DEFAULT_EDIT, $ES_READONLY))
	$ssebuttonedit   = CommonScaleCreate ("Button", "Edit File",     8, 93, 12, 5)
	$ssebuttonrescan = CommonScaleCreate ("Button", "Rescan",       45, 93, 12, 5)
	$ssebuttonaccept = CommonScaleCreate ("Button", "Accept As Is", 45, 87, 12, 5)
	$ssebuttoncancel = CommonScaleCreate ("Button", "Cancel",       80, 93, 12, 5)
	GUICtrlSetBKColor ($ssebuttonaccept, $myyellow)
	GUICtrlSetBKColor ($ssebuttonedit,   $mylightgray)
	GUICtrlSetBKColor ($ssebuttonrescan, $mylightgray)
	GUICtrlSetBKColor ($ssebuttoncancel, $mylightgray)
	GUICtrlSetBKColor ($sseedithandle,   $myyellow)
	;GUICtrlSetBKColor ($ssebuttonclose,  $sseclosecolor)
	GUISetState (@SW_SHOW, $synguihandle)
	While 1
		While $sserunningedit = "yes"
			sleep (10)
			If ProcessExists ($synnotepadpid) Then ContinueLoop
			Return "Rescan"
		Wend
		$sseguistatusarray = GUIGetMsg (1)
		If $sseguistatusarray [1] <> $synguihandle Then ContinueLoop
		$sseguistatus = $sseguistatusarray [0]
		Switch $sseguistatus
			Case $ssebuttoncancel, $GUI_EVENT_CLOSE
				Return "Cancelled"
			Case $ssebuttonaccept
				$sseaccmsg  = "Are you sure you want to accept this file with probable syntax errors?"
				$sseaccrc   = MsgBox ($mbwarnyesno, "Accept?", $sseaccmsg)
				If $sseaccrc = $IDYES Then
					MsgBox ($mbinfook, "Accepted", $ssetarget & " has been accepted", 3)
					Return "Accepted"
				EndIf
			Case $ssebuttonrescan
				Return "Rescan"
			Case $ssebuttonedit
				$sserunningedit = "yes"
				GUICtrlSetState ($ssebuttonedit,   $guihideit)
				GUICtrlSetState ($ssebuttonrescan, $guihideit)
				GUICtrlSetState ($ssebuttoncancel, $guihideit)
				If Not ProcessExists ($synnotepadpid) Then _
					$synnotepadpid = CommonNotepad ($ssefilein, "[CLASS:Notepad]", "Edit file " & $ssefilein, $synguihandle)
		EndSwitch
	WEnd
EndFunc

Func SynCheckISO ($cirecord)
	$cicheck  = "'"
	$cirecord = StringStripWS ($cirecord, 7)
	If StringLeft ($cirecord, 12) = "set isopath="    Then $cicheck = StringTrimLeft ($cirecord, 12)
	If StringLeft ($cirecord, 15) = "set kernelpath=" Then $cicheck = StringTrimLeft ($cirecord, 15)
	If StringLeft ($cirecord, 15) = "set initrdpath=" Then $cicheck = StringTrimLeft ($cirecord, 15)
	If StringLeft ($cirecord, 14) = "set bootparms="  Then $cicheck = StringTrimLeft ($cirecord, 14)
	If StringLeft ($cicheck,  1)  = "'" Then Return
	$cimsg = "The fields in this variable should be enclosed in single quotes" & @CR & @CR & $cicheck
	MsgBox ($mbontop, "** ISOBoot Warning **", $cirecord & @CR & @CR & $cimsg)
EndFunc

Func SynChoose ()
	$scmessage  = "             ** Select a Grub configuration file to be scanned for syntax **"
	$scsearch   = "Grub Configuration Files (*.cfg)"
	$scfilepath = FileOpenDialog ($scmessage, $basepath & "\", $scsearch, $FD_FILEMUSTEXIST, $configfile, $handlemaingui)
	If @error Then
		$scstatus = "Cancelled"
	Else
		FileCopy  ($scfilepath, $syntaxorigfile, 1)
		$scstatus = SynMain ($scfilepath)
	EndIf
	If $scstatus = "Empty" Then
		$scempty = " ** No Code Was Found In This File **" & @CR & @CR & $scfilepath
		MsgBox ($mbwarnok, "             ** Syntax Check Error **", $scempty, 30)
	EndIf
	If  $scstatus  = "Cancelled" Then
		MsgBox ($mbinfook, "", "The Syntax Scan was cancelled by the user")
		Return $scstatus
	EndIf
EndFunc

Func SynStrip ($ssrecord)
	$sscommentloc = StringInStr ($ssrecord, "#")
	If $sscommentloc <> 0 Then $ssrecord = StringMid ($ssrecord, 1, $sscommentloc - 1)
	$ssrecord = StringReplace ($ssrecord, ";", " ")
	$ssrecord = StringStripWS ($ssrecord, 3)
	If $ssrecord = "" Then Return ""
	$ssrecord = " " & $ssrecord & " "
	Return $ssrecord
EndFunc