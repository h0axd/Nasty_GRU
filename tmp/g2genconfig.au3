#include-once
#include  <g2common.au3>
#include  <g2custom.au3>
#include  <g2language.au3>

Func GenConfig()
	CommonTitleSync ()
	CommonWriteLog ()
	FileDelete ($configfile)
	$gcthemename = CommonThemeGetOption ("name")
	$gctimemsg1  = "The Grub default timeout is "
	$gctimemsg2  = $timeloader & " seconds"
	If $timerenabled = "no" Then $gctimemsg2 = "not set"
	CommonWriteLog("          " & "Updating the " & $configstring & " file     " & $gctimemsg1 & $gctimemsg2)
	Dim $configarray[1]
	_ArrayAdd($configarray, "#")
	_ArrayAdd($configarray, "#       Created at " & BasicTimeLine())
	_ArrayAdd($configarray, "#")
	_ArrayAdd($configarray, "# "                     & $progvermessage)
	_ArrayAdd($configarray, "#              Stamp  " & $progtimestampdisp)
	_ArrayAdd($configarray, "#")
	_ArrayAdd($configarray, "# The grub menu theme is - " & $gcthemename)
	_ArrayAdd($configarray, "#")
	_ArrayAdd($configarray, "#")
	If $selectionautocount > Ubound ($selectionarray) Then $selectionautocount = Ubound ($selectionarray)
	If $selectionautocount > 1 Then $genline = "Grub2Win generated " & $selectionautocount & " menu entries."
	If $selectionautocount = 1 Then $genline = "Grub2Win generated " & $selectionautocount & " menu entry."
	If $selectionusercount > 1 Then $genline &= "   " & $selectionusercount & " user menu entries were preserved."
	If $selectionusercount = 1 Then $genline &= "   " & $selectionusercount & " user menu entry was preserved."
	_ArrayAdd($configarray, "#  " & $genline)
	_ArrayAdd($configarray, "#")
	_ArrayAdd($configarray, "#  The Grub default boot OS is menu entry " & $defaultset)
	_ArrayAdd($configarray, "#  " & $gctimemsg1 & $gctimemsg2)
	If $langauto = "" Then $langfullselector = LangGetFullSelector ($langselectedcode)
	_ArrayAdd($configarray, "#  The Grub locale language is " & $langfullselector & "   The locale code is - " & $langselectedcode)
	_ArrayAdd($configarray, "#")
	_ArrayAdd($configarray, "")
	_ArrayAdd($configarray, "")
	If $defaultlastbooted = "yes" Then
		_ArrayAdd($configarray, "load_env default")
		_ArrayAdd($configarray, "load_env grub2win_chosen")
	Else
		_ArrayAdd($configarray, "set default=" & $defaultos)
		_ArrayAdd($configarray, "set grub2win_chosen=" & "'" & $defaultset & "'")
	EndIf
	If $langauto = "yes" Then
		_ArrayAdd($configarray, "set grub2win_langauto=yes")
		$langselectedcode = $langcode
	EndIf
	_ArrayAdd($configarray, "load_env grub2win_reboot")
	_ArrayAdd($configarray, "if [ ! $grub2win_reboot = none ] ; then set default=$grub2win_reboot" & _
	                        " ; set grub2win_reboot=none ; save_env grub2win_reboot ; fi")
	If $timerenabled = "yes" Then
		_ArrayAdd($configarray, "set timeout=" & $timeloader)
	Else
		_ArrayAdd($configarray, "unset timeout")
	EndIf
	_ArrayAdd($configarray, "set lang=" & $langselectedcode)
	_ArrayAdd($configarray, "set grub2win_version=" & $progversion)
	CommonAddFileToArray ($sourcepath & $templatesetparms, $configarray)
	_ArrayAdd($configarray, "set grub2win_custmode=" & $firmwaremode)
	_ArrayAdd($configarray, "set grub2win_lastbooted=" & $defaultlastbooted)
	If $firmwaremode = "EFI" Then _ArrayAdd($configarray, "set grub2win_efilevel=" & $efilevelinstalled)
	If $driveruseata   = "yes" Or $driveruseusb Then CommonAddFileToArray ($sourcepath & $driverfilepath,  $configarray)
	If $driveruseata   = "yes" Then CommonAddFileToArray ($sourcepath & $driverfileata,   $configarray)
    If $driverusecrypt = "yes" Then CommonAddFileToArray ($sourcepath & $driverfilecrypt, $configarray)
	If $driveruselv    = "yes" Then CommonAddFileToArray ($sourcepath & $driverfilelv,    $configarray)
	If $driveruseraid  = "yes" Then CommonAddFileToArray ($sourcepath & $driverfileraid,  $configarray)
	If $driveruseusb   = "yes" Then CommonAddFileToArray ($sourcepath & $driverfileusb,   $configarray)
	If $driverusesleep = "yes" Then CommonAddFileToArray ($sourcepath & $driverfilesleep, $configarray)
	If Not StringInStr($graphset, "auto") Then $graphset &= ",auto"
	If $graphset =  "auto" Then $graphset = $graphconfigauto
	If $gcthemename <> $notheme Then
		If $graphset = $autostring Then $graphset = $graphconfigauto
		_ArrayAdd($configarray, "set gfxmode=" & $graphset)
		CommonAddFileToArray ($sourcepath & $templatetheme,   $configarray)
		CommonAddFileToArray ($sourcepath & $templategfxmenu, $configarray, "yes")
	EndIf
	CommonWriteLog("              The Grub default OS is menu entry " & $defaultset)
	CommonWriteLog("              The Grub language is " & $langfullselector & "  Locale code - " & $langselectedcode)
	$selectionlimit = UBound($selectionarray) - 1
	_ArrayAdd($autoarray, "# start-grub2win-auto-menu-section  " & _StringRepeat("*", 51))
	_ArrayAdd($autoarray, "#")
	$gpctitlepad = 50
	If StringLeft ($graphset, 1) = "8" Then $gpctitlepad = 30
	For $gcsub = 0 To $selectionlimit
		$gcchotkey = ""
		$gctitle  = $selectionarray [$gcsub] [$sEntryTitle]
		If $selectionarray [$gcsub] [$sHotkey] <> "none" Then
			$gcchotkey   = "--hotkey=" & $selectionarray [$gcsub] [$sHotkey]
			$gcctitlehot = "Hotkey="   & $selectionarray [$gcsub] [$sHotkey]
			$gctitle     = CommonPadRight ($gctitle, $gpctitlepad) & "     " & $gcctitlehot
		EndIf
		If $selectionarray [$gcsub] [$sAutoUser]   =  "User" Then ContinueLoop
		If $selectionarray [$gcsub] [$sCustomFunc] <> "" Then CustomSync ($gcsub)
		$gcmenutype = "menuentry   '"
		$gcmenudesc = "  Menu Entry "
		If $selectionarray [$gcsub] [$sOSType] =  "submenu" Then
			$gcmenutype = "submenu     '"
			$gcmenudesc = "  SubMenu Entry "
		EndIf
		_ArrayAdd($autoarray, "")
		_ArrayAdd($autoarray, "#")
		_ArrayAdd($autoarray, "#" & $gcmenudesc & $gcsub & "       " & $selectionarray[$gcsub][$sEntryTitle])
		_ArrayAdd($autoarray, "#")
		If $gcsub = $defaultos And $defaultlastbooted = "no" Then
			_ArrayAdd($autoarray, "#  ** Grub will boot this entry by default **")
			_ArrayAdd($autoarray, "#")
		EndIf
		$gcmenurec    = $gcmenutype & $gctitle & "'"
		$gcctempclass = $selectionarray[$gcsub][$sOSType]
		If StringInStr ($gcctempclass, "windows") Then $gcctempclass = "windows"
		$gpcclass  = "--class " & $gcctempclass & "   --class " & $selectionarray[$gcsub][$sIcon]
		If $selectionarray[$gcsub][$sCustomFunc] <> "" Then $gpcclass &= "   --class " & $selectionarray[$gcsub][$sCustomFunc]
		$gcmenurec &= "   " & $gcchotkey & "    " & $gpcclass & "  {"
		_ArrayAdd($autoarray, $gcmenurec)
		If $selectionarray[$gcsub][$sGraphMode] <> $graphnotset Then _ArrayAdd($autoarray, "     set gfxpayload=" & $selectionarray[$gcsub][$sGraphMode])
		GenGetOSFields ($gcsub, $autoarray, "normal")
		;If $selectionarray[$gcsub][$sAutoUser] <> "Custom" Then EndOSFields ($gcsub, $autoarray, $gcctempclass)
		If $selectionarray[$gcsub][$sFamily] <> "template" Then
			_ArrayAdd ($autoarray, "savelast " & $gcsub &     " '" & $selectionarray [$gcsub] [$sEntryTitle] & "'")
			If $selectionarray [$gcsub] [$sAutoUser] = "Auto" Then _
				_ArrayAdd ($autoarray, "echo GNU Grub is now loading  "    & $selectionarray [$gcsub] [$sEntryTitle])
		EndIf
		_ArrayAdd($autoarray, "}")
	Next
	CommonWriteLog("              Graphics theme - " & BasicCapIt (CommonThemeGetOption ("name")))
	If $graphset <> "None" Then CommonWriteLog ("              Graphics mode  - " & $graphset)
	CommonWriteLog("              " & $genline, 2)
	_ArrayAdd($autoarray, "#")
	_ArrayAdd($autoarray, "# end-grub2win-auto-menu-section     " & _StringRepeat("*", 51))
	_ArrayAdd($autoarray, "")
	CommonAddFileToArray ($sourcepath & $templatefunctions, $autoarray, "yes")
	If $isoneeded     = "yes" Then CommonAddFileToArray ($sourcepath & $templateiso,    $autoarray, "yes")
	For $gpcsearchsub = 0 To Ubound ($autoarray) - 1
		If StringInStr ($autoarray [$gpcsearchsub], "getbootpartition") Then $searchneeded = "yes"
	Next
	If $searchneeded = "yes" Then CommonAddFileToArray ($sourcepath & $templatesearch, $autoarray, "yes")
	_ArrayConcatenate($configarray, $autoarray)
	_ArrayConcatenate($configarray, $userarray)
	$gcrc = CommonArrayWrite($configfile, $configarray)
	If $gcrc <> 0 Then
		CommonWriteLog("                *** Update of the " & $configfile & " file failed ***")
		Return 1
	EndIf
EndFunc

Func GenGetOSFields ($gofsub, ByRef $gofarray, $gofnormsamp = "normal")
	Local $goflinux, $gofinitrd, $gofandroid, $gofbsd, $gofremix
	If $selectionarray[$gofsub][$sBootBy] = $modechainloader Then
		$gofchainstring = "set root='" & "(hd" & $selectionarray[$gofsub][$sDiskAddress]
		If $selectionarray [$gofsub] [$sPartAddress] > 0 Then $gofchainstring &= "," & $selectionarray [$gofsub] [$sPartAddress]
		$gofchainstring &= ")'"
	EndIf
	$goftype   = $selectionarray [$gofsub][$sOSType]
	$goffamily = $selectionarray [$gofsub][$sFamily]
	If $goffamily = "isoboot" Then $isoneeded = "yes"
	If $selectionarray [$gofsub] [$sReviewPause] > 0 Then _
		_ArrayAdd ($gofarray, "     set reviewpause=" & $selectionarray [$gofsub] [$sReviewPause])
	Select
		Case $goffamily = "windows"
			CommonAddFileToArray ($sourcepath & $templatewinauto, $gofarray)
			Return
		Case $selectionarray[$gofsub][$sAutoUser] = "Custom" And $gofnormsamp = "normal"
			_ArrayAdd($gofarray, "#")
			_ArrayAdd($gofarray, "# " & $customcodestart)
			CustomGenCode ($gofsub)
			_ArrayAdd($gofarray, "# " & $customcodeend)
			If $selectionarray[$gofsub][$sReviewPause] > 0 And $selectionarray[$gofsub][$sOSType] <> "isoboot" Then _
				_ArrayAdd ($gofarray, "sleep -i -v $reviewpause ; echo")
			Return
		Case $selectionarray[$gofsub][$sBootBy] = $modechainloader
			_ArrayAdd($gofarray, "     " & $gofchainstring)
			_ArrayAdd($gofarray, "     chainloader +1")
			Return
		Case $goffamily = "linux-deb"
			$goflinux  = "linux   /vmlinuz"
			$gofinitrd = "initrd  /initrd.img"
		Case $goffamily = "linux-sus"
			$goflinux  = "linux   /boot/vmlinuz"
			$gofinitrd = "initrd  /boot/initrd"
		Case $goffamily = "linux-fed"
			$goflinux  = "linux   /boot/vmlinuz"
			$gofinitrd = "initrd  /boot/initramfs.img"
		Case $goffamily = "linux-sla"
			$goflinux  = "linux   /boot/vmlinuz"
			$gofinitrd = "initrd  /boot/initrd.gz"
		Case $selectionarray[$gofsub][$sOSType] = "android"
			$gofandroid = "linux  $kernelfile   "
			$gofinitrd  = "initrd $bootdir/initrd.img"
		Case $selectionarray[$gofsub][$sOSType] = "remix"
			$gofremix   = "linux  " & $remixbootkern & "     root=/dev/ram0 "
			$gofinitrd  = "initrd " & $remixbootimg  & "    "
		Case $goffamily = "freebsd"
			$gofbsd     = "kfreebsd $bootfile"
		Case $goffamily = "template"
			 $selectionarray[$gofsub][$sBootBy] = "Direct Load"
			 CommonAddFileToArray ($sourcepath & $templatestring & $goftype & ".cfg", $gofarray)
			Return
		Case Else
			Return
	EndSelect
	If $selectionarray[$gofsub][$sBootBy] = $modepartaddress Then
		$gofroot = "root=" & CommonConvDevAddr($selectionarray[$gofsub][$sDiskAddress], $selectionarray[$gofsub][$sPartAddress])
		$gofstring = "     set root='" & "(hd" & $selectionarray[$gofsub][$sDiskAddress] & "," & $selectionarray[$gofsub][$sPartAddress] & ")'"
		_ArrayAdd($gofarray, $gofstring)
	ElseIf $selectionarray[$gofsub][$sBootBy] = $modepartlabel Then
		$gofroot = "root=LABEL=$partlabel"
		_ArrayAdd($gofarray, "     set partlabel=" & $selectionarray[$gofsub][$sSearchArg])
		_ArrayAdd($gofarray, "     getbootpartition  label  $partlabel")
	ElseIf $selectionarray[$gofsub][$sBootBy] = $modebootdir Then
		_ArrayAdd($gofarray, "     set bootdir=" & $selectionarray[$gofsub][$sSearchArg])
		_ArrayAdd($gofarray, "     set kernelfile=$bootdir/kernel")
		_ArrayAdd($gofarray, "     getbootpartition  file  $kernelfile")
	Else
		_ArrayAdd($gofarray, "     set bootfile=" & $selectionarray[$gofsub][$sSearchArg])
		_ArrayAdd($gofarray, "     getbootpartition  file   $bootfile")
	EndIf
	$gofparm = $selectionarray[$gofsub][$sBootParm]
	If StringInStr ($gofparm, "NullParm") Then $gofparm = ""
	If $goflinux   <> "" Then _ArrayAdd($gofarray, "     " & $goflinux   & "    " & $gofroot & "    " & $gofparm)
	If $gofandroid <> "" Then _ArrayAdd($gofarray, "     " & $gofandroid & "    " & $gofparm)
	If $gofremix   <> "" Then _ArrayAdd($gofarray, "     " & $gofremix            & $gofparm)
	If $gofinitrd  <> "" Then _ArrayAdd($gofarray, "     " & $gofinitrd)
	If $gofbsd     <> "" Then _ArrayAdd($gofarray, "     " & $gofbsd)
	If $selectionarray[$gofsub][$sAutoUser] = "Custom" And $gofnormsamp = "normal" Then Return
	If $selectionarray[$gofsub][$sReviewPause] > 0 And Not StringInStr ($selectionarray[$gofsub][$sOSType], "windows") Then
	    _ArrayAdd($gofarray, "     echo Boot disk address is  $root")
		_ArrayAdd($gofarray, "     echo The boot mode is      " & $selectionarray[$gofsub][$sBootBy])
		_ArrayAdd($gofarray, "     sleep -i -v $reviewpause ; echo")
	EndIf
	;_ArrayDisplay ($gofarray)
EndFunc

Func GenRebootBuild ($rbentry = 0)
	Select
		Case $rbentry = "none"
			$rbmsg  = "The next reboot has been disabled"
		Case Else
			If Not StringIsDigit ($rbentry) Or $rbentry > Ubound ($selectionarray) - 1 Then
				MsgBox ($mbwarnok, "Reboot Error", "** The menu entry number is invalid - " & $rbentry & " **")
				CommonEndit ("Failed")
			EndIf
			If $selectionarray [$rbentry] [$sDefaultOS] = "DefaultOS" And $defaultlastbooted = "no" Then
				MsgBox ($mbwarnok, "Reboot Error", "** Menu entry " & $rbentry & " is already the default **")
				CommonEndit ("Failed")
			EndIf
			$rbmsg  = "The next reboot is set to menu entry   " & $rbentry & "  " & $selectionarray [$rbentry] [$sEntryTitle]
			$rbentry = StringFormat ("%04d", $rbentry)
	EndSelect
	GenEnvReboot   ($rbentry)
	CommonWriteLog ()
	CommonWriteLog ("    ** Reboot **  " & $rbmsg)
	MsgBox ($mbinfook, "Reboot", $rbmsg & @CR & @CR & @CR & "This message will close in 10 seconds - Or click OK", 10)
	CommonEndit ("Success")
EndFunc

Func GenEnvReboot ($ervalue)
	If StringLen ($envdata) <> 1024 Then Return
	$erloc       = StringInStr ($envdata, $envparmreboot) + 15
	If $erloc    <  15 Then Return
	$ervalue     = CommonPadRight ($ervalue, 4)
	$envdata     = StringLeft ($envdata, $erloc) & $ervalue & StringTrimLeft ($envdata, $erloc + 4)
	$erhandle    = FileOpen ($envfile, $FO_OVERWRITE)
	If $erhandle =  -1 Then Return
	FileWrite    ($erhandle, $envdata)
	FileClose    ($erhandle)
EndFunc