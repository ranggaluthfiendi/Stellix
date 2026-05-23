import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.config
import qs.components.elements
import qs.services

Item {
    id: root

    property real s: 1.2 * Scales.uiScale

    implicitWidth: batteryRow.implicitWidth + Theme.dp(4)
    implicitHeight: BarLayoutState.barHeight * s

    readonly property var battery: UPower.displayDevice
    readonly property bool ready: battery && battery.ready
    readonly property real percentage: ready ? battery.percentage : 0
    readonly property int percentageInt: Math.round(percentage * 100)
    readonly property bool isLow: percentageInt <= BarLayoutState.batteryLowThreshold
    readonly property bool isCharging: ready && (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge)
    readonly property color batteryColor: isLow ? Theme.danger : Theme.success

    readonly property bool showIcon: BarLayoutState.batteryStyle !== "percentage"
    readonly property bool showPercentage: BarLayoutState.batteryStyle !== "icon"

    Row {
        id: batteryRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.dp(4)

        LightningShape {
            visible: root.isCharging && BarLayoutState.batteryShowCharging
            anchors.verticalCenter: parent.verticalCenter
            s: root.s * 0.7
            color: root.batteryColor
        }

        Text {
            visible: root.showPercentage
            text: root.ready ? (root.percentageInt + "%") : "--"
            color: root.batteryColor
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeSM || 12) * root.s)
            font.weight: Typography.weightMedium || Font.Normal
            anchors.verticalCenter: parent.verticalCenter
        }

        BatteryShape {
            visible: root.showIcon
            anchors.verticalCenter: parent.verticalCenter
            s: root.s
            level: root.percentage
            fillColor: root.batteryColor
            strokeColor: root.batteryColor
            backgroundColor: "transparent"
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: RightBarState.open = !RightBarState.open
    }
}
