#Requires AutoHotkey v2.0

states := Map()

!`::
{
    exclude_classes := Map("Progman", 0, "Shell_TrayWnd", 0)
    active_id := WinGetID("A")
    process_name := WinGetProcessName("A")
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
    if (filtered_ids.Length = 1) {
        Exit
    }
    ; this should always be idx = 1
    idx := GetIndex(filtered_ids, active_id)
    if (idx != 1) {
        Exit
    }

    previous_state := states.Get(process_name, [])
    if StateMatchesOrdering(previous_state, filtered_ids) {
        previous_state.RemoveAt(1)
        previous_state.Push(active_id)
        states.Set(process_name, previous_state)
    } else {
        ; if it doesn't match, then something has changed and we reset the state
        new_state := filtered_ids.Clone()
        new_state.RemoveAt(1)
        new_state.Push(active_id)
        states.Set(process_name, new_state)
    }

    WinActivate states.Get(process_name)[1]
}

GetIndex(arr, val) {
    for idx, v in arr {
        if (v = val) {
            return idx
        }
    }
    return -1
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