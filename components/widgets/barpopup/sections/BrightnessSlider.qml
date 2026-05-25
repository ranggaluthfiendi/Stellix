import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components.elements

Rectangle {
    id: root

    Layout.fillWidth: true
    Layout.preferredHeight: Theme.dp(44)
    color: Theme.bgPrimary
    border.width: 1
    border.color: Theme.border
    radius: 0

    property var brightnessService: null
    property real s: Scales.uiScale

    readonly property real percentage: brightnessService ? brightnessService.percentage : 0
    readonly property bool ready: brightnessService ? brightnessService.ready : false

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.dp(6)
        spacing: Theme.dp(6)

        IconBrightness {
            Layout.preferredWidth: Theme.dp(16)
            Layout.preferredHeight: Theme.dp(16)
            Layout.alignment: Qt.AlignVCenter
            iconColor: Theme.textPrimary
            iconSize: Theme.dp(12)
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(8)
            color: Theme.bgSecondary
            border.width: 1
            border.color: Theme.border
            radius: 0

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: root.ready
                    ? Math.max(0, Math.min(parent.width, (root.percentage / 100) * parent.width))
                    : 0
                color: Theme.accentSoft
                radius: 0
            }

            MouseArea {
                id: brightnessMouse
                anchors.fill: parent
                property bool dragging: false
                cursorShape: Qt.SizeHorCursor
                onPressed: function(mouse) {
                    dragging = true
                    if (brightnessService) brightnessService.setPercentage(Math.round((mouse.x / brightnessMouse.width) * 100))
                }
                onPositionChanged: function(mouse) {
                    if (dragging && brightnessService) brightnessService.setPercentage(Math.round((mouse.x / brightnessMouse.width) * 100))
                }
                onReleased: dragging = false
                onWheel: function(wheel) {
                    if (!brightnessService) return
                    var pct = brightnessService.percentage
                    brightnessService.setPercentage(Math.round(pct + (wheel.angleDelta.y > 0 ? 5 : -5)))
                }
            }
        }

        Text {
            text: root.ready ? root.percentage + "%" : "--"
            color: Theme.textMuted
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
        }
    }
}
