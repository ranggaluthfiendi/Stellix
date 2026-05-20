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

    function next() {
        powerList.currentIndex = (powerList.currentIndex + 1) % powerList.count
    }

    function prev() {
        powerList.currentIndex = (powerList.currentIndex - 1 + powerList.count) % powerList.count
    }

    function executeCurrent() {
        if (powerList.currentIndex >= 0) {
            powerList.model[powerList.currentIndex].action()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.dp(12)
        spacing: Theme.dp(10)

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(32)
            spacing: Theme.dp(8)

            Text {
                text: "Power Menu"
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

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(240)
            color: "transparent"
            clip: true

            ListView {
                id: powerList
                anchors.fill: parent
                spacing: Theme.dp(4)
                currentIndex: 0
                model: [
                    { icon: "⏻", label: "Shutdown", action: function() { power.shutdown(); root.closeRequested() } },
                    { icon: "↻", label: "Reboot", action: function() { power.reboot(); root.closeRequested() } },
                    { icon: "↩", label: "Logout", action: function() { power.logout(); root.closeRequested() } },
                    { icon: "🔒", label: "Lock", action: function() { power.lock(); root.closeRequested() } },
                    { icon: "☾", label: "Suspend", action: function() { power.suspend(); root.closeRequested() } },
                    { icon: "👤", label: "Switch User", action: function() { power.logout(); root.closeRequested() } },
                    { icon: "❄", label: "Hibernate", action: function() { power.hibernate(); root.closeRequested() } }
                ]

                delegate: Rectangle {
                    width: powerList.width
                    height: Theme.dp(48)
                    color: powerList.currentIndex === index
                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                        : powerMouse.containsMouse
                            ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.06)
                            : "transparent"
                    radius: 0

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.dp(12)
                        spacing: Theme.dp(10)

                        Text {
                            Layout.preferredWidth: Theme.dp(24)
                            Layout.preferredHeight: Theme.dp(24)
                            Layout.alignment: Qt.AlignVCenter
                            text: modelData.icon
                            color: Theme.textPrimary
                            font.pixelSize: Math.round(18 * s)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
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
                        id: powerMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            powerList.currentIndex = index
                            modelData.action()
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: Theme.dp(4)
                }
            }
        }
    }
}
