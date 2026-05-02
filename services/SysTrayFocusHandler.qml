import QtQuick
import Quickshell.Hyprland
import qs.services

Item {
    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (!event) return

            let name = event.name

            if (name === "activewindow" || name === "activewindowv2") {
                if (SysTrayState.openedMenu !== null) {
                    SysTrayState.closeAll()
                }
                return
            }

            if (name === "mouse" || name === "pointer_button") {
                if (SysTrayState.openedMenu !== null) {
                    if (!SysTrayState.blockClose) {
                        SysTrayState.closeAll()
                    }
                }
            }
        }
    }
}
