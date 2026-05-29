import qs.components.utils
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import qs.config
import qs.components.elements
import qs.core.state

Rectangle {
    id: root

    Layout.fillWidth: true
    Layout.preferredHeight: Theme.dp(6) + artSize + Theme.dp(6)
    color: resolveColor(BarLayoutState.desktopNowPlayingBgColorMode, Theme.bgPrimary)
    border.width: 1
    border.color: resolveColor(BarLayoutState.desktopNowPlayingBorderColorMode, Theme.border)
    radius: 0
    clip: true

    property var mprisService: null
    property real s: Scales.uiScale

    readonly property var activePlayer: mprisService ? mprisService.activePlayer : null
    readonly property bool hasMedia: mprisService ? mprisService.hasPlayer : false

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

    readonly property string displayArtUrl: {
        if (mprisService && mprisService.artUrl && mprisService.artUrl !== "") return mprisService.artUrl
        return mprisService ? mprisService.persistentArtUrl : ""
    }

    readonly property int artSize: Theme.dp(120)
    readonly property int pad: Theme.dp(6)
    readonly property int gap: Theme.dp(6)
    readonly property int rightX: pad + artSize + gap
    readonly property int rightW: width - rightX - pad
    readonly property int rowH: Math.floor(artSize / 5)
    readonly property int btnSz: Math.min(rowH - Theme.dp(4), Theme.dp(24))
    readonly property int iconSz: Math.round(btnSz * 0.55)

    property string artKey: ""
    property string failedArtKey: ""
    property string failedArtKeyBg: ""

    onDisplayArtUrlChanged: {
        root.artKey = root.displayArtUrl
        root.failedArtKey = ""
        root.failedArtKeyBg = ""
    }

    Image {
        id: artBg
        anchors.fill: parent
        source: (root.displayArtUrl && root.displayArtUrl !== root.failedArtKeyBg) ? root.displayArtUrl : ""
        fillMode: Image.PreserveAspectCrop
        visible: status === Image.Ready
        cache: false
        asynchronous: true
        opacity: 0.25
        
        Behavior on source {
            SequentialAnimation {
                NumberAnimation { target: artBg; property: "opacity"; to: 0; duration: 250; easing.type: Easing.OutCubic }
                PropertyAction { target: artBg; property: "source" }
                NumberAnimation { target: artBg; property: "opacity"; to: 0.25; duration: 250; easing.type: Easing.InCubic }
            }
        }
        onStatusChanged: if (status === Image.Error) { root.failedArtKeyBg = root.displayArtUrl; source = "" }
    }

    Rectangle {
        anchors.fill: parent
        color: resolveColor(BarLayoutState.desktopNowPlayingBgColorMode, Theme.bgPrimary)
        opacity: artBg.visible ? 0.6 : 1.0
    }

    WaveVisualizer {
        id: wave
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.dp(4)
        height: Theme.dp(36)
        active: root.hasMedia && root.activePlayer && root.activePlayer.isPlaying
        waveColor: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent)
        opacity: 0.35
        z: 0
    }

    Rectangle {
        id: artBox
        x: root.pad; y: root.pad; width: root.artSize; height: root.artSize
        color: resolveColor(BarLayoutState.desktopNowPlayingBgColorMode, Theme.bgSecondary)
        border.width: 1; border.color: resolveColor(BarLayoutState.desktopNowPlayingBorderColorMode, Theme.border)
        radius: 0; clip: true
        property bool artHovered: false

        Image {
            id: art
            anchors.fill: parent
            source: (root.displayArtUrl && root.displayArtUrl !== root.failedArtKey) ? root.displayArtUrl : ""
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready; cache: false; asynchronous: true
            sourceSize.width: root.artSize; sourceSize.height: root.artSize
            opacity: visible ? (parent.artHovered ? 0.35 : 1.0) : 0
            Behavior on source {
                SequentialAnimation {
                    NumberAnimation { target: art; property: "opacity"; to: 0; duration: 250; easing.type: Easing.OutCubic }
                    PropertyAction { target: art; property: "source" }
                    NumberAnimation { target: art; property: "opacity"; to: 1; duration: 250; easing.type: Easing.InCubic }
                }
            }
            onStatusChanged: if (status === Image.Error) { root.failedArtKey = root.displayArtUrl; source = "" }
        }
        Text { anchors.centerIn: parent; visible: !art.visible; text: "♪"; color: Theme.textMuted; font.pixelSize: Math.round(24 * s) }
        Rectangle { anchors.fill: parent; color: Qt.rgba(0,0,0,0.35); opacity: parent.artHovered ? 1 : 0; visible: opacity > 0 && root.hasMedia; z: 5 }
        
        MouseArea {
            anchors.fill: parent; hoverEnabled: true; cursorShape: root.activePlayer != null ? Qt.PointingHandCursor : Qt.ArrowCursor
            onEntered: parent.artHovered = true; onExited: parent.artHovered = false
            onClicked: if (root.activePlayer && root.activePlayer.canRaise) root.activePlayer.raise()
        }
    }

    MarqueeText {
        id: titleMarquee; x: root.rightX; y: root.pad; width: root.rightW; height: root.rowH
        text: root.hasMedia ? (mprisService ? mprisService.title : "") : "Play something!"
        textColor: root.hasMedia ? resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textPrimary) : resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accent)
        fontSize: 10; fontScale: s; scrolling: true
    }

    MarqueeText {
        id: artistMarquee; x: root.rightX; y: root.pad + root.rowH; width: root.rightW; height: root.rowH
        text: root.hasMedia ? (mprisService ? mprisService.artist : "") : "Your music, your vibe!"
        textColor: resolveColor(BarLayoutState.desktopNowPlayingTextColorMode, Theme.textMuted)
        fontSize: 9; fontScale: s; scrolling: true
    }

    Rectangle {
        x: root.rightX; y: root.pad + root.rowH * 2.5 - 2.5; width: root.rightW; height: Theme.dp(5)
        anchors.verticalCenter: undefined
        color: resolveColor(BarLayoutState.desktopNowPlayingBgColorMode, Theme.bgSecondary)
        border.width: 1; border.color: resolveColor(BarLayoutState.desktopNowPlayingBorderColorMode, Theme.border)
        Rectangle {
            anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
            width: (mprisService && mprisService.length > 0) ? (mprisService.position / mprisService.length) * parent.width : 0
            color: resolveColor(BarLayoutState.desktopNowPlayingAccentColorMode, Theme.accentSoft)
        }
        MouseArea {
            anchors.fill: parent; anchors.margins: -4; enabled: root.activePlayer && root.activePlayer.canSeek
            onPressed: (mouse) => { if (root.activePlayer && mprisService.length > 0) root.activePlayer.position = (mouse.x / width) * mprisService.length }
        }
    }

    Row {
        x: root.rightX; y: root.pad + root.rowH * 3.5; spacing: Theme.dp(2)
        Repeater {
            model: 5
            delegate: Rectangle {
                width: Math.floor((root.rightW - 8) / 5); height: root.btnSz
                color: mouse.containsMouse ? resolveColor(BarLayoutState.desktopNowPlayingBorderColorMode, Theme.border) : resolveColor(BarLayoutState.desktopNowPlayingBgColorMode, Theme.bgSecondary)
                radius: 0; border.width: 1; border.color: mouse.containsMouse ? Theme.textPrimary : Theme.border
                Loader {
                    anchors.centerIn: parent
                    sourceComponent: index === 0 ? shuffleI : index === 1 ? prevI : index === 2 ? playI : index === 3 ? nextI : loopI
                }
                MouseArea {
                    id: mouse; anchors.fill: parent; hoverEnabled: true
                    onClicked: {
                        if (!root.activePlayer) return
                        if (index === 0) root.activePlayer.shuffle = !root.activePlayer.shuffle
                        else if (index === 1) root.activePlayer.previous()
                        else if (index === 2) root.activePlayer.togglePlaying()
                        else if (index === 3) root.activePlayer.next()
                        else if (index === 4) {
                            if (root.activePlayer.loopState === MprisLoopState.None) root.activePlayer.loopState = MprisLoopState.Playlist
                            else if (root.activePlayer.loopState === MprisLoopState.Playlist) root.activePlayer.loopState = MprisLoopState.Track
                            else root.activePlayer.loopState = MprisLoopState.None
                        }
                    }
                }
            }
        }
    }

    Component {
        id: shuffleI
        IconShuffle {
            iconSize: root.iconSz
            iconColor: (root.activePlayer && root.activePlayer.shuffle) ? Theme.accent : Theme.textPrimary
        }
    }
    Component {
        id: prevI
        IconSkipPrev {
            iconSize: root.iconSz
            iconColor: Theme.textPrimary
        }
    }
    Component {
        id: playI
        Item {
            width: root.iconSz
            height: root.iconSz
            IconPlay {
                anchors.fill: parent
                iconColor: Theme.textPrimary
                visible: !root.activePlayer || !root.activePlayer.isPlaying
            }
            IconPause {
                anchors.fill: parent
                iconColor: Theme.textPrimary
                visible: root.activePlayer && root.activePlayer.isPlaying
            }
        }
    }
    Component {
        id: nextI
        IconSkipNext {
            iconSize: root.iconSz
            iconColor: Theme.textPrimary
        }
    }
    Component {
        id: loopI
        IconLoop {
            iconSize: root.iconSz
            iconColor: (root.activePlayer && root.activePlayer.loopState !== MprisLoopState.None) ? Theme.accent : Theme.textPrimary
        }
    }
}
