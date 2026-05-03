import QtQuick
import Quickshell.Hyprland
import qs.services

Item {
    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (!event) return

            const name = event.name

            if (name === "pointer_button") {
                if (!SysTrayState.blockClose) {
                    SysTrayState.closeAll()
                }
                return
            }

            if (name === "activewindow" || name === "activewindowv2") {
                SysTrayState.closeAll()
                return
            }
        }
    }
}
