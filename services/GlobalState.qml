pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.config

Singleton {
    id: root
    property string currentScheme: "dark"

    // Sync with Theme when Theme changes isDark
    Connections {
        target: Theme
        function onIsDarkChanged() {
            root.currentScheme = Theme.schemeName
        }
    }
}
