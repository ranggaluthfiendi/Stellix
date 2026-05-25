pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import QtCore

Item {
    id: root

    property int blurSize: 4
    property real transparency: 0.9

    readonly property string savePath:
        StandardPaths.writableLocation(StandardPaths.ConfigLocation)
        .toString().replace(/^file:\/\//, "") +
        "/quickshell/savedata/hyprland-decoration.json"

    Component.onCompleted: {
        load()
    }

    Process {
        id: readProc
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var text = this.text.trim()
                    if (text === "") return
                    var data = JSON.parse(text)
                    if (data.hasOwnProperty("blurSize")) root.blurSize = data.blurSize
                    if (data.hasOwnProperty("transparency")) root.transparency = data.transparency
                    root.applyToHyprland()
                } catch (e) {}
            }
        }
    }

    Process {
        id: writeProc
    }

    Process {
        id: hyprctlProc
    }

    function load() {
        readProc.exec(["sh", "-c", "cat '" + root.savePath + "' 2>/dev/null || echo ''"])
    }

    function save() {
        var data = {
            blurSize: root.blurSize,
            transparency: root.transparency
        }
        var json = JSON.stringify(data)
        writeProc.exec(["sh", "-c", "mkdir -p $(dirname '" + root.savePath + "') && echo '" + json + "' > '" + root.savePath + "'"])
    }

    function applyToHyprland() {
        hyprctlProc.exec(["sh", "-c",
            "hyprctl keyword decoration:blur:size " + root.blurSize + " && " +
            "hyprctl keyword decoration:blur:brightness " + root.transparency
        ])
    }

    function setBlurSize(value) {
        root.blurSize = Math.round(value)
        save()
        applyToHyprland()
    }

    function setTransparency(value) {
        root.transparency = value
        save()
        applyToHyprland()
    }
}
