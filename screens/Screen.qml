import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components.elements
import qs.components.widgets.media.nowplaying
import qs.components.widgets.system
import qs.components.widgets.barpopup
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

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

            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.exclusiveZone: -1
            WlrLayershell.keyboardFocus: BarLayoutState.desktopSearchFocus ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            NowPlayingWidget {
                visible: BarLayoutState.showScreenNowPlaying
            }
            EqualizerWidget {
                visible: BarLayoutState.showScreenEqualizer
            }
            ClockWidget {
                visible: BarLayoutState.showScreenClock
            }
            SystemStatsWidget {
                visible: BarLayoutState.showScreenSystemStats
            }
            WeatherWidget {
                visible: BarLayoutState.showScreenWeather
            }
            QuickActionsWidget {
                visible: BarLayoutState.showScreenQuickActions
            }

            // --- Snap Guides ---
            Rectangle {
                id: vSnapLine
                width: 1; height: parent.height
                x: BarLayoutState.snapLineXPos
                color: Theme.accent
                visible: BarLayoutState.snapLineXVisible
                z: 999
            }

            Rectangle {
                id: hSnapLine
                width: parent.width; height: 1
                y: BarLayoutState.snapLineYPos
                color: Theme.accent
                visible: BarLayoutState.snapLineYVisible
                z: 999
            }

            BatteryBarPopup {
                brightnessService: BarLayoutState.getItem("brightnessService")
                mprisService: BarLayoutState.getItem("mprisService")
                pipewireService: BarLayoutState.getItem("pwService")
                notificationService: BarLayoutState.getItem("notifService")
            }

            Item {
                anchors.fill: parent
                z: 9999

                visible: SysTrayState.openedMenu !== null || BarPopupState.calendarOpen

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

                        if (BarPopupState.calendarOpen) {
                            BarPopupState.calendarOpen = false
                        }
                    }
                }
            }
        }
    }
}
