import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris

Item {
    id: root

    property var player: null
    property string title: ""
    property string artUrl: ""
    property string identity: ""

    property bool hasMedia: title.length > 0
    property bool hasArt: artUrl !== ""

    property int targetWorkspace: 0

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
        root.updateIdentity()
    }

    function updateIdentity() {
        if (root.player) {
            root.identity = root.player.identity || ""
        } else {
            root.identity = ""
        }
    }

    function updateState() {
        if (!root.player) {
            if (root.title !== "") root.title = ""
            if (root.artUrl !== "") root.artUrl = ""
            root.targetWorkspace = 0
            return
        }

        let newTitle = root.player.trackTitle || ""
        let newArt = root.player.trackArtUrl || ""

        if (root.title !== newTitle)
            root.title = newTitle

        if (root.artUrl !== newArt)
            root.artUrl = newArt

        root.findMediaWorkspace()
    }

    function findMediaWorkspace() {
        root.targetWorkspace = 0
        if (!root.player || !root.identity) return

        let appName = root.identity.toLowerCase()
        let toplevels = Hyprland.toplevels ? Hyprland.toplevels.values : []

        for (let i = 0; i < toplevels.length; i++) {
            let tl = toplevels[i]
            if (!tl || !tl.workspace) continue

            let tlClass = (tl.initialClass || "").toLowerCase()
            let tlTitle = (tl.title || "").toLowerCase()
            let tlApp = (tl.appId || "").toLowerCase()

            if (tlClass.indexOf(appName) >= 0 || tlTitle.indexOf(appName) >= 0 || tlApp.indexOf(appName) >= 0) {
                root.targetWorkspace = tl.workspace.id
                return
            }
        }
    }

    function goToMediaWorkspace() {
        if (root.targetWorkspace > 0) {
            Hyprland.dispatch("workspace " + root.targetWorkspace)
        }
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
