#include-once
#include <g2common.au3>
#include <g2language.au3>

Func XPSetup ()
	Dim $xpoldrelarray[1]
	_ArrayAdd   ($xpoldrelarray, $xptargetstub)
	_ArrayAdd   ($xpoldrelarray, $xpstubsource)
EndFunc

Func XPGetPrevious()
	Local $xpgendfound
	Dim $xpiniarray     [1]
	Dim $xpinbackiarray [1]
	$xpghandle = FileOpen ($xpinifile)
	If $xpghandle = -1 Then
		CommonWriteLog("                *** Error reading " & $xpinifile)
		CommonShowError ("The " & $xpinifile & " file is missing  *****   Grub2Win is aborted *****")
		Exit
	EndIf
	While 1
		$lineini = FileReadLine ($xpghandle)
		If @error = -1 Then ExitLoop
		$lineini = StringStripWS($lineini, 3)
		Select
			Case StringLeft($lineini, 13) = "[boot loader]"
			Case StringLeft($lineini, 19) = "[operating systems]"
			Case StringLeft($lineini, 1)  = "["
				$xpgendfound = "yes"
		EndSelect
		If $xpgendfound = "yes" Then
			_ArrayAdd ($xpinbackiarray, $lineini)
		Else
			_ArrayAdd ($xpiniarray,     $lineini)
		EndIf
		Select
			Case StringLeft($lineini, 8) = "Timeout=" Or StringLeft($lineini, 8) = "timeout="
				$xpiniprevtime  = StringMid($lineini, 9, 5)
				$timewinboot  = $xpiniprevtime
			Case StringLeft($lineini, StringLen($xpstubfile)) = $xpstubfile
				$inistring    = StringTrimLeft($lineini, StringLen($xpstubfile))
				$iniprevdesc  = _StringBetween($inistring, '"', '"')
				$iniprevdesc  = $iniprevdesc[0]
				$xpiniprevitem  = $lineini
			EndSelect
	Wend
	FileClose ($xpghandle)
	If $xpiniarray [Ubound ($xpiniarray) -1] = "" Then _ArrayDelete ($xpiniarray, Ubound ($xpiniarray) -1)
EndFunc

Func XPUpdate ($xutimeout = $timewinboot, $xpsetup = "yes")
	$xurc = XPCreateLoader()
	If $xurc = 1 Then Return 1
	$xpinibootstring = $xpstubfile & '="' & $biosdesc & '"'
	XPIniCleanup()
	If $xutimeout = $xpiniprevtime And $xpinibootstring = $xpiniprevitem And $xpinibackedup = "" And $xpoldfound = ""  Then
		If $xpsetup = "yes" Then CommonWriteLog ("          The Grub2Win entry already exists. No " & $xptargetini & " changes are required")
		Return 0
	EndIf
	If $xutimeout <> $xpiniprevtime Then
		$bootitem = _ArraySearch($xpiniarray, "Timeout=", 0, 0, 0, 1)
		If $bootitem >= 0 Then
			$xpiniarray[$bootitem] = "Timeout=" & $xutimeout
			CommonWriteLog("           The Windows " & $xptargetini & " timeout has been set to " & $xutimeout)
			CommonWriteLog()
		EndIf
	EndIf
	If $xpinibootstring <> $xpiniprevitem Then
		CommonWriteLog("          Adding the new  Grub2Win entry to " & $xpinifile)
		CommonWriteLog('                The title is -  "' & $biosdesc & '"')
		CommonWriteLog("                The Windows boot timeout is " & $xutimeout & " seconds")
		_ArrayAdd ($xpiniarray, "")
		_ArrayAdd ($xpiniarray, $xpinibootstring)
		_ArrayAdd ($xpiniarray, "")
	EndIf
	If $xpiniarray [Ubound ($xpiniarray) -1] = "" Then _ArrayDelete ($xpiniarray, Ubound ($xpiniarray) -1)
	FileDelete($xpinifile)
	$xurc = CommonArrayWrite($xpinifile, $xpiniarray)
	If $xurc = 1 Then
		CommonWriteLog("                *** Error writing " & $xpinifile & "  " & @error)
		Return 1
	EndIf
	CommonWriteLog()
	CommonWriteLog("          " & $xpinifile & " update was successful", 2)
	Return 0
EndFunc

Func XPIniCleanup ($xpuninstall = "")
	$inibootfound = "no"
	$inisub = 1
	While 1
		If $inisub > UBound($xpiniarray) - 1 Then ExitLoop
		$iniline = $xpiniarray[$inisub]
		$iniline = StringStripWS($iniline, 3)
		For $xpsub = 1 To UBound($xpoldrelarray) - 1
			$prevname = $xpoldrelarray[$xpsub]
			If Not StringInStr ($iniline, $prevname)  Then ContinueLoop
			If     StringInStr ($iniline, "default=") And $xpuninstall = "" Then ContinueLoop
			If $iniline = $xpinibootstring And $inibootfound = "no" And $xpuninstall = "" Then
				$inibootfound = "yes"
				ContinueLoop
			EndIf
			_ArrayDelete($xpiniarray, $inisub)
			$xpoldfound = "yes"
			$inisub -= 1
			If $inisub <= UBound($xpiniarray) - 1 And $xpiniarray [$inisub] = "" Then
				_ArrayDelete($xpiniarray, $inisub)
				$inisub -= 1
			EndIf
			CommonWriteLog("                A previous Grub2Win entry has been deleted. Line = " & $iniline)
		Next
		$inisub += 1
	WEnd
EndFunc

Func XPCreateLoader()
	$xcrc = FileCopy($bootmanpath & "\" & $xpstubsource, $xpstubfile, 1)
	If $xcrc = 1 Then
		CommonWriteLog('                The XP stub file ' & $xpstubfile & ' was created', 2)
	Else
		CommonWriteLog("                *** XP stub creation failed   RC = " & $xcrc & " ***", 2)
		Return 1
	EndIf
	$xcrc = FileCopy($bootmanpath & "\" & $bootloaderbios, $xploadfile, 1)
	If $xcrc = 1 Then
		CommonWriteLog('                The XP loader file ' & $xploadfile & ' was created', 2)
	Else
		CommonWriteLog("                *** XP loader creation failed   RC = " & $xcrc & " ***", 2)
		Return 1
	EndIf
	Return 0
EndFunc