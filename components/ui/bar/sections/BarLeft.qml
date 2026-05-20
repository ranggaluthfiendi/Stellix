import QtQuick
import QtQuick.Layouts
import qs.components.ui.bar.items
import qs.components.widgets.systemtray
import qs.components.elements
import qs.config
import qs.services
import qs.components.widgets.rightbar

RowLayout {
    id: root

    property real s: Scales.uiScale

    Layout.leftMargin: Theme.dp(10)
    spacing: Theme.dp(6)

    // ── App launcher button ──
    Rectangle {
        id: appLauncherBtn
        Layout.alignment: Qt.AlignVCenter
        width: Theme.dp(22)
        height: Theme.dp(22)
        color: "transparent"
        border.width: 0
        border.color: "transparent"
        radius: 0

        property bool hovered: false

        Grid {
            anchors.centerIn: parent
            columns: 2
            rowSpacing: Theme.dp(2)
            columnSpacing: Theme.dp(2)

            Repeater {
                model: 4
                Rectangle {
                    width: Theme.dp(5)
                    height: Theme.dp(5)
                    color: Theme.textPrimary
                    radius: Theme.dp(1)
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: appLauncherBtn.hovered ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08) : "transparent"
            border.width: appLauncherBtn.hovered ? 1 : 0
            border.color: appLauncherBtn.hovered ? Theme.textPrimary : "transparent"
            radius: 0
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton
            onEntered: appLauncherBtn.hovered = true
            onExited: appLauncherBtn.hovered = false
            onClicked: {
                if (RightBarState.launcherOpen) {
                    RightBarState.launcherOpen = false
                    launcher.close()
                } else {
                    RightBarState.closeAll()
                    RightBarState.launcherOpen = true
                    launcher.open()
                }
            }
        }
    }

    // ── Workspace switcher button ──
    

    WorkspaceItem {
    }

    SysTray {}
}
