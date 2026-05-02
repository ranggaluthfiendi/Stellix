import QtQuick
import QtQuick.Layouts
import qs.components.ui.bar.items
import qs.components.widgets.systemtray
import qs.config

RowLayout {
    id: root

    property real s: Scales.uiScale

    spacing: 8 * s
    Layout.leftMargin: 10 * s
    Layout.alignment: Qt.AlignVCenter

    WorkspaceItem {
    }

    SysTray {}
}
