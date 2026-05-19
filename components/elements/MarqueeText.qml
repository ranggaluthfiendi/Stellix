import QtQuick
import qs.config

Item {
    id: root
    property string text: ""
    property color textColor: Theme.textPrimary
    property real fontSize: Typography.sizeXXS || 9
    property real fontScale: Scales.uiScale
    property int fontWeight: Typography.weightRegular || Font.Normal
    property bool scrolling: true
    property real textPadding: Theme.dp(8)

    implicitHeight: textItem.implicitHeight

    readonly property real textWidth: textItem.implicitWidth

    clip: true

    property real scrollOffset: 0

    Text {
        id: textItem
        anchors.verticalCenter: parent.verticalCenter
        x: root.needsScroll ? scrollOffset : root.textPadding
        text: root.textPadding > 0 ? "  " + root.text + "  " : root.text
        color: root.textColor
        font.family: Typography.fontFamily
        font.pixelSize: Math.round(root.fontSize * root.fontScale)
        font.weight: root.fontWeight
    }

    Text {
        id: textItem2
        anchors.verticalCenter: parent.verticalCenter
        x: scrollOffset + textItem.implicitWidth
        text: root.textPadding > 0 ? "   " + root.text + "   " : root.text
        color: root.textColor
        font.family: Typography.fontFamily
        font.pixelSize: Math.round(root.fontSize * root.fontScale)
        font.weight: root.fontWeight
        visible: root.needsScroll
    }

    property bool needsScroll: false

    NumberAnimation {
        id: scrollAnim
        target: root
        property: "scrollOffset"
        running: false
        from: 0
        to: -1
        duration: 5000
        easing.type: Easing.Linear
        loops: Animation.Infinite
    }

    function checkOverflow() {
        scrollAnim.stop()
        root.scrollOffset = 0

        root.needsScroll = root.scrolling && textItem.implicitWidth > root.width + 4
        if (root.needsScroll) {
            scrollAnim.from = 0
            scrollAnim.to = -textItem.implicitWidth
            scrollAnim.duration = Math.max(8000, textItem.implicitWidth * 80)
            scrollAnim.start()
        }
    }

    Component.onCompleted: Qt.callLater(checkOverflow)
    onTextChanged: Qt.callLater(checkOverflow)
    onWidthChanged: Qt.callLater(checkOverflow)
}
