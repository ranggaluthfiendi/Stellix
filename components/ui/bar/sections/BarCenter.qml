import QtQuick
import QtQuick.Layouts
import qs.components.ui.bar.items
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

RowLayout {
    id: root

    spacing: 0

    // Leading divider for Center - always visible if Center has items
    Rectangle {
        visible: BarLayoutState.showSeparators && BarLayoutState.visibleCenterItems.length > 0
        Layout.preferredWidth: 1
        Layout.preferredHeight: Theme.dp(14)
        Layout.alignment: Qt.AlignVCenter
        Layout.rightMargin: Theme.dp(6)
        color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.5)
    }

    Repeater {
        model: BarLayoutState.visibleCenterItems
        delegate: RowLayout {
            id: centerDelegate
            required property string modelData
            required property int index

            spacing: 0

            BarItemDelegate {
                modelData: centerDelegate.modelData
                index: centerDelegate.index
            }
        }
    }

    // Trailing divider for Center - always visible if Center has items
    Rectangle {
        visible: BarLayoutState.showSeparators && BarLayoutState.visibleCenterItems.length > 0
        Layout.preferredWidth: 1
        Layout.preferredHeight: Theme.dp(14)
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: Theme.dp(6)
        color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.5)
    }
}
