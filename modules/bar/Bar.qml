import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.components.ui.bar.sections

PanelWindow {
    id: barWindow

    implicitHeight: 30
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }
    
    RowLayout {
        anchors.fill: parent

        BarLeft {}
        Item { Layout.fillWidth: true }
        BarCenter {}
        Item { Layout.fillWidth: true }
        BarRight {}
    }
}
