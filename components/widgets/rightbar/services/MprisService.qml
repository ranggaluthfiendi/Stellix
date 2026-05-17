import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Io
import QtCore
import qs.config

Item {
    id: root

    readonly property var players: (Mpris.players && Mpris.players.values) ? Mpris.players.values : []
    readonly property var activePlayer: players.length > 0 ? players[0] : null

    property int artRefreshCounter: 0
    property string cachedArtUrl: ""
    property string cachedTitle: ""
    property string cachedArtist: ""

    readonly property string artCachePath: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata/media-cache.json"

    StdioCollector { id: cacheReadOut }
    StdioCollector { id: cacheWriteOut }

    Process {
        id: cacheRead
        stdout: cacheReadOut
        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0) {
                try {
                    var data = JSON.parse(cacheReadOut.text.trim())
                    root.cachedArtUrl = data.artUrl || ""
                    root.cachedTitle = data.title || ""
                    root.cachedArtist = data.artist || ""
                } catch (e) {}
            }
        }
    }

    Process {
        id: cacheWrite
        stdout: cacheWriteOut
    }

    function saveCache() {
        var artUrl = root.activePlayer && root.activePlayer.trackArtUrl ? root.activePlayer.trackArtUrl : root.cachedArtUrl
        var title = root.activePlayer && root.activePlayer.trackTitle ? root.activePlayer.trackTitle : root.cachedTitle
        var artist = root.activePlayer && root.activePlayer.trackArtist ? root.activePlayer.trackArtist : root.cachedArtist

        var json = JSON.stringify({
            artUrl: artUrl,
            title: title,
            artist: artist
        })
        var dir = root.artCachePath.replace(/\/[^\/]+$/, "")
        cacheWrite.exec(["sh", "-c", "mkdir -p '" + dir + "' && echo '" + json + "' > '" + root.artCachePath + "'"])
    }

    Connections {
        target: root.activePlayer
        function onTrackArtUrlChanged() {
            root.artRefreshCounter++
            root.saveCache()
        }
        function onTrackTitleChanged() { root.saveCache() }
        function onMetadataChanged() { root.saveCache() }
    }

    Timer {
        id: positionTimer
        interval: 500
        running: root.activePlayer != null && root.activePlayer.playbackState === MprisPlaybackState.Playing
        repeat: true
        onTriggered: {
            root.activePlayer.positionChanged()
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
        var dir = root.artCachePath.replace(/\/[^\/]+$/, "")
        cacheRead.exec(["sh", "-c", "mkdir -p '" + dir + "' && cat '" + root.artCachePath + "' 2>/dev/null || echo '{}'"])
    }
}
