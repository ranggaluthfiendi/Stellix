import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Io
import QtCore

Item {
    id: root

    property var player: null
    property string title: ""
    property string artist: ""
    property string artUrl: ""
    property string localArtPath: ""
    property string identity: ""

    property bool hasMedia: title.length > 0
    property bool hasArt: localArtPath !== "" || artUrl !== ""

    property int targetWorkspace: 0

    property int artRefreshCounter: 0
    property string lastArtUrl: ""

    readonly property string artCacheDir: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata"
    readonly property string localArtFile: artCacheDir + "/nowplaying-cover.jpg"

    StdioCollector { id: artDownloadOut }

    Process {
        id: artDownload
        stdout: artDownloadOut
        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0) {
                root.localArtPath = root.localArtFile
                root.artRefreshCounter++
            }
        }
    }

    function downloadArt(url) {
        if (!url || url === "") {
            root.localArtPath = ""
            return
        }
        var escapedUrl = url.replace(/'/g, "'\\''")
        artDownload.exec(["sh", "-c", "mkdir -p '" + root.artCacheDir + "' && curl -fsSL --max-time 5 '" + escapedUrl + "' -o '" + root.localArtFile + "' 2>/dev/null"])
    }

    function cleanTitle(raw) {
        if (!raw) return ""
        var t = raw
        t = t.replace(/\s*-\s*YouTube\s*$/i, "")
        t = t.replace(/\s*\|\s*YouTube\s*$/i, "")
        t = t.replace(/\s*-\s*youtube\s*$/i, "")
        t = t.replace(/\s*\(\d+\)\s*$/i, "")
        t = t.replace(/^\(\d+\)\s*/, "")
        t = t.replace(/^\[\d+\]\s*/, "")
        t = t.replace(/^\d+\.\s*/, "")
        t = t.trim()
        return t
    }

    function extractArtistFromTitle(rawTitle) {
        if (!rawTitle) return ""
        var parts = rawTitle.split(/\s*-\s*/)
        if (parts.length >= 2) {
            var potential = parts[0].trim()
            if (potential.length > 0 && potential.toLowerCase() !== "unknown") {
                return potential
            }
        }
        return ""
    }

    function cleanArtist(raw, identity, rawTitle) {
        if (raw && raw.length > 0 && raw !== "Unknown" && raw !== "unknown") return raw

        var fromTitle = root.extractArtistFromTitle(rawTitle)
        if (fromTitle.length > 0) return fromTitle

        if (!identity) return ""
        var id = identity.toLowerCase()
        var isBrowser = (id.indexOf("firefox") >= 0 || id.indexOf("chrome") >= 0 || id.indexOf("brave") >= 0 || id.indexOf("chromium") >= 0 || id.indexOf("edge") >= 0 || id.indexOf("plasma-browser") >= 0)
        if (isBrowser) return ""
        return identity
    }

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

        if (root.player !== found) {
            playerConn.target = found
            root.player = found
            root.updateIdentity()
        }
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
            if (root.artist !== "") root.artist = ""
            if (root.artUrl !== "") root.artUrl = ""
            root.localArtPath = ""
            root.targetWorkspace = 0
            root.lastArtUrl = ""
            return
        }

        let rawTitle = root.player.trackTitle || ""
        let newTitle = root.cleanTitle(rawTitle)
        let newArtist = root.cleanArtist(root.player.trackArtist || "", root.player.identity || "", rawTitle)
        let newArt = root.player.trackArtUrl || ""

        if (root.title !== newTitle)
            root.title = newTitle

        if (root.artist !== newArtist)
            root.artist = newArtist

        if (root.artUrl !== newArt) {
            root.artUrl = newArt
            if (newArt !== "" && newArt !== root.lastArtUrl) {
                root.lastArtUrl = newArt
                root.downloadArt(newArt)
            } else if (newArt === "") {
                root.localArtPath = ""
            }
        }

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

    Connections {
        id: playerConn
        target: null
        ignoreUnknownSignals: true

        function onIsPlayingChanged() {
            if (root.player && root.player.isPlaying) root.pickPlayer()
            root.updateState()
        }
        function onTrackChanged() { root.updateState() }
        function onPostTrackChanged() {
            Qt.callLater(function() {
                Qt.callLater(function() {
                    root.updateState()
                })
            })
        }
        function onTrackArtUrlChanged() {
            Qt.callLater(function() {
                Qt.callLater(function() {
                    if (root.player && root.player.trackArtUrl) {
                        var newUrl = root.player.trackArtUrl
                        if (newUrl !== root.lastArtUrl) {
                            root.lastArtUrl = newUrl
                            root.downloadArt(newUrl)
                        }
                    }
                })
            })
        }
        function onPlaybackStateChanged() { root.pickPlayer() }
        function onTrackTitleChanged() { root.updateState() }
        function onTrackArtistChanged() { root.updateState() }
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

    Component.onCompleted: {
        root.pickPlayer()
        root.updateState()
    }
}
