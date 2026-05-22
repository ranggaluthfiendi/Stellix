import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth
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
    
    active: page.focusInContent && page.currentCategory === 8
    focusIndex: page.contentFocusIndex

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.dp(14)

        VabSectionHeader { title: "Bluetooth Management" }

        VabSettingsCard { 
            itemIndex: 0
            isFocused: page.focusInContent && page.contentFocusIndex === 0
            title: "Bluetooth Status"
            desc: {
                if (!Bluetooth.defaultAdapter) return "No Adapter Found";
                if (!Bluetooth.defaultAdapter.enabled) return "Disabled";
                var connectedName = "";
                for (var i = 0; i < Bluetooth.devices.count; i++) {
                    var d = Bluetooth.devices.get(i);
                    if (d && d.connected) { connectedName = d.name; break; }
                }
                if (connectedName !== "") return "Connected to " + connectedName;
                return "Active (No devices connected)";
            }
            
            headerActions: RowLayout {
                spacing: Theme.dp(10)
                VabButton { text: "Scan"; onClicked: Quickshell.execDetached({command: ["bluetoothctl", "scan", "on"]}) }
                VabButton { text: "Show"; onClicked: Quickshell.execDetached({command: ["bluetoothctl", "discoverable", "on"]}) }
                VabSwitch { 
                    checked: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled
                    onToggled: if(Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                } 
            }
        }
        
        VabSectionHeader { title: "Paired & Available Devices"; Layout.topMargin: Theme.dp(10) }

        Repeater {
            model: Bluetooth.devices
            delegate: VabSettingsCard {
                itemIndex: 1 + index
                isFocused: page.focusInContent && page.contentFocusIndex === (1 + index)
                title: modelData.name || "Unknown Device"
                desc: modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "Available")
                
                headerActions: VabButton { 
                    text: modelData.connected ? "Disconnect" : "Connect"
                    onClicked: if(modelData.connected) modelData.disconnectDevice(); else modelData.connectDevice()
                }
            }
        }
        
        Item { 
            visible: Bluetooth.devices.count === 0
            Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(60)
            Text { anchors.centerIn: parent; text: "No devices found"; color: Theme.textMuted; font.pixelSize: Theme.dp(10) } 
        }
    }
}
