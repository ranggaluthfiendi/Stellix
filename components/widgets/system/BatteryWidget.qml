import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Services.UPower
import qs.config
import qs.components.elements

Item {
    id: root

    property real s: Scales.uiScale
    property bool showLabel: true

    width: showLabel ? 36 * s : 16 * s
    height: 16 * s

    readonly property var battery: UPower.displayDevice
    readonly property bool ready: battery && battery.ready

    readonly property real percentage: ready ? battery.percentage : 0
    readonly property int percentageInt: Math.round(percentage * 100)

    readonly property bool charging: ready && (
        battery.state === UPowerDeviceState.Charging ||
        battery.state === UPowerDeviceState.PendingCharge
    )

    readonly property color fillColor: {
        if (!ready) return Theme.textMuted
        if (percentage > 0.5) return Theme.success
        if (percentage > 0.2) return Theme.warning
        return Theme.danger
    }

    RowLayout {
        anchors.fill: parent
        spacing: 5 * root.s

        Text {
            visible: root.showLabel

            text: root.ready
                  ? (root.charging ? "⚡ " : "") + root.percentageInt + "%"
                  : "--"

            color: Theme.textPrimary
            font.family: Typography.fontFamily
            font.pixelSize: Typography.sizeXS * root.s
            font.weight: Typography.weightNormal

            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter

            Layout.preferredHeight: parent.height
        }

        BatteryShape {
            s: root.s
            level: root.percentage
            fillColor: root.fillColor
            strokeColor: Theme.textPrimary

            Layout.preferredWidth: 16 * root.s
            Layout.preferredHeight: 16 * root.s
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
