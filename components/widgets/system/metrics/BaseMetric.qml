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

Item {
    id: root

    property string metricName: "CPU"
    property string stateKey: "Cpu"
    property string valueText: "0%"

    readonly property bool isVisible: BarLayoutState["desktop" + stateKey + "Show"]
    readonly property real metricScale: BarLayoutState["desktop" + stateKey + "Scale"] || 1.0
    readonly property real baseS: 0.6
    readonly property real s: Scales.uiScale * baseS * metricScale

    width: Screen.width
    height: Screen.height
    visible: isVisible && BarLayoutState.showScreenSystemStats

    property var sysSvc: BarLayoutState.getItem("systemInfo")

    readonly property color labelColor: {
        var mode = BarLayoutState["desktop" + stateKey + "ColorMode"] || "accent"
        if (mode === "white") return Qt.rgba(1, 1, 1, 0.8)
        if (mode === "black") return Qt.rgba(0, 0, 0, 0.8)
        if (mode === "success") return Theme.success
        if (mode === "danger") return Theme.danger
        return Theme.accent
    }

    readonly property color valueColor: {
        var mode = BarLayoutState["desktop" + stateKey + "ColorMode"] || "accent"
        if (mode === "white") return "#FFFFFF"
        if (mode === "black") return "#000000"
        return Theme.textPrimary
    }

    Item {
        id: container
        width: contentLayout.implicitWidth + 20 * s
        height: contentLayout.implicitHeight + 20 * s
        x: BarLayoutState["desktop" + stateKey + "X"]
        y: BarLayoutState["desktop" + stateKey + "Y"]
        rotation: BarLayoutState["desktop" + stateKey + "Rotation"]
        opacity: BarLayoutState.desktopWidgetsOpacity * (BarLayoutState["desktop" + stateKey + "Opacity"] || 1.0)

        ColumnLayout {
            id: contentLayout
            anchors.centerIn: parent
            spacing: 2 * s

            Text {
                text: root.metricName
                color: root.labelColor
                font.family: Typography.fontFamily
                font.pixelSize: 10 * s
                font.weight: Font.Bold
            }

            Text {
                text: root.valueText
                color: root.valueColor
                font.family: Typography.fontFamily
                font.pixelSize: 22 * s
                font.weight: Font.Bold
            }
        }

        Draggable {
            id: drag
            anchors.fill: parent
            target: container
            boundWidth: Screen.width
            boundHeight: Screen.height
            currentX: BarLayoutState["desktop" + stateKey + "X"]
            currentY: BarLayoutState["desktop" + stateKey + "Y"]
            onDragPositionChanged: (x, y) => {
                BarLayoutState["desktop" + stateKey + "X"] = x
                BarLayoutState["desktop" + stateKey + "Y"] = y
            }
            onRotateAction: (r) => {
                BarLayoutState["desktop" + stateKey + "Rotation"] = r
            }
        }
    }

    Component.onCompleted: {
        BarLayoutState.registerItem("metricDrag_" + stateKey.toLowerCase(), drag)
    }

    Component.onDestruction: {
        BarLayoutState.unregisterItem("metricDrag_" + stateKey.toLowerCase())
    }
}
