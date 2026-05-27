import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import qs.components.widgets.barpopup

PanelWindow {
    id: overlay

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: BarPopupState.calendarOpen
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
            BarPopupState.calendarOpen = false
            BarPopupState.weatherDetailOpen = false
            BarPopupState.mediaPopupOpen = false
            BarPopupState.notifPopupOpen = false
        }
    }
}
