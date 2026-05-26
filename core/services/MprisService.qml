import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Io
import QtCore
import qs.config

Item {
    id: root

    property var activePlayer: null

    property string title: ""
    property string artist: ""
    property string artUrl: ""
    property string localArtPath: ""
    property string desktopEntry: ""
    property string identity: ""
    property bool isPlaying: false
    property bool hasPlayer: false
    property real position: 0
    property real length: 0
    property int artRefreshCounter: 0
    property string lastArtUrl: ""

    property int targetWorkspace: 0

    function findMediaWorkspace() {
        root.targetWorkspace = 0
        if (!root.activePlayer || !root.identity) return

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

    readonly property string artCacheDir: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata"
    readonly property string localArtFile: artCacheDir + "/current-cover.jpg"
    readonly property string localTitleFile: artCacheDir + "/current-title.txt"
    readonly property string localArtistFile: artCacheDir + "/current-artist.txt"
    readonly property string persistentArtUrl: "file://" + localArtFile

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
            return
        }
        var escapedUrl = url.replace(/'/g, "'\\''")
        artDownload.exec(["sh", "-c", "mkdir -p '" + root.artCacheDir + "' && curl -fsSL --max-time 5 '" + escapedUrl + "' -o '" + root.localArtFile + "' 2>/dev/null"])
    }

    // Persist Title and Artist
    Process { id: persistMeta }

    function saveMetadata(t, a) {
        if (!t || t === "") return
        var safeTitle = t.replace(/'/g, "'\\''")
        var safeArtist = a.replace(/'/g, "'\\''")
        persistMeta.exec(["sh", "-c", "mkdir -p '" + root.artCacheDir + "' && echo '" + safeTitle + "' > '" + root.localTitleFile + "' && echo '" + safeArtist + "' > '" + root.localArtistFile + "'"])
    }

    StdioCollector {
        id: metaLoader
        onStreamFinished: {
            var lines = this.text.split("\n")
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i]
                if (line.startsWith("TITLE:")) {
                    if (root.title === "") root.title = line.substring(6).trim()
                } else if (line.startsWith("ARTIST:")) {
                    if (root.artist === "") root.artist = line.substring(7).trim()
                }
            }
        }
    }

    Process {
        id: metaLoadProc
        stdout: metaLoader
    }

    function loadMetadata() {
        metaLoadProc.exec(["sh", "-c", "printf 'TITLE:'; cat '" + root.localTitleFile + "' 2>/dev/null; printf '\\nARTIST:'; cat '" + root.localArtistFile + "' 2>/dev/null"])
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

    function resolveActivePlayer() {
        var players = Mpris.players.values || []
        var playing = null
        for (var i = 0; i < players.length; i++) {
            if (players[i].isPlaying) {
                playing = players[i]
                break
            }
        }
        if (playing) {
            if (root.activePlayer !== playing) {
                playerConn.target = playing
                root.activePlayer = playing
            }
            return
        }
        if (players.length > 0) {
            if (root.activePlayer !== players[0]) {
                playerConn.target = players[0]
                root.activePlayer = players[0]
            }
            return
        }
        if (root.activePlayer !== null) {
            playerConn.target = null
            root.activePlayer = null
        }
    }

    function updateState() {
        if (!root.activePlayer) {
            // Keep existing title/artist if empty (fall back to persistent)
            root.isPlaying = false
            root.hasPlayer = false
            root.position = 0
            root.length = 0
            root.lastArtUrl = ""
            return
        }

        root.hasPlayer = true
        root.isPlaying = root.activePlayer.isPlaying
        root.desktopEntry = root.activePlayer.desktopEntry || ""
        root.identity = root.activePlayer.identity || ""

        var rawTitle = root.activePlayer.trackTitle || ""
        var newTitle = root.cleanTitle(rawTitle)

        var rawArtist = root.activePlayer.trackArtist || ""
        var identity = root.activePlayer.identity || ""
        var newArtist = root.cleanArtist(rawArtist, identity, rawTitle)

        // Only update and save if the info is actually better or different
        // If youtube artist is just "YouTube" or repeats title, ignore it if we have something better
        if (newTitle !== "" && newTitle !== root.title) {
            root.title = newTitle
            root.artist = newArtist
            root.saveMetadata(newTitle, newArtist)
        } else if (newArtist !== "" && newArtist !== root.artist && newArtist.toLowerCase() !== "youtube") {
            root.artist = newArtist
            root.saveMetadata(root.title, newArtist)
        }

        root.artUrl = root.activePlayer.trackArtUrl || ""
        root.position = root.activePlayer.position || 0
        root.length = root.activePlayer.lengthSupported ? root.activePlayer.length : 0

        if (root.artUrl && root.artUrl !== root.lastArtUrl) {
            root.lastArtUrl = root.artUrl
            root.downloadArt(root.artUrl)
        }

        root.findMediaWorkspace()
    }

    Connections {
        id: playerConn
        target: null
        ignoreUnknownSignals: true

        function onIsPlayingChanged() {
            root.resolveActivePlayer()
            root.updateState()
        }
        function onPlaybackStateChanged() {
            root.updateState()
        }
        function onTrackChanged() {
            root.updateState()
        }
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
                    if (root.activePlayer && root.activePlayer.trackArtUrl) {
                        var newUrl = root.activePlayer.trackArtUrl
                        if (newUrl !== root.lastArtUrl) {
                            root.lastArtUrl = newUrl
                            root.downloadArt(newUrl)
                        }
                    }
                })
            })
        }
        function onTrackTitleChanged() { root.updateState() }
        function onTrackArtistChanged() { root.updateState() }
    }

    Timer {
        id: pollTimer
        interval: 1000 
        running: true
        repeat: true
        onTriggered: {
            root.resolveActivePlayer()
            root.updateState()
        }
    }

    Timer {
        interval: 1000
        running: root.activePlayer && root.activePlayer.playbackState === MprisPlaybackState.Playing
        repeat: true
        onTriggered: {
            if (root.activePlayer) {
                root.activePlayer.positionChanged()
                root.position = root.activePlayer.position
                root.length = root.activePlayer.lengthSupported ? root.activePlayer.length : 0
            }
        }
    }

    function formatTime(val) {
        if (!val || val <= 0) return "00:00"
        var totalSec = Math.floor(val)
        var hours = Math.floor(totalSec / 3600)
        var min = Math.floor((totalSec % 3600) / 60)
        var sec = totalSec % 60
        if (hours > 0) {
            return hours + ":" + (min < 10 ? "0" : "") + min + ":" + (sec < 10 ? "0" : "") + sec
        }
        return (min < 10 ? "0" : "") + min + ":" + (sec < 10 ? "0" : "") + sec
    }

    Component.onCompleted: {
        root.localArtPath = root.localArtFile
        root.loadMetadata()
        root.resolveActivePlayer()
        root.updateState()
    }
}
