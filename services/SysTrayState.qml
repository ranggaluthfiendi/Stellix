pragma Singleton
import QtQuick

QtObject {
    property var openedMenu: null
    property var openedSubmenuEntry: null
    property var openedSubmenuPopup: null
    property var openedOverflow: null
    property var openedTrayPanel: null

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
