#RequireAdmin
#include-once
#include  <g2common.au3>
#include  <g2utility.au3>
#include  <g2bcd.au3>

Const  $actioninstall     = "Install GNU Grub EFI Modules"
Const  $actionrefresh     = "Refresh GNU Grub EFI Modules"
Const  $actiondelete      = "Delete  GNU Grub EFI Modules"
Const  $actionskip        = "Skip Partition - No EFI Directory"
Const  $actionuninstall   = "Uninstall"
Const  $actionenable      = "Enable EFI Boot Master"
Const  $actiondisable     = "Disable EFI Boot Master"
Const  $actiondircopy     = "Copy The EFI To A Directory"
Const  $actionkeeppart    = "Keep EFI Partition Letter "
Const  $actionrelpart     = "Release EFI Partition Letter "
Const  $actionnone        = "No Action"

Func EFIMain ($emruntype, $emguihandle, $emcaller)

	EFIPrepare        ($emguihandle, $emcaller)

	If $efierrorsfound = "yes" Then
		EFICloseOut ($emruntype, $emguihandle, $emcaller)
		Return
	EndIf

	EFIAssignAll      ()

	EFIDisplay        ($emruntype, $emcaller)

	EFIUpdateParts    ($emruntype)

	EFICloseOut       ($emruntype, $emguihandle, $emcaller)
EndFunc

Func EFIPrepare ($epcallhandle = "", $epcaller = "")
	CommonWriteLog   ()
	CommonWriteLog   ("    EFI Update Starts at " & @HOUR & ":" & @MIN & ":" & @SEC)
	$efimilsec         = TimerInit ()
	$utillogfilehandle = FileOpen  ($utillogfile, 2)
	$efipartitioncount = 0
	$efipartarray      = UtilScanDisks ("EFI Update", $epcallhandle, $epcaller)
	If $efipartitioncount > 5 Then
		UtilProcessError ("Too Many EFI System Partitions!     Max = 5", $efipartitioncount & " Were Found       Run Aborted")
		Return
	EndIf
	$sdmsg = "1 EFI System Partition was found"
	If $efipartitioncount > 1 Then $sdmsg = $efipartitioncount & "  EFI System Partitions were found"
	UtilDiskWriteLog  ()
	UtilDiskWriteLog  ($sdmsg)
	If $efipartitioncount = 0 Then
		UtilProcessError ("No EFI System partitions were found!", "Run Aborted")
		Return
	EndIf
	$eficodesize        = DirGetSize ($bootmanpath)
	$sdsizeformat       = StringFormat ("%4.1f", $eficodesize / $mega)
	$eficodesize        = Int ($eficodesize * 1.2)
	$efierrorsfound     = ""
	$eficancelled       = ""
	UtilDiskWriteLog ("")
	UtilDiskWriteLog ("Starting EFI Update at " & BasicTimeLine ())
	If CommonParms   ($advancedmode) Then UtilDiskWriteLog ("** Running In Advanced Mode **")
	UtilDiskWriteLog ()
	UtilDiskWriteLog ("The GNU Grub Modules Require " & $sdsizeformat & " MB Of Space In The EFI Partition")
	UtilDiskWriteLog ()
	CommonCheckpointLog ($utillogfile, $utillogfilehandle)
	;_ArrayDisplay ($efipartarray)
EndFunc

Func EFIAssignAll ()
	For $eaasub = 0 To Ubound ($efipartarray) - 1
		If $efipartarray [$eaasub] [$pIsEFIPart] = "" Then ContinueLoop
		$eaadiskno    = $efipartarray [$eaasub] [$pDiskNumber]
		$eaapartno    = $efipartarray [$eaasub] [$pPartNumber]
		$eaaoldletter = $efipartarray [$eaasub] [$pDriveLetterOld]
		$eaamediadesc = $efipartarray [$eaasub] [$pDriveMediaDesc]
		If $eaaoldletter = "" Then EFISetPartLetter ($eaadiskno, $eaapartno, $eaaoldletter, "release", $eaasub)
		$eaaletter = $efipartarray [$eaasub] [$pDriveLetterNew]
		If $eaaletter = "" Then
			$eaaletter = EFIGetLetter ($efipartarray)
			EFISetPartLetter ($eaadiskno, $eaapartno, $eaaletter, "assign", $eaasub)
		EndIf
		UtilDiskWriteLog (_StringRepeat ("_", 95))
	    UtilDiskWriteLog ()
		If Not FileExists ($eaaletter & "\efi") Then
			$noefimsg = "    ** " & $eaamediadesc & "  " & $eaadiskno & "  Fat32 Partition " & _
				$eaapartno & "  has no \EFI directory **"
			CommonWriteLog    ($noefimsg)
			UtilDiskWriteLog ($noefimsg)
			$efipartarray [$eaasub] [$pAction] = $actionskip
			ContinueLoop
		EndIf
		UtilDiskWriteLog ("Found An EFI Partition On " & $eaamediadesc & "  " & $eaadiskno & "  Partition " & _
			$eaapartno & "  -   Using Letter " & $eaaletter)
		UtilDiskWriteLog ()
		EFIListStats  ($eaadiskno, $eaapartno, $eaaletter, $eaasub, $eaamediadesc)
	Next
	CommonCheckpointLog ($utillogfile, $utillogfilehandle)
EndFunc

Func EFIDisplay ($edruntype, $edcaller)
	If $edruntype = $actionuninstall Or $edruntype = $actiondisable Or $edcaller = $setupstring Then Return
	If $efierrorsfound = "yes" Then Return
	$edbump  = 100
	$eficonfguihandle = GuiCreate ("Grub2Win EFI Confirmation - New Level " & _
		$latestefilevel, 575, 200 + ($efipartitioncount * $edbump), -1, -1, -1, "", $utillogguihandle)
	$edstringall  = $actionrefresh & "|" & $actiondelete
	$edstringnew  = $actioninstall
	$edhelphandle = GuiCtrlCreateButton ("Help", 350, 20, 80, 35)
	GUICtrlSetBkColor ($edhelphandle, $mymedblue)
	GuiCtrlCreateLabel    ("Disk",           45,  75, 60, 20)
	GuiCtrlCreateLabel    ("Partition",     125,  75, 80, 20)
	GuiCtrlCreateLabel    ("Drive Letter",  210,  75, 80, 20)
	GuiCtrlCreateLabel    ("Action",        370,  75, 80, 20)
	$edvert = 95
	For $edsub = 0 To Ubound ($efipartarray) - 1
		If $efipartarray [$edsub] [$pIsEFIPart] = "" Then ContinueLoop
		$edstring  = $edstringnew
		$eddefault = $actioninstall
		$edletter  = $efipartarray [$edsub] [$pDriveLetterNew]
		If $efipartarray [$edsub] [$pGrubFound] = $foundstring Then
			$edstring  = $edstringall
			$eddefault = $actionrefresh
			If CommonParms ($advancedmode) Then
				$edmaststub   = ""
				$edmasterfile = $edletter & $efimasterstring
				If FileExists ($edmasterfile & ".disabled") Then $edmaststub &= "|" & $actionenable
				If FileExists ($edmasterfile)               Then $edmaststub &= "|" & $actiondisable
				$edmaststub &= "|" & $actiondircopy
				$edmaststub &= "|" & $actionkeeppart & " " & $edletter
				If $efipartarray [$edsub] [$pDriveLetterOld] <> "" Then $edmaststub &= "|" & $actionrelpart  & " " & $edletter
				$edstring   &= $edmaststub
			EndIf
		EndIf
		$edstring &= "|" & $actionnone
		GuiCtrlCreateLabel     ($efipartarray [$edsub] [$pDiskNumber],      55, $edvert,       20, 20)
		GuiCtrlCreateLabel     ($efipartarray [$edsub] [$pPartNumber],     145, $edvert,       20, 20)
		GuiCtrlCreateLabel     ($efipartarray [$edsub] [$pDriveLetterNew], 235, $edvert,       20, 20)
		GuiCtrlCreateLabel     ($efipartarray [$edsub] [$pPartInfo],        30, $edvert + 30, 545, 20)
		GuiCtrlCreateLabel     (_StringRepeat ("_", 520),        0, $edvert + 50, 575, 20)
		$efipartarray [$edsub] [$pConfirmHandle] = GuiCtrlCreateCombo ("" ,  310, $edvert - 2, 220, 20)
		If $efipartarray [$edsub] [$pAction] = $actionskip Then
			$edstring  = $actionskip
			$eddefault = $actionskip
		EndIf
		GuiCtrlSetData         ($efipartarray [$edsub] [$pConfirmHandle], $edstring, $eddefault)
		$efipartarray [$edsub] [$pAction] = $eddefault
		$edvert += $edbump
	Next
	$edmsg = "Note: Drive letters are temporarily assigned and will be released after the update"
	            GuiCtrlCreateLabel  ($edmsg,    30,  $edvert,      500,  20)
	$edcancel = GuiCtrlCreateButton ("Cancel",  50,  $edvert + 40,  70,  20)
	$edaccept = GuiCtrlCreateButton ("Accept", 400,  $edvert + 40,  70,  20)
	GUICtrlSetState ($edaccept, $GUI_FOCUS)
	GUISetBkColor   ($mypurple,$eficonfguihandle)
	GUISetState     (@SW_SHOW, $eficonfguihandle)
	UtilDiskWriteLog (_StringRepeat ("_", 95))
	UtilDiskWriteLog ()
	UtilDiskWriteLog ("Ready For Update   -    Waiting For User Confirmation")
	CommonCheckpointLog ($utillogfile, $utillogfilehandle)
	While 1
        $edmsg = GUIGetMsg()
		$edstatus = "no"
		$edchange = "no"
		For $edsub = 0 To Ubound ($efipartarray) - 1
			If $efipartarray [$edsub] [$pIsEFIPart] = "" Then ContinueLoop
			If $edmsg = $efipartarray [$edsub] [$pConfirmHandle] Then
				$efipartarray [$edsub] [$pAction] = StringStripWS (GUICtrlRead ($efipartarray [$edsub] [$pConfirmHandle]), 3)
				$edchange = "yes"
			EndIf
			If $efipartarray [$edsub] [$pAction] <> $actionnone Then $edstatus = "yes"
		Next
		If $edchange = "yes" Then
			If $edstatus = "yes" Then
				GUICtrlSetState ($edaccept, $guishowit)
				GUICtrlSetState ($edaccept, $GUI_FOCUS)
			Else
				GUICtrlSetState ($edaccept,	$guihideit)
			EndIf
		EndIf
		Select
			Case $edmsg = ""
			Case $edmsg = $GUI_EVENT_CLOSE Or $edmsg = $edcancel
				$eficancelled = "yes"
				Return
			Case $edmsg = $edhelphandle
				CommonHelp ("EFIupdateconfirmation")
			Case $edmsg = $edaccept
				ExitLoop
		EndSelect
    WEnd
	Return
EndFunc

Func EFIUpdateParts ($upruntype)
	GUISetState (@SW_RESTORE, $utillogguihandle)
	If $efierrorsfound = "yes" Then Return
	If $eficonfguihandle <> "" Then GuiDelete  ($eficonfguihandle)
	;_ArrayDisplay ($efipartarray)
	For $upsub = 0 To Ubound ($efipartarray) - 1
		If $efipartarray [$upsub] [$pIsEFIPart] = "" Then ContinueLoop
		$updiskno = $efipartarray [$upsub] [$pDiskNumber]
		$uppartno = $efipartarray [$upsub] [$pPartNumber]
		$upletter = $efipartarray [$upsub] [$pDriveLetterNew]
		$upoldlet = $efipartarray [$upsub] [$pDriveLetterOld]
		$upaction = $efipartarray [$upsub] [$pAction]
		$updesc   = $efipartarray [$upsub] [$pDriveMediaDesc]
		$upkeepit = $actionkeeppart & " " & $upletter
		$uprelit  = $actionrelpart  & " " & $upletter
		If $upruntype = $actionuninstall Then $upaction = $actiondelete
		If $eficancelled = "" And $upaction <> $actionnone Then BackupMake ("")
		Select
			Case $eficancelled <> "" Or $upaction  = $actionnone
			Case $efipartarray [$upsub] [$pAction] = $actionskip
			Case $upaction    = $actiondisable
				EFIDisableMaster ($updiskno, $uppartno, $upletter, $updesc)
			Case $upaction    = $actionenable
				EFIEnableMaster  ($updiskno, $uppartno, $upletter, $updesc)
			Case $upaction    = $actiondircopy
				EFIMasterCopy    ($updiskno, $uppartno, $upletter, $updesc)
			Case $upaction    = $upkeepit
			Case $upaction    = $uprelit
				$upoldlet     = ""
			Case Else
				EFIUpdateFiles  ($updiskno, $uppartno, $upletter, $upaction, $upsub)
		EndSelect
		UtilDiskWriteLog ()
		If $upaction = $upkeepit Or $upoldlet <> "" Then ContinueLoop
		UtilDiskWriteLog ("Releasing Drive Letter " & $upletter & " From " & _
			$updesc & " " & $updiskno & "  Partition " & $uppartno)
		EFISetPartLetter  ($updiskno, $uppartno, $upletter, "release", $upsub)
	Next
	CommonCheckpointLog   ($utillogfile, $utillogfilehandle)
EndFunc

Func EFIUpdateFiles ($ufdiskno, $ufpartno, $ufletter, $ufaction, $ufsub)
	$uflvldesc = $efipartarray [$ufsub] [$pDriveMediaDesc]
	$ufdest    = $uflvldesc & " " & $ufdiskno & "    Partition " & $ufpartno & "    Letter " & $ufletter
	$uflvldel  = " Level " & $efipartarray [$ufsub] [$pEFILevel] & "  "
	$uflvladd  = " Level " & $latestefilevel & "  "
	$uflvllog  = $uflvladd
	$ufinstmsg1 = "Installing The GNU Grub EFI" & $uflvladd & "Modules "
    $ufinstmsg2 = "To " & $ufdest
	If $ufaction = $actionrefresh Then
		$ufinstmsg1 = "Refreshing The GNU Grub EFI Modules On " & $ufdest & " "
		$ufinstmsg2 = "To" & $uflvladd
	EndIf
	If $ufaction = $actiondelete  Then
		$ufinstmsg1 = "Deleting   The GNU Grub EFI Modules From "
		$ufinstmsg2 = $ufdest
		$uflvllog   = $uflvldel
		$efipartarray [$ufsub] [$pGrubFound] = ""
		If FileExists ($ufletter & $efimasterstring & ".disabled") And Not FileExists ($ufletter & $efimasterstring) Then
		   EFIEnableMaster  ($ufdiskno, $ufpartno, $ufletter, $uflvldesc)
		EndIf
		$efideleted = "yes"
		BCDCleanup ()
	EndIf
	UtilDiskWriteLog ()
	UtilDiskWriteLog ($ufinstmsg1 & $ufinstmsg2)
	CommonWriteLog    ("    " &      $ufinstmsg1)
	CommonWriteLog    ("        " &  $ufinstmsg2)
	CommonCheckpointLog ($utillogfile, $utillogfilehandle)
	$ufrc = 1
	If FileExists ($ufletter & "\EFI\grub2win") Then $ufrc = DirRemove ($ufletter & "\EFI\grub2win", 1)
	If $ufrc <> 1 Then
		UtilProcessError ("Directory delete failed " & $ufletter & "\EFI\grub2win - Run Cancelled")
		Return
	EndIf
	$grubcfgefilevel = ""
	FileDelete ($storagepath & "\*.efilevel.*")
	If $ufaction = $actiondelete Then Return
	$uffreespace = Int (DriveSpaceFree ($ufletter & "\")) * ($mega)
	If $eficodesize > $uffreespace Then
		$ufspacemessage  = "Freespace required   -  " & $eficodesize & " bytes" & @CR & @CR
		$ufspacemessage &= "Freespace available  -  " & $uffreespace & " bytes"
		MsgBox ($mberrorok, "** Your EFI Partition Is Full **", $ufspacemessage, 120)
		UtilProcessError  ("** There is not enough free space in your EFI partition - Drive " & $ufletter & " - Run Cancelled")
		Return
	EndIf
	$grubcfgefilevel = $latestefilevel
	GUICtrlSetBkColor ($buttonrunefi, $mymedblue)
	If $efideleted = "" Then FileCopy ($bootmanpath & $efilevelfile & ".*", $storagepath, 1)
	$uftargetpath = $ufletter & $efitargetstring
	$ufrc = DirCreate ($uftargetpath)
	If $ufrc <> 1 Then
		UtilProcessError ("Directory create failed " & $uftargetpath & " - Run Cancelled")
		Return
	EndIf
	$ufrc = DirCopy ($bootmanpath, $uftargetpath, 1)
	If $ufrc <> 1 Then
		UtilProcessError ("Directory copy failed " & $uftargetpath & " - Run Cancelled")
		Return
	EndIf
	FileDelete ($uftargetpath & "\*.xp")
	FileDelete ($uftargetpath & "\*.bios")
	$bcbits       = StringMid ($bootmanefi, 15, 2)
	$bcefimessage = "Setting up Grub2Win to run with " & $bcbits & " bit EFI firmware"
	UtilDiskWriteLog ()
	UtilDiskWriteLog (         $bcefimessage)
	CommonWriteLog   ("    " & $bcefimessage)
	$ufgrubloc = _ArraySearch ($bootarray, $firmgrub)
	If @error Then
		$bcdgrubbootid = BCDSetupEFI ($bcbits)
	Else
		$bcdgrubbootid = $bootarray [$ufgrubloc] [$bGUID]
		$bootarray                  [$ufgrubloc] [$bPath] = '\EFI\grub2win\' & $bootmanefi
		CommonBCDRun ('/set ' & $bcdgrubbootid & ' path ' & $bootarray [$ufgrubloc] [$bPath], "bcdpath")
		BCDGetBootArray ()
	EndIf
	BCDSetBootsequence ($bcdgrubbootid, "efiupdate")
EndFunc

Func EFIDisableMaster ($dmdiskno, $dmpartno, $dmletter, $dmdesc)
	$dmmasterfile = $dmletter & $efimasterstring
	$dmlocation =  "The EFI Boot Master Module " & $dmmasterfile & " " & @CR
	$dmlocation &= "on " & $dmdesc & " " & $dmdiskno & "  Partition " & $dmpartno
	$dmwarn =  $dmlocation & @CR & "Will Be Disabled" & @CR & @CR
	$dmwarn &= "Disabling the master EFI boot module may cause boot problems!!" & @CR
	$dmwarn &= "Please make sure you have a good backup of your EFI partition"    & @CR & @CR
	$dmwarn &= "Click OK or Cancel" & @CR
	$dmrc = MsgBox ($mbwarnokcan, "Confirmation", $dmwarn)
	If $dmrc <> $IDOK Then
		MsgBox ($mbwarnok, "Disable Cancelled", $dmlocation & @CR & @CR & " Will Not Be Disabled", 60)
		Return
	EndIf
	FileMove ($dmmasterfile, $dmmasterfile & ".disabled", 1)
	CommonWriteLog ("The EFI Boot Master Has Been Disabled")
	UtilDiskWriteLog ($dmlocation & " Has Been Disabled")
EndFunc

Func EFIEnableMaster ($emdiskno, $empartno, $emletter, $emdesc)
	$emmasterfile = $emletter & $efimasterstring
	$emlocation =  "The EFI Boot Master Module " & $emmasterfile & " " & @CR
	$emlocation &= "on " & $emdesc & " " & $emdiskno & "  Partition " & $empartno
	$emwarn =  $emlocation & @CR & "Will Be Enabled" & @CR & @CR
	$emwarn &= "Click OK or Cancel" & @CR
	$emrc = MsgBox ($mbwarnokcan,"Confirmation", $emwarn)
	If $emrc <> $IDOK Then
		MsgBox ($mbwarnok, "Enable Cancelled", $emlocation & @CR & @CR & "Will Not Be Enabled", 60)
		Return
	EndIf
	FileMove ($emmasterfile & ".disabled", $emmasterfile, 1)
	CommonWriteLog ("The EFI Boot Master Has Been Enabled")
	UtilDiskWriteLog ($emlocation & " Has Been Enabled")
EndFunc

Func EFIMasterCopy ($mcdiskno, $mcpartno, $mcletter, $mcdesc)
	$mcdir  =  $windowsdrive & "\EFI-Copy-Disk-" & $mcdiskno & "-Partition-" & $mcpartno
	$mcwarn =  "The Contents Of Directory " & $mcletter & "\EFI" & @CR & @CR
	$mcwarn &= "on " & $mcdesc & " " & $mcdiskno & "  Partition " & $mcpartno & @CR & @CR
	$mcwarn &= " will be copied to directory " & @CR & $mcdir & @CR & @CR & @CR
	$mcwarn &= "Click OK or Cancel" & @CR
	$mcrc = MsgBox ($mbwarnokcan, "Confirmation", $mcwarn)
	If $mcrc <> $IDOK Then
		MsgBox ($mbwarnok, "EFI Directory Copy", "The Directory Copy Was Cancelled", 60)
		Return
	EndIf
	DirRemove ($mcdir, 1)
	$mchandle = FileFindFirstFile ($mcletter & "\EFI\*.*")
	If $mchandle = -1 Then MsgBox ($mberrorok, "Error", "Error Reading The EFI")
	While 1
		$mcname = FileFindNextFile ($mchandle)
		If @error Then ExitLoop
		If Not StringInStr (FileGetAttrib ($mcletter & "\EFI\" & $mcname), "D") Then ContinueLoop
		If $mcname = "Microsoft" Then ContinueLoop
		DirCopy ($mcletter & "\EFI\" &$mcname, $mcdir & "\EFI\" & $mcname, 1)
	Wend
	FileCopy  ($mcletter     & "\EFI\*.*",  $mcdir & "\EFI\", 1)
	DirCreate ($mcdir                              & "\EFI\Microsoft\Boot")
	DirCopy   ($windowsdrive & "\Boot" ,    $mcdir & "\EFI\Microsoft\Boot", 1)
	FileCopy  ($windowsdrive & "\Boot\*.*", $mcdir & "\EFI\Microsoft\Boot\", 1)
	FileCopy  ($mcletter     & "\EFI\Microsoft\Boot\*.dll",  $mcdir & "\EFI\Microsoft\Boot\", 1)
	FileCopy  ($mcletter     & "\EFI\Microsoft\Boot\*.efi",  $mcdir & "\EFI\Microsoft\Boot\", 1)
	DirCopy   ($mcletter     & "\EFI\Microsoft\Recovery" ,   $mcdir & "\EFI\Microsoft\Recovery", 1)
EndFunc

Func EFICloseOut ($coruntype, $cocallhandle, $cocaller)
	If $coruntype = $actionuninstall Then Return
	$ecflag = "  -  No Errors Found"
	Select
		Case $efierrorsfound = "yes"
			$cocolor = $myred
			$ecmessage = "   **  Grub2Win EFI Update Failed!!  **"
			$ecflag    = "      **  A Severe Error Occurred  **"
			CommonDiagnose ($diagerrorcode)
		Case $eficancelled   = "yes"
			$cocolor = $myyellow
			$ecmessage = "** Grub2Win EFI Update Was Cancelled By User **"
			$ecflag    = "      **  Cancelled By User  **"
		Case Else
			$efideleted = ""
			$ecmessage  = "   **  Grub2Win EFI Update Successfully Completed  **"
			$cocolor    = $mygreen
	EndSelect
	UtilDiskWriteLog ()
	UtilDiskWriteLog ($ecmessage)
	CommonWriteLog    ("    Ending EFI Update" & $ecflag)
	UtilDiskWriteLog ()
	UtilDiskWriteLog ("Ending EFI Update at " & BasicTimeLine () & "    Duration " & CommonCalcDuration ($efimilsec))
	FileClose ($utillogfilehandle)
	FileCopy  ($utillogfile, $efilogfile, 1)
	If CommonParms ($actionsilent) Then Return
	GUISetBkColor     ($cocolor, $utillogguihandle)
	GUICtrlSetBKColor ($utillogtxthandle,   $cocolor)
	If $cocaller = $callermain Then GUICtrlSetState   ($utillogclosehandle, $guishowit + $GUI_FOCUS)
	If Not $efierrorsfound And $coruntype <> $actiondisable Then GUICtrlSetState ($utillogreturnhandle, $guishowit)
	GUISetState       (@SW_SHOW, $utillogguihandle)
	UtilDiskGUIWait ($cocallhandle, $cocaller)
	$esctype = "Main"
	If $efierrorsfound = "yes" Then CommonEndIt ("Failed")
	If $efiexit        = "yes" Then CommonEndIt ("Cancelled")
EndFunc

Func EFISetPartLetter ($epdiskno, $eppartno, $epletter, $eptype, $epsub)
	If $efierrorsfound = "yes" Then Return
	If $eptype = "assign"  And DriveStatus ($epletter & "\") =  "READY" Then Return
	If $eptype = "release" And DriveStatus ($epletter & "\") <> "READY" Then Return
	$ephandle = FileOpen ($diskpartprefix & "efipartletter." & $eptype & $filesuffixin, 2)
	FileWriteLine ($ephandle, "Select Disk "      & $epdiskno)
	FileWriteLine ($ephandle, "Select Partition " & $eppartno)
	If $eptype = "release" Then
		FileWriteLine ($ephandle, "Remove Letter " & $epletter)
        $efipartarray [$epsub] [$pDriveLetterNew] = ""
	EndIf
	If $eptype = "assign"  Then
		FileWriteLine ($ephandle, "Assign Letter " & $epletter)
		$efipartarray [$epsub] [$pDriveLetterNew]  = $epletter
	EndIf
	UtilRunDiskPart ("efipartletter." & $eptype)
	Sleep (250) ; Allow diskpart assign & release time to stabilize
EndFunc

Func EFIListStats ($elsdiskno, $elspartno, $elsletter, $elspartsub, $elsmediadesc)
	$elshandle = FileFindFirstFile ($elsletter & "\EFI\*.*")
	If $elshandle = -1 Then Return
	UtilDiskWriteLog ("The Following Directories Were Found In   " & $elsletter & "\EFI   On  " & _
		$elsmediadesc & "  " & $elsdiskno & "   Partition " & $elspartno & ":")
	$elsefilevel = "none"
	While 1
		$elsfile = FileFindNextFile ($elshandle)
		If @error Then ExitLoop
		If Not @extended Then ContinueLoop
		If $elsfile = "grub2win" Then
			$elsefilevel = CommonGetEFILevel ($elsletter & "\EFI\grub2win")
			If $elsefilevel <> "none" Then $efipartarray [$elspartsub] [$pEFILevel] = $elsefilevel
			$efipartarray [$elspartsub] [$pGrubFound] = $foundstring
		EndIf
		UtilDiskWriteLog ("     " & $elsfile)
	WEnd
	FileClose ($elshandle)
	UtilDiskWriteLog ()
	$elsdriveletter = $efipartarray [$elspartsub] [$pDriveLetterNew]
	$elssize  = Int (DriveSpaceTotal ($elsdriveletter))
	$elsfree  = Int (DriveSpaceFree  ($elsdriveletter))
	$elslabel = CommonGetLabel ($elsdriveletter)
	$efipartarray [$elspartsub] [$pPartLabel] = $elslabel
	$elsused  = $elssize - $elsfree
	$elspct   = StringFormat ("%4.1f", 100 * ($elsused / $elssize)) & "%"
	$elsinfo  = $efipartarray [$elspartsub] [$pDriveLetterNew] & " EFI Partition "
	$elsinfo  &= CommonFormatSize ($elssize * $mega) & "        Used  " & CommonFormatSize ($elsused * $mega)
	$elsinfo  &= "    " & $elspct & "  Full         EFI Module Level = "  & $elsefilevel & "       Label = " & $elslabel
	$efipartarray [$elspartsub] [$pPartInfo] = $elsinfo
	UtilDiskWriteLog ($elsinfo)
	CommonCheckpointLog ($utillogfile, $utillogfilehandle)
	Sleep (2000)
EndFunc

Func EFIGetLetter ($glpartarray)
	$glstring = "mnopqrstuvwxyz"
	$glarray  = DriveGetDrive ("ALL")
	For $glsub = 1 To StringLen ($glstring)
		$gldisk = StringMid ($glstring, $glsub, 1) & ":"
		If _ArraySearch ($glarray,     $gldisk)                   >= 0 Then ContinueLoop
		If _ArraySearch ($glpartarray, $gldisk, 0, 0, 0, 0, 0, 2) >= 0 Then ContinueLoop
		$glstring = StringReplace ($glstring, $gldisk, "")
		Return StringUpper ($gldisk)
	Next
	UtilProcessError ("Not enough available drive letters were found!", "Run Aborted")
	Return
EndFunc