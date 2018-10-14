#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include-once
#include       <g2common.au3>
$setupcaller = "setdownload"
#include       <setfunction.au3>

CommonPrepareAll ()
DownloadRunGUI   ()

Exit

Func DownloadRunGUI ()
	If Not CommonParms ($actionsilent) Then
		$rgmessage  = 'The installer will now download the current ' & @CR & 'GNU Grub and Grub2Win modules' & @CR & @CR
		$rgmessage &= 'Click "OK" to continue or click "Cancel"'
		$rgrc = MsgBox ($mbinfookcan, "Download Software From SourceForge", $rgmessage)
		If $rgrc <> $IDOK Then Exit 2
	EndIf
	$downloadhandlegui    = GUICreate           ("Grub2Win Downloader", 500, 250, -1, -1, $WS_EX_STATICEDGE)
	$downloadhandlemsg    = GUICtrlCreateLabel  ("",        28,   30, 440, 100, $SS_CENTER)
	$downloadhandlebutton = GUICtrlCreateButton ("Cancel", 220,  180,  60,  20)
	CommonSetupWinTemp   ()
	DirCreate            ($windowstempgrub & "\WGet")
	DirCreate            ($windowstempgrub & "\Zip")
	FileInstall          ("..\..\..\support\WGet\wget.exe", $wgetpath)    ; Include the WGet utility
	FileInstall          ("..\..\..\support\Zip\7za.exe",   $zippath)     ; Include the 7Zip utility
	$rgcancelled         = ""
	GUICtrlSetBkColor    ($downloadhandlemsg, $myyellow)
	GUISetBkColor        ($myblue,  $downloadhandlegui)
	CommonDownloadLog    ("Start Download - Version " & $progversion & "  Tracking " & $progtrackversion & "-Inst.txt")
	CommonTrackDown      ("Inst")
	$rgresult = DownloadInetGet ($downloadurlcode, $zippedcode, "Grub2Win Software", $downloadhandlemsg)
	CommonDownloadLog    ("End Download     " & $rgresult)
	If $rgresult = "" Then $rgresult = DownloadExtract ()
	CommonDownloadLog     ("End Extract      " & $rgresult)
	If $rgresult = "" Then
		GUICtrlSetState   ($downloadhandlebutton, $guihideit)
		GUICtrlSetData    ($downloadhandlemsg, @CR & "** Now starting Grub2Win setup **")
		GUICtrlSetBkColor ($downloadhandlemsg, $mygreen)
		WinSetOnTop       ($downloadhandlegui, "", 1)
		GUISetState       (@SW_SHOW, $downloadhandlegui)
		Sleep (1000)
		GUIDelete         ($downloadhandlegui)
		SetupByGUI        ()
		Return
	Else
		GUICtrlSetData    ($downloadhandlemsg, @CR & $rgresult)
		GUICtrlSetBkColor ($downloadhandlemsg, $myred)
		$rgcancelled      = "yes"
	EndIf
	GUICtrlSetData ($downloadhandlebutton, "Close")
	Sleep (250)
	While 1
		$rgstatus = GUIGetMSG ()
		Select
			Case $rgstatus = "" Or $rgstatus = 0
			Case $rgstatus = $downloadhandlebutton And $rgcancelled = "yes"
				ExitLoop
		EndSelect
	Wend
	CommonSetupWinTemp ("yes")
EndFunc

Func DownloadInetGet ($igurl, $igfile, $igdesc, $ighandleflash)
    $igparms     = " " & $igurl & " --no-verbose --no-check-certificate -O " & $igfile & " -o " & $wgetdiagfile
	$igresult    = ""
	$igmsgrc     = ""
	$igtimecheck = 30
	$igtimeflash = 0
	$igtimestart = TimerInit ()
	$igconnmsg   = @CR & "Please Check The SourceForge Site Status And URL" & @CR & $igurl
	; MsgBox ($mbontop, "Inet", $igurl & @CR & $igfile)
	$igpid = Run ($wgetpath & $igparms, "", @SW_HIDE)
	If @error Then $igresult = "The WGet program is missing or failed"
	While $igresult = "" And ProcessExists ($igpid)
		$igstatus = GUIGetMsg ()
		If TimerDiff ($igtimestart) > $igtimecheck * 1000 Then
			$igmsgrc = MsgBox ($mbwarnokcan, "", "The " & $igdesc & " download has not yet completed. Time = " &    _
			    $igtimecheck & " seconds." & @CR & @CR & "Click OK to continue another 30 seconds or click Cancel")
			If $igmsgrc = $IDOK Then $igtimecheck += 30
		EndIf
		If TimerDiff ($igtimestart) > $igtimeflash * 1000 Then
            $igtimeflash += 1
			$igduration = CommonCalcDuration ($igtimestart)
			$igtext = @CR & "** Now downloading the " & $igdesc & " **" & @CR & @CR
			If $igduration <> "" Then $igtext &= "Running for " & $igduration
			GUICtrlSetData ($ighandleflash, $igtext)
			GUISetState    (@SW_SHOW, $downloadhandlegui)
		EndIf
		If $igstatus = $downloadhandlebutton Or $igmsgrc = $IDCANCEL Then _
			$igresult = "** You Cancelled The **" & @CR & @CR & "** " & $igdesc & " Download **"
	Wend
	If $igpid > 0 Then ProcessClose ($igpid)
	GUISetState (@SW_SHOW, $downloadhandlegui)
	Select
		Case $igresult <> ""
		Case Else
			$igcheckhandle = FileOpen ($wgetdiagfile)
			If $igcheckhandle = -1 Then $igresult = "The WGet Diagnosis File was not found"
			$igcheckline1  = FileReadLine ($igcheckhandle)
			$igcheckline2  = FileReadLine ($igcheckhandle)
			FileClose ($igcheckhandle)
			If StringInStr ($igcheckline2, "error") Then
				$igresult = "WGet Error " & @CR & @CR & "SourceForge HTTP Error" & @CR & @CR & $igcheckline2
				InetError ($igcheckline1, $igcheckline2)
			EndIf
			If $igresult = "" Then
				For $igfilesub = 1 To 22
					If FileGetSize ($igfile) > $kilo Then ExitLoop
					If $igfilesub > 20 Then
						$igresult = "The download of the " & $igdesc & " from SourceForge failed. " & $igconnmsg
						InetError ($igcheckline1, $igcheckline2)
					EndIf
					Sleep (100)   ; Give the file a chance to settle
				Next
			EndIf
	EndSelect
	Return $igresult
EndFunc

Func InetError ($ieline1, $ieline2)
	MsgBox ($mbontop, "** Internet Error **", "** Please Check The SourceForge Site Status **" & @CR & @CR &  _
	    @TAB & "Diagnostics follow:" & @CR & @CR &  $ieline1 & @CR & @CR & $ieline2)
EndFunc

Func DownloadExtract ()
	$ieresult       = ""
	$ieextractflash = ""
	$ieextractstart = TimerInit ()
	$ieparms        = " x " & $zippedcode & " -aoa -o" & $windowstempgrub
	$iepidextract   = Run ($zippath & $ieparms, "", @SW_HIDE)
	If @error Then $ieresult = "** The Extract Task Failed To Start"
	GUICtrlSetBkColor ($downloadhandlemsg, $mymedblue)
	While 1
		If Not ProcessExists  ($iepidextract) Then ExitLoop
		$iestatus = GUIGetMsg ()
		Select
			Case $iestatus = $downloadhandlebutton Or $iestatus = $IDCANCEL Or $ieextractflash > 100
				$ieresult = "** You Cancelled The **" & @CR & @CR & "** Grub2Win Software Extract **"
				ExitLoop
			Case TimerDiff ($ieextractstart) > $ieextractflash * 1000
				$ieextractflash   += 1
				$ieextractduration = CommonCalcDuration ($ieextractstart)
				$ieextracttext = @CR & "** Extracting the Grub2Win software **" & @CR & @CR
				If $ieextractduration <> "" Then $ieextracttext &= "Running for " & $ieextractduration
				GUICtrlSetData    ($downloadhandlemsg, $ieextracttext)
				GUISetState       (@SW_SHOW, $downloadhandlegui)
		EndSelect
	Wend
	If $iepidextract > 0 Then ProcessClose ($iepidextract)
	Return $ieresult
EndFunc