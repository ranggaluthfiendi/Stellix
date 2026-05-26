import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.config
import qs.components.elements
import qs.core.state
import qs.components.utils
import "." 

Item {
    id: styleRoot

    property real s: 1.0

    readonly property var mprisSvc: BarLayoutState.getItem("mprisService")
    readonly property var activePlayer: mprisSvc ? mprisSvc.activePlayer : null

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

    implicitWidth: Math.max(300 * s, trackInfo.x + trackInfo.contentWidth + 20 * s)
    implicitHeight: 97 * s

    property real contentOffsetX: 20 * s
    property real mediaOffset: (mprisSvc && mprisSvc.hasPlayer) ? 0 : -(140 * s)

    Behavior on mediaOffset {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }

    BackgroundBox {
        x: styleRoot.contentOffsetX + styleRoot.mediaOffset
        s: styleRoot.s
        secondary: resolveColor(BarLayoutState.desktopNowPlayingBgColorMode, Theme.bgSecondary)
        contentWidth: trackInfo.contentWidth
    }

    SeparatorLines {
        x: styleRoot.contentOffsetX + styleRoot.mediaOffset
        s: styleRoot.s
        secondary: resolveColor(BarLayoutState.desktopNowPlayingBorderColorMode, Theme.border)
        contentWidth: trackInfo.contentWidth
    }

    // --- Nier Interactive Progress Bar ---
    Rectangle {
        x: (197 * styleRoot.s) + styleRoot.contentOffsetX + styleRoot.mediaOffset
        y: 80 * styleRoot.s
        width: Math.min(trackInfo.contentWidth, 500 * styleRoot.s)
        height: 6 * styleRoot.s
        color: "transparent"
        
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width * (mprisSvc && mprisSvc.length > 0 ? mprisSvc.position / mprisSvc.length : 0)
            height: 2 * styleRoot.s
            color: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent)
            opacity: 0.8
            Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            anchors.fill: parent
            enabled: styleRoot.activePlayer && styleRoot.activePlayer.canSeek
            onClicked: (mouse) => {
                if (styleRoot.activePlayer && mprisSvc && mprisSvc.length > 0) {
                    styleRoot.activePlayer.position = (mouse.x / width) * mprisSvc.length
                }
            }
        }
    }

    LeftBars {
        x: styleRoot.contentOffsetX + styleRoot.mediaOffset
        s: styleRoot.s
        primary: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent)
    }

    ArrowShape {
        id: arrow
        x: (145 * s) + styleRoot.contentOffsetX + styleRoot.mediaOffset
        y: 29 * s
        s: styleRoot.s
        primary: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent)
        background: resolveColor(BarLayoutState.desktopNowPlayingBgColorMode, Theme.bgSecondary)
        opacity: (mprisSvc && mprisSvc.hasPlayer) ? (0.4 + (mprisSvc.isPlaying ? 0.3 : 0)) : 0.4
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    Item {
        x: styleRoot.mediaOffset
        width: 140 * s
        height: 97 * s
        clip: true

        property bool artHovered: false

        MouseArea {
            anchors.fill: parent
            hoverEnabled: mprisSvc && mprisSvc.hasPlayer
            cursorShape: (mprisSvc && mprisSvc.hasPlayer) ? Qt.PointingHandCursor : Qt.ArrowCursor
            onEntered: parent.artHovered = true
            onExited: parent.artHovered = false
            onClicked: {
                if (styleRoot.activePlayer && styleRoot.activePlayer.canRaise) {
                    styleRoot.activePlayer.raise()
                }
            }
        }

        Image {
            id: coverArt
            anchors.fill: parent
            clip: true
            asynchronous: true
            cache: false
            source: {
                if (styleRoot.activePlayer && styleRoot.activePlayer.trackArtUrl && styleRoot.activePlayer.trackArtUrl !== "") 
                    return styleRoot.activePlayer.trackArtUrl
                return mprisSvc ? mprisSvc.persistentArtUrl : ""
            }
            fillMode: Image.PreserveAspectCrop
            sourceSize.width: 140 * s
            sourceSize.height: 97 * s
            visible: status === Image.Ready
            opacity: visible ? (parent.artHovered ? 0.35 : 1.0) : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        Image {
            id: blurredBg
            anchors.fill: parent
            z: -1
            source: coverArt.source
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
            cache: false
            asynchronous: true
            opacity: 0.4
        }

        WaveVisualizer {
            id: smoothWave
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8 * s
            anchors.leftMargin: 10 * s
            anchors.rightMargin: 10 * s
            height: 40 * s
            z: 6
            active: mprisSvc && mprisSvc.isPlaying && !parent.artHovered && coverArt.status !== Image.Ready
            waveColor: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent)
            opacity: 0.8
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.35)
            opacity: parent.artHovered ? 1 : 0
            visible: opacity > 0 && mprisSvc && mprisSvc.hasPlayer
            z: 5
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        Column {
            anchors.centerIn: parent
            spacing: 8 * s
            opacity: parent.artHovered ? 1 : 0
            visible: opacity > 0 && mprisSvc && mprisSvc.hasPlayer
            z: 10
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "♪"
                color: Theme.textPrimary
                font.pixelSize: 24 * s
                visible: coverArt.status !== Image.Ready
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: mprisSvc ? mprisSvc.identity : ""
                color: Theme.textPrimary
                font.family: Typography.fontFamily
                font.pixelSize: 9 * s
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                width: 120 * s
            }
        }
    }

    TrackInfo {
        id: trackInfo
        s: styleRoot.s
        primary: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textPrimary)
        player: styleRoot.activePlayer
        x: (5 * s) + styleRoot.contentOffsetX + styleRoot.mediaOffset
        opacity: 1 
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }
}
