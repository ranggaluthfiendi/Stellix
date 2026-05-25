import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import qs.screens
import qs.services
import qs.components.widgets.systemtray
import qs.components.widgets.barpopup
import qs.components.widgets.barpopup.services
import qs.components.widgets.workspaceswitcher
import qs.components.widgets.applauncher
import qs.modules.bar

ShellRoot {
    Bar {}
    Screen {}
    SysTrayFocusHandler {}
    SysTrayGlobalOverlay {}
    CalendarGlobalOverlay {}
    WeatherGlobalOverlay {}
    WelcomeScreen { settingsData: settingsData }

    AppLauncherService {
        id: launcher
        Component.onCompleted: BarLayoutState.registerItem("launcherSvc", launcher)
    }

    WallpaperService {
        id: wallpaper
    }

    PowerService {
        id: power
    }

    ScreenshotService {
        id: screenshot
    }

    CalcService {
        id: calc
    }

    CurrencyService {
        id: currencyService
    }

    ColorService {
        id: colorService
    }

    SystemInfoService {
        id: systemInfo
        Component.onCompleted: BarLayoutState.registerItem("systemInfo", systemInfo)
    }

    PipewireService {
        id: pwService
        Component.onCompleted: BarLayoutState.registerItem("pwService", pwService)
    }

    MprisService {
        id: mprisService
        Component.onCompleted: BarLayoutState.registerItem("mprisService", mprisService)
    }

    BrightnessService {
        id: brightnessService
        Component.onCompleted: {
            BarLayoutState.registerItem("brightnessService", brightnessService)
            brightnessService.init()
        }
    }

    NotificationService {
        id: notifService
        Component.onCompleted: BarLayoutState.registerItem("notifService", notifService)
    }

    Connections {
        target: brightnessService
        function onCurrentValueChanged() {
            BarPopupState.showIndicator("brightness", brightnessService.percentage / 100, false)
        }
    }

    Connections {
        target: (pwService.sink && pwService.sink.audio) ? pwService.sink.audio : null
        ignoreUnknownSignals: true
        function onVolumeChanged() {
            BarPopupState.showIndicator("volume", pwService.sink.audio.volume, pwService.sink.audio.muted)
        }
        function onMutedChanged() {
            BarPopupState.showIndicator("volume", pwService.sink.audio.volume, pwService.sink.audio.muted)
        }
    }

    // Since I don't have a direct reference to brightnessSvc here (it's in BatteryBarPopup),
    // I will rely on the IPC or move brightnessSvc to shell.qml level.

    SettingsData {
        id: settingsData
    }

    RecordService {
        id: recordService
    }

    ClipboardService {
        id: clipboardService
    }

    AppLauncher {
        id: appLauncher
        wallpaper: wallpaper
        clipboardService: clipboardService
    }

    Connections {
        target: BarPopupState
        function onLauncherToggleRequested() {
            if (BarPopupState.launcherOpen) {
                BarPopupState.launcherOpen = false
                launcher.close()
            } else {
                BarPopupState.closeAll()
                BarPopupState.launcherOpen = true
                launcher.open()
            }
        }
    }

    SettingsPopup {
        id: settingsPopup
        wallpaper: wallpaper
        systemInfo: systemInfo
        pwService: pwService
        colorService: colorService
        settingsData: settingsData
    }

    SettingsWindow {
        id: settingsWindow
        wallpaper: wallpaper
        systemInfo: systemInfo
        pwService: pwService
        colorService: colorService
        settingsData: settingsData
    }

    GuidePopup {
        id: guidePopup
    }

    GlobalShortcut {
        id: settingsShortcut
        name: "system-settings"
        description: "Open system settings"
        onPressedChanged: {
            if (pressed) {
                if (BarPopupState.settingsOpen) {
                    BarPopupState.settingsOpen = false
                } else {
                    BarPopupState.closeAll()
                    BarPopupState.settingsOpen = true
                }
            }
        }
    }

    GlobalShortcut {
        id: guideShortcut
        name: "guide-popup"
        description: "Open shortcut guide"

        onPressedChanged: {
            if (pressed) {
                if (BarPopupState.guideOpen) {
                    BarPopupState.guideOpen = false
                } else {
                    BarPopupState.closeAll()
                    BarPopupState.guideOpen = true
                }
            }
        }
    }

    GlobalShortcut {
        id: wsSwitcherShortcut
        name: "workspace-switcher"
        description: "Open workspace switcher"

        onPressedChanged: {
            if (pressed) {
                if (BarPopupState.workspaceSwitcherOpen) {
                    BarPopupState.workspaceSwitcherOpen = false
                } else {
                    BarPopupState.closeAll()
                    BarPopupState.workspaceSwitcherOpen = true
                    BarPopupState.notifPanelRequested = false
                }
            }
        }
    }

    GlobalShortcut {
        id: appLauncherShortcut
        name: "app-launcher"
        description: "Open application launcher"

        onPressedChanged: {
            if (pressed) {
                if (BarPopupState.workspaceSwitcherOpen)
                    BarPopupState.workspaceSwitcherOpen = false
                if (BarPopupState.launcherOpen && appLauncher.viewMode === 0) {
                    BarPopupState.launcherOpen = false
                    launcher.close()
                } else {
                    BarPopupState.closeAll()
                    appLauncher.viewMode = 0
                    BarPopupState.launcherOpen = true
                    launcher.open()
                }
            }
        }
    }

    GlobalShortcut {
        id: clipboardShortcut
        name: "clipboard"
        description: "Open clipboard history"

        onPressedChanged: {
            if (pressed) {
                if (BarPopupState.launcherOpen && appLauncher.viewMode === 8) {
                    BarPopupState.launcherOpen = false
                    launcher.close()
                } else {
                    BarPopupState.closeAll()
                    appLauncher.viewMode = 8
                    BarPopupState.launcherOpen = true
                    launcher.open()
                }
            }
        }
    }

    GlobalShortcut {
        id: altTabNext
        name: "alt-tab-next"
        description: "Switch to next workspace"

        onPressedChanged: {
            if (pressed) {
                if (BarPopupState.launcherOpen) {
                    BarPopupState.launcherOpen = false
                    launcher.close()
                }
                var currentWs = Hyprland.focusedWorkspace.id
                var nextWs = currentWs + 1
                Hyprland.dispatch("workspace " + nextWs)
                BarPopupState.workspaceSwitcherOpen = true
                BarPopupState.notifPanelRequested = false
                wsFlashTimer.restart()
            }
        }
    }

    GlobalShortcut {
        id: altTabPrev
        name: "alt-tab-prev"
        description: "Switch to previous workspace"

        onPressedChanged: {
            if (pressed) {
                if (BarPopupState.launcherOpen) {
                    BarPopupState.launcherOpen = false
                    launcher.close()
                }
                var currentWs = Hyprland.focusedWorkspace.id
                var prevWs = Math.max(1, currentWs - 1)
                Hyprland.dispatch("workspace " + prevWs)
                BarPopupState.workspaceSwitcherOpen = true
                BarPopupState.notifPanelRequested = false
                wsFlashTimer.restart()
            }
        }
    }

    GlobalShortcut {
        id: openRightbarShortcut
        name: "open-rightbar"
        description: "Open rightbar popup"

        onPressedChanged: {
            if (pressed) {
                if (BarPopupState.open) {
                    BarPopupState.open = false
                } else {
                    BarPopupState.closeAll()
                    BarPopupState.open = true
                }
            }
        }
    }

    GlobalShortcut {
        id: openWeatherShortcut
        name: "weather-popup"
        description: "Open weather detail popup"

        onPressedChanged: {
            if (pressed) {
                if (BarPopupState.weatherDetailOpen) {
                    BarPopupState.weatherDetailOpen = false
                } else {
                    BarPopupState.closeAll()
                    BarPopupState.weatherDetailOpen = true
                }
            }
        }
    }

    Timer {
        id: wsFlashTimer
        interval: 600
        repeat: false
        onTriggered: {
            BarPopupState.workspaceSwitcherOpen = false
        }
    }

    WorkspaceSwitcher {
        id: wsSwitcher
        visible: BarPopupState.workspaceSwitcherOpen
        
        onCloseRequested: {
            BarPopupState.workspaceSwitcherOpen = false
            BarPopupState.weatherDetailOpen = false
        }
    }

    // IPC Handler untuk Volume/Brightness Indicator
    IpcHandler {
        target: "indicator"
        function show(type: string, value: real, muted: bool): void {
            BarPopupState.showIndicator(type, value, muted)
        }
    }
}
