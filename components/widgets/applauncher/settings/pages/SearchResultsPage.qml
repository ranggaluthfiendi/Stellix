import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.services
import "../components"

VabContentPage {
    id: page
    
    // External data
    property string searchQuery: ""
    property var settingsData: null
    property bool focusInContent: false
    property int contentFocusIndex: 0
    
    signal goToCategory(int category, string itemTitle)
    
    active: page.focusInContent
    focusIndex: page.contentFocusIndex

    ColumnLayout {
        width: parent.width
        spacing: Theme.dp(8)
        
        Text { 
            text: "Found " + searchRepeater.count + " results for '" + page.searchQuery + "'"
            color: Theme.textMuted
            font.pixelSize: Theme.dp(9) 
        }
        
        Repeater {
            id: searchRepeater
            model: page.settingsData ? page.settingsData.search(page.searchQuery) : []
            delegate: VabSettingsCard {
                itemIndex: index
                isFocused: page.focusInContent && page.contentFocusIndex === index
                title: modelData.title
                desc: modelData.desc
                VabButton { 
                    text: "Go To"
                    onClicked: page.goToCategory(modelData.cat, modelData.title)
                }
            }
        }
        
        Item { 
            visible: searchRepeater.count === 0
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(80)
            Text { anchors.centerIn: parent; text: "No matching settings found"; color: Theme.textMuted } 
        }
    }
}
