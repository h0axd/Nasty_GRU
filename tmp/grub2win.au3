#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\winsource\xxgrub2win.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs  Author: Dave Pickens
   Available from the Grub2Win project at sourceforge.net

   Supports Windows 10, 8, 7, Vista and XP

   Creates and updates the C:\grub2\grub.cfg file

   Creates and maintains the \EFI\grub2win directory in your EFI partition

   Grub2Win is written in AutoIt.
   If you wish to modify and recompile grub2win.exe,
   you will need to download and install the AutoIt software package.
   AutoIt is available free at http://www.autoitscript.com/


         Grub2Win   Copyright (C) 2010 - 2018, Dave Pickens

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see http://www.gnu.org/licenses/gpl.txt.
#ce

#RequireAdmin
#include-once
#include     <g2common.au3>
#include     <g2guimain.au3>
#include     <g2getprev.au3>
#include     <g2genconfig.au3>
#include     <g2syntax.au3>
#include     <g2theme.au3>
#include     <g2xp.au3>
$setupcaller = "grub2win"
#include     <setfunction.au3>

CommonPrepareAll ()
LangSetup        ()

If CommonParms ($setupstring) Then SetupByGUI  ()

; ************  Start of main routine ************

If Not FileExists ($baseexe) Then
	$missingmsg  = 'The base program "' & $baseexe & '"  is missing!!' & @CR & @CR
	$missingmsg &= '                        Grub2Win is cancelled'
	CommonShowError ($missingmsg, "Missing Base Program")
	Exit
EndIf

If $bootos = $xpstring Then
	InitializeXP ()
Else
	InitializeBCD ()
EndIf

ProcessCommon ()

If $bootos = $xpstring Then
	UpdateXP ()
Else
	UpdateBCD ()
EndIf

CommonEndIt("Success")

; ************  End of main routine ************

Func InitializeXP()
	XPSetup ()
	CommonInitialize ()
	XPGetPrevious    ()
EndFunc

Func InitializeBCD()
	CommonInitialize ()
	UpdateCheckDays  ()
	$ibrc = BCDGetBootArray ("yes")
	If $ibrc <> 0 Then CommonEndit ("Failed")
	If $firmwaremode = "EFI" Then
		$typestring     = StringReplace ($typestring, "invaders|", "")
		$latestefilevel = CommonGetEFILevel ($bootmanpath)
	Else
		BCDGetPreviousBIOS ()
	EndIf

	UtilCreateSysInfo      ()
EndFunc

Func ProcessCommon ()
	$pcrc = GetPrevConfig ()
	If $pcrc <> 0 Then CommonEndit ("Failed")
	CheckEnvironment  ()
	If CommonParms ($rebootstring) Then GenRebootBuild ($runparm2)
	$pcrc = MainRunGUI()
	If $pcrc =  3 Then CommonEndit ("Diagnostics")
	If $pcrc <> 0 Then CommonEndit ("Cancelled")
	$pcrc = GenConfig()
	If $pcrc <> 0 Then CommonEndit ("Failed")
	ThemeUpdateFiles ()
	BCDCleanup ("yes")
EndFunc

Func UpdateXP ()
	$uxrc = XPUpdate ($timewinboot, "no")
	If $uxrc <> 0 Then CommonEndIt ("Failed")
EndFunc

Func UpdateBCD ()
	If $firmwaremode = "EFI" Then
		BCDSetWinOrderEFI   ()
		BCDSetWinDescEFI    ()
		$ubgrubmessage = BCDGetUpdateMessage ($bcdfirmorder, "yes")
		If $ubgrubmessage <> ""  Then CommonWriteLog ("          " & $ubgrubmessage)
		If $bcdtestboot =  "yes" Then CommonWriteLog ("            ** A Grub2Win EFI Test Boot Is Set **")
		BCDSetWinTimeout ($timewinboot)
	Else
		BCDSetupBIOS ($timewinboot, "no")
	EndIf
EndFunc

Func CheckEnvironment ()
	If $bootos = "" Then
		CommonWriteLog  ("          *** This OS is not supported ***   " & $osbits & " bit   " & @OSVersion)
		CommonShowError ("Grub2Win does not support this OS" & @CR & @CR & $osbits & " bit   " & @OSVersion)
		Exit
	EndIf
	$celevel = CommonGetEFILevel ($storagepath, "yes")
	CommonSetupSysLines ($celevel)
	CommonWriteLog ("    " & $syslineos)
	If $syslinesecure <> "" Then CommonWriteLog ("    " & $syslinesecure)
	CommonWriteLog ("    " & $syslinepath, 1, "")
	CommonWriteLog ("    " & $langline1, 1, "")
	If $langline2 <> "" Then CommonWriteLog ("    " & $langline2, 1, "")
	If $langline3 <> "" Then CommonWriteLog ("    " & $langline3, 1, "")
	If $langline4 <> "" Then CommonWriteLog ("    " & $langline4, 1, "")
	If StringInStr (FileGetAttrib ($basepath), "C") Then UnCompressIt ()
EndFunc

Func UnCompressIt ()
	CommonWriteLog ("    The Grub2Win base directory  " & $basepath & "  is compressed.")
	$ucmsg  = "The Grub2Win base directory  " & $basepath & "  is compressed."    & @CR & @CR
	$ucmsg &= "               Compression is not recommended !"                   & @CR & @CR & @CR & @CR
	$ucmsg &= 'Click "Yes" to uncompress  ' & $basepath & '  or "No" to continue'
	$ucrc   = MsgBox ($mbwarnyesno, "*** Compression Warning ***", $ucmsg)
	If $ucrc = $IDYES Then CommonRunBat ("xxuncompress.txt", "Grub2Win.UnCompress.bat")
EndFunc