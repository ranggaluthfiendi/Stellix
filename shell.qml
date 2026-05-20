import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.screens
import qs.services
import qs.components.widgets.systemtray
import qs.components.widgets.rightbar
import qs.components.widgets.workspaceswitcher
import qs.components.widgets.applauncher
import qs.modules.bar

ShellRoot {
    Bar {}
    Screen {}
    SysTrayFocusHandler {}
    SysTrayGlobalOverlay {}

    AppLauncherService {
        id: launcher
    }

    AppLauncher {
        id: appLauncher
    }

    GlobalShortcut {
        id: wsSwitcherShortcut
        name: "workspace-switcher"
        description: "Open workspace switcher"

        onPressedChanged: {
            if (pressed) {
                if (RightBarState.launcherOpen) {
                    RightBarState.launcherOpen = false
                    launcher.close()
                }
                RightBarState.workspaceSwitcherOpen = !RightBarState.workspaceSwitcherOpen
            }
        }
    }

    GlobalShortcut {
        id: appLauncherShortcut
        name: "app-launcher"
        description: "Open application launcher"

        onPressedChanged: {
            if (pressed) {
                if (RightBarState.workspaceSwitcherOpen)
                    RightBarState.workspaceSwitcherOpen = false
                if (RightBarState.launcherOpen) {
                    RightBarState.launcherOpen = false
                    launcher.close()
                } else {
                    RightBarState.closeAll()
                    RightBarState.launcherOpen = true
                    launcher.open()
                }
            }
        }
    }

    GlobalShortcut {
        id: altTabNext
        name: "alt-tab-next"
        description: "Switch to next workspace"

        onPressedChanged: {
            if (pressed) {
                if (RightBarState.launcherOpen) {
                    RightBarState.launcherOpen = false
                    launcher.close()
                }
                var currentWs = Hyprland.focusedWorkspace.id
                var nextWs = currentWs + 1
                Hyprland.dispatch("workspace " + nextWs)
                RightBarState.workspaceSwitcherOpen = true
                wsFlashTimer.restart()
            }
        }
    }

    GlobalShortcut {
        id: altTabPrev
        name: "alt-tab-prev"
        description: "Switch to previous workspace"

        onPressedChanged: {
            if (pressed) {
                if (RightBarState.launcherOpen) {
                    RightBarState.launcherOpen = false
                    launcher.close()
                }
                var currentWs = Hyprland.focusedWorkspace.id
                var prevWs = Math.max(1, currentWs - 1)
                Hyprland.dispatch("workspace " + prevWs)
                RightBarState.workspaceSwitcherOpen = true
                wsFlashTimer.restart()
            }
        }
    }

    Timer {
        id: wsFlashTimer
        interval: 600
        repeat: false
        onTriggered: {
            RightBarState.workspaceSwitcherOpen = false
        }
    }

    WorkspaceSwitcher {
        id: wsSwitcher
        visible: RightBarState.workspaceSwitcherOpen
        
        onCloseRequested: {
            RightBarState.workspaceSwitcherOpen = false
        }
    }
}
