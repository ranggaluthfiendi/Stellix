import qs.components.utils
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import qs.components.elements
import "metrics"

Item {
    id: root

    property real baseS: 0.6
    property real s: Scales.uiScale * baseS * BarLayoutState.desktopStatsScale

    width: Screen.width
    height: Screen.height

    readonly property real screenW: Screen.width
    readonly property real screenH: Screen.height

    property var sysSvc: BarLayoutState.getItem("systemInfo")

    readonly property bool isCombined: BarLayoutState.statsDisplayMode === "combined"

    // --- Combined Mode ---
    Item {
        id: combinedContainer
        visible: isCombined
        width: Screen.width
        height: Screen.height

        Item {
            id: container
            width: mainLayout.implicitWidth + 20 * s
            height: mainLayout.implicitHeight + 20 * s

            x: BarLayoutState.desktopStatsX
            y: BarLayoutState.desktopStatsY
            rotation: BarLayoutState.desktopStatsRotation

            opacity: BarLayoutState.desktopWidgetsOpacity * BarLayoutState.desktopStatsOpacity

            readonly property color labelColor: {
                if (BarLayoutState.desktopStatsColorMode === "white") return Qt.rgba(1, 1, 1, 0.8)
                if (BarLayoutState.desktopStatsColorMode === "black") return Qt.rgba(0, 0, 0, 0.8)
                return Theme.accent
            }

            readonly property color valueColor: {
                if (BarLayoutState.desktopStatsColorMode === "white") return "#FFFFFF"
                if (BarLayoutState.desktopStatsColorMode === "black") return "#000000"
                return Theme.textPrimary
            }

            readonly property color netDownLabelColor: {
                var mode = BarLayoutState.desktopStatsNetDownLabelColorMode || "success"
                if (mode === "white") return Qt.rgba(1, 1, 1, 0.8)
                if (mode === "black") return Qt.rgba(0, 0, 0, 0.8)
                if (mode === "success") return Theme.success
                if (mode === "danger") return Theme.danger
                return Theme.accent
            }
            readonly property color netUpLabelColor: {
                var mode = BarLayoutState.desktopStatsNetUpLabelColorMode || "danger"
                if (mode === "white") return Qt.rgba(1, 1, 1, 0.8)
                if (mode === "black") return Qt.rgba(0, 0, 0, 0.8)
                if (mode === "success") return Theme.success
                if (mode === "danger") return Theme.danger
                return Theme.accent
            }

            property int _netLabelKey: 0
            Connections {
                target: BarLayoutState
                function onDesktopStatsNetDownLabelChanged() { container._netLabelKey++ }
                function onDesktopStatsNetUpLabelChanged() { container._netLabelKey++ }
                function onDesktopStatsNetDownLabelColorModeChanged() { container._netLabelKey++ }
                function onDesktopStatsNetUpLabelColorModeChanged() { container._netLabelKey++ }
            }

            readonly property string netDownText: {
                container._netLabelKey
                var v = BarLayoutState.desktopStatsNetDownLabel
                return (v !== undefined && v !== "") ? v : "DOWN"
            }
            readonly property string netUpText: {
                container._netLabelKey
                var v = BarLayoutState.desktopStatsNetUpLabel
                return (v !== undefined && v !== "") ? v : "UP"
            }

            Component {
                id: cpuComp
                ColumnLayout {
                    spacing: 2 * s
                    visible: BarLayoutState.desktopStatsShowCpu
                    Text { text: "CPU"; color: container.labelColor; font.pixelSize: 10 * s; font.weight: Font.Bold }
                    Text {
                        text: sysSvc ? (Math.round(sysSvc.cpuUsage) + "%") : "0%"
                        color: container.valueColor; font.pixelSize: 18 * s; font.weight: Font.Bold
                    }
                }
            }

            Component {
                id: gpuComp
                ColumnLayout {
                    spacing: 2 * s
                    visible: BarLayoutState.desktopStatsShowGpu
                    Text { text: "GPU"; color: container.labelColor; font.pixelSize: 10 * s; font.weight: Font.Bold }
                    Text {
                        text: {
                            if (!sysSvc || sysSvc.gpus.length === 0) return "N/A"
                            for (var i = 0; i < sysSvc.gpus.length; i++) {
                                var gpu = sysSvc.gpus[i]
                                if (gpu.includes("NVIDIA") && gpu.includes("%")) {
                                    var parts = gpu.split(":")
                                    if (parts.length >= 2) return parts[1].trim()
                                }
                            }
                            for (var j = 0; j < sysSvc.gpus.length; j++) {
                                if (sysSvc.gpus[j].includes("%")) return sysSvc.gpus[j]
                            }
                            return "N/A"
                        }
                        color: container.valueColor; font.pixelSize: 18 * s; font.weight: Font.Bold
                        elide: Text.ElideRight
                    }
                }
            }

            Component {
                id: memComp
                ColumnLayout {
                    spacing: 2 * s
                    visible: BarLayoutState.desktopStatsShowMem
                    Text { text: "MEMORY"; color: container.labelColor; font.pixelSize: 10 * s; font.weight: Font.Bold }
                    Text {
                        text: sysSvc ? (Math.round(sysSvc.memUsage) + "%") : "0%"
                        color: container.valueColor; font.pixelSize: 18 * s; font.weight: Font.Bold
                    }
                }
            }

            Component {
                id: diskComp
                ColumnLayout {
                    spacing: 2 * s
                    visible: BarLayoutState.desktopStatsShowDisk
                    Text { text: "DISK"; color: container.labelColor; font.pixelSize: 10 * s; font.weight: Font.Bold }
                    Text {
                        text: sysSvc && sysSvc.diskUsage ? sysSvc.diskUsage : "0%"
                        color: container.valueColor; font.pixelSize: 18 * s; font.weight: Font.Bold
                    }
                }
            }

            Component {
                id: uptimeComp
                ColumnLayout {
                    spacing: 2 * s
                    visible: BarLayoutState.desktopStatsShowUptime
                    Text { text: "UPTIME"; color: container.labelColor; font.pixelSize: 10 * s; font.weight: Font.Bold }
                    Text {
                        text: sysSvc && sysSvc.uptime ? sysSvc.uptime : "0d 0h"
                        color: container.valueColor; font.pixelSize: 18 * s; font.weight: Font.Bold
                    }
                }
            }

            Component {
                id: tempComp
                ColumnLayout {
                    spacing: 2 * s
                    visible: BarLayoutState.desktopStatsShowTemp
                    Text { text: "TEMP"; color: container.labelColor; font.pixelSize: 10 * s; font.weight: Font.Bold }
                    Text {
                        text: sysSvc && sysSvc.temperature ? sysSvc.temperature : "0°C"
                        color: container.valueColor; font.pixelSize: 18 * s; font.weight: Font.Bold
                    }
                }
            }

            Component {
                id: netComp
                ColumnLayout {
                    spacing: 2 * s
                    visible: BarLayoutState.desktopStatsShowNet
                    RowLayout {
                        spacing: 16 * s
                        Layout.alignment: Qt.AlignHCenter
                        ColumnLayout {
                            spacing: 2 * s
                            Layout.alignment: Qt.AlignHCenter
                        Text { text: container.netDownText; color: container.netDownLabelColor; font.pixelSize: 10 * s; font.weight: Font.Bold; horizontalAlignment: Text.AlignHCenter }
                        Text { text: sysSvc ? sysSvc.netDown : "0 KB/s"; color: container.valueColor; font.pixelSize: 18 * s; font.weight: Font.Bold; horizontalAlignment: Text.AlignHCenter }
                    }
                    ColumnLayout {
                        spacing: 2 * s
                        Layout.alignment: Qt.AlignHCenter
                        Text { text: container.netUpText; color: container.netUpLabelColor; font.pixelSize: 10 * s; font.weight: Font.Bold; horizontalAlignment: Text.AlignHCenter }
                            Text { text: sysSvc ? sysSvc.netUp : "0 KB/s"; color: container.valueColor; font.pixelSize: 18 * s; font.weight: Font.Bold; horizontalAlignment: Text.AlignHCenter }
                        }
                    }
                }
            }

            Component {
                id: batteryComp
                ColumnLayout {
                    spacing: 2 * s
                    visible: BarLayoutState.desktopStatsShowBattery
                    Text { text: "BATTERY"; color: container.labelColor; font.pixelSize: 10 * s; font.weight: Font.Bold }
                    Text {
                        text: sysSvc ? (Math.round(sysSvc.batteryLevel) + "%") : "0%"
                        color: container.valueColor; font.pixelSize: 18 * s; font.weight: Font.Bold
                    }
                }
            }

            Component {
                id: swapComp
                ColumnLayout {
                    spacing: 2 * s
                    visible: BarLayoutState.desktopStatsShowSwap
                    Text { text: "SWAP"; color: container.labelColor; font.pixelSize: 10 * s; font.weight: Font.Bold }
                    Text {
                        text: sysSvc ? (Math.round(sysSvc.swapUsage) + "%") : "0%"
                        color: container.valueColor; font.pixelSize: 18 * s; font.weight: Font.Bold
                    }
                }
            }

            Component {
                id: gpuMemComp
                ColumnLayout {
                    spacing: 2 * s
                    visible: BarLayoutState.desktopStatsShowGpuMem
                    Text { text: "GPU MEM"; color: container.labelColor; font.pixelSize: 10 * s; font.weight: Font.Bold }
                    Text {
                        text: sysSvc && sysSvc.gpuMemTotal > 0 ? (Math.round(sysSvc.gpuMemUsage) + "%") : "N/A"
                        color: container.valueColor; font.pixelSize: 18 * s; font.weight: Font.Bold
                    }
                }
            }

            Component {
                id: loadComp
                ColumnLayout {
                    spacing: 2 * s
                    visible: BarLayoutState.desktopStatsShowLoad
                    Text { text: "LOAD"; color: container.labelColor; font.pixelSize: 10 * s; font.weight: Font.Bold }
                    Text {
                        text: sysSvc ? sysSvc.loadAvg1 : "0.00"
                        color: container.valueColor; font.pixelSize: 18 * s; font.weight: Font.Bold
                    }
                }
            }

            Component {
                id: processComp
                ColumnLayout {
                    spacing: 2 * s
                    visible: BarLayoutState.desktopStatsShowProcess
                    Text { text: "PROCESS"; color: container.labelColor; font.pixelSize: 10 * s; font.weight: Font.Bold }
                    Text {
                        text: sysSvc ? sysSvc.processCount.toString() : "0"
                        color: container.valueColor; font.pixelSize: 18 * s; font.weight: Font.Bold
                    }
                }
            }

            Component {
                id: fanComp
                ColumnLayout {
                    spacing: 2 * s
                    visible: BarLayoutState.desktopStatsShowFan
                    Text { text: "FAN"; color: container.labelColor; font.pixelSize: 10 * s; font.weight: Font.Bold }
                    Text {
                        text: sysSvc ? sysSvc.fanSpeedText : "0 RPM"
                        color: container.valueColor; font.pixelSize: 18 * s; font.weight: Font.Bold
                    }
                }
            }

            Component {
                id: ipComp
                ColumnLayout {
                    spacing: 2 * s
                    visible: BarLayoutState.desktopStatsShowIp
                    Text { text: "IP"; color: container.labelColor; font.pixelSize: 10 * s; font.weight: Font.Bold }
                    Text {
                        text: sysSvc ? sysSvc.ipAddress : "N/A"
                        color: container.valueColor; font.pixelSize: 18 * s; font.weight: Font.Bold
                    }
                }
            }

            GridLayout {
                id: mainLayout
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10 * s

                columns: BarLayoutState.desktopStatsLayout === "inline" ? 10 : (BarLayoutState.desktopStatsLayout === "compact" ? 2 : 1)
                columnSpacing: 30 * s
                rowSpacing: 12 * s

                Loader { sourceComponent: cpuComp; visible: BarLayoutState.desktopStatsShowCpu }
                Loader { sourceComponent: gpuComp; visible: BarLayoutState.desktopStatsShowGpu }
                Loader { sourceComponent: memComp; visible: BarLayoutState.desktopStatsShowMem }
                Loader { sourceComponent: diskComp; visible: BarLayoutState.desktopStatsShowDisk }
                Loader { sourceComponent: uptimeComp; visible: BarLayoutState.desktopStatsShowUptime }
                Loader { sourceComponent: tempComp; visible: BarLayoutState.desktopStatsShowTemp }
                Loader { sourceComponent: netComp; visible: BarLayoutState.desktopStatsShowNet; Layout.columnSpan: BarLayoutState.desktopStatsLayout === "compact" ? 2 : 2; active: BarLayoutState.desktopStatsShowNet }
                Loader { sourceComponent: batteryComp; visible: BarLayoutState.desktopStatsShowBattery }
                Loader { sourceComponent: swapComp; visible: BarLayoutState.desktopStatsShowSwap }
                Loader { sourceComponent: gpuMemComp; visible: BarLayoutState.desktopStatsShowGpuMem }
                Loader { sourceComponent: loadComp; visible: BarLayoutState.desktopStatsShowLoad }
                Loader { sourceComponent: processComp; visible: BarLayoutState.desktopStatsShowProcess }
                Loader { sourceComponent: fanComp; visible: BarLayoutState.desktopStatsShowFan }
                Loader { sourceComponent: ipComp; visible: BarLayoutState.desktopStatsShowIp }
            }

            Draggable {
                id: drag
                anchors.fill: parent
                target: container
                boundWidth: root.screenW
                boundHeight: root.screenH
                defaultX: 40 * Scales.uiScale
                defaultY: screenH - (mainLayout.implicitHeight + 20 * s) - 160 * Scales.uiScale
                currentX: BarLayoutState.desktopStatsX
                currentY: BarLayoutState.desktopStatsY
                onDragPositionChanged: (x, y) => {
                    BarLayoutState.desktopStatsX = x
                    BarLayoutState.desktopStatsY = y
                }
                onRotateAction: (r) => {
                    BarLayoutState.desktopStatsRotation = r
                }
            }
        }
    }

    // --- Individual Mode ---
    Item {
        id: individualContainer
        visible: !isCombined
        width: Screen.width
        height: Screen.height

        CpuMetric { visible: BarLayoutState.desktopCpuShow && BarLayoutState.showScreenSystemStats }
        GpuMetric { visible: BarLayoutState.desktopGpuShow && BarLayoutState.showScreenSystemStats }
        MemMetric { visible: BarLayoutState.desktopMemShow && BarLayoutState.showScreenSystemStats }
        DiskMetric { visible: BarLayoutState.desktopDiskShow && BarLayoutState.showScreenSystemStats }
        UptimeMetric { visible: BarLayoutState.desktopUptimeShow && BarLayoutState.showScreenSystemStats }
        TempMetric { visible: BarLayoutState.desktopTempShow && BarLayoutState.showScreenSystemStats }
        NetDownMetric { visible: BarLayoutState.desktopNetDownShow && BarLayoutState.showScreenSystemStats }
        NetUpMetric { visible: BarLayoutState.desktopNetUpShow && BarLayoutState.showScreenSystemStats }
        BatteryMetric { visible: BarLayoutState.desktopBatteryShow && BarLayoutState.showScreenSystemStats }
        SwapMetric { visible: BarLayoutState.desktopSwapShow && BarLayoutState.showScreenSystemStats }
        GpuMemMetric { visible: BarLayoutState.desktopGpuMemShow && BarLayoutState.showScreenSystemStats }
        LoadMetric { visible: BarLayoutState.desktopLoadShow && BarLayoutState.showScreenSystemStats }
        ProcessMetric { visible: BarLayoutState.desktopProcessShow && BarLayoutState.showScreenSystemStats }
        FanMetric { visible: BarLayoutState.desktopFanShow && BarLayoutState.showScreenSystemStats }
        IpMetric { visible: BarLayoutState.desktopIpShow && BarLayoutState.showScreenSystemStats }
    }

    Component.onCompleted: {
        BarLayoutState.registerItem("desktopStatsDrag", isCombined ? combinedContainer.children[0].children[combinedContainer.children[0].children.length - 1] : null)
    }

    Component.onDestruction: {
        BarLayoutState.unregisterItem("desktopStatsDrag")
    }
}
