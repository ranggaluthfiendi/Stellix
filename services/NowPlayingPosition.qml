import QtQuick
import Quickshell
import Quickshell.Io
import QtCore

Item {
    id: util

    readonly property string jsonPath:
        StandardPaths.writableLocation(StandardPaths.ConfigLocation)
        .toString().replace(/^file:\/\//, "") +
        "/quickshell/savedata/nowplaying-position.json"

    property real currentX: defaultX
    property real currentY: defaultY

    property real defaultX: 0
    property real defaultY: 0

    signal positionLoaded(real x, real y)

    Component.onCompleted: {
        loadPosition()
    }

    Process {
        id: readProc
        command: []

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(this.text)
                    util.currentX = typeof parsed.x === "number" ? parsed.x : util.defaultX
                    util.currentY = typeof parsed.y === "number" ? parsed.y : util.defaultY
                } catch (e) {
                    util.currentX = util.defaultX
                    util.currentY = util.defaultY
                }

                util.positionLoaded(util.currentX, util.currentY)
            }
        }
    }

    Process {
        id: writeProc
        command: []
    }

    function applyPosition(x, y, container, clampScreen = true) {
        let finalX = x
        let finalY = y

        if (clampScreen && container) {
            const maxX = container.parent.width - container.width
            const maxY = container.parent.height - container.height

            finalX = Math.max(0, Math.min(finalX, maxX))
            finalY = Math.max(0, Math.min(finalY, maxY))
        }

        currentX = finalX
        currentY = finalY

        Qt.callLater(function() {
            savePosition(finalX, finalY)
            positionLoaded(finalX, finalY)
        })
    }

    function loadPosition() {
        const fallback = JSON.stringify({ x: defaultX, y: defaultY }).replace(/'/g, "'\\''")

        readProc.command = [
            "sh", "-c",
            "cat '" + jsonPath + "' 2>/dev/null || echo '" + fallback + "'"
        ]

        readProc.running = true
    }

    function savePosition(x, y) {
        const json = JSON.stringify({ x: x, y: y }).replace(/'/g, "'\\''")

        writeProc.command = [
            "sh", "-c",
            "mkdir -p '" + jsonPath.replace(/\/[^\/]+$/, "") + "' && echo '" + json + "' > '" + jsonPath + "'"
        ]

        writeProc.running = true
    }
}
