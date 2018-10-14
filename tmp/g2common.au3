#include-once
#include <Array.au3>
#include <File.au3>
#include <Constants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <UpDownConstants.au3>
#include <GDIPlus.au3>
#include <GuiListBox.au3>
#include <GuiButton.au3>
#include <Misc.au3>
#include <StaticConstants.au3>
#include <String.au3>
#include <Date.au3>
#include <WindowsConstants.au3>
#include <WinAPIMisc.au3>
#include <WinAPIFiles.au3>
#include <UserFunctions.au3>
#include <g2basic.au3>

Global $defaultlastbooted   = "no"
Global $timewinboot         = 5
Global $defaultos           = 0
Global $templategfxmenu     = "\template.gfxmenu.cfg"

Const  $pType = 0, $pFamily = 1, $pMode = 2, $pTitle =  3, $pBootParms = 4, $pHoldParms = 5, $parmsfieldcount = 6

Global $osparmarray [19][$parmsfieldcount] = [ _
	["android",      "linux-andremix", "64B",  "Android",  _
		                                 "verbose androidboot.selinux=permissive vmalloc=192M buildvariant=userdebug"], _
	["bootinfo",     "template",       "ALL",  "Boot Information and Utilities", ""],                                   _
	["debian",       "linux-deb",      "ALL",  "Debian Linux",                   "verbose nomodeset"],                  _
	["fedora",       "linux-fed",      "ALL",  "Fedora Linux",                   "verbose nomodeset"],                  _
	["freebsd",      "freebsd",        "ALL",  "FreeBSD",                        ""],                                   _
	["invaders",     "template",       "BIOS", "Invaders Game",                  ""],                                   _
	["isoboot",      "isoboot",        "ALL",  "Boot an ISO file",               ""],                                   _
	["mint",         "linux-deb",      "ALL",  "Mint Linux",                     "verbose nomodeset"],                  _
	["remix",        "linux-andremix", "64B",  "Remix Linux",                    $remixparma & $remixparmb],            _
	["slackware",    "linux-sla",      "ALL",  "Slackware Linux",                "verbose nomodeset"],                  _
	["submenu",      "other",          "ALL",  "Sub Menu",                       ""],                                   _
	["suse",         "linux-sus",      "ALL",  "Suse Linux",                     "splash=verbose showopts nomodeset"],  _
	["ubuntu",       "linux-deb",      "ALL",  "Ubuntu Linux",                   "verbose nomodeset"],                  _
	["windows",      "windows",        "EFI",  "Windows EFI Boot Manager",       ""],                                   _
	["other",        "other",          "ALL",  "Other OS",                       ""],                                   _
	["reboot",       "template",       "ALL",  "Reboot Your System",             ""],                                   _
	["shutdown",     "template",       "ALL",  "Shutdown Your System",           ""],                                   _
	["bootfirmware", "template",       "EFI",  "Boot to your EFI firmware",      ""],                                   _
	["unknown",      "",               "ALL",  "Unknown OS",                     ""]]

Global $mainhelphandle, $mainuninsthandle, $mainresthandle, $mainsynhandle, $mainupdhandle, $selectionhelphandle, $edithelphandle
Global $configarray, $userarray, $selectionarraysize, $handlelastbooted, $custmaxhoriz, $iconhelphandle, $mainloghandle, $mainlogcount
Global $handleselectiongui, $handleselectiondel, $handleselectionscroll, $handleselectionbox
Global $selectionarray, $selectionholdarray, $selectionholdlastbooted
Global $selectionautohigh, $selectionautocount, $selectionusercount, $upmessgstart
Global $bcdtestboot, $upmessguihandle, $upmesstexthandle1, $upmesstexthandle2, $runarray, $bcdwinmenuhold
Global $bcdarray, $bootarray, $bcdnewid, $bcdwinorder, $bcdfirmorder, $bcdwinbootid, $bcdgrubbootid, $backupcomplete
Global $bcdwindisplayorig, $bcdcleanuparray, $bcderrorfound, $screenpicturehandle, $screenshothandle, $screenpreviewhandle
Global $handlemaingui, $handlelog, $logarray
Global $buttonok, $buttonselection, $buttonclose, $buttoncancel, $buttonrunefi, $buttonsetorder, $buttondiag
Global $promptg, $promptl, $promptt, $promptd, $promptbt, $parmstripped, $sysinfomessage
Global $arrowbt, $updownbt, $arrowgt, $updowngt, $timeloader
Global $labelbt1, $labelbt2, $labelgt1
Global $checkdrivers, $checkshortcut, $buttondrivers, $buttonsysinfo, $usersectionfound, $dummyparm
Global $driverhandlegui, $driverbuttonapply, $driverbuttoncancel, $driverhelphandle
Global $drivercheckata, $drivercheckraid, $drivercheckusb, $driverchecklv, $drivercheckcrypt, $driverchecksleep
Global $driveruseata, $driveruseraid, $driveruseusb, $driveruselv, $driverusecrypt, $driverusesleep
Global $grubcfgefilevel, $latestefilevel, $timeoutok, $timerenabled
Global $warnhandle, $genline, $typestring, $windowstypecount, $syslineos, $syslinesecure
Global $defaulthandle, $defaultstring, $defaultset, $defaultselect
Global $graphhandle, $graphset, $diagcomplete
Global $origgraphset, $origtimeloader, $origdefault, $origlangset
Global $scalepcthorz, $scalepctvert, $scalehsize, $scalevsize, $graphmessage, $scalefontsize
Global $bcdprevtime, $driversprevious, $progvermessage, $headermessage, $focushandle, $focushandlelast
Global $esctype, $runparm1, $runparm2, $runparm3, $runparms, $runparmsdisplay
Global $radioname1, $radioname2, $radioname3, $radioname4
Global $selectionstatus, $handleselectionup, $handleselectiondown
Global $handleselectiondefault, $buttonselectioncancel, $buttonselectionadd, $buttonselectionapply
Global $edithandlegui, $editbuttoncancel, $editholdarray, $editlimit, $selectionlimit, $selectionentrycount
Global $edithandletitle, $edithandletype, $editbuttonok, $edithandleentry, $editpictureicon
Global $editpromptbootby, $edithandleradio1, $edithandleradio2, $edithandleradio3, $edithandleradio4, $edittype
Global $editpromptdrva, $edithandledrva, $editpromptdrvc, $edithandledrvc, $editpromptprta, $edithandleprta, $edithandlewarn
Global $editpromptparm, $edithandleparm, $editupdowndrva, $editupdowndrvc, $editupdownprta, $editsearchok, $editsearchfilled
Global $edithandlechkc, $edithandleprtc, $editupdownprtc,$editbuttonstand, $editmessageparm, $editholdentry, $editnewentry
Global $edithandlesearch, $edithandleseland, $edithandleseliso, $edithandledev, $editpromptgraph, $edithandlegraph
Global $edithandlepause, $editupdownpause, $edithandlechknv, $editprompticon
Global $editwarnmessage, $editbuttonapply, $editerrorok, $editparmok, $editparmlength, $edittitleok
Global $edithandlewinset, $edithandlewininst, $edithandlewintitle, $edithandlehotkey, $edithotkeywork
Global $editlistcustedit, $editbuttoncustdel, $editpromptcust, $editpromptsample, $editpromptauto
Global $handleordergui, $handleorderup, $handleorderdown, $handleorderdefault, $handleordertest, $handleordernotest
Global $handleorderscroll, $buttonorderreturn, $buttonorderapply, $orderhelphandle, $ordercurrentstring
Global $orderfirmboot, $orderfirmdisplay, $scrolltoppos, $scrollmaxvsize
Global $parsearray, $parseposition, $parseresult1, $parseresult2, $autoarray, $searchneeded, $isoneeded
Global $iconhandlegui, $iconhandlescroll, $iconbuttoncancel, $iconhold, $iconbuttonapply, $iconarray
Global $efipartarray, $eficonfguihandle, $efiforce32
Global $efierrorsfound, $eficancelled, $efideleted
Global $efiexit, $efimilsec, $efilevelinstalled, $eficodesize, $efipartitioncount
Global $utillogfilehandle, $utillogtxthandle, $utillogct, $utilloglines, $utillogclosehandle, $utillogreturnhandle, $utillogguihandle
Global $diagerrorcode, $biosprevfound, $updatearray, $updatemode
Global $xpiniarray, $xpinbackiarray, $xpiniprevtime, $xpiniprevitem, $xpinibackedup, $xpoldrelarray, $xpinibootstring, $xpoldfound
Global $langcomboarray, $langcombo, $timeunique, $langheader, $langhandle, $langselectedcode, $langauto, $langautostring
Global $langfound, $langline1, $langline2, $langline3, $langline4
Global $handlegrubtimeout, $controlhorizhold
Global $custparsearray, $custparseholdarray, $custparselastloc, $setupstatus, $setuphandleefi, $setupinstallefi, $setuplogfile
Global $setuphandlegui, $setupbuttoncancel, $setupbuttoninstall, $setupbuttonhelp, $setuphandlelist, $setuphandlerun
Global $setupinprogress, $setupdisableprm, $setuphelploc, $setupdownload, $setuphandledel, $setupcaller
Global $setuphandledrive, $setuptargetdrive, $setuphandleshort, $setupbasepath, $setupolddir, $setuptempdir, $setuplevelwarned
Global $setuptargetdir, $setupbuttonclose, $setuphandlewarn, $setupbuttonconfirm, $setupversion, $setuphandleefiprm
Global $setuphandlelabel, $setuphandleprompt, $setupmbrequired, $setuplogarray, $setuphandleforce32, $setupforce32ok, $setupbump
Global $buttonthemehelp, $handlethemedark, $handlethemescroll, $handlethemeshot, $handlethemeface, $handlethemetime
Global $buttonthemeok, $themetempoptarray, $handlethemevers, $handlethememode, $handlethemestyle, $handlethemelines, $handlethemelabs
Global $handlethemesecs, $handlethemeseclab, $handlethemesecud, $handlethemelab1, $handlethemedesc, $handlethemepic, $themedefarray
Global $buttonthemereset, $themeoptarray, $handlethemegui, $buttonthemecancel, $buttonthemecolgrp
Global $buttonthemecoltit, $buttonthemecolsel, $buttonthemecoltxt, $buttonthemecolclk
Global $brushtitle, $brushselect, $brushtext, $brushclock
Global $gdicontextin, $gdihandlein, $gdiformat, $gdifontfam, $gdifont, $gdilayout, $gdimeasure
Global $updatehandlegui, $updatebuttoncancel, $updatehandledown, $updatehandleview, $updatehandlevisit, $updatehandlemsg
Global $updatecandown, $updatehandleclose, $upautohandle, $updatehandlecheck, $updatehandleremind, $updatehandlefreq
Global $updatehandleok, $updatehandlehelp, $updatehandlenext, $scalepicaux, $envreboot, $envdata
Global $downloadhandlegui, $downloadhandlemsg, $downloadhandlebutton
Global $langfullselector = $langenglish

If @Compiled Then
		Opt ("TrayIconHide",  1)    ; Get rid of the AutoIt tray icon
	Else
		Opt ("TrayIconDebug", 1)    ; 1=debug line number
EndIf

CommonSetPaths (BasicGetBaseDrive ())

Func CommonSetPaths ($cspdrive)
	Global $basedrive        = $cspdrive
	Global $basepath         = $basedrive       & "\" & $basestring
	Global $baseexe          = $basepath        & "\" & $exestring
    Global $configfile       = $basepath        & "\" & $configstring
    Global $logfile          = $basepath        & "\update.log"
    Global $helppath         = $basepath        & "\winhelp"
    Global $sourcepath       = $basepath        & "\winsource"
    Global $datapath         = $basepath        & "\windata"
	Global $themepath        = $basepath        & "\themes"
    Global $bootmanpath      = $basepath        & "\" & $bootmanstring
	Global $envfile          = $basepath        & "\grubenv"
    Global $storagepath      = $datapath        & "\storage"
    Global $systemdatafile   = $datapath        & "\system.info.txt"
	Global $backuppath       = $datapath        & "\backup"
	Global $updatedatapath   = $datapath        & "\updatedata"
    Global $efilogfile       = $storagepath     & "\EFIUpdate.log"
	Global $diskreportpath   = $storagepath     & "\diskreport.txt"
	Global $diskreportlfpath = $storagepath     & "\diskreport.linefeed.txt"
    Global $diskpartprefix   = $windowstempgrub & "\diskpart."
    Global $bcdprefix        = $windowstempgrub & "\bcd."
    Global $customtempfile   = $windowstempgrub & "\" & $customtempname
    Global $customtempstand  = $windowstempgrub & "\custom.standard.txt"
	Global $syntaxorigfile   = $windowstempgrub & "\" & $syntaxorigname
    Global $sysinfotempfile  = $windowstempgrub & "\system.info.temp.txt"
	Global $utillogfile      = $windowstempgrub & "\utilityscan.log.txt"
    Global $themebackgrounds = $themepath       & "\backgrounds"
    Global $iconpath         = $themepath       & "\icons"
    Global $themeconfig      = $themepath       & "\custom.config"
    Global $screenshotfile   = $themepath       & "\custom.screenshot.jpg"
	Global $themecustopt     = $themepath       & "\custom.options.txt"
    Global $themecustback    = $themepath       & "\custom.background.png"
    Global $themestandpath   = $themepath       & "\options.standard"
    Global $themelocalpath   = $themepath       & "\options.local"
	Global $themecommon      = $themepath       & "\common"
	Global $thememasterpath  = $themepath       & "\master"
    Global $themefaces       = $themecommon     & "\clockfaces"
    Global $themecolorsource = $themecommon     & "\colorsource"
	Global $themecolorcustom = $themecommon     & "\colorcustom"
	Global $themestatic      = $themecommon     & "\static"
	Global $themeempty       = $themestatic     & "\image.empty.png"
	Global $themedeffile     = $thememasterpath & "\options.txt"
    Global $themetemplate    = $thememasterpath & "\config.template.txt"
	Global $themetemp        = $windowstempgrub & "\themes"
	Global $themetempfiles   = $themetemp       & "\files"
	Global $themetemplocal   = $themetemp       & "\options.local"
	Global $themetempcust    = $themetemp       & "\colorcustom"
	Global $samplecustcode   = $sourcepath      & "\sample.customcode.txt"
    Global $sampleisocode    = $sourcepath      & "\sample.isoboot.txt"
    Global $samplesubcode    = $sourcepath      & "\sample.submenu.txt"
	Global $progtrackversion = CommonTrackVersion  ()
	Global $bootmanefi       = CommonGetEFIBootman ()
	Global $bootmodeefi      = CommonGetEFIMode    ()
	;MsgBox ($mbontop, "Vars", $basepath & @CR & $windowstempgrub & @CR & $progtrackversion)
EndFunc

Func CommonPrepareAll  ()
	If Not FileExists ($windowstempgrub) Then CommonSetupWinTemp ()
	CommonInitParms    ()
	Local $papid
		If @DesktopWidth < 800 Or @Desktopheight < 600 Then
		CommonShowError ("The minimum allowed display size is 800 x 600" & @CR & @CR & _
		"The current display setting is " & @DesktopWidth & " x " & @DesktopHeight)
		Exit
	EndIf
	$paproc = ProcessList ($exestring)
	If Not @error Then
		For $pasub = 1 To Ubound ($paproc) - 1
			If $paproc [$pasub] [1] <> @AutoItPID Then $papid = $paproc [$pasub] [1]
		Next
	EndIf
	If $papid <> "" Then
		$parc = MsgBox ($mbwarnokcan, "", "Grub2Win Is Already Running." & @CR & @CR & _
			"Click OK to continue or click Cancel.")
		If $parc = $IDCANCEL Then Exit
		ProcessClose ($papid)
		Sleep (500)
		CommonRestart ($runparms)
	EndIf
	Dim $logarray [1] [2]
	HotKeySet       ("{ESC}", "CommonEscape")
	HotKeySet       ("{F1}",  "CommonEscape")
EndFunc

Func CommonWriteLog ($wlrecord = "", $wladvance = 1, $wldisplay = "yes", $wlendchar = @CR)
	If $setupinprogress = "yes" Then
		CommonSetupWriteLog ($wlrecord, $wladvance)
		Return
	EndIf
	FileWrite ($handlelog, $wlrecord & $wlendchar)
	If $wladvance = 2 Then FileWrite ($handlelog, $wlendchar)
	If $wldisplay <> "yes" Then Return
	$wlcount = Ubound ($logarray)
	ReDim $logarray [$wlcount + 1] [2]
	$logarray [$wlcount] [0] = $wlrecord
	$logarray [$wlcount] [1] = $wladvance
EndFunc

Func CommonSetupWriteLog  ($swldata = "", $swladvance = "", $swldisplay = "yes")
	_ArrayAdd ($setuplogarray, $swldata)
	;$swldata = StringStripWS ($swldata, 1)
	If $swladvance = 2 Then _ArrayAdd ($setuplogarray, "")
	If CommonParms  ($actionsilent) Or $swldisplay = "" Then Return
	GuiCtrlSetData  ($setuphandlelist, " " & StringReplace ($swldata, @CR, "| ") & "|")
	GUICtrlSetState ($setuphandlelist, $guishowit)
EndFunc

Func CommonCheckpointLog ($cllogfilename, ByRef $cllogfilehandle)
	FileClose ($cllogfilehandle)
	$cllogfilehandle = FileOpen ($cllogfilename, 1)
EndFunc

Func CommonCalcDuration ($cdstarttimer, $cddurticks = "")
	$cdmilsecs = (Int (TimerDiff ($cdstarttimer))) + 500
	If $cddurticks <> "" Then $cdmilsecs = $cddurticks
	Return CommonFormatTicks ($cdmilsecs)
EndFunc

Func CommonGetUptime ()
	Local $tcreturn = DllCall('kernel32.dll', 'uint64', 'GetTickCount64')
	If @error Then Return
	Return CommonFormatTicks ($tcreturn [0])
EndFunc

Func CommonFormatTicks ($ftmilsecs)
	Local $fthours, $ftmins, $ftsecs, $ftout
	_TicksToTime ($ftmilsecs, $fthours, $ftmins, $ftsecs)
	$ftdays  = Int ($fthours / 24)
	$fthours = Mod ($fthours,  24)
	If $ftdays  > 0 Then $ftout &= $ftdays  & " Days "
	If $fthours > 0 Then $ftout &= $fthours & " Hours "
	If $ftmins  > 0 Then $ftout &= $ftmins  & " Minutes "
	If $ftsecs  > 0 Then $ftout &= $ftsecs  & " Seconds"
	If $ftdays  = 1 Then $ftout = StringReplace($ftout, "Days",    "Day")
	If $fthours = 1 Then $ftout = StringReplace($ftout, "Hours",   "Hour")
	If $ftmins  = 1 Then $ftout = StringReplace($ftout, "Minutes", "Minute")
	If $ftsecs  = 1 Then $ftout = StringReplace($ftout, "Seconds", "Second")
	Return $ftout
EndFunc

Func CommonGUIPause()
	Do
		$gpstatus = GUIGetMsg()
	Until $gpstatus <> "" And ($gpstatus = $GUI_EVENT_CLOSE Or $gpstatus = $buttonclose)
EndFunc

Func CommonInitialize  ()
	CommonSetHeaders   ()
	If Not FileExists  ($backuppath)  Then DirCreate ($backuppath)
	If Not FileExists  ($storagepath) Then DirCreate ($storagepath)
	CommonBackStep (5, "update", "log")
	$handlelog = FileOpen ($logfile, $FO_OVERWRITE)
	CommonWriteLog ("***  "                          & $progvermessage & "  ***", 1, "")
	CommonWriteLog ("                     Graphics " & $graphmessage,             1, "")
	CommonWriteLog ("                     Stamp  "   & $progtimestampdisp,        1, "")
	CommonWriteLog ("",                                                           1, "")
	CommonWriteLog ("Grub2Win Is Starting - The Current Time Is")
	CommonWriteLog (BasicTimeLine(), 2)
	If CommonParms ($actionsilent) Then CommonWriteLog _
	    ("*** This Is A Silent Install To " & $setuptargetdir & " ***")
EndFunc

Func CommonSetHeaders ()
	$shname     = "Grub2Win   Version " & $progversion
	CommonScaleIt (85, 90)
	$headermessage    = "     " & $shname & "       G=" & $graphmessage
	If $runparmsdisplay <> "" Then $headermessage &= "     P=" & $runparmsdisplay
	$progvermessage  = "Generated by " & $shname & "   from directory  " & @ScriptDir
	For $shsub = 0 To Ubound ($osparmarray) - 1
		If $osparmarray [$shsub] [$pFamily] = "" Then ContinueLoop
		If $firmwaremode = "EFI"  And $osparmarray [$shsub] [$pMode] = "BIOS" Then ContinueLoop
		If $firmwaremode = "BIOS" And $osparmarray [$shsub] [$pMode] = "EFI"  Then ContinueLoop
		If $procbits     =  32    And $osparmarray [$shsub] [$pMode] = "64B"  Then ContinueLoop
		$typestring &= $osparmarray [$shsub] [$pType] & "|"
	Next
EndFunc

Func CommonScaleCreate($scguitype, $sctext, $scleft, $sctop, $scwidth = "", $scheight = $scalehsize, $scstyle = "", $scexstyle = "")
	If $scleft > 100 Or $sctop > 100 Or $scwidth > 100 Or $scheight > 100 Then
		;CommonShowError ("ScaleCreate Error" & @CR & $scleft & @CR & $sctop & @CR & $scwidth & @CR & $scheight)
		;Exit
	EndIf
	$scleft   = Int($scalepcthorz * $scleft)
	$sctop    = Int($scalepctvert * $sctop)
	$scwidth  = Int($scalepcthorz * $scwidth)
	$scheight = Int($scalepctvert * $scheight)
	If $scwidth  < 1 Then $scwidth  = 1
	If $scheight < 1 Then $scheight = 1
	Select
		Case $scguitype  = "Label"
			$schandle = GUICtrlCreateLabel  ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Button"
			$schandle = GUICtrlCreateButton ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Checkbox"
			$schandle = GUICtrlCreateCheckbox ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Input"
			$schandle = GUICtrlCreateInput  ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Edit"
			$schandle = GUICtrlCreateEdit   ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Combo"
			$schandle = GUICtrlCreateCombo  ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Picture"
			$schandle = GUICtrlCreatePic    ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Group"
			$schandle = GUICtrlCreateGroup  ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Radio"
			$schandle = GUICtrlCreateRadio  ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "List"
			$schandle = GUICtrlCreateList   ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "PicturePNG"
			$schandle    = UserFuncGUICtrlPicCreate ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "LabelPicture"
			$schandle    = GUICtrlCreateLabel       ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
			$scalepicaux = UserFuncGUICtrlPicCreate ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case Else
			CommonShowError ("ScaleCreate" & @CR & "Invalid type = " & $scguitype)
	EndSelect
	Return $schandle
EndFunc

Func CommonBorderCreate ($bcimagefile, $bcleft, $bctop, $bcwidth, $bcheight, ByRef $bctexthandle, $bctext = "", $bcpix = 0.6)
	$bcborderhandle  = CommonScaleCreate ("Label", "", $bcleft, $bctop, $bcwidth + $bcpix, $bcheight + $bcpix)
	$bcinleft        = $bcleft   + $bcpix
	$bcintop         = $bctop    + $bcpix
	$bcinwidth       = $bcwidth  - $bcpix
	$bcinheight      = $bcheight - $bcpix
	CommonScaleCreate ("LabelPicture", $bcimagefile, $bcinleft, $bcintop, $bcinwidth, $bcinheight)
	If $bctext <> "" Then $bctexthandle = CommonScaleCreate _
		("Label", $bctext, $bcinleft, $bctop + $bcheight + $bcpix, $bcinwidth, 3, $SS_CENTER)
	Return $bcborderhandle
EndFunc

Func CommonScaleIt ($sihsize, $sivsize)
	$siwidth    = Int (@DesktopHeight * 1.30)
	If $siwidth >      @DesktopWidth Then $siwidth = @DesktopWidth
	$siheight   = Int ($siwidth * 0.75)
	$scalehsize = Int(((0.9 * $siwidth)  / 100) * $sihsize)
	$scalevsize = Int(((0.9 * $siheight) / 100) * $sivsize)
	If $scalehsize < 760 Or $scalevsize < 520 Or CommonParms ($advancedmode) Then
		$scalehsize = 760
		$scalevsize = 520
	EndIf
	$scalepcthorz  = $scalehsize / 100
	$scalepctvert  = $scalevsize / 100
	$scalefontsize = 8.5
	$graphmessage  = $graphsize & " (" & $scalehsize & "x" & $scalevsize & ")"
EndFunc

Func CommonDisplayLog ()
	$cdlimit = Ubound ($logarray) - 1
	If $cdlimit = $mainlogcount Then return
	$mainlogcount = $cdlimit
	;_ArrayDisplay ($logarray)
	$dldata = ""
	GUICtrlSetData ($mainloghandle, $dldata)
	For $dlsub = 1 To $cdlimit
		$dlrecord  = $logarray [$dlsub] [0]
		$dladvance = $logarray [$dlsub] [1]
		$dlspacer  = ""
		If $dladvance > 0 Then $dlspacer &= _StringRepeat ("|", $dladvance)
		$dldata &= $dlrecord & $dlspacer
	Next
	GUICtrlSetData ($mainloghandle, $dldata)
	If $cdlimit > 13 Then
		GUICtrlSetBkColor ($mainloghandle, $mywhite)
		_GUICtrlListBox_SetTopIndex ($mainloghandle, $cdlimit)
	EndIf
	GUISetState(@SW_SHOW, $handlemaingui)
EndFunc

Func CommonShowError ($semessage, $setitle = "** Grub2Win Error **", $searray = "")
	MsgBox ($mbwarnok, $setitle, $semessage, 60)
	If $searray <> "" Then _ArrayDisplay ($searray, "Array Size " & Ubound ($searray) -1)
EndFunc

Func CommonSaveListings ()
	Dim $slfrontarray [1]
	Dim $slbackarray  [0]
	_ArrayAdd ($slfrontarray, @CRLF)
	_ArrayAdd ($slfrontarray, "******      End of Grub2Win log       ****** ")
	If $firmwaremode = "EFI" Then
		If FileExists ($efilogfile) Then CommonLogStack ($slfrontarray, $efilogfile, "EFI Update")
		_ArrayAdd ($slfrontarray, _StringRepeat (@CRLF, 5))
	EndIf
	If $bootos = $xpstring Then
		_ArrayAdd ($slfrontarray, _StringRepeat (@CRLF, 5))
		_ArrayAdd ($slfrontarray, "                       ******  Start " & $xpinifile & " Listing  ******")
		$slinitime    = FileGetTime ($xpinifile, 0, 1)
		$slinistamp   = StringLeft ($slinitime, 4) & " - " & StringMid ($slinitime, 5, 4) & " - " & StringMid ($slinitime, 9, 6)
		_ArrayAdd ($slfrontarray, "                              Stamp = " & $slinistamp)
		$slbackarray = CommonFileReadToArray ($xpinifile)
		_ArrayAdd ($slbackarray,  "                       ******   End "  & $xpinifile & " Listing   ******")
		_ArrayConcatenate ($slfrontarray, $slbackarray)
	Else
		_ArrayAdd ($slfrontarray, "******  Start BCD Detail Listing  ******")
		_ArrayAdd ($slfrontarray, "As of " & BasicTimeLine ())
		CommonBCDRun ("/v", "listdetail")
		$slbackarray = $runarray
		_ArrayAdd ($slbackarray, "")
		If $firmwaremode = "EFI" Then
			_ArrayAdd ($slbackarray,  "")
			_ArrayAdd ($slbackarray,  "                               BCD Firmware entries")
			_ArrayAdd ($slbackarray,  _StringRepeat ("_", 85))
			CommonBCDRun ("/enum firmware", "listfirmware")
			_ArrayConcatenate ($slbackarray, $runarray)
			_ArrayAdd ($slbackarray, "")
		EndIf
		_ArrayAdd ($slbackarray,  "******   End BCD Detail Listing   ******")
		_ArrayConcatenate ($slfrontarray, $slbackarray)
	EndIf
	FileCopy         ($windowstemp & "\grub2win.*.txt", $updatedatapath & "\", 1)
	FileDelete       ($windowstemp & "\grub2win.*.txt")
	If FileExists    ($systemdatafile) Then CommonLogStack ($slfrontarray, $systemdatafile, "System and Secure Boot Information")
	CommonLogStack   ($slfrontarray, $configfile,                        "grub.cfg")
	CommonLogStack   ($slfrontarray, $datapath & $setuplogstring,        "Grub2Win Setup")
	CommonArrayWrite ($logfile, $slfrontarray, 1)
EndFunc

Func CommonLogStack (ByRef $lsfrontarray, $lsfile, $lsmessage)
	$lsbackarray = CommonFileReadToArray ($lsfile)
	If @error Then Return
	_ArrayAdd ($lsfrontarray, _StringRepeat (@CRLF, 5))
	_ArrayAdd ($lsfrontarray,     "******   Start " & $lsmessage & " listing   ******")
	_ArrayAdd ($lsfrontarray, "")
	_ArrayAdd ($lsbackarray,  "")
	_ArrayAdd ($lsbackarray,      "******    End " & $lsmessage & " listing    ******")
	_ArrayConcatenate ($lsfrontarray, $lsbackarray)
EndFunc

Func CommonBCDRun ($brcommand, $brtempfile = "temp", $brcheckerr = "yes")
	If $bcderrorfound <> "" Then Return 1
	$broutputpath = $bcdprefix & $brtempfile & ".command.txt"
	$brstring =  " /c " & $bcdexec & " " & $brcommand & " > " & $broutputpath
	$brrc     =  ShellExecuteWait (@Comspec, $brstring, "", "", @SW_HIDE)
	Sleep(100)   ;100 ms delay to allow any previous BCD commands to complete
	$runarray =  CommonFileReadToArray  ($broutputpath)
	$bclistarray = $runarray
	_ArrayInsert ($bclistarray, 0, "")
	_ArrayInsert ($bclistarray, 0, "  The Command Is - bcdedit " & $brcommand)
	_ArrayInsert ($bclistarray, 0, "")
	_ArrayInsert ($bclistarray, 0, "")
	CommonArrayWrite ($broutputpath, $bclistarray)
	If $brcheckerr = "" Then Return
	If $brrc <> 0 And Ubound ($runarray) < 30 Then
		$bcderrorfound = "yes"
		CommonShowError ("Return Code " & $brrc & @CR & "Error " & @error & @CR & _
			$brstring, "BCDExec Run Error.")
		_ArrayDisplay ($runarray)
		Return 1
	EndIf
EndFunc

Func CommonBackStep ($bscount, $bsname, $bsext, $bsfromdir = $basepath)
	If Not FileExists ($bsfromdir & "\" & $bsname & "." & $bsext) Then Return
	For $bssub = $bscount To 2 Step -1
		$bsoldfile = $backuppath & "\" & $bsname & ".previous-" & $bssub - 1 & "." & $bsext
		$bsnewfile = $backuppath & "\" & $bsname & ".previous-" & $bssub     & "." & $bsext
		If FileExists ($bsoldfile) Then FileMove ($bsoldfile, $bsnewfile, 1)
	Next
	FileMove ($bsfromdir & "\" & $bsname & "." & $bsext, $backuppath & "\" & $bsname & ".previous-1." & $bsext, 1)
EndFunc

Func CommonArrayWrite ($awoutfile, ByRef $awarray, $awopenmode = $FO_OVERWRITE)
	$awhandleout = FileOpen ($awoutfile, $awopenmode)
	If $awhandleout = -1 Then
		CommonShowError ($awoutfile, "ArrayWrite output file open error", $awarray)
		Return 1
	EndIf
	$awbound = UBound ($awarray) - 1
	For $awsub = 1 To $awbound
		$awline = $awarray[$awsub]
		If $awsub < $awbound Then $awline &= @CRLF
		FileWrite ($awhandleout, $awline)
	Next
	FileClose($awhandleout)
	Return 0
EndFunc

Func CommonFileReadToArray ($mfrinput, $mfrconvert = "")
	$mfrhandle    = FileOpen ($mfrinput, 0)
	If $mfrhandle = -1 Then
		CommonShowError ($mfrinput, "CommonFileReadToArray input file open error", $mfrinput)
		Return 1
	EndIf
	Dim $mfrarray [1]
	$mfrsub = 0
	While 1
		$mfrrec = FileReadLine ($mfrhandle)
		If @error Then ExitLoop
		If $mfrconvert <> "" Then $mfrrec = _WinAPI_OemToChar ($mfrrec)
		ReDim $mfrarray [$mfrsub + 1]
		$mfrarray [$mfrsub] = $mfrrec
		$mfrsub += 1
	WEnd
	FileClose ($mfrhandle)
	Return $mfrarray
EndFunc

Func CommonAddFileToArray ($afinput, ByRef $afarray, $afspace = "")
	$aftemparray = CommonFileReadToArray ($afinput)
	_ArrayConcatenate ($afarray, $aftemparray)
	If $afspace <> "" Then _ArrayAdd ($afarray, "")
	Return 0
EndFunc

Func CommonUpdateMessage ($umtext1 = "", $umtext2 = "", $umendmessage = "*** EFI Updates Are Complete ***", $umsleep = 750, $umheader = "Update In Progress")
	If $umtext1 <> "" Then
		If $upmessguihandle <> "" Then GUIDelete ($upmessguihandle)
		$upmessguihandle   = GUICreate          ($umheader, 400, 300, -1, -1, "", "", $handleordergui)
		$upmesstexthandle1 = GUICtrlCreateLabel ($umtext1,   10, 120, 380, 20, $SS_Center)
		$upmesstexthandle2 = GUICtrlCreateLabel ($umtext2,   10, 150, 380, 20, $SS_Center)
		GUISetBkColor ($mygreen, $upmessguihandle)
		GUISetState   (@SW_SHOW, $upmessguihandle)
		$upmessgstart = TimerInit ()
		Return
	EndIf
	$umsleepout = $umsleep - TimerDiff ($upmessgstart)
	If $upmessguihandle <> "" Then
		If $umendmessage <> "" Then
			GUICtrlSetData ($upmesstexthandle1, $umendmessage)
			GUICtrlSetData ($upmesstexthandle2, "")
			$umsleepout = $umsleep
		EndIf
	EndIf
	If $umsleepout > 0 Then Sleep ($umsleepout)
	GUIDelete ($upmessguihandle)
EndFunc

Func CommonParseStrip($pptext, $ppsearch)
	$pptext = StringReplace($pptext, '"', "")
	$pptext = StringReplace($pptext, "'", "")
	$pploc  = StringInStr($pptext, $ppsearch)
	If $pploc = 0 Then Return 0
	$parmstripped = StringReplace($pptext, $ppsearch, "")
	Return $parmstripped
EndFunc

Func CommonTitleSync ()
	$defaultstring = $lastbooted & "|"
	If $envreboot <> "none" Then $defaultstring = "|"
	For $tssub = 0 To Ubound ($selectionarray) -1
		If $envreboot <> "none" And $tssub = $envreboot Then ContinueLoop
		If $tssub = 0 Or $selectionarray [$tssub] [$sDefaultOS] = "DefaultOS" Then
			$defaultos    = $tssub
			$defaultset   = $tssub & "  -  " & $selectionarray [$tssub][$sEntryTitle]
		EndIf
		$defaultstring   &= $tssub & "  -  " & $selectionarray [$tssub][$sEntryTitle] & "|"
	Next
	If $defaultlastbooted = "yes" Then $defaultset = $lastbooted
EndFunc

Func CommonSetupDefault ($sfhoriz, $sfvert, $sfwidth, $sfheight)
	CommonTitleSync ()
	GUICtrlDelete   ($defaulthandle)
	$defaulthandle = CommonScaleCreate("Combo", "", $sfhoriz, $sfvert, $sfwidth, $sfheight, -1)
	If Ubound ($selectionarray) = 1 Then $defaultset = "0  -  " & $selectionarray [0] [$sEntryTitle]
	GUICtrlSetData ($defaulthandle, $defaultstring, $defaultset)
EndFunc

Func CommonDefaultSync ()
	For $dfsub = 0 To Ubound ($selectionarray) -1
		$selectionarray [$dfsub] [$sDefaultOS] = ""
		If $dfsub = $defaultos Then $selectionarray [$dfsub] [$sDefaultOS] = "DefaultOS"
	Next
EndFunc

Func CommonParmCalc ($pcmenusub, $pcgroup = "Held", $pccontrol = "")
	If $pccontrol = "Reset" Then
		For $lpasub = 0 To Ubound ($osparmarray) - 1
			$osparmarray [$lpasub] [$pHoldParms] = $osparmarray [$lpasub] [$pBootParms]
		Next
	EndIf
	$pctype    = $selectionarray[$pcmenusub][$sOSType]
	If $selectionarray [$pcmenusub] [$sBootParm] = "NullParm" and $pcgroup <> "Standard" Then Return ""
	If $selectionarray [$pcmenusub] [$sAutoUser] = "User" Then Return $selectionarray[$pcmenusub][$sBootParm]
	$pclpasub    = _ArraySearch($osparmarray, $pctype, 0, 0, 0, 0, 1, 0)
	If $pclpasub < 0 Then Return ""
	If $pccontrol = "Store"    Then $osparmarray [$pclpasub] [$pHoldParms] = $selectionarray[$pcmenusub][$sBootParm]
	If $pcgroup   = "Held"     Then Return $osparmarray [$pclpasub] [$pHoldParms]
	If $pcgroup   = "Standard" Then Return CommonSetBitmode ($osparmarray [$pclpasub] [$pBootParms], $procbits)
	If $pcgroup   = "Previous" Then Return $selectionarray[$pcmenusub][$sBootParm]
EndFunc

Func CommonSetBitmode ($sbstring, $sbmode = 32)
	$sbstring = StringReplace ($sbstring, "_x86_64 ", "_x86 ")
	If $sbmode = 64 Then $sbstring = StringReplace ($sbstring, "_x86 ", "_x86_64 ")
	Return $sbstring
EndFunc

Func CommonGetOSParms ($gopsub)
	$goptype = $selectionarray [$gopsub] [$sOSType]
	$goploc  = _ArraySearch ($osparmarray, $goptype)
	If @error Then $goploc = Ubound ($osparmarray) - 1
	Return $goploc
EndFunc

Func CommonCheckUpDown ($cudcontrolhandle, ByRef $cudlastdata, $cudlowlimit = 0, $cudhighlimit = 99)
	$cudnewdata = StringReplace (GUICtrlRead ($cudcontrolhandle), ",", "")
	If $cudnewdata < $cudlowlimit  Then $cudnewdata = $cudlowlimit
	If $cudnewdata > $cudhighlimit Then $cudnewdata = $cudhighlimit
	GUICtrlSetData ($cudcontrolhandle, $cudnewdata)
	$cudstatus   = ""
	If $cudlastdata <> "" And $cudnewdata <> $cudlastdata Then $cudstatus = 1
	$cudlastdata = $cudnewdata
	Return $cudstatus
EndFunc

Func CommonCheckBox ($cbhandle)
	$cbstatus = 0
	If BitAND (GUICtrlRead ($cbhandle), $GUI_CHECKED) = $GUI_CHECKED Then $cbstatus = 1
	Return $cbstatus
EndFunc

Func CommonConvDevAddr($cdadrive, $cdapartition)
	$cdaletters = "abcdefghij"
	$cdaout = "/dev/sd" & StringMid($cdaletters, $cdadrive + 1, 1) & $cdapartition
	Return $cdaout
EndFunc

Func CommonHelp ($chtopic)
	WinClose      ($helptitle)
	WinWaitClose  ($helptitle, "", 10)
	$chstring     = $helppath
	If CommonParms ($setupstring) Then $chstring = $setupbasepath & "\winhelp"
	$chstring    &= "\usermanual\" & $chtopic & ".html"
	ShellExecute  ($chstring)
	If @error Then MsgBox ($mbwarnok, _
		"Grub2Win Help Error", "The Help HTML File Was Not Found" & @CR &@CR & $chstring)
EndFunc

Func CommonArraySetDefaults($asdsub)
	If $selectionarray [$asdsub] [$sBootBy]    = "" And $selectionarray [$asdsub] [$sOSType]   = "windows"  Then $selectionarray[$asdsub][$sBootBy] = $modewinauto
	If $selectionarray [$asdsub] [$sBootBy]    = "" And $selectionarray [$asdsub] [$sFamily]  <> "template" Then $selectionarray[$asdsub][$sBootBy] = $modepartaddress
	If $selectionarray [$asdsub] [$sBootBy]    = "" And $selectionarray [$asdsub] [$sOSType]   = "android"  Then $selectionarray[$asdsub][$sBootBy] = $modebootdir
	If $selectionarray [$asdsub] [$sAutoUser]  = "" Then $selectionarray [$asdsub][$sAutoUser] = "Auto"
	If $selectionarray [$asdsub] [$sOSType]    = "" Then $selectionarray [$asdsub][$sOSType]   = "unknown"
	If ($selectionarray [$asdsub] [$sOSType]   = "other" And  $selectionarray [$asdsub][$sAutoUser] <> "User") Or _
	    $selectionarray [$asdsub] [$sOSType]   = "isoboot" Or $selectionarray [$asdsub] [$sOSType]   = "submenu"  _
		Then $selectionarray [$asdsub][$sAutoUser] = "Custom"
	$asdparmloc                                = CommonGetOSParms ($asdsub)
	$asdtitle                                  = $osparmarray [$asdparmloc] [$pTitle]
	If $selectionarray[$asdsub][$sEntryTitle]  = "" Then $selectionarray[$asdsub][$sEntryTitle]  = $asdtitle
	If $selectionarray[$asdsub][$sSortSeq]     = "" Then $selectionarray[$asdsub][$sSortSeq]     = ($asdsub * 100)
	If $selectionarray[$asdsub][$sGraphMode]   = "" Then $selectionarray[$asdsub][$sGraphMode]   = $graphnotset
	If $selectionarray[$asdsub][$sHotKey]      = "" Then $selectionarray[$asdsub][$sHotKey]      = "none"
	If $selectionarray[$asdsub][$sDiskAddress] = "" Then $selectionarray[$asdsub][$sDiskAddress] = 0
	If $selectionarray[$asdsub][$sPartAddress] = "" Then $selectionarray[$asdsub][$sPartAddress] = 0
	If $selectionarray[$asdsub][$sReviewPause] = "" Then $selectionarray[$asdsub][$sReviewPause] = 0
	If $selectionarray[$asdsub][$sIcon]        = "" Then $selectionarray[$asdsub][$sIcon]        = "icon-" & $selectionarray [$asdsub] [$sOSType]
	If StringInStr ($selectionarray[$asdsub][$sIcon], "windows") Then $selectionarray[$asdsub][$sIcon] = "icon-windows"
EndFunc

Func CommonSetupSysLines ($sslefilevel, $ssletype = "")
	$syslineos = "The OS is " & $bootos & "   " & $osbits & " bit   "
	$cemode    = "Boot mode is " & $systemmode
	If $firmwaremode   = "EFI" Then
		$cemode        = $ssletype & "EFI level is " & $sslefilevel
		$syslinesecure = "Secure Boot is " & $securebootstatus
	EndIf
	$syslineos &= $cemode
EndFunc

Func CommonContentStringCheck ($csshandle, ByRef $cssok, $cssmaxlength, $cssallowslash = "no")
	$cssfield = GUICtrlRead   ($csshandle)
	$cssfield = StringStripWS ($cssfield, 3)
	$csscheck = StringStripWS ($cssfield, 8)
	$csscheck = StringReplace ($csscheck, ".", "")
	$csscheck = StringReplace ($csscheck, "-", "")
	If $cssallowslash = "yes" Then $csscheck = StringReplace($csscheck, "/", "")
	GUICtrlSetData ($csshandle, $cssfield)
	$cssok = ""
	If Not StringIsAlNum($csscheck) Or StringLen($cssfield) < 1 Or StringLen($cssfield) > $cssmaxlength Then
		$cssok = "no"
	EndIf
	Return $cssfield
EndFunc

Func CommonDriversInUse ()
	If $driveruseata = "yes" Or $driveruseraid  = "yes" Or $driveruseusb = "yes" Or _
		$driveruselv = "yes" Or	$driverusecrypt = "yes" Then Return 1
EndFunc

Func CommonDriversClearUse ()
	$driveruseata   = ""
	$driveruseraid  = ""
	$driveruseusb   = ""
	$driveruselv    = ""
	$driverusecrypt = ""
	$driverusesleep = ""
EndFunc

Func CommonEndIt ($eiresult, $eireturnit = "no")
	If $handlemaingui <> "" Then GUIDelete ($handlemaingui)
	$handlemaingui  = GUICreate ($headermessage & "      L=" & $langheader, $scalehsize, $scalevsize, -1, -1, -1)
	If $mainloghandle <> "" Then GUICtrlDelete ($mainloghandle)
	$mainloghandle  = CommonScaleCreate ("List", "", 2, 5, 95, 85, 0x00200000)
    GUICtrlSetFont ($mainloghandle, 11)
	$buttonclose    = CommonScaleCreate ("Button", "Close", 47, 92, 10, 3.5)
	CommonWriteLog ()
	$eitime = BasicTimeLine()
	$eicolor = $mygreen
	Select
		Case $eiresult =  "Success"
			CommonWriteLog("The Grub2Win run was successful at " & $eitime)
		Case $eiresult =  "XPClose"
			CommonWriteLog("XP update was directed to the Grub2Win download site at " & $eitime, 1, "yes")
		Case $eiresult =  "Failed"
			CommonWriteLog("*** Grub2Win failed ***   at " & $eitime)
			$eicolor = $myred
		Case $eiresult = "Diagnostics"
			CommonWriteLog("Grub2Win diagnostics were run at " & $eitime)
			$eicolor = $myorange
		Case $eiresult <> "Restart"
			CommonWriteLog("*** Grub2Win was cancelled ***  at " & $eitime)
			$eicolor = $myyellow
	EndSelect
	CommonWriteLog     ("Run duration was " & CommonCalcDuration ($startmilsec), 1, "yes", "")
	CommonDisplayLog   ()
	GUICtrlSetBkColor  ($mainloghandle, $eicolor)
	GUISetBkColor      ($eicolor, $handlemaingui)
	GUISetState        (@SW_SHOW, $handlemaingui)
	FileClose          ($handlelog)
	WinClose           ("System Information", "")
	If $eireturnit = "yes" Then Return
	CommonSaveListings ()
	CommonSetupWinTemp ("yes")
	If $eiresult = "Restart" Then
		Run ($baseexe)
		Exit
	EndIf
	If $efiexit = "yes" Or $eiresult = "Escape" Or $eiresult = "XPClose" Or CommonParms ($rebootstring) Then Exit
	CommonGuiPause()
	Exit
EndFunc

Func CommonThemeGetOption ($tgoparm, $tgolower = "", $tgoarray = $themetempoptarray)
	$tgoloc = _ArraySearch ($tgoarray, $tgoparm, 0, 0, 0, 0, 0, 2)
	If @error Then Return ""
	$tgovalue = $tgoarray [$tgoloc] [3]
	If $tgolower <> "" Then $tgovalue = StringLower ($tgovalue)
	Return $tgovalue
EndFunc

Func CommonThemePutOption ($tpoparm, $tpovalue, ByRef $tpoarray)
	$tpoloc = _ArraySearch ($tpoarray, $tpoparm, 0, 0, 0, 0, 0, 2)
	If @error Then Return ""
	$tpoarray [$tpoloc] [3] = StringLower ($tpovalue)
EndFunc

Func CommonSetupWinTemp ($wtcleanup = "")
	                         DirRemove ($windowstempgrub, 1)
	If $wtcleanup  = "" Then DirCreate ($windowstempgrub)
EndFunc

Func CommonAndroidArray ($aasub, $aaparm = $selectionarray [$aasub] [$sBootParm])
	$selectionarray[$aasub][$sNvidia] = "no"
	If StringInStr ($aaparm, $parmnvidia) Then $selectionarray[$aasub][$sNvidia] = "yes"
EndFunc

Func CommonControlGet ($cghandlewindow, $cghandlecontrol, ByRef $cgabspos)
	$cgworkhandle = ControlGetHandle ($cghandlewindow, "",$cghandlecontrol)
	$cgabspos     = WinGetPos ($cgworkhandle)
	If @error Then Return 0
	$controlhorizhold = $cgabspos [0]
	Return $cgabspos [1]
EndFunc

Func CommonMouseMove ($mmhandlewindow, $mmhandlecontrol)
	$mmnewposvert  = CommonControlGet ($mmhandlewindow, $mmhandlecontrol, $dummyparm)
	MouseMove ($controlhorizhold, $mmnewposvert, 1)
EndFunc

Func CommonControlCheckClick ($cchandlewindow, $cchandlecontrol)
	If ControlCommand ($cchandlewindow, "", $cchandlecontrol, "IsEnabled") Then
		Local $ccarray
		$ccreturn = CommonControlGet ($cchandlewindow, $cchandlecontrol, $ccarray)
		If $ccreturn <> 0 Then
			$ccmousehor  = MouseGetPos (0)
			$ccmousevert = MouseGetPos (1)
			If $ccmousehor  >= $ccarray [0] And  $ccmousehor  <= $ccarray [0] + $ccarray [2] And _
			   $ccmousevert >= $ccarray [1] And  $ccmousevert <= $ccarray [1] + $ccarray [3] Then Return 1
		EndIf
	EndIf
EndFunc

Func CommonScrollDelete ($sdhandle)
	$sdtoppos = _GUIScrollBars_GetScrollPos ($sdhandle, $SB_VERT)
	If $sdtoppos < 0   Then $sdtoppos = 0
	If $sdhandle <> "" Then GuiDelete ($sdhandle)
	$sdhandle = ""
	Return $sdtoppos
EndFunc

Func CommonScrollGenerate ($sghandlescroll, $sghsize, $sgmaxvsize)
	_GUIScrollbars_Generate ($sghandlescroll, $sghsize, $sgmaxvsize)
	If _GUIScrollBars_GetScrollInfoPage ($handleselectionscroll, $SB_VERT) < 1 Then Return
	If $scrolltoppos > 0 Then _GUIScrollBars_SetScrollInfoPos ($sghandlescroll, $SB_VERT, $scrolltoppos)
EndFunc

Func CommonScrollMove ($smhandlewindow, $smhandlescroll, $smhandlecontrol, $smupdown, $smminbumppos)
	$smpagepos    = _GUIScrollBars_GetScrollInfoPage ($smhandlescroll, $SB_VERT)
	If $smpagepos = 0 Then
		CommonMouseMove ($smhandlewindow, $smhandlecontrol)
		Return
	EndIf
	$smtag         = _GUIScrollBars_GetScrollBarInfoEx($smhandlescroll, $OBJID_VSCROLL)
	$smscrollvtop  =  DllStructGetData ($smtag, "Top")
	$smscrollvbot  =  DllStructGetData ($smtag, "Bottom")
	$smthumbvbot   =  DllStructGetData ($smtag, "xyThumbBottom") - $smscrollvtop
    $smmaxpos      = _GUIScrollBars_GetScrollInfoMax  ($smhandlescroll, $SB_VERT)
	$smbumppos     = Int ($smmaxpos * .10)
	$smrangev      = $smscrollvbot - $smscrollvtop
	$smlimtopv     = Int (0.25 * $smrangev) + $smscrollvtop
	$smlimbotv     = Int (0.75 * $smrangev) + $smscrollvtop
	$smmouseabs    = MouseGetPos (1)
	If $smbumppos  < $smminbumppos Then $smbumppos = $smminbumppos
	$smnewtoppos   = $scrolltoppos
	;MsgBox ($mbontop, "Mouse " & $smmouseabs, $smlimtopv & @CR & $smlimbotv & @CR & $smupdown)
	If $smmouseabs > $smlimbotv And $smupdown = "down" Then
		$smnewtoppos = $scrolltoppos + $smbumppos
		If $smthumbvbot > $smlimbotv Then $smnewtoppos = $smmaxpos - $smpagepos + 1
	EndIf
	If $smmouseabs < $smlimtopv And $smupdown = "up"   Then $smnewtoppos = $scrolltoppos - $smbumppos
	If $smnewtoppos < $smminbumppos Then $smnewtoppos = 0
	If $smnewtoppos <> $scrolltoppos Then _GUIScrollBars_SetScrollInfoPos ($smhandlescroll, $SB_VERT, $smnewtoppos)
	CommonMouseMove ($smhandlewindow, $smhandlecontrol)
EndFunc

Func CommonPrevParse ($cpptext, $cppsearch, $cppfindposition = "*")
	If StringLeft($cpptext, 1) = "#" Then Return 0
	If Not StringInStr($cpptext, $cppsearch) Then Return 0
	$cpptext = CommonStripSpecial($cpptext)
	$parsearray = _StringBetween ($cpptext, "'", "'")
	If Not @error And StringLen ($parsearray [0]) <> 0 Then
		For $cppsub = 0 To Ubound ($parsearray) - 1
			$cppfrom = $parsearray [$cppsub]
			$cppto   = StringReplace ($cppfrom, " ", "%")
			$cpptext = StringReplace ($cpptext, $cppfrom, $cppto, 1)
		Next
	EndIf
	$parsearray = StringSplit ($cpptext, " ")
	If @error Then Return 0
	$cppsub = 1
	$cpplimit = UBound ($parsearray) - 1
	While $cppsub < $cpplimit
		$cppnull = StringStripWS ($parsearray [$cppsub], 3)
		If $cppnull = "" Then
			_ArrayDelete ($parsearray, $cppsub)
			$cpplimit -= 1
			ContinueLoop
		EndIf
		$cppnull              = StringReplace ($cppnull, "%", " ")
		$parsearray [$cppsub] = StringReplace ($cppnull, "'", "")
		If $cppfindposition = "*" And $parsearray[$cppsub] = $cppsearch Then $cppfindposition = $cppsub
		$cppsub += 1
	Wend
	If $cppfindposition > $cpplimit Then Return 0
	If $parsearray[$cppfindposition] <> $cppsearch Then Return 0
	$parseposition = $cppfindposition
	$parseresult1 = ""
	If $parseposition + 1 < UBound($parsearray) Then $parseresult1 = $parsearray[$parseposition + 1]
	$parseresult2 = ""
	If $parseposition + 2 < UBound($parsearray) Then $parseresult2 = $parsearray[$parseposition + 2]
	Return 1
EndFunc

Func CommonShortcut ($csmakeshortcut)
	If $csmakeshortcut = "yes" Then
		$csshortlink = StringTrimRight ($shortcutfile, 4)
		$csshortprog = $baseexe
		$csshorticon = $basepath & "\winsource\xxgrub2win.ico"
		$csshortmsg  = "The Grub2Win Desktop Shortcut Was Created."
		If FileExists      ($shortcutfile) Then $csshortmsg = "The Existing Grub2Win Desktop Shortcut Was Kept."
		FileDelete         ($shortcutfile)
		FileCreateShortcut ($csshortprog, $csshortlink, "", "", "", $csshorticon)
	Else
		$csshortmsg   = "The Grub2Win Desktop Shortcut Was Not Requested."
		If FileExists ($shortcutfile) Then $csshortmsg = "The Grub2Win Desktop Shortcut Was Removed."
		FileDelete    ($shortcutfile)
	EndIf
	Return $csshortmsg
EndFunc

Func CommonGetEFILevel ($geldir, $gelcheckbcd = "no")
	If $gelcheckbcd = "yes" and $bcdgrubbootid = "" Then Return "none"
	$gelhandle = FileFindFirstFile ($geldir & $efilevelfile & ".*.*")
	$gelname   = FileFindNextFile  ($gelhandle)
	FileClose ($gelhandle)
	$gelsplit  = StringSplit       ($gelname, ".")
	If Ubound ($gelsplit) < 4 Then Return "none"
	Return $gelsplit [3]
EndFunc

Func CommonGetEFIBootman ()
	$gebmode = CommonGetEFIMode ()
	If $gebmode = 32 Then Return $bootmanefi32
	Return $bootmanefi64
EndFunc

Func CommonGetEFIMode ()
	If $procbits = 32 Then Return $procbits
	If $osbits   = 64 Then Return $osbits
	$gemhandle = FileFindFirstFile ($storagepath & $efimodefile & ".*.*")
	$gemname   = FileFindNextFile  ($gemhandle)
	FileClose ($gemhandle)
	If StringInStr ($gemname, 32) Then Return 32
	Return 64
EndFunc

Func CommonPutEFIMode ($pembits)
	If $procbits = 32 Then $pembits = $procbits
	If $osbits   = 64 Then $pembits =  $osbits
	Dim $pemarray [2]
	$pemarray [1] = "Placeholder for the EFI mode setting"
	FileDelete       ($storagepath & $efimodefile & ".*.*")
	CommonArrayWrite ($storagepath & $efimodefile & "." & $pembits & ".txt", $pemarray)
EndFunc

Func CommonDiagnose ($cderrorcode)
	If $diagcomplete = "yes" Then Return
	$cddiagdir = $basepath & "\diagnose"
	If FileExists ($cddiagdir) Then DirRemove ($cddiagdir, 1)
	EnvSet  ("diagauto",  "yes")
	EnvSet  ("basedir",   $basepath)
	EnvSet  ("errorcode", $cderrorcode)
	CommonWriteLog ("Diagnostics are now being run")
	CommonWriteLog ("This may take up to 60 seconds")
	CommonWriteLog ()
	CommonUpdateMessage ("The Grub2Win Diagnostics Are Running", "This May Take Up To 60 Seconds", "", 750, "Diagnostics")
	RunWait ($sourcepath & "\xxdiag.bat", "", @SW_MINIMIZE)
	CommonUpdateMessage ("", "", "Diagnostics Are Complete")
	If FileExists ($cddiagdir) Then
		CommonWriteLog ("Diagnostics are complete, the data has been stored in directory " & $cddiagdir)
	Else
		CommonWriteLog ("The diagnostic routine failed")
	EndIf
	$diagcomplete = "yes"
EndFunc

Func CommonRunBat ($rbsource, $rbname, $rbvar = "set basepath=" & $basepath, $rbshow = @SW_SHOW, $rbexit = "yes")
	$rbarray = CommonFileReadToArray ($sourcepath & "\" & $rbsource)
	_ArrayInsert ($rbarray, 0, "")
	_ArrayInsert ($rbarray, 2, $rbvar)
	$rbtemp     = $windowstemp & "\" & $rbname
	CommonArrayWrite ($rbtemp, $rbarray)
	Run ($rbtemp, "", $rbshow)
	If $rbexit = "yes" Then Exit
EndFunc

Func CommonGetLabel ($gldrive)
	$gllabel = DriveGetLabel ($gldrive)
	If @error Or $gllabel = "" Then $gllabel = "** Unlabeled **"
	Return $gllabel
EndFunc

Func CommonFormatSize ($fsbytes, $fsjustify = "")
	$fsoutstring =                           StringFormat ("%4.0f",      $fsbytes)          & " Bytes"
	If $fsbytes >= $kilo Then $fsoutstring = StringFormat ("%4.0f", Int ($fsbytes / $kilo)) & " KB"
	If $fsbytes >= $mega Then $fsoutstring = StringFormat ("%4.0f", Int ($fsbytes / $mega)) & " MB"
	If $fsbytes >= $giga Then $fsoutstring = StringFormat ("%4.0f", Int ($fsbytes / $giga)) & " GB"
	If $fsbytes >= $tera Then $fsoutstring = StringFormat ("%4.1f",      $fsbytes / $tera ) & " TB"
	$fsoutstring = StringStripWS ($fsoutstring, 3)
	$fsoutstring = StringReplace ($fsoutstring, ".0", "")
	If $fsjustify <> "" Then $fsoutstring = _StringRepeat (" ", 6 - StringLen ($fsoutstring)) & $fsoutstring
	Return $fsoutstring
EndFunc

Func CommonStripSpecial ($csstext)
	$csstext = StringReplace($csstext, '"', "'")
	$csstext = StringReplace($csstext, '{', "")
	$csstext = StringReplace($csstext, '}', "")
	Return $csstext
EndFunc

Func CommonPadRight ($prinput, $prlength, $prchar = " ")
	$prinput     = StringLeft ($prinput, $prlength)
	$prexpand    = $prlength - StringLen ($prinput)
	If $prexpand > 0 Then $prinput = $prinput & _StringRepeat ($prchar, $prexpand)
	Return ($prinput)
EndFunc

Func CommonStampUnique ()
	$timeunique += 1
	Return @MON & @MDAY & StringRight (@YEAR, 2) & @HOUR & @MIN & @SEC & "-" & StringFormat ("%03i", $timeunique)
EndFunc

Func CommonEscape ()
	If $updatehandlegui <> "" And WinGetState ($updatehandlegui) = 15 Then
		$updateMode = "ShowRefresh"
		GUICtrlSetBkColor ($updatehandledown, $myorange)
		GUICtrlSetState   ($updatehandledown, $guishowit)
		Return
	EndIf
	If (Not CommonParms ("Setup") And WinGetState ($handlemaingui)  <> 15) Or   _
		   (CommonParms ("Setup") And WinGetState ($setuphandlegui) <> 15) Then
		    CommonEscapeOut ()
			Return
	EndIf
	HotKeySet      ("{ESC}")
	HotKeySet      ("{F1}")
	If CommonParms ($advancedmode) Then
		MsgBox ($mbontop, "", "** You are already running in  Advanced Mode **")
		HotKeySet  ("{ESC}", "CommonEscape")
		HotKeySet  ("{F1}",  "CommonEscape")
		CommonEscapeOut ()
		Return
	EndIf
	$cerc = MsgBox ($mbquestyesno, "", "Do you want to enter  Advanced Mode?")
	HotKeySet      ("{ESC}", "CommonEscape")
	HotKeySet      ("{F1}",  "CommonEscape")
	If $cerc = $IDYES Then
		If CommonParms ("Setup") Then CommonSetupCloseOut ()
		$cename = BasicCapIt (StringTrimRight (@ScriptName, 4))
		MsgBox ($mbinfook, "** Restart **", "Now restarting " & $cename & " in Advanced Mode ", 2)
		CommonRestart ($runparms & $advancedmode)
	EndIf
	CommonEscapeOut ()
EndFunc

Func CommonNotepad ($cnnotefile, $cnnotewinname = "", $cnnotetitle = "", $cncallerhandle = "")
	$cnnotehandle = $tera
	$cnpid        = ShellExecute  ($notepadexec, $cnnotefile)
	If $cncallerhandle <> "" Then
		GUISetBkColor  ($myred, $cncallerhandle)
		$cncallertitle = WinGetTitle ($cncallerhandle)
		WinSetTitle    ($cncallerhandle, "", "    ****  Waiting for the Notepad window to appear ****")
		$cnnotehandle  = WinWaitActive ($cnnotewinname, "", 10)
		WinSetTitle    ($cncallerhandle, "", "    ****  Waiting for you to finish editing the custom code in Notepad ****")
		WinSetTitle    ($cnnotehandle, "", $cnnotetitle)
		$cnloc         = WinGetPos ($cncallerhandle)
		If Not @error Then WinMove ($cnnotehandle, "", $cnloc [0] - 10, $cnloc [1] - 10, $cnloc [2], $cnloc [3], 1)
		While ProcessExists ($cnpid) And $cnnotehandle <> 0
			Sleep (200)
		Wend
		WinSetTitle   ($cncallerhandle, "", $cncallertitle)
	EndIf
	If $cnpid = 0 Or $cnnotehandle = 0 Then
		MsgBox ($mbwarnok, "** Notepad Error **",                                                    _
			"The Windows Notepad program did not initialize properly, run cancelled." & @CR  & @CR & _
			$cnnotefile & @CR & @CR & "RC=" & $cnpid & "-" & $cnnotehandle)
		Exit
	EndIf
	Return $cnpid
EndFunc

Func CommonRestart ($crparms)
	$crexe = StringReplace (@ScriptFullPath, ".au3", ".exe")
	Run    ('"' & $crexe & '" '    & $crparms)
	If @error Then
		MsgBox ($mbontop, "", "** Restarting From " & '"' & $crexe & '" **', 2)
		Run    ('"' & $crexe & '" '    & $crparms)
	EndIf
	Exit
EndFunc

Func CommonEscapeOut ()
	$eorc = MsgBox ($mbquestyesno, "", "Do you want to cancel Grub2Win?")
	If $eorc = $IDYES Then CommonEndit ("Cancelled")
EndFunc

Func CommonTrackVersion ()
	$tvver   = BasicFormatVersion ($baseexe)
	;$tvver = "1.0.2.4"   ; Test
	$tvnum   = Number (StringReplace ($tvver, ".", ""))
    $tvtrack = StringTrimRight ($tvver, 1) & "X"
	If $tvnum < 1030              Then $tvtrack = "Earlier"
	If $tvnum = 0000              Then $tvtrack = "Testing"
	If Not FileExists ($basepath) Then $tvtrack = "NoFile"
	Return $tvtrack
EndFunc

Func CommonTrackDown ($tdtype)
	$tdurl    = $trackurl    & "/"          & $progtrackversion & "-" & $tdtype & ".txt/download"
	$tdfile   = $windowstemp & "\grub2win." & $progtrackversion & "-" & $tdtype & ".txt"
	$tddiag   = $windowstemp & "\grub2win.trackdiag.txt"
    $tdparms  = " " & $tdurl & " --no-verbose --no-check-certificate -O " & $tdfile & " -o " & $tddiag
	Run ($wgetpath & $tdparms, "", @SW_HIDE)
EndFunc

Func CommonDownloadLog ($dltext)
	$dlhandle = FileOpen ($downloadlog, 1)
	FileWriteLine        ($dlhandle, BasicTimeLine () & "    " & $dltext)
	FileClose            ($dlhandle)
EndFunc

Func CommonInitParms ()
	Local $ipsetup
	If  $Cmdline  [0] > 0 Then $runparm1 = $Cmdline [1]
	If  $Cmdline  [0] > 1 Then $runparm2 = $Cmdline [2]
	If  $Cmdline  [0] > 2 Then $runparm3 = $Cmdline [3]
	$runparms = $runparm1 & " " & $runparm2 & " " & $runparm3
	If StringInStr ($runparms, "Setup") Then $ipsetup = "Setup"
	$runparmsdisplay = StringStripWS (StringReplace ($runparms, "Setup", ""), 7)
	$runparms        = $runparmsdisplay & $ipsetup
	If CommonParms ($advancedmode) Then
		$sdmsgrc = MsgBox ($mbwarnokcan, "** Grub2Win Advanced Mode Warning **",                 _
	    "Running in Advanced Mode can damage your system!"            & @CR & @CR &       _
		"Make sure that you have good backups and be very careful." &   @CR & @CR & @CR & _
		"Click OK to continue or click Cancel")
		If $sdmsgrc <> $IDOK Then Exit
	EndIf
EndFunc

Func CommonParms ($cpparm)
	If StringInStr ($runparms, $cpparm) Then Return 1
EndFunc

Func CommonSetupCloseOut ()
   	CommonSetupWriteLog ("End Setup - " & BasicTimeLine ())
	CommonArrayWrite    ($setuplogfile, $setuplogarray)
	FileCopy            ($setuplogfile, $datapath & "\", 1)
	FileCopy            ($downloadlog,  $datapath & "\", 1)
	FileCopy            ($windowstempgrub & $encryptstring, $storagepath & $encryptstring, 1)
EndFunc