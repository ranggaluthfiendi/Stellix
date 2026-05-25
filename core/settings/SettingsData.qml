import QtQuick
import Quickshell
import Quickshell.Io
import QtCore
import qs.config
import qs.data

Item {
    id: root

    readonly property string savePath: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata/settings-state.json"

    // Sidebar state
    property bool appearanceExp: true
    property bool connectivityExp: true
    property bool workspaceExp: true
    property bool systemExp: true
    property bool metricsExp: true

    property bool showWelcomeScreen: true
    property bool settingsFloating: false

    property var recentSearches: []

    onAppearanceExpChanged: save()
    onConnectivityExpChanged: save()
    onWorkspaceExpChanged: save()
    onSystemExpChanged: save()
    onShowWelcomeScreenChanged: save()
    onSettingsFloatingChanged: save()
    onRecentSearchesChanged: save()

    function addRecentSearch(query) {
        if (!query || query.trim() === "") return
        var q = query.trim().toLowerCase()
        var copy = recentSearches.slice()
        var idx = copy.indexOf(q)
        if (idx !== -1) copy.splice(idx, 1)
        copy.unshift(q)
        if (copy.length > 10) copy = copy.slice(0, 10)
        recentSearches = copy
    }

    function clearRecentSearches() {
        recentSearches = []
    }

    function save() {
        var data = {
            appearanceExp: root.appearanceExp,
            connectivityExp: root.connectivityExp,
            workspaceExp: root.workspaceExp,
            systemExp: root.systemExp,
            metricsExp: root.metricsExp,
            showWelcomeScreen: root.showWelcomeScreen,
            settingsFloating: root.settingsFloating,
            recentSearches: root.recentSearches
        }
        var json = JSON.stringify(data)
        writeProcess.exec(["sh", "-c", "mkdir -p $(dirname '" + root.savePath + "') && echo '" + json + "' > '" + root.savePath + "'"])
    }

    function load() {
        readProcess.exec(["cat", root.savePath])
    }

    Process {
        id: writeProcess
    }

    Process {
        id: readProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text.trim())
                    if (data.hasOwnProperty("appearanceExp")) root.appearanceExp = data.appearanceExp
                    if (data.hasOwnProperty("connectivityExp")) root.connectivityExp = data.connectivityExp
                    if (data.hasOwnProperty("workspaceExp")) root.workspaceExp = data.workspaceExp
                    if (data.hasOwnProperty("systemExp")) root.systemExp = data.systemExp
                    if (data.hasOwnProperty("metricsExp")) root.metricsExp = data.metricsExp
                    if (data.hasOwnProperty("showWelcomeScreen")) root.showWelcomeScreen = data.showWelcomeScreen
                    if (data.hasOwnProperty("settingsFloating")) root.settingsFloating = data.settingsFloating
                    if (data.hasOwnProperty("recentSearches") && Array.isArray(data.recentSearches)) root.recentSearches = data.recentSearches
                } catch (e) {}
            }
        }
    }

    Component.onCompleted: load()

    // Search proxy using external SearchModel
    function search(query) {
        return SearchModel.search(query)
    }

    readonly property var settingsModel: SearchModel.settingsModel
}
