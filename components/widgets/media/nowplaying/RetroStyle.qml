import QtQuick
import QtQuick.Layouts
import Quickshell
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

    implicitWidth: Theme.dp(280) * s
    implicitHeight: Theme.dp(160) * s

    // ── Cassette Body ──
    Rectangle {
        anchors.fill: parent
        color: resolveColor(BarLayoutState.desktopNowPlayingBgColorMode, Theme.bgSecondary)
        radius: Theme.dp(8) * s
        border.width: 4
        border.color: resolveColor(BarLayoutState.desktopNowPlayingBorderColorMode, Theme.border)
        
        // ── Persistent Artwork / Label Area ──
        Rectangle {
            anchors.centerIn: parent
            width: parent.width - Theme.dp(40) * s
            height: parent.height - Theme.dp(60) * s
            color: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent)
            radius: Theme.dp(4) * s
            clip: true

            // Blurred art as label background
            Image {
                anchors.fill: parent
                source: {
                    if (root.activePlayer && root.activePlayer.trackArtUrl && root.activePlayer.trackArtUrl !== "") 
                        return root.activePlayer.trackArtUrl
                    return mprisService ? mprisService.persistentArtUrl : ""
                }
                fillMode: Image.PreserveAspectCrop
                opacity: 0.3
                visible: status === Image.Ready
            }
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.dp(8) * s
                spacing: 0
                
                Text {
                    text: "CASSETTE TAPE"
                    color: "white"
                    font.pixelSize: Theme.dp(8) * s
                    font.weight: Font.Bold
                    Layout.alignment: Qt.AlignRight
                }
                
                Item { Layout.fillHeight: true }
                
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(40) * s
                        color: Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.9)
                        radius: Theme.dp(2) * s
                        border.width: 1
                        border.color: resolveColor(BarLayoutState.desktopNowPlayingBorderColorMode, Theme.border)
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.dp(4) * s
                            spacing: 2
                            
                            MarqueeText {
                                Layout.fillWidth: true
                                text: mprisService ? (mprisService.title || "SIDE A") : "SIDE A"
                                textColor: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textPrimary)
                                fontSize: 10
                                fontScale: s
                                fontWeight: Font.Bold
                                scrolling: true
                                textPadding: 0
                            }
                            MarqueeText {
                                Layout.fillWidth: true
                                text: mprisService ? (mprisService.artist || "REC: 2026") : "REC: 2026"
                                textColor: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textMuted)
                                fontSize: 8
                                fontScale: s
                                fontWeight: Font.Normal
                                scrolling: true
                                textPadding: 0
                            }
                        }
                    }
                
                Item { Layout.fillHeight: true }
                
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "60 min"; color: "white"; font.pixelSize: Theme.dp(8) * s }
                    Item { Layout.fillWidth: true }
                    Text { text: "HI-FI"; color: "white"; font.pixelSize: Theme.dp(8) * s; font.weight: Font.Bold }
                }
            }
        }
        
        // ── Spools ──
        Row {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: Theme.dp(20) * s
            spacing: Theme.dp(80) * s
            
            Repeater {
                model: 2
                Rectangle {
                    width: Theme.dp(30) * s
                    height: width
                    radius: width / 2
                    color: resolveColor(BarLayoutState.desktopNowPlayingBorderColorMode, Theme.border)

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.4
                        height: width
                        radius: width / 2
                        color: resolveColor(BarLayoutState.desktopNowPlayingBgColorMode, Theme.bgSecondary)

                        RotationAnimation on rotation {
                            running: root.activePlayer && root.activePlayer.isPlaying
                            from: 0; to: 360; duration: 2000; loops: Animation.Infinite
                        }

                        Rectangle {
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 2; height: 6; color: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent)
                        }
                    }
                }

            }
        }
        
        // ── Bottom Controls ──
        RowLayout {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.dp(6) * s
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.dp(10) * s
            
            Rectangle {
                Layout.preferredWidth: Theme.dp(32) * s
                Layout.preferredHeight: Theme.dp(24) * s
                radius: 4; color: prevRM.containsMouse ? resolveColor(BarLayoutState.desktopNowPlayingBorderColorMode, Theme.border) : resolveColor(BarLayoutState.desktopNowPlayingBgColorMode, Theme.bgSecondary)
                Text { anchors.centerIn: parent; text: "<<"; font.pixelSize: 8 * s; color: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textPrimary) }
                MouseArea { id: prevRM; anchors.fill: parent; hoverEnabled: true; onClicked: if (root.activePlayer) root.activePlayer.previous() }
            }
            Rectangle {
                Layout.preferredWidth: Theme.dp(32) * s
                Layout.preferredHeight: Theme.dp(24) * s
                radius: 4; color: playRM.containsMouse ? resolveColor(BarLayoutState.desktopNowPlayingBorderColorMode, Theme.border) : resolveColor(BarLayoutState.desktopNowPlayingBgColorMode, Theme.bgSecondary)
                Text { anchors.centerIn: parent; text: (root.activePlayer && root.activePlayer.isPlaying) ? "|| " : "> "; font.pixelSize: 8 * s; color: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent) }
                MouseArea { id: playRM; anchors.fill: parent; hoverEnabled: true; onClicked: if (root.activePlayer) root.activePlayer.togglePlaying() }
            }
            Rectangle {
                Layout.preferredWidth: Theme.dp(32) * s
                Layout.preferredHeight: Theme.dp(24) * s
                radius: 4; color: nextRM.containsMouse ? resolveColor(BarLayoutState.desktopNowPlayingBorderColorMode, Theme.border) : resolveColor(BarLayoutState.desktopNowPlayingBgColorMode, Theme.bgSecondary)
                Text { anchors.centerIn: parent; text: ">>"; font.pixelSize: 8 * s; color: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textPrimary) }
                MouseArea { id: nextRM; anchors.fill: parent; hoverEnabled: true; onClicked: if (root.activePlayer) root.activePlayer.next() }
            }
        }

        // ── Interactive Progress ──
        MouseArea {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: Theme.dp(15) * s
            enabled: root.activePlayer && root.activePlayer.canSeek
            onClicked: (mouse) => {
                if (root.activePlayer) {
                    root.activePlayer.position = (mouse.x / width) * root.activePlayer.length
                }
            }
        }
    }
}
