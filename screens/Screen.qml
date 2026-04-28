import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components.widgets.misc

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
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
                    overlay.WlrLayershell.layer = WlrLayer.Background
                    overlay.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                }
            }

            LabelBoxWidget {
                text: "Hello world"
                posLeft: 10
                posTop: 10
                backgroundColor: "#800000"
            }
            
            LabelBoxWidget {
                text: "Goodbye world"
                posLeft: 10
                posBottom: 10
            }
        }
    }
}
