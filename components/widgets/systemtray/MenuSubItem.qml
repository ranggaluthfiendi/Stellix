import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

ColumnLayout {
    id: root

    required property var menu

    spacing: Theme.dp(2)

    QsMenuOpener {
        id: opener
        menu: root.menu
    }

    Repeater {
        model: opener.children ? opener.children : []

        delegate: Loader {
            required property var modelData

            active: modelData !== null && modelData !== undefined

            sourceComponent: modelData && modelData.isSeparator
                ? sep
                : item

            Layout.fillWidth: true
        }
    }

    Component {
        id: sep

        Rectangle {
            height: Theme.dp(1)
            color: Theme.textMuted
            opacity: 0.3
            Layout.fillWidth: true
        }
    }

    Component {
        id: item

        MenuSubItemDelegate {
            entry: modelData
        }
    }
}
