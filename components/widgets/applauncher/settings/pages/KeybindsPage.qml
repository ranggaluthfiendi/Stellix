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
    
    // Logic state passed from main root
    property bool isRecording: false
    property var keybindMap: null
    property string recordingTarget: ""
    
    // UI Notification State
    property string uiMessage: ""
    property color uiMessageColor: Theme.accent
    Timer { id: msgTimer; interval: 3000; onTriggered: page.uiMessage = "" }

    function showMessage(msg, isError) {
        page.uiMessage = msg
        page.uiMessageColor = isError ? Theme.danger : Theme.accent
        msgTimer.restart()
    }

    signal recordClicked(string target)
    
    active: page.focusInContent && page.currentCategory === 4
    focusIndex: page.contentFocusIndex

    ColumnLayout {
        width: parent.width
        spacing: Theme.dp(10)

        Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.dp(34)
                color: page.uiMessage !== "" ? Qt.rgba(page.uiMessageColor.r, page.uiMessageColor.g, page.uiMessageColor.b, 0.15) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.08)
                border.width: 1; border.color: page.uiMessage !== "" ? page.uiMessageColor : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2); radius: 0
                
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }

                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: Theme.dp(16); anchors.rightMargin: Theme.dp(12)
                    Text { text: page.uiMessage !== "" ? (page.uiMessageColor === Theme.danger ? "❌" : "✅") : "💡"; font.pixelSize: Theme.dp(11) }
                    Text {
                        text: page.uiMessage !== "" ? page.uiMessage : (page.isRecording ? "Press a key to record... (ESC to cancel)" : "Click on a keybind to change it. Press ESC to cancel recording.")
                        color: page.uiMessage !== "" ? page.uiMessageColor : (page.isRecording ? Theme.accent : Theme.textMuted)
                        font.pixelSize: Theme.dp(8); Layout.fillWidth: true; font.weight: page.uiMessage !== "" ? Font.Bold : Font.Normal
                    }
                }
            }

            VabSectionHeader { title: "System Shortcuts" }
            
            VabKeybindItem { 
                itemIndex: 0; isFocused: page.focusInContent && page.contentFocusIndex === 0
                label: "App Launcher"; target: "launcher"; keybindMap: page.keybindMap; isRecording: page.isRecording; recordingTarget: page.recordingTarget
                onRecordClicked: page.recordClicked("launcher")
            }
            VabKeybindItem { 
                itemIndex: 1; isFocused: page.focusInContent && page.contentFocusIndex === 1
                label: "Clipboard History"; target: "clipboard"; keybindMap: page.keybindMap; isRecording: page.isRecording; recordingTarget: page.recordingTarget
                onRecordClicked: page.recordClicked("clipboard")
            }
            VabKeybindItem { 
                itemIndex: 2; isFocused: page.focusInContent && page.contentFocusIndex === 2
                label: "System Settings"; target: "settings"; keybindMap: page.keybindMap; isRecording: page.isRecording; recordingTarget: page.recordingTarget
                onRecordClicked: page.recordClicked("settings")
            }
            VabKeybindItem { 
                itemIndex: 3; isFocused: page.focusInContent && page.contentFocusIndex === 3
                label: "Shortcut Guide"; target: "guide"; keybindMap: page.keybindMap; isRecording: page.isRecording; recordingTarget: page.recordingTarget
                onRecordClicked: page.recordClicked("guide")
            }
            VabKeybindItem { 
                itemIndex: 4; isFocused: page.focusInContent && page.contentFocusIndex === 4
                label: "Workspace Switcher"; target: "ws_tab"; keybindMap: page.keybindMap; isRecording: page.isRecording; recordingTarget: page.recordingTarget
                onRecordClicked: page.recordClicked("ws_tab")
            }

            VabSectionHeader { title: "Applications"; Layout.topMargin: Theme.dp(10) }
            
            VabKeybindItem { 
                itemIndex: 5; isFocused: page.focusInContent && page.contentFocusIndex === 5
                label: "Terminal"; target: "terminal"; keybindMap: page.keybindMap; isRecording: page.isRecording; recordingTarget: page.recordingTarget
                onRecordClicked: page.recordClicked("terminal")
            }
            VabKeybindItem { 
                itemIndex: 6; isFocused: page.focusInContent && page.contentFocusIndex === 6
                label: "File Manager"; target: "files"; keybindMap: page.keybindMap; isRecording: page.isRecording; recordingTarget: page.recordingTarget
                onRecordClicked: page.recordClicked("files")
            }
            VabKeybindItem { 
                itemIndex: 7; isFocused: page.focusInContent && page.contentFocusIndex === 7
                label: "Browser"; target: "browser"; keybindMap: page.keybindMap; isRecording: page.isRecording; recordingTarget: page.recordingTarget
                onRecordClicked: page.recordClicked("browser")
            }
            VabKeybindItem { 
                itemIndex: 8; isFocused: page.focusInContent && page.contentFocusIndex === 8
                label: "Code Editor"; target: "code"; keybindMap: page.keybindMap; isRecording: page.isRecording; recordingTarget: page.recordingTarget
                onRecordClicked: page.recordClicked("code")
            }
            VabKeybindItem { 
                itemIndex: 9; isFocused: page.focusInContent && page.contentFocusIndex === 9
                label: "Discord"; target: "discord"; keybindMap: page.keybindMap; isRecording: page.isRecording; recordingTarget: page.recordingTarget
                onRecordClicked: page.recordClicked("discord")
            }

            VabSectionHeader { title: "Window Management"; Layout.topMargin: Theme.dp(10) }
            
            VabKeybindItem { 
                itemIndex: 10; isFocused: page.focusInContent && page.contentFocusIndex === 10
                label: "Kill Window"; target: "kill"; keybindMap: page.keybindMap; isRecording: page.isRecording; recordingTarget: page.recordingTarget
                onRecordClicked: page.recordClicked("kill")
            }
            VabKeybindItem { 
                itemIndex: 11; isFocused: page.focusInContent && page.contentFocusIndex === 11
                label: "Screenshot"; target: "screenshot"; keybindMap: page.keybindMap; isRecording: page.isRecording; recordingTarget: page.recordingTarget
                onRecordClicked: page.recordClicked("screenshot")
            }
            VabKeybindItem { 
                itemIndex: 12; isFocused: page.focusInContent && page.contentFocusIndex === 12
                label: "Fullscreen"; target: "fullscreen"; keybindMap: page.keybindMap; isRecording: page.isRecording; recordingTarget: page.recordingTarget
                onRecordClicked: page.recordClicked("fullscreen")
            }
            VabKeybindItem { 
                itemIndex: 13; isFocused: page.focusInContent && page.contentFocusIndex === 13
                label: "Toggle Floating"; target: "floating"; keybindMap: page.keybindMap; isRecording: page.isRecording; recordingTarget: page.recordingTarget
                onRecordClicked: page.recordClicked("floating")
            }

            Item { Layout.preferredHeight: Theme.dp(20) }
        }
}
