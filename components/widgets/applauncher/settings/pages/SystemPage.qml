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
    property var systemInfo: null
    property int currentCategory: 0
    property bool focusInContent: false
    property int contentFocusIndex: 0
    
    // Internal state
    property bool updateConsoleVisible: false
    
    active: page.focusInContent && page.currentCategory === 5
    focusIndex: page.contentFocusIndex

    ColumnLayout {
        width: parent.width
        spacing: Theme.dp(14)
        
        VabSectionHeader { title: "Shell Management" }
        
        VabSettingsCard { 
            itemIndex: 0
            isFocused: page.focusInContent && page.contentFocusIndex === 0
            title: "Stellix Shell"; desc: "Version 1.0"
            headerActions: VabButton { 
                text: "Restart Shell"
                onClicked: function(){ Quickshell.execDetached({command: ["sh", "-c", "pkill quickshell; quickshell"]}) } 
            } 
        }

        VabSectionHeader { title: "Hardware Details"; Layout.topMargin: Theme.dp(10) }

        // --- Kernel ---
        VabSettingsCard { itemIndex: 1; isFocused: page.focusInContent && page.contentFocusIndex === 1; title: "Kernel Version"; desc: page.systemInfo ? page.systemInfo.kernel : "Unknown" }
        
        // --- CPU ---
        VabSettingsCard { itemIndex: 2; isFocused: page.focusInContent && page.contentFocusIndex === 2; title: "CPU Model"; desc: page.systemInfo ? page.systemInfo.cpuModel : "Unknown" }

        // --- GPU ---
        VabSettingsCard { 
            itemIndex: 3
            isFocused: page.focusInContent && page.contentFocusIndex === 3
            title: "GPU"
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Layout.topMargin: 4
                Repeater {
                    model: (page.systemInfo && page.systemInfo.gpus) ? page.systemInfo.gpus : []
                    delegate: RowLayout {
                        spacing: 8
                        Text { text: "•"; color: Theme.accent; font.bold: true }
                        Text { 
                            text: modelData
                            color: Theme.textPrimary
                            font.pixelSize: Theme.dp(10)
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
        
        VabSettingsCard { itemIndex: 4; isFocused: page.focusInContent && page.contentFocusIndex === 4; title: "Storage Usage"; desc: page.systemInfo ? "Root Partition: " + page.systemInfo.storageInfo : "Unknown" }

        VabSectionHeader { title: "Live Metrics"; Layout.topMargin: Theme.dp(10) }
        
        RowLayout {
            spacing: Theme.dp(12); Layout.fillWidth: true
            VabInfoBox { label: "Uptime"; value: page.systemInfo ? page.systemInfo.uptime : "0h 0m" }
            VabInfoBox { label: "RAM Used"; value: page.systemInfo ? Math.round(page.systemInfo.memUsed) + " MB" : "0 MB" }
            VabInfoBox { label: "RAM Total"; value: page.systemInfo ? Math.round(page.systemInfo.memTotal) + " MB" : "0 MB" }
        }
        
        VabSectionHeader { title: "Maintenance"; Layout.topMargin: Theme.dp(10) }
        
        VabSettingsCard { 
            itemIndex: 5
            isFocused: page.focusInContent && page.contentFocusIndex === 5
            title: "System Updates"; desc: page.systemInfo ? page.systemInfo.updatesCount + " packages pending" : "0 packages pending"
            
            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton { 
                    text: page.updateConsoleVisible ? "Hide Console" : "Check Updates"
                    onClicked: {
                        if (page.systemInfo) page.systemInfo.refresh()
                        page.updateConsoleVisible = !page.updateConsoleVisible
                    }
                }
            }

            // Update Console inside card content
            Rectangle {
                visible: page.updateConsoleVisible
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(120)
                color: Qt.darker(Theme.bgSecondary, 1.2)
                border.width: 1; border.color: Theme.border; radius: 0
                
                ScrollView {
                    anchors.fill: parent
                    anchors.margins: Theme.dp(8)
                    clip: true
                    Text {
                        width: parent.width
                        text: "[stellix@arch] checkupdates\n" + (page.systemInfo && page.systemInfo.updatesCount > 0 ? "Checking for updates...\nFound " + page.systemInfo.updatesCount + " packages to update.\nRun 'sudo pacman -Syu' to apply." : "System is up to date.")
                        color: "#00FF00"
                        font.family: "Monospace"
                        font.pixelSize: Theme.dp(9)
                    }
                }
            }
        }
    }
}
