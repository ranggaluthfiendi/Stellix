import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.components.elements
import qs.components.widgets.barpopup
import "../components/widgets/applauncher/settings/components"

PanelWindow {
    id: root

    property var settingsData: null
    property bool active: settingsData ? settingsData.showWelcomeScreen : false
    
    visible: active
    color: "transparent"

    anchors {
        top: true; left: true; right: true; bottom: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible && mainContent.opacity > 0.5 ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: -1

    Connections {
        target: BarPopupState
        function onWelcomeRequested() {
            root.active = true
            mainContent.currentIndex = 0
            fadeIn.start()
        }
    }

    Item {
        id: mainContent
        anchors.fill: parent
        opacity: 0

        property int currentIndex: 0
        readonly property int totalPages: 4
        property bool localShowOnStartup: root.settingsData ? root.settingsData.showWelcomeScreen : true

        Component.onCompleted: {
            if (root.active) {
                fadeIn.start()
            }
        }
        
        NumberAnimation { id: fadeIn; target: mainContent; property: "opacity"; from: 0; to: 1; duration: 800; easing.type: Easing.OutCubic }
        NumberAnimation { 
            id: fadeOut; 
            target: mainContent; 
            property: "opacity"; 
            from: 1; to: 0; 
            duration: 400; 
            easing.type: Easing.InCubic; 
            onFinished: {
                if (root.settingsData) root.settingsData.showWelcomeScreen = mainContent.localShowOnStartup
                root.active = false
                BarPopupState.weatherDetailOpen = false
            }
        }

        // Background Dim
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.6
        }

        // Main Card
        Rectangle {
            id: card
            anchors.centerIn: parent
            width: Theme.dp(540)
            height: mainContent.currentIndex === 3 ? Theme.dp(560) : Theme.dp(520)
            color: Theme.bgPrimary
            border.width: 1
            border.color: Theme.border
            radius: 0
            clip: true
            scale: 0.9 + (0.1 * mainContent.opacity)
            y: (root.height - height) / 2 + (Theme.dp(20) * (1 - mainContent.opacity))

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.dp(32)
                spacing: Theme.dp(20)

                // Header (Common for all pages or specific?) 
                // Let's keep a consistent header but change content
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Theme.dp(16)

                    Item {
                        Layout.preferredWidth: Theme.dp(80)
                        Layout.preferredHeight: Theme.dp(80)
                        Layout.alignment: Qt.AlignHCenter
                        StarShape {
                            id: star
                            anchors.centerIn: parent
                            width: Theme.dp(64); height: Theme.dp(64)
                            color: Theme.accent
                            RotationAnimation on rotation { from: 0; to: 360; duration: 6000; loops: Animation.Infinite; running: root.visible }
                        }
                        Rectangle { anchors.centerIn: parent; width: Theme.dp(90); height: Theme.dp(90); radius: width / 2; color: Theme.accent; opacity: 0.15; z: -1 }
                    }

                    ColumnLayout {
                        spacing: Theme.dp(4)
                        Layout.alignment: Qt.AlignHCenter
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: mainContent.currentIndex === 0 ? "Welcome to Stellix" : (mainContent.currentIndex === 1 ? "Quick Controls" : (mainContent.currentIndex === 2 ? "Aesthetic Engine" : "Desktop Widgets"))
                            color: Theme.textPrimary; font.pixelSize: Theme.dp(24); font.weight: Font.Bold
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Stellix Shell Environment"
                            color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Medium; opacity: 0.8
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.border; opacity: 0.3 }

                // Paged Content
                StackLayout {
                    id: pagedStack
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: mainContent.currentIndex

                    // Page 0: Intro
                    ColumnLayout {
                        spacing: Theme.dp(16)
                        Text {
                            Layout.fillWidth: true
                            text: "Experience a focused, aesthetic, and high-performance workflow powered by Quickshell and Hyprland.\n\nStellix is designed to be fully customizable, lightweight, and deeply integrated with your Linux system."
                            color: Theme.textSecondary; font.pixelSize: Theme.dp(12); horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; lineHeight: 1.5
                        }
                    }

                    // Page 1: Features
                    ColumnLayout {
                        spacing: Theme.dp(12)
                        Text {
                            Layout.fillWidth: true
                            text: "Control your system with ease using global shortcuts and modular widgets."
                            color: Theme.textSecondary; font.pixelSize: Theme.dp(11); horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
                        }
                        GridLayout {
                            columns: 2; Layout.alignment: Qt.AlignHCenter; columnSpacing: Theme.dp(20); rowSpacing: Theme.dp(8)
                            Text { text: "SUPER + ENTER"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold }
                            Text { text: "Terminal"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10) }
                            Text { text: "SUPER + I"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold }
                            Text { text: "Settings"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10) }
                            Text { text: "ALT + SPACE"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold }
                            Text { text: "Launcher"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10) }
                            Text { text: "SUPER + /"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold }
                            Text { text: "Shortcut Guide"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10) }
                        }
                    }

                    // Page 2: Customization
                    ColumnLayout {
                        spacing: Theme.dp(16)
                        Text {
                            Layout.fillWidth: true
                            text: "Your system, your colors. Stellix uses Matugen to generate dynamic themes from your wallpaper.\n\nChange your wallpaper from the launcher and watch the entire shell transform instantly."
                            color: Theme.textSecondary; font.pixelSize: Theme.dp(12); horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; lineHeight: 1.5
                        }
                    }

                    // Page 3: Desktop Widgets
                    ColumnLayout {
                        spacing: Theme.dp(12)
                        Text {
                            Layout.fillWidth: true
                            text: "Customize your desktop with draggable widgets. Clock, system stats, weather, music player, and audio visualizer — all configurable from Settings."
                            color: Theme.textSecondary; font.pixelSize: Theme.dp(11); horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
                        }
                        GridLayout {
                            columns: 2; Layout.alignment: Qt.AlignHCenter; columnSpacing: Theme.dp(20); rowSpacing: Theme.dp(8)
                            Text { text: "CLOCK"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold }
                            Text { text: "Time & Date"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10) }
                            Text { text: "STATS"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold }
                            Text { text: "CPU, RAM, GPU, Net"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10) }
                            Text { text: "WEATHER"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold }
                            Text { text: "Live Forecast"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10) }
                            Text { text: "NOW PLAYING"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold }
                            Text { text: "Media Controls"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10) }
                            Text { text: "EQUALIZER"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold }
                            Text { text: "Audio Visualizer"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10) }
                            Text { text: "QUICK ACTIONS"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold }
                            Text { text: "Power Buttons"; color: Theme.textPrimary; font.pixelSize: Theme.dp(10) }
                        }
                    }
                }

                // Page Indicators
                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Theme.dp(8)
                    Repeater {
                        model: mainContent.totalPages
                        Rectangle {
                            width: mainContent.currentIndex === index ? Theme.dp(16) : Theme.dp(6)
                            height: Theme.dp(6); radius: 3
                            color: mainContent.currentIndex === index ? Theme.accent : Theme.border
                            Behavior on width { NumberAnimation { duration: 200 } }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Footer
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(48); color: "transparent"
                    RowLayout {
                        anchors.fill: parent; spacing: Theme.dp(12)
                        
                        RowLayout {
                            Layout.alignment: Qt.AlignVCenter; spacing: Theme.dp(12)
                            VabSwitch {
                                checked: mainContent.localShowOnStartup
                                onToggled: mainContent.localShowOnStartup = !mainContent.localShowOnStartup
                            }
                            Text { text: "Show on startup"; color: Theme.textMuted; font.pixelSize: Theme.dp(10); verticalAlignment: Text.AlignVCenter }
                        }

                        Item { Layout.fillWidth: true }

                        VabButton {
                            visible: mainContent.currentIndex > 0
                            text: "Back"
                            onClicked: mainContent.currentIndex--
                        }

                        VabButton {
                            text: mainContent.currentIndex === mainContent.totalPages - 1 ? "Get Started" : "Next"
                            onClicked: {
                                if (mainContent.currentIndex < mainContent.totalPages - 1) mainContent.currentIndex++
                                else fadeOut.start()
                            }
                        }
                    }
                }
            }
        }
    }

    // Capture Escape key to close
    Item {
        focus: root.visible
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                fadeOut.start()
                event.accepted = true
            }
        }
    }
}

