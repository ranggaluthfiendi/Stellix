import qs.core.settings
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components.widgets.barpopup

PanelWindow {
    id: root

    property real s: Scales.uiScale
    
    visible: BarPopupState.guideOpen
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: BarPopupState.guideOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: -1

    MouseArea {
        anchors.fill: parent
        onClicked: {
            BarPopupState.guideOpen = false
            BarPopupState.weatherDetailOpen = false
        }

        Keys.forwardTo: [keyboardHandler]
    }

    Item {
        id: keyboardHandler
        anchors.fill: parent
        focus: BarPopupState.guideOpen

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape || event.key === Qt.Key_Slash) {
                BarPopupState.guideOpen = false
                event.accepted = true
            }
        }
    }

    Rectangle {
        id: mainContainer
        anchors.centerIn: parent
        width: Math.min(parent.width - Theme.dp(64), Theme.dp(1000))
        height: Math.min(parent.height - Theme.dp(64), contentCol.implicitHeight + Theme.dp(32))
        color: Theme.bgSecondary
        border.width: 1
        border.color: Theme.border
        radius: 0

        opacity: BarPopupState.guideOpen ? 1 : 0
        scale: BarPopupState.guideOpen ? 1 : 0.95

        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        Behavior on scale {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(16)
            spacing: Theme.dp(10)

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(8)

                Text {
                    text: "Stellix Shortcut Guide"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(14 * s)
                    font.weight: Font.Bold
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "ESC / to close"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
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
                    spacing: Theme.dp(14)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)

                        CategorySection {
                            title: "System"
                            Layout.fillWidth: true
                            GridLayout {
                                columns: 1
                                rowSpacing: Theme.dp(4)
                                columnSpacing: Theme.dp(16)
                                Layout.fillWidth: true

                                GuideItem { label: "App Launcher"; keys: "Super+R"; keys2: "Alt+Space" }
                                GuideItem { label: "Clipboard"; keys: "Super+V" }
                                GuideItem { label: "Settings"; keys: "Super+I" }
                                GuideItem { label: "Guide"; keys: "Super+/" }
                                GuideItem { label: "Rightbar"; keys: "Super+Alt" }
                                GuideItem { label: "WS Switcher"; keys: "Super+Tab" }
                            }
                        }

                        CategorySection {
                            title: "Windows"
                            Layout.fillWidth: true
                            GridLayout {
                                columns: 1
                                rowSpacing: Theme.dp(4)
                                columnSpacing: Theme.dp(16)
                                Layout.fillWidth: true

                                GuideItem { label: "Kill Window"; keys: "Super+Q" }
                                GuideItem { label: "Fullscreen"; keys: "Super+F" }
                                GuideItem { label: "Floating"; keys: "Super+Shift+F" }
                                GuideItem { label: "Exit Hyprland"; keys: "Super+M" }
                                GuideItem { label: "Move Focus"; keys: "Super+Arrows" }
                                GuideItem { label: "Swap Window"; keys: "Super+Shift+Arrows" }
                            }
                        }

                        CategorySection {
                            title: "Apps"
                            Layout.fillWidth: true
                            GridLayout {
                                columns: 1
                                rowSpacing: Theme.dp(4)
                                columnSpacing: Theme.dp(16)
                                Layout.fillWidth: true

                                GuideItem { label: "Terminal"; keys: "Super+Enter" }
                                GuideItem { label: "Files"; keys: "Super+E" }
                                GuideItem { label: "Browser"; keys: "Super+W" }
                                GuideItem { label: "VS Code"; keys: "Super+C" }
                                GuideItem { label: "Discord"; keys: "Super+D" }
                                GuideItem { label: "Steam"; keys: "Super+G" }
                            }
                        }

                        CategorySection {
                            title: "Screenshots"
                            Layout.fillWidth: true
                            GridLayout {
                                columns: 1
                                rowSpacing: Theme.dp(4)
                                columnSpacing: Theme.dp(16)
                                Layout.fillWidth: true

                                GuideItem { label: "Region"; keys: "Super+Shift+S" }
                                GuideItem { label: "Window"; keys: "Super+S" }
                                GuideItem { label: "Monitor"; keys: "Super+Shift+Print" }
                            }
                        }

                        CategorySection {
                            title: "Media"
                            Layout.fillWidth: true
                            GridLayout {
                                columns: 1
                                rowSpacing: Theme.dp(4)
                                columnSpacing: Theme.dp(16)
                                Layout.fillWidth: true

                                GuideItem { label: "Volume"; keys: "Super+./," }
                                GuideItem { label: "Mute"; keys: "Super+;" }
                                GuideItem { label: "Brightness"; keys: "Super+]/[" }
                                GuideItem { label: "Play/Pause"; keys: "Media Key" }
                            }
                        }

                        CategorySection {
                            title: "Workspaces"
                            Layout.fillWidth: true
                            GridLayout {
                                columns: 1
                                rowSpacing: Theme.dp(4)
                                columnSpacing: Theme.dp(16)
                                Layout.fillWidth: true

                                GuideItem { label: "Switch WS"; keys: "Super+1-0" }
                                GuideItem { label: "Move to WS"; keys: "Super+Shift+1-0" }
                                GuideItem { label: "Next WS"; keys: "Alt+Tab" }
                                GuideItem { label: "Prev WS"; keys: "Alt+Shift+Tab" }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.dp(12)

                        CategorySection {
                            title: "Launcher Commands"
                            Layout.fillWidth: true
                            GridLayout {
                                columns: 1
                                rowSpacing: Theme.dp(4)
                                columnSpacing: Theme.dp(16)
                                Layout.fillWidth: true

                                GuideItem { label: "Command"; keys: "/"; isSub: true }
                                GuideItem { label: "Action"; keys: ">"; isSub: true }
                                GuideItem { label: "Search"; keys: "?"; isSub: true }
                                GuideItem { label: "Context Menu"; keys: "Ctrl"; isSub: true }
                                GuideItem { label: "Calculator"; keys: "> calc"; isSub: true }
                                GuideItem { label: "Currency"; keys: "> currency"; isSub: true }
                                GuideItem { label: "Colors"; keys: "> color"; isSub: true }
                                GuideItem { label: "Wallpaper"; keys: "> wallpaper"; isSub: true }
                            }
                        }

                        CategorySection {
                            title: "Widgets"
                            Layout.fillWidth: true
                            GridLayout {
                                columns: 1
                                rowSpacing: Theme.dp(4)
                                columnSpacing: Theme.dp(16)
                                Layout.fillWidth: true

                                GuideItem { label: "Move"; keys: "Right-Click+Drag" }
                                GuideItem { label: "Rotate"; keys: "Scroll Wheel" }
                                GuideItem { label: "Reset Rotation"; keys: "Middle-Click" }
                                GuideItem { label: "Reset Position"; keys: "Double Right-Click" }
                            }
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
                    text: "Stellix Shell"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
                    font.weight: Font.Bold
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Powered by Quickshell & Hyprland"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                }
            }
        }
    }

    component CategorySection: ColumnLayout {
        property string title: ""
        default property alias content: innerContent.data
        Layout.fillWidth: true
        spacing: Theme.dp(6)

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.dp(8)

            Text {
                text: title
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(10 * s)
                font.weight: Font.Bold
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.5)
            }
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
        spacing: Theme.dp(6)

        Text {
            text: label
            color: isSub ? Theme.textMuted : Theme.textPrimary
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((isSub ? 9 : 10) * s)
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        KeyBox { text: keys }
        KeyBox { text: keys2; visible: keys2.length > 0 }
    }

    component KeyBox: Rectangle {
        property string text: ""
        Layout.preferredHeight: Theme.dp(20)
        Layout.preferredWidth: keyText.implicitWidth + Theme.dp(10)
        color: hovered ? Theme.surface : Theme.bgPrimary
        border.width: 1
        border.color: hovered ? Theme.accent : Theme.border
        radius: Theme.dp(3)

        property bool hovered: false

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: parent.hovered = true
            onExited: parent.hovered = false
        }

        Text {
            id: keyText
            anchors.centerIn: parent
            text: parent.text
            color: Theme.accent
            font.family: Typography.fontFamily
            font.pixelSize: Math.round(8 * s)
            font.weight: Font.Medium
        }
    }
}
