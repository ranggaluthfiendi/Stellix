import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.components.widgets.rightbar

PanelWindow {
    id: overlay

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: RightBarState.calendarOpen
    color: "transparent"

    Component.onCompleted: {
        if (overlay.WlrLayershell) {
            overlay.WlrLayershell.layer = WlrLayer.Top
            overlay.WlrLayershell.exclusiveZone = -1
            overlay.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons

        onPressed: {
            RightBarState.calendarOpen = false
        }
    }
}
