import QtQuick
import Quickshell
import Quickshell.Io
import QtCore

Item {
    id: util

    readonly property string jsonPath:
        StandardPaths.writableLocation(StandardPaths.ConfigLocation)
        .toString().replace(/^file:\/\//, "") +
        "/quickshell/savedata/bar-state.json"

    property bool currentPinned: true
    property bool currentAutoHide: true

    signal stateLoaded(bool pinned, bool autoHide)

    Component.onCompleted: {
        loadState()
    }

    Process {
        id: readProc
        command: []

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(this.text)

                    util.currentPinned = typeof parsed.pinned === "boolean" ? parsed.pinned : true
                    util.currentAutoHide = typeof parsed.autoHide === "boolean" ? parsed.autoHide : true

                } catch (e) {
                    util.currentPinned = true
                    util.currentAutoHide = true
                }

                util.stateLoaded(util.currentPinned, util.currentAutoHide)
            }
        }
    }

    Process {
        id: writeProc
        command: []
    }

    function loadState() {
        const fallback = JSON.stringify({
            pinned: true,
            autoHide: true
        }).replace(/'/g, "'\\''")

        readProc.command = [
            "sh", "-c",
            "cat '" + jsonPath + "' 2>/dev/null || echo '" + fallback + "'"
        ]

        readProc.running = true
    }

    function saveState(pinned, autoHide) {
        const json = JSON.stringify({
            pinned: pinned,
            autoHide: autoHide
        }).replace(/'/g, "'\\''")

        writeProc.command = [
            "sh", "-c",
            "mkdir -p '" + jsonPath.replace(/\/[^\/]+$/, "") + "' && echo '" + json + "' > '" + jsonPath + "'"
        ]

        writeProc.running = true
    }

    function applyState(pinned, autoHide) {
        currentPinned = pinned
        currentAutoHide = autoHide

        Qt.callLater(function() {
            saveState(currentPinned, currentAutoHide)
            stateLoaded(currentPinned, currentAutoHide)
        })
    }
}
