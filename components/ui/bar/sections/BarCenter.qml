import QtQuick
import QtQuick.Layouts
import qs.components.ui.bar.items
import qs.config
import qs.services

RowLayout {
    id: root

    spacing: 0

    Repeater {
        model: BarLayoutState.visibleCenterItems
        delegate: RowLayout {
            id: centerDelegate
            required property string modelData
            required property int index

            spacing: 0

            Rectangle {
                visible: BarLayoutState.showSeparators && BarLayoutState.visibleCenterItems.length === 1
                Layout.preferredWidth: 1
                Layout.preferredHeight: Theme.dp(14)
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: Theme.dp(6)
                color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.5)
            }

            BarItemDelegate {
                modelData: centerDelegate.modelData
                index: centerDelegate.index
                showTrailingSeparator: BarLayoutState.visibleCenterItems.length > 1
            }

            Rectangle {
                visible: BarLayoutState.showSeparators && BarLayoutState.visibleCenterItems.length === 1
                Layout.preferredWidth: 1
                Layout.preferredHeight: Theme.dp(14)
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: Theme.dp(6)
                color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.5)
            }
        }
    }
}
