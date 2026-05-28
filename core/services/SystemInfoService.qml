import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // Existing properties
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
    
    // New properties
    property int batteryLevel: 0
    property string batteryStatus: "Unknown"
    property bool batteryCharging: false
    
    property real swapUsed: 0
    property real swapTotal: 0
    property real swapUsage: 0
    
    property real gpuMemUsed: 0
    property real gpuMemTotal: 0
    property real gpuMemFree: 0
    property real gpuMemUsage: 0
    property real gpuPower: 0
    property string gpuTemp: "0°C"
    
    property string loadAvg1: "0.00"
    property string loadAvg5: "0.00"
    property string loadAvg15: "0.00"
    
    property int processCount: 0
    
    property real cpuFreqMin: 0
    property real cpuFreqMax: 0
    property real cpuFreqAvg: 0
    
    property var fanSpeeds: []
    property string fanSpeedText: "0 RPM"
    
    property var thermalZones: []
    property string cpuTemp: "0°C"
    property string maxTemp: "0°C"
    
    property string ipAddress: "N/A"
    property string gateway: "N/A"
    
    property real diskRead: 0
    property real diskWrite: 0
    property string diskIoText: "0 B/s"
    
    property real memBuffers: 0
    property real memCached: 0
    property real memAvailable: 0
    property real memActive: 0
    property real memInactive: 0
    
    property var cpuPerCore: []
    
    // Internal tracking
    property var _lastNetBytes: ({rx: 0, tx: 0, time: 0})
    property var _lastCpuStats: ({user: 0, nice: 0, system: 0, idle: 0, iowait: 0, irq: 0, softirq: 0, time: 0})
    property var _lastDiskIo: ({read: 0, write: 0, time: 0})

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
                if (sections.length < 25) return;

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

                // 10: Temperature (sensors)
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
                    networks.sort(function(a, b) {
                        if (a.active && !b.active) return -1;
                        if (!a.active && b.active) return 1;
                        return parseInt(b.signal) - parseInt(a.signal);
                    });
                    root.availableNetworks = networks;
                }

                // 17: Battery
                var battParts = sections[17].trim().split('|');
                if (battParts.length >= 2) {
                    root.batteryLevel = parseInt(battParts[0]) || 0;
                    root.batteryStatus = battParts[1].trim();
                    root.batteryCharging = root.batteryStatus.toLowerCase().includes("charging");
                }

                // 18: Swap
                var swapLine = sections[18].trim().split(/\s+/);
                if (swapLine.length >= 3) {
                    root.swapTotal = parseInt(swapLine[1]) || 0;
                    root.swapUsed = parseInt(swapLine[2]) || 0;
                    root.swapUsage = root.swapTotal > 0 ? Math.round((root.swapUsed / root.swapTotal) * 100) : 0;
                }

                // 19: GPU Memory
                var gpuMemParts = sections[19].trim().split(',');
                if (gpuMemParts.length >= 3) {
                    root.gpuMemUsed = parseInt(gpuMemParts[0]) || 0;
                    root.gpuMemTotal = parseInt(gpuMemParts[1]) || 0;
                    root.gpuMemFree = parseInt(gpuMemParts[2]) || 0;
                    root.gpuMemUsage = root.gpuMemTotal > 0 ? Math.round((root.gpuMemUsed / root.gpuMemTotal) * 100) : 0;
                }

                // 20: GPU Power
                root.gpuPower = parseFloat(sections[20].trim()) || 0;

                // 21: Load Average
                var loadParts = sections[21].trim().split(/\s+/);
                if (loadParts.length >= 3) {
                    root.loadAvg1 = loadParts[0];
                    root.loadAvg5 = loadParts[1];
                    root.loadAvg15 = loadParts[2];
                }

                // 22: Process Count
                root.processCount = parseInt(sections[22].trim()) || 0;

                // 23: CPU Frequency
                var freqParts = sections[23].trim().split(',');
                if (freqParts.length >= 3) {
                    root.cpuFreqMin = parseFloat(freqParts[0]) || 0;
                    root.cpuFreqMax = parseFloat(freqParts[1]) || 0;
                    root.cpuFreqAvg = parseFloat(freqParts[2]) || 0;
                }

                // 24: Fan Speed
                root.fanSpeedText = sections[24].trim() || "0 RPM";
                var fanLines = sections[24].trim().split('\n');
                var fans = [];
                for (var f = 0; f < fanLines.length; f++) {
                    var fanVal = fanLines[f].trim();
                    if (fanVal.length > 0) fans.push(fanVal);
                }
                root.fanSpeeds = fans;

                // 25: Thermal Zones
                var thermalLines = sections[25].trim().split('\n');
                var thermals = [];
                var maxT = 0;
                for (var t = 0; t < thermalLines.length; t++) {
                    var tLine = thermalLines[t].trim();
                    if (tLine.length > 0) {
                        thermals.push(tLine);
                        var tempMatch = tLine.match(/(\d+)/);
                        if (tempMatch) {
                            var tempVal = parseInt(tempMatch[1]);
                            if (tempVal > maxT) maxT = tempVal;
                        }
                    }
                }
                root.thermalZones = thermals;
                root.maxTemp = maxT > 0 ? Math.round(maxT / 1000) + "°C" : "0°C";
                root.cpuTemp = root.temperature !== "0°C" ? root.temperature : root.maxTemp;

                // 26: IP Address
                root.ipAddress = sections[26].trim() || "N/A";

                // 27: Memory Detail
                var memDetailParts = sections[27].trim().split(',');
                if (memDetailParts.length >= 5) {
                    root.memBuffers = parseInt(memDetailParts[0]) || 0;
                    root.memCached = parseInt(memDetailParts[1]) || 0;
                    root.memAvailable = parseInt(memDetailParts[2]) || 0;
                    root.memActive = parseInt(memDetailParts[3]) || 0;
                    root.memInactive = parseInt(memDetailParts[4]) || 0;
                }

                // 28: CPU Per-Core
                var coreLines = sections[28].trim().split('\n');
                var cores = [];
                for (var c = 0; c < coreLines.length; c++) {
                    var cLine = coreLines[c].trim();
                    if (cLine.length > 0) cores.push(cLine);
                }
                root.cpuPerCore = cores;

                // 29: Storage I/O
                var diskIoParts = sections[29].trim().split(',');
                if (diskIoParts.length >= 2) {
                    var diskRead = parseInt(diskIoParts[0]) || 0;
                    var diskWrite = parseInt(diskIoParts[1]) || 0;
                    var now = Date.now();
                    
                    if (root._lastDiskIo.time > 0) {
                        var dt = (now - root._lastDiskIo.time) / 1000;
                        if (dt > 0) {
                            var readBps = Math.max(0, (diskRead - root._lastDiskIo.read) / dt);
                            var writeBps = Math.max(0, (diskWrite - root._lastDiskIo.write) / dt);
                            root.diskIoText = root.formatBytes(readBps) + "/s R | " + root.formatBytes(writeBps) + "/s W";
                        }
                    }
                    root._lastDiskIo = {read: diskRead, write: diskWrite, time: now};
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
                  "nmcli -t -f active,ssid,signal,security dev wifi | head -20; echo '---SECTION---'; " +
                  "CAP=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1); STAT=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1); echo \"${CAP:-0}|${STAT:-Unknown}\"; echo '---SECTION---'; " +
                  "free -m | grep Swap:; echo '---SECTION---'; " +
                  "if command -v nvidia-smi >/dev/null; then nvidia-smi --query-gpu=memory.used,memory.total,memory.free --format=csv,noheader,nounits 2>/dev/null | head -1; else echo '0,0,0'; fi; echo '---SECTION---'; " +
                  "if command -v nvidia-smi >/dev/null; then nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits 2>/dev/null | head -1; else echo '0'; fi; echo '---SECTION---'; " +
                  "cat /proc/loadavg; echo '---SECTION---'; " +
                  "ps aux | wc -l; echo '---SECTION---'; " +
                  "MIN=$(cat /proc/cpuinfo | grep 'MHz' | awk '{print $4}' | sort -n | head -1); MAX=$(cat /proc/cpuinfo | grep 'MHz' | awk '{print $4}' | sort -n | tail -1); AVG=$(cat /proc/cpuinfo | grep 'MHz' | awk '{sum+=$4; n++} END {if(n>0) printf \"%.0f\", sum/n; else print 0}'); echo \"${MIN:-0},${MAX:-0},${AVG:-0}\"; echo '---SECTION---'; " +
                  "cat /sys/class/hwmon/hwmon*/fan*_input 2>/dev/null || echo '0 RPM'; echo '---SECTION---'; " +
                  "for tz in /sys/class/thermal/thermal_zone*/; do TYPE=$(cat ${tz}type 2>/dev/null); TEMP=$(cat ${tz}temp 2>/dev/null); if [ -n \"$TYPE\" ] && [ -n \"$TEMP\" ]; then echo \"${TYPE}: ${TEMP}\"; fi; done || echo 'N/A'; echo '---SECTION---'; " +
                  "ip -4 addr show $(ip route | grep default | awk '{print $5}' | head -1) 2>/dev/null | grep inet | awk '{print $2}' | cut -d/ -f1 || echo 'N/A'; echo '---SECTION---'; " +
                  "BUFF=$(grep Buffers /proc/meminfo | awk '{print $2}'); CACH=$(grep ^Cached /proc/meminfo | awk '{print $2}'); AVAIL=$(grep MemAvailable /proc/meminfo | awk '{print $2}'); ACT=$(grep ^Active /proc/meminfo | awk '{print $2}'); INACT=$(grep Inactive /proc/meminfo | awk '{print $2}'); echo \"${BUFF:-0},${CACH:-0},${AVAIL:-0},${ACT:-0},${INACT:-0}\"; echo '---SECTION---'; " +
                  "cat /proc/stat | grep '^cpu[0-9]' | awk '{idle=$5; total=0; for(i=2;i<=NF;i++) total+=$i; printf \"%s: %d%%\\n\", $1, (total-idle)*100/total}'; echo '---SECTION---'; " +
                  "DISK=$(cat /proc/diskstats | grep -E 'nvme[0-9]+n[0-9]+|sda ' | awk '{read+=$6*512; write+=$10*512} END {print read\",\"write}'); echo \"${DISK:-0,0}\"";
        infoProc.exec(["sh", "-c", cmd]);
    }
}
