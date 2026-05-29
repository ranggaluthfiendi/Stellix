import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    required property var entry

    signal close()
    signal requestSubmenu(var entry, var anchorItem)

    readonly property bool isEnabled: entry && entry.enabled
    readonly property bool isSeparator: entry && entry.isSeparator
    readonly property bool isCheckbox: entry && entry.buttonType === QsMenuButtonType.CheckBox
    readonly property bool isRadio: entry && entry.buttonType === QsMenuButtonType.RadioButton
    readonly property bool hasSubmenu: entry && entry.hasChildren
    readonly property bool isActiveSubmenu: SysTrayState.openedSubmenuEntry === entry

    property real s: Scales.uiScale

    implicitHeight: isSeparator ? Theme.dp(1) : Theme.dp(24)
    implicitWidth: isSeparator ? Theme.dp(120) : row.implicitWidth + Theme.dp(16)

    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    Rectangle {
        anchors.fill: parent
        radius: 0
        visible: !isSeparator

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

    Rectangle {
        visible: isSeparator
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Theme.dp(3)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.dp(3)
        anchors.leftMargin: Theme.dp(8)
        anchors.rightMargin: Theme.dp(8)
        width: parent.width - Theme.dp(16)
        height: Theme.dp(1)
        color: Theme.border
    }

    scale: isEnabled && mouse.containsMouse ? 1.02 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: Theme.dp(8)
        anchors.rightMargin: Theme.dp(8)
        spacing: Theme.dp(6)
        visible: !isSeparator

        Text {
            text: entry && entry.text ? entry.text : ""
            color: isEnabled ? Theme.textPrimary : Theme.textMuted
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeXXS || 9) * root.s)

            Layout.fillWidth: true
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            id: checkIndicator
            visible: isCheckbox || isRadio
            text: {
                if (isCheckbox) return entry.checkState === Qt.Checked ? "check_circle" : ""
                if (isRadio) return entry.checkState === Qt.Checked ? "●" : ""
                return ""
            }
            color: isEnabled ? Theme.accent : Theme.textMuted
            font.family: Typography.fontFamily
            font.pixelSize: Math.round((Typography.sizeXS || 10) * root.s)
            font.weight: Font.Bold
        }

        Text {
            text: hasSubmenu ? "arrow_right" : ""
            font.family: Typography.materialSymbols
            font.styleName: "Regular"
            color: isActiveSubmenu ? Theme.accent : Theme.textMuted
            visible: hasSubmenu
            font.pixelSize: Math.round((Typography.sizeXXS || 9) * root.s)
        }
    }

    Timer {
        id: hoverTimer
        interval: 120
        repeat: false

        onTriggered: {
            if (!isEnabled || !entry || !hasSubmenu) return

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
        enabled: isEnabled && !isSeparator

        onEntered: {
            if (entry && hasSubmenu) hoverTimer.start()
        }

        onExited: {
            hoverTimer.stop()
        }

        onClicked: {
            if (!entry) return

            if (isCheckbox || isRadio) {
                try { entry.triggered() } catch(e) {}
            } else if (hasSubmenu) {
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
