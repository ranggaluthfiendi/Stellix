import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.config

Slider {
    id: sl
    property bool muted: false
    
    // Allow external layout control
    Layout.fillWidth: true
    Layout.minimumWidth: Theme.dp(100)
    Layout.maximumWidth: Theme.dp(300)
    Layout.preferredWidth: Theme.dp(200)
    Layout.preferredHeight: Theme.dp(24)
    stepSize: 0.02
    
    background: Rectangle {
        x: sl.leftPadding
        y: sl.topPadding + sl.availableHeight/2 - height/2
        width: sl.availableWidth
        height: Theme.dp(4)
        color: Theme.border
        radius: 0 
        Rectangle {
            width: sl.visualPosition * parent.width
            height: parent.height
            color: sl.muted ? Theme.danger : Theme.accent 
            radius: 0 
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }
    handle: Rectangle {
        x: sl.leftPadding + sl.visualPosition * (sl.availableWidth - width)
        y: sl.topPadding + sl.availableHeight/2 - height/2
        width: Theme.dp(16)
        height: Theme.dp(16)
        color: sl.muted ? Theme.danger : Theme.accent
        border.width: 2
        border.color: Theme.bgPrimary
        radius: 0 
        Behavior on color { ColorAnimation { duration: 200 } }
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.NoButton // Important: Let clicks pass to the Slider handle/track
        onWheel: function(wheel) {
            var step = (wheel.angleDelta.y > 0) ? 0.05 : -0.05
            sl.value = Math.min(sl.to, Math.max(sl.from, sl.value + step))
            sl.moved()
        }
    }
}
