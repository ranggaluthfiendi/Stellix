import QtQuick
import qs.config
import Quickshell.Services.Mpris

Item {
    id: root

    property real s
    property color primary

    required property var player

    property string trackTitle: ""
    property string artist: ""

    function updateTrack() {
        let t = player && player.trackTitle ? player.trackTitle : "No Track"
        let a = player && player.trackArtist ? player.trackArtist : "No Artist"

        if (trackTitle !== t) {
            trackTitle = t
            titleWrap.scroll = 0
        }

        if (artist !== a) {
            artist = a
            artistWrap.scroll = 0
        }
    }

    onPlayerChanged: updateTrack()

    Connections {
        target: root.player ? root.player : null
        function onTrackChanged() { root.updateTrack() }
        function onPostTrackChanged() { root.updateTrack() }
        function onPlaybackStateChanged() { root.updateTrack() }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: root.updateTrack()
    }

    Component.onCompleted: updateTrack()

    Rectangle {
        id: coverBox
        x: 212 * s
        y: 38 * s

        width: 20 * s
        height: 20 * s
        color: primary

        opacity: 0.9

        SequentialAnimation on opacity {
            running: true
            loops: Animation.Infinite

            // offset supaya tidak bareng dengan arrow
            PauseAnimation { duration: 450 }

            NumberAnimation {
                from: 0.9
                to: 0.55
                duration: 1200
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                from: 0.55
                to: 0.9
                duration: 1200
                easing.type: Easing.InOutQuad
            }
        }
    }

    Item {
        id: titleWrap
        x: 245 * s
        y: 24 * s
        width: 350 * s
        height: 24 * s
        clip: true

        property real scroll: 0
        property real speed: 20
        property real gap: 60 * s

        readonly property bool overflow: title1.width > width
        readonly property real total: title1.width + gap

        Text {
            id: title1
            text: trackTitle
            color: primary
            font.family: Typography.fontFamily
            font.pixelSize: Typography.sizeLG * s
            x: -titleWrap.scroll
        }

        Text {
            text: trackTitle
            color: primary
            font.family: Typography.fontFamily
            font.pixelSize: Typography.sizeLG * s
            x: title1.width + titleWrap.gap - titleWrap.scroll
            visible: titleWrap.overflow
        }

        NumberAnimation on scroll {
            running: titleWrap.overflow
            loops: Animation.Infinite
            from: 0
            to: titleWrap.total
            duration: (titleWrap.total / titleWrap.speed) * 1000
            easing.type: Easing.Linear
        }
    }

    Item {
        id: artistWrap
        x: 245 * s
        y: 50 * s
        width: 350 * s
        height: 20 * s
        clip: true

        property real scroll: 0
        property real speed: 20
        property real gap: 60 * s

        readonly property bool overflow: artist1.width > width
        readonly property real total: artist1.width + gap

        Text {
            id: artist1
            text: artist
            color: primary
            font.family: Typography.fontFamily
            font.pixelSize: Typography.sizeMD * s
            font.weight: Typography.weightBold
            x: -artistWrap.scroll
        }

        Text {
            text: artist
            color: primary
            font.family: Typography.fontFamily
            font.pixelSize: Typography.sizeMD * s
            font.weight: Typography.weightBold
            x: artist1.width + artistWrap.gap - artistWrap.scroll
            visible: artistWrap.overflow
        }

        NumberAnimation on scroll {
            running: artistWrap.overflow
            loops: Animation.Infinite
            from: 0
            to: artistWrap.total
            duration: (artistWrap.total / artistWrap.speed) * 1000
            easing.type: Easing.Linear
        }
    }
    property real contentWidth: {
        let t = title1.width
        let a = artist1.width
        let w = Math.max(t, a)
        return (w > 0 ? w : 200 * s) + 100 * s
    }
}
