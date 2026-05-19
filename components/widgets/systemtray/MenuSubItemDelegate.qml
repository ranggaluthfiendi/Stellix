import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Item {
    id: root

    required property var entry
    property bool expanded: false
    property real s: Scales.uiScale

    implicitHeight: Theme.dp(24)
    implicitWidth: row.implicitWidth + Theme.dp(16)

    ColumnLayout {
        spacing: 0
        width: implicitWidth

        Rectangle {
            id: bg

            height: Theme.dp(24)
            width: implicitWidth

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
                    id: label

                    text: entry && entry.text ? entry.text : ""
                    color: entry && entry.enabled
                        ? Theme.textPrimary
                        : Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 9) * root.s)

                    wrapMode: Text.NoWrap
                    elide: Text.ElideNone

                    Layout.fillWidth: false
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    text: entry && entry.hasChildren ? "▶" : ""
                    color: Theme.textMuted
                    visible: entry && entry.hasChildren
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 9) * root.s)
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
                        try { entry.showChildren = root.expanded } catch(e) {}
                    } else {
                        try { entry.triggered() } catch(e) {}
                    }
                }
            }
        }

        Loader {
            active: root.expanded && entry && entry.hasChildren
            visible: active

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
