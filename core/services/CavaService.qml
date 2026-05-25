pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import QtCore

Item {
    id: root

    property var bars: []
    property bool active: true

    readonly property string configPath: 
        StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString().replace(/^file:\/\//, "") + 
        "/quickshell/savedata/cava/config"
    
    readonly property string outputPath: "/tmp/quickshell_cava_out"

    Process {
        id: cavaDaemon
        command: ["/home/rang/.config/quickshell/scripts/cava_daemon.sh", root.configPath, root.outputPath]
        running: root.active
    }

    Process {
        id: readProc
        command: ["cat", root.outputPath]
        stdout: StdioCollector {
            onStreamFinished: {
                var cleanLine = this.text.trim()
                if (cleanLine === "") return
                
                var parts = cleanLine.split(/\s+/)
                var values = []
                for (var i = 0; i < 16; i++) {
                    var val = parseInt(parts[i])
                    values.push(isNaN(val) ? 0 : val / 100.0)
                }
                
                if (values.length === 16) {
                    root.bars = values
                }
            }
        }
    }

    Timer {
        interval: 50 // 20 fps
        running: root.active
        repeat: true
        onTriggered: readProc.exec(["cat", root.outputPath])
    }

    Component.onCompleted: {
        var initial = []
        for (var i = 0; i < 16; i++) initial.push(0)
        bars = initial
    }
}
