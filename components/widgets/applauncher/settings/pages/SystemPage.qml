import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.services
import qs.components.widgets.rightbar
import "../components"

VabContentPage {
    id: page
    
    // External data
    property var settingsData: null
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

        VabSettingsCard {
            itemIndex: 1
            isFocused: page.focusInContent && page.contentFocusIndex === 1
            title: "Welcome Screen"; desc: "Show a welcoming screen on startup"
            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: "Show Now"
                    onClicked: {
                        RightBarState.settingsOpen = false
                        RightBarState.welcomeRequested()
                    }
                }
                VabSwitch {
                    checked: settingsData ? settingsData.showWelcomeScreen : true
                    onToggled: if(settingsData) settingsData.showWelcomeScreen = !settingsData.showWelcomeScreen
                }
            }
        }

        VabSettingsCard {
            itemIndex: 2
            isFocused: page.focusInContent && page.contentFocusIndex === 2
            title: "Windowed Settings"; desc: "Use a floating window instead of an overlay"
            headerActions: VabSwitch {
                checked: settingsData ? settingsData.settingsFloating : false
                onToggled: if(settingsData) settingsData.settingsFloating = !settingsData.settingsFloating
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(36)
                color: Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.1)
                border.width: 1; border.color: Theme.danger; radius: 0
                visible: settingsData ? settingsData.settingsFloating : false
                
                RowLayout {
                    anchors.fill: parent; anchors.margins: Theme.dp(8); spacing: Theme.dp(8)
                    Text { text: "⚠"; color: Theme.danger; font.pixelSize: Theme.dp(14); font.weight: Font.Bold }
                    Text {
                        text: "EXPERIMENTAL: This mode may cause UI scaling or focus issues on some monitors."
                        color: Theme.danger; font.pixelSize: Theme.dp(8); Layout.fillWidth: true; wrapMode: Text.WordWrap
                    }
                }
            }
        }

        VabSectionHeader { title: "Hardware Details"; Layout.topMargin: Theme.dp(10) }

        // --- Kernel ---
        VabSettingsCard { itemIndex: 3; isFocused: page.focusInContent && page.contentFocusIndex === 3; title: "Kernel Version"; desc: page.systemInfo ? page.systemInfo.kernel : "Unknown" }
        
        // --- CPU ---
        VabSettingsCard { itemIndex: 4; isFocused: page.focusInContent && page.contentFocusIndex === 4; title: "CPU Model"; desc: page.systemInfo ? page.systemInfo.cpuModel : "Unknown" }

        // --- GPU ---
        VabSettingsCard { 
            itemIndex: 5
            isFocused: page.focusInContent && page.contentFocusIndex === 5
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
        
        VabSettingsCard { itemIndex: 6; isFocused: page.focusInContent && page.contentFocusIndex === 6; title: "Storage Usage"; desc: page.systemInfo ? "Root Partition: " + page.systemInfo.storageInfo : "Unknown" }

        VabSectionHeader { title: "Live Metrics"; Layout.topMargin: Theme.dp(10) }
        
        RowLayout {
            spacing: Theme.dp(12)
            Layout.fillWidth: true
            
            VabInfoBox { 
                label: "Uptime"
                value: page.systemInfo ? page.systemInfo.uptime : "0h 0m"
                Layout.fillWidth: true
            }
            VabInfoBox { 
                label: "RAM Used"
                value: page.systemInfo ? Math.round(page.systemInfo.memUsed) + " MB" : "0 MB"
                Layout.fillWidth: true
            }
            VabInfoBox { 
                label: "RAM Total"
                value: page.systemInfo ? Math.round(page.systemInfo.memTotal) + " MB" : "0 MB"
                Layout.fillWidth: true
            }
        }
        
        VabSectionHeader { title: "Maintenance"; Layout.topMargin: Theme.dp(10) }
        
        VabSettingsCard { 
            itemIndex: 7
            isFocused: page.focusInContent && page.contentFocusIndex === 7
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
