import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services

RowLayout {
    id: delegate

    required property string modelData
    required property int index
    property bool showTrailingSeparator: true

    spacing: Theme.dp(6)

    Loader {
        id: loader
        Layout.alignment: Qt.AlignVCenter

        onStatusChanged: {
            if (status === Loader.Ready && item) {
                BarLayoutState.registerItem(delegate.modelData, item)
            }
        }

        Component.onDestruction: {
            BarLayoutState.unregisterItem(delegate.modelData)
        }

        source: {
            switch (delegate.modelData) {
                case "launcher": return Qt.resolvedUrl("LauncherItem.qml")
                case "workspace": return Qt.resolvedUrl("WorkspaceItem.qml")
                case "systray": return Qt.resolvedUrl("../../../widgets/systemtray/SysTray.qml")
                case "clock": return Qt.resolvedUrl("ClockItem.qml")
                case "battery": return Qt.resolvedUrl("MenuItem.qml")
                case "notif": return Qt.resolvedUrl("NotifItem.qml")
                default: return ""
            }
        }
    }

    Rectangle {
        visible: BarLayoutState.showSeparators && delegate.showTrailingSeparator
        Layout.preferredWidth: 1
        Layout.preferredHeight: Theme.dp(14)
        Layout.alignment: Qt.AlignVCenter
        color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.5)
    }
}
