import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import "./settings/components"

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

    function nextAnim() {
        if (root.wallpaper) root.wallpaper.cycleTransition()
    }

    function checkKonami(key) {
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.dp(12)

        // Header
        RowLayout {
            visible: root.showHints
            Layout.fillWidth: true
            spacing: Theme.dp(8)
            Text { 
                text: "Wallpaper Switcher"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(14 * s)
                font.weight: Font.Bold 
            }
            Item { Layout.fillWidth: true }
            Text { 
                text: root.wallpaper ? root.wallpaper.wallpaperDir.replace(Quickshell.env("HOME"), "~") : "~/Pictures/Wallpapers"
                color: Theme.textMuted
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(8 * s)
            }
        }

        // Preview Area
        Rectangle {
            visible: root.showPreview
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(100)
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
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: Theme.dp(8); anchors.rightMargin: Theme.dp(8); spacing: Theme.dp(8)
                    Text {
                        text: root.wallpaper ? root.wallpaper.getWallpaperName(root.wallpaper.currentIndex) : ""
                        color: "white"
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(9 * s)
                        font.weight: Font.Medium
                        Layout.fillWidth: true; elide: Text.ElideRight
                    }
                    Text {
                        text: "Transition: " + (root.wallpaper ? root.wallpaper.transitionType : "fade")
                        color: Theme.accent
                        font.family: Typography.fontFamily
                        font.pixelSize: Math.round(9 * s)
                        font.weight: Font.Bold
                    }
                }
            }
        }

        // Wallpaper Grid
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: Theme.dp(100)
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
                
                ScrollBar.vertical: ScrollBar { 
                    width: Theme.dp(4)
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle {
                        implicitWidth: Theme.dp(4)
                        radius: 0
                        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                    }
                }
            }
        }

        // Transition Settings
        ColumnLayout {
            visible: root.showHints
            Layout.fillWidth: true
            spacing: Theme.dp(4)

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(8)
                Text { 
                    text: "Duration:"
                    color: Theme.textSecondary
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
                    Layout.preferredWidth: Theme.dp(60) 
                }
                VabSlider {
                    id: durationSlider
                    Layout.fillWidth: true
                    Layout.preferredWidth: -1
                    from: 0.1; to: 3.0; stepSize: 0.1
                    value: root.wallpaper ? root.wallpaper.transitionDuration : 0.5
                    onValueChanged: if (root.wallpaper) root.wallpaper.transitionDuration = value
                }
                Text { 
                    text: (root.wallpaper ? root.wallpaper.transitionDuration.toFixed(1) : "0.5") + "s"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
                    Layout.preferredWidth: Theme.dp(36)
                    horizontalAlignment: Text.AlignRight 
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.dp(8)
                Text { 
                    text: "FPS:"
                    color: Theme.textSecondary
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
                    Layout.preferredWidth: Theme.dp(60) 
                }
                VabSlider {
                    id: fpsSlider
                    Layout.fillWidth: true
                    Layout.preferredWidth: -1
                    from: 30; to: 144; stepSize: 1
                    value: root.wallpaper ? root.wallpaper.transitionFps : 60
                    onValueChanged: if (root.wallpaper) root.wallpaper.transitionFps = Math.round(value)
                }
                Text { 
                    text: (root.wallpaper ? root.wallpaper.transitionFps : 60) + " fps"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
                    Layout.preferredWidth: Theme.dp(36)
                    horizontalAlignment: Text.AlignRight 
                }
            }
        }

        // --- Footer Navigation Section ---
        Rectangle {
            visible: root.showHints
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(28)
            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
            radius: 0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.dp(12)
                anchors.rightMargin: Theme.dp(12)
                spacing: Theme.dp(10)

                FooterHint { label: "Navigate"; keys: "Arrows" }
                FooterSeparator {}
                FooterHint { label: "Apply"; keys: "Enter" }
                FooterSeparator {}
                FooterHint { label: "Transition"; keys: "T" }
                FooterSeparator {}
                FooterHint { label: "Close"; keys: "Esc" }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: "Stellix Wallpaper"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(8 * s)
                    font.weight: Font.Bold
                    opacity: 0.6
                }
            }
        }
    }

    component FooterHint: RowLayout {
        property string label: ""
        property string keys: ""
        spacing: Theme.dp(4)
        
        Text {
            text: keys
            color: Theme.accent
            font.family: Typography.fontFamily
            font.pixelSize: Math.round(8 * s)
            font.weight: Font.Bold
        }
        Text {
            text: label
            color: Theme.textMuted
            font.family: Typography.fontFamily
            font.pixelSize: Math.round(8 * s)
        }
    }

    component FooterSeparator: Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: Theme.dp(12)
        color: Theme.border
        opacity: 0.5
    }
}
