pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import QtCore

Item {
    id: root

    readonly property string savePath: StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + "/quickshell/savedata/nowplaying-state.json"

    property real posX: -1
    property real posY: -1

    function save(x, y) {
        root.posX = x
        root.posY = y
        var data = {
            x: x,
            y: y
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
                    if (data.hasOwnProperty("x")) root.posX = data.x
                    if (data.hasOwnProperty("y")) root.posY = data.y
                } catch (e) {}
            }
        }
    }

    Component.onCompleted: load()
}
