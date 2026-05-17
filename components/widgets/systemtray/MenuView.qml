import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components.widgets.systemtray
import qs.config

ColumnLayout {
    id: root
    width: implicitWidth
    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height

    property var menu

    signal close()
    signal requestSubmenu(var entry, var anchorItem)

    spacing: Theme.dp(2)

    property int animationTick: 0

    function playOpenAnimation() {
        animationTick++
    }

    QsMenuOpener {
        id: opener
        menu: root.menu
    }

    Repeater {
        id: repeater
        model: opener.children ? opener.children : []

        delegate: Loader {
            id: loader

            required property var modelData
            required property int index

            property bool valid:
                modelData !== null &&
                modelData !== undefined

            active: valid

            sourceComponent: valid && modelData.isSeparator
                ? separatorComponent
                : itemComponent

            Layout.fillWidth: true

            property string reloadKey: modelData ? modelData.toString() : ""
            onReloadKeyChanged: {
                if (active) {
                    active = false
                    active = true
                }
            }

            Connections {
                target: root

                function onAnimationTickChanged() {
                    if (!loader.item) return

                    loader.item.opacity = 0
                    loader.item.y = Theme.dp(10)

                    animDelay.interval = index * 30
                    animDelay.start()
                }
            }

            onLoaded: {
                if (!item) return

                item.opacity = 0
                item.y = Theme.dp(10)

                animDelay.interval = index * 30
                animDelay.start()
            }

            Timer {
                id: animDelay
                interval: 0
                repeat: false

                onTriggered: {
                    if (!loader.item) return
                    loader.item.opacity = 1
                    loader.item.y = 0
                }
            }
        }
    }

    Component {
        id: separatorComponent

        Rectangle {
            height: Theme.dp(1)
            color: Theme.border
            Layout.fillWidth: true
        }
    }

    Component {
        id: itemComponent

        MenuItem {
            entry: modelData

            opacity: 1
            y: 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            onClose: root.close()

            onRequestSubmenu: (entry, anchorItem) => {
                root.requestSubmenu(entry, anchorItem)
            }
        }
    }
}
