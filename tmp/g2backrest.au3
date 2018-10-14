#include-once
#include  <g2common.au3>

Func BackupMake ($bmspacer = "yes")
	If $backupcomplete = "yes" Then Return
	If $bmspacer <> "" Then CommonWriteLog ()
	CommonWriteLog ("    Creating backups in " & $backuppath)
	$bmname      = "grub2win." & $firmwaremodelow & ".backup"
	$bmext       = "g2b"
	$bmarray     = CommonFileReadToArray ($configfile)
	$bmstamp     = FileGetTime     ($configfile, 0, 1)
	$bmbackfile  = $backuppath & "\" & $bmname & "."        & $bmext
	$bmlevel     = 0
	If $firmwaremode = "EFI" Then $bmlevel = CommonGetEFILevel ($storagepath, "yes")
	_ArrayInsert  ($bmarray, 0, $backupdelim & "FileStamp=" & $bmstamp & $backupdelim & "EFILevel="  & $bmlevel & $backupdelim)
	CommonBackStep (5, $bmname, $bmext, $backuppath)
	_FileWriteFromArray ($bmbackfile, $bmarray)
	If $bootos = $xpstring Then
		$bmname        = "xpboot.backup"
		$bmext         = "ini"
		CommonBackStep      (5, $bmname, $bmext, $backuppath)
		FileCopy      ($xpinifile, $backuppath & "\" & $bmname & "." & $bmext, 1)
	Else
		$bmname        = "winbcd." & $firmwaremodelow & ".backup"
		$bmext         = "bcd"
		CommonBackStep      (5, $bmname, $bmext, $backuppath)
		$bmwinbcdfile  = $backuppath & "\" & $bmname & "." & $bmext
		CommonBCDRun  ("/export " & $bmwinbcdfile, "export")
		FileDelete    ($backuppath & "\*.bcd.log*")
	EndIf
	$backupcomplete = "yes"
EndFunc

Func BackupChoose ()
	$bcmessage  = "                       ** Select a Grub2Win backup file to be restored **"
	$bcsearch   = "Grub2Win Backups (*." & $firmwaremodelow & "*.g2b)"
	$bcfile     = $backuppath & "\grub2win." & $firmwaremodelow & ".backup.g2b"
	$bcfilepath = FileOpenDialog ($bcmessage, $backuppath & "\", $bcsearch,  $FD_FILEMUSTEXIST, $bcfile, $handlemaingui)
	If @error Then
		$bcstatus = "cancelled"
	Else
		$bcstatus = BackupRestore ($bcfilepath)
	EndIf
	If  $bcstatus Then
		MsgBox ($mbinfook, "Restore Cancelled", "The Grub2Win restore was cancelled by the user")
		return 0
	EndIf
EndFunc

Func BackupRestore ($brpath)
	$brdisplay = StringReplace ($brpath, $backuppath & "\", "          ")
	$brbcd     = StringReplace ($brdisplay, "grub2win", "winbcd")
	$brbcd     = StringReplace ($brbcd,     "g2b",      "bcd")
	$brini     = StringReplace ($brdisplay, "grub2win", "xpboot")
	$brini     = StringReplace ($brini,     "g2b",      "ini")
	$brini     = StringReplace ($brini,     ".bios.",   ".")
	$brini     = StringReplace ($brini,     ".xp.",     ".")
	$brmsg     = "The Grub2Win settings will be restored from this backup:"  & @CR  & @CR & $brdisplay & @CR & @CR & @CR
	If $bootos = $xpstring Then
		$brmsg    &= "The Windows boot.ini file will also be restored from:" & @CR  & @CR & $brini & @CR & @CR & @CR
	Else
		$brmsg    &= "The Windows BCD will also be restored from:"           & @CR  & @CR & $brbcd     & @CR & @CR & @CR
	EndIf
	$brmsg    &= 'Please click "Yes" to confirm'                             & @CR  & @CR
	$brrc = MsgBox ($mbquestyesno, "Restore", $brmsg)
	If $brrc <> $IDYES Then Return "cancelled"
	$brarray  = CommonFileReadToArray ($brpath)
	$brsplit  = StringSplit    ($brarray [0], $backupdelim, 1)
	$brstamp  = StringTrimLeft ($brsplit [2], 10)
	$brlevel  = StringTrimLeft ($brsplit [3],  9)
	_ArrayDelete        ($brarray, 0)
	_FileWriteFromArray ($configfile, $brarray)
	FileSetTime         ($configfile, $brstamp)
	If $bootos = $xpstring Then
		$brinifile  = $backuppath & "\" & StringStripWS ($brini, 8)
		FileCopy ($brinifile, $xpinifile, 1)
	Else
		FileDelete    ($storagepath & $efilevelfile & ".*")
		If $firmwaremode = "EFI" Then
			FileWriteLine ($storagepath & $efilevelfile & "." & $brlevel & ".txt", "Placeholder for the Grub2Win EFI bootcode level")
		EndIF
		$brbcdfile  = $backuppath & "\" & StringStripWS ($brbcd, 8)
		CommonBCDRun  ("/import " & $brbcdfile & " /clean", "import")
	EndIf
	CommonWriteLog ()
	CommonWriteLog ("The Grub2Win settings were restored from backup: " & $brpath, 1, "")
	MsgBox ($mbinfook, "Restore", "The restore was successful" & @CR & @CR & 'Grub2Win will restart when you click "OK"')
	CommonEndIt  ("Restart")
EndFunc