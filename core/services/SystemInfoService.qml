import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string uptime: "0h 0m"
    property real memUsed: 0
    property real memTotal: 1
    property int cpuCount: 0
    property string kernel: "Unknown"
    property string cpuModel: "Unknown"
    property var gpus: []
    property int updatesCount: 0
    property string storageInfo: "Unknown"
    property string diskUsage: "0%"
    property string temperature: "0°C"
    property string ssid: "Disconnected"
    property string wifiPass: "N/A"
    property string netUp: "0 KB/s"
    property string netDown: "0 KB/s"
    property var availableNetworks: []
    
    property string distroName: "Unknown"
    property string distroId: "linux"
    property string distroLogo: ""
    
    property var _lastNetBytes: ({rx: 0, tx: 0, time: 0})

    Timer {
        interval: 5000 
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: refresh()
    }

    Process {
        id: infoProc
        stdout: StdioCollector {
            onStreamFinished: {
                var rawText = this.text.trim();
                if (rawText === "") return;
                
                var sections = rawText.split('---SECTION---');
                if (sections.length < 15) return;

                // 0: Uptime
                var upSeconds = parseFloat(sections[0].trim().split(/\s+/)[0]);
                if (!isNaN(upSeconds)) {
                    var h = Math.floor(upSeconds / 3600);
                    var m = Math.floor((upSeconds % 3600) / 60);
                    root.uptime = h + "h " + m + "m";
                }

                // 1: RAM
                var memLine = sections[1].trim().split(/\s+/);
                if (memLine.length >= 3) {
                    root.memTotal = parseInt(memLine[1]) || 1;
                    root.memUsed = parseInt(memLine[2]) || 0;
                }

                // 2: CPU Count
                root.cpuCount = parseInt(sections[2].trim()) || 0;

                // 3: Kernel
                root.kernel = sections[3].trim() || "Unknown";

                // 4: CPU Model
                root.cpuModel = sections[4].trim() || "Unknown";

                // 5: GPUs
                var gpuLines = sections[5].trim().split('\n');
                var gpuList = [];
                for (var j = 0; j < gpuLines.length; j++) {
                    var g = gpuLines[j].trim();
                    if (g.length > 0) gpuList.push(g);
                }
                root.gpus = gpuList;

                // 6: Updates
                root.updatesCount = parseInt(sections[6].trim()) || 0;
                
                // 7: Storage
                root.storageInfo = sections[7].trim() || "Unknown";

                // 8: Disk Usage
                root.diskUsage = sections[8].trim() || "0%";

                // 9: Temperature
                root.temperature = sections[9].trim() || "0°C";

                // 10: SSID
                root.ssid = sections[10].trim() || "Disconnected";

                // 11: WiFi Pass
                root.wifiPass = sections[11].trim() || "N/A";

                // 12: OS Info
                var osParts = sections[12].trim().split(';');
                if (osParts.length >= 3) {
                    root.distroName = osParts[0];
                    root.distroId = osParts[1];
                    root.distroLogo = osParts[2];
                }

                // 13: Network Speeds
                var netData = sections[13].trim().split(/\s+/);
                if (netData.length >= 2) {
                    var rx = parseInt(netData[0]);
                    var tx = parseInt(netData[1]);
                    var now = Date.now();
                    
                    if (root._lastNetBytes.time > 0) {
                        var dt = (now - root._lastNetBytes.time) / 1000;
                        if (dt > 0) {
                            var downBps = (rx - root._lastNetBytes.rx) / dt;
                            var upBps = (tx - root._lastNetBytes.tx) / dt;
                            root.netDown = root.formatBytes(Math.max(0, downBps)) + "/s";
                            root.netUp = root.formatBytes(Math.max(0, upBps)) + "/s";
                        }
                    }
                    root._lastNetBytes = {rx: rx, tx: tx, time: now};
                }

                // 14: Saved Connections
                var savedConnections = sections[14].trim().split('\n').map(function(s){ return s.trim() });

                // 15: Available Networks
                if (sections.length >= 16) {
                    var wifiLines = sections[15].trim().split('\n');
                    var networks = [];
                    for (var k = 0; k < wifiLines.length; k++) {
                        var line = wifiLines[k].trim();
                        if (line === "") continue;
                        var parts = line.split(':');
                        if (parts.length >= 4) {
                            var ssidVal = parts[1];
                            var isKnown = savedConnections.indexOf(ssidVal) !== -1;
                            networks.push({
                                active: parts[0] === "yes",
                                ssid: ssidVal,
                                signal: parts[2],
                                security: parts[3],
                                connected: parts[0] === "yes",
                                known: isKnown
                            });
                        }
                    }
                    // Sort: Active first, then by signal strength
                    networks.sort(function(a, b) {
                        if (a.active && !b.active) return -1;
                        if (!a.active && b.active) return 1;
                        return parseInt(b.signal) - parseInt(a.signal);
                    });
                    root.availableNetworks = networks;
                }
            }
        }
    }

    function formatBytes(bytes) {
        if (bytes < 1024) return Math.round(bytes) + " B";
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB";
        return (bytes / (1024 * 1024)).toFixed(1) + " MB";
    }

    function refresh() {
        var cmd = "cat /proc/uptime; echo '---SECTION---'; " +
                  "free -m | grep Mem:; echo '---SECTION---'; " +
                  "nproc; echo '---SECTION---'; " +
                  "uname -sr; echo '---SECTION---'; " +
                  "lscpu | grep 'Model name:' | cut -d: -f2 | xargs; echo '---SECTION---'; " +
                  "lspci -k | grep -E 'VGA|3D' | cut -d: -f3 | cut -d'(' -f1 | xargs -I{} echo {}; " +
                  "if command -v nvidia-smi >/dev/null; then nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | xargs -I{} echo NVIDIA: {}%; fi; echo '---SECTION---'; " +
                  "(checkupdates 2>/dev/null | wc -l || echo 0); echo '---SECTION---'; " +
                  "df -h / | tail -1 | awk '{print $3 \" / \" $2 \" (used \" $5 \")\"}'; echo '---SECTION---'; " +
                  "df / | tail -1 | awk '{print $5}'; echo '---SECTION---'; " +
                  "sensors | grep -m1 -E 'Tctl|Tdie|Package id 0|Core 0|temp1' | awk -F'+' '{print $2}' | awk '{print $1}' || echo 'N/A'; echo '---SECTION---'; " +
                  "nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2 || echo 'Disconnected'; echo '---SECTION---'; " +
                  "SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2); [ -n \"$SSID\" ] && nmcli -s -g 802-11-wireless-security.psk connection show \"$SSID\" 2>/dev/null || echo 'N/A'; echo '---SECTION---'; " +
                  "source /etc/os-release && echo \"$PRETTY_NAME;$ID;$LOGO\"; echo '---SECTION---'; " +
                  "awk '/wlp|enp|eth/ {rx+=$2; tx+=$10} END {print rx \" \" tx}' /proc/net/dev; echo '---SECTION---'; " +
                  "nmcli -t -f name,type connection show | grep 802-11-wireless | cut -d: -f1; echo '---SECTION---'; " +
                  "nmcli -t -f active,ssid,signal,security dev wifi | head -20";
        infoProc.exec(["sh", "-c", cmd]);
    }
}
