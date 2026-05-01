import QtQuick
import Quickshell.Services.Mpris

Item {
    id: root

    property var player: null
    property string title: ""
    property string artUrl: ""

    property bool hasMedia: title.length > 0
    property bool hasArt: artUrl !== ""

    function pickPlayer() {
        let found = null

        for (let p of Mpris.players.values) {
            if (p.isPlaying) {
                found = p
                break
            }
        }

        if (!found && Mpris.players.values.length > 0) {
            found = Mpris.players.values[0]
        }

        root.player = found
    }

    function updateState() {
        if (!root.player) {
            if (root.title !== "") root.title = ""
            if (root.artUrl !== "") root.artUrl = ""
            return
        }

        let newTitle = root.player.trackTitle || ""
        let newArt = root.player.trackArtUrl || ""

        if (root.title !== newTitle)
            root.title = newTitle

        if (root.artUrl !== newArt)
            root.artUrl = newArt
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            root.pickPlayer()
            root.updateState()
        }
    }

    Connections {
        target: root.player ? root.player : null

        function onTrackChanged() { root.updateState() }
        function onPostTrackChanged() { root.updateState() }
        function onTrackArtUrlChanged() { root.updateState() }
        function onPlaybackStateChanged() { root.pickPlayer() }
    }

    Component.onCompleted: {
        root.pickPlayer()
        root.updateState()
    }
}
