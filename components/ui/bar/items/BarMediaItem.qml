import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core.services
import qs.core.state
import qs.core.settings
import qs.config
import qs.components.widgets.barpopup

Item {
    id: root

    property real s: Scales.uiScale

    implicitHeight: BarLayoutState.barHeight * s
    implicitWidth: styleLoader.item ? styleLoader.item.width : Theme.dp(20)

    readonly property var mprisService: BarLayoutState.getItem("mprisService")
    readonly property bool hasMedia: mprisService ? mprisService.hasPlayer : false
    readonly property bool isPlaying: mprisService ? mprisService.isPlaying : false
    readonly property string title: mprisService ? mprisService.title : ""
    readonly property string artist: mprisService ? mprisService.artist : ""
    readonly property string artUrl: mprisService ? mprisService.artUrl : ""

    property bool expanded: false

    Loader {
        id: styleLoader
        anchors.verticalCenter: parent.verticalCenter
        source: {
            switch (BarLayoutState.barMediaStyle) {
                case "compact": return Qt.resolvedUrl("media/CompactStyle.qml")
                case "icon": return Qt.resolvedUrl("media/IconStyle.qml")
                case "expandable": return Qt.resolvedUrl("media/ExpandableStyle.qml")
                default: return Qt.resolvedUrl("media/CompactStyle.qml")
            }
        }
        onLoaded: {
            if (item) {
                item.s = root.s
                item.rootItem = root
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        visible: BarLayoutState.barMediaStyle !== "expandable"

        onClicked: {
            BarPopupState.mediaPopupOpen = !BarPopupState.mediaPopupOpen
        }
    }

    PanelWindow {
        id: mediaPanel
        visible: BarPopupState.mediaPopupOpen
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.exclusiveZone: -1

        anchors {
            top: !BarLayoutState.isBottom
            bottom: BarLayoutState.isBottom
            left: true
            right: true
        }

        implicitWidth: Theme.dp(372)
        implicitHeight: mediaContent.implicitHeight

        readonly property real screenW: mediaPanel.screen ? mediaPanel.screen.width : 1920
        readonly property real centerMargin: Math.max(0, (screenW - mediaPanel.implicitWidth) / 2)

        readonly property string mediaSection: BarLayoutState.findItemSection("media")
        readonly property bool isLeftMedia: mediaSection === "left"
        readonly property bool isCenterMedia: mediaSection === "center"
        readonly property bool isRightMedia: mediaSection === "right"

        margins.left: isLeftMedia ? Theme.dp(5) : (isCenterMedia ? centerMargin : screenW - mediaPanel.implicitWidth - Theme.dp(5))
        margins.right: isLeftMedia ? screenW - mediaPanel.implicitWidth - Theme.dp(5) : (isCenterMedia ? centerMargin : Theme.dp(5))
        margins.top: !BarLayoutState.isBottom ? (BarLayoutState.barHeight * s + Theme.dp(4)) : 0
        margins.bottom: BarLayoutState.isBottom ? (BarLayoutState.barHeight * s + Theme.dp(4)) : 0

        Rectangle {
            id: mediaBg
            anchors.fill: parent
            color: Theme.bgSecondary
            border.width: 1
            border.color: Theme.border
            radius: BarLayoutState.barPopupRounded ? Theme.radiusMedium : 0

            property real animOpacity: 0
            opacity: animOpacity

            states: State {
                name: "visible"
                when: mediaPanel.visible
                PropertyChanges { target: mediaBg; animOpacity: 1 }
            }

            transitions: [
                Transition {
                    from: ""
                    to: "visible"
                    NumberAnimation { target: mediaBg; property: "animOpacity"; duration: 180; easing.type: Easing.OutCubic }
                },
                Transition {
                    from: "visible"
                    to: ""
                    NumberAnimation { target: mediaBg; property: "animOpacity"; duration: 140; easing.type: Easing.InCubic }
                }
            ]

            BarMediaPopup {
                id: mediaContent
                anchors.fill: parent
                mprisService: root.mprisService
                s: root.s
            }
        }
    }
}
