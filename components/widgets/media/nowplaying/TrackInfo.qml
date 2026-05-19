import QtQuick
import QtQuick.Shapes
import qs.config
import qs.components.elements
import Quickshell.Services.Mpris

Item {
    id: root

    property real s: Scales.uiScale * 0.6
    property color primary
    required property var player

    property string trackTitle: ""
    property string artist: ""

    property bool isPlaying: false

    function updateTrack() {
        trackTitle = player && player.trackTitle ? player.trackTitle : "No Track"
        artist = player && player.trackArtist ? player.trackArtist : "No Artist"
    }

    function syncPlayback() {
        if (!player) {
            isPlaying = false
            return
        }

        let newState = player.isPlaying === true

        if (isPlaying !== newState) {
            isPlaying = newState
        }
    }

    onPlayerChanged: {
        playerConn.target = null
        playerConn.target = root.player
        updateTrack()
        syncPlayback()
    }

    Connections {
        id: playerConn
        target: root.player
        ignoreUnknownSignals: true

        function onTrackChanged() { root.updateTrack() }
        function onPlaybackStateChanged() { root.syncPlayback() }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: root.syncPlayback()
    }

    Component.onCompleted: {
        updateTrack()
        syncPlayback()
    }

    Item {
        id: controlBox

        x: 212 * s
        y: 38 * s

        width: 20 * s
        height: 20 * s

        Rectangle {
            anchors.fill: parent
            color: ctrlMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : "transparent"
            radius: 4 * s

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
        }

        MouseArea {
            id: ctrlMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                if (!root.player || !root.player.canControl)
                    return

                if (root.isPlaying)
                    root.player.pause()
                else
                    root.player.play()

                root.syncPlayback()
            }
        }

        Item {
            width: 12 * s
            height: 12 * s

            x: (controlBox.width - width) / 2
            y: (controlBox.height - height) / 2

            Canvas {
                anchors.fill: parent
                visible: !root.isPlaying

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    ctx.fillStyle = ctrlMouse.containsMouse ? Theme.accent : Theme.textPrimary
                    ctx.beginPath()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(width, height / 2)
                    ctx.lineTo(0, height)
                    ctx.closePath()
                    ctx.fill()
                }
            }

            Row {
                anchors.fill: parent
                spacing: width * 0.2
                visible: root.isPlaying

                Rectangle {
                    width: parent.width * 0.35
                    height: parent.height
                    color: ctrlMouse.containsMouse ? Theme.accent : Theme.textPrimary
                    radius: 1 * s
                }

                Rectangle {
                    width: parent.width * 0.35
                    height: parent.height
                    color: ctrlMouse.containsMouse ? Theme.accent : Theme.textPrimary
                    radius: 1 * s
                }
            }
        }
    }

    MarqueeText {
        id: titleMarquee
        x: 245 * s
        y: 24 * s
        width: 350 * s
        height: 28 * s
        text: root.trackTitle
        textColor: root.primary
        fontSize: 12
        fontScale: Scales.uiScale
        fontWeight: Font.Normal
        scrolling: true
        textPadding: 0
    }

    MarqueeText {
        id: artistMarquee
        x: 245 * s
        y: 52 * s
        width: 350 * s
        height: 24 * s
        text: root.artist
        textColor: root.primary
        fontSize: 10
        fontScale: Scales.uiScale
        fontWeight: Font.Bold
        scrolling: true
        textPadding: 0
    }

    property real contentWidth: {
        let w = Math.max(titleMarquee.textWidth, artistMarquee.textWidth)
        return (w > 0 ? w : 200 * s) + 140 * s
    }

    // ── App Launcher Button ──
    Rectangle {
        x: 245 * s + Math.max(titleMarquee.textWidth, artistMarquee.textWidth) + 20 * s
        y: 30 * s
        width: appLbl.implicitWidth + 16 * s
        height: 22 * s
        color: appBtnMouse.containsMouse ? Theme.accent : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.6)
        border.width: 1
        border.color: appBtnMouse.containsMouse ? Theme.accent : Theme.border
        radius: 4 * s
        visible: root.player && root.player.identity && root.player.identity !== ""

        Text {
            id: appLbl
            anchors.centerIn: parent
            text: "▶ " + root.player.identity
            color: appBtnMouse.containsMouse ? Theme.bgPrimary : Theme.textMuted
            font.family: Typography.fontFamily
            font.pixelSize: Typography.sizeXXS
            font.weight: Font.Bold
        }

        MouseArea {
            id: appBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.player && root.player.canRaise) {
                    root.player.raise()
                }
            }
        }
    }
}
