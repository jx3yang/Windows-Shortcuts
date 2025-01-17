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

; suppose that previously, the state was     [A, B, C, D, E, F, G]
; then after Alt+`, the state will should be [B, C, D, E, F, G, A]
; and the ordering of the windows will be    [B, A, C, D, E, F, G], assuming that nothing else has changed

; few more examples:
; state:    [C, D, E, F, G, A, B]
; ordering: [C, B, A, D, E, F, G]

; state:    [D, E, F, G, A, B, C]
; ordering: [D, C, B, A, E, F, G]
StateMatchesOrdering(last_state, current_ordering) {
    if (last_state.Length != current_ordering.Length) {
        return false
    }
    if (last_state.Get(1) != current_ordering.Get(1)) {
        return false
    }

    idx_state := -1
    idx_ordering := 2
    while idx_ordering <= current_ordering.Length {
        if (last_state.Get(idx_state) != current_ordering.Get(idx_ordering)) {
            break
        }
        idx_state--
        idx_ordering++
    }

    idx_state := 2
    while idx_ordering <= current_ordering.Length {
        if (last_state.Get(idx_state) != current_ordering.Get(idx_ordering)) {
            return false
        }
        idx_state++
        idx_ordering++
    }
    return true
}