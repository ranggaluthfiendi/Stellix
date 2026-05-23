import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.services
import qs.components.widgets.applauncher
import "../components"

VabContentPage {
    id: page
    
    // External data
    property var systemInfo: null
    property var wallpaper: null
    property var colorService: null
    
    property int currentCategory: 0
    property bool focusInContent: false
    property int contentFocusIndex: 0
    property bool subFocusActive: false
    
    active: page.focusInContent && page.currentCategory === 0
    focusIndex: page.contentFocusIndex

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.dp(14)
        
        VabSectionHeader { title: "Desktop Background" }

        VabSettingsCard { 
            itemIndex: 0
            isFocused: page.focusInContent && page.contentFocusIndex === 0
            title: "Wallpaper Gallery"; desc: page.wallpaper ? "Transition: " + page.wallpaper.transitionType : "Loading..."
            
            headerActions: RowLayout {
                spacing: Theme.dp(10)
                VabButton { text: "Cycle"; onClicked: if(page.wallpaper) page.wallpaper.cycleTransition() }
                VabButton { text: "Apply"; onClicked: wpSwitcher.apply() }
                VabButton { 
                    text: wallpaperExpand.visible ? "Close" : "Gallery"
                    onClicked: wallpaperExpand.visible = !wallpaperExpand.visible
                }
            }

            // Preview Area inside card content
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(140)
                color: Theme.bgPrimary; border.width: 1; border.color: Theme.border; radius: 0; clip: true

                Image {
                    anchors.fill: parent
                    source: page.wallpaper ? page.wallpaper.currentWallpaperPath : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                // Overlay Navigation Arrows
                Rectangle {
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: Theme.dp(8)
                    width: Theme.dp(28); height: Theme.dp(28); color: prevWpM.containsMouse ? Theme.accent : Qt.rgba(0,0,0,0.4); radius: width/2
                    Text { anchors.centerIn: parent; text: "‹"; color: prevWpM.containsMouse ? Theme.bgPrimary : "white"; font.pixelSize: Theme.dp(18); font.weight: Font.Bold }
                    MouseArea { id: prevWpM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if(page.wallpaper) page.wallpaper.prev() }
                }

                Rectangle {
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; anchors.rightMargin: Theme.dp(8)
                    width: Theme.dp(28); height: Theme.dp(28); color: nextWpM.containsMouse ? Theme.accent : Qt.rgba(0,0,0,0.4); radius: width/2
                    Text { anchors.centerIn: parent; text: "›"; color: nextWpM.containsMouse ? Theme.bgPrimary : "white"; font.pixelSize: Theme.dp(18); font.weight: Font.Bold }
                    MouseArea { id: nextWpM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if(page.wallpaper) page.wallpaper.next() }
                }

                Rectangle {
                    anchors.bottom: parent.bottom; width: parent.width; height: Theme.dp(24)
                    color: Qt.rgba(0,0,0,0.6)
                    Text {
                        anchors.centerIn: parent; text: page.wallpaper ? page.wallpaper.getWallpaperName(page.wallpaper.currentIndex) : ""
                        color: "white"; font.pixelSize: Theme.dp(9); font.weight: Font.Medium
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.NoButton // Allow navigation buttons above to handle clicks
                    onClicked: wallpaperExpand.visible = !wallpaperExpand.visible
                }
            }
        }
        
        // Expandable Wallpaper Switcher (Grid only)
        Rectangle {
            id: wallpaperExpand
            property int itemIndex: 1
            visible: false
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(190) // Approx 2 rows
            color: Theme.bgSecondary; border.width: 1; border.color: (page.focusInContent && page.contentFocusIndex === 1) ? Theme.accent : Theme.border; radius: 0; clip: true
            
            WallpaperSwitcher {
                id: wpSwitcher
                wallpaper: page.wallpaper
                anchors.fill: parent; anchors.margins: Theme.dp(4)
                showHints: false
                showPreview: false
                focus: page.focusInContent && page.contentFocusIndex === 1 && page.subFocusActive
            }
            
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
                visible: page.focusInContent && page.contentFocusIndex === 1 && !page.subFocusActive
                Text { anchors.centerIn: parent; text: "Press ENTER to browse gallery"; color: Theme.accent; font.pixelSize: Theme.dp(9); font.weight: Font.Bold }
            }
        }

        VabSettingsCard {
            id: wallpaperDirCard
            property bool expanded: false
            itemIndex: 2
            isFocused: page.focusInContent && page.contentFocusIndex === 2
            title: "Wallpaper Directory"; desc: page.wallpaper ? page.wallpaper.wallpaperDir : "~/Pictures/Wallpapers"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton {
                    text: "Reset"
                    onClicked: if (page.wallpaper) page.wallpaper.resetWallpaperDir()
                }
                VabButton {
                    text: wallpaperDirCard.expanded ? "Close" : "Change"
                    onClicked: wallpaperDirCard.expanded = !wallpaperDirCard.expanded
                }
            }

            Rectangle {
                visible: wallpaperDirCard.expanded
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(40)
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    spacing: Theme.dp(8)

                    TextField {
                        id: dirInput
                        Layout.fillWidth: true
                        text: page.wallpaper ? page.wallpaper.wallpaperDir : ""
                        placeholderText: "~/Pictures/Wallpapers"
                        color: Theme.textPrimary
                        font.pixelSize: Theme.dp(10)
                        background: Rectangle {
                            color: Theme.bgPrimary
                            border.width: 1
                            border.color: dirInput.activeFocus ? Theme.accent : Theme.border
                            radius: 0
                        }
                        onAccepted: if (page.wallpaper) page.wallpaper.setWallpaperDir(text)
                    }

                    Rectangle {
                        width: Theme.dp(60)
                        height: Theme.dp(28)
                        color: dirApplyMouse.containsMouse ? Theme.accent : "transparent"
                        border.width: 1
                        border.color: Theme.accent
                        radius: 0

                        Text {
                            anchors.centerIn: parent
                            text: "Apply"
                            color: dirApplyMouse.containsMouse ? Theme.bgPrimary : Theme.accent
                            font.pixelSize: Theme.dp(9)
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: dirApplyMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (page.wallpaper) page.wallpaper.setWallpaperDir(dirInput.text)
                        }
                    }
                }
            }
        }

        VabSettingsCard {
            itemIndex: 3
            isFocused: page.focusInContent && page.contentFocusIndex === 3
            title: "Transition Duration"; desc: "Wallpaper transition speed in seconds"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabSlider {
                    from: 0.1; to: 3.0; value: page.wallpaper ? page.wallpaper.transitionDuration : 0.5; stepSize: 0.1
                    onValueChanged: if (page.wallpaper) page.wallpaper.transitionDuration = value
                }
                Text {
                    text: (page.wallpaper ? page.wallpaper.transitionDuration.toFixed(1) : "0.5") + "s"
                    color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold
                    Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight
                }
            }
        }

        VabSettingsCard {
            itemIndex: 4
            isFocused: page.focusInContent && page.contentFocusIndex === 4
            title: "Transition FPS"; desc: "Frames per second for wallpaper transition"

            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabSlider {
                    from: 30; to: 144; value: page.wallpaper ? page.wallpaper.transitionFps : 60; stepSize: 1
                    onValueChanged: if (page.wallpaper) page.wallpaper.transitionFps = Math.round(value)
                }
                Text {
                    text: (page.wallpaper ? page.wallpaper.transitionFps : 60) + " fps"
                    color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold
                    Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight
                }
            }
        }

        VabSectionHeader { title: "Colors & Theme"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard { 
            itemIndex: 5; isFocused: page.focusInContent && page.contentFocusIndex === 5; title: "Dark Mode"; desc: "System-wide color preference"
            headerActions: VabSwitch { 
                checked: Theme.isDark; 
                onToggled: {
                    if(page.colorService) page.colorService.toggleMode()
                }
            } 
        }
        
        VabSettingsCard { 
            id: matugenCard
            property bool expanded: false
            itemIndex: 7; isFocused: page.focusInContent && page.contentFocusIndex === 7; 
            title: "Matugen Theme"; 
            desc: page.colorService ? page.colorService.currentTypeName : "Standard Tonal"
            
            headerActions: RowLayout {
                spacing: Theme.dp(8)
                VabButton { 
                    text: "Cycle"
                    onClicked: if(page.colorService) page.colorService.cycleType()
                }
                VabButton { 
                    text: matugenCard.expanded ? "Close" : "Change"
                    onClicked: matugenCard.expanded = !matugenCard.expanded 
                } 
            }

            // Theme Selector List (Expanded to show all 8 items)
            Rectangle {
                visible: matugenCard.expanded
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(310) // 8 items * 38dp approx
                color: Qt.darker(Theme.bgSecondary, 1.1)
                border.width: 1; border.color: Theme.border; radius: 0
                clip: true

                ScrollView {
                    anchors.fill: parent; anchors.margins: 4; clip: true
                    ColumnLayout {
                        width: parent.width; spacing: 2
                        Repeater {
                            model: page.colorService ? page.colorService.schemeTypes : []
                            delegate: Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(36)
                                color: (page.colorService && page.colorService.currentType === modelData.value) 
                                    ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) 
                                    : (tm.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.05) : "transparent")
                                
                                RowLayout {
                                    anchors.fill: parent; anchors.margins: Theme.dp(10); spacing: 10
                                    Column {
                                        Layout.fillWidth: true
                                        Text { text: modelData.name; color: (page.colorService && page.colorService.currentType === modelData.value) ? Theme.accent : Theme.textPrimary; font.pixelSize: Theme.dp(9); font.weight: Font.Bold }
                                        Text { text: modelData.desc; color: Theme.textMuted; font.pixelSize: Theme.dp(7) }
                                    }
                                    Text { text: "✓"; visible: (page.colorService && page.colorService.currentType === modelData.value); color: Theme.accent; font.pixelSize: Theme.dp(10) }
                                }
                                MouseArea { 
                                    id: tm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: if(page.colorService) page.colorService.setType(modelData.value) 
                                }
                            }
                        }
                    }
                }
            }
        }

        VabSectionHeader { title: "Desktop Effects"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard { 
            id: blurCard
            itemIndex: 8
            isFocused: page.focusInContent && page.contentFocusIndex === 8
            title: "Blur Radius"; desc: "Glass effect intensity"
            
            headerActions: RowLayout {
                spacing: Theme.dp(12)
                VabSlider { 
                    id: blurSlider
                    from: 0; to: 100; stepSize: 1
                    Component.onCompleted: value = HyprlandDecoration.blurSize
                    onValueChanged: {
                        if (pressed) HyprlandDecoration.setBlurSize(value)
                    }
                }
                Text { 
                    text: blurSlider.value + "px"; 
                    color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; 
                    Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight 
                }
            }
        }
        
        VabSettingsCard { 
            id: transparencyCard
            itemIndex: 9
            isFocused: page.focusInContent && page.contentFocusIndex === 9
            title: "Transparency"; desc: "Panel background opacity"
            
            headerActions: RowLayout {
                spacing: Theme.dp(12)
                VabSlider { 
                    id: transparencySlider
                    from: 0; to: 100; stepSize: 1
                    Component.onCompleted: value = Math.round(HyprlandDecoration.transparency * 100)
                    onValueChanged: {
                        if (pressed) HyprlandDecoration.setTransparency(value / 100)
                    }
                }
                Text { 
                    text: transparencySlider.value + "%"; 
                    color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; 
                    Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight 
                }
            }
        }
    }
}
