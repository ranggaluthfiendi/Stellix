import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

PanelWindow {
    id: overlay

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: SysTrayState.openedMenu !== null || SysTrayState.openedOverflow !== null
    color: "transparent"

    Component.onCompleted: {
        if (overlay.WlrLayershell) {
            overlay.WlrLayershell.layer = WlrLayer.Overlay
            overlay.WlrLayershell.exclusiveZone = -1
            overlay.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons

        onPressed: {
            SysTrayState.forceCloseAll()
        }
    }
}
