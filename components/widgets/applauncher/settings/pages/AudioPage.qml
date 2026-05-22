import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.services
import qs.components.elements
import "../components"

VabContentPage {
    id: page
    
    // External data
    property var systemInfo: null
    property int currentCategory: 0
    property bool focusInContent: false
    property int contentFocusIndex: 0
    
    property var pwService: null
    
    // Internal state for device switchers
    property bool outSwitchVisible: false
    property bool inSwitchVisible: false
    
    active: page.focusInContent && page.currentCategory === 2
    focusIndex: page.contentFocusIndex

    ColumnLayout {
        width: parent.width
        spacing: Theme.dp(14)
        
        VabSectionHeader { title: "Primary Output" }

        VabSettingsCard {
            itemIndex: 0
            isFocused: page.focusInContent && page.contentFocusIndex === 0
            title: "Master Speaker"; desc: (page.pwService && page.pwService.sink) ? page.pwService.nodeName(page.pwService.sink) : "Unknown Output"
            
            headerActions: RowLayout {
                spacing: Theme.dp(12)

                VabSlider { 
                    value: (page.pwService && page.pwService.sink) ? page.pwService.sink.audio.volume : 0; 
                    muted: (page.pwService && page.pwService.sink) && page.pwService.sink.audio.muted
                    onMoved: if(page.pwService && page.pwService.sink) page.pwService.sink.audio.volume = value 

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        onWheel: function(wheel) {
                            if (!page.pwService || !page.pwService.sink) return
                            var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                            page.pwService.sink.audio.volume = Math.max(0, Math.min(1, page.pwService.sink.audio.volume + delta))
                        }
                    }
                }

                Text {
                    text: (page.pwService && page.pwService.sink) ? Math.round(page.pwService.sink.audio.volume * 100) + "%" : "0%"
                    color: (page.pwService && page.pwService.sink && page.pwService.sink.audio.muted) ? Theme.danger : Theme.accent
                    font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight
                }

                Rectangle {
                    Layout.preferredWidth: Theme.dp(28); Layout.preferredHeight: Theme.dp(28)
                    color: outMuteM.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"
                    border.width: 1; border.color: (page.pwService && page.pwService.sink && page.pwService.sink.audio.muted) ? Theme.danger : Theme.accent; radius: 0
                    IconVolume { 
                        anchors.centerIn: parent; iconSize: Theme.dp(14)
                        iconColor: (page.pwService && page.pwService.sink && page.pwService.sink.audio.muted) ? Theme.danger : Theme.accent 
                    }
                    MouseArea {
                        id: outMuteM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: if(page.pwService && page.pwService.sink) page.pwService.sink.audio.muted = !page.pwService.sink.audio.muted
                    }
                }

                VabButton {
                    text: page.outSwitchVisible ? "Close" : "Switch"
                    visible: page.pwService && page.pwService.sinkDevices().length > 1
                    onClicked: page.outSwitchVisible = !page.outSwitchVisible
                }
            }
        }
        
        // Output Device Switcher
        Rectangle {
            visible: page.outSwitchVisible
            Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(140); color: Qt.darker(Theme.bgSecondary, 1.1); border.width: 1; border.color: Theme.border; radius: 0
            ScrollView {
                anchors.fill: parent; anchors.margins: 4; clip: true
                ColumnLayout {
                    width: parent.width; spacing: 2
                    Repeater {
                        model: page.pwService ? page.pwService.sinkDevices() : []
                        delegate: Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(34); color: (page.pwService && page.pwService.sink === modelData) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : (m.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.05) : "transparent")
                            RowLayout {
                                anchors.fill: parent; anchors.margins: Theme.dp(10); spacing: 10
                                Text { text: page.pwService ? page.pwService.nodeName(modelData) : ""; color: (page.pwService && page.pwService.sink === modelData) ? Theme.accent : Theme.textPrimary; font.pixelSize: Theme.dp(9); Layout.fillWidth: true; elide: Text.ElideRight }
                                Text { text: "✓"; visible: (page.pwService && page.pwService.sink === modelData); color: Theme.accent; font.pixelSize: Theme.dp(10) }
                            }
                            MouseArea { id: m; anchors.fill: parent; hoverEnabled: true; onClicked: if(page.pwService) page.pwService.preferredDefaultAudioSink = modelData }
                        }
                    }
                }
            }
        }
        
        VabSectionHeader { title: "Recording Input"; Layout.topMargin: Theme.dp(10) }

        VabSettingsCard {
            itemIndex: 1
            isFocused: page.focusInContent && page.contentFocusIndex === 1
            title: "Default Mic"; desc: (page.pwService && page.pwService.source) ? page.pwService.nodeName(page.pwService.source) : "No Microphone"
            
            headerActions: RowLayout {
                spacing: Theme.dp(12)

                VabSlider { 
                    value: (page.pwService && page.pwService.source) ? page.pwService.source.audio.volume : 0; 
                    muted: (page.pwService && page.pwService.source) && page.pwService.source.audio.muted
                    onMoved: if(page.pwService && page.pwService.source) page.pwService.source.audio.volume = value 

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        onWheel: function(wheel) {
                            if (!page.pwService || !page.pwService.source) return
                            var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                            page.pwService.source.audio.volume = Math.max(0, Math.min(1, page.pwService.source.audio.volume + delta))
                        }
                    }
                }

                Text {
                    text: (page.pwService && page.pwService.source) ? Math.round(page.pwService.source.audio.volume * 100) + "%" : "0%"
                    color: (page.pwService && page.pwService.source && page.pwService.source.audio.muted) ? Theme.danger : Theme.accent
                    font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight
                }

                Rectangle {
                    Layout.preferredWidth: Theme.dp(28); Layout.preferredHeight: Theme.dp(28)
                    color: inMuteM.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"
                    border.width: 1; border.color: (page.pwService && page.pwService.source && page.pwService.source.audio.muted) ? Theme.danger : Theme.accent; radius: 0
                    IconMic { 
                        anchors.centerIn: parent; iconSize: Theme.dp(14)
                        iconColor: (page.pwService && page.pwService.source && page.pwService.source.audio.muted) ? Theme.danger : Theme.accent 
                    }
                    MouseArea {
                        id: inMuteM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: if(page.pwService && page.pwService.source) page.pwService.source.audio.muted = !page.pwService.source.audio.muted
                    }
                }

                VabButton {
                    text: page.inSwitchVisible ? "Close" : "Switch"
                    visible: page.pwService && page.pwService.sourceDevices().length > 1
                    onClicked: page.inSwitchVisible = !page.inSwitchVisible
                }
            }
        }
        
        // Input Device Switcher
        Rectangle {
            visible: page.inSwitchVisible
            Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(140); color: Qt.darker(Theme.bgSecondary, 1.1); border.width: 1; border.color: Theme.border; radius: 0
            ScrollView {
                anchors.fill: parent; anchors.margins: 4; clip: true
                ColumnLayout {
                    width: parent.width; spacing: 2
                    Repeater {
                        model: page.pwService ? page.pwService.sourceDevices() : []
                        delegate: Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(34); color: (page.pwService && page.pwService.source === modelData) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : (ms.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.05) : "transparent")
                            RowLayout {
                                anchors.fill: parent; anchors.margins: Theme.dp(10); spacing: 10
                                Text { text: page.pwService ? page.pwService.nodeName(modelData) : ""; color: (page.pwService && page.pwService.source === modelData) ? Theme.accent : Theme.textPrimary; font.pixelSize: Theme.dp(9); Layout.fillWidth: true; elide: Text.ElideRight }
                                Text { text: "✓"; visible: (page.pwService && page.pwService.source === modelData); color: Theme.accent; font.pixelSize: Theme.dp(10) }
                            }
                            MouseArea { id: ms; anchors.fill: parent; hoverEnabled: true; onClicked: if(page.pwService) page.pwService.preferredDefaultAudioSource = modelData }
                        }
                    }
                }
            }
        }

        VabSectionHeader { title: "Application Mixer"; Layout.topMargin: Theme.dp(12) }

        Repeater {
            model: page.pwService ? page.pwService.sinkApps() : []
            delegate: VabSettingsCard {
                itemIndex: 2 + index
                isFocused: page.focusInContent && page.contentFocusIndex === (2 + index)
                title: page.pwService ? page.pwService.nodeName(modelData) : ""; desc: "Playback stream"
                
                headerActions: RowLayout {
                    spacing: Theme.dp(12)
                    VabSlider { 
                        value: modelData.audio.volume; 
                        muted: modelData.audio.muted
                        onMoved: modelData.audio.volume = value 
                        
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            onWheel: function(wheel) {
                                var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                                modelData.audio.volume = Math.max(0, Math.min(1, modelData.audio.volume + delta))
                            }
                        }
                    }
                    Text {
                        text: Math.round(modelData.audio.volume * 100) + "%"
                        color: modelData.audio.muted ? Theme.danger : Theme.accent
                        font.pixelSize: Theme.dp(10); font.weight: Font.Bold; Layout.preferredWidth: Theme.dp(36); horizontalAlignment: Text.AlignRight
                    }
                    Rectangle {
                        Layout.preferredWidth: Theme.dp(28); Layout.preferredHeight: Theme.dp(28)
                        color: appMuteM.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"
                        border.width: 1; border.color: modelData.audio.muted ? Theme.danger : Theme.accent; radius: 0
                        IconVolume { 
                            anchors.centerIn: parent; iconSize: Theme.dp(14)
                            iconColor: modelData.audio.muted ? Theme.danger : Theme.accent 
                        }
                        MouseArea {
                            id: appMuteM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.audio.muted = !modelData.audio.muted
                        }
                    }
                }
            }
        }

        // Empty state for mixer
        Item {
            visible: page.pwService ? page.pwService.sinkApps().length === 0 : true
            Layout.fillWidth: true; Layout.preferredHeight: Theme.dp(60)
            Text {
                anchors.centerIn: parent
                text: "No applications currently playing audio"
                color: Theme.textMuted
                font.pixelSize: Theme.dp(10)
            }
        }
    }
}
