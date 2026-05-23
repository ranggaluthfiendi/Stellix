import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import qs.screens
import qs.services
import qs.components.widgets.systemtray
import qs.components.widgets.rightbar
import qs.components.widgets.rightbar.services
import qs.components.widgets.workspaceswitcher
import qs.components.widgets.applauncher
import qs.modules.bar

ShellRoot {
    Bar {}
    Screen {}
    SysTrayFocusHandler {}
    SysTrayGlobalOverlay {}
    CalendarGlobalOverlay {}
    WelcomeScreen { settingsData: settingsData }

    AppLauncherService {
        id: launcher
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
            if (!RightBarState.indicatorVisible || RightBarState.indicatorType !== "brightness")
                RightBarState.showIndicator("brightness", brightnessService.percentage / 100, false)
        }
    }

    Connections {
        target: (pwService.sink && pwService.sink.audio) ? pwService.sink.audio : null
        ignoreUnknownSignals: true
        function onVolumeChanged() {
            if (!RightBarState.indicatorVisible || RightBarState.indicatorType !== "volume")
                RightBarState.showIndicator("volume", pwService.sink.audio.volume, pwService.sink.audio.muted)
        }
        function onMutedChanged() {
            RightBarState.showIndicator("volume", pwService.sink.audio.volume, pwService.sink.audio.muted)
        }
    }

    // Since I don't have a direct reference to brightnessSvc here (it's in BatteryRightBar),
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
        target: RightBarState
        function onLauncherToggleRequested() {
            if (RightBarState.launcherOpen) {
                RightBarState.launcherOpen = false
                launcher.close()
            } else {
                RightBarState.closeAll()
                RightBarState.launcherOpen = true
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
                if (RightBarState.settingsOpen) {
                    RightBarState.settingsOpen = false
                } else {
                    RightBarState.closeAll()
                    RightBarState.settingsOpen = true
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
                if (RightBarState.guideOpen) {
                    RightBarState.guideOpen = false
                } else {
                    RightBarState.closeAll()
                    RightBarState.guideOpen = true
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
                if (RightBarState.workspaceSwitcherOpen) {
                    RightBarState.workspaceSwitcherOpen = false
                } else {
                    RightBarState.closeAll()
                    RightBarState.workspaceSwitcherOpen = true
                    RightBarState.notifPanelRequested = false
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
                if (RightBarState.workspaceSwitcherOpen)
                    RightBarState.workspaceSwitcherOpen = false
                if (RightBarState.launcherOpen && appLauncher.viewMode === 0) {
                    RightBarState.launcherOpen = false
                    launcher.close()
                } else {
                    RightBarState.closeAll()
                    appLauncher.viewMode = 0
                    RightBarState.launcherOpen = true
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
                if (RightBarState.launcherOpen && appLauncher.viewMode === 8) {
                    RightBarState.launcherOpen = false
                    launcher.close()
                } else {
                    RightBarState.closeAll()
                    appLauncher.viewMode = 8
                    RightBarState.launcherOpen = true
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
                if (RightBarState.launcherOpen) {
                    RightBarState.launcherOpen = false
                    launcher.close()
                }
                var currentWs = Hyprland.focusedWorkspace.id
                var nextWs = currentWs + 1
                Hyprland.dispatch("workspace " + nextWs)
                RightBarState.workspaceSwitcherOpen = true
                RightBarState.notifPanelRequested = false
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
                if (RightBarState.launcherOpen) {
                    RightBarState.launcherOpen = false
                    launcher.close()
                }
                var currentWs = Hyprland.focusedWorkspace.id
                var prevWs = Math.max(1, currentWs - 1)
                Hyprland.dispatch("workspace " + prevWs)
                RightBarState.workspaceSwitcherOpen = true
                RightBarState.notifPanelRequested = false
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
                if (RightBarState.open) {
                    RightBarState.open = false
                } else {
                    RightBarState.closeAll()
                    RightBarState.open = true
                }
            }
        }
    }

    Timer {
        id: wsFlashTimer
        interval: 600
        repeat: false
        onTriggered: {
            RightBarState.workspaceSwitcherOpen = false
        }
    }

    WorkspaceSwitcher {
        id: wsSwitcher
        visible: RightBarState.workspaceSwitcherOpen
        
        onCloseRequested: {
            RightBarState.workspaceSwitcherOpen = false
        }
    }

    // IPC Handler untuk Volume/Brightness Indicator
    IpcHandler {
        target: "indicator"
        function show(type: string, value: real, muted: bool): void {
            RightBarState.showIndicator(type, value, muted)
        }
    }
}
