import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.components.widgets.rightbar
import "./settings"

PanelWindow {
    id: root

    visible: RightBarState.settingsOpen && (settingsData ? !settingsData.settingsFloating : true)
    color: "transparent"

    anchors {
        top: true; left: true; right: true; bottom: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: -1

    // Services (Passed from shell.qml)
    property var pwService: null
    property var systemInfo: null
    property var wallpaper: null
    property var colorService: null
    property var settingsData: null

    MouseArea {
        anchors.fill: parent
        onClicked: { RightBarState.settingsOpen = false }
    }

    Rectangle {
        id: mainContainer
        anchors.centerIn: parent
        width: Theme.dp(940); height: Theme.dp(720)
        color: Theme.bgPrimary; border.width: Theme.borderWidth; border.color: Theme.border; radius: 0 
        opacity: root.visible ? 1 : 0
        scale: root.visible ? 1 : 0.97
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        MouseArea { anchors.fill: parent; onClicked: {} }

        SettingsContent {
            anchors.fill: parent
            pwService: root.pwService
            systemInfo: root.systemInfo
            wallpaper: root.wallpaper
            colorService: root.colorService
            settingsData: root.settingsData
            isFloating: false
        }
    }
}
