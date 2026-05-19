import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config
import Quickshell.Wayland

PopupWindow {
    id: root
    property var popupPanel: null
    property var closeCallback: null
    visible: false
    readonly property real s: Scales.uiScale

    readonly property real itemH: Theme.dp(38)
    readonly property real maxContentH: Theme.dp(200)
    readonly property real contentH: Math.min(Theme.dp(32) + Theme.dp(1) + 4 * itemH + Theme.dp(16), maxContentH)

    implicitWidth: Theme.dp(252)
    implicitHeight: contentH
    grabFocus: false

    property bool slideIn: false
    property real slideY: -Theme.dp(25)

    onVisibleChanged: {
        if (visible) {
            slideY = -Theme.dp(25)
            slideIn = true
        }
    }

    anchor.window: popupPanel
    anchor.rect.x: -(implicitWidth + Theme.dp(372) + Theme.dp(8))
    anchor.rect.y: Theme.dp(0)

    StdioCollector { id: cmdOut }

    Process {
        id: cmdRunner
        stdout: cmdOut
        onExited: function(exitCode, exitStatus) {
            if (root.closeCallback) root.closeCallback()
        }
    }

    function runCommand(cmd) {
        cmdRunner.exec(cmd)
    }

    Rectangle {
        anchors.fill: parent
        y: root.slideY
        color: Theme.bgSecondary
        border.width: 1
        border.color: Theme.border
        radius: 0

        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        Flickable {
            anchors.fill: parent
            contentWidth: parent.width
            contentHeight: powerLayout.implicitHeight
            interactive: contentHeight > height
            clip: true

            ScrollBar.vertical: ScrollBar {
                policy: powerLayout.implicitHeight > parent.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                width: Theme.dp(4)
            }

            ColumnLayout {
                id: powerLayout
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Theme.dp(8)
                spacing: Theme.dp(4)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(4)

                    Text {
                        text: "Power"
                        color: Theme.textPrimary
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 12) * s)
                        font.weight: Typography.weightBold || Font.Bold
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "Close"
                        color: closeMouse.containsMouse ? Theme.danger : Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: { if (root.closeCallback) root.closeCallback() }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.dp(1)
                    color: Theme.border
                }

                Repeater {
                    model: [
                       { label: "Logout",icon: "↩",cmd: ["hyprctl", "dispatch", "exit"],colorType: "warning"},
                        { label: "Sleep", icon: "☾", cmd: ["systemctl", "suspend"], colorType: "info" },
                        { label: "Reboot", icon: "↻", cmd: ["systemctl", "reboot"], colorType: "danger" },
                        { label: "Shutdown", icon: "⏻", cmd: ["systemctl", "poweroff"], colorType: "danger" }
                    ]

                    delegate: PowerButton {
                        required property var modelData
                        Layout.fillWidth: true
                        s: root.s
                        colorType: modelData.colorType
                        buttonLabel: modelData.label
                        buttonIcon: modelData.icon
                        onExecute: root.runCommand(modelData.cmd)
                    }
                }
            }
        }
    }
}
