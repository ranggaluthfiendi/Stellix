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
    implicitHeight: Dimens.barHeight * s

    readonly property var battery: UPower.displayDevice
    readonly property bool ready: battery && battery.ready
    readonly property real percentage: ready ? battery.percentage : 0
    readonly property int percentageInt: Math.round(percentage * 100)

    Row {
        id: batteryRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.dp(4)

        Text {
            text: root.ready ? (root.percentageInt + "%") : "--"
            color: Theme.textPrimary
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeSM || 12) * root.s)
            font.weight: Typography.weightMedium || Font.Normal
            anchors.verticalCenter: parent.verticalCenter
        }

        BatteryShape {
            anchors.verticalCenter: parent.verticalCenter
            s: root.s
            level: root.percentage
            fillColor: root.percentage > 0.2 ? Theme.textPrimary : Theme.danger
            strokeColor: Theme.textPrimary
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
