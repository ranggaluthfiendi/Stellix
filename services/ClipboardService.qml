import QtQuick
import Quickshell
import Quickshell.Io
import QtCore

Item {
    id: root

    property var history: []
    property var filteredHistory: []
    property var pinnedIds: []
    property int maxHistory: 50
    property string searchText: ""
    property int totalCount: 0
    property int pinnedCount: 0

    property string _savePath: Quickshell.configPath("savedata/clipboard-pins.json")

    Component.onCompleted: {
        loadPins()
        refreshHistory()
    }

    onSearchTextChanged: {
        filterHistory()
    }

    FileView {
        id: pinsFile
        path: root._savePath
        onLoadFailed: function(error) {
            root.pinnedIds = []
        }
    }

    function loadPins() {
        try {
            var data = pinsFile.text()
            if (data && data.length > 0) {
                root.pinnedIds = JSON.parse(data)
            } else {
                root.pinnedIds = []
            }
        } catch(e) {
            root.pinnedIds = []
        }
    }

    function savePins() {
        pinsFile.setText(JSON.stringify(root.pinnedIds))
    }

    function isPinned(id) {
        return root.pinnedIds.indexOf(id) !== -1
    }

    function togglePin(id) {
        var idx = root.pinnedIds.indexOf(id)
        if (idx !== -1) {
            var newPins = []
            for (var i = 0; i < root.pinnedIds.length; i++) {
                if (root.pinnedIds[i] !== id) newPins.push(root.pinnedIds[i])
            }
            root.pinnedIds = newPins
        } else {
            root.pinnedIds = root.pinnedIds.concat([id])
        }
        root.pinnedCount = root.pinnedIds.length
        savePins()
        filterHistory()
    }

    Process {
        id: listProcess
        stdout: StdioCollector {
            onStreamFinished: {
                var output = this.text.trim()
                if (output.length === 0) {
                    root.history = []
                    root.filteredHistory = []
                    root.totalCount = 0
                    return
                }
                var lines = output.split("\n")
                var items = []
                for (var i = 0; i < lines.length && i < root.maxHistory; i++) {
                    var line = lines[i]
                    if (line.length === 0) continue
                    var tabIdx = line.indexOf("\t")
                    if (tabIdx > 0) {
                        var id = line.substring(0, tabIdx)
                        var preview = line.substring(tabIdx + 1)
                        var cleanPreview = preview.replace(/\0/g, "")
                        var pinned = root.isPinned(id)
                        var isImage = cleanPreview.indexOf("data:image/") === 0
                        items.push({ id: id, text: cleanPreview, pinned: pinned, isImage: isImage })
                    }
                }
                items.sort(function(a, b) {
                    if (a.pinned !== b.pinned) return a.pinned ? -1 : 1
                    return parseInt(b.id) - parseInt(a.id)
                })
                root.history = items
                root.totalCount = items.length
                root.filterHistory()
            }
        }
    }

    function filterHistory() {
        var query = root.searchText.trim().toLowerCase()
        if (query.length === 0) {
            root.filteredHistory = root.history
            return
        }
        var filtered = []
        for (var i = 0; i < root.history.length; i++) {
            var item = root.history[i]
            if (item.text.toLowerCase().indexOf(query) !== -1) {
                filtered.push(item)
            }
        }
        root.filteredHistory = filtered
    }

    function refreshHistory() {
        listProcess.exec(["cliphist", "list"])
    }

    Process {
        id: decodeProcess
        stdout: StdioCollector {
            id: decodeCollector
            onStreamFinished: {
                var content = this.text
                if (content.length > 0) {
                    copyProcess.exec(["sh", "-c", "printf '%s' '" + content.replace(/'/g, "'\\''") + "' | wl-copy"])
                }
            }
        }
    }

    Process {
        id: copyProcess
    }

    function copyToClipboard(id) {
        // First get the type if possible, or just decode normally
        decodeProcess.exec(["sh", "-c", "cliphist decode '" + id + "' | wl-copy"])
    }

    function copyImageToClipboard(id) {
        // Improved image copying logic
        decodeProcess.exec(["sh", "-c", "cliphist decode '" + id + "' | wl-copy --type image/png"])
    }

    Process {
        id: deleteProcess
        stdout: StdioCollector {
            onStreamFinished: root.refreshHistory()
        }
    }

    function deleteFromHistory(id) {
        deleteProcess.exec(["sh", "-c", "cliphist list | grep -w \"^" + id + "\" | cliphist delete"])
    }

    Process {
        id: clearProcess
        stdout: StdioCollector {
            onStreamFinished: root.refreshHistory()
        }
    }

    function clearHistory() {
        clearProcess.exec(["cliphist", "wipe"])
    }

    Timer {
        id: refreshTimer
        interval: 2000
        repeat: true
        running: true
        onTriggered: root.refreshHistory()
    }
}
