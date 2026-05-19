import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import qs.config
import qs.components.elements

Rectangle {
    id: root

    Layout.fillWidth: true
    Layout.preferredHeight: Theme.dp(6) + artSize + Theme.dp(6)
    color: Theme.bgPrimary
    border.width: 1
    border.color: Theme.border
    radius: 0
    clip: true

    property var mprisService: null
    property real s: Scales.uiScale

    readonly property var activePlayer: mprisService ? mprisService.activePlayer : null
    readonly property int artRefreshCounter: mprisService ? mprisService.artRefreshCounter : 0
    readonly property string displayArtUrl: activePlayer && activePlayer.trackArtUrl
        ? activePlayer.trackArtUrl
        : ""
    readonly property string displayTitle: activePlayer
        ? (activePlayer.trackTitle || "")
        : ""
    readonly property string displayArtist: activePlayer
        ? (activePlayer.trackArtist || activePlayer.identity || "")
        : ""
    readonly property bool hasMedia: activePlayer != null && (displayTitle.length > 0 || displayArtist.length > 0 || displayArtUrl.length > 0)

    property string failedArtUrl: ""
    property string failedArtUrlBg: ""

    readonly property int artSize: Theme.dp(120)
    readonly property int pad: Theme.dp(6)
    readonly property int gap: Theme.dp(6)
    readonly property int rightX: pad + artSize + gap
    readonly property int rightW: width - rightX - pad
    readonly property int rowH: Math.floor(artSize / 5)
    readonly property int btnSz: Math.min(rowH - Theme.dp(4), Theme.dp(24))
    readonly property int iconSz: Math.round(btnSz * 0.55)

    Image {
        id: artBg
        anchors.fill: parent
        source: root.hasMedia && root.displayArtUrl && root.displayArtUrl !== root.failedArtUrlBg
            ? root.displayArtUrl + "?t=" + root.artRefreshCounter : ""
        fillMode: Image.PreserveAspectCrop
        visible: status === Image.Ready
        cache: false
        asynchronous: true
        opacity: 0.15
        onStatusChanged: {
            if (status === Image.Error) {
                root.failedArtUrlBg = root.displayArtUrl
                source = ""
            }
        }
    }
    Rectangle {
        anchors.fill: parent
        color: Theme.bgPrimary
        opacity: artBg.visible ? 0.7 : 1.0
    }

    Rectangle {
        id: artBox
        x: root.pad
        y: root.pad
        width: root.artSize
        height: root.artSize
        color: Theme.bgSecondary
        border.width: 1
        border.color: Theme.border
        radius: 0
        clip: true

        Image {
            id: art
            anchors.fill: parent
            source: root.hasMedia && root.displayArtUrl && root.displayArtUrl !== root.failedArtUrl
                ? root.displayArtUrl + "?t=" + root.artRefreshCounter : ""
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
            cache: false
            asynchronous: true
            sourceSize.width: root.artSize
            sourceSize.height: root.artSize
            onStatusChanged: {
                if (status === Image.Error) {
                    root.failedArtUrl = root.displayArtUrl
                    source = ""
                }
            }
        }
        Text {
            anchors.centerIn: parent
            visible: !art.visible
            text: "♪"
            color: Theme.textMuted
            font.pixelSize: Math.round(24 * s)
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            visible: root.activePlayer != null
            onClicked: {
                if (!root.activePlayer) return
                var identity = root.activePlayer.identity.toLowerCase()
                var desktopEntry = root.activePlayer.desktopEntry || ""
                var toplevels = Hyprland.toplevels.values
                for (var i = 0; i < toplevels.length; i++) {
                    var tl = toplevels[i]
                    if (!tl) continue
                    var appId = (tl.appId || "").toLowerCase()
                    var title = (tl.title || "").toLowerCase()
                    if (desktopEntry.length > 0 && appId.indexOf(desktopEntry.toLowerCase()) !== -1) {
                        if (tl.workspace) {
                            tl.workspace.activate()
                            return
                        }
                    }
                    if (identity.length > 0 && (title.indexOf(identity) !== -1 || appId.indexOf(identity) !== -1)) {
                        if (tl.workspace) {
                            tl.workspace.activate()
                            return
                        }
                    }
                }
                if (root.activePlayer.canRaise) root.activePlayer.raise()
            }
        }
    }

    MarqueeText {
        id: titleMarquee
        x: root.rightX
        y: root.pad
        width: root.rightW
        height: root.rowH
        text: root.hasMedia ? root.displayTitle : "🎵 Play something — try Spotify, YouTube Music, or your favorite tunes!"
        textColor: root.hasMedia ? Theme.textPrimary : Theme.accent
        fontSize: 10
        fontScale: s
        fontWeight: Typography.weightMedium || Font.Normal
        scrolling: true
        textPadding: 0
    }

    MarqueeText {
        id: artistMarquee
        x: root.rightX
        y: root.pad + root.rowH
        width: root.rightW
        height: root.rowH
        text: root.hasMedia ? root.displayArtist : "Your music, your vibe — hit play!"
        textColor: Theme.textMuted
        fontSize: 9
        fontScale: s
        fontWeight: Font.Normal
        scrolling: true
        textPadding: 0
    }

    Item {
        x: root.rightX
        y: root.pad + root.rowH * 2
        width: root.rightW
        height: root.rowH

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: Theme.dp(5)
            color: Theme.bgSecondary
            border.width: 1
            border.color: Theme.border
            radius: 0

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: root.activePlayer && root.activePlayer.length > 0
                    ? Math.max(0, Math.min(parent.width,
                        (root.activePlayer.position / root.activePlayer.length) * parent.width))
                    : 0
                color: Theme.accentSoft
                radius: 0
            }

            MouseArea {
                id: progressMouse
                anchors.fill: parent
                anchors.margins: -Theme.dp(4)
                enabled: root.activePlayer && root.activePlayer.canSeek
                cursorShape: Qt.SizeHorCursor
                property bool dragging: false
                onPressed: function(mouse) {
                    dragging = true
                    if (root.activePlayer && root.activePlayer.length > 0) {
                        root.activePlayer.position = (mouse.x / progressMouse.width) * root.activePlayer.length
                    }
                }
                onPositionChanged: function(mouse) {
                    if (dragging && root.activePlayer && root.activePlayer.length > 0) {
                        root.activePlayer.position = (mouse.x / progressMouse.width) * root.activePlayer.length
                    }
                }
                onReleased: dragging = false
            }
        }
    }

    Item {
        x: root.rightX
        y: root.pad + root.rowH * 3
        width: root.rightW
        height: root.rowH

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: root.activePlayer && root.activePlayer.positionSupported
                ? mprisService.formatTime(root.activePlayer.position)
                : "00:00"
            color: Theme.textMuted
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
        }
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.activePlayer && root.activePlayer.lengthSupported && root.activePlayer.length > 0
                ? mprisService.formatTime(root.activePlayer.length)
                : ""
            color: Theme.textMuted
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
        }
    }

    Item {
        id: controlRow
        x: root.rightX
        y: root.pad + root.rowH * 4
        width: root.rightW
        height: root.rowH

        readonly property int ctrlW: Math.round(root.btnSz * 1.5)
        readonly property int ctrlH: root.btnSz

        Row {
            anchors.centerIn: parent
            spacing: Math.max(Theme.dp(2),
                (controlRow.width - 6 * controlRow.ctrlW) / 7)

            Rectangle {
                width: controlRow.ctrlW; height: controlRow.ctrlH
                color: shuffleMouse.containsMouse
                    ? (root.activePlayer && root.activePlayer.shuffleSupported && root.activePlayer.shuffle
                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35)
                        : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                    : (root.activePlayer && root.activePlayer.shuffleSupported && root.activePlayer.shuffle
                        ? Theme.accentSoft : Theme.bgSecondary)
                border.width: 1
                border.color: root.activePlayer && root.activePlayer.shuffleSupported && root.activePlayer.shuffle
                    ? Theme.accent : Theme.border
                radius: 0
                opacity: root.activePlayer && root.activePlayer.shuffleSupported ? 1.0 : 0.35

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                IconShuffle {
                    anchors.centerIn: parent
                    iconColor: root.activePlayer && root.activePlayer.shuffle ? Theme.accent : Theme.textPrimary
                    iconSize: root.iconSz
                }
                MouseArea {
                    id: shuffleMouse
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    enabled: root.activePlayer && root.activePlayer.shuffleSupported && root.activePlayer.canControl
                    onClicked: root.activePlayer.shuffle = !root.activePlayer.shuffle
                }
            }

            Rectangle {
                width: controlRow.ctrlW; height: controlRow.ctrlH
                color: prevMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Theme.bgSecondary
                border.width: 1; border.color: prevMouse.containsMouse ? Theme.textPrimary : Theme.border; radius: 0
                opacity: root.activePlayer && root.activePlayer.canGoPrevious ? 1.0 : 0.35

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                IconSkipPrev {
                    anchors.centerIn: parent
                    iconColor: Theme.textPrimary
                    iconSize: root.iconSz
                }
                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: root.activePlayer && root.activePlayer.canGoPrevious ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: root.activePlayer && root.activePlayer.canGoPrevious
                    onClicked: root.activePlayer.previous()
                }
            }

            Rectangle {
                width: controlRow.ctrlW; height: controlRow.ctrlH
                color: playMouse.containsMouse
                    ? (root.activePlayer ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                    : (root.activePlayer ? Theme.accent : Theme.bgSecondary)
                border.width: 1
                border.color: root.activePlayer ? Theme.accent : (playMouse.containsMouse ? Theme.textPrimary : Theme.border)
                radius: 0
                opacity: root.activePlayer && root.activePlayer.canTogglePlaying ? 1.0 : 0.35

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                IconPlay {
                    anchors.centerIn: parent
                    iconColor: root.activePlayer ? Theme.bgPrimary : Theme.textPrimary
                    iconSize: root.iconSz
                    visible: !root.activePlayer || !root.activePlayer.isPlaying
                }
                IconPause {
                    anchors.centerIn: parent
                    iconColor: root.activePlayer ? Theme.bgPrimary : Theme.textPrimary
                    iconSize: root.iconSz
                    visible: root.activePlayer && root.activePlayer.isPlaying
                }
                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: root.activePlayer && root.activePlayer.canTogglePlaying ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: root.activePlayer && root.activePlayer.canTogglePlaying
                    onClicked: root.activePlayer.togglePlaying()
                }
            }

            Rectangle {
                width: controlRow.ctrlW; height: controlRow.ctrlH
                color: nextMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Theme.bgSecondary
                border.width: 1; border.color: nextMouse.containsMouse ? Theme.textPrimary : Theme.border; radius: 0
                opacity: root.activePlayer && root.activePlayer.canGoNext ? 1.0 : 0.35

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                IconSkipNext {
                    anchors.centerIn: parent
                    iconColor: Theme.textPrimary
                    iconSize: root.iconSz
                }
                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: root.activePlayer && root.activePlayer.canGoNext ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: root.activePlayer && root.activePlayer.canGoNext
                    onClicked: root.activePlayer.next()
                }
            }

            Rectangle {
                width: controlRow.ctrlW; height: controlRow.ctrlH
                color: loopMouse.containsMouse
                    ? (root.activePlayer && root.activePlayer.loopSupported
                        && root.activePlayer.loopState !== MprisLoopState.None
                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35)
                        : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                    : (root.activePlayer && root.activePlayer.loopSupported
                        && root.activePlayer.loopState !== MprisLoopState.None
                        ? Theme.accentSoft : Theme.bgSecondary)
                border.width: 1
                border.color: root.activePlayer && root.activePlayer.loopSupported
                    && root.activePlayer.loopState !== MprisLoopState.None
                    ? Theme.accent : Theme.border
                radius: 0
                opacity: root.activePlayer && root.activePlayer.loopSupported ? 1.0 : 0.35

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                IconLoop {
                    anchors.centerIn: parent
                    iconColor: root.activePlayer && root.activePlayer.loopState !== MprisLoopState.None
                        ? Theme.accent : Theme.textPrimary
                    iconSize: root.iconSz
                }
                MouseArea {
                    id: loopMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: root.activePlayer && root.activePlayer.loopSupported && root.activePlayer.canControl ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: root.activePlayer && root.activePlayer.loopSupported && root.activePlayer.canControl
                    onClicked: {
                        if (!root.activePlayer) return
                        switch (root.activePlayer.loopState) {
                            case MprisLoopState.None:     root.activePlayer.loopState = MprisLoopState.Playlist; break
                            case MprisLoopState.Playlist: root.activePlayer.loopState = MprisLoopState.Track;    break
                            default:                       root.activePlayer.loopState = MprisLoopState.None;    break
                        }
                    }
                }
            }

            Rectangle {
                width: controlRow.ctrlW; height: controlRow.ctrlH
                color: refreshMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12) : Theme.bgSecondary
                border.width: 1; border.color: refreshMouse.containsMouse ? Theme.textPrimary : Theme.border; radius: 0
                opacity: root.activePlayer ? 1.0 : 0.35

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                IconRefresh {
                    anchors.centerIn: parent
                    iconColor: Theme.textPrimary
                    iconSize: root.iconSz
                }
                MouseArea {
                    id: refreshMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: root.activePlayer ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: root.activePlayer != null
                    onClicked: {
                        if (root.mprisService) {
                            try { root.mprisService.refresh() } catch(e) {}
                        }
                    }
                }
            }
        }
    }
}
