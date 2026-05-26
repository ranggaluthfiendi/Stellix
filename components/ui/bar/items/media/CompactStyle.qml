import QtQuick
import QtQuick.Layouts
import qs.config
import qs.core.state
import qs.components.utils

Item {
    id: root

    property real s: 1.0
    property var rootItem: null

    height: Theme.dp(32)
    width: contentRow.implicitWidth + Theme.dp(8)

    readonly property var mprisService: rootItem ? rootItem.mprisService : null
    readonly property bool hasMedia: rootItem ? rootItem.hasMedia : false
    readonly property bool isPlaying: rootItem ? rootItem.isPlaying : false
    readonly property string title: rootItem ? rootItem.title : ""
    readonly property string artist: rootItem ? rootItem.artist : ""
    readonly property string artUrl: rootItem ? rootItem.artUrl : ""

    readonly property var elementOrder: BarLayoutState.barMediaElementOrder

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: Theme.dp(6)

        Repeater {
            model: root.elementOrder

            Loader {
                Layout.alignment: Qt.AlignVCenter
                required property string modelData

                visible: !BarLayoutState.isMediaElementHidden(modelData)

                sourceComponent: {
                    switch (modelData) {
                        case "art": return artComp
                        case "text": return textComp
                        default: return null
                    }
                }
            }
        }
    }

    Component {
        id: artComp
        Rectangle {
            width: Theme.dp(18)
            height: Theme.dp(18)
            radius: Theme.dp(2)
            color: Theme.bgPrimary

            Image {
                id: artImage
                anchors.fill: parent
                anchors.margins: Theme.dp(2)
                source: root.hasMedia && root.artUrl ? root.artUrl : ""
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                visible: !artImage.visible
                text: "♪"
                color: Theme.accent
                font.pixelSize: Math.round(10 * root.s)
            }
        }
    }

    Component {
        id: textComp
        Item {
            width: Theme.dp(80)
            height: Theme.dp(18)

            MarqueeText {
                anchors.fill: parent
                text: root.hasMedia ? root.title + (root.artist ? " - " + root.artist : "") : "No media"
                textColor: Theme.textPrimary
                fontSize: 9
                fontScale: root.s
                scrolling: true
                textPadding: 0
            }
        }
    }
}
