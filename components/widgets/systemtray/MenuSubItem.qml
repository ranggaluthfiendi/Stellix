import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

ColumnLayout {
    id: root

    required property var menu

    spacing: Theme.dp(2)

    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height

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

            Layout.fillWidth: false
            Layout.preferredWidth: implicitWidth
        }
    }

    Component {
        id: sep

        Rectangle {
            height: Theme.dp(1)
            width: implicitWidth
            color: Theme.textMuted
            opacity: 0.3

            Layout.fillWidth: false
            Layout.preferredWidth: implicitWidth
        }
    }

    Component {
        id: item

        MenuSubItemDelegate {
            entry: modelData

            Layout.fillWidth: false
            Layout.preferredWidth: implicitWidth
        }
    }
}
