import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.config
import qs.components.widgets.rightbar
import qs.components.elements
import Quickshell.Wayland

PopupWindow {
    id: root
    property var popupPanel: null
    property var closeCallback: null
    property var trackedNotifs: []
    visible: false

    property bool slideIn: false
    property real slideY: -Theme.dp(30)

    // ── Clear All animation state ──
    property bool clearAllActive: false
    property int clearAllProgress: 0

    readonly property int filteredCount: root.filteredNotifs().length
    readonly property real itemH: Theme.dp(72)
    readonly property real listH: filteredCount > 0
        ? Math.min(filteredCount * itemH, Theme.dp(360))
        : Theme.dp(100)

    implicitWidth: Theme.dp(372)
    implicitHeight: Math.min(
        Theme.dp(40) + Theme.dp(1) + listH + Theme.dp(16),
        Theme.dp(500)
    )
    grabFocus: false

    property real s: Scales.uiScale

    property string filterCategory: "all"

    onVisibleChanged: {
        if (visible) {
            slideY = -Theme.dp(30)
            slideIn = true
        }
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
        if (diff < 3600) return Math.floor(diff / 60) + "m"
        if (diff < 86400) return Math.floor(diff / 3600) + "h"
        return d.getDate() + "/" + (d.getMonth() + 1)
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
        try { n.dismiss() } catch (e) {}
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
        color: Theme.bgSecondary
        border.width: 1
        border.color: Theme.border
        radius: 0

        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.dp(8)
            spacing: Theme.dp(6)

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(6)

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
                    implicitHeight: Theme.dp(18)
                    color: Theme.danger
                    border.width: 0
                    radius: Theme.dp(9)

                    Text {
                        id: countLabel
                        anchors.centerIn: parent
                        text: String(root.filteredCount)
                        color: "#ffffff"
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                        font.weight: Typography.weightBold || Font.Bold
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    implicitWidth: dndLabel.implicitWidth + Theme.dp(16)
                    implicitHeight: Theme.dp(22)
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
                        text: RightBarState.dndEnabled ? "DND On" : "DND"
                        color: RightBarState.dndEnabled ? Theme.bgPrimary : Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                        font.weight: RightBarState.dndEnabled
                            ? (Typography.weightBold || Font.Bold)
                            : (Typography.weightRegular || Font.Normal)
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
                    requireHold: true // Keep hold for clearing all filtered
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
                spacing: Theme.dp(4)
                visible: root.notifCategories().length > 1

                Rectangle {
                    Layout.preferredHeight: Theme.dp(18)
                    Layout.preferredWidth: catAllLabel.implicitWidth + Theme.dp(10)
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
                        Layout.preferredHeight: Theme.dp(18)
                        Layout.preferredWidth: catLbl.implicitWidth + Theme.dp(10)
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

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: root.listH

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Theme.dp(12)
                    visible: root.filteredCount === 0

                    IconBell {
                        Layout.alignment: Qt.AlignHCenter
                        iconColor: RightBarState.dndEnabled ? Theme.textMuted : Theme.accent
                        iconSize: Theme.dp(48)
                        Layout.bottomMargin: Theme.dp(10)
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Theme.dp(2)

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: RightBarState.dndEnabled
                                ? "Do Not Disturb"
                                : "No Notifications"
                            color: Theme.textPrimary
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeSM || 14) * s)
                            font.weight: Typography.weightBold || Font.Bold
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: RightBarState.dndEnabled
                                ? "You won't see new alerts"
                                : "Your tray is empty"
                            color: Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                        }
                    }
                }

                ListView {
                    anchors.fill: parent
                    clip: true
                    spacing: Theme.dp(4)
                    model: root.filteredNotifs()
                    visible: root.filteredCount > 0

                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: ListView.view.width
                        height: modelData.body && modelData.body.length > 0 ? Theme.dp(96) : root.itemH

                        property bool dismissPending: false

                        // Exit animation for Clear All
                        property real exitX: 0
                        property real exitOpacity: 1

                        states: State {
                            name: "exiting"
                            when: root.clearAllActive && index < root.clearAllProgress
                            PropertyChanges { target: delegateItem; exitX: delegateItem.width + Theme.dp(20); exitOpacity: 0 }
                        }

                        transitions: Transition {
                            to: "exiting"
                            NumberAnimation { properties: "exitX,exitOpacity"; duration: 280; easing.type: Easing.InCubic }
                        }

                        id: delegateItem
                        transform: Translate { x: delegateItem.exitX }
                        opacity: delegateItem.exitOpacity

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

                        Rectangle {
                            id: swipeRect
                            x: 0
                            width: parent.width
                            height: parent.height
                            color: Theme.bgPrimary
                            border.width: 1
                            border.color: Theme.border
                            radius: 0
                            z: 2

                            Behavior on x {
                                enabled: !dragMouse.drag.active && !root.clearAllActive
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.dp(8)
                                spacing: Theme.dp(8)

                                Rectangle {
                                    Layout.preferredWidth: Theme.dp(36)
                                    Layout.preferredHeight: Theme.dp(36)
                                    Layout.alignment: Qt.AlignVCenter
                                    color: Theme.accentSoft
                                    border.width: 1
                                    border.color: Theme.border
                                    radius: 0

                                    Image {
                                        id: notifAppIcon
                                        anchors.fill: parent
                                        anchors.margins: Theme.dp(4)
                                        source: modelData.appIcon ? "image://icon/" + modelData.appIcon : ""
                                        fillMode: Image.PreserveAspectFit
                                        visible: (modelData.appIcon || "").length > 0 && status === Image.Ready
                                        asynchronous: true
                                        cache: true
                                        sourceSize.width: Theme.dp(28)
                                        sourceSize.height: Theme.dp(28)
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: !notifAppIcon.visible
                                        text: modelData.appName ? modelData.appName.charAt(0).toUpperCase() : "N"
                                        color: Theme.accent
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeSM || 14) * s)
                                        font.weight: Typography.weightBold || Font.Bold
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: Theme.dp(2)

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: Theme.dp(4)

                                        MarqueeText {
                                            Layout.fillWidth: true
                                            text: modelData.appName || ""
                                            textColor: Theme.accent
                                            fontSize: 7
                                            fontScale: s
                                            fontWeight: Typography.weightMedium || Font.Normal
                                            scrolling: true
                                            textPadding: 0
                                        }

                                        Text {
                                            text: root.formatNotifTime(modelData.time)
                                            color: Theme.textMuted
                                            font.family: Typography.fontFamily
                                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                        }
                                    }

                                    MarqueeText {
                                        text: modelData.summary || "Notification"
                                        textColor: Theme.textPrimary
                                        fontSize: 10
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
                                        font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                                        font.weight: Font.Normal
                                        wrapMode: Text.Wrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                        lineHeight: 1.2
                                        lineHeightMode: Text.ProportionalHeight
                                        Layout.fillWidth: true
                                        visible: modelData.body && modelData.body.length > 0
                                    }
                                }
                            }

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
                    }
                }
            }
        }
    }
}
