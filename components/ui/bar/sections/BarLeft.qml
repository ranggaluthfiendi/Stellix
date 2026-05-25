import QtQuick
import QtQuick.Layouts
import qs.components.ui.bar.items
import qs.components.widgets.systemtray
import qs.components.elements
import qs.config
import qs.services
import qs.components.widgets.barpopup

RowLayout {
    id: root

    property real s: Scales.uiScale

    Layout.leftMargin: Theme.dp(14)
    spacing: 0

    Repeater {
        model: BarLayoutState.visibleLeftItems
        delegate: BarItemDelegate {}
    }

    Rectangle {
        visible: BarLayoutState.showSeparators && BarLayoutState.visibleLeftItems.length > 0 && (BarLayoutState.visibleCenterItems.length > 0 || BarLayoutState.visibleRightItems.length > 0)
        Layout.preferredWidth: 1
        Layout.preferredHeight: Theme.dp(14)
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: Theme.dp(6)
        color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.5)
    }
}
