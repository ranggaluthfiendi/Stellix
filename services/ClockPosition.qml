import QtQuick
import Quickshell
import Quickshell.Io
import QtCore

Item {
    id: util

    readonly property string jsonPath:
        StandardPaths.writableLocation(StandardPaths.ConfigLocation)
        .toString().replace(/^file:\/\//, "") +
        "/quickshell/savedata/time-position.json"

    property real currentX: defaultX
    property real currentY: defaultY
    property int currentAlign: 1

    property real defaultX: 0
    property real defaultY: 0

    signal positionLoaded(real x, real y)
    signal alignLoaded(int align)

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
                    util.currentAlign = typeof parsed.align === "number" ? parsed.align : 1

                } catch (e) {
                    util.currentX = util.defaultX
                    util.currentY = util.defaultY
                    util.currentAlign = 1
                }

                util.positionLoaded(util.currentX, util.currentY)
                util.alignLoaded(util.currentAlign)
            }
        }
    }

    Process {
        id: writeProc
        command: []
    }

    function applyPosition(x, y, container, align, clampScreen = true) {
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

        if (typeof align === "number")
            currentAlign = align

        Qt.callLater(function() {
            savePosition(currentX, currentY, currentAlign)
            positionLoaded(currentX, currentY)
            alignLoaded(currentAlign)
        })
    }

    function loadPosition() {
        const fallback = JSON.stringify({
            x: defaultX,
            y: defaultY,
            align: 1
        }).replace(/'/g, "'\\''")

        readProc.command = [
            "sh", "-c",
            "cat '" + jsonPath + "' 2>/dev/null || echo '" + fallback + "'"
        ]

        readProc.running = true
    }

    function savePosition(x, y, align) {
        const json = JSON.stringify({
            x: x,
            y: y,
            align: align
        }).replace(/'/g, "'\\''")

        writeProc.command = [
            "sh", "-c",
            "mkdir -p '" + jsonPath.replace(/\/[^\/]+$/, "") + "' && echo '" + json + "' > '" + jsonPath + "'"
        ]

        writeProc.running = true
    }
}
