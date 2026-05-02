import QtQuick
import QtQuick.Layouts
import qs.components.ui.bar.items
import qs.config

RowLayout {
    id: root

    property real s: Scales.uiScale

    Layout.rightMargin: 10 * s
    Layout.alignment: Qt.AlignVCenter

    MenuItem {
    }
}
