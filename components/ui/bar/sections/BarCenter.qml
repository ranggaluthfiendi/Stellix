import QtQuick
import qs.components.ui.bar.items
import qs.config

Item {
    id: root

    implicitHeight: Dimens.barHeight * Scales.uiScale
    implicitWidth: clockItem.implicitWidth + Theme.dp(8)

    ClockItem {
        id: clockItem
        anchors.centerIn: parent
    }
}
