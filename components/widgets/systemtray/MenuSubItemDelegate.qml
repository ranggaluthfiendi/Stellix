import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Item {
    id: root

    required property var entry
    property bool expanded: false

    implicitHeight: Theme.dp(28)
    implicitWidth: row.implicitWidth + Theme.dp(12)

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: bg
            height: Theme.dp(28)
            Layout.fillWidth: true
            radius: 0

            color: mouse.containsMouse
                   ? Qt.rgba(
                        Theme.accentSoft.r,
                        Theme.accentSoft.g,
                        Theme.accentSoft.b,
                        0.15
                     )
                   : "transparent"

            RowLayout {
                id: row
                anchors.fill: parent
                anchors.leftMargin: Theme.dp(8)
                anchors.rightMargin: Theme.dp(8)
                spacing: Theme.dp(6)

                Text {
                    text: entry && entry.text ? entry.text : ""
                    color: entry && entry.enabled
                           ? Theme.textPrimary
                           : Theme.textMuted

                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    text: entry && entry.hasChildren ? "▶" : ""
                    color: Theme.textMuted
                    visible: entry && entry.hasChildren
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    if (!entry) return

                    if (entry.hasChildren) {
                        root.expanded = !root.expanded

                        try {
                            entry.showChildren = root.expanded
                        } catch(e) {}
                    } else {
                        try { entry.triggered() } catch(e) {}
                    }
                }
            }
        }

        Loader {
            active: root.expanded && entry && entry.hasChildren
            sourceComponent: submenu
        }
    }

    Component {
        id: submenu

        MenuSubItem {
            menu: entry
        }
    }
}
