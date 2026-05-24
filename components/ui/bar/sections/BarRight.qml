import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.components.ui.bar.items
import qs.components.widgets.rightbar
import qs.components.elements
import qs.config
import qs.services

RowLayout {
    id: root

    property real s: Scales.uiScale

    implicitHeight: BarLayoutState.barHeight * s
    Layout.alignment: Qt.AlignVCenter
    spacing: 0

    // Leading divider for Right section - only if it follows another section
    Rectangle {
        visible: BarLayoutState.showSeparators && BarLayoutState.visibleRightItems.length > 0 && (BarLayoutState.visibleLeftItems.length > 0 || BarLayoutState.visibleCenterItems.length > 0)
        Layout.preferredWidth: 1
        Layout.preferredHeight: Theme.dp(14)
        Layout.alignment: Qt.AlignVCenter
        Layout.rightMargin: Theme.dp(6)
        color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.5)
    }

    Repeater {
        model: BarLayoutState.visibleRightItems
        delegate: BarItemDelegate {}
    }
}
