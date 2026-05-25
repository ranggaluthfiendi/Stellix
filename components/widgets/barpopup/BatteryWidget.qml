import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.config
import qs.components.elements
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

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

    readonly property var activeElements: {
        var result = []
        for (var i = 0; i < BarLayoutState.batteryElements.length; i++) {
            var el = BarLayoutState.batteryElements[i]
            if (el === "charging" && !BarLayoutState.batteryShowCharging) continue
            if (el === "icon" && !showIcon) continue
            if (el === "percentage" && !showPercentage) continue
            result.push(el)
        }
        return result
    }

    Row {
        id: batteryRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.dp(4)
        leftPadding: Theme.dp(4)
        rightPadding: Theme.dp(4)

        Repeater {
            model: root.activeElements
            delegate: Loader {
                required property string modelData
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: {
                    if (modelData === "charging") return chargingComp
                    if (modelData === "percentage") return percentageComp
                    if (modelData === "icon") return iconComp
                    return null
                }
            }
        }
    }

    Component {
        id: chargingComp
        LightningShape {
            visible: root.isCharging
            s: root.s * 0.7
            color: root.batteryColor
        }
    }

    Component {
        id: percentageComp
        Text {
            text: root.ready ? (root.percentageInt + "%") : "--"
            color: root.batteryColor
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeSM || 12) * root.s)
            font.weight: Typography.weightMedium || Font.Normal
        }
    }

    Component {
        id: iconComp
        BatteryShape {
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
        onClicked: BarPopupState.open = !BarPopupState.open
    }
}
