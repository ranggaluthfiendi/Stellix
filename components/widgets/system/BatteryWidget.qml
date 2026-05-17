import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Services.UPower
import qs.config
import qs.components.elements
import qs.components.widgets.rightbar

Item {
    id: root

    property real s: Scales.uiScale
    property bool showLabel: true

    width: showLabel ? 56 * s : 16 * s
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
        spacing: 2 * root.s

        Item {
            Layout.preferredWidth: 36 * root.s
            Layout.minimumWidth: 36 * root.s
            Layout.maximumWidth: 36 * root.s
            Layout.preferredHeight: parent.height

            Text {
                id: label
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                text: root.ready ? root.percentageInt + "%" : "--"

                color: Theme.textPrimary
                font.family: Typography.fontFamily
                font.pixelSize: Typography.sizeXS * root.s
                font.weight: Typography.weightNormal
            }

            LightningShape {
                id: lightning
                visible: root.charging
                s: root.s * 0.7

                anchors.verticalCenter: label.verticalCenter
                anchors.right: label.left
                anchors.rightMargin: 0

                opacity: root.charging ? 1 : 0

                SequentialAnimation on opacity {
                    running: root.charging
                    loops: Animation.Infinite

                    NumberAnimation { from: 1; to: 0.2; duration: 800 }
                    NumberAnimation { from: 0.2; to: 1; duration: 500 }
                }
            }
        }

        BatteryShape {
            s: root.s
            level: root.percentage
            fillColor: root.fillColor
            strokeColor: Theme.textPrimary

            Layout.preferredWidth: 16 * root.s
            Layout.minimumWidth: 16 * root.s
            Layout.maximumWidth: 16 * root.s
            Layout.preferredHeight: 16 * root.s
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            RightBarState.toggle()
        }
    }
}
