#RequireAdmin
#include-once
#include  <g2common.au3>

Const  $efiguid         = "C12A7328-F81F-11D2-BA4B-00A0C93EC93B"

Const  $partfieldcount  = 22                  ; Partitition array subscripts
Const  $pDiskNumber     =  0, $pPartNumber     =  1, $pDriveLetterOld =  2, $pDriveLetterNew =  3, $pPartFileSystem =  4
Const  $pPartLabel      =  5, $pPartOffset     =  6, $pPartSize       =  7, $pPartFreeSpace  =  8, $pPartType       =  9
Const  $pPartInfo       = 10, $pConfirmHandle  = 11, $pEFILevel       = 12, $pIsEFIPart      = 13, $pAction         = 14
Const  $pGrubFound      = 15, $pSortCode       = 16, $pDriveMediaDesc = 17, $pDriveLabel     = 18, $pDriveSize      = 19
Const  $pDriveUsed      = 20, $pDriveStyle     = 21, $pDrivePartCount = 22

If StringInStr (@ScriptName, "g2utility") Then
	_ArrayDisplay (UtilScanDisks ())
	CommonNotepad ($diskreportpath)
EndIf

Func UtilScanDisks ($sdtitle = "", $sdcallhandle = "", $sdcaller = "")
	$sdpartcount = 0
	Dim $sdpartarray [0] [$partfieldcount + 1]
	If Not CommonParms ($actionsilent) Then UtilDiskGUISetup ($sdtitle, $sdcallhandle, $sdcaller)
	$sddiskarray = UtilGetDiskArray    ()
	For $sdsub = 0 To Ubound ($sddiskarray) - 1
		$sdpartcount += UtilUpdatePartArray ($sdpartarray, $sddiskarray [$sdsub])
	Next
	UtilPartitionReport ($sdpartarray)
	$sdmsg = "1 Partition was found"
	If $sdpartcount > 1 Then $sdmsg = "A total of  " & $sdpartcount & "  Partitions were found"
	UtilDiskWriteLog  ()
	UtilDiskWriteLog  ($sdmsg)
	;_ArrayDisplay ($sdpartarray)
	Return $sdpartarray
EndFunc

Func UtilPrepareObjects ($poobjectname, ByRef $poWMISvc, ByRef $poColObjects)
	$poWMISvc     = ObjGet ("winmgmts:\\" & @ComputerName & "\root\cimv2")
	$poColObjects = $poWMISvc.ExecQuery ("SELECT * FROM " & $poobjectname)
EndFunc

Func UtilGetDiskArray ()
	Dim $gdadiskarray [0]
	Local $gdacolDiskDrives
	If CommonParms   ($advancedmode) Then UtilDiskWriteLog ("** Running In Advanced Mode **")
	UtilDiskWriteLog ("Spinning Up And Scanning Disks", "startline")
	UtilDiskWriteLog ("  -  The Partition Scan May Take Up To 60 seconds", "endline")
	UtilDiskWriteLog ()
	Sleep       (250)
	UtilPrepareObjects ("Win32_DiskDrive", $dummyparm, $gdacolDiskDrives)
	For $dummyparm In $gdacolDiskDrives
		$gdadisknumber   = StringTrimLeft ($dummyparm.DeviceId, 17)
		_ArrayAdd ($gdadiskarray, $gdadisknumber)
	Next
	$gdadiskcount = Ubound ($gdadiskarray)
	If $gdadiskcount = 0 Then
		UtilProcessError ("No drives were detected!", "Run Aborted")
		Return
	EndIf
	$gdadiskmsg = "1 disk drive was detected"
	If $gdadiskcount > 1 Then $gdadiskmsg = $gdadiskcount & " disk drives were detected"
	UtilDiskWriteLog ($gdadiskmsg)
	UtilDiskWriteLog ()
	_ArraySort       ($gdadiskarray)
	;_ArrayDisplay ($gdadiskarray)
	Return ($gdadiskarray)
EndFunc

Func UtilUpdatePartArray (ByRef $upaarray, $upadriveprocess = "")
	Local $upaoDiskDrive, $upaoLogicalDisk, $upaoPartition  ; Dummys for RefCheck
	Local $upaoWMISvc, $upacolDiskDrives, $upadrivesub
	$upapartcount = 0
	UtilPrepareObjects ("Win32_DiskDrive", $upaoWMISvc, $upacolDiskDrives)
	For $upaoDiskDrive In $upacolDiskDrives
		$upadiskno   = StringTrimLeft ($upaoDiskDrive.DeviceId, 17)
		If $upadriveprocess <> "" And $upadriveprocess <> $upadiskno Then ContinueLoop
		$upadrivelabel   = $upaoDiskDrive.Caption
		$upamediatype    = $upaoDiskDrive.MediaType
		$upadrivesize    = Number ($upaoDiskDrive.Size)
		$upamediadesc    = "Disk "
		If $upamediatype = "Removable Media" Then $upamediadesc = "Flash"
		_ArrayAdd ($upaarray, $upadiskno & "|" & 0)
		$upasub          = Ubound ($upaarray) - 1
		$upaarray [$upasub] [$pDriveLabel]     = $upadrivelabel
		$upaarray [$upasub] [$pDriveSize]      = $upadrivesize
		$upaarray [$upasub] [$pDriveMediaDesc] = $upamediadesc
		$upaarray [$upasub] [$pSortCode]   = $upadiskno & "-000"
		$upadrivesub     = $upasub
		UtilDiskWriteLog  ("Examining " & $upamediadesc & "  " & $upadiskno, "startline")
		$sQuery = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" & $upaoDiskDrive.DeviceId & _
			      "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition"
		$colPartitions = $upaoWMISvc.ExecQuery($sQuery)
       	$upaoffset     = ""
		$upastyle      = "Unknown"
		$upaadjust     = 1
		$upaeficount   = 0
		For $upaoPartition In $colPartitions
			$upapartcount += 1
			If $upaoffset = "" Then $upaoffset = Number ($upaoPartition.StartingOffset)
			$upatype = $upaoPartition.type
			$upastyle = "MBR"
			If StringInStr ($upatype, "GPT") Then $upastyle = "GPT"
			$upasplit  = StringSplit ($upaoPartition.DeviceId, "#")
			$upapartno = ""
			If UBound ($upasplit) > 2 Then $upapartno = $upasplit [3]
			If $upapartno = 0 And $upaoffset = 129 * $mega Then
				UtilReserved ($upaarray, $upadiskno, $upadrivesub)
				$upaadjust   = 2
			EndIf
			$upapartno += $upaadjust
			_ArrayAdd ($upaarray, $upadiskno & "|" & $upapartno)
			$upasub       = Ubound ($upaarray) - 1
			$upaarray [$upasub] [$pDriveMediaDesc] = $upamediadesc
			$upaarray [$upasub] [$pSortCode]       = $upadiskno & "-" & StringFormat ("%03d", $upapartno)
			$upaarray [$upasub] [$pPartType]       = $upatype
			$upaarray [$upasub] [$pPartOffset]     = Number ($upaoPartition.StartingOffset)
			$upapartsize = Number ($upaoPartition.Size)
			;MsgBox ($mbontop, "Size " & $upadiskno & " " & $upapartno, $upapartsize & @CR & $upadrivesize)
			If $upapartsize > $upadrivesize Then $upapartsize = $upadrivesize
			$upaarray [$upasub] [$pPartSize]       =  $upapartsize
			$upaarray [$upadrivesub] [$pDriveUsed] += $upapartsize
			If $upapartno = 0 Then $upaarray [$upasub] [$pDriveLabel] = $upadrivelabel
			$sQuery = "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" & _
				$upaoPartition.DeviceId & "'} WHERE AssocClass = Win32_LogicalDiskToPartition"
			$colLogicalDisks = $upaoWMISvc.ExecQuery($sQuery)
			For $upaoLogicalDisk In $colLogicalDisks
				If $upatype = "Extended Partition" Then ContinueLoop
				$upaarray [$upasub] [$pDriveLetterOld] = $upaoLogicalDisk.DeviceId
				$upaarray [$upasub] [$pPartFileSystem] = StringStripWS  ($upaoLogicalDisk.FileSystem, 7)
				$upaarray [$upasub] [$pPartFreespace]  = $upaoLogicalDisk.Freespace
				If  $upaarray [$upasub] [$pDriveLetterOld] <> "" Then _
					$upaarray [$upasub] [$pPartLabel] = CommonGetLabel ($upaarray [$upasub] [$pDriveLetterOld])
			Next
			If $upastyle <> "GPT" Then ContinueLoop
			If $upamediadesc = "Flash" Then
				If CommonParms ($advancedmode) Then _
				$upaarray [$upasub] [$pIsEFIPart] = UtilEFIFlash ($upasub, $upaarray)
			Else
				$upaarray [$upasub] [$pIsEFIPart] = UtilEFIVerify ($upadiskno, $upapartno, $upatype)
			EndIf
			If $upaarray [$upasub] [$pIsEFIPart]      = "yes" Then	$upaeficount += 1
			If $upaarray [$upasub] [$pDriveLetterOld] <> ""   Then _
			   $upaarray [$upasub] [$pDriveLetterNew] = $upaarray [$upasub] [$pDriveLetterOld]
		Next
		$upaarray [$upadrivesub] [$pDrivePartCount] = $upapartcount
		UtilDiskStats ($upadiskno, $upapartcount, $upaeficount, $upamediadesc)
	Next
	$upaarray [$upadrivesub] [$pDriveStyle] = $upastyle
	$efipartitioncount += $upaeficount
	_ArraySort ($upaarray, 0, 0, 0, $pSortCode)
	Return      $upapartcount
EndFunc

Func UtilReserved (ByRef $urarray, $urdisknumber, $urdrivesub)
	_ArrayAdd ($urarray, $urdisknumber & "|1")
	$ursub   = Ubound ($urarray) - 1
	$urarray [$ursub]      [$pPartLabel]   = $partreserved
	$urarray [$ursub]      [$pPartSize]    = 128 * $mega
	$urarray [$urdrivesub] [$pDriveUsed]  += 129 * $mega
	$urarray [$ursub]      [$pSortCode]    = $urdisknumber & "-001"
	Return $ursub
EndFunc

Func UtilEFIVerify ($evdiskno, $evpartno, $evtype)
	$evcheckguid = ""
	If Not StringInStr ($evtype, "System") Then Return $evcheckguid
	$evhandle    = FileOpen ($diskpartprefix & "getefipart" & $filesuffixin, 2)
	FileWriteLine ($evhandle, "Select Disk "      & $evdiskno)
	FileWriteLine ($evhandle, "Select Partition " & $evpartno)
	FileWriteLine ($evhandle, "Detail Partition ")
	FileClose     ($evhandle)
	$evwork = UtilRunDiskPart ("getefipart", "")
	For $evsub = 0 To Ubound ($evwork) - 1
		$evrec = $evwork [$evsub]
		If StringInStr ($evrec, $efiguid) Then $evcheckguid = "yes"
	Next
	If Not CommonParms ($advancedmode) And $evcheckguid = "" Then
		UtilDiskWriteLog ()
		UtilDiskWriteLog ("Disk  " & $evdiskno & " Partition " & $evpartno & _
		"  has an improper EFI GUID ")
		UtilDiskWriteLog ()
	EndIf
	Return $evcheckguid
EndFunc

Func UtilEFIFlash ($efsub, ByRef $efarray)
	$efreturn = ""
	$efletter = $efarray [$efsub] [$pDriveLetterOld]
	If StringInStr ($efarray [$efsub] [$pPartFileSystem], "fat") And FileExists ($efletter & "\efi") Then $efreturn = "yes"
	Return $efreturn
EndFunc

Func UtilDiskGUISetup ($dgsguititle = "", $dgscallhandle = "", $dgscaller = "")
	$utillogct           = 0
	$utilloglines        = ""
	If $dgsguititle      = "" Then $dgsguititle = "Grub2Win Disk Scan"
	$dgsguititle        &= " Log"
	If $runparmsdisplay <> "" Then $dgsguititle &= "          P=" & $runparmsdisplay
	If $dgscallhandle <> "" Then GUISetState (@SW_MINIMIZE, $dgscallhandle)
	If $utillogguihandle <> "" Then GUIDelete ($utillogguihandle)
	$utillogguihandle    = GuiCreate          ($dgsguititle, 600, 570,  10,   0, "", $WS_EX_STATICEDGE, $dgscallhandle)
	$utillogtxthandle    = GUICtrlCreateList  ("",   0,   0,  600, 500, 0x00200000)
	GUISetBkColor       ($mymedblue, $utillogguihandle)
	GUICtrlSetBKColor   ($utillogtxthandle, $mymedblue)
	$utillogclosehandle  = GuiCtrlCreateButton ("Exit Grub2Win",                         20, 510, 100, 30)
	GUICtrlSetState     ($utillogclosehandle, $guihideit)
	$utillogreturnhandle = GuiCtrlCreateButton ("Return To The " & $dgscaller & " Menu", 370, 510, 200, 30)
	GUICtrlSetState     ($utillogreturnhandle, $guihideit)
	GUISetState         (@SW_SHOW,  $utillogguihandle)
	UtilDiskWriteLog ()
	UtilDiskWriteLog ()
	UtilDiskWriteLog ("Starting the " & $dgsguititle & " at " & BasicTimeLine ())
	UtilDiskWriteLog ()
	UtilDiskWriteLog ($progvermessage)
	UtilDiskWriteLog ("           Program Stamp   " & $progtimestampdisp)
	UtilDiskWriteLog ()
	UtilDiskWriteLog ()
EndFunc

Func UtilDiskGUIWait ($gwcallhandle, $gwcaller)
	While 1
		$gwmsg = GUIGetMsg ()
		Select
			Case $gwmsg  = ""
			Case $gwmsg  = $utillogclosehandle
				$efiexit = "yes"
				ExitLoop
			Case $gwmsg  = $utillogreturnhandle
				UtilDiskWriteLog ()
				UtilDiskWriteLog ("Returning To The Grub2Win " & $gwcaller & " Menu")
				Sleep (700)
				GUISetState (@SW_RESTORE, $gwcallhandle)
				ExitLoop
		EndSelect
	Wend
	If $utillogguihandle <> "" Then GUIDelete ($utillogguihandle)
EndFunc

Func UtilDiskStats ($dsdisk, $dspartcount, $dseficount, $dsdesc)
	$dsmsg = "Found " & StringFormat ("%2s", $dspartcount) & "  Partitions"
	If $dspartcount  = 0 Then $dsmsg = "No partitions were found on " & $dsdesc & "  " & $dsdisk
	If $dspartcount  = 1 Then $dsmsg = StringTrimRight ($dsmsg, 1) & " "
	If $dseficount   > 0 Then $dsmsg &= "      ** " & $dsdesc & "  " & $dsdisk & "  contains an EFI partition **"
	Sleep            (100)
	UtilDiskWriteLog ("       " & $dsmsg, "endline")
EndFunc

Func UtilPartitionReport ($prarray)
	;_ArrayDisplay ($prarray)
	Local $proffset, $prprevdrivesize, $prprevoffset, $prprevsize
	$prhandle = FileOpen ($diskreportpath, 2)
	$uptitle  = @CRLF & @TAB & @TAB & "** Disk and Partition Report as of " & BasicTimeLine ()
	If $runparmsdisplay <> "" Then $uptitle &= "       Parms = " & $runparmsdisplay
	FileWriteLine ($prhandle, $uptitle & " **")
	For $prsub = 0 To Ubound ($prarray) - 1
		$prline = @TAB
		If $prarray [$prsub] [$pPartNumber] = 0 Then
			UtilCheckUnalloc ($prprevoffset, $prprevsize, $prprevdrivesize, 0, $prhandle)
			UtilDiskHeader ($prsub, $prarray, $prhandle)
			$proffset        = 0
			$prprevoffset    = 0
			$prprevsize      = 0
			$prprevdrivesize = $prarray [$prsub] [$pDriveSize]
			ContinueLoop
		EndIf
		UtilCheckUnalloc ($prprevoffset, $prprevsize, $prarray [$prsub] [$pPartOffset], $prarray [$prsub] [$pPartSize], $prhandle)
		UtilFormatField  ($prline, "Partition", $prarray [$prsub] [$pPartNumber],     14)
		UtilFormatField  ($prline, "Letter",    $prarray [$prsub] [$pDriveLetterOld], 14)
		UtilFormatField  ($prline, "FS",        $prarray [$prsub] [$pPartFileSystem], 14)
		$prsizeline = CommonFormatSize ($prarray [$prsub][$pPartSize], "yes")
		If $prarray [$prsub] [$pDriveLetterOld] <> "" Then
			$prusedpercent =  100 - Int (100 * ($prarray [$prsub] [$pPartFreeSpace] / $prarray [$prsub] [$pPartSize]))
			$prsizeline &= "   " & $prusedpercent & "% Full"
		EndIf
		UtilFormatField  ($prline, "Size", $prsizeline, 30)
		$prlabel = $prarray [$prsub] [$pPartLabel]
		$prmisc  = ""
		If $prlabel <> "" Then
			$prmisc = "Label = " & $prlabel
			If $prlabel = "** Unlabeled **" Or $prlabel = "** Microsoft Reserved **" Then $prmisc = $prlabel
			If $prarray [$prsub] [$pPartType]  = "Extended Partition" Then $prmisc = $prarray [$prsub] [$pPartType]
			$prline &= $prmisc & "    "
		EndIf
		If $prarray [$prsub] [$pIsEFIPart] = "yes" Then $prline &= "** EFI Partition **"
		FileWriteLine ($prhandle, @TAB & $prline & @CRLF & @CRLF)
	Next
	UtilCheckUnalloc ($prprevoffset, $prprevsize, $prprevdrivesize, 0, $prhandle)
	FileClose ($prhandle)
	$prhandle = FileOpen ($diskreportpath)
	$prlfdata = FileRead ($prhandle)
	FileClose ($prhandle)
	$prlfdata = StringReplace ($prlfdata, @CR, @LF)
	$prlfhandle = FileOpen ($diskreportlfpath, 2)
	FileWrite ($prlfhandle, $prlfdata)
	FileClose ($prlfhandle)
EndFunc

Func UtilCheckUnalloc (ByRef $cuprevoffset, ByRef $cuprevsize, $cucurroffset, $cucurrsize, $cuhandle)
	$cusize = $cucurroffset - $cuprevoffset - $cuprevsize
	;MsgBox ($mbontop, "Unalloc " & $cutype, "UA =" & $cusize & @CR & "PO = " & $cuprevoffset & @CR & _
	;	"CO = " & $cucurroffset & @CR & "PS = " & $cuprevsize)
	$cuprevoffset = $cucurroffset
	$cuprevsize   = $cucurrsize
	If $cusize <= $mega Then Return
	$culine = @TAB & CommonPadRight ("** Unallocated Space ** ", 42) & "Size " & CommonFormatSize ($cusize, "yes")
	FileWriteLine ($cuhandle, @TAB & $culine & @CRLF & @CRLF)
EndFunc

Func UtilDiskHeader ($dhsub, $dharray, $dhhandle)
	$dhline = @TAB
	UtilFormatField ($dhline, $dharray [$dhsub] [$pDriveMediaDesc], $dharray [$dhsub] [$pDiskNumber], 10)
	UtilFormatField ($dhline, "Style", $dharray [$dhsub] [$pDriveStyle], 15)
	UtilFormatField ($dhline, "Size",  CommonFormatSize  ($dharray [$dhsub] [$pDriveSize]), 18)
	$dhusednumber = CommonFormatSize  ($dharray [$dhsub] [$pDriveUsed])
	$dhusedpct    = ($dharray [$dhsub] [$pDriveUsed] / $dharray [$dhsub] [$pDriveSize])
	$dhusedpct    = ($dhusedpct * 100)
	$dhpctformat  = StringFormat ("%3.0f", $dhusedpct)
	If $dhusedpct < 99.999 Then $dhpctformat = StringFormat ("%3.2f", $dhusedpct)
	If $dhusedpct < 99     Then $dhpctformat = StringFormat ("%3.1f", $dhusedpct)
	UtilFormatField ($dhline, "Used", $dhusednumber & "  " & $dhpctformat & "%", 25)
	$dhfree    =  $dharray [$dhsub] [$pDriveSize] - $dharray [$dhsub] [$pDriveUsed]
	If $dhfree > 1 * $mega Then
		UtilFormatField ($dhline, "Free", CommonFormatSize  ($dhfree), 15)
	Else
		UtilFormatField ($dhline, "",     "",                          15)
	EndIf
	UtilFormatField ($dhline, "", $dharray [$dhsub] [$pDriveLabel], 40)
	FileWriteLine   ($dhhandle, @CRLF & @CRLF & @CRLF & $dhline & @CRLF & @CRLF)
	If $dharray [$dhsub] [$pDrivePartCount] = 0 Then FileWriteLine ($dhhandle, @TAB & @TAB & "** No Partitions Found **")
EndFunc

Func UtilFormatField (ByRef $ffline, $ffname, $ffdata, $ffpad = 10, $ffsep = " ")
	If $ffdata = "" Then $ffname = ""
	$ffline &= CommonPadRight ($ffname & $ffsep & $ffdata, $ffpad)
EndFunc

Func UtilRunDiskPart ($rufilestring, $rudisperror = "yes")                      ; Run DiskPart Utility
	$ruinfile   = $diskpartprefix & $rufilestring & $filesuffixin
	$ruoutfile  = $diskpartprefix & $rufilestring & $filesuffixout
	$ruinhandle = FileOpen ($ruinfile, 1)
	FileWriteLine ($ruinhandle, "Exit")
	FileClose     ($ruinhandle)
	$rustring =  " /c " & $efiutilexec & " /s " & $ruinfile & " > " & $ruoutfile
	$rurc     =  ShellExecuteWait (@Comspec, $rustring, "", "", @SW_HIDE)
	Sleep(100)   ;100 ms delay to allow any previous DiskPart commands to complete
	$ruarray  =  CommonFileReadToArray  ($ruoutfile, "yes")
	If @error Or $rurc <> 0 Then
		If $rudisperror = "yes" Then UtilProcessError ("DiskPart Run Error - Return Code " & _
			$rurc, "Error " & @error & "   " & $rustring);
		Return 1
	EndIf
	Return $ruarray
EndFunc

Func UtilCheckEncryption ($cedrive)
	If $bootos = $xpstring Then Return 0
	$ceoutput  = $windowstempgrub & $encryptstring
	$cestring  = " /c " & $encryptexec & " -status " & $cedrive & " > " & $ceoutput
	ShellExecuteWait (@Comspec, $cestring, "", "", @SW_HIDE)
	If @error Then Return 0
	$cearray   = CommonFileReadToArray ($ceoutput)
	;_ArrayDisplay ($cearray, $cerc)
	For $cesub = 0 To Ubound ($cearray) - 1
		$cerec = $cearray [$cesub]
		If Not StringInStr ($cerec, "Encryption Method") Then ContinueLoop
		If     StringInStr ($cerec, "None")              Then Return 0
		Return 1
	Next
EndFunc

Func UtilProcessError ($peline1, $peline2 = "", $pelogfile = $utillogfile, $pelogfilehandle = $utillogfilehandle)
	UtilDiskWriteLog ()
	UtilDiskWriteLog ($peline1)
	If $peline2 <> "" Then UtilDiskWriteLog ($peline2)
	UtilDiskWriteLog ()
	$efierrorsfound = "yes"
	$diagerrorcode  = $peline1
	If $pelogfile <> "" Then CommonCheckpointLog ($pelogfile, $pelogfilehandle)
EndFunc

Func UtilDiskWriteLog ($wlline = "", $wltype = "", $wltxthandle = $utillogtxthandle, $wlfilehandle = $utillogfilehandle)
	Local $wldisplaynl, $wlfilenl
	If $wltype      = "" Or $wltype = "endline" Then
		$utillogct   += 1
		$wldisplaynl = "|"
		$wlfilenl    = @CR
	EndIf
	$wlformatline = $wlline
	If $wltype  <> "endline" Then $wlformatline = "    " & $wlline
	If $utillogct > 28 Then
		 GUICtrlSetData ($wltxthandle, $wlformatline & "|")
		_GUICtrlListBox_SetTopIndex ($wltxthandle, $utillogct - 28)
	Else
		$utilloglines &= $wlformatline & $wldisplaynl
		GUICtrlSetData ($wltxthandle, "")
		GUICtrlSetData ($wltxthandle, $utilloglines)
	EndIf
	FileWrite ($wlfilehandle, $wlline & $wlfilenl)
EndFunc

Func UtilGetBootPartition ()
	Local $gbpconfig
	UtilPrepareObjects ("Win32_BootConfiguration", $dummyparm, $gbpconfig)
	For $dummyparm In $gbpconfig
		$gbpaddress = $dummyparm.Caption
	Next
	$gbparray = StringSplit ($gbpaddress, "\")
	If @error Or $gbparray [0] < 4 Then Return ""
	$gbpdisk = StringReplace ($gbparray [3], "Harddisk",  "")
	$gbppart = StringReplace ($gbparray [4], "Partition", "") + 1
	Return @LF & @LF & "Windows Boot    " & @TAB & @TAB & "Disk  " & $gbpdisk & "  Partition  " & $gbppart
EndFunc

Func UtilCreateSysInfo ()
	Local $csimessage
	If Not FileExists ($windowstempgrub) Then Return
	$csicpu = RegRead ($regkeycpu & "\0", "ProcessorNameString")
	For $csicores = 1 To 100
		RegEnumKey($regkeycpu, $csicores)
		If @error Then ExitLoop
	Next
    $csimem    = MemGetStats () [1] * $kilo
	$csiheader = "Current as of "     & BasicTimeLine   () & "    Grub2Win version " & $progversion  & @LF & @LF
	$csiuptime = "Windows Uptime Is " & CommonGetUptime ()                                           & @LF & @LF
	$csifirm   = $systemmode
	If $firmwaremode = "EFI" Then $csifirm &= "-" & $bootmodeefi
	ShellExecuteWait ("Regedit.exe", '/E "' & $sysinfotempfile & '" "'       & $regkeysysinfo   & '"', "", "")
	If FileExists ($sysinfotempfile) Then
		$csiarray    = CommonFileReadToArray   ($sysinfotempfile)
		$csimessage  = "Processor" & @TAB & "(" & $csicores - 1 & " Core " & $procbits & " Bit)"   & @TAB & $csicpu & @LF & @LF
		$csimessage &= "Memory   " & @TAB & "(" & Int (($csimem / $giga) + 0.999) & " GB)        " & @TAB
		$csimessage &= _WinAPI_GetNumberFormat (0, $csimem, _WinAPI_CreateNumberFormatInfo (0, 1, 3, '', ',', 1)) & " Bytes"
		$csimessage &= @LF & @LF & "Firmware Mode Is " & CommonPadRight ($csifirm, 12) & @TAB
		If $firmwaremode = "EFI" Then $csimessage &= "Secure Boot Is " & $securebootstatus
		$csimessage &= UtilGetBootPartition ()
		For $csisub = 3 To Ubound ($csiarray) - 2
			$csirecord     = StringReplace  ($csiarray   [$csisub], '"',  '')
			$csirecord     = StringReplace  ($csirecord, 'dword:000000',  '')
			If StringInStr ($csirecord, "Default string") Then ContinueLoop
			$csilocsplit   = StringInStr    ($csirecord, "=")
			$csirecleft    = StringLeft     ($csirecord, $csilocsplit - 1)
			$csirecright   = StringTrimLeft ($csirecord, $csilocsplit)
			If $csilocsplit < 16 Then $csirecleft &= @TAB
			$csirecord     = $csirecleft & _StringRepeat  (" ", 25 - $csilocsplit) & @TAB & $csirecright
			$csimessage   &= @LF & @LF  &  StringReplace ($csirecord, '"', '')
		Next
	EndIf
	If StringLen     ($csimessage) < 30 Then Return
	$sysinfomessage = $csiheader & $csiuptime & $csimessage
	$csimessage = StringReplace ($csimessage, "dword:", "")
	$csihandle  = FileOpen ($systemdatafile, 2)
	FileWrite   ($csihandle, $csiheader & $csimessage)
	FileClose   ($csihandle)
EndFunc