import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.config
import qs.components.elements
import qs.core.state
import qs.components.utils

Item {
    id: root

    property real s: 1.0

    readonly property var mprisService: BarLayoutState.getItem("mprisService")
    readonly property var activePlayer: mprisService ? mprisService.activePlayer : null

    function resolveColor(mode, fallback) {
        switch (mode) {
            case "accent": return Theme.accent
            case "accent_soft": return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
            case "bg_secondary": return Theme.bgSecondary
            case "bg_primary": return Theme.bgPrimary
            case "text_primary": return Theme.textPrimary
            case "text_muted": return Theme.textMuted
            case "border": return Theme.border
            case "white": return "#ffffff"
            case "black": return "#000000"
            case "transparent": return "transparent"
            case "custom": return BarLayoutState.desktopNowPlayingCustomBgColor
            default: return fallback
        }
    }

    implicitWidth: Theme.dp(340) * s
    implicitHeight: Theme.dp(140) * s

    ClippingRectangle {
        id: bg
        anchors.fill: parent
        color: Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.4)
        radius: Theme.dp(BarLayoutState.desktopNowPlayingRadius) * s
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.1)
        clip: true

        // ── Glass reflection effect ──
        Rectangle {
            anchors.fill: parent
            radius: bg.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.05) }
                GradientStop { position: 0.5; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.05) }
            }
        }

        // ── Persistent Background Art ──
        Image {
            id: blurredBg
            anchors.fill: parent
            source: {
                if (root.activePlayer && root.activePlayer.trackArtUrl && root.activePlayer.trackArtUrl !== "") 
                    return root.activePlayer.trackArtUrl
                return mprisService ? mprisService.persistentArtUrl : ""
            }
            fillMode: Image.PreserveAspectCrop
            opacity: 0.15
            visible: status === Image.Ready
            asynchronous: true
        }

        // Animated Waves
        WaveVisualizer {
            anchors.fill: parent
            opacity: 0.1
            active: root.activePlayer && root.activePlayer.isPlaying
            waveColor: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent)
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(16) * s
            spacing: Theme.dp(20) * s

            // ── Spinning Vinyl Art ──
            ClippingRectangle {
                Layout.preferredWidth: Theme.dp(100) * s
                Layout.preferredHeight: Theme.dp(100) * s
                radius: width / 2
                color: Theme.border
                clip: true
                
                Item {
                    anchors.fill: parent
                    RotationAnimation on rotation {
                        running: root.activePlayer && root.activePlayer.isPlaying
                        from: 0; to: 360; duration: 5000; loops: Animation.Infinite
                    }

                    Image {
                        anchors.fill: parent
                        source: {
                            if (root.activePlayer && root.activePlayer.trackArtUrl && root.activePlayer.trackArtUrl !== "") 
                                return root.activePlayer.trackArtUrl
                            return mprisService ? mprisService.persistentArtUrl : ""
                        }
                        fillMode: Image.PreserveAspectCrop
                        visible: status === Image.Ready
                        asynchronous: true
                    }
                    
                    Rectangle {
                        anchors.centerIn: parent
                        width: Theme.dp(20) * s
                        height: width
                        radius: width / 2
                        color: Theme.bgPrimary
                        border.width: 2
                        border.color: Qt.rgba(1, 1, 1, 0.2)
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MarqueeText {
                    Layout.fillWidth: true
                    text: mprisService ? (mprisService.title || "No Media") : "No Media"
                    textColor: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textPrimary)
                    fontSize: 16
                    fontScale: s
                    fontWeight: Font.Black
                    scrolling: true
                    textPadding: 0
                }

                MarqueeText {
                    Layout.fillWidth: true
                    text: mprisService ? (mprisService.artist || "Unknown Artist") : "Unknown"
                    textColor: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent)
                    fontSize: 12
                    fontScale: s
                    fontWeight: Font.Medium
                    scrolling: true
                    textPadding: 0
                }

                Item { Layout.preferredHeight: Theme.dp(10) * s }

                RowLayout {
                    spacing: Theme.dp(12) * s
                    
                    Rectangle {
                        Layout.preferredWidth: Theme.dp(32) * s
                        Layout.preferredHeight: Theme.dp(32) * s
                        radius: 16 * s
                        color: prevM.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                        Text { anchors.centerIn: parent; text: "󰒮"; font.pixelSize: 14 * s; color: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textPrimary) }
                        MouseArea { id: prevM; anchors.fill: parent; hoverEnabled: true; onClicked: if (root.activePlayer) root.activePlayer.previous() }
                    }

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(40) * s
                        Layout.preferredHeight: Theme.dp(40) * s
                        radius: width / 2
                        color: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent)
                        
                        Text {
                            anchors.centerIn: parent
                            text: (root.activePlayer && root.activePlayer.isPlaying) ? "󰏤" : "󰐊"
                            color: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, "white")
                            font.pixelSize: Theme.dp(20) * s
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: if (root.activePlayer) root.activePlayer.togglePlaying()
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(32) * s
                        Layout.preferredHeight: Theme.dp(32) * s
                        radius: 16 * s
                        color: nextM.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                        Text { anchors.centerIn: parent; text: "󰒭"; font.pixelSize: 14 * s; color: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textPrimary) }
                        MouseArea { id: nextM; anchors.fill: parent; hoverEnabled: true; onClicked: if (root.activePlayer) root.activePlayer.next() }
                    }
                }
            }
        }
        
        // ── Interactive Bottom Progress Bar ──
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width * (mprisService && mprisService.length > 0 ? mprisService.position / mprisService.length : 0)
            height: Theme.dp(6) * s
            color: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent)
            opacity: 0.8
            Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Theme.dp(12) * s
            enabled: root.activePlayer && root.activePlayer.canSeek
            onClicked: (mouse) => {
                if (root.activePlayer) {
                    root.activePlayer.position = (mouse.x / width) * root.activePlayer.length
                }
            }
        }
    }
}
