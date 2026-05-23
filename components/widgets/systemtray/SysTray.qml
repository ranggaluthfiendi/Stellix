pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import qs.components.widgets.systemtray
import qs.components.elements
import qs.config
import qs.services
Item {
    id: root

    property int visibleLimit: 8
    property bool hidePassiveItems: false

    property var trayItems: SystemTray.items && SystemTray.items.values
        ? SystemTray.items.values
        : []

    function statusRank(item) {
        if (!item) return 99
        if (item.status === Status.NeedsAttention) return 0
        if (item.status === Status.Active) return 1
        if (item.status === Status.Passive) return 2
        return 3
    }

    function categoryRank(item) {
        if (!item) return 99
        if (item.category === Category.Hardware) return 0
        if (item.category === Category.Communications) return 1
        if (item.category === Category.SystemServices) return 2
        if (item.category === Category.ApplicationStatus) return 3
        return 4
    }

    function sortAndFilterItems(items) {
        var list = (items || []).filter(function(it) {
            if (!it) return false
            if (hidePassiveItems && it.status === Status.Passive) return false
            return true
        })

        list.sort(function(a, b) {
            var sr = statusRank(a) - statusRank(b)
            if (sr !== 0) return sr

            var cr = categoryRank(a) - categoryRank(b)
            if (cr !== 0) return cr

            var at = (a.title || a.id || "").toLowerCase()
            var bt = (b.title || b.id || "").toLowerCase()
            return at.localeCompare(bt)
        })

        return list
    }

    property var processedTrayItems: sortAndFilterItems(trayItems)
    property var visibleItems: visibleLimit > 0
        ? processedTrayItems.slice(0, visibleLimit)
        : processedTrayItems
    property var overflowItems: visibleLimit > 0
        ? processedTrayItems.slice(visibleLimit)
        : []

    property real itemSize: Theme.dp(26)
    property real spacing: Theme.dp(6)

    property bool hasAnyTrayItems: processedTrayItems.length > 0
    property bool hasOverflow: overflowItems.length > 0
    property bool trayPanelOpen: trayPopup.open

    implicitHeight: itemSize
    implicitWidth: hasAnyTrayItems ? itemSize : 0

    PopupWindow {
        id: menuPopup
        color: "transparent"

        property var menuModel: null
        property bool internalVisible: false
        property bool ready: menuLoader.item !== null
        property real slideY: -Theme.dp(12)

        visible: internalVisible && ready

        implicitWidth: menuLoader.item && menuLoader.item.implicitWidth
            ? Math.max(menuLoader.item.implicitWidth, Theme.dp(80))
            : Theme.dp(80)

        implicitHeight: menuLoader.item && menuLoader.item.implicitHeight
            ? Math.max(menuLoader.item.implicitHeight, Theme.dp(30))
            : Theme.dp(30)

        anchor.item: root
        anchor.rect: BarLayoutState.isBottom
            ? Qt.rect(0, -(implicitHeight + Theme.dp(6)), 0, 0)
            : Qt.rect(0, root.height + Theme.dp(6), 0, 0)

        onInternalVisibleChanged: {
            if (internalVisible) slideY = -Theme.dp(12)
        }

        Rectangle {
            anchors.fill: parent
            y: menuPopup.slideY
            color: Qt.rgba(Theme.bgSecondary.r, Theme.bgSecondary.g, Theme.bgSecondary.b, BarLayoutState.systrayOpacity)

            Behavior on y {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            Loader {
                id: menuLoader
                anchors.fill: parent
                active: false

                sourceComponent: MenuView {
                    menu: menuPopup.menuModel

                    onClose: {
                        menuPopup.internalVisible = false
                        SysTrayState.closeAll()
                    }

                    onRequestSubmenu: (entry, anchorItem) => {
                        if (!entry) {
                            subMenuPopup.menuData = null
                            SysTrayState.openedSubmenuEntry = null
                            SysTrayState.openedSubmenuPopup = null
                            return
                        }

                        SysTrayState.openedSubmenuEntry = entry
                        SysTrayState.openedSubmenuPopup = subMenuPopup

                        subMenuPopup.menuData = entry
                        subMenuPopup.anchorItem = anchorItem
                    }
                }

                onLoaded: {
                    if (item && menuPopup.menuModel) {
                        item.menu = menuPopup.menuModel
                    }
                }
            }
        }
    }

    PopupWindow {
        id: trayPopup
        color: "transparent"

        property bool open: false
        property real slideY: -Theme.dp(12)

        visible: open && hasAnyTrayItems

        implicitWidth: {
            var cols = Math.min(Math.max(visibleItems.length, 1), 6)
            return (cols * itemSize) + (Math.max(cols - 1, 0) * spacing) + Theme.dp(16)
        }

        implicitHeight: {
            var cols = Math.min(Math.max(visibleItems.length, 1), 6)
            var rows = Math.ceil(Math.max(visibleItems.length, 1) / cols)
            return (rows * itemSize) + (Math.max(rows - 1, 0) * spacing) + Theme.dp(16)
                + (hasOverflow ? (itemSize + spacing) : 0)
        }

        anchor.item: launcher
        anchor.rect: BarLayoutState.isBottom
            ? Qt.rect(0, -(implicitHeight + Theme.dp(6)), 0, 0)
            : Qt.rect(0, launcher.height + Theme.dp(6), 0, 0)

        onOpenChanged: {
            if (open) slideY = -Theme.dp(12)
        }
        onVisibleChanged: {
            if (!visible) {
                open = false
            }
        }

        Rectangle {
            anchors.fill: parent
            y: trayPopup.slideY
            radius: 0
            color: Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, BarLayoutState.systrayOpacity)

            Behavior on y {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.dp(8)
                spacing: Theme.dp(8)

                GridLayout {
                    id: trayGrid
                    Layout.fillWidth: true
                    columns: Math.min(Math.max(visibleItems.length, 1), 6)
                    columnSpacing: spacing
                    rowSpacing: spacing

                    Repeater {
                        model: visibleItems

                        delegate: Item {
                            width: itemSize
                            height: itemSize

                            required property var modelData
                            property bool needsAttention: modelData && modelData.status === Status.NeedsAttention

                            Rectangle {
                                anchors.fill: parent
                                radius: 0
                                color: iconMouse.containsMouse
                                    ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08)
                                    : (needsAttention ? Qt.rgba(1, 0.35, 0.2, 0.16) : "transparent")
                                border.width: iconMouse.containsMouse || needsAttention ? 1 : 0
                                border.color: iconMouse.containsMouse
                                    ? Theme.textPrimary
                                    : (needsAttention ? Qt.rgba(1, 0.4, 0.2, 0.7) : "transparent")

                                Behavior on color {
                                    ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                                }

                                Image {
                                    anchors.centerIn: parent
                                    source: modelData.icon ?? ""
                                    width: Theme.dp(18)
                                    height: Theme.dp(18)
                                    fillMode: Image.PreserveAspectFit
                                }

                                MouseArea {
                                    id: iconMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                                    function openItemMenu(item) {
                                        if (!item || !item.hasMenu) return

                                        SysTrayState.blockClose = true
                                        SysTrayState.closeAll()

                                        menuPopup.menuModel = null
                                        menuLoader.active = false

                                        menuPopup.menuModel = item.menu
                                        menuLoader.active = true
                                        menuPopup.internalVisible = true

                                        SysTrayState.openedMenu = menuPopup
                                        overflowPopup.open = false

                                        Qt.callLater(function() {
                                            SysTrayState.blockClose = false
                                        })
                                    }

                                    onClicked: (mouseEvent) => {
                                        if (!modelData) return

                                        if (mouseEvent.button === Qt.RightButton) {
                                            if (modelData.hasMenu) openItemMenu(modelData)
                                            return
                                        }

                                        if (mouseEvent.button === Qt.MiddleButton) {
                                            try {
                                                modelData.secondaryActivate()
                                            } catch(e) {
                                            }
                                            return
                                        }

                                        if (modelData.onlyMenu || modelData.hasMenu) {
                                            openItemMenu(modelData)
                                        } else {
                                            try {
                                                modelData.activate()
                                            } catch(e) {
                                            }
                                        }
                                    }

                                    onWheel: (wheel) => {
                                        if (!modelData) return
                                        try {
                                            modelData.scroll(wheel.angleDelta.y, wheel.angleDelta.x !== 0)
                                        } catch(e) {
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    id: overflowButton
                    Layout.alignment: Qt.AlignHCenter
                    width: itemSize
                    height: itemSize
                    visible: hasOverflow

                    Rectangle {
                        anchors.fill: parent
                        radius: 0
                        color: mouseOverflow.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08) : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }

                        MouseArea {
                            id: mouseOverflow
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton

                            onClicked: {
                                if (overflowPopup.open) {
                                    SysTrayState.closeAll()
                                    return
                                }

                                SysTrayState.blockClose = true
                                SysTrayState.closeAll()

                                overflowPopup.open = true
                                SysTrayState.openedOverflow = overflowPopup

                                Qt.callLater(function() {
                                    SysTrayState.blockClose = false
                                })
                            }
                        }

                        ChevronShape {
                            anchors.centerIn: parent
                            width: Theme.dp(18)
                            height: Theme.dp(18)
                            direction: overflowPopup.open ? "up" : "down"
                            color: Theme.textPrimary
                        }
                    }
                }
            }
        }
    }

    PopupWindow {
        id: overflowPopup
        color: "transparent"

        property bool open: false
        property real slideX: -Theme.dp(12)

        visible: open && overflowItems.length > 0

        property int cols: Math.min(overflowItems.length, 4)
        property int rows: Math.ceil(overflowItems.length / cols)

        implicitWidth: cols * itemSize
        implicitHeight: rows * itemSize

        anchor.window: trayPopup
        anchor.rect: Qt.rect(trayPopup.width + Theme.dp(6), 0, 0, 0)

        onOpenChanged: {
            if (open) slideX = -Theme.dp(12)
        }
        onVisibleChanged: {
            if (!visible) {
                open = false
                if (SysTrayState.openedOverflow === overflowPopup) {
                    SysTrayState.openedOverflow = null
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            x: overflowPopup.slideX
            color: Qt.rgba(Theme.bgSecondary.r, Theme.bgSecondary.g, Theme.bgSecondary.b, BarLayoutState.systrayOpacity)

            Behavior on x {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            GridLayout {
                anchors.centerIn: parent
                columns: Math.min(overflowItems.length, 4)

                Repeater {
                    model: overflowItems

                    delegate: Item {
                        width: itemSize
                        height: itemSize

                        required property var modelData
                        property bool needsAttention: modelData && modelData.status === Status.NeedsAttention

                        Rectangle {
                            anchors.fill: parent
                            radius: 0
                            color: overMouse.containsMouse
                                ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08)
                                : (needsAttention ? Qt.rgba(1, 0.35, 0.2, 0.16) : "transparent")
                            border.width: overMouse.containsMouse || needsAttention ? 1 : 0
                            border.color: overMouse.containsMouse
                                ? Theme.textPrimary
                                : (needsAttention ? Qt.rgba(1, 0.4, 0.2, 0.7) : "transparent")

                            Behavior on color {
                                ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                            }

                            Image {
                                anchors.centerIn: parent
                                source: modelData.icon ?? ""
                                width: Theme.dp(18)
                                height: Theme.dp(18)
                                fillMode: Image.PreserveAspectFit
                            }

                            MouseArea {
                                id: overMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                                function openItemMenu(item) {
                                    if (!item || !item.hasMenu) return

                                    SysTrayState.blockClose = true
                                    SysTrayState.closeAll()

                                    menuPopup.menuModel = null
                                    menuLoader.active = false

                                    menuPopup.menuModel = item.menu
                                    menuLoader.active = true
                                    menuPopup.internalVisible = true

                                    SysTrayState.openedMenu = menuPopup
                                    SysTrayState.openedOverflow = null

                                    overflowPopup.open = false

                                    Qt.callLater(function() {
                                        SysTrayState.blockClose = false
                                    })
                                }

                                onClicked: (mouseEvent) => {
                                    if (!modelData) return

                                    if (mouseEvent.button === Qt.RightButton) {
                                        if (modelData.hasMenu) openItemMenu(modelData)
                                        return
                                    }

                                    if (mouseEvent.button === Qt.MiddleButton) {
                                        try {
                                            modelData.secondaryActivate()
                                        } catch(e) {
                                        }
                                        return
                                    }

                                    if (modelData.onlyMenu || modelData.hasMenu) {
                                        openItemMenu(modelData)
                                    } else {
                                        try {
                                            modelData.activate()
                                        } catch(e) {
                                        }
                                    }
                                }

                                onWheel: (wheel) => {
                                    if (!modelData) return
                                    try {
                                        modelData.scroll(wheel.angleDelta.y, wheel.angleDelta.x !== 0)
                                    } catch(e) {
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    PopupWindow {
        id: subMenuPopup
        color: "transparent"

        property var menuData: null
        property var anchorItem: null
        property real slideX: -Theme.dp(12)

        visible: menuData !== null

        implicitWidth: subMenuLoader.item && subMenuLoader.item.implicitWidth
            ? subMenuLoader.item.implicitWidth
            : Theme.dp(80)

        implicitHeight: subMenuLoader.item && subMenuLoader.item.implicitHeight
            ? subMenuLoader.item.implicitHeight
            : Theme.dp(30)

        anchor.item: anchorItem
        anchor.rect: anchorItem
            ? Qt.rect(anchorItem.width + Theme.dp(6), 0, 0, 0)
            : Qt.rect(0, 0, 0, 0)

        onMenuDataChanged: {
            if (menuData !== null) slideX = -Theme.dp(12)
        }

        Rectangle {
            anchors.fill: parent
            x: subMenuPopup.slideX
            color: Qt.rgba(Theme.bgSecondary.r, Theme.bgSecondary.g, Theme.bgSecondary.b, BarLayoutState.systrayOpacity)

            Behavior on x {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            Loader {
                id: subMenuLoader
                anchors.fill: parent

                sourceComponent: MenuView {
                    menu: subMenuPopup.menuData

                    onClose: {
                        subMenuPopup.menuData = null
                        SysTrayState.openedSubmenuEntry = null
                        SysTrayState.openedSubmenuPopup = null
                    }
                }
            }
        }
    }

    Item {
        id: launcher
        width: itemSize
        height: itemSize
        visible: hasAnyTrayItems

        Rectangle {
            anchors.fill: parent
            radius: 0
            color: launcherMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08) : (trayPopup.open ? Theme.bgSecondary : "transparent")
            border.width: launcherMouse.containsMouse ? 1 : 0
            border.color: launcherMouse.containsMouse ? Theme.textPrimary : "transparent"

            Behavior on color {
                ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            MouseArea {
                id: launcherMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton

                onClicked: {
                    if (trayPopup.open) {
                        SysTrayState.forceCloseAll()
                        trayPopup.open = false
                        overflowPopup.open = false
                        return
                    }

                    SysTrayState.blockClose = true
                    SysTrayState.closeAll()

                    trayPopup.open = true
                    SysTrayState.openedTrayPanel = trayPopup

                    Qt.callLater(function() {
                        SysTrayState.blockClose = false
                    })
                }
            }

            ChevronShape {
                anchors.centerIn: parent
                width: Theme.dp(16)
                height: Theme.dp(16)
                direction: trayPopup.open ? "up" : "down"
                color: Theme.textPrimary
            }
        }
    }
}
