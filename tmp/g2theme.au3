#include-once
#include <g2common.au3>
#include <g2getprev.au3>

If StringInStr (@ScriptName, "g2theme") Then
	HotKeySet  ("{ESC}", "ThemeEscape")
	HotKeySet  ("{F1}",  "ThemeEscape")
	GetPrevConfig    ()
	CommonScaleIt    (85, 90)
	ThemeEdit        ()
	ThemeUpdateFiles ()
EndIf

Func ThemeEdit          ()
	ThemeCreateHold ()
	ThemeSetupGUI       ()
	$terc = ThemeRunGUI ()
	Return $terc
EndFunc

Func ThemeSetupGUI ()
	If $handlethemegui <> "" Then GuiDelete ($handlethemegui)
	$handlethemegui    = GUICreate ("Customize Theme", $scalehsize + 70, $scalevsize + 40, -1, -1, -1, -1, $handlemaingui)
	                     CommonScaleCreate ("Label",    "Click the image to select your background", 5, 6.8, 33, 2.2)
	$buttonthemehelp   = CommonScaleCreate ("Button",   "Help",                     99,   3,   8, 3.5)
	GUICtrlSetBkColor  ($buttonthemehelp, $mymedblue)
	$buttonthemecolgrp = CommonScaleCreate ("Group",    "Set Colors",               47,   0,   47, 8, $BS_CENTER)
	$buttonthemecoltit = CommonScaleCreate ("Button",   "Titles",                   50,   3,    7, 3.5)
	$buttonthemecolsel = CommonScaleCreate ("Button",   "Selected Item",            60,   3,   10, 3.5)
	$buttonthemecoltxt = CommonScaleCreate ("Button",   "Text",                     73.5, 3,    7, 3.5)
	$buttonthemecolclk = CommonScaleCreate ("Button",   "Clock",                    84,   3,    7, 3.5)
	$handlethemeshot   = CommonScaleCreate ("Label",    "",                          4,   9,  101, 79)
	$handlethemepic    = CommonScaleCreate ("Picture",  $screenshotfile,             4,   9,  101, 79)
	$handlethemetime   = CommonScaleCreate ("Checkbox", " Enable Grub Timeout",      6,  90,   16, 3.5)
	$handlethemesecs   = CommonScaleCreate ("Input",    $timeloader,                22,  90.5,  4.5, 3, $ES_RIGHT)
	$handlethemeseclab = CommonScaleCreate ("Label",    "seconds",                  27,  90.5,  8,   3)
	$handlethemesecud  = GUICtrlCreateUpdown ($handlethemesecs, $UDS_ALIGNLEFT)
    $handlethemelabs   = CommonScaleCreate ("Label",    "Style",                    18.5, 95.8,  8, 3.5)
	$handlethemestyle  = CommonScaleCreate ("Combo",    "",                         22,   95.3, 14, 10,  -1)
	$handlethemelab1   = CommonScaleCreate ("Label",    "Face",                     18.5, 99.3,  8, 3.5)
	$handlethemeface   = CommonScaleCreate ("Combo",    "",                         22,   99,  15, 3.5, -1)
	$handlethemedesc   = CommonScaleCreate ("Label",    "",                         45,   88,  17, 3.5, $SS_CENTER)
	$handlethemedark   = CommonScaleCreate ("Checkbox", " Dark Background",         45,   92,  20, 3.5)
	$handlethemescroll = CommonScaleCreate ("Checkbox", " Scroll Bar",              45,   97,  20, 3.5)
	$handlethemelines  = CommonScaleCreate ("Checkbox", " Show Prompt Lines",       45,  102,  20, 3.5)
	$handlethemevers   = CommonScaleCreate ("Checkbox", " Show Grub2Win Version",   68,   92,  20, 3.5)
	$handlethememode   = CommonScaleCreate ("Checkbox", " Show Boot Mode",          68,   97,  25, 3.5)
	$buttonthemereset  = CommonScaleCreate ("Button",   "Set Standard View",        93,   90,  13, 3.8)
	$buttonthemecancel = CommonScaleCreate ("Button",   "Cancel",                    4,  100,  10, 3.8)
	$buttonthemeok     = CommonScaleCreate ("Button",   "OK",                       94,  100,  10, 3.8)
	GUICtrlSetData     ($handlethemeface,  ThemeGetFaces (), CommonThemeGetOption ("face"))
	GUICtrlSetData     ($handlethemestyle, "Clock|Progress Bar")
	GUISetBkColor      ($mylightgray, $handlethemegui)
	ThemeRefreshHandles  ()
	GUISetState        (@SW_MINIMIZE, $handlemaingui)
	GUISetState        (@SW_SHOW,     $handlethemegui)
EndFunc

Func ThemeRunGUI ()
	Local $rgprevname, $rgprevstyle, $rgprevface
	$rgname        = CommonThemeGetOption ("name",  "lower")
	ThemeGetLocal ($rgname)
	$rgstyle       = CommonThemeGetOption ("style", "lower")
	$rgface        = CommonThemeGetOption ("face",  "lower")
	$rgtime        = $GUI_UNCHECKED
	$rgholdenabled = $timerenabled
	If $timerenabled = "yes" Then $rgtime = $GUI_CHECKED
	GUICtrlSetState ($handlethemetime, $rgtime)
	ThemeRefreshGUI ()
	While 1
		$rgreturn = GUIGetMSG (1)
		$rgstatus = $rgreturn [0]
		$rghandle = $rgreturn [1]
		If $rgstatus < 1 And $rgstatus <> $GUI_EVENT_CLOSE And $rgstatus <> $GUI_EVENT_PRIMARYUP And _
		    $rgstatus <> $GUI_EVENT_PRIMARYDOWN Then ContinueLoop
		Select
			Case $rgstatus = $GUI_EVENT_CLOSE Or $rgstatus = $buttonthemecancel
				If $rghandle <> $handlethemegui Then ContinueLoop
				$timerenabled = $rgholdenabled
				ThemeRestoreHold ()
				ExitLoop
			Case $rgstatus = $GUI_EVENT_PRIMARYUP
				If CommonCheckUpDown ($handlethemesecs, $timeloader, 0, 999) Then ThemeRefreshGUI ()
			Case $rgstatus = $buttonthemehelp
				CommonHelp ("customizingthetheme")
				ContinueLoop
			Case $rgstatus = $handlethemeshot Or $rgstatus = $handlethemedesc
				$rgname    = ThemeSelectCreate ($rgname)
				If $rgname = $rgprevname Then ContinueLoop
				ThemeGetLocal ($rgname)
				CommonThemePutOption ("name", $rgname, $themetempoptarray)
				ThemeResetColor ()
				ThemeRefreshGUI ($rgname)
				$rgprevname = $rgname
			Case $rgstatus = $handlethemetime
				$timerenabled = "no"
				If CommonCheckBox ($handlethemetime) Then $timerenabled = "yes"
				ThemeRefreshGUI ($rgname)
			Case $rgstatus = $handlethemedark
				ThemeCheckBox   ($handlethemedark,   "dark")
			Case $rgstatus = $handlethemescroll
				ThemeCheckBox   ($handlethemescroll, "scrollbar")
			Case $rgstatus = $handlethemelines
				ThemeCheckBox   ($handlethemelines,  "lines")
			Case $rgstatus = $handlethemevers
				ThemeCheckBox   ($handlethemevers,   "version")
			Case $rgstatus = $handlethememode
				ThemeCheckBox   ($handlethememode,   "bootmode")
			Case $rgstatus = $handlethemeface
				$rgface = StringLower (GUICtrlRead ($handlethemeface))
				CommonThemePutOption ("face", $rgface, $themetempoptarray)
				If $rgface <> $rgprevface Then ThemeRefreshGUI ()
				$rgprevface = $rgface
			Case $rgstatus = $handlethemestyle
				$rgstyle = StringLower (GUICtrlRead ($handlethemestyle))
				CommonThemePutOption ("style", $rgstyle, $themetempoptarray)
				If $rgstyle <> $rgprevstyle Then ThemeRefreshGUI ()
				$rgprevstyle = $rgstyle
			Case $rgstatus = $buttonthemecoltit
				$rgcolortit   = CommonThemeGetOption ("coltitle")
				ThemeGetColors ($rgname, "coltitle",  $rgcolortit)
			Case $rgstatus = $buttonthemecolsel
				$rgcolorsel   = CommonThemeGetOption ("colselect")
				ThemeGetColors ($rgname, "colselect", $rgcolorsel)
			Case $rgstatus = $buttonthemecoltxt
				$rgcolortext  = CommonThemeGetOption ("coltext")
				ThemeGetColors ($rgname, "coltext", $rgcolortext, "yes")
			Case $rgstatus = $buttonthemecolclk
				$rgcolorclock = CommonThemeGetOption ("colclock")
				ThemeGetColors ($rgname, "colclock", $rgcolorclock, "yes")
			Case $rgstatus = $buttonthemereset
				$themetempoptarray = ThemeLoadOptions ($themestandpath & "\" & $rgname & ".txt")
				$timerenabled = "yes"
				ThemeResetColor ()
				ThemeSetupGUI   ()
				GUICtrlSetState ($handlethemetime, $GUI_CHECKED)
				ThemeRefreshGUI ($rgname)
			Case $rgstatus = $buttonthemeok
				GuiCtrlSetData ($updowngt, $timeloader)
				Assign ("themeoptarrayhold_" & $rgname, $themetempoptarray, 2)
				ExitLoop
			Case Else
		EndSelect
	WEnd
	If $handlethemegui <> "" Then GUIDelete ($handlethemegui)
	GUISetState (@SW_RESTORE, $handlemaingui)
	If $rgstatus = $buttonthemeok Then
		Return "OK"
	Else
		Return "Cancelled"
	EndIf
EndFunc

Func ThemeCheckBox ($tcbhandle, $tcbkey)
	$tcbvalue = "no"
	If CommonCheckBox    ($tcbhandle) Then $tcbvalue = "yes"
	CommonThemePutOption ($tcbkey, $tcbvalue, $themetempoptarray)
	ThemeRefreshGUI ()
EndFunc

Func ThemeRefreshGUI ($rgname = "")
	GUICtrlSetState ($handlethemelab1,   $guihideit)
	GUICtrlSetState ($handlethemelabs,   $guihideit)
	GUICtrlSetState ($handlethemestyle,  $guihideit)
	GUICtrlSetState ($handlethemeface,   $guihideit)
	If $rgname = "" Then $rgname = CommonThemeGetOption ("name")
	ThemeBuildScreenShot ($rgname)
	If $rgname = $notheme Then
		$rgnamedesc = $nothemedesc
		GUICtrlSetState ($handlethemedark,   $guihideit)
		GUICtrlSetState ($handlethemescroll, $guihideit)
		GUICtrlSetState ($handlethemelines,  $guihideit)
		GUICtrlSetState ($handlethemevers,   $guihideit)
		GUICtrlSetState ($buttonthemereset,  $guihideit)
		GUICtrlSetState ($handlethememode,   $guihideit)
		GUICtrlSetState ($buttonthemecolgrp, $guihideit)
		GUICtrlSetState ($buttonthemecoltit, $guihideit)
		GUICtrlSetState ($buttonthemecolsel, $guihideit)
		GUICtrlSetState ($buttonthemecoltxt, $guihideit)
		GUICtrlSetState ($buttonthemecolclk, $guihideit)
	Else
		$rgnamedesc = BasicCapIt ($rgname)
		GUICtrlSetState ($handlethemedark,   $guishowit)
		GUICtrlSetState ($handlethemescroll, $guishowit)
		GUICtrlSetState ($handlethemelines,  $guishowit)
		GUICtrlSetState ($handlethemevers,   $guishowit)
		GUICtrlSetState ($handlethememode,   $guishowit)
		GUICtrlSetState ($buttonthemereset,  $guishowit)
		GUICtrlSetState ($buttonthemecolgrp, $guishowit)
		GUICtrlSetState ($buttonthemecoltit, $guishowit)
		GUICtrlSetState ($buttonthemecolsel, $guishowit)
		GUICtrlSetState ($buttonthemecoltxt, $guishowit)
		GUICtrlSetState ($buttonthemecolclk, $guishowit)
		GUICtrlSetState ($handlethemelabs,   $guishowit)
		GUICtrlSetState ($handlethemestyle,  $guishowit)
		GUICtrlSetState ($handlethemeface,   $guishowit)
		GUICtrlSetState ($handlethemelab1,   $guishowit)
	EndIf
	If $timerenabled = "yes" Then
		If CommonThemeGetOption ("style") <> "clock" Then
			GUICtrlSetState ($handlethemeface,   $guihideit)
			GUICtrlSetState ($handlethemelab1,   $guihideit)
			GUICtrlSetState ($buttonthemecolclk, $guihideit)
		EndIf
		GUICtrlSetState ($handlethemesecs,   $guishowit)
		GUICtrlSetState ($handlethemeseclab, $guishowit)
		GUICtrlSetState ($handlethemesecud,  $guishowit)
	Else
		GUICtrlSetState ($handlethemelabs,   $guihideit)
		GUICtrlSetState ($handlethemestyle,  $guihideit)
		GUICtrlSetState ($handlethemeface,   $guihideit)
		GUICtrlSetState ($handlethemelab1,   $guihideit)
		GUICtrlSetState ($handlethemesecs,   $guihideit)
		GUICtrlSetState ($handlethemeseclab, $guihideit)
		GUICtrlSetState ($handlethemesecud,  $guihideit)
	EndIf
	GUICtrlSetData  ($handlethemedesc, $rgnamedesc)
	GUICtrlSetImage ($handlethemepic,  $screenshotfile)
EndFunc

Func ThemeBuildScreenShot ($wsname = "")
	If $wsname = "" Then $wsname = CommonThemeGetOption ("name")
	If $wsname = $notheme Then
		ThemeGDISetup     ($themestatic & "\image.notheme.jpg", "Arial", 16)
		ThemeBuildNotheme ()
		ThemeGDICloseout  ($screenshotfile)
	Else
		$wsnamelow = StringLower ($wsname)
		ThemeGDISetup    ($themebackgrounds & "\" & $wsnamelow & ".jpg", "Arial", 16)
		ThemeBuildImage  ()
		ThemeGDICloseout ($screenshotfile)
	EndIf
EndFunc

Func ThemeBuildBackground ($tbbfile)
	ThemeGDISetup    ($tbbfile, "Arial", 16)
	ThemeGDICloseout ($themecustback)
EndFunc

Func ThemeBuildImage ()
	$tbivert  = 50
	If CommonThemeGetOption ("dark")      = "yes" Then _
		ThemeLayerImage ($themestatic & "\menubox.dark_c.png",              115, 40,       755, 600)
	If CommonThemeGetOption ("scrollbar") = "yes" Then _
	    ThemeLayerImage ($themestatic & "\image.scrollbar.png",             855, 35,        19, 610)
	For $tbisub = 0 To Ubound ($selectionarray) - 1
		If $tbisub > 8 Then Exitloop
		$tbibrush = $brushtitle
		$tbiicon = $selectionarray [$tbisub] [$sIcon]
		$tbitext = $selectionarray [$tbisub] [$sEntryTitle]
		If $selectionarray [$tbisub] [$sDefaultOS] <> "" Then
			$tbibrush = $brushselect
			If CommonThemeGetOption ("scrollbar") = "yes" Then _
				ThemeLayerImage ($themestatic & "\select_c.png",            125, $tbivert +  3, 725, 56)
		EndIf
		ThemeLayerImage ($themepath & "\icons\" & $tbiicon & ".png",        130, $tbivert +  8,  45, 45)
		ThemeLayerText  ($tbitext,                                          195, $tbivert + 17, $tbibrush)
		$tbivert += 60
	Next
	If CommonThemeGetOption ("version")  = "yes" Then
		ThemeLayerText  ("Grub2Win",                                  895, 340, $brushtext)
		ThemeLayerImage ($themecolorcustom & "\digita.png",                907, 370, 15, 20)
		ThemeLayerImage ($themecolorcustom & "\digitpoint.png",            922, 370,  5, 20)
		ThemeLayerImage ($themecolorcustom & "\digitb.png",                927, 370, 15, 20)
		ThemeLayerImage ($themecolorcustom & "\digitpoint.png",            942, 370,  5, 20)
		ThemeLayerImage ($themecolorcustom & "\digitc.png",                947, 370, 15, 20)
		ThemeLayerImage ($themecolorcustom & "\digitpoint.png",            962, 370,  5, 20)
		ThemeLayerImage ($themecolorcustom & "\digitd.png",                967, 370, 15, 20)
	EndIf
	If CommonThemeGetOption ("bootmode") = "yes" Then
		$tbioffset = 885
		If $firmwaremode = "EFI" Then $tbioffset = 905
		ThemeLayerImage ($themecolorcustom & "\image.type" & $firmwaremode & $procbits & ".png", $tbioffset, 425, 110, 30)
	EndIf
	If CommonThemeGetOption ("lines") = "yes" Then
		$tbitext1 = "Select an item with the arrow keys and press enter to boot."
		$tbitext2 = "Press:  'c' for a grub command or  'e'  to edit."
		ThemeLayerText  ($tbitext1,                165, 665, $brushtext)
		ThemeLayerText  ($tbitext2,                165, 690, $brushtext)
	EndIf
	If $timerenabled = "no" Then Return
	If CommonThemeGetOption ("style") = "clock" Then
		ThemeLayerText  ($timeloader & "s",          938, 685, $brushclock)
		$tbiface = CommonThemeGetOption ("face")
		If $tbiface <> $noface Then
			$tbifacefile = $themefaces  & "\" & $tbiface & ".png"
			If $tbiface = $ticksonly Then $tbifacefile = $themeempty
			ThemeLayerImage ($themecolorcustom & "\image.clock.png", 901, 544, 108, 108)
			ThemeLayerImage ($tbifacefile,                      921, 559,  70,  70)
		EndIf
	EndIf
	If CommonThemeGetOption ("style")  = "progress bar" Then
		ThemeLayerImage ($themestatic & "\image.progress.bar.png",        130, 695, 790, 40)
		$tbiprogmessage = "The hilighted entry will be executed automatically in " & $timeloader & "s"
		ThemeLayerText  ($tbiprogmessage,                                 220, 703, $brushtext)
	EndIf
EndFunc

Func ThemeBuildNotheme ()
	$tbntext0 = "GNU GRUB   version 2.02"
	ThemeLayerText  ($tbntext0,                365,  35, $brushtext)
	$tbnvert  = 110
	For $tbnsub = 0 To Ubound ($selectionarray) - 1
		$tbnbrush = $brushtitle
		If $tbnsub > 12 Then Exitloop
		$tbntext = $selectionarray [$tbnsub] [$sEntryTitle]
		If $selectionarray [$tbnsub] [$sDefaultOS] <> "" Then
			$tbnbrush = $brushselect
			ThemeLayerImage ($themestatic & "\select.notheme.png", 23, $tbnvert + 12, 975, 30)
		EndIf
		ThemeLayerText  ($tbntext,               40, $tbnvert + 17, $tbnbrush)
		$tbnvert += 30
	Next
	$tbntext1 = "Use the     and     keys to select which entry is highlighted."
	$tbntext2 = "Press enter to boot the selected OS,  'e'  to edit the commands"
	$tbntext3 = "before booting or  'c'  for a command-line."
	$tbntext4 = "The hilighted entry will be executed automatically in " & $timeloader & "s"
	ThemeLayerText  ($tbntext1,                              165, 625, $brushtext)
	ThemeLayerText  ($tbntext2,                              165, 650, $brushtext)
	ThemeLayerText  ($tbntext3,                              165, 675, $brushtext)
	ThemeLayerImage ($themestatic & "\image.arrow.up.png",   250, 628, 15, 15)
	ThemeLayerImage ($themestatic & "\image.arrow.down.png", 318, 632, 14, 14)
	If $timerenabled = "no" Then Return
	ThemeLayerText  ($tbntext4, 165, 700, $brushtext)
EndFunc

Func ThemeLayerImage ($listack, $lileft, $litop, $liwidth, $liheight)
	$lihandlestack    = _GDIPlus_ImageLoadFromFile ($listack)
	If $lihandlestack = 0 Then Return ; MsgBox ($mbontop, "GDI Get File Error", "Stack = " & $listack)
	$licontextstack   = _GDIPlus_ImageGetGraphicsContext ($lihandlestack)
	_GDIPlus_GraphicsDrawImageTrans ($gdicontextin, $lihandlestack, $liwidth, $liheight, $lileft, $litop)
	_GDIPlus_GraphicsDispose ($licontextstack)
	_GDIPlus_ImageDispose    ($lihandlestack)
EndFunc

Func ThemeLayerText ($lttext, $ltleft, $lttop, $ltbrush)
	$gdilayout  = _GDIPlus_RectFCreate           ($ltleft, $lttop, 0, 0)
	$gdimeasure = _GDIPlus_GraphicsMeasureString ($gdicontextin, $lttext, $gdifont, $gdilayout, $gdiformat)
	_GDIPlus_GraphicsDrawStringEx ($gdicontextin, $lttext, $gdifont, $gdimeasure [0], $gdiformat, $ltbrush)
EndFunc

Func ThemeGDISetup ($gsinfile, $gsfontname, $gsfontsize)
	_GDIPlus_Startup ()
	$gdihandlein    = _GDIPlus_ImageLoadFromFile       ($gsinfile)
	If $gdihandlein = 0 Then MsgBox ($mbwarnok, "GDI Get File Error", "Input File = " & $gsinfile)
	$gdihandlein    = _GDIPlus_ImageResize             ($gdihandlein, 1024, 768)
	$gdicontextin   = _GDIPlus_ImageGetGraphicsContext ($gdihandlein)
	$gdiformat      = _GDIPlus_StringFormatCreate      ()
	$gdifontfam     = _GDIPlus_FontFamilyCreate        ($gsfontname)
	$gdifont        = _GDIPlus_FontCreate              ($gdifontfam, $gsfontsize, 0)
	ThemeSetupColors ()
EndFunc

Func ThemeGDICloseout ($gcoutfile)
	FileDelete ($gcoutfile)
	_GDIPlus_ImageSaveToFile     ($gdihandlein, $gcoutfile)
	_GDIPlus_FontDispose         ($gdifont)
	_GDIPlus_FontFamilyDispose   ($gdifontfam)
	_GDIPlus_StringFormatDispose ($gdiformat)
	_GDIPlus_GraphicsDispose     ($gdicontextin)
	_GDIPlus_ImageDispose        ($gdihandlein)
	_GDIPlus_BrushDispose        ($brushtitle)
	_GDIPlus_BrushDispose        ($brushselect)
	_GDIPlus_BrushDispose        ($brushtext)
	_GDIPlus_Shutdown            ()
EndFunc

Func ThemeGetCurrent ($tgcfile = $themecustopt)
	$tgcarray = ThemeLoadOptions ($tgcfile)
	$tgcarray = ThemeHealOptions ($tgcarray)
	Return $tgcarray
EndFunc

Func ThemeGetLocal ($glname)
	If IsDeclared ("themeoptarrayhold_" & $glname) = $DECLARED_GLOBAL Then
		$themetempoptarray = Eval ("themeoptarrayhold_" & $glname)
		ThemeRefreshHandles ()
		Return
	EndIf
	$glstandfile  = $themestandpath & "\" & $glname & ".txt"
	$gllocalfile  = $themelocalpath & "\" & $glname & ".txt"
	If Not FileExists ($glstandfile) Then FileCopy ($themedeffile, $glstandfile, 1)
	                                      FileCopy ($glstandfile,  $themecustopt, 1)
	If FileExists ($gllocalfile)     Then FileCopy ($gllocalfile,  $themecustopt, 1)
	$themetempoptarray = ThemeLoadOptions ($themecustopt)
	$themetempoptarray = ThemeHealOptions ($themetempoptarray)
	CommonThemePutOption ("name", $glname, $themetempoptarray)
	ThemeRefreshHandles ()
EndFunc

Func ThemeHealOptions (ByRef $hoinarray)
	If Not IsArray ($themedefarray) Then $themedefarray = ThemeLoadOptions ($themedeffile)
	$hohealedarray = $themedefarray
	For $hosub = 0 To Ubound ($hohealedarray) - 1
		$hofield = $hohealedarray [$hosub] [2]
		$hovalue = CommonThemeGetOption ($hofield, "", $hoinarray)
		If $hofield <> "level" And $hovalue <> "" Then $hohealedarray [$hosub] [3] = $hovalue
	Next
	Return $hohealedarray
EndFunc

Func ThemeLoadOptions ($tlofile, $tlocheck = "yes")
	Dim $tloarray [0] [5]
	$tlohandleopts = FileOpen ($tlofile)
	While 1
		$tlorecord = FileReadLine ($tlohandleopts)
		If @error Then ExitLoop
		$tlotype     = StringStripWs (StringLeft ($tlorecord, 11),     3)
		If $tlotype  = "" Then ContinueLoop
		$tlohandname = StringStripWs (StringMid      ($tlorecord, 12, 23), 3)
		$tlokey      = StringStripWs (StringMid      ($tlorecord, 35, 10), 3)
		$tlovalue    = StringStripWs (StringTrimLeft ($tlorecord, 46)    , 3)
		_ArrayAdd ($tloarray, $tlotype & "|" & $tlohandname & "|" & $tlokey & "|" & $tlovalue & "|")
	WEnd
	FileClose ($tlohandleopts)
	$tloname = CommonThemeGetOption ("name", "", $tloarray)
	$tlobackground  = $themebackgrounds & "\" & $tloname & ".jpg"
	If $tlocheck <> "" And $tloname <> "basic" And Not FileExists ($tlobackground) Then
		ThemeStarterSetup ()
		MsgBox ($mbwarnok, "File " & $tlofile, "Theme background file " & $tlobackground & " is missing."  _
		     & @CR & @CR & 'The theme was changed to "Basic"' & @CR & @CR & "Grub2Win will restart when you click OK")
		Run ($baseexe)
		Exit
	EndIf
	;_ArrayDisplay ($tloarray)
	Return $tloarray
EndFunc

Func ThemeGetFaces ()
	$tgfstring = $noface
	$tgfhandle = FileFindFirstFile ($themefaces & "\*.png")
	While 1
		$tgfname = FileFindNextFile ($tgfhandle)
		If @error Then ExitLoop
		$tgfstring &= "|" & BasicCapIt (StringTrimRight ($tgfname, 4))
	WEnd
	Return $tgfstring & "|" & $ticksonly
EndFunc

Func ThemeGetColors ($gcname, $gcfield, $gccurrent, $gccopy = "")
	$gccolortext = _ChooseColor (2, Execute ("0x" & $gccurrent), 2, $handlethemegui)
	If $gccolortext = -1 Then Return
	$gccolortext = StringTrimLeft ($gccolortext, 2)
	CommonThemePutOption ($gcfield, $gccolortext, $themetempoptarray)

	If $gccopy <> "" Then ThemeCopyColor ($gcfield, $gccolortext)
	; MsgBox ($mbontop, "GetColors " & $gccolortext, $gcfield)
	ThemeRefreshGUI      ($gcname)
EndFunc

Func ThemeSetupColors ()
	$tpctitle  = CommonThemeGetOption ("coltitle")
	$tpcselect = CommonThemeGetOption ("colselect")
	$tpctext   = CommonThemeGetOption ("coltext")
	$tpcclock  = CommonThemeGetOption ("colclock")
	GUICtrlSetBkColor ($buttonthemecoltit,    Execute ("0x" &   $tpctitle))
	GUICtrlSetColor   ($buttonthemecoltit,    ThemeGetContrast ($tpctitle))
	GUICtrlSetBkColor ($buttonthemecolsel,    Execute ("0x" &   $tpcselect))
	GUICtrlSetColor   ($buttonthemecolsel,    ThemeGetContrast ($tpcselect))
	GUICtrlSetBkColor ($buttonthemecoltxt,    Execute ("0x" &   $tpctext))
	GUICtrlSetColor   ($buttonthemecoltxt,    ThemeGetContrast ($tpctext))
	GUICtrlSetBkColor ($buttonthemecolclk,    Execute ("0x" &   $tpcclock))
	GUICtrlSetColor   ($buttonthemecolclk,    ThemeGetContrast ($tpcclock))
	$brushtitle  = _GDIPlus_BrushCreateSolid (Execute ("0xFF" & $tpctitle))
	$brushselect = _GDIPlus_BrushCreateSolid (Execute ("0xFF" & $tpcselect))
	$brushtext   = _GDIPlus_BrushCreateSolid (Execute ("0xFF" & $tpctext))
	$brushclock  = _GDIPlus_BrushCreateSolid (Execute ("0xFF" & $tpcclock))
EndFunc

Func ThemeCopyColor ($cctype, $cccolor = "", $ccfromdir = $themecolorsource, $cctodir = $themecolorcustom)
	If $cctype = "colclock" Then ThemeChangeColor ("tick.png",             $cccolor, $ccfromdir, $cctodir)
	If $cctype = "colclock" Then ThemeChangeColor ("image.clock.png",      $cccolor, $ccfromdir, $cctodir)
	If $cctype = "coltext"  Then ThemeChangeColor ("digita.png",           $cccolor, $ccfromdir, $cctodir)
	If $cctype = "coltext"  Then ThemeChangeColor ("digitb.png",           $cccolor, $ccfromdir, $cctodir)
	If $cctype = "coltext"  Then ThemeChangeColor ("digitc.png",           $cccolor, $ccfromdir, $cctodir)
	If $cctype = "coltext"  Then ThemeChangeColor ("digitd.png",           $cccolor, $ccfromdir, $cctodir)
	If $cctype = "coltext"  Then ThemeChangeColor ("digitpoint.png",       $cccolor, $ccfromdir, $cctodir)
	If $cctype = "coltext"  Then ThemeChangeColor ("image.typeefi32.png",  $cccolor, $ccfromdir, $cctodir)
	If $cctype = "coltext"  Then ThemeChangeColor ("image.typeefi64.png",  $cccolor, $ccfromdir, $cctodir)
	If $cctype = "coltext"  Then ThemeChangeColor ("image.typebios32.png", $cccolor, $ccfromdir, $cctodir)
	If $cctype = "coltext"  Then ThemeChangeColor ("image.typebios64.png", $cccolor, $ccfromdir, $cctodir)
EndFunc

Func ThemeChangeColor ($ccfile, $ccoutcolor, $ccfromdir = $themecolorsource, $cctodir = $themecolorcustom)
	$ccbgr = StringMid ($ccoutcolor, 5, 2) & StringMid ($ccoutcolor, 3, 2) & StringLeft ($ccoutcolor, 2) & "FF"
	;MsgBox ($mbontop, "Colors", "BGR=" & $ccbgr & @CR &  "RGB=" & $ccoutcolor)
	_GDIPlus_Startup  ()
    $ccimage = _GDIPlus_ImageLoadFromFile ($ccfromdir & "\" & $ccfile)
	$ccimage = _ImageColorRegExpReplace   ($ccimage, "(000000FF)",   $ccbgr)
	_GDIPlus_ImageSaveToFile ($ccimage,    $cctodir   & "\" & $ccfile)
	_GDIPlus_ImageDispose ($ccimage)
	_GDIPlus_Shutdown     ()
EndFunc


Func ThemeGetContrast ($tgccolor)
	$tgcred        = Dec (StringLeft  ($tgccolor, 2))
	$tgcgreen      = Dec (StringMid   ($tgccolor, 3,2))
	$tgcblue       = Dec (StringRight ($tgccolor, 2))
	$tgcbrightness = Int (.299 * $tgcred + .587 * $tgcgreen + .114 * $tgcblue)
	$tgccontrast   = $myblack
	If $tgcbrightness < 128 Then $tgccontrast = $mywhite
	;MsgBox ($mbontop, "RGB " & $tgcbrightness & " " & $tgccontrast, $tgccolor & @CR & $tgcred & @CR & $tgcgreen & @CR & $tgcblue)
	Return $tgccontrast
EndFunc

Func ThemeResetColor ()
	ThemeCopyColor  ("coltext",  CommonThemeGetOption ("coltext"))
	ThemeCopyColor  ("colclock", CommonThemeGetOption ("colclock"))
EndFunc

Func ThemeRefreshHandles ()
	For $tshsub = 0 To Ubound ($themetempoptarray) - 1
		$tshvalue  = StringLower ($themetempoptarray [$tshsub] [1])
   	    $tshhandle = Eval ($tshvalue)
		If @error Then ContinueLoop
		;MsgBox ($mbontop, "Eval", $tshvalue & @CR & $tshhandle)
		$themetempoptarray [$tshsub] [4] = $tshhandle
		$thschecked = $GUI_UNCHECKED
		If $themetempoptarray [$tshsub] [3] = "yes" Then $thschecked = $GUI_CHECKED
        GUICtrlSetState ($tshhandle, $thschecked)
	    ;MsgBox ($mbontop, $tshvalue, $tshhandle)
	Next
	$trhstyle = CommonThemeGetOption ("style")
	GUICtrlSetData ($handlethemestyle, $trhstyle)
	GUICtrlSetData ($handlethemeface,  CommonThemeGetOption ("face"))
EndFunc

Func ThemeUpdateFiles ($tufoutfile = $themecustopt)
	;_ArrayDisplay ($themetempoptarray, Ubound ($themetempoptarray) - 1)
	ThemeWriteOptionsFile ($tufoutfile, $themetempoptarray, BasicTimeLine ())
	$tufname = CommonThemeGetOption ("name")
	$tuflocal =  $themelocalpath & "\" & $tufname & ".txt"
	FileCopy ($themecustopt, $tuflocal, 1)
	ThemeBuildBackground ($themebackgrounds & "\" & $tufname & ".jpg")
	If $tufname <> $notheme Then ThemeGenConfig ()
EndFunc

Func ThemeWriteOptionsFile ($wofoutfile, ByRef $wofarray, $wofstamp = "")
	$wofhandleopts = FileOpen ($wofoutfile, $FO_OVERWRITE)
	FileWriteLine ($wofhandleopts, _StringRepeat (" ", 34) & "Timestamp = " & $wofstamp & @CR & @CR)
	For $wofsub = 0 To Ubound ($wofarray) - 1
		$wofrecord  = CommonPadRight ($wofarray [$wofsub] [0], 11)
		$wofrecord &= CommonPadRight ($wofarray [$wofsub] [1], 23)
		$wofrecord &= CommonPadRight ($wofarray [$wofsub] [2],  9) & " = "
		$wofrecord &=                 $wofarray [$wofsub] [3]
		If $wofsub < Ubound ($wofarray) - 1 Then $wofrecord &= @CR
		FileWrite ($wofhandleopts, $wofrecord)
	Next
	FileClose ($wofhandleopts)
EndFunc

Func ThemeStarterSetup ()
	FileCopy ($thememasterpath & "\background.png", $themepath & "\custom.background.png", 1)
	FileCopy ($thememasterpath & "\options.txt",    $themepath & "\custom.options.txt",    1)
	If FileExists ($setupolddir & "\themes\custom.background.png") Then	FileCopy ($setupolddir & "\themes\custom.*", $themepath & "\", 1)
	$themetempoptarray = ThemeGetCurrent           ($themepath & "\custom.options.txt")
	ThemeGenConfig ()
EndFunc

Func ThemeGenConfig ()
	Dim $tgc64biosarray [1]
	Dim $tgc64efiarray  [1]
	Dim $tgc32biosarray [1]
	Dim $tgc32efiarray  [1]
	$tgchandle = FileOpen ($themetemplate)
	While 1
		$tgcrecord = FileReadLine ($tgchandle)
		If @error Then ExitLoop
		$tgcincloc = StringInStr ($tgcrecord, "##g2w-include")
		If $tgcincloc <> 0 Then
			$tgcparse = StringStripWs (StringTrimLeft ($tgcrecord, $tgcincloc + 12), 7)
			$tgcsplit = StringSplit ($tgcparse, " ")
			$tgcrecvalue = StringLeft ($tgcsplit [2], 4)
			If @error Then ContinueLoop
			$tgcoptvalue = StringLeft (CommonThemeGetOption ($tgcsplit [1], "lower"), 4)
			If $tgcrecvalue <> $tgcoptvalue Then ContinueLoop
			;_ArrayDisplay ($tgcsplit, $tgcparse & " " & $tgccompare)
		EndIf
		$tgcreploc = StringInStr ($tgcrecord, "##g2w-replace")
		If $tgcreploc <> 0 Then
			$tgcparse = StringStripWs (StringTrimLeft ($tgcrecord, $tgcreploc + 12), 7)
			$tgcsplit = StringSplit ($tgcparse, " ")
			If @error Then ContinueLoop
			$tgcrep = CommonThemeGetOption ($tgcsplit [1], "lower")
			$tgcrecord = StringReplace ($tgcrecord, $tgcsplit [2], $tgcrep)
			;_ArrayDisplay ($tgcsplit, $tgcparse)
		EndIf
		$tgcparmloc = StringInStr ($tgcrecord, "##g2w")
		If $tgcparmloc <> 0 Then $tgcrecord  = StringLeft  ($tgcrecord, $tgcparmloc - 1)
		If StringInStr ($tgcrecord, "*clockfacestring*") Then
			$tgcface = CommonThemeGetOption ("face")
			If $tgcface = $noface Then ContinueLoop
			$tgcfacestring = '"common/clockfaces/' & $tgcface & '.png"'
			If Not FileExists ($themefaces & "\" & $tgcface & ".png") Or $tgcface = $ticksonly _
				Then $tgcfacestring = '"common/static/image.empty.png"'
			$tgcfacestring &= '   tick_bitmap = "common/colorcustom/tick.png"'
			$tgcrecord      = '   center_bitmap   = ' & $tgcfacestring
		EndIf
		$tgcoutefi  = StringStripWS ($tgcrecord, 2)
		$tgcoutbios = $tgcoutefi
		If StringInStr ($tgcrecord, "*bootmodestring*") Then
			_ArrayAdd ($tgc64efiarray,  '    + image { left = 14%  top = 20%   file = "common/colorcustom/image.typeefi64.png"  }')
			_ArrayAdd ($tgc64biosarray, '    + image { left = 05%  top = 20%   file = "common/colorcustom/image.typebios64.png" }')
			_ArrayAdd ($tgc32efiarray,  '    + image { left = 14%  top = 20%   file = "common/colorcustom/image.typeefi32.png"  }')
			_ArrayAdd ($tgc32biosarray, '    + image { left = 05%  top = 20%   file = "common/colorcustom/image.typebios32.png" }')
			ContinueLoop
		EndIf
		_ArrayAdd ($tgc64efiarray,  $tgcoutefi)
		_ArrayAdd ($tgc64biosarray, $tgcoutbios)
		_ArrayAdd ($tgc32efiarray,  $tgcoutefi)
		_ArrayAdd ($tgc32biosarray, $tgcoutbios)
	Wend
	;_ArrayDisplay ($tgcefiarray)
	FileDelete       ($themeconfig & "*")
	CommonArrayWrite ($themeconfig & ".64.bios.txt", $tgc64biosarray)
	CommonArrayWrite ($themeconfig & ".64.efi.txt",  $tgc64efiarray)
	CommonArrayWrite ($themeconfig & ".32.bios.txt", $tgc32biosarray)
	CommonArrayWrite ($themeconfig & ".32.efi.txt",  $tgc32efiarray)
EndFunc

Func ThemeMainScreenShot ()
	ThemeBuildScreenShot      ()
	If $screenpicturehandle <> "" Then GUICtrlDelete ($screenpicturehandle)
	If $screenshothandle    <> "" Then GUICtrlDelete ($screenshothandle)
	If $screenpreviewhandle <> "" Then GUICtrlDelete ($screenpreviewhandle)
    $sstheme = BasicCapIt (CommonThemeGetOption ("name"))
	$sstext = 'Preview of theme  "' & $sstheme & '"  -  Click to customize'
	If $sstheme = $notheme Then $sstext = $nothemedesc
	$screenshothandle    = CommonScaleCreate ("Label",   "",              44,  1, 55, 52)
	$screenpicturehandle = CommonScaleCreate ("Picture", $screenshotfile, 44,  1, 55, 52)
	$screenpreviewhandle = CommonScaleCreate ("Label",   $sstext,         44, 53, 55,  3, $SS_CENTER)
	GUICtrlSetState ($screenshothandle, $guishowit)
EndFunc

Func ThemeSelectCreate ($tsgcurrname)
	$schandlegui = GUICreate  ("Click on the background you want to use", _
		$scalehsize, $scalevsize + 15, -1, -1, -1, -1, $handlethemegui)
	;GUISetBKColor ($mygreen, $schandlegui)
	$scarray = ThemeSelectRefreshMatrix ($schandlegui, $tsgcurrname)
	GUISetState (@SW_SHOW, $schandlegui)
	$scname  = ""
	;_ArrayDisplay ($scarray)
	While 1
		$ipstatus = GUIGetMsg ()
		Select
			Case $ipstatus = "" Or $ipstatus = 0
			Case $ipstatus = $GUI_EVENT_CLOSE
				$scname = $tsgcurrname
				ExitLoop
		   	Case Else
				;MsgBox ($mbontop, "Status", $ipstatus)
				For $scsub = 0 To Ubound ($scarray) - 1
				If $ipstatus = $scarray [$scsub] [0] Or $ipstatus = $scarray [$scsub] [1] Then
					$scname  = $scarray [$scsub] [2]
					ExitLoop (2)
				EndIf
				Next
		EndSelect
	Wend
	If $schandlegui <> "" Then GUIDelete ($schandlegui)
	If $scname = $nothemedesc Then $scname = $notheme
	;MsgBox ($mbontop, "Name", $scname)
	Return $scname
EndFunc

Func ThemeSelectRefreshMatrix ($rmhandlegui, $rmcurrname)
	$rmhandlematrix  = GUICreate ("", $scalehsize, $scalevsize + 10, 0, 0, $WS_CHILD, "", $rmhandlegui)
	$rmhoriz = 53
	$rmvert  = 3
	$rmcurrcount = 1
	Dim $rmarray [1] [3]
	ThemeSelectFormat (0, $themebackgrounds, $notheme, 3, $rmvert, $rmarray, $rmcurrname, $rmcurrcount)
	$rmcount     = 1
	$rmcurrcount = 2
	$rmhandle = FileFindFirstFile ($themebackgrounds & "\*.jpg")
	While 1
		$rmname = FileFindNextFile ($rmhandle)
		If @error Then ExitLoop
		If $rmname = "Notheme.jpg" Or $rmname = "Basic.jpg" Then ContinueLoop
		$rmhoriz  = 53
		ReDim $rmarray [$rmcount + 1] [3]
		If Mod ($rmcount, 2) = 0 Then
			$rmvert  = ($rmcount * 17) + 3
			$rmhoriz = 3
		EndIf
		$rmname = StringTrimRight ($rmname, 4)
		ThemeSelectFormat ($rmcount, $themebackgrounds, $rmname, $rmhoriz, $rmvert, $rmarray, $rmcurrname, $rmcurrcount)
		$rmcount += 1
	WEnd
	FileClose ($rmhandle)
	ReDim $rmarray [$rmcount + 1] [3]
    ThemeSelectFormat ($rmcount, $themebackgrounds, "basic", 53, $rmvert, $rmarray, $rmcurrname, $rmcurrcount)
	CommonScrollGenerate ($rmhandlematrix, $scalehsize - 17, ($rmcount + 2) * $scalepctvert * 16)
	;MsgBox ($mbontop, "Count", $rmcurrcount & @CR & ($rmcurrcount - 2) * 4)
	If $rmcurrcount > 4 Then _GUIScrollBars_SetScrollInfoPos ($rmhandlematrix, $SB_VERT, Int (($rmcurrcount - 1) / 2) * 9)
	GUISetState(@SW_SHOW, $rmhandlematrix)
	;_ArrayDisplay ($rmarray, $rmname)
	Return $rmarray
EndFunc

Func ThemeSelectFormat ($sfcount, $sfdir, $sfname, $sfhoriz, $sfvert, ByRef $sfarray, $sfcurrname, ByRef $sfcurrcount)
	$tsftexthandle = ""
	$sfnamedisplay = BasicCapIt ($sfname)
	If $sfname = $notheme Then $sfnamedisplay = $nothemedesc
	$sfarray [$sfcount] [0] = CommonBorderCreate ($sfdir & "\" & $sfname & ".jpg", _
		$sfhoriz, $sfvert, 41, 28, $tsftexthandle, $sfnamedisplay)
	$sfarray [$sfcount] [1] = $tsftexthandle
	$sfarray [$sfcount] [2] = $sfname
	If $sfname = $sfcurrname Or ($sfname = $nothemedesc And $sfcurrname = $notheme) Then
		GUICtrlSetBkColor ($sfarray [$sfcount] [0], $myred)
		$sfcurrcount = $sfcount
	EndIf
EndFunc

Func ThemeCreateHold ()
	$themeoptarray     = ThemeGetCurrent ()
	$themetempoptarray = $themeoptarray
	DirRemove ($themetemp, 1)
	DirCreate ($themetemp)
	DirCreate ($themetempfiles)
	FileCopy  ($themepath & "\custom.*", $themetempfiles, 1)
	DirCopy   ($themecolorcustom,        $themetempcust, 1)
	DirCopy   ($themelocalpath,          $themetemplocal, 1)
EndFunc

Func ThemeRestoreHold ()
	FileCopy  ($themetempfiles & "\custom.*", $themepath, 1)
	DirCopy   ($themetempcust,                $themecolorcustom, 1)
	DirCopy   ($themetemplocal,               $themelocalpath , 1)
	DirRemove ($themetemp, 1)
	$themetempoptarray = $themeoptarray
EndFunc

Func ThemeEscape ()
	Exit
EndFunc