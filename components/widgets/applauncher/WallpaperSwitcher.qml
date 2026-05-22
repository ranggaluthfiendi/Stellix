import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.services

Rectangle {
    id: root

    color: "transparent"

    property real s: Scales.uiScale
    property var wallpaper: null
    property bool showHints: true
    property bool showPreview: true
    property int monitorIndex: -1

    readonly property var animNames: [
        "instant", "simple", "fade", "left", "right", "top", "bottom",
        "wipe", "wave", "grow", "center", "outer", "random"
    ]

    function apply() {
        if (root.wallpaper) root.wallpaper.applyWallpaper(root.monitorIndex)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.dp(12)

        // Header (Optional)
        ColumnLayout {
            visible: root.showHints
            Layout.fillWidth: true
            spacing: 2
            Text { text: "Wallpaper Switcher"; color: Theme.textPrimary; font.pixelSize: Theme.dp(12); font.weight: Font.Bold }
            Text { text: "Images: ~/Pictures/Wallpapers"; color: Theme.textMuted; font.pixelSize: Theme.dp(8) }
        }

        // Preview Area (Always visible if space permits)
        Rectangle {
            visible: root.showPreview
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(160)
            color: Theme.bgPrimary; border.width: 1; border.color: Theme.border; radius: 0; clip: true

            Image {
                id: previewImage
                anchors.fill: parent
                source: root.wallpaper ? root.wallpaper.currentWallpaperPath : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                opacity: 1
            }

            Rectangle {
                anchors.bottom: parent.bottom; width: parent.width; height: Theme.dp(24)
                color: Qt.rgba(0,0,0,0.6)
                Text {
                    anchors.centerIn: parent; text: root.wallpaper ? root.wallpaper.getWallpaperName(root.wallpaper.currentIndex) : ""
                    color: "white"; font.pixelSize: Theme.dp(9); font.weight: Font.Medium
                }
            }
        }

        // Wallpaper Grid
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            color: "transparent"; radius: 0; clip: true

            GridView {
                id: wallpaperGrid
                anchors.fill: parent
                model: root.wallpaper ? root.wallpaper.wallpapers : []
                cellWidth: Theme.dp(80); cellHeight: Theme.dp(90)
                currentIndex: root.wallpaper ? root.wallpaper.currentIndex : 0
                focus: true 

                Keys.onPressed: function(event) {
                    if (!root.wallpaper) return;
                    if (event.key === Qt.Key_Right) { currentIndex = (currentIndex + 1) % model.length; event.accepted = true }
                    else if (event.key === Qt.Key_Left) { currentIndex = (currentIndex - 1 + model.length) % model.length; event.accepted = true }
                    else if (event.key === Qt.Key_Up) { currentIndex = (currentIndex - 4 + model.length) % model.length; event.accepted = true }
                    else if (event.key === Qt.Key_Down) { currentIndex = (currentIndex + 4) % model.length; event.accepted = true }
                    else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) { root.apply(); event.accepted = true }
                    else if (event.key === Qt.Key_T) { root.wallpaper.cycleTransition(); event.accepted = true }
                }

                delegate: Item {
                    width: Theme.dp(80); height: Theme.dp(90)
                    Rectangle {
                        anchors.fill: parent; anchors.margins: 4
                        color: wallpaperGrid.currentIndex === index ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : "transparent"
                        border.width: 2; border.color: wallpaperGrid.currentIndex === index ? Theme.accent : Theme.border; radius: 0
                        
                        Image {
                            anchors.fill: parent; anchors.margins: 4
                            source: modelData; fillMode: Image.PreserveAspectCrop; asynchronous: true
                        }
                    }
                    MouseArea {
                        anchors.fill: parent; onClicked: { 
                            wallpaperGrid.currentIndex = index; 
                            if (root.wallpaper) root.wallpaper.goTo(index) 
                        }
                    }
                }
                
                ScrollBar.vertical: ScrollBar { width: Theme.dp(4); policy: ScrollBar.AsNeeded }
            }
        }

        // Footer Hints (Optional)
        RowLayout {
            visible: root.showHints
            Layout.fillWidth: true; spacing: 10
            Text { text: "↑↓←→ Navigate | Enter Apply | T Transition"; color: Theme.accent; font.pixelSize: Theme.dp(8) }
        }
    }
}
