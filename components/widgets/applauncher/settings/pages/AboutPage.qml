import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.components.elements
import "../components"

VabContentPage {
    id: page
    
    // External data passed from main SettingsPopup
    property var systemInfo: null
    
    // Properties for VabContentPage
    property int currentCategory: 0
    property bool focusInContent: false
    property int contentFocusIndex: 0
    
    active: page.focusInContent && page.currentCategory === 6
    focusIndex: page.contentFocusIndex

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.dp(30)
        
        // --- Stellix Shell Section ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.dp(12)
            Layout.alignment: Qt.AlignHCenter
            
            Item {
                Layout.preferredWidth: Theme.dp(100)
                Layout.preferredHeight: Theme.dp(100)
                Layout.alignment: Qt.AlignHCenter
                
                StarShape {
                    id: shellStar
                    anchors.centerIn: parent
                    width: Theme.dp(64)
                    height: Theme.dp(64)
                    color: Theme.accent
                    
                    RotationAnimation on rotation {
                        id: starSpin
                        from: 0; to: 360; duration: 1000; loops: Animation.Infinite; running: false
                    }
                }

                MouseArea {
                    id: shellHold
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: starSpin.running = true
                    onReleased: starSpin.running = false
                    onCanceled: starSpin.running = false
                    onClicked: Quickshell.execDetached({command: ["xdg-open", "https://github.com/RanggaLuthfiendi"]})
                }
                
                // Subtle glow when hovered
                Rectangle {
                    anchors.centerIn: parent
                    width: Theme.dp(80); height: Theme.dp(80)
                    color: Theme.accent; opacity: shellHold.containsMouse ? 0.1 : 0
                    radius: width/2; z: -1
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
            }

            Text {
                text: "Stellix Shell Environment"; color: Theme.textPrimary; font.pixelSize: Theme.dp(22); font.weight: Font.Bold
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: "A master-crafted custom shell for Quickshell & Hyprland\nFocused on performance, aesthetics, and master logic control."; color: Theme.textMuted
                font.pixelSize: Theme.dp(10); horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter
            }
        }

        Rectangle { Layout.preferredWidth: parent.width * 0.6; Layout.preferredHeight: 1; color: Theme.border; Layout.alignment: Qt.AlignHCenter; opacity: 0.3 }

        // --- Core Tech Stack Section ---
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.dp(40)
            
            VabTechItem { 
                name: "Quickshell"; url: "https://quickshell.org/"; 
                icon: "file:///usr/share/icons/hicolor/scalable/apps/org.quickshell.svg" 
            }
            VabTechItem { 
                name: "Hyprland"; url: "https://wiki.hypr.land/"; 
                icon: "" // User will add manually
            }
            VabTechItem { 
                name: "Matugen"; url: "https://github.com/InioX/matugen"; 
                icon: "" // User will add manually
            }
        }

        // --- OS Info Section ---
        Rectangle {
            Layout.preferredWidth: Theme.dp(240)
            Layout.preferredHeight: Theme.dp(110)
            Layout.alignment: Qt.AlignHCenter
            color: distroMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05) : "transparent"
            border.width: 1; border.color: distroMouse.containsMouse ? Theme.accent : Theme.border; radius: 0
            
            ColumnLayout {
                anchors.centerIn: parent; spacing: Theme.dp(8)
                Image {
                    source: {
                        var logo = (page.systemInfo && page.systemInfo.distroLogo && page.systemInfo.distroLogo !== "") ? page.systemInfo.distroLogo : "archlinux-logo"
                        return "file:///usr/share/pixmaps/" + logo + ".svg"
                    }
                    Layout.preferredWidth: Theme.dp(48); Layout.preferredHeight: Theme.dp(48)
                    fillMode: Image.PreserveAspectFit; Layout.alignment: Qt.AlignHCenter
                }
                Column {
                    Layout.alignment: Qt.AlignHCenter
                    Text { text: page.systemInfo ? page.systemInfo.distroName : "Linux System"; color: Theme.textPrimary; font.pixelSize: Theme.dp(11); font.weight: Font.Bold; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: (page.systemInfo && page.systemInfo.distroId === "arch") ? "Independent Rolling" : "Based on Arch Linux"; color: Theme.accent; font.pixelSize: Theme.dp(8); anchors.horizontalCenter: parent.horizontalCenter }
                }
            }
            
            MouseArea {
                id: distroMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached({command: ["xdg-open", (page.systemInfo && page.systemInfo.distroId === "arch" ? "https://archlinux.org" : "https://archlinux.org")]})
            }
        }

        Rectangle { Layout.preferredWidth: Theme.dp(250); Layout.preferredHeight: 1; color: Theme.border; Layout.alignment: Qt.AlignHCenter; opacity: 0.3 }

        // Creator Info
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.dp(4)
            Text { text: "Developer"; color: Theme.textMuted; font.pixelSize: Theme.dp(8); Layout.alignment: Qt.AlignHCenter }
            Text { text: "Rang2 (Rangga Luthfiendi)"; color: Theme.accent; font.pixelSize: Theme.dp(12); font.weight: Font.Bold; Layout.alignment: Qt.AlignHCenter }
        }
    }

    // Helper component for tech stack items
    component VabTechItem: Item {
        id: techItem
        property string name: ""
        property string url: ""
        property string icon: ""
        Layout.preferredWidth: Theme.dp(120)
        Layout.preferredHeight: Theme.dp(100)
        
        ColumnLayout {
            anchors.centerIn: parent; spacing: 10
            Image { 
                source: (techItem.icon && techItem.icon !== "") ? techItem.icon : ""
                visible: (techItem.icon && techItem.icon !== "")
                Layout.preferredWidth: Theme.dp(54); Layout.preferredHeight: Theme.dp(54); fillMode: Image.PreserveAspectFit; Layout.alignment: Qt.AlignHCenter 
            }
            Text { text: techItem.name ? techItem.name : ""; color: Theme.textPrimary; font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.alignment: Qt.AlignHCenter }
        }
        
        MouseArea {
            id: techM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: if(techItem.url && techItem.url !== "") Quickshell.execDetached({command: ["xdg-open", techItem.url]})
        }
    }
}
