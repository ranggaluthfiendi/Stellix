import QtQuick

Item {
    id: root

    property string text: "Label"

    property color textColor: "white"
    property color backgroundColor: "#222"

    property real posLeft: NaN
    property real posRight: NaN
    property real posTop: NaN
    property real posBottom: NaN

    property int paddingX: 12
    property int paddingY: 6

    width: label.implicitWidth + paddingX * 2
    height: label.implicitHeight + paddingY * 2

    x: !parent ? 0 :
       !isNaN(posLeft) ? posLeft :
       !isNaN(posRight) ? parent.width - width - posRight :
       (parent.width - width) / 2

    y: !parent ? 0 :
       !isNaN(posTop) ? posTop :
       !isNaN(posBottom) ? parent.height - height - posBottom :
       (parent.height - height) / 2

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: root.backgroundColor

        Text {
            id: label
            text: root.text
            color: root.textColor

            anchors.centerIn: parent
        }
    }
}
