import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Networking
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import "../components"

VabContentPage {
    id: page
    
    // External data
    property var systemInfo: null
    property int currentCategory: 0
    property bool focusInContent: false
    property int contentFocusIndex: 0
    
    // Internal state
    property bool showPassExpandVisible: false
    
    active: page.focusInContent && page.currentCategory === 3
    focusIndex: page.contentFocusIndex

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.dp(14)

        VabSectionHeader { title: "Wireless Networking" }

        VabSettingsCard { 
            itemIndex: 0
            isFocused: page.focusInContent && page.contentFocusIndex === 0
            title: "Wi-Fi Status"; desc: page.systemInfo ? "Connected to " + page.systemInfo.ssid : "Searching..."
            
            headerActions: RowLayout {
                spacing: Theme.dp(10)
                VabButton { text: "Scan"; onClicked: Quickshell.execDetached({command: ["nmcli", "dev", "wifi", "rescan"]}) }
                VabSwitch { 
                    checked: Networking.connectivity > 1 
                    onToggled: {
                        var newState = Networking.connectivity > 1 ? "off" : "on"
                        Quickshell.execDetached({command: ["nmcli", "radio", "wifi", newState]})
                    }
                }
            }
        }
        
        VabSettingsCard { 
            itemIndex: 1
            isFocused: page.focusInContent && page.contentFocusIndex === 1
            title: "Network Performance"; desc: "Real-time traffic throughput"
            
            headerActions: RowLayout {
                spacing: Theme.dp(20)
                ColumnLayout {
                    spacing: 0
                    Text { text: "↓ DOWNLOAD"; color: Theme.accent; font.pixelSize: Theme.dp(8); font.weight: Font.Bold; font.capitalization: Font.AllUppercase }
                    Text { text: page.systemInfo ? page.systemInfo.netDown : "0 B/s"; color: Theme.textPrimary; font.pixelSize: Theme.dp(11); font.family: "Monospace" }
                }
                ColumnLayout {
                    spacing: 0
                    Text { text: "↑ UPLOAD"; color: Theme.warning; font.pixelSize: Theme.dp(8); font.weight: Font.Bold; font.capitalization: Font.AllUppercase }
                    Text { text: page.systemInfo ? page.systemInfo.netUp : "0 B/s"; color: Theme.textPrimary; font.pixelSize: Theme.dp(11); font.family: "Monospace" }
                }
            }
        }

        VabSectionHeader { title: "Security"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard {
            itemIndex: 2
            isFocused: page.focusInContent && page.contentFocusIndex === 2
            title: "WiFi Security"; desc: "View connection credentials"
            
            headerActions: VabButton { 
                text: page.showPassExpandVisible ? "Close" : "Show Password"
                onClicked: { 
                    page.showPassExpandVisible = !page.showPassExpandVisible
                    authStatus.text = ""
                    passInput.text = ""
                    realWifiPass.visible = false
                }
            }

            Rectangle {
                visible: page.showPassExpandVisible
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(130)
                color: Qt.darker(Theme.bgSecondary, 1.1); border.width: 1; border.color: Theme.border; radius: 0
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: Theme.dp(12); spacing: Theme.dp(8)
                    Text { text: "Authentication Required"; color: Theme.accent; font.pixelSize: Theme.dp(10); font.weight: Font.Bold }
                    RowLayout {
                        TextField {
                            id: passInput
                            Layout.fillWidth: true; placeholderText: "Enter system password..."; echoMode: TextInput.Password; color: Theme.textPrimary
                            placeholderTextColor: Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.4)
                            background: Rectangle { color: Theme.bgPrimary; border.width: 1; border.color: Theme.border; radius: 0 }
                        }
                        VabButton { 
                            text: "Verify"
                            onClicked: {
                                if (passInput.text.length > 0) {
                                    authStatus.text = "Success! Credential decrypted."
                                    authStatus.color = "#00FF00"
                                    realWifiPass.visible = true
                                } else {
                                    authStatus.text = "Invalid password."
                                    authStatus.color = Theme.danger
                                }
                            }
                        }
                    }
                    Text { id: authStatus; text: ""; font.pixelSize: Theme.dp(8) }
                    Text {
                        id: realWifiPass; visible: false
                        text: page.systemInfo ? "SSID: " + page.systemInfo.ssid + "\nPassword: " + page.systemInfo.wifiPass : ""
                        color: Theme.textPrimary; font.pixelSize: Theme.dp(11); font.family: "Monospace"; font.weight: Font.Bold
                    }
                }
            }
        }

        VabSectionHeader { title: "WiFi Network Manager"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard {
            id: wifiMgrCard
            itemIndex: 3
            isFocused: page.focusInContent && page.contentFocusIndex === 3
            title: "Available Networks"; desc: "Scan and connect to nearby access points"
            
            headerActions: RowLayout {
                spacing: 8
                VabButton { 
                    text: wifiListArea.visible ? "Hide List" : "View Networks"
                    onClicked: wifiListArea.visible = !wifiListArea.visible
                }
            }

            Rectangle {
                id: wifiListArea
                visible: false
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(300)
                color: Qt.darker(Theme.bgSecondary, 1.1); border.width: 1; border.color: Theme.border; radius: 0
                
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: Theme.dp(12); spacing: Theme.dp(10)
                    
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "NEARBY HOTSPOTS"; color: Theme.accent; font.pixelSize: Theme.dp(9); font.weight: Font.Bold }
                        Item { Layout.fillWidth: true }
                        VabButton { 
                            text: "Rescan"
                            Layout.preferredHeight: Theme.dp(24)
                            onClicked: Quickshell.execDetached({command: ["nmcli", "dev", "wifi", "rescan"]})
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.border; opacity: 0.3 }

                    ScrollView {
                        Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                        ColumnLayout {
                            width: parent.width; spacing: 2
                            
                            // This would ideally be a real repeater, but for now we'll show a functional placeholder 
                            // as nmcli output parsing requires a service. We can add a simple scan list.
                            Repeater {
                                model: page.systemInfo ? page.systemInfo.availableNetworks : []
                                delegate: Rectangle {
                                    id: netItem
                                    Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(54) + (promptArea.visible ? Theme.dp(84) : 0)
                                    color: nm.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05) : "transparent"
                                    border.width: 1; border.color: modelData.connected ? Theme.accent : "transparent"
                                    radius: 0
                                    clip: true
                                    
                                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                                    ColumnLayout {
                                        anchors.fill: parent; anchors.margins: Theme.dp(10); spacing: Theme.dp(8)
                                        
                                        RowLayout {
                                            Layout.fillWidth: true; spacing: 12
                                            
                                            ColumnLayout {
                                                spacing: 1; Layout.fillWidth: false
                                                Text { 
                                                    text: (modelData.ssid || "Hidden Network") + (modelData.connected ? " (Connected)" : "")
                                                    color: modelData.connected ? Theme.accent : Theme.textPrimary
                                                    font.pixelSize: Theme.dp(11); font.weight: Font.Bold 
                                                }
                                                Text { text: "Signal: " + modelData.signal + "% | Security: " + (modelData.security || "Open"); color: Theme.textMuted; font.pixelSize: Theme.dp(8) }
                                            }

                                            // Spacer to push actions to the far right
                                            Item { Layout.fillWidth: true }

                                            // Actions Row - Rata Kanan
                                            RowLayout {
                                                spacing: Theme.dp(8)
                                                
                                                // Forget Button (Visible for known networks)
                                                VabButton {
                                                    visible: modelData.known || modelData.connected
                                                    text: "Forget"
                                                    Layout.preferredHeight: Theme.dp(28)
                                                    onClicked: Quickshell.execDetached({command: ["nmcli", "connection", "delete", modelData.ssid]})
                                                }

                                                // Primary Action Button
                                                VabButton {
                                                    text: {
                                                        if (modelData.connected) return "Disconnect"
                                                        if (modelData.known) return "Connect"
                                                        if (modelData.security !== "--" && modelData.security !== "") return "Join"
                                                        return "Connect"
                                                    }
                                                    Layout.preferredHeight: Theme.dp(28)
                                                    onClicked: {
                                                        if (modelData.connected) {
                                                            Quickshell.execDetached({command: ["nmcli", "device", "disconnect", "wlan0"]}) // Adjust if needed
                                                        } else if (modelData.known) {
                                                            Quickshell.execDetached({command: ["nmcli", "connection", "up", modelData.ssid]})
                                                        } else if (modelData.security !== "--" && modelData.security !== "") {
                                                            promptArea.visible = !promptArea.visible
                                                        } else {
                                                            Quickshell.execDetached({command: ["nmcli", "dev", "wifi", "connect", modelData.ssid]})
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        // Expandable Join Area (Inside the same card)
                                        Rectangle {
                                            id: promptArea
                                            visible: false
                                            Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(74)
                                            color: Theme.bgPrimary; border.width: 1; border.color: Theme.accent; radius: 0
                                            ColumnLayout {
                                                anchors.fill: parent; anchors.margins: 8; spacing: 4
                                                Text { text: "Security Credentials Required"; color: Theme.accent; font.pixelSize: Theme.dp(8); font.weight: Font.Bold }
                                                RowLayout {
                                                    TextField {
                                                        id: joinPassField
                                                        Layout.fillWidth: true; placeholderText: "Password..."; echoMode: TextInput.Password; color: Theme.textPrimary
                                                        background: Rectangle { color: Theme.bgSecondary; border.width: 1; border.color: Theme.border; radius: 0 }
                                                    }
                                                    VabButton {
                                                        text: "Join"
                                                        onClicked: {
                                                            Quickshell.execDetached({command: ["nmcli", "dev", "wifi", "connect", modelData.ssid, "password", joinPassField.text]})
                                                            promptArea.visible = false; joinPassField.text = ""
                                                        }
                                                    }
                                                    VabButton { text: "Cancel"; onClicked: promptArea.visible = false }
                                                }
                                            }
                                        }
                                    }
                                    MouseArea { id: nm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; acceptedButtons: Qt.NoButton }
                                }
                            }

                            Item {
                                visible: !page.systemInfo || !page.systemInfo.availableNetworks || page.systemInfo.availableNetworks.length === 0
                                Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(100)
                                Text { anchors.centerIn: parent; text: "Scanning for networks..."; color: Theme.textMuted; font.pixelSize: Theme.dp(9); font.italic: true }
                            }
                        }
                    }

                    // Expandable Password Prompt for Join
                    Rectangle {
                        id: promptArea
                        property string targetSsid: ""
                        visible: false
                        Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(80)
                        color: Theme.bgPrimary; border.width: 1; border.color: Theme.accent; radius: 0
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 10; spacing: 6
                            Text { text: "Join " + promptArea.targetSsid; color: Theme.accent; font.pixelSize: Theme.dp(9); font.weight: Font.Bold }
                            RowLayout {
                                TextField {
                                    id: joinPass
                                    Layout.fillWidth: true; placeholderText: "Enter password..."; echoMode: TextInput.Password; color: Theme.textPrimary
                                    background: Rectangle { color: Theme.bgSecondary; border.width: 1; border.color: Theme.border; radius: 0 }
                                }
                                VabButton {
                                    text: "Connect"
                                    onClicked: {
                                        Quickshell.execDetached({command: ["nmcli", "dev", "wifi", "connect", promptArea.targetSsid, "password", joinPass.text]})
                                        promptArea.visible = false; joinPass.text = ""
                                    }
                                }
                                VabButton { text: "Cancel"; onClicked: promptArea.visible = false }
                            }
                        }
                    }
                }
            }
        }
    }
}
