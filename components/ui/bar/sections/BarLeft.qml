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

    Layout.leftMargin: Theme.dp(14)
    spacing: 0

    Repeater {
        model: BarLayoutState.visibleLeftItems
        delegate: BarItemDelegate {}
    }
}
