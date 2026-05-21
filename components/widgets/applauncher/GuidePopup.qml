import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components.widgets.rightbar

PanelWindow {
    id: root

    property real s: Scales.uiScale
    
    visible: RightBarState.guideOpen
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: RightBarState.guideOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: -1

    MouseArea {
        anchors.fill: parent
        onClicked: RightBarState.guideOpen = false

        Keys.forwardTo: [keyboardHandler]
    }

    Item {
        id: keyboardHandler
        anchors.fill: parent
        focus: RightBarState.guideOpen

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape || event.key === Qt.Key_Slash) {
                RightBarState.guideOpen = false
                event.accepted = true
            }
        }
    }

    Rectangle {
        id: mainContainer
        anchors.centerIn: parent
        width: Theme.dp(700)
        height: contentCol.implicitHeight + Theme.dp(32)
        color: Theme.bgSecondary
        border.width: 1
        border.color: Theme.border
        radius: 0

        opacity: RightBarState.guideOpen ? 1 : 0
        scale: RightBarState.guideOpen ? 1 : 0.95

        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        Behavior on scale {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        Column {
            id: contentCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.dp(16)
            spacing: Theme.dp(12)

            RowLayout {
                width: parent.width
                spacing: Theme.dp(8)

                Text {
                    text: "Quick Guide"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(14 * s)
                    font.weight: Font.Bold
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "ESC to close"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: Theme.dp(4)
                columnSpacing: Theme.dp(16)

                GuideItem { label: "App Launcher"; keys: "Super + R"; keys2: "Alt + Space" }
                GuideItem { label: "Next Workspace"; keys: "Alt + Tab" }
                GuideItem { label: "Workspace Switcher"; keys: "Super + Tab" }
                GuideItem { label: "Prev Workspace"; keys: "Alt + Shift + Tab" }
                GuideItem { label: "Quick Settings"; keys: "Super + Alt" }
                GuideItem { label: "Terminal"; keys: "Super + Enter" }
                GuideItem { label: "Shortcut Guide"; keys: "Super + /" }
                GuideItem { label: "File Manager"; keys: "Super + E" }
                GuideItem { label: "Kill Window"; keys: "Super + Q" }
                GuideItem { label: "Browser"; keys: "Super + W" }
                GuideItem { label: "Fullscreen"; keys: "Super + F" }
                GuideItem { label: "Toggle Floating"; keys: "Super + Shift + F" }
            }

            Text {
                width: parent.width
                text: "Volume"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(11 * s)
                font.weight: Font.Bold
            }

            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: Theme.dp(4)
                columnSpacing: Theme.dp(16)

                GuideItem { label: "Mute"; keys: "Super + ;" }
                GuideItem { label: "Up"; keys: "Super + ." }
                GuideItem { label: "Down"; keys: "Super + ," }
            }

            Text {
                width: parent.width
                text: "Brightness"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(11 * s)
                font.weight: Font.Bold
            }

            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: Theme.dp(4)
                columnSpacing: Theme.dp(16)

                GuideItem { label: "Up"; keys: "Super + ]" }
                GuideItem { label: "Down"; keys: "Super + [" }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            Text {
                width: parent.width
                text: "Inside App Launcher"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(11 * s)
                font.weight: Font.Bold
            }

            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: Theme.dp(4)
                columnSpacing: Theme.dp(16)

                GuideItem { label: "Commands"; keys: "/"; isSub: true }
                GuideItem { label: "Context Menu"; keys: "Ctrl / Right-Click"; isSub: true }
                GuideItem { label: "Action Trigger"; keys: ">"; isSub: true }
                GuideItem { label: "Go Back"; keys: "Shift + A"; isSub: true }
                GuideItem { label: "Help Menu"; keys: "?"; isSub: true }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            RowLayout {
                width: parent.width
                spacing: Theme.dp(12)

                Text {
                    text: "ESC"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
                    font.weight: Font.Medium
                }

                Text {
                    text: "Close this guide"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Click anywhere outside"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
                }
            }
        }
    }

    component GuideItem: RowLayout {
        property string label: ""
        property string keys: ""
        property string keys2: ""
        property bool isSub: false
        Layout.fillWidth: true
        spacing: Theme.dp(8)

        Text {
            text: label
            color: isSub ? Theme.textMuted : Theme.textPrimary
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((isSub ? 10 : 11) * s)
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        KeyBox { text: keys }
        KeyBox { text: keys2; visible: keys2.length > 0 }
    }

    component KeyBox: Rectangle {
        property string text: ""
        Layout.preferredHeight: Theme.dp(22)
        Layout.preferredWidth: keyText.implicitWidth + Theme.dp(14)
        color: hovered ? Theme.surface : Theme.bgPrimary
        border.width: 1
        border.color: hovered ? Theme.accent : Theme.border
        radius: Theme.dp(4)

        property bool hovered: false
        property bool pressed: false

        scale: pressed ? 0.92 : (hovered ? 1.05 : 1.0)

        Behavior on scale {
            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
        }

        Behavior on color {
            ColorAnimation { duration: 100 }
        }

        Behavior on border.color {
            ColorAnimation { duration: 100 }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.hovered = true
            onExited: { parent.hovered = false; parent.pressed = false }
            onPressed: parent.pressed = true
            onReleased: parent.pressed = false
        }

        Text {
            id: keyText
            anchors.centerIn: parent
            text: parent.text
            color: Theme.accent
            font.family: Typography.fontFamily
            font.pixelSize: Math.round(9 * s)
            font.weight: Font.Medium
        }
    }
}
