import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string temp: "--"
    property string tempRaw: ""
    property string desc: "Unknown"
    property string location: "Unknown"
    property string icon: ""
    property string city: "Jakarta"
    property string unit: "C"

    property bool loading: false

    readonly property string unitSymbol: {
        switch (root.unit) {
            case "F": return "°F"
            case "R": return "°R"
            case "K": return "K"
            default: return "°C"
        }
    }

    function convertTemp(celsiusStr) {
        var c = parseFloat(celsiusStr.replace(/[°CcCfFrRkK\s]/g, ""))
        if (isNaN(c)) return "--"
        switch (root.unit) {
            case "F": return Math.round(c * 9/5 + 32).toString()
            case "R": return Math.round(c * 4/5).toString()
            case "K": return Math.round(c + 273.15).toString()
            default: return Math.round(c).toString()
        }
    }

    Process {
        id: weatherProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false
                var raw = this.text.trim();
                if (raw.includes("Unknown") || raw === "") return;
                
                var parts = raw.split('|');
                if (parts.length >= 3) {
                    root.tempRaw = parts[0].trim();
                    root.temp = root.convertTemp(root.tempRaw);
                    root.desc = parts[1].trim();
                    root.location = parts[2].trim();
                }
            }
        }
    }

    function refresh() {
        if (loading || root.city === "") return
        loading = true
        
        var cityQuery = root.city.replace(/\s+/g, '+');
        var cmd = "curl -s 'wttr.in/" + cityQuery + "?format=%t|%C|%l'";
        weatherProc.exec(["sh", "-c", cmd]);
    }

    onCityChanged: refresh()
    onUnitChanged: { if (root.tempRaw !== "") root.temp = root.convertTemp(root.tempRaw) }

    Component.onCompleted: refresh()

    Timer {
        interval: 1800000
        running: true
        repeat: true
        onTriggered: refresh()
    }
}
