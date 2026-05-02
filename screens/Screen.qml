import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components.widgets.misc
import qs.components.elements
import qs.components.widgets.media.nowplaying
import qs.components.widgets.system

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            id: overlay

            screen: modelData
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Component.onCompleted: {
                if (overlay.WlrLayershell != null) {
                    overlay.WlrLayershell.exclusiveZone = -1
                    overlay.WlrLayershell.layer = WlrLayer.Background
                    overlay.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                }
            }

            NowPlayingWidget {}
            ClockWidget{}
        }
    }
}
