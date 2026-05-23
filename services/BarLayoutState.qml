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
    property bool barBorder: true
    onBarBorderChanged: save()
    property bool showSeparators: false
    onShowSeparatorsChanged: save()
    property int workspaceCount: 5
    onWorkspaceCountChanged: save()

    property var leftItems: ["launcher", "workspace", "systray"]
    property var centerItems: ["clock"]
    property var rightItems: ["battery", "notif"]

    property var hiddenItems: []

    readonly property var allItemIds: ["launcher", "workspace", "systray", "clock", "battery", "notif"]
    readonly property var hideableItems: ["launcher", "workspace", "systray", "clock"]

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
        "workspace": "Workspace",
        "systray": "System Tray",
        "clock": "Clock",
        "battery": "Battery",
        "notif": "Notifications"
    })

    readonly property var presets: [
        {
            name: "Default",
            desc: "Classic layout with launcher, workspace, systray on left",
            left: ["launcher", "workspace", "systray"],
            center: ["clock"],
            right: ["battery", "notif"],
            hidden: []
        },
        {
            name: "Centered",
            desc: "Workspace centered, clock on left",
            left: ["clock"],
            center: ["workspace"],
            right: ["battery", "notif"],
            hidden: ["launcher", "systray"]
        },
        {
            name: "Minimal",
            desc: "Only clock centered, clean and simple",
            left: [],
            center: ["clock"],
            right: ["battery", "notif"],
            hidden: ["launcher", "workspace", "systray"]
        },
        {
            name: "Productivity",
            desc: "Workspace and systray centered, launcher on left",
            left: ["launcher"],
            center: ["workspace", "clock"],
            right: ["battery", "notif"],
            hidden: ["systray"]
        },
        {
            name: "Split",
            desc: "Balanced split with clock on right",
            left: ["launcher", "workspace"],
            center: ["systray"],
            right: ["clock", "battery", "notif"],
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

    property var visibleLeftItems: []
    property var visibleCenterItems: []
    property var visibleRightItems: []

    function updateVisibleItems() {
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
        layoutChanged()
    }

    function setBarPosition(pos) {
        barPosition = pos
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
        rightItems = ["battery", "notif"]
        hiddenItems = []
        showBatteryPercentage = true
        clockFormat = "time"
        clock24Hour = true
        clockShowSeconds = false
        batteryLowThreshold = 20
        batteryStyle = "both"
        batteryShowCharging = true
        barHeight = 32
        barOpacity = 1.0
        calendarOpacity = 1.0
        notifOpacity = 1.0
        systrayOpacity = 1.0
        barBorder = true
        showSeparators = false
        workspaceCount = 5
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
            batteryShowCharging: root.batteryShowCharging,
            barHeight: root.barHeight,
            barOpacity: root.barOpacity,
            calendarOpacity: root.calendarOpacity,
            notifOpacity: root.notifOpacity,
            systrayOpacity: root.systrayOpacity,
            barBorder: root.barBorder,
            showSeparators: root.showSeparators,
            workspaceCount: root.workspaceCount
        }
        var json = JSON.stringify(data)
        writeProc.exec(["sh", "-c", "mkdir -p $(dirname '" + root.savePath + "') && echo '" + json + "' > '" + root.savePath + "'"])
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
                    var text = this.text.trim()
                    if (text === "") return
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
                    if (data.hasOwnProperty("batteryShowCharging")) root.batteryShowCharging = data.batteryShowCharging
                    if (data.hasOwnProperty("barHeight")) root.barHeight = data.barHeight
                    if (data.hasOwnProperty("barOpacity")) root.barOpacity = data.barOpacity
                    if (data.hasOwnProperty("calendarOpacity")) root.calendarOpacity = data.calendarOpacity
                    if (data.hasOwnProperty("notifOpacity")) root.notifOpacity = data.notifOpacity
                    if (data.hasOwnProperty("systrayOpacity")) root.systrayOpacity = data.systrayOpacity
                    if (data.hasOwnProperty("barBorder")) root.barBorder = data.barBorder
                    if (data.hasOwnProperty("showSeparators")) root.showSeparators = data.showSeparators
                    if (data.hasOwnProperty("workspaceCount")) root.workspaceCount = data.workspaceCount
                } catch (e) {}
            }
        }
    }

    Component.onCompleted: {
        load()
        updateVisibleItems()
    }
}
