pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import QtCore

Item {
    id: root

    readonly property string savePath:
        StandardPaths.writableLocation(StandardPaths.ConfigLocation)
        .toString().replace(/^file:\/\//, "") +
        "/quickshell/savedata/bar-layout.json"

    property bool _loading: true

    property real barScreenWidth: 0

    property string barPosition: "top"
    onBarPositionChanged: save()
    readonly property bool isBottom: barPosition === "bottom"

    property bool showBatteryPercentage: true
    onShowBatteryPercentageChanged: save()
    property string clockFormat: "time"
    onClockFormatChanged: save()
    property bool clock24Hour: true
    onClock24HourChanged: save()
    property bool clockShowSeconds: false
    onClockShowSecondsChanged: save()

    property int batteryLowThreshold: 20
    onBatteryLowThresholdChanged: save()
    property string batteryStyle: "both"
    onBatteryStyleChanged: save()
    property var batteryElements: ["charging", "percentage", "icon"]
    onBatteryElementsChanged: save()
    property bool batteryShowCharging: true
    onBatteryShowChargingChanged: save()

    property int barHeight: 32
    onBarHeightChanged: save()
    property real barOpacity: 1.0
    onBarOpacityChanged: save()
    property real calendarOpacity: 1.0
    onCalendarOpacityChanged: save()
    property real notifOpacity: 1.0
    onNotifOpacityChanged: save()
    property real systrayOpacity: 1.0
    onSystrayOpacityChanged: save()
    property real weatherPopupOpacity: 1.0
    onWeatherPopupOpacityChanged: save()
    property bool weatherPopupRounded: false
    onWeatherPopupRoundedChanged: save()
    property bool calendarPopupRounded: false
    onCalendarPopupRoundedChanged: save()
    property bool notifPopupRounded: false
    onNotifPopupRoundedChanged: save()
    property bool rightbarPopupRounded: false
    onRightbarPopupRoundedChanged: save()
    property bool barBorder: true
    onBarBorderChanged: save()
    property bool showSeparators: false
    onShowSeparatorsChanged: save()
    property int workspaceCount: 5
    onWorkspaceCountChanged: save()

    // SysTray options
    property bool systrayShowAll: true
    onSystrayShowAllChanged: save()
    property int systrayCollapseLimit: 5
    onSystrayCollapseLimitChanged: save()

    // --- Desktop Widgets State ---
    property bool showScreenClock: false
    onShowScreenClockChanged: save()
    property real desktopClockX: 40
    onDesktopClockXChanged: save()
    property real desktopClockY: 40
    onDesktopClockYChanged: save()
    property real desktopClockRotation: 0
    onDesktopClockRotationChanged: save()
    property string desktopClockColorMode: "accent"
    onDesktopClockColorModeChanged: save()
    property real desktopClockScale: 1.0
    onDesktopClockScaleChanged: save()
    property bool desktopClock24Hour: true
    onDesktopClock24HourChanged: save()
    property bool desktopClockShowSeconds: false
    onDesktopClockShowSecondsChanged: save()
    property bool desktopClockShowDate: true
    onDesktopClockShowDateChanged: save()
    property bool desktopClockShowWeekday: true
    onDesktopClockShowWeekdayChanged: save()
    property bool desktopClockShowYear: false
    onDesktopClockShowYearChanged: save()
    property int desktopClockAlignment: 1
    onDesktopClockAlignmentChanged: save()

    property bool showScreenSystemStats: false
    onShowScreenSystemStatsChanged: save()
    property real desktopStatsX: 40
    onDesktopStatsXChanged: save()
    property real desktopStatsY: 800
    onDesktopStatsYChanged: save()
    property real desktopStatsRotation: 0
    onDesktopStatsRotationChanged: save()
    property string desktopStatsLayout: "default"
    onDesktopStatsLayoutChanged: save()
    property string desktopStatsColorMode: "accent"
    onDesktopStatsColorModeChanged: save()
    property bool desktopStatsShowCpu: true
    onDesktopStatsShowCpuChanged: save()
    property bool desktopStatsShowGpu: true
    onDesktopStatsShowGpuChanged: save()
    property bool desktopStatsShowMem: true
    onDesktopStatsShowMemChanged: save()
    property bool desktopStatsShowNet: true
    onDesktopStatsShowNetChanged: save()
    property bool desktopStatsShowDisk: false
    onDesktopStatsShowDiskChanged: save()
    property bool desktopStatsShowUptime: false
    onDesktopStatsShowUptimeChanged: save()
    property bool desktopStatsShowTemp: false
    onDesktopStatsShowTempChanged: save()
    property string desktopStatsNetDownLabel: "DOWN"
    onDesktopStatsNetDownLabelChanged: save()
    property string desktopStatsNetUpLabel: "UP"
    onDesktopStatsNetUpLabelChanged: save()
    property string desktopStatsNetLabelStyle: "short"
    onDesktopStatsNetLabelStyleChanged: save()
    property real desktopStatsScale: 1.0
    onDesktopStatsScaleChanged: save()

    property bool showScreenWeather: false
    onShowScreenWeatherChanged: save()
    property real desktopWeatherX: 40
    onDesktopWeatherXChanged: save()
    property real desktopWeatherY: 600
    onDesktopWeatherYChanged: save()
    property real desktopWeatherRotation: 0
    onDesktopWeatherRotationChanged: save()
    property string desktopWeatherLayout: "default"
    onDesktopWeatherLayoutChanged: save()
    property real desktopWeatherScale: 1.0
    onDesktopWeatherScaleChanged: save()
    property string desktopWeatherCity: ""
    onDesktopWeatherCityChanged: save()
    property string desktopWeatherUnit: "C"
    onDesktopWeatherUnitChanged: save()

    property string systemCity: ""

    Process {
        id: detectCityProc
        command: ["sh", "-c", "timedatectl show --property=Timezone --value 2>/dev/null | awk -F/ '{print $NF}' | sed 's/_/ /g'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var city = this.text.trim()
                if (city !== "" && root.systemCity === "") {
                    root.systemCity = city
                    if (root.desktopWeatherCity === "") {
                        root.desktopWeatherCity = city
                        save()
                    }
                }
            }
        }
    }

    property bool showScreenQuickActions: false
    onShowScreenQuickActionsChanged: save()
    property real desktopQuickActionsX: 800
    onDesktopQuickActionsXChanged: save()
    property real desktopQuickActionsY: 900
    onDesktopQuickActionsYChanged: save()
    property real desktopQuickActionsRotation: 0
    onDesktopQuickActionsRotationChanged: save()
    property bool desktopQuickActionsVisible: true
    onDesktopQuickActionsVisibleChanged: save()
    property bool desktopQuickActionsPinned: false
    onDesktopQuickActionsPinnedChanged: save()
    property real desktopQuickActionsRadius: 12
    onDesktopQuickActionsRadiusChanged: save()
    property real desktopQuickActionsScale: 1.0
    onDesktopQuickActionsScaleChanged: save()

    property bool showScreenNowPlaying: false
    onShowScreenNowPlayingChanged: save()
    property real desktopNowPlayingX: 1400
    onDesktopNowPlayingXChanged: save()
    property real desktopNowPlayingY: 40
    onDesktopNowPlayingYChanged: save()
    property real desktopNowPlayingRotation: 0
    onDesktopNowPlayingRotationChanged: save()
    property real desktopNowPlayingScale: 1.0
    onDesktopNowPlayingScaleChanged: save()

    property bool showScreenEqualizer: false
    onShowScreenEqualizerChanged: save()
    property real desktopEqualizerX: 800
    onDesktopEqualizerXChanged: save()
    property real desktopEqualizerY: 400
    onDesktopEqualizerYChanged: save()
    property real desktopEqualizerRotation: 0
    onDesktopEqualizerRotationChanged: save()
    property real desktopEqualizerScale: 1.0
    onDesktopEqualizerScaleChanged: save()
    property string desktopEqualizerColorMode: "accent"
    onDesktopEqualizerColorModeChanged: save()
    property string desktopEqualizerCustomColor: "#ffffff"
    onDesktopEqualizerCustomColorChanged: save()
    property string desktopEqualizerStyle: "wave"
    onDesktopEqualizerStyleChanged: save()
    property real desktopEqualizerLineThickness: 2.0
    onDesktopEqualizerLineThicknessChanged: save()
    property real desktopEqualizerFillOpacity: 0.15
    onDesktopEqualizerFillOpacityChanged: save()
    property bool desktopEqualizerMirrored: true
    onDesktopEqualizerMirroredChanged: save()
    property bool desktopEqualizerDoubleWave: true
    onDesktopEqualizerDoubleWaveChanged: save()
    property bool desktopEqualizerFilled: false
    onDesktopEqualizerFilledChanged: save()

    property real desktopWidgetsOpacity: 1.0
    onDesktopWidgetsOpacityChanged: save()
    property real desktopClockOpacity: 1.0
    onDesktopClockOpacityChanged: save()
    property real desktopNowPlayingOpacity: 1.0
    onDesktopNowPlayingOpacityChanged: save()
    property real desktopEqualizerOpacity: 1.0
    onDesktopEqualizerOpacityChanged: save()
    property real desktopStatsOpacity: 1.0
    onDesktopStatsOpacityChanged: save()
    property real desktopWeatherOpacity: 1.0
    onDesktopWeatherOpacityChanged: save()
    property real desktopQuickActionsOpacity: 1.0
    onDesktopQuickActionsOpacityChanged: save()

    property bool showIndicators: true
    onShowIndicatorsChanged: save()

    property bool desktopSearchFocus: false
    property real snapLineXPos: 0
    property bool snapLineXVisible: false
    property real snapLineYPos: 0
    property bool snapLineYVisible: false

    property var leftItems: ["launcher", "workspace", "systray"]
    property var centerItems: ["clock"]
    property bool weatherShowIcon: true
    onWeatherShowIconChanged: save()
    property bool weatherShowTemp: true
    onWeatherShowTempChanged: save()
    property bool weatherShowDesc: false
    onWeatherShowDescChanged: save()
    property string weatherBarLayout: "icon-temp"
    onWeatherBarLayoutChanged: save()
    property var weatherElements: ["icon", "temp", "desc"]
    onWeatherElementsChanged: save()
    property var weatherElementsDisabled: []
    onWeatherElementsDisabledChanged: save()

    property var rightItems: ["battery", "notif", "weather"]

    property var hiddenItems: []

    readonly property var allItemIds: ["launcher", "workspace", "systray", "clock", "battery", "notif", "weather"]
    readonly property var hideableItems: ["launcher", "workspace", "systray", "clock", "weather", "notif"]

    readonly property var weatherBarLayouts: []

    readonly property var clockFormats: [
        { value: "time", label: "Time Only" },
        { value: "date", label: "Date Only" },
        { value: "time-date", label: "Time + Date" },
        { value: "date-time", label: "Date + Time" },
        { value: "time-tz", label: "Time + Timezone" }
    ]

    readonly property var batteryStyles: [
        { value: "both", label: "Icon + Percentage" },
        { value: "icon", label: "Icon Only" },
        { value: "percentage", label: "Percentage Only" }
    ]

    readonly property var itemLabels: ({
        "launcher": "App Launcher",
        "workspace": "Workspaces",
        "systray": "System Tray",
        "clock": "Clock",
        "battery": "Battery",
        "notif": "Notifications",
        "weather": "Weather",
        "stats": "System Stats",
        "quickactions": "Quick Actions",
        "nowplaying": "Now Playing"
    })

    readonly property var presets: [
        {
            name: "Default",
            desc: "Classic layout with launcher, workspace, systray on left",
            left: ["launcher", "workspace", "systray"],
            center: ["clock"],
            right: ["battery", "notif", "weather"],
            hidden: []
        },
        {
            name: "Centered",
            desc: "Workspace centered, clock on left",
            left: ["clock"],
            center: ["workspace"],
            right: ["battery", "notif", "weather"],
            hidden: ["launcher", "systray"]
        },
        {
            name: "Minimal",
            desc: "Only clock centered, clean and simple",
            left: [],
            center: ["clock"],
            right: ["battery", "notif", "weather"],
            hidden: ["launcher", "workspace", "systray"]
        },
        {
            name: "Productivity",
            desc: "Workspace and systray centered, launcher on left",
            left: ["launcher"],
            center: ["workspace", "clock"],
            right: ["battery", "notif", "weather"],
            hidden: ["systray"]
        },
        {
            name: "Split",
            desc: "Balanced split with clock on right",
            left: ["launcher", "workspace"],
            center: ["systray"],
            right: ["clock", "battery", "notif", "weather"],
            hidden: []
        }
    ]

    property var _itemRefs: ({})

    signal layoutChanged()

    function registerItem(id, item) {
        var copy = {}
        for (var key in _itemRefs) copy[key] = _itemRefs[key]
        copy[id] = item
        _itemRefs = copy
    }

    function unregisterItem(id) {
        var copy = {}
        for (var key in _itemRefs) {
            if (key !== id) copy[key] = _itemRefs[key]
        }
        _itemRefs = copy
    }

    function getItem(id) {
        return _itemRefs[id] || null
    }

    function isHidden(id) {
        return hiddenItems.indexOf(id) !== -1
    }

    function toggleHide(id) {
        var copy = hiddenItems.slice()
        var idx = copy.indexOf(id)
        if (idx === -1) copy.push(id)
        else copy.splice(idx, 1)
        hiddenItems = copy
        save()
        updateVisibleItems()
    }

    function filterVisible(items) {
        var result = []
        for (var i = 0; i < items.length; i++) {
            if (hiddenItems.indexOf(items[i]) === -1) result.push(items[i])
        }
        return result
    }

    property var visibleLeftItems: ["launcher", "workspace", "systray"]
    property var visibleCenterItems: ["clock"]
    property var visibleRightItems: ["battery", "notif", "weather"]

    function updateVisibleItems() {
        if (root._loading) return
        visibleLeftItems = filterVisible(leftItems)
        visibleCenterItems = filterVisible(centerItems)
        visibleRightItems = filterVisible(rightItems)
    }

    onLeftItemsChanged: updateVisibleItems()
    onCenterItemsChanged: updateVisibleItems()
    onRightItemsChanged: updateVisibleItems()
    onHiddenItemsChanged: updateVisibleItems()

    function getItemsForSection(section) {
        if (section === "left") return leftItems
        if (section === "center") return centerItems
        if (section === "right") return rightItems
        return []
    }

    function moveItemWithinSection(section, fromIndex, toIndex) {
        var items = getItemsForSection(section).slice()
        if (fromIndex < 0 || fromIndex >= items.length) return
        if (toIndex < 0 || toIndex >= items.length) return
        var item = items.splice(fromIndex, 1)[0]
        items.splice(toIndex, 0, item)
        setSectionItems(section, items)
    }

    function moveItemToSection(itemId, targetSection, targetIndex) {
        var sourceSection = findItemSection(itemId)
        if (sourceSection === "" || sourceSection === targetSection) return

        var srcItems = getItemsForSection(sourceSection).slice()
        var srcIdx = srcItems.indexOf(itemId)
        if (srcIdx === -1) return
        srcItems.splice(srcIdx, 1)
        setSectionItems(sourceSection, srcItems)

        var tgtItems = getItemsForSection(targetSection).slice()
        if (targetIndex < 0) targetIndex = 0
        if (targetIndex > tgtItems.length) targetIndex = tgtItems.length
        tgtItems.splice(targetIndex, 0, itemId)
        setSectionItems(targetSection, tgtItems)
    }

    function findItemSection(itemId) {
        if (leftItems.indexOf(itemId) !== -1) return "left"
        if (centerItems.indexOf(itemId) !== -1) return "center"
        if (rightItems.indexOf(itemId) !== -1) return "right"
        return ""
    }

    function getItemIndex(section, itemId) {
        var items = getItemsForSection(section)
        return items.indexOf(itemId)
    }

    function setSectionItems(section, items) {
        if (section === "left") leftItems = items
        else if (section === "center") centerItems = items
        else if (section === "right") rightItems = items
        save()
        layoutChanged()
    }

    function setBarPosition(pos) {
        barPosition = pos
        save()
        layoutChanged()
    }

    function toggleBarPosition() {
        setBarPosition(isBottom ? "top" : "bottom")
    }

    function resetOpacity() {
        barOpacity = 1.0
        calendarOpacity = 1.0
        notifOpacity = 1.0
        systrayOpacity = 1.0
        save()
    }

    function resetBarHeight() {
        barHeight = 32
        save()
    }

    function resetAll() {
        barPosition = "top"
        leftItems = ["launcher", "workspace", "systray"]
        centerItems = ["clock"]
        rightItems = ["battery", "notif", "weather"]
        hiddenItems = []
        showBatteryPercentage = true
        clockFormat = "time"
        clock24Hour = true
        clockShowSeconds = false
        batteryLowThreshold = 20
        batteryStyle = "both"
        batteryElements = ["charging", "percentage", "icon"]
        barHeight = 32
        barOpacity = 1.0
        calendarOpacity = 1.0
        notifOpacity = 1.0
        systrayOpacity = 1.0
        weatherPopupOpacity = 1.0
        weatherPopupRounded = false
        calendarPopupRounded = false
        notifPopupRounded = false
        rightbarPopupRounded = false
        barBorder = true
        showSeparators = false
        workspaceCount = 5

        systrayShowAll = true
        systrayCollapseLimit = 5

        weatherShowIcon = true
        weatherShowTemp = true
        weatherShowDesc = false
        weatherBarLayout = "icon-temp"
        weatherElements = ["icon", "temp", "desc"]
        weatherElementsDisabled = []

        showScreenClock = false
        desktopClockX = 40
        desktopClockY = 40
        desktopClockColorMode = "accent"
        desktopClockScale = 1.0
        desktopClock24Hour = true
        desktopClockShowSeconds = false
        desktopClockShowDate = true
        desktopClockShowWeekday = true
        desktopClockShowYear = false
        desktopClockAlignment = 1

        showScreenSystemStats = false
        desktopStatsX = 40
        desktopStatsY = 800
        desktopStatsLayout = "default"
        desktopStatsColorMode = "accent"
        desktopStatsShowCpu = true
        desktopStatsShowGpu = true
        desktopStatsShowMem = true
        desktopStatsShowNet = true
        desktopStatsShowDisk = false
        desktopStatsShowUptime = false
        desktopStatsShowTemp = false
        desktopStatsNetDownLabel = "DOWN"
        desktopStatsNetUpLabel = "UP"
        desktopStatsNetLabelStyle = "short"
        desktopStatsScale = 1.0

        showScreenWeather = false
        desktopWeatherX = 40
        desktopWeatherY = 600
        desktopWeatherLayout = "default"
        desktopWeatherScale = 1.0
        desktopWeatherCity = systemCity
        desktopWeatherUnit = "C"

        showScreenQuickActions = false
        desktopQuickActionsX = 800
        desktopQuickActionsY = 900
        desktopQuickActionsVisible = true
        desktopQuickActionsPinned = false
        desktopQuickActionsRadius = 12
        desktopQuickActionsScale = 1.0

        showScreenNowPlaying = false
        desktopNowPlayingX = 1400
        desktopNowPlayingY = 40
        desktopNowPlayingScale = 1.0

        showScreenEqualizer = false
        desktopEqualizerX = 800
        desktopEqualizerY = 400
        desktopEqualizerScale = 1.0
        desktopEqualizerColorMode = "accent"
        desktopEqualizerCustomColor = "#ffffff"
        desktopEqualizerStyle = "wave"
        desktopEqualizerLineThickness = 2.0
        desktopEqualizerFillOpacity = 0.15
        desktopEqualizerMirrored = true
        desktopEqualizerDoubleWave = true
        desktopEqualizerFilled = false

        desktopWidgetsOpacity = 1.0
        desktopClockOpacity = 1.0
        desktopNowPlayingOpacity = 1.0
        desktopStatsOpacity = 1.0
        desktopWeatherOpacity = 1.0
        desktopQuickActionsOpacity = 1.0

        showIndicators = true

        save()
        layoutChanged()
    }

    function resetToDefaults() {
        applyPreset(0)
    }

    function applyPreset(index) {
        if (index < 0 || index >= presets.length) return
        var p = presets[index]
        leftItems = p.left.slice()
        centerItems = p.center.slice()
        rightItems = p.right.slice()
        hiddenItems = p.hidden.slice()
        save()
        layoutChanged()
    }

    function save() {
        if (root._loading) return
        var data = {
            barPosition: root.barPosition,
            leftItems: root.leftItems,
            centerItems: root.centerItems,
            rightItems: root.rightItems,
            hiddenItems: root.hiddenItems,
            showBatteryPercentage: root.showBatteryPercentage,
            clockFormat: root.clockFormat,
            clock24Hour: root.clock24Hour,
            clockShowSeconds: root.clockShowSeconds,
            batteryLowThreshold: root.batteryLowThreshold,
            batteryStyle: root.batteryStyle,
            batteryElements: root.batteryElements,
            barHeight: root.barHeight,
            barOpacity: root.barOpacity,
            calendarOpacity: root.calendarOpacity,
            notifOpacity: root.notifOpacity,
            systrayOpacity: root.systrayOpacity,
            weatherPopupOpacity: root.weatherPopupOpacity,
            weatherPopupRounded: root.weatherPopupRounded,
            calendarPopupRounded: root.calendarPopupRounded,
            notifPopupRounded: root.notifPopupRounded,
            rightbarPopupRounded: root.rightbarPopupRounded,
            barBorder: root.barBorder,
            showSeparators: root.showSeparators,
            workspaceCount: root.workspaceCount,

            systrayShowAll: root.systrayShowAll,
            systrayCollapseLimit: root.systrayCollapseLimit,

            weatherShowIcon: root.weatherShowIcon,
            weatherShowTemp: root.weatherShowTemp,
            weatherShowDesc: root.weatherShowDesc,
            weatherBarLayout: root.weatherBarLayout,
            weatherElements: root.weatherElements,
            weatherElementsDisabled: root.weatherElementsDisabled,

            // Desktop Widgets
            showScreenClock: root.showScreenClock,
            desktopClockX: root.desktopClockX,
            desktopClockY: root.desktopClockY,
            desktopClockRotation: root.desktopClockRotation,
            desktopClockColorMode: root.desktopClockColorMode,
            desktopClockScale: root.desktopClockScale,
            desktopClock24Hour: root.desktopClock24Hour,
            desktopClockShowSeconds: root.desktopClockShowSeconds,
            desktopClockShowDate: root.desktopClockShowDate,
            desktopClockShowWeekday: root.desktopClockShowWeekday,
            desktopClockShowYear: root.desktopClockShowYear,
            desktopClockAlignment: root.desktopClockAlignment,

            showScreenSystemStats: root.showScreenSystemStats,
            desktopStatsX: root.desktopStatsX,
            desktopStatsY: root.desktopStatsY,
            desktopStatsRotation: root.desktopStatsRotation,
            desktopStatsLayout: root.desktopStatsLayout,
            desktopStatsColorMode: root.desktopStatsColorMode,
            desktopStatsShowCpu: root.desktopStatsShowCpu,
            desktopStatsShowGpu: root.desktopStatsShowGpu,
            desktopStatsShowMem: root.desktopStatsShowMem,
            desktopStatsShowNet: root.desktopStatsShowNet,
            desktopStatsShowDisk: root.desktopStatsShowDisk,
            desktopStatsShowUptime: root.desktopStatsShowUptime,
            desktopStatsShowTemp: root.desktopStatsShowTemp,
            desktopStatsNetDownLabel: root.desktopStatsNetDownLabel,
            desktopStatsNetUpLabel: root.desktopStatsNetUpLabel,
            desktopStatsNetLabelStyle: root.desktopStatsNetLabelStyle,
            desktopStatsScale: root.desktopStatsScale,

            showScreenWeather: root.showScreenWeather,
            desktopWeatherX: root.desktopWeatherX,
            desktopWeatherY: root.desktopWeatherY,
            desktopWeatherRotation: root.desktopWeatherRotation,
            desktopWeatherLayout: root.desktopWeatherLayout,
            desktopWeatherScale: root.desktopWeatherScale,
            desktopWeatherCity: root.desktopWeatherCity,
            desktopWeatherUnit: root.desktopWeatherUnit,

            showScreenQuickActions: root.showScreenQuickActions,
            desktopQuickActionsX: root.desktopQuickActionsX,
            desktopQuickActionsY: root.desktopQuickActionsY,
            desktopQuickActionsRotation: root.desktopQuickActionsRotation,
            desktopQuickActionsVisible: root.desktopQuickActionsVisible,
            desktopQuickActionsPinned: root.desktopQuickActionsPinned,
            desktopQuickActionsRadius: root.desktopQuickActionsRadius,
            desktopQuickActionsScale: root.desktopQuickActionsScale,

            showScreenNowPlaying: root.showScreenNowPlaying,
            desktopNowPlayingX: root.desktopNowPlayingX,
            desktopNowPlayingY: root.desktopNowPlayingY,
            desktopNowPlayingRotation: root.desktopNowPlayingRotation,
            desktopNowPlayingScale: root.desktopNowPlayingScale,

            showScreenEqualizer: root.showScreenEqualizer,
            desktopEqualizerX: root.desktopEqualizerX,
            desktopEqualizerY: root.desktopEqualizerY,
            desktopEqualizerRotation: root.desktopEqualizerRotation,
            desktopEqualizerScale: root.desktopEqualizerScale,
            desktopEqualizerColorMode: root.desktopEqualizerColorMode,
            desktopEqualizerCustomColor: root.desktopEqualizerCustomColor,
            desktopEqualizerStyle: root.desktopEqualizerStyle,
            desktopEqualizerLineThickness: root.desktopEqualizerLineThickness,
            desktopEqualizerFillOpacity: root.desktopEqualizerFillOpacity,
            desktopEqualizerMirrored: root.desktopEqualizerMirrored,
            desktopEqualizerDoubleWave: root.desktopEqualizerDoubleWave,
            desktopEqualizerFilled: root.desktopEqualizerFilled,

            desktopWidgetsOpacity: root.desktopWidgetsOpacity,
            desktopClockOpacity: root.desktopClockOpacity,
            desktopNowPlayingOpacity: root.desktopNowPlayingOpacity,
            desktopEqualizerOpacity: root.desktopEqualizerOpacity,
            desktopStatsOpacity: root.desktopStatsOpacity,
            desktopWeatherOpacity: root.desktopWeatherOpacity,
            desktopQuickActionsOpacity: root.desktopQuickActionsOpacity,

            showIndicators: root.showIndicators
        }
        var json = JSON.stringify(data)
        // Escaping for shell: replace ' with '\''
        var escapedJson = json.replace(/'/g, "'\\''")
        writeProc.exec(["sh", "-c", "mkdir -p $(dirname '" + root.savePath + "') && echo '" + escapedJson + "' > '" + root.savePath + "'"])
    }

    function load() {
        readProc.exec(["sh", "-c", "cat '" + root.savePath + "' 2>/dev/null || echo ''"])
    }

    Process {
        id: writeProc
    }

    Process {
        id: readProc
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root._loading = true
                    var text = this.text.trim()
                    if (text === "") {
                        root._loading = false
                        return
                    }
                    var data = JSON.parse(text)
                    if (data.hasOwnProperty("barPosition")) root.barPosition = data.barPosition
                    if (data.hasOwnProperty("leftItems") && Array.isArray(data.leftItems)) root.leftItems = data.leftItems
                    if (data.hasOwnProperty("centerItems") && Array.isArray(data.centerItems)) root.centerItems = data.centerItems
                    if (data.hasOwnProperty("rightItems") && Array.isArray(data.rightItems)) root.rightItems = data.rightItems
                    if (data.hasOwnProperty("hiddenItems") && Array.isArray(data.hiddenItems)) root.hiddenItems = data.hiddenItems
                    if (data.hasOwnProperty("showBatteryPercentage")) root.showBatteryPercentage = data.showBatteryPercentage
                    if (data.hasOwnProperty("clockFormat")) root.clockFormat = data.clockFormat
                    if (data.hasOwnProperty("clock24Hour")) root.clock24Hour = data.clock24Hour
                    if (data.hasOwnProperty("clockShowSeconds")) root.clockShowSeconds = data.clockShowSeconds
                    if (data.hasOwnProperty("batteryLowThreshold")) root.batteryLowThreshold = data.batteryLowThreshold
                    if (data.hasOwnProperty("batteryStyle")) root.batteryStyle = data.batteryStyle
                    if (data.hasOwnProperty("batteryElements") && Array.isArray(data.batteryElements)) root.batteryElements = data.batteryElements
                    if (data.hasOwnProperty("barHeight")) root.barHeight = data.barHeight
                    if (data.hasOwnProperty("barOpacity")) root.barOpacity = data.barOpacity
                    if (data.hasOwnProperty("calendarOpacity")) root.calendarOpacity = data.calendarOpacity
                    if (data.hasOwnProperty("notifOpacity")) root.notifOpacity = data.notifOpacity
                    if (data.hasOwnProperty("systrayOpacity")) root.systrayOpacity = data.systrayOpacity
                    if (data.hasOwnProperty("weatherPopupOpacity")) root.weatherPopupOpacity = data.weatherPopupOpacity
                    if (data.hasOwnProperty("weatherPopupRounded")) root.weatherPopupRounded = data.weatherPopupRounded
                    if (data.hasOwnProperty("calendarPopupRounded")) root.calendarPopupRounded = data.calendarPopupRounded
                    if (data.hasOwnProperty("notifPopupRounded")) root.notifPopupRounded = data.notifPopupRounded
                    if (data.hasOwnProperty("rightbarPopupRounded")) root.rightbarPopupRounded = data.rightbarPopupRounded
                    if (data.hasOwnProperty("barBorder")) root.barBorder = data.barBorder
                    if (data.hasOwnProperty("showSeparators")) root.showSeparators = data.showSeparators
                    if (data.hasOwnProperty("workspaceCount")) root.workspaceCount = data.workspaceCount

                    if (data.hasOwnProperty("systrayShowAll")) root.systrayShowAll = data.systrayShowAll
                    if (data.hasOwnProperty("systrayCollapseLimit")) root.systrayCollapseLimit = data.systrayCollapseLimit

                    if (data.hasOwnProperty("weatherShowIcon")) root.weatherShowIcon = data.weatherShowIcon
                    if (data.hasOwnProperty("weatherShowTemp")) root.weatherShowTemp = data.weatherShowTemp
                    if (data.hasOwnProperty("weatherShowDesc")) root.weatherShowDesc = data.weatherShowDesc
                    if (data.hasOwnProperty("weatherBarLayout")) root.weatherBarLayout = data.weatherBarLayout
                    if (data.hasOwnProperty("weatherElements") && Array.isArray(data.weatherElements)) root.weatherElements = data.weatherElements
                    if (data.hasOwnProperty("weatherElementsDisabled") && Array.isArray(data.weatherElementsDisabled)) root.weatherElementsDisabled = data.weatherElementsDisabled

                    // Desktop Widgets
                    if (data.hasOwnProperty("showScreenClock")) root.showScreenClock = data.showScreenClock
                    if (data.hasOwnProperty("desktopClockX")) root.desktopClockX = data.desktopClockX
                    if (data.hasOwnProperty("desktopClockY")) root.desktopClockY = data.desktopClockY
                    if (data.hasOwnProperty("desktopClockRotation")) root.desktopClockRotation = data.desktopClockRotation
                    if (data.hasOwnProperty("desktopClockColorMode")) root.desktopClockColorMode = data.desktopClockColorMode
                    if (data.hasOwnProperty("desktopClockScale")) root.desktopClockScale = data.desktopClockScale
                    if (data.hasOwnProperty("desktopClock24Hour")) root.desktopClock24Hour = data.desktopClock24Hour
                    if (data.hasOwnProperty("desktopClockShowSeconds")) root.desktopClockShowSeconds = data.desktopClockShowSeconds
                    if (data.hasOwnProperty("desktopClockShowDate")) root.desktopClockShowDate = data.desktopClockShowDate
                    if (data.hasOwnProperty("desktopClockShowWeekday")) root.desktopClockShowWeekday = data.desktopClockShowWeekday
                    if (data.hasOwnProperty("desktopClockShowYear")) root.desktopClockShowYear = data.desktopClockShowYear
                    if (data.hasOwnProperty("desktopClockAlignment")) root.desktopClockAlignment = data.desktopClockAlignment

                    if (data.hasOwnProperty("showScreenSystemStats")) root.showScreenSystemStats = data.showScreenSystemStats
                    if (data.hasOwnProperty("desktopStatsX")) root.desktopStatsX = data.desktopStatsX
                    if (data.hasOwnProperty("desktopStatsY")) root.desktopStatsY = data.desktopStatsY
                    if (data.hasOwnProperty("desktopStatsRotation")) root.desktopStatsRotation = data.desktopStatsRotation
                    if (data.hasOwnProperty("desktopStatsLayout")) root.desktopStatsLayout = data.desktopStatsLayout
                    if (data.hasOwnProperty("desktopStatsColorMode")) root.desktopStatsColorMode = data.desktopStatsColorMode
                    if (data.hasOwnProperty("desktopStatsShowCpu")) root.desktopStatsShowCpu = data.desktopStatsShowCpu
                    if (data.hasOwnProperty("desktopStatsShowGpu")) root.desktopStatsShowGpu = data.desktopStatsShowGpu
                    if (data.hasOwnProperty("desktopStatsShowMem")) root.desktopStatsShowMem = data.desktopStatsShowMem
                    if (data.hasOwnProperty("desktopStatsShowNet")) root.desktopStatsShowNet = data.desktopStatsShowNet
                    if (data.hasOwnProperty("desktopStatsShowDisk")) root.desktopStatsShowDisk = data.desktopStatsShowDisk
                    if (data.hasOwnProperty("desktopStatsShowUptime")) root.desktopStatsShowUptime = data.desktopStatsShowUptime
                    if (data.hasOwnProperty("desktopStatsShowTemp")) root.desktopStatsShowTemp = data.desktopStatsShowTemp
                    if (data.hasOwnProperty("desktopStatsNetDownLabel")) root.desktopStatsNetDownLabel = data.desktopStatsNetDownLabel
                    if (data.hasOwnProperty("desktopStatsNetUpLabel")) root.desktopStatsNetUpLabel = data.desktopStatsNetUpLabel
                    if (data.hasOwnProperty("desktopStatsNetLabelStyle")) root.desktopStatsNetLabelStyle = data.desktopStatsNetLabelStyle
                    if (data.hasOwnProperty("desktopStatsScale")) root.desktopStatsScale = data.desktopStatsScale

                    if (data.hasOwnProperty("showScreenWeather")) root.showScreenWeather = data.showScreenWeather
                    if (data.hasOwnProperty("desktopWeatherX")) root.desktopWeatherX = data.desktopWeatherX
                    if (data.hasOwnProperty("desktopWeatherY")) root.desktopWeatherY = data.desktopWeatherY
                    if (data.hasOwnProperty("desktopWeatherRotation")) root.desktopWeatherRotation = data.desktopWeatherRotation
                    if (data.hasOwnProperty("desktopWeatherLayout")) root.desktopWeatherLayout = data.desktopWeatherLayout
                    if (data.hasOwnProperty("desktopWeatherScale")) root.desktopWeatherScale = data.desktopWeatherScale
                    if (data.hasOwnProperty("desktopWeatherCity")) root.desktopWeatherCity = data.desktopWeatherCity
                    if (data.hasOwnProperty("desktopWeatherUnit")) root.desktopWeatherUnit = data.desktopWeatherUnit
                    
                    if (data.hasOwnProperty("showScreenQuickActions")) root.showScreenQuickActions = data.showScreenQuickActions
                    if (data.hasOwnProperty("desktopQuickActionsX")) root.desktopQuickActionsX = data.desktopQuickActionsX
                    if (data.hasOwnProperty("desktopQuickActionsY")) root.desktopQuickActionsY = data.desktopQuickActionsY
                    if (data.hasOwnProperty("desktopQuickActionsRotation")) root.desktopQuickActionsRotation = data.desktopQuickActionsRotation
                    if (data.hasOwnProperty("desktopQuickActionsVisible")) root.desktopQuickActionsVisible = data.desktopQuickActionsVisible
                    if (data.hasOwnProperty("desktopQuickActionsPinned")) root.desktopQuickActionsPinned = data.desktopQuickActionsPinned
                    if (data.hasOwnProperty("desktopQuickActionsRadius")) root.desktopQuickActionsRadius = data.desktopQuickActionsRadius
                    if (data.hasOwnProperty("desktopQuickActionsScale")) root.desktopQuickActionsScale = data.desktopQuickActionsScale

                    if (data.hasOwnProperty("showScreenNowPlaying")) root.showScreenNowPlaying = data.showScreenNowPlaying
                    if (data.hasOwnProperty("desktopNowPlayingX")) root.desktopNowPlayingX = data.desktopNowPlayingX
                    if (data.hasOwnProperty("desktopNowPlayingY")) root.desktopNowPlayingY = data.desktopNowPlayingY
                    if (data.hasOwnProperty("desktopNowPlayingRotation")) root.desktopNowPlayingRotation = data.desktopNowPlayingRotation
                    if (data.hasOwnProperty("desktopNowPlayingScale")) root.desktopNowPlayingScale = data.desktopNowPlayingScale

                    if (data.hasOwnProperty("showScreenEqualizer")) root.showScreenEqualizer = data.showScreenEqualizer
                    if (data.hasOwnProperty("desktopEqualizerX")) root.desktopEqualizerX = data.desktopEqualizerX
                    if (data.hasOwnProperty("desktopEqualizerY")) root.desktopEqualizerY = data.desktopEqualizerY
                    if (data.hasOwnProperty("desktopEqualizerRotation")) root.desktopEqualizerRotation = data.desktopEqualizerRotation
                    if (data.hasOwnProperty("desktopEqualizerScale")) root.desktopEqualizerScale = data.desktopEqualizerScale
                    if (data.hasOwnProperty("desktopEqualizerColorMode")) root.desktopEqualizerColorMode = data.desktopEqualizerColorMode
                    if (data.hasOwnProperty("desktopEqualizerCustomColor")) root.desktopEqualizerCustomColor = data.desktopEqualizerCustomColor
                    if (data.hasOwnProperty("desktopEqualizerStyle")) root.desktopEqualizerStyle = data.desktopEqualizerStyle
                    if (data.hasOwnProperty("desktopEqualizerLineThickness")) root.desktopEqualizerLineThickness = data.desktopEqualizerLineThickness
                    if (data.hasOwnProperty("desktopEqualizerFillOpacity")) root.desktopEqualizerFillOpacity = data.desktopEqualizerFillOpacity
                    if (data.hasOwnProperty("desktopEqualizerMirrored")) root.desktopEqualizerMirrored = data.desktopEqualizerMirrored
                    if (data.hasOwnProperty("desktopEqualizerDoubleWave")) root.desktopEqualizerDoubleWave = data.desktopEqualizerDoubleWave
                    if (data.hasOwnProperty("desktopEqualizerFilled")) root.desktopEqualizerFilled = data.desktopEqualizerFilled

                    if (data.hasOwnProperty("desktopWidgetsOpacity")) root.desktopWidgetsOpacity = data.desktopWidgetsOpacity
                    if (data.hasOwnProperty("desktopClockOpacity")) root.desktopClockOpacity = data.desktopClockOpacity
                    if (data.hasOwnProperty("desktopNowPlayingOpacity")) root.desktopNowPlayingOpacity = data.desktopNowPlayingOpacity
                    if (data.hasOwnProperty("desktopEqualizerOpacity")) root.desktopEqualizerOpacity = data.desktopEqualizerOpacity
                    if (data.hasOwnProperty("desktopStatsOpacity")) root.desktopStatsOpacity = data.desktopStatsOpacity
                    if (data.hasOwnProperty("desktopWeatherOpacity")) root.desktopWeatherOpacity = data.desktopWeatherOpacity
                    if (data.hasOwnProperty("desktopQuickActionsOpacity")) root.desktopQuickActionsOpacity = data.desktopQuickActionsOpacity

                    if (data.hasOwnProperty("showIndicators")) root.showIndicators = data.showIndicators

                    loadFinishedTimer.start()

                    // Validation: Ensure all allItemIds are present somewhere
                    var allCurrent = root.leftItems.concat(root.centerItems).concat(root.rightItems)
                    var changed = false
                    for (var i = 0; i < root.allItemIds.length; i++) {
                        var id = root.allItemIds[i]
                        if (allCurrent.indexOf(id) === -1) {
                            // Item is missing, restore to default section
                            var defaultSection = "left"
                            if (id === "clock") defaultSection = "center"
                            else if (id === "battery" || id === "notif") defaultSection = "right"
                            
                            var items = root.getItemsForSection(defaultSection).slice()
                            items.push(id)
                            if (defaultSection === "left") root.leftItems = items
                            else if (defaultSection === "center") root.centerItems = items
                            else if (defaultSection === "right") root.rightItems = items
                            changed = true
                        }
                    }
                } catch (e) {
                    root._loading = false
                }
            }
        }
    }

    Timer {
        id: loadFinishedTimer
        interval: 100
        repeat: false
        onTriggered: {
            root._loading = false

            // Migration: ensure all 3 weather elements exist
            var defaults = ["icon", "temp", "desc"]
            var migrated = root.weatherElements.slice()
            for (var i = 0; i < defaults.length; i++) {
                if (migrated.indexOf(defaults[i]) === -1) migrated.push(defaults[i])
            }
            if (migrated.length !== root.weatherElements.length) {
                root.weatherElements = migrated
                root.save()
            }

            updateVisibleItems()
            var allCurrent = root.leftItems.concat(root.centerItems).concat(root.rightItems)
            var changed = false
            for (var i = 0; i < root.allItemIds.length; i++) {
                if (allCurrent.indexOf(root.allItemIds[i]) === -1) changed = true
            }
            if (changed) root.save()
        }
    }

    Component.onCompleted: {
        detectCityProc.running = true
        load()
    }
}
