#RequireAdmin
#include-once
#include <g2common.au3>
#include <InetConstants.au3>

Const  $updateparms     = $storagepath     & "\updateparms.txt"
Const  $updatechangelog = $windowstempgrub & "\changelog.txt"
Const  $updatenever     = "** Never **"
Const  $updatedefault   = "30 Days"
Const  $updateversion   = "You are running Grub2Win version " & $progversion
Const  $updateconnmsg   = @CR & "Please Check The SourceForge Site Status"

Const  $sUpNextRemind = 0, $sUpRemindFreq    = 1, $sUpLastCheck = 2
Const  $sUpToGoDays   = 3, $sUpLastCheckDays = 4, $sUpOldRemind = 5

If StringInStr (@ScriptName, "g2update") Then
	HotKeySet  ("{ESC}", "UpdateEscape")
	HotKeySet  ("{F1}",  "UpdateEscape")
	CommonScaleIt (85, 90)
	Dim $logarray [1] [2]
	UpdateGetParms ()
	UpdateRunGUI   ()
EndIf

Func UpdateCheckDays ()
	$cddaystogo = StringLeft ($todaydate, 7) - UpdateGetParms ()
	CommonWriteLog ("    Update was last checked on " & StringTrimLeft ($updatearray [$sUpLastCheck], 37), 1, "")
	;_ArrayDisplay ($updatearray, $cddaystogo & "-" & $updatetoday & "-" & UpdateGetParms ())
	If $progage < 30 Or $updatearray [$sUpRemindFreq] = $updatenever Or $cddaystogo < 0 Then Return
	FileDelete     ($updatechangelog)
	CommonWriteLog ("    Update is auto loading the ChangeLog")
	UpdateTrack    ("Qwry")
	$upautohandle = InetGet ($downloadurlquery, $updatechangelog, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
	If @error Then $upautohandle = ""
EndFunc

Func UpdateRunGUI ($rgnewraw = "", $rgmessage = "", $rgcolor = $mylightgray)
	$updatearray    [$sUpNextRemind] = $todaydate
	$updatehandlevisit  = ""
	$updatehandleview   = ""
	$updatehandledown   = ""
	$updatehandlecheck  = ""
	$updatehandleremind = ""
	$updatehandlefreq   = ""
	$updatehandleclose  = ""
	$updatehandlenext   = ""
	$updatehandlehelp   = ""
	$updatehandleok     = ""
	$updatemode         = ""
	$rgholdfreq         = $updatearray [$sUpRemindFreq]
	$rgsetdefault       = $rgholdfreq
	$rgpidview          = ""
	GUISetState         (@SW_MINIMIZE, $handlemaingui)
	$sgreldate          = StringTrimLeft ($progdate, 37)
	$sgversion          = "Grub2Win Version " & $progversion & "     Released " & $sgreldate
	If $updatehandlegui <> "" Then GUIDelete ($updatehandlegui)
	$updatehandlegui    = GUICreate ($sgversion, $scalehsize * 0.5, $scalevsize * 0.75, -1, -1, $WS_EX_STATICEDGE, -1, $handlemaingui)
	$updatehandlehelp             = CommonScaleCreate ("Button",   "Help",       45,    1,    4,  3.5)
	GUICtrlSetBkColor ($updatehandlehelp, $mymedblue)
	$updatehandlenext   = CommonScaleCreate ("Label",    "",                      1,    5,   47, 12, $SS_CENTER)
	$updatehandlemsg    = CommonScaleCreate ("Label",    "",                      2,   17,   45,  9, $SS_CENTER)
	$updatehandlecheck  = CommonScaleCreate ("Button",   "Check For Updates Now", 9,   28,   33,  8)
	GUICtrlSetBkColor ($updatehandlecheck, $mygreen)
	$updatehandleremind = CommonScaleCreate ("CheckBox", "",                      8,   40.8, 27, 3.5)
	$updatehandlefreq   = CommonScaleCreate ("Combo",    "",                     35,   41,   10, 3.5, -1)
	$updatehandlevisit  = CommonScaleCreate ("Button", _
		@CR & "Visit The Official Grub2Win Site",                                14,   55,   23,   4)
	GUICtrlSetBkColor ($updatehandlevisit, $mymedblue)
	$updatebuttoncancel = CommonScaleCreate ("Button",   "Cancel",                2,   65,   10, 3.8)
	$updatehandleclose  = CommonScaleCreate ("Button",   "Close",                20,   65,   10, 3.8)
	$updatehandleok     = CommonScaleCreate ("Button",   "OK",                   38,   65,   10, 3.8)
	GUICtrlSetState ($updatehandleclose,  $guihideit)
	GUISetBkColor   ($myblue,  $updatehandlegui)
	UpdateDateBox   ()
	If $rgcolor     = $myred Then UpdateSetMessage ($myred, $rgmessage, $rgnewraw)
	GUISetState     (@SW_SHOW, $updatehandlegui)
	$rgsetbox       = $GUI_CHECKED
	If $updatearray [$sUpRemindFreq] = $updatenever Then $rgsetbox = $GUI_UNCHECKED
	GUICtrlSetState ($updatehandleremind, $rgsetbox)
	If $rgsetdefault = $updatenever Then $rgsetdefault = $updatedefault
	GUICtrlSetData  ($updatehandlefreq, $updatedefault & "|60 Days|90 Days", $rgsetdefault)
	UpdateCheckBox  ()
	;_ArrayDisplay ($updatearray)
	While 1
		$rgreturn = GUIGetMSG (1)
		$rgstatus = $rgreturn [0]
		$rghandle = $rgreturn [1]
		Select
			Case $rgstatus  = "" Or $rgstatus = 0
			Case $rgstatus  = $updatebuttoncancel Or $rgstatus = $updatehandleclose
				If $rghandle <> $updatehandlegui Then ContinueLoop
				If $rgstatus = $updatebuttoncancel Then
					$updatearray [$sUpRemindFreq] = $rgholdfreq
					$updatearray [$sUpNextRemind] = $updatearray [$sUpOldRemind]
				EndIf
				ExitLoop
			Case $rgstatus = $updatehandlehelp
				CommonHelp ("Checkingforupdates")
				ContinueLoop
			Case $rgstatus = $updatehandledown
				DirCreate         ($windowstempgrub & "\Zip")
                Sleep (250)
				GUICtrlSetState   ($updatehandleview,  $guihideit)
				GUICtrlSetState   ($updatehandlevisit, $guihideit)
				GUICtrlSetState   ($updatehandleok,    $guihideit)
				GUICtrlSetData    ($updatehandledown, @CR & "** The Grub2Win upgrade is downloading **" & @CR & _
					"This may take up to 60 seconds")
				GUICtrlSetBkColor ($updatehandledown, $myyellow)
				$rgresult = UpdateInetGet ($downloadurlcode, $zippedcode, "Grub2Win Software", $updatehandledown)
				If $rgresult <> "" Then ContinueLoop
				$rgresult = UpdateInetGet ($downloadurlzip,  $zippath,    "7-Zip Software", $updatehandledown)
				If $rgresult <> "" Then ContinueLoop
				Sleep (250)
				$rgresult = UpdateExtract ()
				If $rgresult <> "" Then ContinueLoop
			Case $rgstatus  = $updatehandleview
				If ProcessExists ($rgpidview) Then ContinueLoop
				$rgpidview     = CommonNotepad ($updatechangelog, "changelog.txt")
			Case $rgstatus  = $updatehandlevisit
				WinClose        ("Grub2Win download", "")
				ShellExecute    ($downloadurlvisit)
				CommonWriteLog  ("*** Visiting the Grub2Win site ***")
			Case $rgstatus  = $updatehandleremind
				$updatearray [$sUpRemindFreq] = UpdateCheckBox ()
				UpdateDateBox ()
			Case $rgstatus = $updatehandlefreq
				$updatearray [$sUpRemindFreq] = GUICtrlRead ($updatehandlefreq)
				UpdateDateBox ()
			Case $rgstatus  = $updatehandlecheck Or $rgstatus = $updatehandleok Or $upautohandle <> ""
				;MsgBox ($mbontop, "Check", $rgstatus & @CR & $updatehandlecheck)
				GUICtrlSetState ($updatehandlecheck,            $guihideit)
				GUICtrlSetState ($updatehandleok,               $guihideit)
				GUICtrlSetState ($updatehandlefreq,   $guihideit)
				GUICtrlSetState ($updatehandleremind, $guihideit)
				GUICtrlSetState ($updatebuttoncancel, $guihideit)
				GUICtrlSetState ($updatehandleclose,  $guishowit)
				If $rgstatus  = $updatehandlecheck Then
					If IsArray  ($logarray) Then CommonWriteLog ("    Checking for Grub2Win updates", 1, "")
					$updatehandlecheck = CommonScaleCreate ("Label", "", 9,  20,   33,  8, $SS_CENTER)
					GUICtrlSetBkColor ($updatehandlecheck, $myorange)
					UpdateTrack ("Qwry")
					$rgresult = UpdateInetGet ($downloadurlquery, $updatechangelog, "Change Log", $updatehandlecheck)
					If $rgresult <> "" Then ContinueLoop
					$rgnewraw = UpdateGetVersion ($rgcolor, $rgmessage)
				EndIf
				If $rgstatus = $updatehandleok Then
					If $rgholdfreq = $updatearray [$sUpRemindFreq] Then
						$updatearray [$sUpNextRemind] = $updatearray [$sUpOldRemind]
						UpdateDateBox ()
						ExitLoop
					EndIf
					MsgBox ($mbinfook, "", "The Grub2Win reminder frequency has been updated", 2)
				Else
					UpdateSetMessage ($rgcolor, $rgmessage, $rgnewraw)
				EndIf
				UpdateDateBox ()
		EndSelect
	Wend
	UpdatePutParms ($updatearray [$sUpNextRemind])
    If $updatehandlegui <> "" Then GUIDelete ($updatehandlegui)
	GUISetState (@SW_RESTORE, $handlemaingui)
EndFunc

Func UpdateGetVersion (ByRef $gvcolor, ByRef $gvmessage)
	$gvhandle = FileOpen     ($updatechangelog)
	$gvrecord = FileReadLine ($gvhandle)
	FileClose ($gvhandle)
	$gvrecord = StringReplace ($gvrecord, @TAB, " ")
	$gvrecord = StringStripWS ($gvrecord, 7)
	$gvsplit  = StringSplit   ($gvrecord, " ")
	If @error Then Return ""
	$gvnewraw = $gvsplit [3]
	$gvnewver = Number (StringReplace ($gvnewraw,    ".", ""))
	$gvoldver = Number (StringReplace ($progversion, ".", ""))
	;_ArrayDisplay ($gvsplit, $gvnewver & " " & $gvoldver)
	If  $gvoldver >= $gvnewver Then
		$gvmessage = @CR & "This is the latest version available"
		$gvcolor   = $mygreen
	Else
		$gvmessage = "The latest version is " & $gvnewraw & @CR & "Please upgrade to the latest version of Grub2Win"
		$gvcolor   = $myorange
	EndIf
	$updatearray   [$sUpLastCheck] = BasicFormatDate ($todaydate)
	UpdatePutParms ()
	Return $gvnewraw
EndFunc

Func UpdateSetMessage ($smcolor, $smmessage2, $smnewraw)
	;MsgBox ($mbontop, "Ver", $progversion & @CR & $smnewraw)
	$upautohandle      = ""
	$updatehandleview = CommonScaleCreate ("Button", "View The Change Log", 14, 46, 23, 4)
	GUICtrlSetBkColor ($updatehandleview, $mymedblue)
	GUICtrlSetBkColor ($updatehandlemsg,  $smcolor)
	GUICtrlSetData    ($updatehandlemsg,  $updateversion & @CR & $smmessage2)
	If FileExists ($updatechangelog) Then
		$smupref   = "Upgrade To"
		$smupcolor = $mygreen
		If $smnewraw = $progversion Then
			$smupref   = "Refresh"
			$smupcolor = $myorange
		EndIf
		$updatehandledown = CommonScaleCreate ("Button", @CR & $smupref & " Grub2Win Version " & $smnewraw, _
			1, 30, 47, 9, $BS_MULTILINE)
		GUICtrlSetBkColor ($updatehandledown, $smupcolor)
		If $smcolor <> $myorange And $updatemode = "" Then GUICtrlSetState ($updatehandledown, $guihideit)
	Else
		GuiCtrlSetState   ($updatehandleview,  $guishowdis)
		GuiCtrlSetState   ($updatehandlevisit, $guishowdis)
		GUICtrlSetBkColor ($updatehandlemsg,   $myred)
		GUICtrlSetData    ($updatehandlemsg,   "The Grub2Win Update Check Failed." & $updateconnmsg)
	EndIf
	If $updatehandlecheck  <> "" Then GUICtrlDelete  ($updatehandlecheck)
	If $updatehandleremind <> "" Then GUICtrlDelete  ($updatehandleremind)
	If $updatehandlefreq   <> "" Then GUICtrlDelete  ($updatehandlefreq)
EndFunc

Func UpdateInetGet ($igurl, $igfile, $igdesc, $ighandleflash)
	GUICtrlSetState ($updatehandleclose, $guihideit)
	$igresult    = ""
	$igmsgrc     = ""
	$igtimecheck = 30
	$igtimeflash = 0
	$igtimestart = TimerInit ()
	$igconnmsg   = $updateconnmsg & " And URL " & @CR & $igurl
	CommonWriteLog ("    Update is downloading the " & $igdesc)
	If $updatecandown <> "" Then GUICtrlDelete ($updatecandown)
	$updatecandown = CommonScaleCreate ("Button", "Cancel Download", 33, 65, 15, 3.8)
	$ighandle = InetGet ($igurl, $igfile, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
	While $igresult = ""
		$igstatus = GUIGetMsg ($updatehandlegui)
		If TimerDiff ($igtimestart) > $igtimecheck * 1000 Then
			$igmsgrc = MsgBox ($mbwarnokcan, "", "The " & $igdesc & " download has not yet completed. Time = " &    _
			    $igtimecheck & " seconds." & @CR & @CR & "Click OK to continue another 30 seconds or click Cancel")
			If $igmsgrc = $IDOK Then $igtimecheck += 30
		EndIf
		If TimerDiff ($igtimestart) > $igtimeflash * 1000 Then
            $igtimeflash += 1
			$igduration = CommonCalcDuration ($igtimestart)
			$igtext = @CR & "** Now downloading the " & $igdesc & " **" & @CR
			If $igduration <> "" Then $igtext &= "Running for " & $igduration
			GUICtrlSetData ($ighandleflash, $igtext)
			GUISetState    (@SW_SHOW, $updatehandlegui)
		EndIf
		If $igstatus = $updatecandown Or $igmsgrc = $IDCANCEL Then
			$igresult = "The Download Of The " & $igdesc & " Was Cancelled."
			ExitLoop
		EndIf
		If InetGetInfo ($ighandle, $INET_DOWNLOADCOMPLETE) Then	ExitLoop
	Wend
	$iginetrc = InetGetInfo ($ighandle, $INET_DOWNLOADERROR)
	InetClose ($ighandle)
	Select
		Case $igresult <> ""
		Case $iginetrc > 0
			$igresult = "Internet error " & $iginetrc & " while downloading " & $igdesc & "." & $igconnmsg
		Case Else
			For $igfilesub = 1 To 22
				If FileGetSize ($igfile) > $kilo Then ExitLoop
				If $igfilesub > 20 Then $igresult =  _
				"The download of file " & $igdesc & " failed. " & $igconnmsg
			Sleep (100)   ; Give the file a chance to settle
			Next
	EndSelect
	GUICtrlSetState ($updatecandown, $guihideit)
	If $igresult <> "" Then
		FileDelete        ($igfile)
		GUICtrlSetData    ($updatehandlemsg,   $igresult)
		GUICtrlSetBkColor ($updatehandlemsg,   $myred)
		GUICtrlSetFont    ($updatehandlemsg,   7)
		GUICtrlSetState   ($updatehandledown,  $guihideit)
		GUICtrlSetState   ($updatehandlecheck, $guihideit)
	EndIf
	GUICtrlSetState ($updatehandleclose, $guishowit)
	If $igresult <> "" Then CommonWriteLog ("    " & $igresult)
	Return $igresult
EndFunc

Func UpdateExtract ()
	UpdateTrack ("Updt")
	$ueextractflash = ""
	$ueextractstart = TimerInit ()
	$ueparms        = " x " & $zippedcode & " -aoa -o" & $windowstempgrub
	$uepidextract   = Run ($zippath & $ueparms, "", @SW_HIDE)
	If @error Then Return
	GUICtrlSetState ($updatehandleclose, $guihideit)
	If $updatecandown <> "" Then GUICtrlDelete ($updatecandown)
	$updatecandown = CommonScaleCreate ("Button", "Cancel Extract", 33, 65, 15, 3.8)
	GUICtrlSetBkColor ($updatehandledown, $mymedblue)
	While 1
		If Not ProcessExists  ($uepidextract) Then ExitLoop
		$uestatus = GUIGetMsg ($updatehandlegui)
		Select
			Case $uestatus = $updatecandown Or $uestatus = $IDCANCEL Or $ueextractflash > 100
				ProcessClose    ($uepidextract)
				If $updatecandown <> "" Then GUICtrlDelete ($updatecandown)
				GUICtrlSetState ($updatehandleclose, $guishowit)
				GUICtrlSetData  ($updatehandledown, @CR & "** The Extract Failed **")
				GUISetState     (@SW_SHOW, $updatehandlegui)
				Return "Cancelled"
			Case TimerDiff ($ueextractstart) > $ueextractflash * 1000
				$ueextractflash   += 1
				$ueextractduration = CommonCalcDuration ($ueextractstart)
				$ueextracttext = @CR & "** Extracting the Grub2Win software **" & @CR
				If $ueextractduration <> "" Then $ueextracttext &= "Running for " & $ueextractduration
				GUICtrlSetData    ($updatehandledown, $ueextracttext)
				GUISetState       (@SW_SHOW, $updatehandlegui)
		EndSelect
	Wend
	GUICtrlSetState   ($updatecandown, $guihideit)
	GUICtrlSetData    ($updatehandledown, @CR & "** Now starting Grub2Win setup **")
	GUICtrlSetBkColor ($updatehandledown, $myorange)
	Sleep (250)
	Run               ($windowstempgrub & "\install\winsource\" & $exestring & " Setup")
	Exit
EndFunc

Func UpdateGetParms ()
	Dim $updatearray [6]
	$gphandle = FileOpen ($updateparms)
	If $gphandle = -1 Then
		$updatearray [$sUpRemindFreq] = $updatedefault
		Return
	EndIf
	$updatearray [$sUpNextRemind]  = StringTrimLeft (FileReadLine ($gphandle), 14)
	$ugremind                      = StringTrimLeft (FileReadLine ($gphandle), 14)
	$updatearray [$sUpRemindFreq]  = StringStripWS ($ugremind, 7)
	$updatearray [$sUpLastCheck]   = StringTrimLeft (FileReadLine ($gphandle), 14)
	FileClose ($gphandle)
	$updatearray [$sUpOldRemind]   = $updatearray [$sUpNextRemind]
	If $updatearray [$sUpRemindFreq] = "" Then $updatearray [$sUpRemindFreq] = $updatedefault
	$gporiginaljul = StringLeft ($updatearray [$sUpNextRemind], 7)
    UpdateCalcDates ()
	Return $gporiginaljul
EndFunc

Func UpdatePutParms ($ppremind = $todaydate, $ppnewfreq = $updatearray [$sUpRemindFreq])
	$pphandle = FileOpen ($updateparms, 2)
	FileWriteLine ($pphandle, "nextremind  = " & $ppremind)
	FileWriteLine ($pphandle, "remindfreq  = " & $ppnewfreq)
	FileWrite     ($pphandle, "lastcheck   = " & $updatearray [$sUpLastCheck])
	FileClose     ($pphandle)
EndFunc

Func UpdateDateBox ()
	UpdateCalcDates ()
	$dbnextdate = StringTrimLeft ($updatearray [$sUpNextRemind], 36)
    $dbmsg1 = "The last Grub2Win update check was" & @CR
	$dbmsg2 = $updatearray [$sUpLastCheckDays] & "  days ago at  "
	If $updatearray [$sUpLastCheckDays] = 0 Then $dbmsg2 = "Today at  "
	If $updatearray [$sUpLastCheckDays] = 1 Then $dbmsg2 = "Yesterday at  "
	$dbcheckdate  = StringTrimLeft ($updatearray [$sUpLastCheck], 23)
	$dbfuture     = "in " & $updatearray [$sUpToGoDays] &  " days on"
	If $updatearray [$sUpToGoDays] = 1 Then $dbfuture =  "tomorrow"
	$dbmsg3 = "The next reminder will be " & $dbfuture & $dbnextdate
    If $updatearray [$sUpToGoDays] < 1 Then $dbfuture =  "today" & StringTrimLeft ($todaydate, 23)
	If $updatearray [$sUpRemindFreq] = $updatenever Then $dbmsg3 =  "** Reminders are disabled **"
	$dbmsg = $dbmsg1 & $dbmsg2 & $dbcheckdate & @CR & @CR & $dbmsg3
	GUICtrlSetData ($updatehandlenext, $dbmsg)
EndFunc

Func UpdateTrack ($uttype)
	CommonDownloadLog ("Downloading Track "  & $progtrackversion & "-" & $uttype & ".txt")
	$uturl    = $trackurl    & "/"          & $progtrackversion & "-" & $uttype & ".txt/download"
	$utfile   = $windowstemp & "\grub2win." & $progtrackversion & "-" & $uttype & ".txt"
	InetGet ($uturl, $utfile, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
	;MsgBox ($mbontop,  "Track", $progtrackversion & @CR & $uttype & @CR & $uthandle & @CR & $utfile)
EndFunc

Func UpdateCalcDates ()
	$updatearray [$sUpLastCheckDays] = StringLeft ($todaydate, 7) - StringLeft ($updatearray [$sUpLastCheck], 7)
	If $updatearray [$sUpRemindFreq] = $updatenever Then Return
	$cdremindjul = StringLeft (BasicFormatDate ($updatearray [$sUpNextRemind]), 7)
	$cdfreq      = Number (StringLeft ($updatearray [$sUpRemindFreq], 2))
	$cdtodayjul  = StringLeft ($todaydate, 7)
	If $cdremindjul < $cdtodayjul - $cdfreq Then $cdremindjul = $cdtodayjul
	If $cdremindjul + $cdfreq > $cdtodayjul + $cdfreq Then $cdremindjul = $cdtodayjul
    $updatearray [$sUpNextRemind] = BasicFormatDate ($cdremindjul + $cdfreq)
	$updatearray [$sUpToGoDays]   = StringLeft ($updatearray [$sUpNextRemind], 7) - $cdtodayjul
	If $updatearray [$sUpToGoDays] < 0 Then
	   $updatearray [$sUpToGoDays] = 0
	   $updatearray [$sUpNextRemind] = $todaydate
	EndIf
	;_ArrayDisplay ($updatearray)
EndFunc

Func UpdateCheckBox ()
	If CommonCheckBox ($updatehandleremind) Then
		GUICtrlSetState ($updatehandlefreq,   $guishowit)
		GUICtrlSetData  ($updatehandleremind, "Enable Reminders  -  Remind Me Every")
		$cbfreq = GUICtrlRead ($updatehandlefreq)
	Else
		GUICtrlSetState ($updatehandlefreq,   $guihideit)
		GUICtrlSetData  ($updatehandleremind, "Enable Reminders")
		$cbfreq = $updatenever
	EndIf
	;MsgBox ($mbontop, "Check", $cbfreq)
	Return $cbfreq
EndFunc

Func UpdateEscape ()
	Exit
EndFunc