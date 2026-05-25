pragma Singleton
import qs.core.settings
import QtQuick
import qs.components.widgets.barpopup

QtObject {
    property var openedMenu: null
    onOpenedMenuChanged: if (openedMenu) { BarPopupState.calendarOpen = false; BarPopupState.weatherDetailOpen = false; BarPopupState.workspaceSwitcherOpen = false }

    property var openedSubmenuEntry: null
    property var openedSubmenuPopup: null
    property var openedOverflow: null
    onOpenedOverflowChanged: if (openedOverflow) { BarPopupState.calendarOpen = false; BarPopupState.weatherDetailOpen = false; BarPopupState.workspaceSwitcherOpen = false }

    property var openedTrayPanel: null
    onOpenedTrayPanelChanged: if (openedTrayPanel) { BarPopupState.calendarOpen = false; BarPopupState.weatherDetailOpen = false; BarPopupState.workspaceSwitcherOpen = false }

    property bool blockClose: false

    function closeAll() {
        if (blockClose) return

        if (openedMenu && openedMenu.internalVisible !== undefined) {
            openedMenu.internalVisible = false
        }

        if (openedSubmenuPopup && openedSubmenuPopup.menuData !== undefined) {
            openedSubmenuPopup.menuData = null
        }

        if (openedOverflow && openedOverflow.open !== undefined) {
            openedOverflow.open = false
        }

        if (openedTrayPanel && openedTrayPanel.open !== undefined) {
            openedTrayPanel.open = false
        }

        openedMenu = null
        openedSubmenuEntry = null
        openedSubmenuPopup = null
        openedOverflow = null
        openedTrayPanel = null
    }

    function forceCloseAll() {
        if (openedMenu && openedMenu.internalVisible !== undefined) {
            openedMenu.internalVisible = false
        }

        if (openedSubmenuPopup && openedSubmenuPopup.menuData !== undefined) {
            openedSubmenuPopup.menuData = null
        }

        if (openedOverflow && openedOverflow.open !== undefined) {
            openedOverflow.open = false
        }

        if (openedTrayPanel && openedTrayPanel.open !== undefined) {
            openedTrayPanel.open = false
        }

        openedMenu = null
        openedSubmenuEntry = null
        openedSubmenuPopup = null
        openedOverflow = null
        openedTrayPanel = null
        blockClose = false
    }
}
