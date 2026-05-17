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
        : (mprisService ? mprisService.cachedArtUrl : "")
    readonly property string displayTitle: activePlayer
        ? (activePlayer.trackTitle || "No title")
        : (mprisService && mprisService.cachedTitle ? mprisService.cachedTitle : "")
    readonly property string displayArtist: activePlayer
        ? (activePlayer.trackArtist || activePlayer.identity || "")
        : (mprisService && mprisService.cachedArtist ? mprisService.cachedArtist : "")
    readonly property bool hasMedia: activePlayer != null || displayArtUrl.length > 0 || displayTitle.length > 0

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
        source: root.displayArtUrl
            ? root.displayArtUrl + "?t=" + root.artRefreshCounter : ""
        fillMode: Image.PreserveAspectCrop
        visible: status === Image.Ready
        cache: false
        asynchronous: true
        opacity: 0.15
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
            source: root.displayArtUrl
                ? root.displayArtUrl + "?t=" + root.artRefreshCounter : ""
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
            cache: false
            asynchronous: true
            sourceSize.width: root.artSize
            sourceSize.height: root.artSize
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

    Item {
        x: root.rightX
        y: root.pad
        width: root.rightW
        height: root.rowH
        clip: true

        Text {
            id: titleText
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            text: root.hasMedia ? root.displayTitle : "🎵 Play something — try Spotify, YouTube Music, or your favorite tunes!"
            color: root.hasMedia ? Theme.textPrimary : Theme.accent
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
            font.weight: Typography.weightMedium || Font.Normal
            elide: Text.ElideNone
        }

        NumberAnimation {
            id: titleScroll
            target: titleText
            property: "x"
            from: 0
            to: -(titleText.implicitWidth - parent.width + Theme.dp(4))
            duration: Math.max(4000, titleText.implicitWidth * 60)
            easing.type: Easing.Linear
            loops: Animation.Infinite
            running: root.hasMedia && titleText.implicitWidth > parent.width
        }
        onWidthChanged: {
            titleScroll.stop()
            titleText.x = 0
            if (titleText.implicitWidth > width)
                titleScroll.start()
        }
    }

    Item {
        x: root.rightX
        y: root.pad + root.rowH
        width: root.rightW
        height: root.rowH
        clip: true

        Text {
            id: artistText
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            text: root.hasMedia ? root.displayArtist : "Your music, your vibe — hit play!"
            color: root.hasMedia ? Theme.textMuted : Theme.textMuted
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
            elide: Text.ElideNone
        }

        NumberAnimation {
            target: artistText
            property: "x"
            from: 0
            to: -(artistText.implicitWidth - parent.width + Theme.dp(4))
            duration: Math.max(4000, artistText.implicitWidth * 60)
            easing.type: Easing.Linear
            loops: Animation.Infinite
            running: root.hasMedia && artistText.implicitWidth > parent.width
        }
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

        readonly property int ctrlW: Math.round(root.btnSz * 1.6)
        readonly property int ctrlH: root.btnSz

        Row {
            anchors.centerIn: parent
            spacing: Math.max(Theme.dp(2),
                (controlRow.width - 5 * controlRow.ctrlW) / 6)

            Rectangle {
                width: controlRow.ctrlW; height: controlRow.ctrlH
                color: root.activePlayer && root.activePlayer.shuffleSupported && root.activePlayer.shuffle
                    ? Theme.accentSoft : Theme.bgSecondary
                border.width: 1
                border.color: root.activePlayer && root.activePlayer.shuffleSupported && root.activePlayer.shuffle
                    ? Theme.accent : Theme.border
                radius: 0
                opacity: root.activePlayer && root.activePlayer.shuffleSupported ? 1.0 : 0.35

                Text {
                    anchors.centerIn: parent
                    text: "⇄"
                    color: root.activePlayer && root.activePlayer.shuffle ? Theme.accent : Theme.textPrimary
                    font.pixelSize: Math.round(8 * s)
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    enabled: root.activePlayer && root.activePlayer.shuffleSupported && root.activePlayer.canControl
                    onClicked: root.activePlayer.shuffle = !root.activePlayer.shuffle
                }
            }

            Rectangle {
                width: controlRow.ctrlW; height: controlRow.ctrlH
                color: Theme.bgSecondary
                border.width: 1; border.color: Theme.border; radius: 0
                opacity: root.activePlayer && root.activePlayer.canGoPrevious ? 1.0 : 0.35

                IconSkipPrev {
                    anchors.centerIn: parent
                    iconColor: Theme.textPrimary
                    iconSize: root.iconSz
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: root.activePlayer && root.activePlayer.canGoPrevious ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: root.activePlayer && root.activePlayer.canGoPrevious
                    onClicked: root.activePlayer.previous()
                }
            }

            Rectangle {
                width: controlRow.ctrlW; height: controlRow.ctrlH
                color: root.activePlayer ? Theme.accent : Theme.bgSecondary
                border.width: 1
                border.color: root.activePlayer ? Theme.accent : Theme.border
                radius: 0
                opacity: root.activePlayer && root.activePlayer.canTogglePlaying ? 1.0 : 0.35

                IconPlay {
                    anchors.centerIn: parent
                    iconColor: "white"
                    iconSize: root.iconSz
                    visible: !root.activePlayer || !root.activePlayer.isPlaying
                }
                IconPause {
                    anchors.centerIn: parent
                    iconColor: "white"
                    iconSize: root.iconSz
                    visible: root.activePlayer && root.activePlayer.isPlaying
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: root.activePlayer && root.activePlayer.canTogglePlaying ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: root.activePlayer && root.activePlayer.canTogglePlaying
                    onClicked: root.activePlayer.togglePlaying()
                }
            }

            Rectangle {
                width: controlRow.ctrlW; height: controlRow.ctrlH
                color: Theme.bgSecondary
                border.width: 1; border.color: Theme.border; radius: 0
                opacity: root.activePlayer && root.activePlayer.canGoNext ? 1.0 : 0.35

                IconSkipNext {
                    anchors.centerIn: parent
                    iconColor: Theme.textPrimary
                    iconSize: root.iconSz
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: root.activePlayer && root.activePlayer.canGoNext ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: root.activePlayer && root.activePlayer.canGoNext
                    onClicked: root.activePlayer.next()
                }
            }

            Rectangle {
                width: controlRow.ctrlW; height: controlRow.ctrlH
                color: root.activePlayer && root.activePlayer.loopSupported
                    && root.activePlayer.loopState !== MprisLoopState.None
                    ? Theme.accentSoft : Theme.bgSecondary
                border.width: 1
                border.color: root.activePlayer && root.activePlayer.loopSupported
                    && root.activePlayer.loopState !== MprisLoopState.None
                    ? Theme.accent : Theme.border
                radius: 0
                opacity: root.activePlayer && root.activePlayer.loopSupported ? 1.0 : 0.35

                Text {
                    anchors.centerIn: parent
                    text: root.activePlayer && root.activePlayer.loopState === MprisLoopState.Track
                        ? "1↺" : "↺"
                    color: root.activePlayer && root.activePlayer.loopState !== MprisLoopState.None
                        ? Theme.accent : Theme.textPrimary
                    font.pixelSize: Math.round(8 * s)
                    font.bold: root.activePlayer && root.activePlayer.loopState === MprisLoopState.Track
                }
                MouseArea {
                    anchors.fill: parent
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
        }
    }
}
