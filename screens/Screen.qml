import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components.widgets.misc
import qs.components.elements
import qs.components.widgets.media.nowplaying
import qs.components.widgets.system
import qs.services

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

            Item {
                anchors.fill: parent
                z: 9999

                visible: SysTrayState.openedMenu !== null

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.AllButtons

                    onPressed: (mouse) => {
                        if (SysTrayState.openedMenu) {
                            const p = SysTrayState.openedMenu.mapFromItem(
                                parent,
                                mouse.x,
                                mouse.y
                            )

                            if (
                                p.x < 0 ||
                                p.y < 0 ||
                                p.x > SysTrayState.openedMenu.width ||
                                p.y > SysTrayState.openedMenu.height
                            ) {
                                SysTrayState.closeAll()
                            }
                        }
                    }
                }
            }
        }
    }
}
