import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool sinkReady: sink && sink.audio && sink.ready
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool sourceReady: source && source.audio && source.ready

    PwObjectTracker {
        id: pwTracker
        objects: Pipewire.nodes.values
    }

    readonly property var allSinks: Pipewire.nodes.values.filter(function(n) { return n && n.isSink && n.audio })
    readonly property var allSources: Pipewire.nodes.values.filter(function(n) { return n && n.audio && !n.isSink })

    function sinkDevices() { return allSinks.filter(function(n) { return !n.isStream }) }
    function sinkApps() { return allSinks.filter(function(n) { return n.isStream }) }
    function sourceDevices() { return allSources.filter(function(n) { return !n.isStream }) }
    function sourceApps() { return allSources.filter(function(n) { return n.isStream }) }

    function nodeName(node) {
        if (!node) return "Unknown"
        var appName = node.properties ? node.properties["application.name"] : null
        if (appName) return appName
        return node.nickname || node.description || node.name || "Device"
    }

    function nodeIconPath(node) {
        if (!node) return ""
        var props = node.properties || {}

        var rawIconName = props["application.icon-name"] || ""
        var rawMediaIcon = props["media.icon-name"] || ""
        var rawAppName   = props["application.name"]   || node.name || ""
        var rawBinary    = props["application.process.binary"] || ""

        var candidates = []

        if (rawIconName.length > 0) {
            candidates.push(rawIconName)
            candidates.push(rawIconName.toLowerCase())
        }
        if (rawMediaIcon.length > 0) {
            candidates.push(rawMediaIcon)
            candidates.push(rawMediaIcon.toLowerCase())
        }

        if (rawBinary.length > 0) {
            candidates.push(rawBinary)
            candidates.push(rawBinary.toLowerCase())
            var baseName = rawBinary.split("/").pop()
            candidates.push(baseName)
            candidates.push(baseName.toLowerCase())
        }

        if (rawAppName.length > 0) {
            candidates.push(rawAppName.toLowerCase())
            candidates.push(rawAppName.toLowerCase().replace(/ /g, "-"))
            candidates.push(rawAppName.toLowerCase().replace(/ /g, ""))
        }

        var lowerName = rawAppName.toLowerCase()
        if (lowerName.indexOf("brave") >= 0) {
            candidates.push("brave-browser")
            candidates.push("com.brave.Browser")
        }
        if (lowerName.indexOf("firefox") >= 0) {
            candidates.push("firefox")
            candidates.push("org.mozilla.firefox")
        }
        if (lowerName.indexOf("chrome") >= 0 && lowerName.indexOf("chromium") < 0) {
            candidates.push("google-chrome")
            candidates.push("chrome")
        }
        if (lowerName.indexOf("chromium") >= 0) {
            candidates.push("chromium-browser")
            candidates.push("chromium")
        }
        if (lowerName.indexOf("spotify") >= 0) {
            candidates.push("spotify-client")
            candidates.push("spotify")
        }
        if (lowerName.indexOf("vlc") >= 0) {
            candidates.push("vlc")
        }
        if (lowerName.indexOf("discord") >= 0) {
            candidates.push("discord")
            candidates.push("com.discordapp.Discord")
        }
        if (lowerName.indexOf("telegram") >= 0) {
            candidates.push("telegram")
            candidates.push("org.telegram.desktop")
        }
        if (lowerName.indexOf("slack") >= 0) {
            candidates.push("slack")
        }
        if (lowerName.indexOf("zoom") >= 0) {
            candidates.push("Zoom")
            candidates.push("zoom")
        }
        if (lowerName.indexOf("teams") >= 0) {
            candidates.push("teams-for-linux")
            candidates.push("teams")
        }
        if (lowerName.indexOf("thunderbird") >= 0) {
            candidates.push("thunderbird")
        }
        if (lowerName.indexOf("obs") >= 0 || lowerName.indexOf("studio") >= 0) {
            candidates.push("obs")
            candidates.push("com.obsproject.Studio")
        }

        for (var i = 0; i < candidates.length; i++) {
            var c = candidates[i]
            if (!c || c.length === 0) continue
            var p = Quickshell.iconPath(c, true)
            if (p && p.length > 0) return p
        }
        return ""
    }
}
