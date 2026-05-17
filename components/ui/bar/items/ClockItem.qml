import QtQuick
import Quickshell
import qs.services
import qs.config
import qs.components.widgets.rightbar

Item {
    id: root

    property real s: Scales.uiScale

    implicitHeight: Dimens.barHeight * s
    implicitWidth: timeText.implicitWidth + tzText.implicitWidth + Theme.dp(4)

    Text {
        id: timeText
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -tzText.implicitWidth / 2 - Theme.dp(1)
        text: Time.time
        color: Theme.textPrimary
        font.family: Typography.fontFamily
        font.pixelSize: Math.round((Typography.sizeMD || 12) * s)
        font.weight: Typography.weightMedium || Font.Normal
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        id: tzText
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: timeText.implicitWidth / 2 + Theme.dp(1)
        text: Time.timezone
        color: Theme.textMuted
        font.family: Typography.fontFamily
        font.pixelSize: Math.round((Typography.sizeXS || 9) * s)
        font.weight: Typography.weightRegular || Font.Normal
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: {
            RightBarState.calendarOpen = !RightBarState.calendarOpen
            RightBarState.calendarMonthOffset = 0
        }
    }
}
