import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string uptime: "0h 0m"
    property real memUsed: 0
    property real memTotal: 1
    property real memUsage: 0
    property int cpuCount: 0
    property real cpuUsage: 0
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
    property var _lastCpuStats: ({user: 0, nice: 0, system: 0, idle: 0, iowait: 0, irq: 0, softirq: 0, time: 0})

    Timer {
        interval: 2000 
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
                if (sections.length < 17) return;

                // 0: CPU Usage
                var cpuLine = sections[0].trim().split(/\s+/);
                if (cpuLine.length >= 8) {
                    var user = parseInt(cpuLine[1]) || 0;
                    var nice = parseInt(cpuLine[2]) || 0;
                    var systemVal = parseInt(cpuLine[3]) || 0;
                    var idle = parseInt(cpuLine[4]) || 0;
                    var iowait = parseInt(cpuLine[5]) || 0;
                    var irq = parseInt(cpuLine[6]) || 0;
                    var softirq = parseInt(cpuLine[7]) || 0;
                    
                    var totalIdle = idle + iowait;
                    var totalNonIdle = user + nice + systemVal + irq + softirq;
                    var total = totalIdle + totalNonIdle;
                    
                    if (root._lastCpuStats.time > 0) {
                        var prevTotalIdle = root._lastCpuStats.idle + root._lastCpuStats.iowait;
                        var prevTotal = prevTotalIdle + root._lastCpuStats.user + root._lastCpuStats.nice + root._lastCpuStats.system + root._lastCpuStats.irq + root._lastCpuStats.softirq;
                        
                        var diffIdle = totalIdle - prevTotalIdle;
                        var diffTotal = total - prevTotal;
                        
                        if (diffTotal > 0) {
                            root.cpuUsage = Math.round(((diffTotal - diffIdle) / diffTotal) * 100);
                        }
                    }
                    root._lastCpuStats = {user: user, nice: nice, system: systemVal, idle: idle, iowait: iowait, irq: irq, softirq: softirq, time: Date.now()};
                }

                // 1: Uptime
                var upSeconds = parseFloat(sections[1].trim().split(/\s+/)[0]);
                if (!isNaN(upSeconds)) {
                    var h = Math.floor(upSeconds / 3600);
                    var m = Math.floor((upSeconds % 3600) / 60);
                    root.uptime = h + "h " + m + "m";
                }

                // 2: RAM
                var memLine = sections[2].trim().split(/\s+/);
                if (memLine.length >= 3) {
                    root.memTotal = parseInt(memLine[1]) || 1;
                    root.memUsed = parseInt(memLine[2]) || 0;
                    root.memUsage = Math.round((root.memUsed / root.memTotal) * 100);
                }

                // 3: CPU Count
                root.cpuCount = parseInt(sections[3].trim()) || 0;

                // 4: Kernel
                root.kernel = sections[4].trim() || "Unknown";

                // 5: CPU Model
                root.cpuModel = sections[5].trim() || "Unknown";

                // 6: GPUs
                var gpuLines = sections[6].trim().split('\n');
                var gpuList = [];
                for (var j = 0; j < gpuLines.length; j++) {
                    var g = gpuLines[j].trim();
                    if (g.length > 0) gpuList.push(g);
                }
                root.gpus = gpuList;

                // 7: Updates
                root.updatesCount = parseInt(sections[7].trim()) || 0;
                
                // 8: Storage
                root.storageInfo = sections[8].trim() || "Unknown";

                // 9: Disk Usage
                root.diskUsage = sections[9].trim() || "0%";

                // 10: Temperature
                root.temperature = sections[10].trim() || "0°C";

                // 11: SSID
                root.ssid = sections[11].trim() || "Disconnected";

                // 12: WiFi Pass
                root.wifiPass = sections[12].trim() || "N/A";

                // 13: OS Info
                var osParts = sections[13].trim().split(';');
                if (osParts.length >= 3) {
                    root.distroName = osParts[0];
                    root.distroId = osParts[1];
                    root.distroLogo = osParts[2];
                }

                // 14: Network Speeds
                var netData = sections[14].trim().split(/\s+/);
                if (netData.length >= 2) {
                    var rx = parseInt(netData[0]);
                    var tx = parseInt(netData[1]);
                    if (!isNaN(rx) && !isNaN(tx)) {
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
                }

                // 15: Saved Connections
                var savedConnections = sections[15].trim().split('\n').map(function(s){ return s.trim() });

                // 16: Available Networks
                if (sections.length >= 17) {
                    var wifiLines = sections[16].trim().split('\n');
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
        var cmd = "cat /proc/stat | head -1; echo '---SECTION---'; " +
                  "cat /proc/uptime; echo '---SECTION---'; " +
                  "free -m | grep Mem:; echo '---SECTION---'; " +
                  "nproc; echo '---SECTION---'; " +
                  "uname -sr; echo '---SECTION---'; " +
                  "lscpu | grep 'Model name:' | cut -d: -f2 | xargs; echo '---SECTION---'; " +
                  "lspci -k | grep -E 'VGA|3D' | cut -d: -f3 | cut -d'(' -f1 | xargs -I{} echo {}; " +
                  "if command -v nvidia-smi >/dev/null; then nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | while read line; do echo \"NVIDIA: ${line}%\"; done; fi; echo '---SECTION---'; " +
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
