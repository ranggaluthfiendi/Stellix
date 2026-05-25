import QtQuick
import Quickshell.Hyprland
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

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
