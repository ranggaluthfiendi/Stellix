import qs.components.utils
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import qs.components.elements

Item {
    id: root

    property real baseS: 0.6
    property real s: Scales.uiScale * baseS * BarLayoutState.desktopQuickActionsScale

    width: Screen.width
    height: Screen.height

    readonly property real screenW: Screen.width
    readonly property real screenH: Screen.height

    Item {
        id: container
        width: 340 * s
        height: 64 * s

        x: BarLayoutState.desktopQuickActionsX
        y: BarLayoutState.desktopQuickActionsY
        rotation: BarLayoutState.desktopQuickActionsRotation

        opacity: BarLayoutState.desktopWidgetsOpacity * BarLayoutState.desktopQuickActionsOpacity * (BarLayoutState.desktopQuickActionsVisible ? 1.0 : 0.0)
        scale: BarLayoutState.desktopQuickActionsVisible ? 1.0 : 0.9

        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

        Timer {
            id: autohideTimer
            interval: 3000
            onTriggered: if (!BarLayoutState.desktopQuickActionsPinned && !mouseArea.containsMouse) BarLayoutState.desktopQuickActionsVisible = false
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                BarLayoutState.desktopQuickActionsVisible = true
                autohideTimer.stop()
            }
            onExited: {
                if (!BarLayoutState.desktopQuickActionsPinned) autohideTimer.restart()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(Theme.bgSecondary.r, Theme.bgSecondary.g, Theme.bgSecondary.b, 0.4)
            border.width: 1
            border.color: Theme.border
            radius: BarLayoutState.desktopQuickActionsRadius * s

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8 * s
                spacing: 4 * s

                Repeater {
                    model: [
                        { iconComp: "StarShape", action: "screenshot", label: "Shot" },
                        { iconComp: "IconEye", action: "lock", label: "Lock" },
                        { iconComp: "IconPause", action: "sleep", label: "Sleep" },
                        { iconComp: "IconLoop", action: "restart", label: "Reboot" },
                        { iconComp: "IconClose", action: "power", label: "Off" }
                    ]

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: actMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
                        radius: Math.max(0, BarLayoutState.desktopQuickActionsRadius - 4) * s

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4 * s

                            Loader {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 20 * s
                                Layout.preferredHeight: 20 * s
                                sourceComponent: {
                                    if (modelData.iconComp === "StarShape") return starComp
                                    if (modelData.iconComp === "IconEye") return eyeComp
                                    if (modelData.iconComp === "IconPause") return pauseComp
                                    if (modelData.iconComp === "IconLoop") return loopComp
                                    if (modelData.iconComp === "IconClose") return closeComp
                                    return null
                                }
                            }

                            Text {
                                text: modelData.label.toUpperCase()
                                color: Theme.textMuted
                                font.pixelSize: 7 * s
                                font.weight: Font.Bold
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        MouseArea {
                            id: actMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.action === "screenshot") {
                                    Quickshell.execDetached({command: ["hyprshot", "-m", "window"]})
                                } else if (modelData.action === "lock") {
                                    Quickshell.execDetached({command: ["hyprlock"]})
                                } else if (modelData.action === "sleep") {
                                    Quickshell.execDetached({command: ["systemctl", "suspend"]})
                                } else if (modelData.action === "restart") {
                                    Quickshell.execDetached({command: ["systemctl", "reboot"]})
                                } else if (modelData.action === "power") {
                                    Quickshell.execDetached({command: ["systemctl", "poweroff"]})
                                }
                            }
                        }
                    }
                }
            }
        }

        Component { id: starComp; StarShape { color: Theme.textPrimary; anchors.fill: parent; animate: false } }
        Component { id: eyeComp; IconEye { iconColor: Theme.textPrimary; anchors.fill: parent } }
        Component { id: pauseComp; IconPause { iconColor: Theme.textPrimary; anchors.fill: parent } }
        Component { id: loopComp; IconLoop { iconColor: Theme.textPrimary; anchors.fill: parent } }
        Component { id: closeComp; IconClose { iconColor: Theme.textPrimary; anchors.fill: parent } }

        Draggable {
            id: drag
            anchors.fill: parent
            target: container
            boundWidth: root.screenW
            boundHeight: root.screenH
            defaultX: (screenW - (340 * s)) / 2
            defaultY: screenH - (64 * s) - 40 * Scales.uiScale
            enabled: BarLayoutState.desktopQuickActionsPinned
            currentX: BarLayoutState.desktopQuickActionsX
            currentY: BarLayoutState.desktopQuickActionsY
            onDragPositionChanged: (x, y) => {
                BarLayoutState.desktopQuickActionsX = x
                BarLayoutState.desktopQuickActionsY = y
            }
            onRotateAction: (r) => {
                BarLayoutState.desktopQuickActionsRotation = r
            }
        }
    }

    Connections {
        target: BarLayoutState
        function onDesktopQuickActionsPinnedChanged() {
            if (BarLayoutState.desktopQuickActionsPinned) BarLayoutState.desktopQuickActionsVisible = true
        }
    }

    Component.onCompleted: {
        BarLayoutState.registerItem("desktopQuickActionsDrag", drag)
    }

    Component.onDestruction: {
        BarLayoutState.unregisterItem("desktopQuickActionsDrag")
    }
}
