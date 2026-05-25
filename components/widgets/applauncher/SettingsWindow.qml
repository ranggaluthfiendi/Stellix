import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.services
import qs.components.widgets.barpopup
import "./settings"

FloatingWindow {
    id: root

    property var pwService: null
    property var systemInfo: null
    property var wallpaper: null
    property var colorService: null
    property var settingsData: null

    visible: BarPopupState.settingsOpen && (settingsData ? settingsData.settingsFloating : false)
    title: "Stellix Control"
    
    implicitWidth: Theme.dp(940)
    implicitHeight: Theme.dp(720)
    
    color: Theme.bgPrimary

    onVisibleChanged: {
        if (!visible && BarPopupState.settingsOpen && (settingsData ? settingsData.settingsFloating : false)) {
            BarPopupState.settingsOpen = false
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
