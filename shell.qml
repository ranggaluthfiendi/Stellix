import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.screens
import qs.services
import qs.components.widgets.systemtray
import qs.components.widgets.rightbar
import qs.components.widgets.workspaceswitcher
import qs.modules.bar

ShellRoot {
    Bar {}
    Screen {}
    SysTrayFocusHandler {}
    SysTrayGlobalOverlay {}

    GlobalShortcut {
        id: wsSwitcherShortcut
        name: "workspace-switcher"
        description: "Open workspace switcher"

        onPressedChanged: {
            if (pressed)
                RightBarState.workspaceSwitcherOpen = !RightBarState.workspaceSwitcherOpen
        }
    }

    WorkspaceSwitcher {
        id: wsSwitcher
        visible: RightBarState.workspaceSwitcherOpen
        
        // onCloseRequested: {
        //     RightBarState.workspaceSwitcherOpen = false
        // }
    }
}
