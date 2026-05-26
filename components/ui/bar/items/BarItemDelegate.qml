import QtQuick
import QtQuick.Layouts
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

RowLayout {
    id: delegate

    required property string modelData
    required property int index

    spacing: Theme.dp(6)

    readonly property bool isLastItemInSection: {
        var section = BarLayoutState.findItemSection(delegate.modelData)
        if (section === "left") return delegate.index === BarLayoutState.visibleLeftItems.length - 1
        if (section === "center") return delegate.index === BarLayoutState.visibleCenterItems.length - 1
        if (section === "right") return delegate.index === BarLayoutState.visibleRightItems.length - 1
        return true
    }

    Loader {
        id: loader
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: {
            if (delegate.modelData === "battery" && BarLayoutState.batteryStyle === "percentage") return Theme.dp(4)
            if (delegate.modelData === "workspace") return Theme.dp(6)
            return 0
        }
        Layout.rightMargin: {
            if (delegate.modelData === "battery" && BarLayoutState.batteryStyle === "percentage") return Theme.dp(4)
            if (delegate.modelData === "workspace") return Theme.dp(6)
            return 0
        }

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
                case "weather": return Qt.resolvedUrl("WeatherItem.qml")
                case "media": return Qt.resolvedUrl("BarMediaItem.qml")
                default: return ""
            }
        }
    }

    Rectangle {
        id: itemSeparator
        visible: BarLayoutState.showSeparators && !delegate.isLastItemInSection
        Layout.preferredWidth: 1
        Layout.preferredHeight: Theme.dp(14)
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: Theme.dp(2)
        color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.5)
    }
}
