import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Rectangle {
    id: root
    property string title: ""
    property string desc: ""
    property int itemIndex: -1
    property bool isFocused: false
    
    // Highlight logic
    property bool isHighlighted: false
    Timer {
        id: highlightTimer
        interval: 2000
        onTriggered: root.isHighlighted = false
    }
    
    function highlight() {
        root.isHighlighted = true
        highlightTimer.restart()
    }

    Connections {
        target: {
            var p = root.parent
            while (p && !p.hasOwnProperty("highlightItem")) {
                p = p.parent
            }
            return p
        }
        ignoreUnknownSignals: true
        function onHighlightItem(targetTitle) {
            if (targetTitle === root.title) {
                root.highlight()
            }
        }
    }
    
    // Separate aliases for header actions and main content
    property alias headerActions: headerActionsContainer.data
    default property alias content: mainContentContainer.data
    
    Layout.fillWidth: true
    implicitHeight: mainLayout.implicitHeight + Theme.dp(24)
    color: root.isHighlighted ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : (isFocused ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : Theme.bgSecondary)
    border.width: 1
    border.color: root.isHighlighted || isFocused ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.4)
    radius: 0

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.leftMargin: Theme.dp(16)
        anchors.rightMargin: Theme.dp(16)
        anchors.topMargin: Theme.dp(12)
        anchors.bottomMargin: Theme.dp(12)
        spacing: Theme.dp(12)

        // Top Row: Title/Desc on Left, Header Actions on Right
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.dp(16)
            
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: Theme.dp(2)

                Text {
                    text: root.title
                    color: Theme.textPrimary
                    font.pixelSize: Theme.dp(12)
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: root.desc
                    color: Theme.textMuted
                    font.pixelSize: Theme.dp(10)
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    visible: root.desc !== ""
                }
            }
            
            // Spacer to push actions to the right
            Item { Layout.fillWidth: true; Layout.minimumWidth: Theme.dp(10) }
            
            RowLayout {
                id: headerActionsContainer
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                spacing: Theme.dp(10)
                // Important: children will be buttons, switches, etc.
            }
        }

        // Bottom Area: Main content (Sliders, etc.) - Full Width
        ColumnLayout {
            id: mainContentContainer
            Layout.fillWidth: true
            spacing: Theme.dp(8)
            visible: mainContentContainer.children.length > 0
        }
    }
}
