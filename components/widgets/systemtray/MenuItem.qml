import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services

Item {
    id: root

    required property var entry

    signal close()
    signal requestSubmenu(var entry, var anchorItem)

    readonly property bool isEnabled: entry && entry.enabled

    readonly property bool isActiveSubmenu: SysTrayState.openedSubmenuEntry === entry

    property real s: Scales.uiScale

    implicitHeight: Theme.dp(24)
    implicitWidth: row.implicitWidth + Theme.dp(16)

    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    scale: isEnabled && mouse.containsMouse ? 1.02 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 0

        color: {
            if (!isEnabled) return "transparent"

            if (isActiveSubmenu) {
                return Qt.rgba(
                    Theme.textPrimary.r,
                    Theme.textPrimary.g,
                    Theme.textPrimary.b,
                    0.10
                )
            }

            return mouse.containsMouse
                ? Qt.rgba(
                    Theme.textPrimary.r,
                    Theme.textPrimary.g,
                    Theme.textPrimary.b,
                    0.08
                  )
                : "transparent"
        }

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: Theme.dp(8)
        anchors.rightMargin: Theme.dp(8)
        spacing: Theme.dp(6)

        Text {
            text: entry && entry.text ? entry.text : ""
            color: isEnabled ? Theme.textPrimary : Theme.textMuted
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeXXS || 9) * root.s)

            Layout.fillWidth: false
            wrapMode: Text.NoWrap
            elide: Text.ElideNone
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: entry && entry.hasChildren ? "▶" : ""

            color: isActiveSubmenu ? Theme.accent : Theme.textMuted
            visible: entry && entry.hasChildren
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeXXS || 9) * root.s)
        }
    }

    Timer {
        id: hoverTimer
        interval: 120
        repeat: false

        onTriggered: {
            if (!isEnabled || !entry || !entry.hasChildren) return

            if (SysTrayState.openedSubmenuEntry !== entry) {
                root.requestSubmenu(entry, root)
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true

        cursorShape: isEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: isEnabled

        onEntered: {
            if (entry && entry.hasChildren) hoverTimer.start()
        }

        onExited: {
            hoverTimer.stop()
        }

        onClicked: {
            if (!entry) return

            if (entry.hasChildren) {
                if (SysTrayState.openedSubmenuEntry === entry) {
                    root.requestSubmenu(null, null)
                } else {
                    root.requestSubmenu(entry, root)
                }
            } else {
                try { entry.triggered() } catch(e) {}
                root.close()
            }
        }
    }
}
