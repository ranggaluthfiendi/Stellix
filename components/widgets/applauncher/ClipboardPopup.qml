import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config

Rectangle {
    id: root

    color: "transparent"
    focus: true
    property var service: null

    signal closeRequested

    property real s: Scales.uiScale

    Component.onCompleted: {
        if (root.service) {
            root.service.refreshHistory()
        }
    }

    onVisibleChanged: {
        if (visible) {
            Qt.callLater(function() {
                searchField.forceActiveFocus()
            })
            if (root.service) {
                root.service.refreshHistory()
            }
        }
    }

    function selectCurrent() {
        if (clipList.currentIndex >= 0 && root.service) {
            var item = root.service.filteredHistory[clipList.currentIndex]
            if (item) {
                if (item.isImage) {
                    root.service.copyImageToClipboard(item.id)
                } else {
                    root.service.copyToClipboard(item.id)
                }
            }
        }
    }

    function next() {
        clipList.currentIndex = Math.min(clipList.currentIndex + 1, clipList.count - 1)
    }

    function prev() {
        clipList.currentIndex = Math.max(clipList.currentIndex - 1, 0)
    }

    function togglePinCurrent() {
        if (clipList.currentIndex >= 0 && root.service) {
            var item = root.service.filteredHistory[clipList.currentIndex]
            if (item) root.service.togglePin(item.id)
        }
    }

    function deleteCurrent() {
        if (clipList.currentIndex >= 0 && root.service) {
            var item = root.service.filteredHistory[clipList.currentIndex]
            if (item) root.service.deleteFromHistory(item.id)
        }
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            if (searchField.text.length > 0) {
                searchField.text = ""
                if (root.service) root.service.searchText = ""
            } else {
                root.closeRequested()
            }
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.selectCurrent()
            event.accepted = true
        } else if (event.key === Qt.Key_Down) {
            clipList.currentIndex = Math.min(clipList.currentIndex + 1, clipList.count - 1)
            event.accepted = true
        } else if (event.key === Qt.Key_Up) {
            clipList.currentIndex = Math.max(clipList.currentIndex - 1, 0)
            event.accepted = true
        } else if (event.key === Qt.Key_F && !event.modifiers) {
            root.togglePinCurrent()
            event.accepted = true
        } else if (event.key === Qt.Key_Delete) {
            if (event.modifiers & Qt.AltModifier) {
                if (root.service) root.service.clearHistory()
            } else {
                root.deleteCurrent()
            }
            event.accepted = true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.dp(12)
        spacing: Theme.dp(12)

        // --- Header Section ---
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(32)
            spacing: Theme.dp(12)

            Text {
                text: "Clipboard History"
                color: Theme.accent
                font.family: Typography.fontFamily
                font.pixelSize: Math.round(14 * s)
                font.weight: Font.Bold
            }

            Rectangle {
                Layout.preferredHeight: Theme.dp(18)
                Layout.preferredWidth: countText.implicitWidth + Theme.dp(12)
                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
                radius: 0
                
                Text {
                    id: countText
                    anchors.centerIn: parent
                    text: root.service ? root.service.totalCount : "0"
                    color: Theme.accent
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
                    font.weight: Font.Bold
                }
            }

            Item { Layout.fillWidth: true }

            // Clear All Button
            Rectangle {
                Layout.preferredWidth: clearText.implicitWidth + Theme.dp(16)
                Layout.preferredHeight: Theme.dp(26)
                color: clearMouse.containsMouse ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.1) : "transparent"
                border.width: 1
                border.color: Theme.danger
                radius: 0

                Text {
                    id: clearText
                    anchors.centerIn: parent
                    text: "Clear All"
                    color: Theme.danger
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(9 * s)
                    font.weight: Font.Medium
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: if (root.service) root.service.clearHistory()
                }
            }
        }

        // --- Search Section ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(40)
            color: Theme.bgPrimary
            border.width: 1
            border.color: searchField.activeFocus ? Theme.accent : Theme.border
            radius: 0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.dp(12)
                anchors.rightMargin: Theme.dp(12)
                spacing: Theme.dp(8)

                Text {
                    text: "search"
                    font.family: Typography.materialSymbols
                    font.styleName: "Regular"
                    color: searchField.activeFocus ? Theme.accent : Theme.textMuted
                    font.pixelSize: Math.round(12 * s)
                    opacity: 0.7
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "Type to search clipboard history..."
                    placeholderTextColor: Theme.textMuted
                    color: Theme.textPrimary
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(11 * s)
                    background: Item {}
                    verticalAlignment: TextInput.AlignVCenter

                    onTextChanged: {
                        if (root.service) {
                            root.service.searchText = text
                            clipList.currentIndex = 0
                        }
                    }

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Down || event.key === Qt.Key_Up || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            event.accepted = false
                        } else if (event.key === Qt.Key_Delete) {
                            if (text.length === 0) {
                                root.deleteCurrent()
                                event.accepted = true
                            }
                        }
                    }
                }
                
                // Clear Search Button
                Rectangle {
                    Layout.preferredWidth: Theme.dp(20)
                    Layout.preferredHeight: Theme.dp(20)
                    color: clearSearchMouse.containsMouse ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.1) : "transparent"
                    radius: 0
                    visible: searchField.text.length > 0
                    
                    Text {
                        anchors.centerIn: parent
                        text: "close"
                        font.family: Typography.materialSymbols
                        font.styleName: "Regular"
                        color: Theme.textMuted
                        font.pixelSize: Math.round(10 * s)
                    }
                    
                    MouseArea {
                        id: clearSearchMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            searchField.text = ""
                            if (root.service) root.service.searchText = ""
                            searchField.forceActiveFocus()
                        }
                    }
                }
            }
        }

        // --- List Section ---
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            clip: true

            ListView {
                id: clipList
                anchors.fill: parent
                model: root.service ? root.service.filteredHistory : []
                currentIndex: 0
                spacing: Theme.dp(4)
                
                delegate: Item {
                    width: clipList.width
                    height: Theme.dp(52)

                    // Swipe Background (Delete)
                    Rectangle {
                        anchors.fill: parent
                        color: Theme.danger
                        opacity: Math.min(0.8, Math.abs(swipeRect.x) / Theme.dp(100))
                        radius: 0
                        z: 1

                        Text {
                            anchors.right: swipeRect.x < 0 ? parent.right : undefined
                            anchors.left: swipeRect.x > 0 ? parent.left : undefined
                            anchors.margins: Theme.dp(16)
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Delete Item"
                            color: "white"
                            font.family: Typography.fontFamily
                            font.pixelSize: Math.round(10 * s)
                            font.weight: Font.Bold
                        }
                    }

                    Rectangle {
                        id: swipeRect
                        x: 0
                        width: parent.width
                        height: parent.height
                        color: clipList.currentIndex === index 
                            ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            : itemMouse.containsMouse 
                                ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.05)
                                : "transparent"
                        border.width: clipList.currentIndex === index ? 1 : 0
                        border.color: Theme.accent
                        radius: 0
                        z: 2

                        Behavior on x {
                            enabled: !dragMouse.drag.active
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.dp(12)
                            anchors.rightMargin: Theme.dp(12)
                            spacing: Theme.dp(12)

                            // Content Preview (Image or Text)
                            Item {
                                Layout.preferredWidth: Theme.dp(38)
                                Layout.preferredHeight: Theme.dp(38)
                                Layout.alignment: Qt.AlignVCenter

                                Rectangle {
                                    anchors.fill: parent
                                    color: clipList.currentIndex === index ? Theme.accentSoft : Theme.bgSecondary
                                    border.width: 1
                                    border.color: clipList.currentIndex === index ? Theme.accent : Theme.border
                                    radius: 0
                                    
                                    Behavior on color { ColorAnimation { duration: 200 } }

                                    // --- Unique Geometric Icons ---
                                    Item {
                                        anchors.fill: parent
                                        opacity: clipList.currentIndex === index ? 1.0 : 0.6

                                        // Text Entry Icon (Abstract Lines)
                                        Column {
                                            anchors.centerIn: parent
                                            spacing: Theme.dp(3)
                                            visible: !modelData.isImage
                                            Rectangle { width: Theme.dp(16); height: Theme.dp(1.5); color: clipList.currentIndex === index ? Theme.accent : Theme.textPrimary }
                                            Rectangle { width: Theme.dp(10); height: Theme.dp(1.5); color: clipList.currentIndex === index ? Theme.accent : Theme.textPrimary; opacity: 0.7 }
                                            Rectangle { width: Theme.dp(14); height: Theme.dp(1.5); color: clipList.currentIndex === index ? Theme.accent : Theme.textPrimary }
                                            Rectangle { width: Theme.dp(8); height: Theme.dp(1.5); color: clipList.currentIndex === index ? Theme.accent : Theme.textPrimary; opacity: 0.5 }
                                        }

                                        // Image Entry Icon (Geometric Composition)
                                        Item {
                                            anchors.centerIn: parent
                                            width: Theme.dp(18); height: Theme.dp(16)
                                            visible: modelData.isImage
                                            
                                            Rectangle { 
                                                anchors.fill: parent; color: "transparent"; 
                                                border.width: 1.5; border.color: clipList.currentIndex === index ? Theme.accent : Theme.textPrimary 
                                            }
                                            
                                            // Stylized "Sun/Focus"
                                            Rectangle {
                                                x: Theme.dp(3); y: Theme.dp(3)
                                                width: Theme.dp(4); height: Theme.dp(4)
                                                radius: width/2
                                                color: clipList.currentIndex === index ? Theme.accent : Theme.textPrimary
                                            }
                                            
                                            // Stylized "Mountain/landscape"
                                            Rectangle {
                                                anchors.bottom: parent.bottom; anchors.right: parent.right
                                                anchors.margins: 1
                                                width: Theme.dp(10); height: Theme.dp(10)
                                                color: clipList.currentIndex === index ? Theme.accent : Theme.textPrimary
                                                opacity: 0.4
                                                rotation: 45
                                            }
                                        }
                                    }
                                }
                            }

                            // Text Preview
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.isImage ? "Image Entry" : (modelData.text.length > 120 ? modelData.text.substring(0, 120).replace(/\n/g, " ") + "..." : modelData.text.replace(/\n/g, " "))
                                    color: Theme.textPrimary
                                    font.family: modelData.isImage ? Typography.fontFamily : "monospace"
                                    font.pixelSize: Math.round(10 * s)
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                    wrapMode: Text.Wrap
                                }
                                
                                Text {
                                    text: modelData.pinned ? "Pinned Item" : "Recently Copied"
                                    color: Theme.textMuted
                                    font.family: Typography.fontFamily
                                    font.pixelSize: Math.round(8 * s)
                                    opacity: 0.6
                                }
                            }
                            
                            // Pin Indicator (Small Dot) - Moved to Right
                            Rectangle {
                                Layout.preferredWidth: Theme.dp(6)
                                Layout.preferredHeight: Theme.dp(6)
                                color: Theme.warning
                                radius: width/2
                                visible: modelData.pinned
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: function(mouse) {
                                clipList.currentIndex = index
                                if (mouse.button === Qt.RightButton) {
                                    if (root.service) root.service.togglePin(modelData.id)
                                } else {
                                    root.selectCurrent()
                                }
                            }
                        }

                        MouseArea {
                            id: dragMouse
                            anchors.fill: parent
                            drag.target: swipeRect
                            drag.axis: Drag.XAxis
                            drag.minimumX: -Theme.dp(120)
                            drag.maximumX: Theme.dp(120)
                            propagateComposedEvents: true

                            onReleased: {
                                if (Math.abs(swipeRect.x) > Theme.dp(80)) {
                                    if (root.service) root.service.deleteFromHistory(modelData.id)
                                    swipeRect.x = 0 // Reset position
                                } else {
                                    swipeRect.x = 0
                                }
                            }
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    id: vbar
                    policy: ScrollBar.AsNeeded
                    width: Theme.dp(4)
                    
                    contentItem: Rectangle {
                        implicitWidth: Theme.dp(4)
                        radius: 0
                        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                    }
                }
            }

            // Empty State
            ColumnLayout {
                anchors.centerIn: parent
                visible: clipList.count === 0
                spacing: Theme.dp(8)
                
                Text {
                    text: "inbox"
                    font.family: Typography.materialSymbols
                    font.styleName: "Regular"
                    font.pixelSize: Math.round(32 * s)
                    Layout.alignment: Qt.AlignHCenter
                    opacity: 0.5
                }
                
                Text {
                    text: root.service && root.service.searchText.length > 0 ? "No matching entries found" : "Your clipboard history is empty"
                    color: Theme.textMuted
                    font.family: Typography.fontFamily
                    font.pixelSize: Math.round(11 * s)
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // --- Footer Navigation Section ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.dp(28)
            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
            radius: 0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.dp(12)
                anchors.rightMargin: Theme.dp(12)
                spacing: Theme.dp(8)

                FooterHint { label: "Nav"; keys: "↑/↓" }
                FooterSeparator {}
                FooterHint { label: "Copy"; keys: "Enter" }
                FooterSeparator {}
                FooterHint { label: "Pin"; keys: "F" }
                FooterSeparator {}
                FooterHint { label: "Del"; keys: "Del" }
                FooterSeparator {}
                FooterHint { label: "All"; keys: "Alt+Del" }
                FooterSeparator {}
                FooterHint { label: "Close"; keys: "Esc" }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: "Clipboard"
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
