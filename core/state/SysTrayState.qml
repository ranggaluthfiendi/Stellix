pragma Singleton
import qs.core.settings
import QtQuick
import qs.components.widgets.barpopup

QtObject {
    property var openedMenu: null
    onOpenedMenuChanged: {
        if (openedMenu) {
            BarPopupState.open = false
            BarPopupState.calendarOpen = false
            BarPopupState.weatherDetailOpen = false
            BarPopupState.workspaceSwitcherOpen = false
            BarPopupState.mediaPopupOpen = false
            BarPopupState.notifPopupOpen = false
        }
    }

    property var openedSubmenuEntry: null
    property var openedSubmenuPopup: null
    property var openedOverflow: null
    onOpenedOverflowChanged: {
        if (openedOverflow) {
            BarPopupState.open = false
            BarPopupState.calendarOpen = false
            BarPopupState.weatherDetailOpen = false
            BarPopupState.workspaceSwitcherOpen = false
            BarPopupState.mediaPopupOpen = false
            BarPopupState.notifPopupOpen = false
        }
    }

    property var openedTrayPanel: null
    onOpenedTrayPanelChanged: {
        if (openedTrayPanel) {
            BarPopupState.open = false
            BarPopupState.calendarOpen = false
            BarPopupState.weatherDetailOpen = false
            BarPopupState.workspaceSwitcherOpen = false
            BarPopupState.mediaPopupOpen = false
            BarPopupState.notifPopupOpen = false
        }
    }

    property bool blockClose: false

    function _closeTrayItems() {
        if (openedMenu && openedMenu.internalVisible !== undefined) openedMenu.internalVisible = false
        if (openedSubmenuPopup && openedSubmenuPopup.menuData !== undefined) openedSubmenuPopup.menuData = null
        if (openedOverflow && openedOverflow.open !== undefined) openedOverflow.open = false
        if (openedTrayPanel && openedTrayPanel.open !== undefined) openedTrayPanel.open = false
        openedMenu = null
        openedSubmenuEntry = null
        openedSubmenuPopup = null
        openedOverflow = null
        openedTrayPanel = null
    }

    function closeAll() {
        if (blockClose) return
        _closeTrayItems()
    }

    function forceCloseAll() {
        _closeTrayItems()
        blockClose = false
    }
}
