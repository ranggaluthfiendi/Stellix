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
    
    // Internal state for search highlighting
    property string _pendingHighlight: ""
    property int _retryCount: 0

    Timer {
        id: scrollTimer
        interval: 150 // Initial check delay
        repeat: false
        onTriggered: {
            if (root._pendingHighlight !== "") {
                var target = findTargetByTitle(mainLayout, root._pendingHighlight);
                
                // CRITICAL: Check if layout has actually populated and the item has a position
                // If implicitHeight is very low, the page probably isn't ready.
                if (target && mainLayout.implicitHeight > 100) {
                    scrollToItem(target, true);
                    root._pendingHighlight = "";
                    root._retryCount = 0;
                } else if (root._retryCount < 8) { // Up to ~2 seconds of total waiting
                    root._retryCount++;
                    scrollTimer.interval = 200;
                    scrollTimer.restart();
                } else {
                    root._pendingHighlight = "";
                    root._retryCount = 0;
                }
            }
        }
    }

    NumberAnimation {
        id: scrollAnim
        target: flickable
        property: "contentY"
        duration: 600
        easing.type: Easing.OutCubic
    }

    function triggerHighlight(title) {
        if (!title) return;
        root.highlightItem(title)
        root._pendingHighlight = title
        root._retryCount = 0
        scrollTimer.interval = 100
        scrollTimer.restart()
    }

    function scrollToItem(targetChild, force = false) {
        if (!targetChild) return;
        
        // Ensure animation is fresh
        scrollAnim.stop();

        // Map position to the scrollable content area
        var pos = targetChild.mapToItem(flickable.contentItem, 0, 0);
        var absY = pos.y;
        
        var viewHeight = flickable.height;
        var currentScrollY = flickable.contentY;
        var margin = Theme.dp(100); 
        
        // Calculate target scroll position
        var targetScrollY = Math.max(0, absY - margin);
        
        // Use the latest possible contentHeight
        var realContentHeight = Math.max(flickable.height, mainLayout.implicitHeight + root.topPad + root.botPad);
        var maxScroll = Math.max(0, realContentHeight - viewHeight);
        targetScrollY = Math.min(targetScrollY, maxScroll);

        if (force) {
            scrollAnim.to = targetScrollY;
            scrollAnim.start();
        } else {
            // Standard keyboard navigation
            if (absY < currentScrollY + margin) {
                flickable.contentY = Math.max(0, absY - margin);
            } else if (absY + targetChild.height > currentScrollY + viewHeight - margin) {
                flickable.contentY = Math.min(maxScroll, absY + targetChild.height - viewHeight + margin);
            }
        }
    }

    // Comprehensive recursive search for items with title or label
    function findTargetByTitle(container, searchTitle) {
        if (!container || !searchTitle) return null;
        var lowerSearch = searchTitle.toLowerCase().trim();
        
        function checkItem(item) {
            if (!item) return null;
            
            var itemText = "";
            try {
                if (typeof item.title === "string") itemText = item.title;
                else if (typeof item.label === "string") itemText = item.label;
            } catch(e) {}
            
            if (itemText && itemText.toLowerCase().trim() === lowerSearch) {
                return item;
            }
            
            if (item.children) {
                for (var i = 0; i < item.children.length; i++) {
                    var found = checkItem(item.children[i]);
                    if (found) return found;
                }
            }
            return null;
        }
        
        return checkItem(container);
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
        contentHeight: Math.max(height, mainLayout.implicitHeight + root.topPad + root.botPad)
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
        visible: flickable.contentY > Theme.dp(200)
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
        var targetChild = findTargetByIndex(mainLayout, root.focusIndex);
        scrollToItem(targetChild);
    }

    function findTargetByIndex(container, index) {
        if (!container) return null;
        var stack = [container];
        while (stack.length > 0) {
            var item = stack.pop();
            if (!item) continue;
            if (item.hasOwnProperty("itemIndex") && item.itemIndex === index) return item;
            if (item.children) {
                for (var i = 0; i < item.children.length; i++) stack.push(item.children[i]);
            }
        }
        return null;
    }
}
