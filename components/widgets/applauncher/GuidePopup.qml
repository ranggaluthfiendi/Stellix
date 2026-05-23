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
        width: Theme.dp(800)
        height: Math.min(parent.height - Theme.dp(64), contentCol.implicitHeight + Theme.dp(32))
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

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(16)
            spacing: Theme.dp(12)

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(8)

                Text {
                    text: "Stellix Shortcut Guide"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(16 * s)
                    font.weight: Font.Bold
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "ESC or / to close | Scroll for more"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(10 * s)
                }

                Rectangle {
                    width: 1
                    height: Theme.dp(12)
                    color: Theme.border
                    visible: guideScroll.contentHeight > guideScroll.height && guideScroll.contentY < (guideScroll.contentHeight - guideScroll.height - 20)
                }

                Text {
                    text: "Scroll for more ↓"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
                    visible: guideScroll.contentHeight > guideScroll.height && guideScroll.contentY < (guideScroll.contentHeight - guideScroll.height - 20)
                    
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { from: 0.4; to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 1.0; to: 0.4; duration: 1000; easing.type: Easing.InOutQuad }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.border
            }

            ScrollView {
                id: guideScroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: availableWidth

                ScrollBar.vertical: ScrollBar {
                    id: vBar
                    policy: ScrollBar.AsNeeded
                    width: Theme.dp(4)
                    active: true
                    
                    contentItem: Rectangle {
                        implicitWidth: Theme.dp(4)
                        radius: Theme.dp(2)
                        color: vBar.pressed ? Theme.accent : (vBar.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2))
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }

                ColumnLayout {
                    id: contentCol
                    width: parent.width
                    spacing: Theme.dp(20)

                    // --- System ---
                    CategorySection {
                        title: "System & Quickshell"
                        GridLayout {
                            columns: 2
                            rowSpacing: Theme.dp(6)
                            columnSpacing: Theme.dp(24)
                            Layout.fillWidth: true

                            GuideItem { label: "App Launcher"; keys: "Super + R"; keys2: "Alt + Space" }
                            GuideItem { label: "Clipboard History"; keys: "Super + V" }
                            GuideItem { label: "System Settings"; keys: "Super + I" }
                            GuideItem { label: "Shortcut Guide"; keys: "Super + /" }
                            GuideItem { label: "Quick Settings"; keys: "Win + Alt (L/R)" }
                            GuideItem { label: "Workspace Switcher"; keys: "Super + Tab" }
                        }
                    }

                    // --- Windows ---
                    CategorySection {
                        title: "Window Management"
                        GridLayout {
                            columns: 2
                            rowSpacing: Theme.dp(6)
                            columnSpacing: Theme.dp(24)
                            Layout.fillWidth: true

                            GuideItem { label: "Kill Active Window"; keys: "Super + Q" }
                            GuideItem { label: "Fullscreen"; keys: "Super + F" }
                            GuideItem { label: "Toggle Floating"; keys: "Super + Shift + F" }
                            GuideItem { label: "Exit Hyprland"; keys: "Super + M" }
                            
                            GuideItem { label: "Move Focus"; keys: "Super + Arrows" }
                            GuideItem { label: "Swap Window"; keys: "Super + Shift + Arrows" }
                            GuideItem { label: "Resize Window"; keys: "Super + Mouse Right" }
                            GuideItem { label: "Drag Window"; keys: "Super + Mouse Left" }
                        }
                    }

                    // --- Apps ---
                    CategorySection {
                        title: "Applications"
                        GridLayout {
                            columns: 2
                            rowSpacing: Theme.dp(6)
                            columnSpacing: Theme.dp(24)
                            Layout.fillWidth: true

                            GuideItem { label: "Terminal (Kitty)"; keys: "Super + Enter"; keys2: "Super + T" }
                            GuideItem { label: "File Manager (Nautilus)"; keys: "Super + E" }
                            GuideItem { label: "Browser (Brave)"; keys: "Super + W" }
                            GuideItem { label: "VS Code"; keys: "Super + C" }
                            GuideItem { label: "Discord"; keys: "Super + D" }
                            GuideItem { label: "Steam"; keys: "Super + G" }
                            GuideItem { label: "OBS Studio"; keys: "Super + O" }
                        }
                    }

                    // --- Multimedia ---
                    CategorySection {
                        title: "Multimedia & Hardware"
                        GridLayout {
                            columns: 2
                            rowSpacing: Theme.dp(6)
                            columnSpacing: Theme.dp(24)
                            Layout.fillWidth: true

                            GuideItem { label: "Volume Up/Down"; keys: "Super + . / ," }
                            GuideItem { label: "Mute Toggle"; keys: "Super + ;" }
                            GuideItem { label: "Brightness Up/Down"; keys: "Super + ] / [" }
                            GuideItem { label: "Screenshot (Region)"; keys: "Super + Shift + S" }
                            GuideItem { label: "Screenshot (Window)"; keys: "Super + S" }
                            GuideItem { label: "Media Play/Pause"; keys: "Media Keys" }
                        }
                    }

                    // --- Workspaces ---
                    CategorySection {
                        title: "Workspaces"
                        GridLayout {
                            columns: 2
                            rowSpacing: Theme.dp(6)
                            columnSpacing: Theme.dp(24)
                            Layout.fillWidth: true

                            GuideItem { label: "Switch Workspace"; keys: "Super + 1-0" }
                            GuideItem { label: "Move to Workspace"; keys: "Super + Shift + 1-0" }
                            GuideItem { label: "Next/Prev Workspace"; keys: "Alt + (Shift) + Tab" }
                        }
                    }

                    // --- App Launcher Features ---
                    CategorySection {
                        title: "Launcher Features"
                        GridLayout {
                            columns: 2
                            rowSpacing: Theme.dp(6)
                            columnSpacing: Theme.dp(24)
                            Layout.fillWidth: true

                            GuideItem { label: "Command Mode"; keys: "/"; isSub: true }
                            GuideItem { label: "Action Trigger"; keys: ">"; isSub: true }
                            GuideItem { label: "Search Mode"; keys: "?"; isSub: true }
                            GuideItem { label: "Context Menu"; keys: "Ctrl / Right-Click"; isSub: true }
                            GuideItem { label: "Go Back"; keys: "Shift + A"; isSub: true }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.border
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(12)

                Text {
                    text: "StellixOS"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(10 * s)
                    font.weight: Font.Bold
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Powered by Quickshell & Hyprland"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
                }
            }
        }
    }

    component CategorySection: ColumnLayout {
        property string title: ""
        default property alias content: innerContent.data
        Layout.fillWidth: true
        spacing: Theme.dp(8)

        Text {
            text: title
            color: Theme.accent
            font.family: Typography.fontFamily
            font.pixelSize: Math.round(12 * s)
            font.weight: Font.Bold
            opacity: 0.8
        }

        ColumnLayout {
            id: innerContent
            Layout.fillWidth: true
            spacing: 0
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
            cursorShape: Qt.PointingHandCursor
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
