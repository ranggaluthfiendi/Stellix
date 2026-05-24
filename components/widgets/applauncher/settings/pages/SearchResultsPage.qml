import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.services
import "../components"

VabContentPage {
    id: page
    
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
        
        // Recent Searches (shown when no query)
        ColumnLayout {
            visible: page.searchQuery === "" && page.settingsData && page.settingsData.recentSearches.length > 0
            Layout.fillWidth: true
            spacing: Theme.dp(6)

            Text { 
                text: "Recent Searches"
                color: Theme.textMuted
                font.pixelSize: Theme.dp(9)
                font.weight: Font.Bold
            }

            Repeater {
                model: page.settingsData ? page.settingsData.recentSearches : []
                delegate: Rectangle {
                    required property string modelData
                    required property int index

                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.dp(36)
                    color: recentMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.08) : "transparent"
                    border.width: 1
                    border.color: recentMouse.containsMouse ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.3)
                    radius: 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.dp(12)
                        anchors.rightMargin: Theme.dp(8)
                        spacing: Theme.dp(8)

                        Text {
                            text: "🕐"
                            font.pixelSize: Theme.dp(10)
                        }

                        Text {
                            text: modelData
                            color: Theme.textPrimary
                            font.pixelSize: Theme.dp(10)
                            font.weight: Font.Medium
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: Theme.dp(20)
                            height: Theme.dp(20)
                            color: clearRecentMouse.containsMouse ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.1) : "transparent"
                            radius: 0

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: clearRecentMouse.containsMouse ? Theme.danger : Theme.textMuted
                                font.pixelSize: Theme.dp(8)
                            }

                            MouseArea {
                                id: clearRecentMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var copy = page.settingsData.recentSearches.slice()
                                    copy.splice(index, 1)
                                    page.settingsData.recentSearches = copy
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: recentMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            page.searchQuery = modelData
                            page.settingsData.addRecentSearch(modelData)
                        }
                    }
                }
            }

            VabButton {
                text: "Clear All"
                onClicked: page.settingsData.clearRecentSearches()
            }
        }

        // Search Results
        Text { 
            visible: page.searchQuery !== ""
            text: "Found " + searchRepeater.count + " results for '" + page.searchQuery + "'"
            color: Theme.textMuted
            font.pixelSize: Theme.dp(9) 
        }
        
        Repeater {
            id: searchRepeater
            model: page.searchQuery !== "" && page.settingsData ? page.settingsData.search(page.searchQuery) : []
            delegate: VabSettingsCard {
                itemIndex: index
                isFocused: page.focusInContent && page.contentFocusIndex === index
                title: modelData.title
                desc: modelData.desc
                sectionLabel: modelData.section || ""

                VabButton { 
                    text: "Go To"
                    onClicked: {
                        page.settingsData.addRecentSearch(page.searchQuery)
                        page.goToCategory(modelData.cat, modelData.title)
                    }
                }
            }
        }
        
        Item { 
            visible: page.searchQuery !== "" && searchRepeater.count === 0
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(80)
            Text { anchors.centerIn: parent; text: "No matching settings found"; color: Theme.textMuted } 
        }
    }
}
