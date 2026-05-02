import QtQuick
import QtQuick.Layouts
import qs.components.elements
import qs.config
import qs.components.widgets.system

RowLayout {
    id: root

    property real s: Scales.uiScale


    BatteryWidget {
        s: 1.2 * root.s
    }

    StarShape {
        s: root.s
        width: 16 * s
        height: 16 * s
        color: Theme.textPrimary
    }
}
