import qs.core.settings
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.config
import qs.components.elements
import qs.components.widgets.barpopup

Rectangle {
    id: root

    Layout.fillWidth: true
    Layout.preferredHeight: Theme.dp(44)
    color: Theme.bgPrimary
    border.width: 1
    border.color: Theme.border
    radius: 0

    property real s: Scales.uiScale

    signal powerClicked

    readonly property var battery: UPower.displayDevice
    readonly property bool ready: battery && battery.ready
    readonly property real percentage: ready ? battery.percentage : 0
    readonly property int percentageInt: Math.round(percentage * 100)

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.dp(6)
        spacing: Theme.dp(6)

        Text {
            text: "Battery"
            color: Theme.textPrimary
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
            font.weight: Typography.weightMedium || Font.Normal
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(6)
            color: Theme.bgSecondary
            border.width: 1
            border.color: Theme.border
            radius: 0

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Math.max(0, Math.min(parent.width, parent.width * root.percentage))
                color: Theme.success
                radius: 0
            }
        }

        Text {
            text: root.ready ? (root.percentageInt + "%") : "--"
            color: Theme.textMuted
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
            font.weight: Typography.weightMedium || Font.Normal
        }

        // Weather shortcut button
        Rectangle {
            Layout.preferredWidth: Theme.dp(24)
            Layout.preferredHeight: Theme.dp(24)
            color: weatherMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Theme.bgSecondary
            border.width: 1
            border.color: weatherMouse.containsMouse ? Theme.accent : Theme.border
            radius: 0

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            IconCloud {
                anchors.centerIn: parent
                iconColor: weatherMouse.containsMouse ? Theme.accent : Theme.textPrimary
                iconSize: Theme.dp(12)
            }

            MouseArea {
                id: weatherMouse
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    BarPopupState.closeAll()
                    BarPopupState.weatherDetailOpen = true
                }
            }
        }

        // Notification shortcut button
        Rectangle {
            Layout.preferredWidth: Theme.dp(24)
            Layout.preferredHeight: Theme.dp(24)
            color: notifMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Theme.bgSecondary
            border.width: 1
            border.color: notifMouse.containsMouse ? Theme.accent : Theme.border
            radius: 0

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            IconBell {
                anchors.centerIn: parent
                iconColor: notifMouse.containsMouse ? Theme.accent : Theme.textPrimary
                iconSize: Theme.dp(12)
            }

            MouseArea {
                id: notifMouse
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    BarPopupState.closeAll()
                    BarPopupState.notifPanelRequested = true
                }
            }
        }

        // Power button
        Rectangle {
            Layout.preferredWidth: Theme.dp(24)
            Layout.preferredHeight: Theme.dp(24)
            color: powerMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Theme.bgSecondary
            border.width: 1
            border.color: powerMouse.containsMouse ? Theme.accent : Theme.border
            radius: 0

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            Text {
                anchors.centerIn: parent
                text: "⏻"
                color: powerMouse.containsMouse ? Theme.accent : Theme.textPrimary
                font.family: Typography.fontFamily
                font.pixelSize: Math.round((Typography.sizeSM || 13) * root.s)
            }

            MouseArea {
                id: powerMouse
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.powerClicked()
            }
        }
    }
}
