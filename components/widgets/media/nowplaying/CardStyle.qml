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

    property real s: Scales.uiScale
    property real iconSz: Theme.dp(16) * s

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
    implicitHeight: Theme.dp(130) * s

    ClippingRectangle {
        id: bg
        anchors.fill: parent
        color: resolveColor(BarLayoutState.desktopNowPlayingBgColorMode, Theme.bgSecondary)
        radius: Theme.dp(BarLayoutState.desktopNowPlayingRadius) * s
        border.width: 1
        border.color: resolveColor(BarLayoutState.desktopNowPlayingBorderColorMode, Theme.border)
        clip: true

        // ── Persistent Background Art Blur ──
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

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(16) * s
            spacing: Theme.dp(20) * s

            // ── Artwork Box ──
            ClippingRectangle {
                Layout.preferredWidth: Theme.dp(96) * s
                Layout.preferredHeight: Theme.dp(96) * s
                radius: Theme.dp(10) * s
                color: Theme.border
                clip: true

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

                Text {
                    anchors.centerIn: parent
                    text: "♪"
                    font.pixelSize: Theme.dp(32) * s
                    color: Theme.textMuted
                    visible: !parent.children[0].visible
                }

                // Play/Pause Overlay
                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(0, 0, 0, 0.4)
                    opacity: artMouse.containsMouse ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    IconPlay {
                        anchors.centerIn: parent
                        visible: !root.activePlayer || !root.activePlayer.isPlaying
                        iconSize: Theme.dp(32) * s
                        iconColor: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, "white")
                    }
                    IconPause {
                        anchors.centerIn: parent
                        visible: root.activePlayer && root.activePlayer.isPlaying
                        iconSize: Theme.dp(32) * s
                        iconColor: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, "white")
                    }
                }

                MouseArea {
                    id: artMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: if (root.activePlayer) root.activePlayer.togglePlaying()
                }
            }

            // ── Info & Controls ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(4) * s

                MarqueeText {
                    Layout.fillWidth: true
                    text: mprisService ? (mprisService.title || "No Media Playing") : "No Media"
                    textColor: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textPrimary)
                    fontSize: 14
                    fontScale: s
                    fontWeight: Font.Bold
                    scrolling: true
                    textPadding: 0
                }

                MarqueeText {
                    Layout.fillWidth: true
                    text: mprisService ? (mprisService.artist || "Unknown Artist") : "Unknown"
                    textColor: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textMuted)
                    fontSize: 11
                    fontScale: s
                    fontWeight: Font.Normal
                    scrolling: true
                    textPadding: 0
                }

                Item { Layout.fillHeight: true }

                // ── Interactive Progress ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(4) * s

                    Rectangle {
                        id: progressBar
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.dp(6) * s
                        color: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.1)
                        radius: height / 2

                        Rectangle {
                            width: parent.width * (mprisService && mprisService.length > 0 ? mprisService.position / mprisService.length : 0)
                            height: parent.height
                            color: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent)
                            radius: height / 2
                            Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: root.activePlayer && root.activePlayer.canSeek
                            onClicked: (mouse) => {
                                if (root.activePlayer) {
                                    root.activePlayer.position = (mouse.x / width) * root.activePlayer.length
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: mprisService ? mprisService.formatTime(mprisService.position) : "00:00"
                            color: Theme.textMuted
                            font.pixelSize: Theme.dp(8) * s
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: mprisService ? mprisService.formatTime(mprisService.length) : "00:00"
                            color: Theme.textMuted
                            font.pixelSize: Theme.dp(8) * s
                        }
                    }
                }

                // ── Controls ──
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: Theme.dp(12) * s

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(32) * s
                        Layout.preferredHeight: Theme.dp(32) * s
                        color: prevMouse.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                        radius: 16 * s
                        Text { anchors.centerIn: parent; text: "󰒮"; font.pixelSize: 14 * s; color: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textPrimary) }
                        MouseArea { id: prevMouse; anchors.fill: parent; hoverEnabled: true; onClicked: if (root.activePlayer) root.activePlayer.previous() }
                    }
                    Rectangle {
                        Layout.preferredWidth: Theme.dp(32) * s
                        Layout.preferredHeight: Theme.dp(32) * s
                        color: playMouse.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                        radius: 16 * s
                        Text { anchors.centerIn: parent; text: (root.activePlayer && root.activePlayer.isPlaying) ? "󰏤" : "󰐊"; font.pixelSize: 16 * s; color: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent) }
                        MouseArea { id: playMouse; anchors.fill: parent; hoverEnabled: true; onClicked: if (root.activePlayer) root.activePlayer.togglePlaying() }
                    }
                    Rectangle {
                        Layout.preferredWidth: Theme.dp(32) * s
                        Layout.preferredHeight: Theme.dp(32) * s
                        color: nextMouse.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                        radius: 16 * s
                        Text { anchors.centerIn: parent; text: "󰒭"; font.pixelSize: 14 * s; color: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textPrimary) }
                        MouseArea { id: nextMouse; anchors.fill: parent; hoverEnabled: true; onClicked: if (root.activePlayer) root.activePlayer.next() }
                    }
                }
            }
        }
    }
}
