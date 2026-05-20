import QtQuick
import Quickshell
import QtCore

Item {
    id: root

    property string searchText: ""
    property string sortMode: "az"
    property int filterMode: 0
    property bool groupByCategory: false

    readonly property var allApps: {
        var apps = []
        var entries = DesktopEntries.applications.values
        if (!entries) return apps
        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i]
            if (!entry || entry.noDisplay) continue
            apps.push({
                id: entry.id,
                name: entry.name || "",
                genericName: entry.genericName || "",
                comment: entry.comment || "",
                icon: entry.icon || "",
                command: entry.command || [],
                execString: entry.execString || "",
                workingDirectory: entry.workingDirectory || "",
                keywords: entry.keywords || [],
                categories: entry.categories || [],
                entryObj: entry
            })
        }
        return apps
    }

    readonly property var categoryList: {
        var cats = {}
        var entries = DesktopEntries.applications.values
        if (!entries) return []
        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i]
            if (!entry || entry.noDisplay) continue
            if (entry.categories && entry.categories.length > 0) {
                for (var c = 0; c < entry.categories.length; c++) {
                    cats[entry.categories[c]] = true
                }
            }
        }
        var result = ["All"]
        var sorted = Object.keys(cats).sort()
        for (var j = 0; j < sorted.length; j++) {
            result.push(sorted[j])
        }
        return result
    }

    function _filterApps(apps) {
        var query = root.searchText.toLowerCase().trim()
        var results = []

        for (var i = 0; i < apps.length; i++) {
            var app = apps[i]

            if (root.filterMode > 0) {
                var filterCat = root.categoryList[root.filterMode]
                if (app.categories.indexOf(filterCat) < 0) continue
            }

            var nameMatch = app.name.toLowerCase().indexOf(query) >= 0
            var genericMatch = app.genericName.toLowerCase().indexOf(query) >= 0
            var commentMatch = app.comment.toLowerCase().indexOf(query) >= 0
            var keywordMatch = false
            for (var k = 0; k < app.keywords.length; k++) {
                if (app.keywords[k].toLowerCase().indexOf(query) >= 0) {
                    keywordMatch = true
                    break
                }
            }
            if (nameMatch || genericMatch || commentMatch || keywordMatch) {
                results.push(app)
            }
        }

        return results
    }

    readonly property var filteredApps: {
        var results = root._filterApps(root.allApps)

        if (root.sortMode === "az") {
            results.sort(function(a, b) { return a.name.localeCompare(b.name) })
        } else if (root.sortMode === "za") {
            results.sort(function(a, b) { return b.name.localeCompare(a.name) })
        }

        return results
    }

    readonly property var groupedApps: {
        if (!root.groupByCategory || root.filterMode > 0) return []

        var results = root._filterApps(root.allApps)
        var groups = {}

        for (var i = 0; i < results.length; i++) {
            var app = results[i]
            var category = app.categories.length > 0 ? app.categories[0] : "Other"
            if (!groups[category]) groups[category] = []
            groups[category].push(app)
        }

        var sorted = Object.keys(groups).sort()
        var flat = []
        for (var j = 0; j < sorted.length; j++) {
            var cat = sorted[j]
            var apps = groups[cat]
            if (root.sortMode === "az") apps.sort(function(a, b) { return a.name.localeCompare(b.name) })
            else if (root.sortMode === "za") apps.sort(function(a, b) { return b.name.localeCompare(a.name) })
            for (var k = 0; k < apps.length; k++) {
                apps[k]._categoryGroup = cat
                flat.push(apps[k])
            }
        }

        return flat
    }

    function open() {
        root.searchText = ""
        root.sortMode = "az"
        root.filterMode = 0
        root.groupByCategory = false
    }

    function close() {
        root.searchText = ""
    }

    function launchApp(app) {
        if (!app) return
        if (app.entryObj) {
            app.entryObj.execute()
        } else if (app.command && app.command.length > 0) {
            Quickshell.execDetached({
                command: app.command,
                workingDirectory: app.workingDirectory || StandardPaths.writableLocation(StandardPaths.HomeLocation)
            })
        }
        root.close()
    }

    function getIconPath(app) {
        if (!app || !app.icon) return ""
        var p = Quickshell.iconPath(app.icon, true)
        if (p !== "") return p
        return ""
    }

    function getCategoryIcon(category) {
        var iconMap = {
            "AudioVideo": "multimedia-player",
            "Audio": "audio-x-generic",
            "Video": "video-x-generic",
            "Development": "applications-development",
            "Education": "applications-education",
            "Game": "applications-games",
            "Graphics": "applications-graphics",
            "Network": "applications-internet",
            "Office": "applications-office",
            "Settings": "preferences-system",
            "System": "applications-system",
            "Utility": "applications-utilities",
            "Other": "applications-other"
        }
        return iconMap[category] || "applications-other"
    }

    function getAppCategories(app) {
        if (!app || !app.categories || app.categories.length === 0) return "No category"
        return app.categories.join(", ")
    }
}
