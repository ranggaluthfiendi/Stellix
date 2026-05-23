import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.config
import qs.services
import qs.components.widgets.rightbar
import qs.components.elements
import Quickshell.Wayland

PopupWindow {
    id: root
    color: "transparent"
    property var popupPanel: null
    property var closeCallback: null
    property var trackedNotifs: []
    visible: false
    property real barRightPanelHeight: 0

    property bool slideIn: false
    property real slideY: -Theme.dp(30)

    property bool clearAllActive: false
    property int clearAllProgress: 0

    readonly property int filteredCount: root.filteredNotifs().length
    readonly property real itemH: Theme.dp(56)
    readonly property int maxVisibleItems: 2
    readonly property real actionItemH: Theme.dp(30)

    readonly property bool hasCategories: root.notifCategories().length > 1
    readonly property real catRowH: root.hasCategories ? Theme.dp(24) : 0

    property int expandedNotifIndex: -1

    readonly property real refPanelH: root.barRightPanelHeight > 0 ? root.barRightPanelHeight : Theme.dp(380)
    readonly property real maxListH: root.refPanelH - Theme.dp(80)
    readonly property real listH: root.calcListH()
    readonly property bool needsScroll: root.listH > root.maxListH

    implicitWidth: Theme.dp(372)
    implicitHeight: root.calcTotalH()
    grabFocus: false

    property real s: Scales.uiScale

    property string filterCategory: "all"

    onVisibleChanged: {
        if (visible) {
            slideY = -Theme.dp(30)
            slideIn = true
        } else {
            root.expandedNotifIndex = -1
        }
    }

    function calcTotalH() {
        var headerH = Theme.dp(32) + Theme.dp(4) + root.catRowH + Theme.dp(1)
        var footerH = Theme.dp(8)
        var actualListH = root.needsScroll ? root.maxListH : root.listH
        return headerH + actualListH + footerH
    }

    function calcListH() {
        if (root.filteredCount === 0) return Theme.dp(100)
        var total = 0
        var arr = root.filteredNotifs()
        for (var i = 0; i < arr.length; i++) {
            total += root.itemH
            if (i > 0) total += Theme.dp(4)
            if (root.expandedNotifIndex === i && arr[i] && arr[i].actions) {
                var ac = arr[i].actions.length
                total += Theme.dp(4) + Theme.dp(1) + (ac * root.actionItemH) + Math.max(ac - 1, 0) * Theme.dp(3) + Theme.dp(8)
            }
        }
        return total
    }

    function filteredNotifs() {
        var arr = (root.trackedNotifs || []).slice()
        if (root.filterCategory !== "all") {
            arr = arr.filter(function(n) {
                return n && n.appName && n.appName === root.filterCategory
            })
        }
        arr.sort(function(a, b) {
            var ta = a && a.time ? a.time : 0
            var tb = b && b.time ? b.time : 0
            return tb - ta
        })
        return arr
    }

    function formatNotifTime(ts) {
        if (!ts) return ""
        var d = new Date(ts * 1000)
        var now = new Date()
        var diff = Math.floor((now - d) / 1000)
        if (diff < 60) return "now"
        if (diff < 3600) return Math.floor(diff / 60) + "m ago"
        if (diff < 86400) return Math.floor(diff / 3600) + "h ago"
        return d.getDate() + "/" + (d.getMonth() + 1)
    }

    function formatNotifTimeFull(ts) {
        if (!ts) return ""
        var d = new Date(ts * 1000)
        var h = d.getHours().toString().padStart(2, "0")
        var m = d.getMinutes().toString().padStart(2, "0")
        return h + ":" + m
    }

    function dismissAll() {
        if (root.clearAllActive) return
        var arr = root.filteredNotifs()
        if (arr.length === 0) return
        root.clearAllActive = true
        root.clearAllProgress = 0
        clearAllTimer.start()
    }

    Timer {
        id: clearAllTimer
        interval: 80
        repeat: true
        onTriggered: {
            root.clearAllProgress++
            if (root.clearAllProgress >= root.filteredCount) {
                stop()
                var arr = root.trackedNotifs || []
                for (var i = 0; i < arr.length; i++) {
                    if (!arr[i]) continue
                    try { arr[i].dismiss() } catch (e) {}
                }
                root.clearAllActive = false
                root.clearAllProgress = 0
            }
        }
    }

    function dismissOne(n) {
        if (!n) return
        root.expandedNotifIndex = -1
        try { n.dismiss() } catch (e) {}
    }

    function toggleActions(idx) {
        if (root.expandedNotifIndex === idx) {
            root.expandedNotifIndex = -1
        } else {
            root.expandedNotifIndex = idx
        }
    }

    function notifCategories() {
        var arr = root.trackedNotifs || []
        var cats = {}
        for (var i = 0; i < arr.length; i++) {
            if (!arr[i] || !arr[i].appName) continue
            var name = arr[i].appName
            if (!cats[name]) cats[name] = 0
            cats[name]++
        }
        var result = []
        for (var k in cats) {
            result.push({ name: k, count: cats[k] })
        }
        return result
    }

    anchor.window: popupPanel
    anchor.rect.x: Theme.dp(0)

    Rectangle {
        anchors.fill: parent
        y: root.slideY
        color: Qt.rgba(Theme.bgSecondary.r, Theme.bgSecondary.g, Theme.bgSecondary.b, BarLayoutState.notifOpacity)
        border.width: 1
        border.color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, BarLayoutState.notifOpacity)
        radius: 0

        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(6)
            spacing: Theme.dp(4)

            // ── Header ──
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(4)

                Text {
                    text: "Notifications"
                    color: Theme.textPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 11) * s)
                    font.weight: Typography.weightBold || Font.Bold
                }

                Rectangle {
                    visible: root.filteredCount > 0
                    implicitWidth: countLabel.implicitWidth + Theme.dp(8)
                    implicitHeight: Theme.dp(16)
                    color: Theme.danger
                    border.width: 0
                    radius: Theme.dp(8)

                    Text {
                        id: countLabel
                        anchors.centerIn: parent
                        text: String(root.filteredCount)
                        color: "#ffffff"
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                        font.weight: Typography.weightBold || Font.Bold
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    implicitWidth: dndLabel.implicitWidth + Theme.dp(12)
                    implicitHeight: Theme.dp(20)
                    color: dndMouse.containsMouse
                        ? (RightBarState.dndEnabled ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85) : Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.12))
                        : (RightBarState.dndEnabled ? Theme.accent : Theme.bgPrimary)
                    border.width: 1
                    border.color: RightBarState.dndEnabled ? Theme.accent : Theme.border
                    radius: 0

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    Text {
                        id: dndLabel
                        anchors.centerIn: parent
                        text: RightBarState.dndEnabled ? "DND" : "DND"
                        color: RightBarState.dndEnabled ? Theme.bgPrimary : Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                    }

                    MouseArea {
                        id: dndMouse
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: RightBarState.toggleDnd()
                    }
                }

                HoldButton {
                    s: root.s
                    visible: root.filteredCount > 0
                    buttonLabel: "Clear"
                    requireHold: true
                    onExecute: root.dismissAll()
                }

                Text {
                    text: "✕"
                    color: closeMouse.containsMouse ? Theme.danger : Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                    Layout.alignment: Qt.AlignVCenter

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    MouseArea {
                        id: closeMouse
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        anchors.margins: -Theme.dp(4)
                        hoverEnabled: true
                        onClicked: { if (root.closeCallback) root.closeCallback() }
                    }
                }
            }

            // ── Category filter ──
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(3)
                visible: root.notifCategories().length > 1

                Rectangle {
                    Layout.preferredHeight: Theme.dp(16)
                    Layout.preferredWidth: catAllLabel.implicitWidth + Theme.dp(8)
                    color: catAllMouse.containsMouse && root.filterCategory !== "all"
                        ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08)
                        : (root.filterCategory === "all" ? Theme.accentSoft : Theme.bgPrimary)
                    border.width: 1
                    border.color: root.filterCategory === "all" ? Theme.accent : Theme.border
                    radius: 0

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    Text {
                        id: catAllLabel
                        anchors.centerIn: parent
                        text: "All"
                        color: root.filterCategory === "all" ? Theme.bgPrimary : Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                        font.weight: root.filterCategory === "all" ? (Typography.weightBold || Font.Bold) : (Typography.weightRegular || Font.Normal)
                    }

                    MouseArea {
                        id: catAllMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.filterCategory = "all"
                    }
                }

                Repeater {
                    model: root.notifCategories()

                    delegate: Rectangle {
                        required property var modelData
                        Layout.preferredHeight: Theme.dp(16)
                        Layout.preferredWidth: catLbl.implicitWidth + Theme.dp(8)
                        color: catMouse.containsMouse && root.filterCategory !== modelData.name
                            ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08)
                            : (root.filterCategory === modelData.name ? Theme.accentSoft : Theme.bgPrimary)
                        border.width: 1
                        border.color: root.filterCategory === modelData.name ? Theme.accent : Theme.border
                        radius: 0

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        Text {
                            id: catLbl
                            anchors.centerIn: parent
                            text: modelData.name + " (" + modelData.count + ")"
                            color: root.filterCategory === modelData.name ? Theme.bgPrimary : Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                            font.weight: root.filterCategory === modelData.name ? (Typography.weightBold || Font.Bold) : (Typography.weightRegular || Font.Normal)
                        }

                        MouseArea {
                            id: catMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: root.filterCategory = modelData.name
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(1)
                color: Theme.border
            }

            // ── Notification List ──
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                // Empty state
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Theme.dp(8)
                    visible: root.filteredCount === 0

                    IconBell {
                        Layout.alignment: Qt.AlignHCenter
                        iconColor: RightBarState.dndEnabled ? Theme.textMuted : Theme.accent
                        iconSize: Theme.dp(36)
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Theme.dp(2)

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: RightBarState.dndEnabled ? "Do Not Disturb" : "No Notifications"
                            color: Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeSM || 14) * s)
                            font.weight: Typography.weightBold || Font.Bold
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: RightBarState.dndEnabled ? "You won't see new alerts" : "Your tray is empty"
                            color: Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                        }
                    }
                }

                // Scrollable list
                Flickable {
                    id: notifFlickable
                    anchors.fill: parent
                    contentWidth: parent.width
                    contentHeight: notifColumn.implicitHeight
                    interactive: contentHeight > height
                    clip: true
                    visible: root.filteredCount > 0

                    ScrollBar.vertical: ScrollBar {
                        policy: root.needsScroll ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                        width: Theme.dp(4)
                    }

                    Column {
                        id: notifColumn
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Theme.dp(4)

                        Repeater {
                            id: notifRepeater
                            model: root.filteredNotifs()

                            delegate: Item {
                                required property var modelData
                                required property int index
                                width: notifFlickable.width

                                property bool isExpanded: root.expandedNotifIndex === index
                                property int actionCount: modelData.actions ? modelData.actions.length : 0
                                property real actionsSectionH: isExpanded && actionCount > 0
                                    ? Theme.dp(4) + Theme.dp(1) + (actionCount * root.actionItemH) + Math.max(actionCount - 1, 0) * Theme.dp(3) + Theme.dp(8)
                                    : 0
                                property real totalH: root.itemH + actionsSectionH

                                height: totalH
                                opacity: 1

                                Behavior on height {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }

                                property real exitX: 0

                                id: delegateItem
                                transform: Translate { x: delegateItem.exitX }

                                // Swipe dismiss background
                                Rectangle {
                                    anchors.fill: parent
                                    color: Math.abs(swipeRect.x) > Theme.dp(50) ? Theme.danger : "transparent"
                                    opacity: Math.min(1.0, Math.abs(swipeRect.x) / Theme.dp(80))
                                    z: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Dismiss"
                                        color: "white"
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeSM || 12) * s)
                                        font.weight: Font.Bold
                                        visible: Math.abs(swipeRect.x) > Theme.dp(30)
                                    }
                                }

                                // Main notification card
                                Rectangle {
                                    id: swipeRect
                                    x: 0
                                    y: 0
                                    width: parent.width
                                    height: root.itemH
                                    color: Theme.bgPrimary
                                    border.width: 1
                                    border.color: isExpanded ? Theme.accent : Theme.border
                                    radius: 0
                                    z: 2

                                    Behavior on x {
                                        enabled: !dragMouse.drag.active && !root.clearAllActive
                                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: Theme.dp(4)
                                        anchors.rightMargin: Theme.dp(28)
                                        anchors.topMargin: Theme.dp(2)
                                        anchors.bottomMargin: Theme.dp(2)
                                        spacing: Theme.dp(6)

                                        // App icon
                                        Rectangle {
                                            Layout.preferredWidth: Theme.dp(28)
                                            Layout.preferredHeight: Theme.dp(28)
                                            Layout.alignment: Qt.AlignVCenter
                                            color: Theme.bgSecondary
                                            border.width: 1
                                            border.color: Theme.border
                                            radius: 0

                                            Image {
                                                id: notifAppIcon
                                                anchors.fill: parent
                                                anchors.margins: Theme.dp(3)
                                                source: modelData.appIcon ? "image://icon/" + modelData.appIcon : ""
                                                fillMode: Image.PreserveAspectFit
                                                visible: (modelData.appIcon || "").length > 0 && status === Image.Ready
                                                asynchronous: true
                                                cache: true
                                                sourceSize.width: Theme.dp(22)
                                                sourceSize.height: Theme.dp(22)
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                visible: !notifAppIcon.visible
                                                text: modelData.appName ? modelData.appName.charAt(0).toUpperCase() : "N"
                                                color: Theme.accent
                                                font.family: Typography.fontFamily
                                                font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
                                                font.weight: Typography.weightBold || Font.Bold
                                            }
                                        }

                                        // Content
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            spacing: Theme.dp(1)

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: Theme.dp(4)

                                                Text {
                                                    text: modelData.appName || ""
                                                    color: Theme.accent
                                                    font.family: Typography.fontFamily
                                                    font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                                    font.weight: Typography.weightMedium || Font.Normal
                                                    Layout.fillWidth: true
                                                    elide: Text.ElideRight
                                                }

                                                Text {
                                                    text: root.formatNotifTimeFull(modelData.time)
                                                    color: Theme.textMuted
                                                    font.family: Typography.fontFamily
                                                    font.pixelSize: Math.round((Typography.sizeXXS || 6) * s)
                                                }
                                            }

                                            MarqueeText {
                                                text: modelData.summary || "Notification"
                                                textColor: Theme.textPrimary
                                                fontSize: Typography.sizeXXS || 8
                                                fontScale: s
                                                fontWeight: Typography.weightMedium || Font.Normal
                                                scrolling: true
                                                textPadding: 0
                                                Layout.fillWidth: true
                                            }

                                            Text {
                                                text: modelData.body || ""
                                                color: Theme.textMuted
                                                font.family: Typography.fontFamily
                                                font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                                maximumLineCount: 1
                                                visible: modelData.body && modelData.body.length > 0
                                            }
                                        }
                                    }

                                    // "..." actions button
                                    Rectangle {
                                        id: actionsBtn
                                        anchors.right: parent.right
                                        anchors.rightMargin: Theme.dp(4)
                                        anchors.verticalCenter: parent.verticalCenter
                                        implicitWidth: Theme.dp(22)
                                        implicitHeight: Theme.dp(22)
                                        color: actionsBtnMouse.containsMouse ? Theme.accent : (isExpanded ? Theme.accent : Theme.bgSecondary)
                                        border.width: 1
                                        border.color: actionsBtnMouse.containsMouse ? Theme.accent : (isExpanded ? Theme.accent : Theme.border)
                                        radius: 0
                                        visible: modelData.actions && modelData.actions.length > 0
                                        z: 3

                                        Behavior on color { ColorAnimation { duration: 100 } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: isExpanded ? "▾" : "⋯"
                                            color: actionsBtnMouse.containsMouse || isExpanded ? Theme.bgPrimary : Theme.textMuted
                                            font.family: Typography.fontFamily
                                            font.pixelSize: Math.round((Typography.sizeSM || 12) * s)
                                            font.weight: Typography.weightBold || Font.Bold
                                        }

                                        MouseArea {
                                            id: actionsBtnMouse
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            hoverEnabled: true
                                            onClicked: root.toggleActions(index)
                                        }
                                    }

                                    // Swipe drag area
                                    MouseArea {
                                        id: dragMouse
                                        anchors.fill: parent
                                        drag.target: swipeRect
                                        drag.axis: Drag.XAxis
                                        drag.minimumX: -Theme.dp(100)
                                        drag.maximumX: Theme.dp(100)

                                        onReleased: {
                                            if (Math.abs(swipeRect.x) > Theme.dp(60)) {
                                                root.dismissOne(modelData)
                                            } else {
                                                swipeRect.x = 0
                                            }
                                        }
                                    }
                                }

                                // Inline actions section
                                Column {
                                    y: swipeRect.height + Theme.dp(4)
                                    width: parent.width
                                    spacing: Theme.dp(3)
                                    visible: isExpanded && modelData.actions && modelData.actions.length > 0
                                    opacity: visible ? 1 : 0

                                    Behavior on opacity {
                                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: Theme.dp(1)
                                        color: Theme.border
                                    }

                                    Repeater {
                                        model: modelData.actions || []

                                        delegate: Rectangle {
                                            required property var modelData
                                            width: parent.width
                                            height: root.actionItemH
                                            color: actionItemMouse.containsMouse ? Theme.accent : Theme.bgSecondary
                                            border.width: 1
                                            border.color: actionItemMouse.containsMouse ? Theme.accent : Theme.border
                                            radius: 0

                                            Behavior on color { ColorAnimation { duration: 120 } }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: Theme.dp(6)
                                                spacing: Theme.dp(6)

                                                Text {
                                                    text: "▸"
                                                    color: actionItemMouse.containsMouse ? Theme.bgPrimary : Theme.accent
                                                    font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
                                                    font.weight: Typography.weightBold || Font.Bold
                                                }

                                                Text {
                                                    text: modelData.text
                                                    color: actionItemMouse.containsMouse ? Theme.bgPrimary : Theme.textPrimary
                                                    font.family: Typography.fontFamily
                                                    font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                                                    font.weight: actionItemMouse.containsMouse ? (Typography.weightBold || Font.Bold) : (Typography.weightRegular || Font.Normal)
                                                    Layout.fillWidth: true
                                                }
                                            }

                                            MouseArea {
                                                id: actionItemMouse
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true
                                                onClicked: {
                                                    try { modelData.invoke() } catch (e) {}
                                                    root.expandedNotifIndex = -1
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
