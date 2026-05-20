import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.services
import qs.components.elements

Rectangle {
    id: root

    color: "transparent"

    property real s: Scales.uiScale

    signal closeRequested

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.dp(12)
        spacing: Theme.dp(10)

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(32)
            spacing: Theme.dp(8)

            Text {
                text: "Screenshot"
                color: Theme.textPrimary
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(13 * s)
                font.weight: Font.Bold
            }

            Item { Layout.fillWidth: true }

            StarShape {
                Layout.preferredWidth: Theme.dp(16)
                Layout.preferredHeight: Theme.dp(16)
                color: Theme.accent
                animate: true
            }
        }

        Repeater {
            model: [
                { icon: "edit-select-all", label: "Select Region", action: function() { screenshot.screenshotRegion(); root.closeRequested() } },
                { icon: "window-new", label: "Active Window", action: function() { screenshot.screenshotWindow(); root.closeRequested() } },
                { icon: "video-display", label: "Full Screen", action: function() { screenshot.screenshotOutput(); root.closeRequested() } }
            ]

            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(48)
                color: shotMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
                radius: 0

                Behavior on color {
                    ColorAnimation { duration: 100 }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.dp(12)
                    spacing: Theme.dp(10)

                    Image {
                        Layout.preferredWidth: Theme.dp(24)
                        Layout.preferredHeight: Theme.dp(24)
                        Layout.alignment: Qt.AlignVCenter
                        source: Quickshell.iconPath(modelData.icon, true)
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: modelData.label
                        color: Theme.textPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(12 * s)
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                    }
                }

                MouseArea {
                    id: shotMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: modelData.action()
                }
            }
        }
    }
}
