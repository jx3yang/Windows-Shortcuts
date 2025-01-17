#Requires AutoHotkey v2.0

states := Map()
expected_orderings := Map()
exclude_classes := Map("Progman", 0, "Shell_TrayWnd", 0)

; Alt+` switches to the next window of the same application
!`::
{
    active_id := WinGetID("A")
    process_name := WinGetProcessName("A")
    ids := WinGetList("ahk_exe " . process_name)
    filtered_ids := GetFilteredIDs(process_name)
    if (filtered_ids.Length = 1) {
        Exit
    }
    if (filtered_ids[1] != active_id) {
        Exit
    }

    previous_state := states.Get(process_name, [])
    expected_ordering := expected_orderings.Get(process_name, [])
    if OrderingMatches(filtered_ids, expected_ordering) {
        new_state := previous_state
        new_ordering := expected_ordering
    } else {
        ; if it doesn't match, then something has changed and we reset the state
        new_state := filtered_ids.Clone()
        new_ordering := filtered_ids.Clone()
    }
    new_id := new_state[2]

    new_state.RemoveAt(1)
    new_state.Push(active_id)
    states.Set(process_name, new_state)
    
    RemoveValue(new_ordering, new_id)
    new_ordering.InsertAt(1, new_id)
    expected_orderings.Set(process_name, new_ordering)

    WinActivate new_id
}

; Alt+Shift+` switches to the previous window of the same application
!+`::
{
    active_id := WinGetID("A")
    process_name := WinGetProcessName("A")
    ids := WinGetList("ahk_exe " . process_name)
    filtered_ids := GetFilteredIDs(process_name)
    if (filtered_ids.Length = 1) {
        Exit
    }
    if (filtered_ids[1] != active_id) {
        Exit
    }

    previous_state := states.Get(process_name, [])
    expected_ordering := expected_orderings.Get(process_name, [])
    if OrderingMatches(filtered_ids, expected_ordering) {
        new_state := previous_state
        new_ordering := expected_ordering
    } else {
        ; if it doesn't match, then something has changed and we reset the state
        new_state := filtered_ids.Clone()
        new_ordering := filtered_ids.Clone()
    }
    new_id := new_state[-1]

    new_state.RemoveAt(-1)
    new_state.InsertAt(1, new_id)
    states.Set(process_name, new_state)

    RemoveValue(new_ordering, new_id)
    new_ordering.InsertAt(1, new_id)
    expected_orderings.Set(process_name, new_ordering)

    WinActivate new_state[1]
}

GetFilteredIDs(process_name) {
    ids := WinGetList("ahk_exe " . process_name)
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
    return filtered_ids
}

OrderingMatches(actual_ordering, expected_ordering) {
    if (actual_ordering.Length != expected_ordering.Length) {
        return false
    }
    for idx, id in actual_ordering {
        if (id != expected_ordering.Get(idx)) {
            return false
        }
    }
    return true
}

RemoveValue(arr, value) {
    for idx, item in arr {
        if (item = value) {
            arr.RemoveAt(idx)
            return
        }
    }
}
