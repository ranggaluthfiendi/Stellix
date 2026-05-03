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

    property int visibleLimit: 0

    property var trayItems: SystemTray.items && SystemTray.items.values
        ? SystemTray.items.values
        : []

    property var visibleItems: trayItems.slice(0, visibleLimit)
    property var overflowItems: trayItems.slice(visibleLimit)

    property real itemSize: Theme.dp(26)
    property real spacing: Theme.dp(6)

    property bool hasOverflow: overflowItems.length > 0

    implicitHeight: itemSize

    implicitWidth: {
        var count = visibleItems.length + (hasOverflow ? 1 : 0)
        if (count <= 0) return 0
        return (count * itemSize) + ((count - 1) * spacing)
    }

    PopupWindow {
        id: menuPopup

        property var menuModel: null
        property bool internalVisible: false
        property bool ready: menuLoader.item !== null

        visible: internalVisible && ready

        implicitWidth: menuLoader.item && menuLoader.item.implicitWidth
    ? Math.max(menuLoader.item.implicitWidth, Theme.dp(80))
    : Theme.dp(80)

implicitHeight: menuLoader.item && menuLoader.item.implicitHeight
    ? Math.max(menuLoader.item.implicitHeight, Theme.dp(30))
    : Theme.dp(30)

        anchor.item: root
        anchor.rect: Qt.rect(0, root.height + Theme.dp(6), 0, 0)

        Rectangle {
            anchors.fill: parent
            color: Theme.bgSecondary
            opacity: Theme.opacityPanel

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
    id: overflowPopup

    property bool open: false

    visible: open && overflowItems.length > 0

    property real itemSize: Theme.dp(26)
    property int cols: Math.min(overflowItems.length, 4)
    property int rows: Math.ceil(overflowItems.length / cols)

    implicitWidth: cols * itemSize
    implicitHeight: rows * itemSize

    anchor.item: overflowButton
    anchor.rect: Qt.rect(
        0,
        overflowButton.height + Theme.dp(6),
        0,
        0
    )

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
        color: Theme.bgSecondary
        opacity: Theme.opacityPanel

        GridLayout {
            anchors.centerIn: parent
            columns: Math.min(overflowItems.length, 4)

            Repeater {
                model: overflowItems

                delegate: Item {
                    width: Theme.dp(26)
                    height: Theme.dp(26)

                    required property var modelData

                    Rectangle {
                        anchors.fill: parent
                        color: mouse.containsMouse ? Theme.accentSoft : "transparent"

                        Image {
                            anchors.centerIn: parent
                            source: modelData.icon ?? ""
                            width: Theme.dp(18)
                            height: Theme.dp(18)
                            fillMode: Image.PreserveAspectFit
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (!modelData) return

                                SysTrayState.blockClose = true

                                SysTrayState.closeAll()

                                menuPopup.menuModel = null
                                menuLoader.active = false

                                menuPopup.menuModel = modelData.menu
                                menuLoader.active = true
                                menuPopup.internalVisible = true

                                SysTrayState.openedMenu = menuPopup
                                SysTrayState.openedOverflow = null

                                overflowPopup.open = false

                                Qt.callLater(function() {
                                    SysTrayState.blockClose = false
                                })
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

        property var menuData: null
        property var anchorItem: null

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

        Rectangle {
            anchors.fill: parent
            color: Theme.bgSecondary
            opacity: Theme.opacityPanel

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
    

    RowLayout {
        id: row
        spacing: Theme.dp(6)

        Repeater {
            model: visibleItems

            delegate: Item {
                id: trayItem
                required property var modelData

                width: Theme.dp(26)
                height: Theme.dp(26)

                Rectangle {
                    anchors.fill: parent
                    color: mouse.containsMouse ? Theme.accentSoft : "transparent"

                    Image {
                        anchors.centerIn: parent
                        source: modelData.icon ?? ""
                        width: Theme.dp(18)
                        height: Theme.dp(18)
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (!modelData) return

                            if (modelData.hasMenu) {
                                SysTrayState.closeAll()

                                menuPopup.menuModel = null
                                menuLoader.active = false

                                menuPopup.menuModel = modelData.menu
                                menuLoader.active = true
                                menuPopup.internalVisible = true

                                SysTrayState.openedMenu = menuPopup
                            } else {
                                try { modelData.activate() } catch(e) {}
                            }
                        }
                    }
                }
            }
        }

        Item {
            id: overflowButton
            width: root.itemSize
            height: root.itemSize
            visible: overflowItems.length > 0

            Rectangle {
                anchors.fill: parent
                color: mouseOverflow.containsMouse ? Theme.accentSoft : "transparent"

                MouseArea {
                    id: mouseOverflow
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

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
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 9999

        visible: SysTrayState.openedMenu !== null || overflowPopup.open
        enabled: visible

        onPressed: {
            SysTrayState.forceCloseAll()
            overflowPopup.open = false
        }
    }
}
