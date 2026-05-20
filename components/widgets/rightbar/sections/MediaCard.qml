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
    readonly property string localArtPath: mprisService ? mprisService.localArtPath : ""
    readonly property string displayTitle: mprisService ? mprisService.title : ""
    readonly property string displayArtist: mprisService ? mprisService.artist : ""
    readonly property bool hasMedia: mprisService ? mprisService.hasPlayer : false

    readonly property string displayArtUrl: localArtPath !== ""
        ? "file://" + localArtPath
        : ""

    readonly property string desktopEntry: mprisService ? mprisService.desktopEntry : ""
    readonly property string identity: mprisService ? mprisService.identity : ""

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

    onLocalArtPathChanged: {
        root.artKey = root.displayArtUrl
        root.failedArtKey = ""
        root.failedArtKeyBg = ""
    }

    Image {
        id: artBg
        anchors.fill: parent
        source: root.hasMedia && root.displayArtUrl && root.displayArtUrl !== root.failedArtKeyBg
            ? root.displayArtUrl : ""
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

        onStatusChanged: {
            if (status === Image.Error) {
                root.failedArtKeyBg = root.displayArtUrl
                source = ""
            }
        }
    }
    Rectangle {
        anchors.fill: parent
        color: Theme.bgPrimary
        opacity: artBg.visible ? 0.6 : 1.0
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

        property bool artHovered: false

        Image {
            id: art
            anchors.fill: parent
            source: root.hasMedia && root.displayArtUrl && root.displayArtUrl !== root.failedArtKey
                ? root.displayArtUrl : ""
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
            cache: false
            asynchronous: true
            sourceSize.width: root.artSize
            sourceSize.height: root.artSize
            opacity: visible ? (parent.artHovered ? 0.35 : 1.0) : 0
            
            Behavior on source {
                SequentialAnimation {
                    NumberAnimation { target: art; property: "opacity"; to: 0; duration: 250; easing.type: Easing.OutCubic }
                    PropertyAction { target: art; property: "source" }
                    NumberAnimation { target: art; property: "opacity"; to: 1; duration: 250; easing.type: Easing.InCubic }
                }
            }

            onStatusChanged: {
                if (status === Image.Error) {
                    root.failedArtKey = root.displayArtUrl
                    source = ""
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
        Text {
            anchors.centerIn: parent
            visible: !art.visible && !parent.artHovered
            text: "♪"
            color: Theme.textMuted
            font.pixelSize: Math.round(24 * s)
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.35)
            opacity: parent.artHovered ? 1 : 0
            visible: opacity > 0 && root.hasMedia
            z: 5

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 4 * s
            width: parent.width - 8 * s
            opacity: parent.artHovered ? 1 : 0
            visible: opacity > 0 && root.hasMedia
            z: 10

            property bool iconLoaded: false

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            Image {
                id: appIcon
                anchors.horizontalCenter: parent.horizontalCenter
                width: 28 * s
                height: 28 * s
                source: {
                    var de = root.desktopEntry
                    if (de) {
                        var entry = DesktopEntries.byId(de)
                        if (entry && entry.icon) {
                            var p = Quickshell.iconPath(entry.icon, true)
                            if (p !== "") return p
                        }
                    }
                    return ""
                }
                visible: source !== "" && status === Image.Ready
                fillMode: Image.PreserveAspectFit
                onVisibleChanged: parent.iconLoaded = visible
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !parent.iconLoaded
                text: "♪"
                color: Theme.textPrimary
                font.pixelSize: 20 * s
            }

            Item {
                width: parent.width
                height: 14 * s
                clip: true

                TextMetrics {
                    id: identityMetrics
                    text: root.identity || ""
                    font.pixelSize: 8 * s
                    font.weight: Font.Bold
                    font.family: Typography.fontFamily
                }

                Text {
                    visible: identityMetrics.width <= parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.identity || ""
                    color: Theme.textPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: 8 * s
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                }

                Item {
                    visible: identityMetrics.width > parent.width
                    anchors.fill: parent
                    clip: true
                    property real offset: 0

                    Row {
                        id: identityScroll
                        spacing: 30
                        anchors.verticalCenter: parent.verticalCenter
                        x: parent.offset

                        Text {
                            text: root.identity || ""
                            color: Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: 8 * s
                            font.weight: Font.Bold
                        }
                        Text {
                            text: root.identity || ""
                            color: Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: 8 * s
                            font.weight: Font.Bold
                        }
                    }

                    NumberAnimation on offset {
                        from: 0
                        to: -(identityMetrics.width + 30)
                        duration: (identityMetrics.width + 30) * 50
                        loops: Animation.Infinite
                        running: identityMetrics.width > parent.width
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: root.activePlayer != null ? Qt.PointingHandCursor : Qt.ArrowCursor
            onEntered: parent.artHovered = true
            onExited: parent.artHovered = false
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

        readonly property int btnCount: 5
        readonly property int ctrlW: Math.floor((controlRow.width - (btnCount - 1) * Theme.dp(2)) / btnCount)
        readonly property int ctrlH: root.btnSz

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.dp(2)

            Rectangle {
                width: controlRow.ctrlW; height: controlRow.ctrlH
                color: shuffleMouse.containsMouse
                    ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12)
                    : Theme.bgSecondary
                border.width: 1
                border.color: shuffleMouse.containsMouse ? Theme.textPrimary : Theme.border
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
                    ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12)
                    : Theme.bgSecondary
                border.width: 1
                border.color: loopMouse.containsMouse ? Theme.textPrimary : Theme.border
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

                Rectangle {
                    visible: root.activePlayer && root.activePlayer.loopState === MprisLoopState.Track
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: Theme.dp(1)
                    width: Theme.dp(5)
                    height: Theme.dp(5)
                    radius: Theme.dp(2.5)
                    color: Theme.accent
                }

                Text {
                    visible: root.activePlayer && root.activePlayer.loopState === MprisLoopState.Playlist
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: -Theme.dp(1)
                    text: "1"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(7 * s)
                    font.weight: Font.Bold
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
        }
    }
}
