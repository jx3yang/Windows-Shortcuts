#Requires AutoHotkey v2.0
^+Backspace::  ; Ctrl + Shift + Backspace
{
    Send "+{Home}"  ; Send Shift + Home (select to the beginning of the line)
    Send "{Backspace}"  ; Send Backspace to delete the selected text
}