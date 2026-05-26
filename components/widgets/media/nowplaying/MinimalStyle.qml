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

    implicitWidth: contentCol.implicitWidth + Theme.dp(32) * s
    implicitHeight: contentCol.implicitHeight + Theme.dp(16) * s

    Rectangle {
        anchors.fill: parent
        color: resolveColor(BarLayoutState.desktopNowPlayingBgColorMode, Theme.bgSecondary)
        radius: Theme.dp(6) * s
        opacity: 0.8
    }

    ColumnLayout {
        id: contentCol
        anchors.centerIn: parent
        spacing: Theme.dp(4) * s

        RowLayout {
            spacing: Theme.dp(8) * s
            Text {
                text: (root.activePlayer && root.activePlayer.isPlaying) ? "󰏤" : "󰐊"
                font.pixelSize: Theme.dp(14) * s
                color: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent)
            }
            MarqueeText {
                width: Theme.dp(150) * s
                text: mprisService ? (mprisService.title || "No Media") : "No Media"
                textColor: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textPrimary)
                fontSize: 11
                fontScale: s
                fontWeight: Font.Bold
                scrolling: true
                textPadding: 0
            }
            Text {
                text: "•"
                color: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textMuted)
                font.pixelSize: Theme.dp(10) * s
            }
            MarqueeText {
                width: Theme.dp(100) * s
                text: mprisService ? (mprisService.artist || "Unknown") : "Unknown"
                textColor: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textMuted)
                fontSize: 10
                fontScale: s
                fontWeight: Font.Normal
                scrolling: true
                textPadding: 0
            }
        }

        // ── Interactive Progress ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(3) * s
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
    }

    MouseArea {
        anchors.fill: parent
        onClicked: if (root.activePlayer) root.activePlayer.togglePlaying()
    }
}
