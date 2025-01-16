#Requires AutoHotkey v2.0
!`::
{
    exclude_classes := Map("Progman", 0, "Shell_TrayWnd", 0)
    active_id := WinGetID("A")
    ids := WinGetList("ahk_exe " . WinGetProcessName("A"))
    filtered_ids := Array()
    for id in ids {
        this_class := WinGetClass(id)
        this_title := WinGetTitle(id)
        if (exclude_classes.Has(this_class)) {
            continue
        }
        if (this_title = '') {
            continue
        }
        filtered_ids.Push(id)
    }
    if (filtered_ids.Length = 1) {
        Exit
    }
    idx := GetIndex(filtered_ids, active_id)
    if (idx = -1) {
        Exit
    }
    next_idx := Mod(idx, filtered_ids.Length) + 1

    WinActivate filtered_ids.Get(next_idx)
}

GetIndex(arr, val) {
    for idx, v in arr {
        if (v = val) {
            return idx
        }
    }
    return -1
}