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
    property real slideY: -Theme.dp(20)

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
            slideY = -Theme.dp(20)
            slideIn = true
        }
    }

    function filteredNotifs() {
        var arr = (root.trackedNotifs || []).slice()
        if (root.filterCategory !== "all") {
            arr = arr.filter(function(n) {
                return n && n.appName && n.appName.toLowerCase().indexOf(root.filterCategory) >= 0
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
        var arr = root.trackedNotifs || []
        for (var i = 0; i < arr.length; i++) {
            if (!arr[i]) continue
            try { arr[i].dismiss() } catch (e) {}
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
                    color: Theme.accentSoft
                    border.width: 1
                    border.color: Theme.accent
                    radius: Theme.dp(9)

                    Text {
                        id: countLabel
                        anchors.centerIn: parent
                        text: String(root.filteredCount)
                        color: Theme.accent
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                        font.weight: Typography.weightBold || Font.Bold
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    implicitWidth: dndLabel.implicitWidth + Theme.dp(16)
                    implicitHeight: Theme.dp(22)
                    color: RightBarState.dndEnabled ? Theme.accent : Theme.bgPrimary
                    border.width: 1
                    border.color: RightBarState.dndEnabled ? Theme.accent : Theme.border
                    radius: 0

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
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
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
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round((Typography.sizeXXS || 9) * s)
                    Layout.alignment: Qt.AlignVCenter

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        anchors.margins: -Theme.dp(4)
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
                    color: root.filterCategory === "all" ? Theme.accentSoft : Theme.bgPrimary
                    border.width: 1
                    border.color: root.filterCategory === "all" ? Theme.accent : Theme.border
                    radius: 0

                    Text {
                        id: catAllLabel
                        anchors.centerIn: parent
                        text: "All"
                        color: root.filterCategory === "all" ? Theme.accent : Theme.textMuted
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                        font.weight: root.filterCategory === "all" ? (Typography.weightBold || Font.Bold) : (Typography.weightRegular || Font.Normal)
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.filterCategory = "all"
                    }
                }

                Repeater {
                    model: root.notifCategories()

                    delegate: Rectangle {
                        required property var modelData
                        Layout.preferredHeight: Theme.dp(18)
                        Layout.preferredWidth: catLbl.implicitWidth + Theme.dp(10)
                        color: root.filterCategory === modelData.name ? Theme.accentSoft : Theme.bgPrimary
                        border.width: 1
                        border.color: root.filterCategory === modelData.name ? Theme.accent : Theme.border
                        radius: 0

                        Text {
                            id: catLbl
                            anchors.centerIn: parent
                            text: modelData.name + " (" + modelData.count + ")"
                            color: root.filterCategory === modelData.name ? Theme.accent : Theme.textMuted
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                            font.weight: root.filterCategory === modelData.name ? (Typography.weightBold || Font.Bold) : (Typography.weightRegular || Font.Normal)
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
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
                        width: ListView.view.width
                        height: root.itemH

                        property bool dismissPending: false

                        Rectangle {
                            anchors.fill: parent
                            color: parent.dismissPending ? Theme.danger : "transparent"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        Rectangle {
                            id: swipeRect
                            x: 0
                            width: parent.width - Math.abs(x)
                            height: parent.height
                            color: Theme.bgPrimary
                            border.width: 1
                            border.color: Theme.border
                            radius: 0

                            Behavior on x {
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
                                        source: modelData.appIcon || ""
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

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.appName || ""
                                            color: Theme.accent
                                            font.family: Typography.fontFamily
                                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                            font.weight: Typography.weightMedium || Font.Normal
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: root.formatNotifTime(modelData.time)
                                            color: Theme.textMuted
                                            font.family: Typography.fontFamily
                                            font.pixelSize: Math.round((Typography.sizeXXS || 7) * s)
                                        }
                                    }

                                    Text {
                                        text: modelData.summary || "Notification"
                                        color: Theme.textPrimary
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeXXS || 10) * s)
                                        font.weight: Typography.weightMedium || Font.Normal
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: modelData.body || ""
                                        color: Theme.textMuted
                                        font.family: Typography.fontFamily
                                        font.pixelSize: Math.round((Typography.sizeXXS || 8) * s)
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        visible: modelData.body && modelData.body.length > 0
                                        maximumLineCount: 2
                                        wrapMode: Text.Wrap
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: Theme.dp(22)
                                    Layout.preferredHeight: Theme.dp(22)
                                    Layout.alignment: Qt.AlignTop
                                    color: Theme.bgSecondary
                                    border.width: 1
                                    border.color: Theme.border
                                    radius: 0

                                    IconClose {
                                        anchors.centerIn: parent
                                        iconColor: Theme.textMuted
                                        iconSize: Theme.dp(9)
                                    }

                                    MouseArea {
                                        cursorShape: Qt.PointingHandCursor
                                        anchors.fill: parent
                                        onClicked: root.dismissOne(modelData)
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                drag.target: swipeRect
                                drag.axis: MouseArea.XAxis
                                drag.minimumX: -Theme.dp(80)
                                drag.maximumX: Theme.dp(80)

                                onReleased: {
                                    if (Math.abs(swipeRect.x) > Theme.dp(50)) {
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
