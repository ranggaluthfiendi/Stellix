import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
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
        spacing: Theme.dp(12)

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(32)
            spacing: Theme.dp(8)

            Text {
                text: "Power Menu"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(14 * s)
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
            Layout.fillHeight: true
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
                    { icon: "lock", label: "Lock", action: function() { power.lock(); root.closeRequested() } },
                    { icon: "☾", label: "Suspend", action: function() { power.suspend(); root.closeRequested() } },
                    { icon: "👤", label: "Switch User", action: function() { power.logout(); root.closeRequested() } },
                    { icon: "ac_unit", label: "Hibernate", action: function() { power.hibernate(); root.closeRequested() } }
                ]

                delegate: Rectangle {
                    width: powerList.width
                    height: Theme.dp(48)
                    color: powerList.currentIndex === index
                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                        : powerMouse.containsMouse
                            ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.06)
                            : "transparent"
                    border.width: powerList.currentIndex === index ? 1 : 0
                    border.color: Theme.accent
                    radius: 0

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.dp(12)
                        spacing: Theme.dp(12)

                        Text {
                            Layout.preferredWidth: Theme.dp(24)
                            Layout.preferredHeight: Theme.dp(24)
                            Layout.alignment: Qt.AlignVCenter
                            text: modelData.icon
                            color: powerList.currentIndex === index ? Theme.accent : Theme.textPrimary
                            font.pixelSize: Math.round(18 * s)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            text: modelData.label
                            color: Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(12 * s)
                            font.weight: powerList.currentIndex === index ? Font.Bold : Font.Normal
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
                    contentItem: Rectangle {
                        implicitWidth: Theme.dp(4)
                        radius: 0
                        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                    }
                }
            }
        }

        // --- Footer Navigation Section ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(28)
            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
            radius: 0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.dp(12)
                anchors.rightMargin: Theme.dp(12)
                spacing: Theme.dp(10)

                FooterHint { label: "Select"; keys: "↑/↓" }
                FooterSeparator {}
                FooterHint { label: "Execute"; keys: "Enter" }
                FooterSeparator {}
                FooterHint { label: "Close"; keys: "Esc" }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: "Stellix Power"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                    font.weight: Font.Bold
                    opacity: 0.6
                }
            }
        }
    }

    component FooterHint: RowLayout {
        property string label: ""
        property string keys: ""
        spacing: Theme.dp(4)
        
        Text {
            text: keys
            color: Theme.accent
            font.family: Typography.fontFamily
            font.pixelSize: Math.round(8 * s)
            font.weight: Font.Bold
        }
        Text {
            text: label
            color: Theme.textMuted
            font.family: Typography.fontFamily
            font.pixelSize: Math.round(8 * s)
        }
    }

    component FooterSeparator: Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: Theme.dp(12)
        color: Theme.border
        opacity: 0.5
    }
}
