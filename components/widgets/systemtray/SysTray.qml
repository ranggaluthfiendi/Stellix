pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import qs.components.widgets.systemtray
import qs.config
import qs.services

Item {
    id: root

    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth

    RowLayout {
        id: row
        spacing: Theme.dp(6)

        Repeater {
            model: SystemTray.items && SystemTray.items.values
                   ? SystemTray.items.values
                   : []

            delegate: Item {
                id: trayItem
                required property var modelData

                width: Theme.dp(26)
                height: Theme.dp(26)

                property bool valid: modelData !== null && modelData !== undefined

                Rectangle {
                    anchors.fill: parent
                    radius: 0

                    color: mouse.containsMouse
                        ? Qt.rgba(
                            Theme.accentSoft.r,
                            Theme.accentSoft.g,
                            Theme.accentSoft.b,
                            0.15
                          )
                        : "transparent"

                    Image {
                        anchors.centerIn: parent
                        source: valid && modelData.icon ? modelData.icon : ""
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
                            if (!valid) return

                            if (modelData.hasMenu) {

                                if (!menuPopup.internalVisible) {
                                    SysTrayState.closeAll()
                                }

                                if (!contentLoader.active) {
                                    contentLoader.active = true
                                }

                                menuPopup.internalVisible = !menuPopup.internalVisible

                                if (menuPopup.internalVisible) {
                                    SysTrayState.openedMenu = menuPopup
                                } else {
                                    SysTrayState.closeAll()
                                }

                            } else {
                                try { modelData.activate() } catch(e) {}
                            }
                        }
                    }
                }

                QsMenuOpener {
                    id: opener
                    menu: valid && modelData.menu ? modelData.menu : null
                }

                PopupWindow {
                    id: menuPopup

                    property bool internalVisible: false
                    property bool ready: contentLoader.item !== null

                    visible: opener.menu !== null && internalVisible && ready

                    implicitWidth: Math.max(
                        Theme.dp(150),
                        contentLoader.item ? contentLoader.item.implicitWidth : Theme.dp(150)
                    )

                    implicitHeight: Math.max(
                        Theme.dp(50),
                        contentLoader.item ? contentLoader.item.implicitHeight : Theme.dp(50)
                    )

                    anchor.item: parent
                    anchor.rect: Qt.rect(0, parent.height + Theme.dp(6), 0, 0)

                    Component.onCompleted: {
                        if (menuPopup.WlrLayershell) {
                            menuPopup.WlrLayershell.layer = WlrLayer.Overlay
                            menuPopup.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                        }
                    }

                    onVisibleChanged: {
                        if (visible) {
                            SysTrayState.openedMenu = menuPopup

                            Qt.callLater(function() {
                                if (contentLoader.item && contentLoader.item.playOpenAnimation) {
                                    contentLoader.item.playOpenAnimation()
                                }
                            })
                        } else if (SysTrayState.openedMenu === menuPopup) {
                            SysTrayState.closeAll()
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 0
                        color: Theme.bgSecondary
                        opacity: Theme.opacityPanel

                        Loader {
                            id: contentLoader
                            anchors.fill: parent
                            active: false

                            sourceComponent: MenuView {
                                id: menuView

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

                                    if (SysTrayState.openedSubmenuEntry === entry) {
                                        return
                                    }

                                    SysTrayState.openedSubmenuEntry = entry
                                    SysTrayState.openedSubmenuPopup = subMenuPopup

                                    subMenuPopup.menuData = entry
                                    subMenuPopup.anchorItem = anchorItem
                                }
                            }

                            onLoaded: {
                                if (item && opener.menu) {
                                    item.menu = opener.menu
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

        implicitWidth: Math.max(
            Theme.dp(150),
            contentLoader.item ? contentLoader.item.implicitWidth : Theme.dp(150)
        )

        implicitHeight: Math.max(
            Theme.dp(50),
            contentLoader.item ? contentLoader.item.implicitHeight : Theme.dp(50)
        )

        anchor.item: anchorItem
        anchor.rect: anchorItem
            ? Qt.rect(anchorItem.width + Theme.dp(6), 0, 0, 0)
            : Qt.rect(0, 0, 0, 0)

        Component.onCompleted: {
            if (subMenuPopup.WlrLayershell) {
                subMenuPopup.WlrLayershell.layer = WlrLayer.Overlay
                subMenuPopup.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 0
            color: Theme.bgSecondary
            opacity: Theme.opacityPanel

            Loader {
                id: contentLoader
                anchors.fill: parent

                sourceComponent: MenuView {
                    menu: subMenuPopup.menuData

                    onClose: {
                        subMenuPopup.menuData = null
                        SysTrayState.openedSubmenuEntry = null
                        SysTrayState.openedSubmenuPopup = null
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
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 9999

        visible: SysTrayState.openedMenu !== null
        enabled: visible

        onPressed: {
            SysTrayState.forceCloseAll()
        }
    }
}
