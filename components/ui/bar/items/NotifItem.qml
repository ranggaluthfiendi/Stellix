import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components.widgets.rightbar
import qs.components.elements

Rectangle {
    id: notifBox
    Layout.alignment: Qt.AlignVCenter
    width: Theme.dp(22)
    height: Theme.dp(22)
    color: "transparent"
    border.width: 0
    border.color: "transparent"
    radius: 0

    readonly property int count: RightBarState.notifCount
    property bool hovered: false

    IconBell {
        anchors.centerIn: parent
        iconSize: Theme.dp(13)
        iconColor: Theme.textPrimary
    }

    Rectangle {
        id: badge
        visible: notifBox.count > 0 && !RightBarState.dndEnabled
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: -Theme.dp(4)
        anchors.rightMargin: -Theme.dp(4)
        width: Math.max(Theme.dp(14), badgeText.implicitWidth + Theme.dp(4))
        height: Theme.dp(14)
        color: Theme.danger
        radius: Theme.dp(7)
        z: 1

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: notifBox.count > 99 ? "99+" : String(notifBox.count)
            color: "white"
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeXXS || 7) * Scales.uiScale)
            font.weight: Typography.weightBold || Font.Bold
        }
    }

    Rectangle {
        anchors.fill: parent
        color: notifBox.hovered ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08) : "transparent"
        border.width: notifBox.hovered ? 1 : 0
        border.color: notifBox.hovered ? Theme.textPrimary : "transparent"
        radius: 0
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onEntered: notifBox.hovered = true
        onExited: notifBox.hovered = false
        onClicked: {
            RightBarState.closeAll()
            RightBarState.notifPanelRequested = true
        }
    }
}
