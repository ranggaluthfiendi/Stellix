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

    Repeater {
        model: BarLayoutState.visibleRightItems
        delegate: BarItemDelegate {}
    }
}
