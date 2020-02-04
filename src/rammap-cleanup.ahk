#NoTrayIcon

SetTitleMatchMode RegEx

GetRamMapExe() {
    If (A_Args.Length() > 0) {
        ramMapFilePath := A_Args[1]
    }
    Else {
        ramMapFilePath := A_ScriptDir . "/RAMMap.exe"
    }

    If (!FileExist(ramMapFilePath)) {
        MsgBox, RAMMap.exe could not be found.
        ExitApp, -1
    }

    return ramMapFilePath
}

RunRamMap() {
    ramMapExe := GetRamMapExe()
    Run, %ramMapExe%
}

GetRamMapTitle() {
    return "RamMap.*www\.sysinternals\.com"
}

ActivateRamMapWindow(winTitle) {
    WinActivate, % winTitle
    Sleep 25
}

EmptyWorkingSets() {
    ActivateRamMapWindow(GetRamMapTitle())
    SendInput, {Alt down}
    Sleep, 25
    SendInput, e
    Sleep, 25
    SendInput, {Alt up}
    Sleep, 25
    SendInput, w
}

EmptySystemWorkingSet() {
    ActivateRamMapWindow(GetRamMapTitle())
    SendInput, {Alt down}
    Sleep, 25
    SendInput, e
    Sleep, 25
    SendInput, {Alt up}
    Sleep, 25
    SendInput, s
}

EmptyModifiedPageList() {
    ActivateRamMapWindow(GetRamMapTitle())
    SendInput, {Alt down}
    Sleep, 25
    SendInput, e
    Sleep, 25
    SendInput, {Alt up}
    Sleep, 25
    SendInput, m
}

EmptyStandbyList() {
    ActivateRamMapWindow(GetRamMapTitle())
    SendInput, {Alt down}
    Sleep, 25
    SendInput, e
    Sleep, 25
    SendInput, {Alt up}
    Sleep, 25
    SendInput, t
}

EmptyPriority0StandbyList() {
    ActivateRamMapWindow(GetRamMapTitle())
    SendInput, {Alt down}
    Sleep, 25
    SendInput, e
    Sleep, 25
    SendInput, {Alt up}
    Sleep, 25
    SendInput, l
}

Refresh() {
    ActivateRamMapWindow(GetRamMapTitle())
    SendInput, {F5}
}

CloseRamMap() {
    ActivateRamMapWindow(GetRamMapTitle())
    SendInput, {Alt down}
    Sleep, 25
    SendInput, f
    Sleep, 25
    SendInput, {Alt up}
    Sleep, 25
    SendInput, x
}

GetCurrentTabIndex(winTitle) {
    ActivateRamMapWindow(winTitle)
    ControlGet, currentTab, Tab,, SysTabControl321, % winTitle
    return (currentTab - 1)
}

SetCurrentTabIndex(winTitle, index) {
    ActivateRamMapWindow(winTitle)
    SendMessage, 0x1330, index,, SysTabControl321, % winTitle
    Sleep, 0
    SendMessage, 0x130C, index,, SysTabControl321, % winTitle
    Sleep, 250
}

WaitUntilFinished() {
    ramMapTitle := GetRamMapTitle()

    SetCurrentTabIndex(ramMapTitle, 0)

    Loop
    {
        currentTabIndex := GetCurrentTabIndex(ramMapTitle)

        SetCurrentTabIndex(ramMapTitle, (currentTabIndex + 1))
        newTabIndex := GetCurrentTabIndex(ramMapTitle)

        If (newTabIndex = (currentTabIndex + 1)) {
            SetCurrentTabIndex(ramMapTitle, 0)
            Break
        }

        Sleep, 250
    }
}

RunRamMap()
WinWaitActive, GetRamMapTitle(),, 10
If (!WinExist(GetRamMapTitle())) {
    MsgBox, RAMMap can not be started.
    ExitApp, -1
}

WaitUntilFinished()

EmptyWorkingSets()
WaitUntilFinished()

EmptySystemWorkingSet()
WaitUntilFinished()

EmptyModifiedPageList()
WaitUntilFinished()

EmptyStandbyList()
WaitUntilFinished()

EmptyPriority0StandbyList()
WaitUntilFinished()

CloseRamMap()
WinWaitClose, GetRamMapTitle(),, 5

SetTitleMatchMode 1