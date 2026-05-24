import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.components.elements

Item {
    id: root

    property real baseS: 0.6
    property real s: Scales.uiScale * baseS * BarLayoutState.desktopStatsScale

    width: Screen.width
    height: Screen.height

    readonly property real screenW: Screen.width
    readonly property real screenH: Screen.height

    property var sysSvc: BarLayoutState.getItem("systemInfo")

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

        readonly property string netDownText: {
            var v = BarLayoutState.desktopStatsNetDownLabel
            return (v !== undefined && v !== "") ? v : "DOWN"
        }
        readonly property string netUpText: {
            var v = BarLayoutState.desktopStatsNetUpLabel
            return (v !== undefined && v !== "") ? v : "UP"
        }

        // Components for reuse
        Component {
            id: cpuComp
            ColumnLayout {
                spacing: 2 * s
                visible: BarLayoutState.desktopStatsShowCpu
                Text { text: "CPU"; color: container.labelColor; font.pixelSize: 10 * s; font.weight: Font.Bold }
                Text {
                    text: sysSvc ? (Math.round(sysSvc.cpuCount * 4) + "%") : "0%"
                    color: container.valueColor; font.pixelSize: 22 * s; font.weight: Font.Bold
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
                            if (sysSvc.gpus[i].includes("%")) return sysSvc.gpus[i]
                        }
                        var first = sysSvc.gpus[0].trim()
                        if (first.endsWith(")")) first = first.substring(0, first.length - 1)
                        var parts = first.split(' ')
                        return parts[parts.length - 1]
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
                    text: sysSvc ? (Math.round(sysSvc.memUsed / 1024) + " GB") : "0 GB"
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
                    color: container.valueColor; font.pixelSize: 14 * s; font.weight: Font.Bold
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
            RowLayout {
                spacing: 20 * s
                visible: BarLayoutState.desktopStatsShowNet
                ColumnLayout {
                    spacing: 2 * s
                    Layout.alignment: Qt.AlignHCenter
                    Text { text: root.netDownText !== undefined ? root.netDownText : "DOWN"; color: BarLayoutState.desktopStatsColorMode === "accent" ? Theme.success : container.labelColor; font.pixelSize: 9 * s; font.weight: Font.Bold; horizontalAlignment: Text.AlignHCenter }
                    Text { text: sysSvc ? sysSvc.netDown : "0 KB/s"; color: container.valueColor; font.pixelSize: 14 * s; font.weight: Font.Medium; horizontalAlignment: Text.AlignHCenter }
                }
                ColumnLayout {
                    spacing: 2 * s
                    Layout.alignment: Qt.AlignHCenter
                    Text { text: root.netUpText !== undefined ? root.netUpText : "UP"; color: BarLayoutState.desktopStatsColorMode === "accent" ? Theme.danger : container.labelColor; font.pixelSize: 9 * s; font.weight: Font.Bold; horizontalAlignment: Text.AlignHCenter }
                    Text { text: sysSvc ? sysSvc.netUp : "0 KB/s"; color: container.valueColor; font.pixelSize: 14 * s; font.weight: Font.Medium; horizontalAlignment: Text.AlignHCenter }
                }
            }
        }

        // --- Main Layout Selector ---
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
            Loader { sourceComponent: netComp; visible: BarLayoutState.desktopStatsShowNet; Layout.columnSpan: BarLayoutState.desktopStatsLayout === "compact" ? 2 : 1 }
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

    Component.onCompleted: {
        BarLayoutState.registerItem("desktopStatsDrag", drag)
    }

    Component.onDestruction: {
        BarLayoutState.unregisterItem("desktopStatsDrag")
    }
}
