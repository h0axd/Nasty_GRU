#include-once
#include  <g2common.au3>
#include  <g2custom.au3>
#include  <g2theme.au3>
#include  <g2language.au3>

Func GetPrevConfig()
	If Not FileExists ($configfile) Then FileCopy ($sourcepath & "\basic.cfg", $configfile, 1)
	$gpchandle = FileOpen($configfile, 0)
	If $gpchandle = -1 Then
		CommonWriteLog("                *** Error reading " & $configfile & " " & @error)
		Return 1
	EndIf
	ThemeCreateHold ()
	$envreboot  = GetPrevEnvReboot ()
	$gpcmenusub = 0
	$gpcseldim  = 0
	Dim $selectionarray [1] [$selectionfieldcount + 1]
	Dim $userarray      [1]
	Dim $autoarray      [1]
	Dim $configarray    [1]
	Dim $custparsearray [0] [0]
	$gpcuserstatus     = "off"
	$gpcautostatus     = "off"
	$gpccustcodestatus = "off"
	$gpcsavelaststatus = "off"
	While 1
		$gpcrecord = FileReadLine ($gpchandle)
		If @error = -1 Then	ExitLoop
		$gpcrecord = StringReplace ($gpcrecord, Chr(9), "        ")
		$gpcrecord = StringStripWS ($gpcrecord, 2)
		If StringInStr($gpcrecord, "end-grub2win-auto-menu-section") Then
			$gpcautostatus = "off"
		EndIf
		If StringInStr($gpcrecord, "start") And StringInStr($gpcrecord, "user-section") Then
			$gpcrecord = "# start-grub2win-user-section   " & _StringRepeat("*", 56)
			$gpcautostatus = "off"
			$gpcuserstatus = "on"
			$usersectionfound = "yes"
		EndIf
		If StringInStr($gpcrecord, "start-grub2win-savelast-section ") Then $gpcsavelaststatus = "on"
		If StringInStr($gpcrecord, "end-grub2win-savelast-section ")   Then $gpcsavelaststatus = "off"
		If $gpcsavelaststatus = "on" Then ContinueLoop
		If StringInStr($gpcrecord, "end") And StringInStr($gpcrecord, "user-section") Then
			$gpcrecord = "# end-grub2win-user-section     " & _StringRepeat("*", 56)
			$gpcuserstatus = "off"
			_ArrayAdd($userarray, $gpcrecord)
		EndIf
		If $gpcuserstatus = "off" Then
			If StringInStr($gpcrecord, $customcodestart) Then
				$gpccustcodestatus = "on"
				ContinueLoop
			EndIf
			If StringInStr($gpcrecord, $customcodeend) Then
				$gpccustcodestatus = "off"
				ContinueLoop
			EndIf
		EndIf
		Select
			Case StringInStr ($gpcrecord, "start-grub2win-driver-ata-section")
				$driveruseata   = "yes"
			Case StringInStr ($gpcrecord, "start-grub2win-driver-raid-section")
				$driveruseraid  = "yes"
			Case StringInStr ($gpcrecord, "start-grub2win-driver-usb-section")
				$driveruseusb   = "yes"
			Case StringInStr ($gpcrecord, "start-grub2win-driver-lv-section")
				$driveruselv    = "yes"
			Case StringInStr ($gpcrecord, "start-grub2win-driver-crypt-section")
				$driverusecrypt = "yes"
			Case StringInStr ($gpcrecord, "start-grub2win-driver-sleep-section")
				$driverusesleep = "yes"
		EndSelect
		Select
			Case StringLeft (StringStripWS ($gpcrecord, 7), 1) = "#"   ; Skip Comments
			Case GetPrevCheckMenu ($gpcrecord) <> "" And $gpccustcodestatus = "off"
				If $gpcuserstatus  = "off" Then $gpcautostatus = "on"
				ReDim $selectionarray [$gpcseldim + 1] [$selectionfieldcount + 1]
				$gpcmenusub = Ubound  ($selectionarray) - 1
				$gpcseldim += 1
				If $gpcautostatus = "on" Then
					$selectionarray [$gpcmenusub] [$sAutoUser] = "Auto"
					$selectionarray [$gpcmenusub] [$sBootParm] = "NullParm"
					$selectionautocount += 1
				Else
					$selectionarray [$gpcmenusub] [$sAutoUser]  = "User"
					$selectionusercount += 1
				EndIf
				If CommonPrevParse ($gpcrecord, "submenu", 1) Then $selectionarray [$gpcmenusub] [$sOSType] = "submenu"
				$gpchotloc = StringInStr ($parseresult1, "Hotkey=")
				If $gpchotloc <> 0 Then $parseresult1 = StringLeft ($parseresult1, $gpchotloc - 1)
				$selectionarray [$gpcmenusub] [$sEntryTitle] = StringStripWS ($parseresult1, 3)
				If StringIsDigit ($envreboot) And $envreboot = $gpcmenusub Then _
					$selectionarray [$gpcmenusub] [$sReboot] = "Reboot"
				If $gpcmenusub = $defaultos Then $selectionarray [$gpcmenusub] [$sDefaultOS] = "DefaultOS"
				If StringInStr ($gpcrecord, "--")  Then GetPrevParseParms  ($gpcrecord, $gpcmenusub)
				CommonArraySetDefaults ($gpcmenusub)
			Case CommonPrevParse ($gpcrecord, "set", 1)
				Select
					Case $gpccustcodestatus = "on"
					Case CommonParseStrip ($parseresult1, "timeout=") And $gpcautostatus = "off"
						$timeloader   = $parmstripped
						$timerenabled = "yes"
					Case CommonParseStrip ($parseresult1, "default=")
						$defaultos = $parmstripped
					Case CommonParseStrip ($parseresult1, "grub2win_efilevel=")
						$grubcfgefilevel = $parmstripped
					Case CommonParseStrip ($parseresult1, "grub2win_lastbooted=") And $envreboot = "none"
						$defaultlastbooted = $parmstripped
					Case CommonParseStrip ($parseresult1, "gfxmode=")
						$graphset = StringReplace ($parmstripped, ",auto", "")
						If     StringInStr ($parmstripped, "1024x768,800x600") Then $graphset = $autostring
						If Not StringInStr ($graphstring,  $graphset)          Then $graphset = $autostring
					Case CommonParseStrip ($parseresult1, "grub2win_langauto=")
						If $langfound = "yes" Then $langauto = $parmstripped
					Case CommonParseStrip ($parseresult1, "lang=")
						$langselectedcode = $parmstripped
						$langfullselector = LangGetFullSelector ($langselectedcode)
					Case $gpcautostatus = "off" And $gpcuserstatus = "off" And $gpccustcodestatus = "off"
					Case $gpcmenusub < 0
					Case $selectionarray [$gpcmenusub] [$sOSType] = "submenu" And $gpccustcodestatus = "on"
					Case CommonParseStrip ($parseresult1, "bootdir=")
						$selectionarray [$gpcmenusub] [$sBootBy] = $modebootdir
						$selectionarray [$gpcmenusub] [$sSearchArg] = $parmstripped
					Case CommonParseStrip ($parseresult1, "root=")
						$parmstripped = StringReplace ($parmstripped, "(hd", "")
						$parmstripped = StringReplace ($parmstripped, ")", "")
						$parmstripped = StringReplace ($parmstripped, "gpt", "")
						$parmstripped = StringReplace ($parmstripped, "msdos", "")
						$gpcdrivepart = StringSplit($parmstripped, ",")
						If @error Then
							If StringIsDigit ($parmstripped) Then $selectionarray [$gpcmenusub] [$sDiskAddress] = $parmstripped
						Else
							$selectionarray [$gpcmenusub] [$sBootBy] = $modepartaddress
							$selectionarray [$gpcmenusub] [$sDiskAddress] = $gpcdrivepart[1]
							$selectionarray [$gpcmenusub] [$sPartAddress] = $gpcdrivepart[2]
						EndIf
					Case CommonParseStrip ($parseresult1, "gfxpayload=")
						$selectionarray [$gpcmenusub] [$sGraphMode] = $parmstripped
					Case CommonParseStrip ($parseresult1, "partlabel=")
						$selectionarray [$gpcmenusub] [$sBootBy] = $modepartlabel
						$selectionarray [$gpcmenusub] [$sSearchArg] = $parmstripped
					Case CommonParseStrip ($parseresult1, "bootfile=")
						$selectionarray [$gpcmenusub] [$sBootBy] = $modepartfile
						$selectionarray [$gpcmenusub] [$sSearchArg] = $parmstripped
					Case CommonParseStrip ($parseresult1, "reviewpause=")
						$selectionarray [$gpcmenusub] [$sReviewPause] = $parmstripped
				EndSelect
			Case $gpcautostatus = "off" And $gpcuserstatus = "off" And $gpccustcodestatus = "off"
			Case CommonPrevParse ($gpcrecord, "getbootpartition", 1)
				If $gpcuserstatus = "on" Then $searchneeded = "yes"
				If $parseresult2 = "" Then
					$parseresult2 = $parseresult1
					$parseresult1 = "label"
				EndIf
				If $parseresult1 = "label" And Not StringInStr ($parseresult2, "$") Then
					$selectionarray [$gpcmenusub] [$sBootBy] = $modepartlabel
					$selectionarray [$gpcmenusub] [$sSearchArg] = $parseresult2
				EndIf
			Case CommonPrevParse ($gpcrecord, "g2wisoboot", 1)
				$isoneeded = "yes"
			Case StringInStr ($gpcrecord, "set efibootmgr")
				$selectionarray [$gpcmenusub] [$sBootBy] = $modewinauto
			Case StringInStr ($gpcrecord, "/bootmgr") Or StringInStr ($gpcrecord, "/ntldr")
				$selectionarray [$gpcmenusub] [$sBootBy] = $modewinauto
				$selectionarray [$gpcmenusub] [$sPartAddress] = ""
			Case CommonPrevParse ($gpcrecord, "chainloader", 1) And Not StringInStr ($gpcrecord, "bootmgr")
				$selectionarray [$gpcmenusub] [$sBootBy] = $modechainloader
			Case CommonPrevParse ($gpcrecord, "linux", 1)
				$gpcparm = ""
				For $gpclinsub = 3 To UBound($parsearray) - 1
					$gpcinstance = $parsearray[$gpclinsub]
					If StringLeft ($gpcinstance, 5) = "root=" Then ContinueLoop
					$gpcparm &= $gpcinstance & " "
				Next
				$gpcparm = StringStripWS ($gpcparm, 2)
				If StringLen ($gpcparm) <> 0 Then $selectionarray [$gpcmenusub] [$sBootParm] = $gpcparm
				If $selectionarray [$gpcmenusub] [$sFamily] = "linux-andremix" Then CommonAndroidArray ($gpcmenusub, $gpcparm)
			Case CommonPrevParse ($gpcrecord, "sleep", 1) And $gpccustcodestatus = "off"
				If StringInStr ($gpcrecord, "$reviewpause") Then ContinueCase
				$gpcpause = StringStripWS ($gpcrecord,  8)
				$gpcpause = StringReplace ($gpcpause, "sleep", "")
				$gpcpause = StringReplace ($gpcpause,  "-i", "")
				$gpcpause = StringReplace ($gpcpause,  "-v", "")
				$gpcpause = StringReplace ($gpcpause,  ";echo", "")
				$selectionarray [$gpcmenusub] [$sReviewPause] = 0
				If StringIsDigit ($gpcpause) Then $selectionarray [$gpcmenusub] [$sReviewPause] = $gpcpause
		EndSelect
		If $gpcuserstatus     = "on" Then _ArrayAdd ($userarray, $gpcrecord)
		If $gpccustcodestatus = "on" Then CustomStoreRecord ($gpcmenusub, $gpcrecord)
	WEnd
	FileClose($gpchandle)
	If $graphset        = "" Then $graphset   = $graphdefault
	If $timeloader      = "" Then $timeloader = 30
	If CommonDriversInUse () Then $driversprevious = "yes"
	While 1
		If UBound($userarray) = 1 Then
			$userarray = CommonFileReadToArray ($sourcepath & $templateuser)
			ExitLoop
		EndIf
		$gpcmenu = StringStripWS($userarray[0], 8)
		If StringLen($gpcmenu) <> 0 Then ExitLoop
		_ArrayDelete($userarray, 0)
	WEnd
	If  $selectionarray [0] [$sOSType] = "" Then
		CommonArraySetDefaults (0)
		$selectionarray [0] [$sOSType]     = "windows"
		$selectionarray [0] [$sFamily]     = "windows"
		$selectionarray [0] [$sBootBy]     = $modewinauto
		$selectionarray [0] [$sDefaultOS]  = "DefaultOS"
		$selectionarray [0] [$sAutoUser]   = "Auto"
		$selectionarray [0] [$sIcon]       = "icon-windows"
		$selectionarray [0] [$sHotKey]     = "w"
		$gpcparmloc = CommonGetOSParms (0)
		$selectionarray [0] [$sEntryTitle] = $osparmarray [$gpcparmloc] [$pTitle]
	EndIf
	CommonTitleSync()
	If $firmwaremode <> "EFI" Then GetPrevWinBIOS ()
	If Ubound ($selectionarray) < 1 Then Dim $selectionarray [1] [$selectionfieldcount + 1]
	;_ArrayDisplay ($selectionarray)
EndFunc

Func GetPrevParseParms ($pprecord, $ppmenusub)
	$pprecord = CommonStripSpecial ($pprecord)
	$pparray  = StringSplit ($pprecord, "--", 1)
	If @error Then Return
	$ppostype = "other"
	$ppicon   = ""
	$ppcust   = ""
	For $ppsub = 1 To Ubound ($pparray) - 1
		$ppentry = StringStripWS ($pparray [$ppsub], 8)
		If StringLeft ($ppentry, 6) = "hotkey" Then
			$selectionarray [$ppmenusub] [$sHotKey] = StringTrimLeft ($ppentry, 7)
			ContinueLoop
		EndIf
		If StringLeft ($ppentry, 5) <> "class" Then ContinueLoop
		$ppentry = StringTrimLeft ($ppentry, 5)
		If StringInStr ($typestring, $ppentry) Or $ppentry = "windows" Then $ppostype = $ppentry
		If StringInStr ($ppentry, "icon-")     Then
			$ppicon = $ppentry
			If Not FileExists ($iconpath & "\" & $ppicon & ".png") Then $ppicon = "icon-unknown"
		EndIf
		If StringInStr ($ppentry, "custom_") Then $ppcust = $ppentry
	Next
	;MsgBox ($mbontop, "Class", "Rec  " & $pprecord & @CR & "Type  " & $ppostype & @CR & "Icon  " & $ppicon & @CR & "Cust  " & $ppcust)
	$selectionarray [$ppmenusub] [$sOSType]     = $ppostype
	$selectionarray [$ppmenusub] [$sIcon]       = $ppicon
	$selectionarray [$ppmenusub] [$sCustomFunc] = $ppcust
	$ppparmloc = CommonGetOSParms ($ppmenusub)
	$selectionarray [$ppmenusub] [$sFamily]     = $osparmarray [$ppparmloc] [$pFamily]
	If $ppcust <> "" And $selectionarray[$ppmenusub] [$sAutoUser] <> "User" Then $selectionarray[$ppmenusub] [$sAutoUser] = "Custom"
    ;_ArrayDisplay ($Selectionarray, $ppcust)
EndFunc

Func GetPrevCheckMenu ($cmrecord)
	$cmrecord = StringStripWS ($cmrecord, 1)
	If StringLeft ($cmrecord, 10) <> "menuentry " And StringLeft ($cmrecord, 8) <> "submenu " Then Return 0
	$cmarray = _StringBetween ($cmrecord, "'", "'")
	If @error Then Return 0
	;_ArrayDisplay ($cmarray)
	$parseresult1 = $cmarray [0]
	Return 1
EndFunc

Func GetPrevWinBIOS ()
	; Remove Windows menuentries from BIOS machines.
	$gpcsub = 0
	While 1
		$gpclimit = Ubound ($selectionarray) - 1
		If $gpcsub > $gpclimit Then ExitLoop
		If $selectionarray [$gpcsub] [$sOSType] = "windows" And $selectionarray [$gpcsub] [$sAutoUser] <> "user" Then
			_ArrayDelete ($selectionarray, $gpcsub)
		Else
			$gpcsub += 1
		EndIf
	Wend
EndFunc

Func GetPrevEnvReboot ($erfile = $envfile)
	$erentry  = ""
	$erhandle = FileOpen ($erfile)
	If $erhandle = -1 Then Return $erentry
	$envdata  = FileRead ($erhandle)
	FileClose ($erhandle)
	$erloc    = StringInStr ($envdata, $envparmreboot)
	If $erloc <> 0 Then $erentry = StringMid ($envdata, $erloc + 16, 4)
	;MsgBox ($mbontop, "Data", "R = " & $erentry & @CR & $envdata)
	Return $erentry
EndFunc