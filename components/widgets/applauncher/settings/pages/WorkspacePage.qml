import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import qs.config
import qs.services
import "../components"

VabContentPage {
    id: page
    
    // External data
    property var systemInfo: null
    property int currentCategory: 0
    property bool focusInContent: false
    property int contentFocusIndex: 0
    
    active: page.focusInContent && page.currentCategory === 1
    focusIndex: page.contentFocusIndex

    ColumnLayout {
        width: parent.width
        spacing: Theme.dp(14)
        
        VabSectionHeader { title: "Desktop Behavior" }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(100)
            Text {
                anchors.centerIn: parent
                text: "Desktop Behavior settings are managed by system config."
                color: Theme.textMuted
                font.pixelSize: Theme.dp(10)
                font.italic: true
            }
        }
    }
}
