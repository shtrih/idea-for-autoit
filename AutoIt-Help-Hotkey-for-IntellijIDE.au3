#pragma compile(Console, true)
#pragma compile(x64, true)
#pragma compile(FileDescription, Map hotkey (e.g. F1) in PhpStorm (or other Intellij IDE) to open AutoIt documentation for the word under the keyboard cursor.)
#pragma compile(ProductName, AutoIt-Help-Hotkey-for-IntellijIDE)
#pragma compile(ProductVersion, 1.0.0)
#pragma compile(FileVersion, 1.0.0)
#pragma compile(LegalCopyright, © shtrih)

#include <MsgBoxConstants.au3>

ConsoleWrite(@ScriptName & " started!" & @CRLF)

Const $eg_sConfigFilePath = @ScriptName & '.ini'
Const $eg_sIDEName = 'PhpStorm'
Const $eg_sAutoItPath = 'C:\Program Files (x86)\AutoIt3\'
Const $eg_sHotKey = '^q'

$g_sAutoItPath = ""
$g_sHotKey = ""
$g_sIDEName = ""

configRead($eg_sConfigFilePath)

If Not $g_sHotKey Then
    $sError = "Hotkey is not set in config. Quitting. " & @CRLF
    ConsoleWriteError($sError)
    MsgBox($MB_SYSTEMMODAL, @ScriptName, $sError)
    Exit 1
EndIf

HotKeySet($g_sHotKey, "ShowHelp")

While True
    Sleep(100)
WEnd

Func ShowHelp()
    ConsoleWrite("Help triggered" & @CRLF)

    ConsoleWrite("Checking IDE window is active..." & @CRLF)
    WinWaitActive("[REGEXPTITLE:(.*- " & $g_sIDEName & ")$; CLASS:SunAwtFrame]")

    ConsoleWrite("Unselecting word" & @CRLF)
    Send("^+w")
    Send("^+w")

    ConsoleWrite("Selecting word" & @CRLF)
    Send("^w")

    ConsoleWrite("Backuping clipboard" & @CRLF)
    Local $sOldData = ClipGet()
    If @error Then
        $sError = "Cannot access the clipboard to back it up"
        If @error = 1 Then
            $sError = "Clipboard is empty"
        EndIf

        ConsoleWriteError($sError & @CRLF)
        ;MsgBox($MB_SYSTEMMODAL, @ScriptName, $sError & @CRLF)
    EndIf

    ConsoleWrite("Copying selected word" & @CRLF)
    Send("^c")

    Sleep(100)

    ConsoleWrite("Unselecting word" & @CRLF)
    Send("^+w")

    Local $sData = ClipGet()
    If @error Then
        $sError = "Cannot access the clipboard"
        If @error = 1 Then
            $sError = "Clipboard is empty"
        EndIf

        ConsoleWriteError($sError & @CRLF)
        ; MsgBox($MB_SYSTEMMODAL, @ScriptName, $sError & @CRLF)
    EndIf

    ConsoleWrite("Restoring the clipboard" & @CRLF)
    If $sOldData = '' Or Not ClipPut($sOldData) Then
        ConsoleWriteError("Failed to restore the clipboard!" & @CRLF)
    EndIf

    If $sData = '' Then
        ConsoleWriteError("Do nothing because the clipboard is empty" & @CRLF)
        Return
    EndIf

    ConsoleWrite("Open Help for: " & $sData & @CRLF)

    ; https://www.autoitscript.com/forum/topic/27108-new-scite4autoit3-with-scite-v169/?do=findComment&comment=195424
    $sCommand = StringFormat('"%sAutoIt3Help.exe" "%s"', $g_sAutoItPath, $sData)
    Run($sCommand)
    If @error Then
        $sError = "Cannot run command: " & $sCommand & @CRLF
        ConsoleWriteError($sError)
        MsgBox($MB_SYSTEMMODAL, @ScriptName, $sError)
    EndIf
EndFunc

Func configCreate($sFilePath)
    ConsoleWrite('Trying to write config file ' & $sFilePath & @CRLF)

    $iResult = IniWrite($sFilePath, 'General', 'autoit_install_path', $eg_sAutoItPath)
    IniWrite($sFilePath, 'General', 'hotkey_comment', '; e.g. {f1} or ^q. See also: https://www.autoitscript.com/autoit3/docs/functions/HotKeySet.htm')
    IniWrite($sFilePath, 'General', 'hotkey', $eg_sHotKey)
    IniWrite($sFilePath, 'General', 'ide_name', $eg_sIDEName)

    If Not $iResult Then
        ConsoleWriteError("Failed to save config." & @CRLF)
    EndIf
EndFunc

Func configCheck($sFilePath)
    If Not FileExists($sFilePath) Then
        configCreate($sFilePath)
    EndIf
EndFunc

Func configRead($sFilePath)
    configCheck($sFilePath)

    $g_sAutoItPath = IniRead($sFilePath, 'General', 'autoit_install_path', $eg_sAutoItPath)
    $g_sHotKey = IniRead($sFilePath, 'General', 'hotkey', $eg_sHotKey)
    $g_sIDEName = IniRead($sFilePath, 'General', 'ide_name', $eg_sIDEName)
EndFunc