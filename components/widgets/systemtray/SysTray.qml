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

    property bool hidePassiveItems: false

    property var trayItems: SystemTray.items && SystemTray.items.values
        ? SystemTray.items.values
        : []

    function statusRank(item) {
        if (!item) return 99
        var s = item.status
        if (s === 2 || s === "NeedsAttention") return 0
        if (s === 1 || s === "Active") return 1
        if (s === 0 || s === "Passive") return 2
        return 3
    }

    function categoryRank(item) {
        if (!item) return 99
        var c = item.category
        if (c === 0 || c === "Hardware") return 0
        if (c === 1 || c === "Communications") return 1
        if (c === 2 || c === "SystemServices") return 2
        if (c === 3 || c === "ApplicationStatus") return 3
        return 4
    }

    function sortAndFilterItems(items) {
        var list = (items || []).filter(function(it) {
            if (!it) return false
            if (hidePassiveItems && (it.status === 0 || it.status === "Passive")) return false
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
    
    readonly property bool shouldCollapse: !BarLayoutState.systrayShowAll && (processedTrayItems.length > BarLayoutState.systrayCollapseLimit)
    
    readonly property var barItems: shouldCollapse
        ? processedTrayItems.slice(0, BarLayoutState.systrayCollapseLimit)
        : processedTrayItems

    readonly property var visibleItems: shouldCollapse
        ? processedTrayItems.slice(BarLayoutState.systrayCollapseLimit)
        : []

    readonly property var overflowItems: []

    property real itemSize: Theme.dp(26)
    property real spacing: Theme.dp(6)

    property bool hasAnyTrayItems: processedTrayItems.length > 0
    property bool hasOverflow: overflowItems.length > 0
    readonly property bool trayPanelOpen: !!(trayPopup && trayPopup.open)

    implicitHeight: itemSize
    implicitWidth: row.implicitWidth

    RowLayout {
        id: row
        spacing: root.spacing
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: root.barItems
            delegate: Item {
                id: barItem
                width: root.itemSize
                height: root.itemSize
                
                required property var modelData
                
                SysTrayIcon {
                    anchors.fill: parent
                    item: barItem.modelData
                    size: root.itemSize
                }
            }
        }

        Item {
            id: launcher
            width: root.itemSize
            height: root.itemSize
            visible: root.hasAnyTrayItems && root.shouldCollapse

            Rectangle {
                anchors.fill: parent
                radius: 0
                color: launcherMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08) : (trayPopup.open ? Theme.bgSecondary : "transparent")
                
                MouseArea {
                    id: launcherMouse
                    anchors.fill: parent
                    onClicked: {
                        if (trayPopup.open) {
                            SysTrayState.forceCloseAll()
                        } else {
                            SysTrayState.closeAll()
                            trayPopup.open = true
                            SysTrayState.openedTrayPanel = trayPopup
                        }
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

    component SysTrayIcon: Item {
        id: iconRoot
        property var item: null
        property real size: Theme.dp(26)
        
        width: size
        height: size

        readonly property bool needsAttention: !!item && (item.status === 2 || item.status === "NeedsAttention")

        Rectangle {
            anchors.fill: parent
            color: iconMouse.containsMouse 
                ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.08) 
                : (iconRoot.needsAttention ? Qt.rgba(1, 0.35, 0.2, 0.16) : "transparent")
            border.width: iconMouse.containsMouse || iconRoot.needsAttention ? 1 : 0
            border.color: iconMouse.containsMouse ? Theme.textPrimary : (iconRoot.needsAttention ? Qt.rgba(1, 0.4, 0.2, 0.7) : "transparent")

            Image {
                anchors.centerIn: parent
                source: (iconRoot.item && iconRoot.item.icon) ? iconRoot.item.icon : ""
                width: Theme.dp(18)
                height: Theme.dp(18)
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                id: iconMouse
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                onClicked: (mouse) => {
                    if (!iconRoot.item) return
                    
                    if (mouse.button === Qt.RightButton) {
                        if (iconRoot.item.hasMenu) root.openMenu(iconRoot.item)
                        return
                    }

                    if (mouse.button === Qt.MiddleButton) {
                        try { iconRoot.item.secondaryActivate() } catch(e) {}
                        return
                    }

                    if (iconRoot.item.onlyMenu || iconRoot.item.hasMenu) {
                        root.openMenu(iconRoot.item)
                    } else {
                        try { iconRoot.item.activate() } catch(e) {}
                    }
                }

                onWheel: (wheel) => {
                    if (iconRoot.item) {
                        try { iconRoot.item.scroll(wheel.angleDelta.y, wheel.angleDelta.x !== 0) } catch(e) {}
                    }
                }
            }
        }
    }

    function openMenu(item) {
        if (!item || !item.hasMenu) return
        SysTrayState.closeAll()
        menuPopup.menuModel = item.menu
        menuLoader.active = true
        menuPopup.internalVisible = true
        SysTrayState.openedMenu = menuPopup
        overflowPopup.open = false
    }

    PopupWindow {
        id: menuPopup
        color: "transparent"
        property var menuModel: null
        property bool internalVisible: false
        property bool ready: menuLoader.item !== null
        property real slideY: -Theme.dp(12)
        visible: internalVisible && ready
        implicitWidth: menuLoader.item ? Math.max(menuLoader.item.implicitWidth, Theme.dp(80)) : Theme.dp(80)
        implicitHeight: menuLoader.item ? Math.max(menuLoader.item.implicitHeight, Theme.dp(30)) : Theme.dp(30)
        anchor.item: root
        anchor.rect: BarLayoutState.isBottom ? Qt.rect(0, -(implicitHeight + Theme.dp(6)), 0, 0) : Qt.rect(0, root.height + Theme.dp(6), 0, 0)
        Rectangle {
            anchors.fill: parent
            y: menuPopup.slideY
            color: Qt.rgba(Theme.bgSecondary.r, Theme.bgSecondary.g, Theme.bgSecondary.b, BarLayoutState.systrayOpacity)
            Loader {
                id: menuLoader
                anchors.fill: parent
                active: false
                sourceComponent: MenuView {
                    menu: menuPopup.menuModel
                    onClose: { menuPopup.internalVisible = false; SysTrayState.closeAll() }
                    onRequestSubmenu: (entry, anchorItem) => {
                        if (!entry) {
                            subMenuPopup.menuData = null
                            SysTrayState.openedSubmenuEntry = null
                            SysTrayState.openedSubmenuPopup = null
                        } else {
                            SysTrayState.openedSubmenuEntry = entry
                            SysTrayState.openedSubmenuPopup = subMenuPopup
                            subMenuPopup.menuData = entry
                            subMenuPopup.anchorItem = anchorItem
                        }
                    }
                }
            }
        }
    }

    PopupWindow {
        id: trayPopup
        color: "transparent"
        property bool open: false
        visible: open && hasAnyTrayItems

        readonly property int cols: Math.min(Math.max(visibleItems.length, 3), 5)
        readonly property int rows: Math.ceil(visibleItems.length / cols)

        implicitWidth: Theme.dp(240)
        implicitHeight: trayContent.implicitHeight + Theme.dp(32)

        anchor.item: launcher
        anchor.rect: BarLayoutState.isBottom ? Qt.rect(0, -(implicitHeight + Theme.dp(8)), 0, 0) : Qt.rect(0, launcher.height + Theme.dp(8), 0, 0)

        Rectangle {
            anchors.fill: parent
            color: Theme.bgSecondary
            border.width: 1
            border.color: Theme.border
            radius: BarLayoutState.weatherPopupRounded ? Theme.radiusMedium : 0
            
            // Subtly darken the background slightly more for depth
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0,0,0,0.1)
                radius: parent.radius
                z: -1
            }

            ColumnLayout {
                id: trayContent
                anchors.fill: parent
                anchors.margins: Theme.dp(16)
                spacing: Theme.dp(12)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.dp(8)

                    Text {
                        text: "System Tray"
                        color: Theme.accent
                        font.family: Typography.fontFamily
                        font.pixelSize: Theme.dp(11)
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        Layout.preferredWidth: Theme.dp(18)
                        Layout.preferredHeight: Theme.dp(18)
                        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                        radius: Theme.dp(4)
                        
                        Text {
                            anchors.centerIn: parent
                            text: root.visibleItems.length
                            color: Theme.accent
                            font.pixelSize: Theme.dp(9)
                            font.weight: Font.Bold
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: Theme.dp(24)
                        height: Theme.dp(24)
                        color: closeMouse.containsMouse ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.1) : "transparent"
                        radius: Theme.dp(4)

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: closeMouse.containsMouse ? Theme.danger : Theme.textMuted
                            font.pixelSize: Theme.dp(10)
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: SysTrayState.forceCloseAll()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.border
                    opacity: 0.5
                }

                GridLayout {
                    Layout.alignment: Qt.AlignHCenter
                    columns: trayPopup.cols
                    columnSpacing: Theme.dp(10)
                    rowSpacing: Theme.dp(10)

                    Repeater {
                        model: root.visibleItems
                        delegate: Item {
                            width: root.itemSize + Theme.dp(8)
                            height: root.itemSize + Theme.dp(8)
                            required property var modelData

                            Rectangle {
                                anchors.fill: parent
                                color: innerIconMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"
                                radius: 0
                                border.width: innerIconMouse.containsMouse ? 1 : 0
                                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                            }

                            SysTrayIcon {
                                anchors.centerIn: parent
                                item: modelData
                                size: root.itemSize
                            }

                            MouseArea {
                                id: innerIconMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton // Let SysTrayIcon handle clicks
                            }
                        }
                    }
                }
                
                // Add a small footer message if it's empty (though popup won't show)
                Text {
                    visible: root.visibleItems.length === 0
                    text: "No active items"
                    color: Theme.textMuted
                    font.pixelSize: Theme.dp(9)
                    font.italic: true
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }

    PopupWindow {
        id: subMenuPopup
        color: "transparent"
        property var menuData: null
        property var anchorItem: null
        visible: menuData !== null
        implicitWidth: subMenuLoader.item ? subMenuLoader.item.implicitWidth : Theme.dp(80)
        implicitHeight: subMenuLoader.item ? subMenuLoader.item.implicitHeight : Theme.dp(30)
        anchor.item: anchorItem
        anchor.rect: anchorItem ? Qt.rect(anchorItem.width + Theme.dp(6), 0, 0, 0) : Qt.rect(0, 0, 0, 0)
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(Theme.bgSecondary.r, Theme.bgSecondary.g, Theme.bgSecondary.b, BarLayoutState.systrayOpacity)
            Loader {
                id: subMenuLoader; anchors.fill: parent
                sourceComponent: MenuView {
                    menu: subMenuPopup.menuData
                    onClose: { subMenuPopup.menuData = null; SysTrayState.openedSubmenuEntry = null; SysTrayState.openedSubmenuPopup = null }
                }
            }
        }
    }
}
