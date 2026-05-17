import QtQuick
import QtQuick.Layouts
import qs.components.ui.bar.items
import qs.components.widgets.systemtray
import qs.components.elements
import qs.config

RowLayout {
    id: root

    property real s: Scales.uiScale

    Layout.leftMargin: Theme.dp(10)
    spacing: Theme.dp(6)

    // ── Workspace switcher button ──
    Rectangle {
        id: wsBox
        Layout.alignment: Qt.AlignVCenter
        width: Theme.dp(22)
        height: Theme.dp(22)
        color: "transparent"
        border.width: 0
        border.color: "transparent"
        radius: 0

        property bool hovered: false

        IconWorkspaces {
            anchors.centerIn: parent
            iconSize: Theme.dp(13)
            iconColor: Theme.textPrimary
        }

        Rectangle {
            anchors.fill: parent
            color: wsBox.hovered ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08) : "transparent"
            border.width: wsBox.hovered ? 1 : 0
            border.color: wsBox.hovered ? Theme.textPrimary : "transparent"
            radius: 0
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton
            onEntered: wsBox.hovered = true
            onExited: wsBox.hovered = false
            onClicked: {
                RightBarState.workspaceSwitcherOpen = !RightBarState.workspaceSwitcherOpen
            }
        }
    }

    WorkspaceItem {
    }

    SysTray {}
}
