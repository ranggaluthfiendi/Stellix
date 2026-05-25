import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property real currentValue: 0
    property int maxValue: 100
    property bool ready: false

    readonly property real percentage: maxValue > 0 ? Math.round((currentValue / maxValue) * 100) : 0

    StdioCollector { id: getOut }
    StdioCollector { id: maxOut }

    Process {
        id: getProcess
        command: ["brightnessctl", "get"]
        stdout: getOut
        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0) {
                var txt = getOut.text.trim()
                var val = parseInt(txt)
                if (!isNaN(val) && val >= 0) {
                    root.currentValue = val
                    root.ready = true
                }
            }
        }
    }

    Process {
        id: maxProcess
        command: ["brightnessctl", "max"]
        stdout: maxOut
        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0) {
                var val = parseInt(maxOut.text.trim())
                if (!isNaN(val) && val > 0) {
                    root.maxValue = val
                }
            }
        }
    }

    Process {
        id: setProcess
        onExited: function(exitCode, exitStatus) {
            getProcess.exec(["brightnessctl", "get"])
        }
    }

    Timer {
        id: refreshTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: getProcess.exec(["brightnessctl", "get"])
    }

    function init() {
        maxProcess.exec(["brightnessctl", "max"])
        Qt.callLater(function() { getProcess.exec(["brightnessctl", "get"]) })
    }

    function setPercentage(pct) {
        pct = Math.max(0, Math.min(100, pct))
        var val = Math.max(0, Math.round((pct / 100) * root.maxValue))
        root.currentValue = val
        root.ready = true
        setProcess.exec(["brightnessctl", "set", String(val)])
    }
}
