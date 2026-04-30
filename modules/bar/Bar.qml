import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.components.ui.bar.sections
import qs.config

Scope {
    id: root

    property bool hovering: false
    property bool pinned: false
    property bool autoHideEnabled: true

    readonly property bool expanded: (
        !autoHideEnabled
        || root.hovering
        || root.pinned
    )

    PanelWindow {
        id: barWindow

        implicitHeight: expanded ? Dimens.barHeight : 2
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }

        Component.onCompleted: {
            if (barWindow.WlrLayershell) {
                barWindow.WlrLayershell.layer = WlrLayer.Overlay
                barWindow.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
            }
        }

        property real offset: expanded ? 0 : -Dimens.barHeight
        property real contentOpacity: expanded ? 1 : 0

        Behavior on implicitHeight {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        Behavior on offset {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        Behavior on contentOpacity {
            NumberAnimation { duration: 140; easing.type: Easing.InOutQuad }
        }

        HoverHandler {
            onHoveredChanged: root.hovering = hovered
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                root.pinned = !root.pinned
            }

            onDoubleClicked: {
                root.autoHideEnabled = !root.autoHideEnabled
            }
        }

        Item {
            anchors.fill: parent
            y: barWindow.offset
            opacity: barWindow.contentOpacity

            RowLayout {
                anchors.fill: parent

                BarLeft {}
                Item { Layout.fillWidth: true }
                BarCenter {}
                Item { Layout.fillWidth: true }
                BarRight {}
            }
        }
    }
}
