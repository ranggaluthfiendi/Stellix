import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.services
import qs.components.widgets.rightbar
import "./settings"

FloatingWindow {
    id: root

    property var pwService: null
    property var systemInfo: null
    property var wallpaper: null
    property var colorService: null
    property var settingsData: null

    visible: RightBarState.settingsOpen && (settingsData ? settingsData.settingsFloating : false)
    title: "Stellix Control"
    
    implicitWidth: Theme.dp(940)
    implicitHeight: Theme.dp(720)
    
    color: Theme.bgPrimary

    onVisibleChanged: {
        if (!visible && RightBarState.settingsOpen && (settingsData ? settingsData.settingsFloating : false)) {
            RightBarState.settingsOpen = false
        }
    }

    SettingsContent {
        anchors.fill: parent
        pwService: root.pwService
        systemInfo: root.systemInfo
        wallpaper: root.wallpaper
        colorService: root.colorService
        settingsData: root.settingsData
        isFloating: true
        parentWindow: root
    }
}
