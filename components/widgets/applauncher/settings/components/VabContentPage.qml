import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config

Item {
    id: root
    property int focusIndex: 0
    property bool active: false
    
    signal highlightItem(string title)
    
    function triggerHighlight(title) {
        root.highlightItem(title)
    }

    Layout.fillWidth: true
    Layout.fillHeight: true
    
    // Alias content to mainLayout so pages can add items
    default property alias content: mainLayout.data

    readonly property real topPad: Theme.dp(24)
    readonly property real botPad: Theme.dp(48)
    readonly property real sidePad: Theme.dp(48)

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: mainLayout.implicitHeight + root.topPad + root.botPad
        clip: true
        interactive: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        
        ScrollBar.vertical: ScrollBar { 
            id: vBar
            width: Theme.dp(6)
            policy: ScrollBar.AsNeeded
            anchors.right: parent.right
            anchors.rightMargin: Theme.dp(4)
            background: Rectangle { color: "transparent" }
            contentItem: Rectangle {
                color: vBar.pressed ? Theme.accent : (vBar.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.6) : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.4))
                radius: 0
            }
        }

        ColumnLayout {
            id: mainLayout
            width: flickable.width - (root.sidePad * 2)
            anchors.top: parent.top
            anchors.topMargin: root.topPad
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.dp(16)
        }
    }

    // --- Back to Top Indicator ---
    Rectangle {
        id: backToTop
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.dp(24)
        anchors.horizontalCenter: parent.horizontalCenter
        width: Theme.dp(120); height: Theme.dp(32)
        color: bttMouse.containsMouse ? Theme.accent : Qt.rgba(Theme.bgPrimary.r, Theme.bgPrimary.g, Theme.bgPrimary.b, 0.95)
        border.width: 1; border.color: Theme.accent; radius: 0
        visible: flickable.contentY > Theme.dp(400)
        opacity: visible ? 1 : 0
        z: 100

        Behavior on opacity { NumberAnimation { duration: 200 } }
        Behavior on color { ColorAnimation { duration: 150 } }

        RowLayout {
            anchors.centerIn: parent; spacing: 8
            Text { text: "↑"; color: bttMouse.containsMouse ? Theme.bgPrimary : Theme.accent; font.pixelSize: Theme.dp(14); font.weight: Font.Bold }
            Text { text: "BACK TO TOP"; color: bttMouse.containsMouse ? Theme.bgPrimary : Theme.textPrimary; font.pixelSize: Theme.dp(9); font.weight: Font.Bold; font.capitalization: Font.AllUppercase }
        }

        MouseArea {
            id: bttMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: flickable.contentY = 0
        }
    }

    // Auto-scroll logic for keyboard navigation
    onFocusIndexChanged: {
        if (!active) return;
        
        function findTarget(container) {
            for (var i = 0; i < container.children.length; i++) {
                var child = container.children[i];
                if (child && child.hasOwnProperty("itemIndex") && child.itemIndex === root.focusIndex) {
                    return child;
                }
                if (child && child.children && child.children.length > 0) {
                    var sub = findTarget(child);
                    if (sub) return sub;
                }
            }
            return null;
        }
        
        var targetChild = findTarget(mainLayout);
        
        if (targetChild) {
            var relY = targetChild.mapToItem(mainLayout, 0, 0).y + root.topPad;
            var viewHeight = flickable.height;
            var currentScrollY = flickable.contentY;
            var margin = Theme.dp(40);
            
            if (relY < currentScrollY + margin) {
                flickable.contentY = Math.max(0, relY - margin);
            } else if (relY + targetChild.height > currentScrollY + viewHeight - margin) {
                flickable.contentY = Math.min(flickable.contentHeight - viewHeight, relY + targetChild.height - viewHeight + margin);
            }
        }
    }
}
