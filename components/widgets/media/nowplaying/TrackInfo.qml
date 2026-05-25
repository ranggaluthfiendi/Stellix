import qs.components.utils
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

    function cleanTitle(raw) {
        if (!raw) return ""
        var t = raw
        t = t.replace(/\s*-\s*YouTube\s*$/i, "")
        t = t.replace(/\s*\|\s*YouTube\s*$/i, "")
        t = t.replace(/\s*\(\d+\)\s*$/i, "")
        t = t.replace(/^\(\d+\)\s*/, "")
        t = t.replace(/^\[\d+\]\s*/, "")
        t = t.replace(/^\d+\.\s*/, "")
        return t.trim()
    }

    function cleanArtist(raw, identity) {
        if (raw && raw.length > 0 && raw !== "Unknown" && raw !== "unknown") return raw
        if (!identity) return ""
        var id = identity.toLowerCase()
        if (id.indexOf("firefox") >= 0 || id.indexOf("chrome") >= 0 || id.indexOf("brave") >= 0 || id.indexOf("chromium") >= 0 || id.indexOf("edge") >= 0) {
            return ""
        }
        return identity
    }

    function updateTrack() {
        if (!player) {
            trackTitle = ""
            artist = ""
            return
        }
        trackTitle = cleanTitle(player.trackTitle || "")
        artist = cleanArtist(player.trackArtist || "", player.identity || "")
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
        function onPostTrackChanged() {
            Qt.callLater(function() { root.updateTrack() })
        }
        function onPlaybackStateChanged() { root.syncPlayback() }
        function onTrackTitleChanged() { root.updateTrack() }
        function onTrackArtistChanged() { root.updateTrack() }
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
        width: 300 * s
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
        width: 300 * s
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
}
