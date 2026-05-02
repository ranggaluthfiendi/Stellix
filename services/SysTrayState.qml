pragma Singleton
import QtQuick

QtObject {
    property var openedMenu: null
    property var openedSubmenuEntry: null
    property var openedSubmenuPopup: null

    property bool blockClose: false

    function closeAll() {
        if (blockClose) return

        if (openedMenu && openedMenu.internalVisible !== undefined) {
            openedMenu.internalVisible = false
        }

        if (openedSubmenuPopup && openedSubmenuPopup.menuData !== undefined) {
            openedSubmenuPopup.menuData = null
        }

        openedMenu = null
        openedSubmenuEntry = null
        openedSubmenuPopup = null
    }

    function forceCloseAll() {
        if (openedMenu && openedMenu.internalVisible !== undefined) {
            openedMenu.internalVisible = false
        }

        if (openedSubmenuPopup && openedSubmenuPopup.menuData !== undefined) {
            openedSubmenuPopup.menuData = null
        }

        openedMenu = null
        openedSubmenuEntry = null
        openedSubmenuPopup = null
        blockClose = false
    }
}
