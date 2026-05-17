pragma ComponentBehavior: Bound;

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.config

Item {
    id: root

    property int wsBaseIndex: 1
    property int wsCount: 5
    property int scrollAccumulator: 0
    property int currentIndex: 1

    property var workspacesWithClients: []

    width: Scales.dp(90)
    height: Scales.dp(24)

    Process {
        id: clientsProc
        command: ["hyprctl", "clients", "-j"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let clients = JSON.parse(text)
                    let result = []

                    for (let i = 0; i < clients.length; i++) {
                        let wsId = clients[i].workspace.id
                        if (!result.includes(wsId))
                            result.push(wsId)
                    }

                    root.workspacesWithClients = result
                } catch (e) {
                    root.workspacesWithClients = []
                }
            }
        }
    }

    Timer {
        interval: 400
        running: true
        repeat: true
        onTriggered: {
            if (!clientsProc.running)
                clientsProc.running = true
        }
    }

    function hasWindows(wsId) {
        return workspacesWithClients.includes(wsId)
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton

        onWheel: event => {
            event.accepted = true

            let acc = root.scrollAccumulator - event.angleDelta.y
            const sign = Math.sign(acc)
            acc = Math.abs(acc)

            const offset = sign * Math.floor(acc / 120)
            root.scrollAccumulator = sign * (acc % 120)

            if (offset !== 0) {
                const ws = Hyprland.focusedWorkspace
                if (!ws) return
                Hyprland.dispatch(`workspace ${Math.max(1, ws.id + offset)}`)
            }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: Scales.dp(5)

        Repeater {
            model: root.wsCount

            Item {
                id: wsItem
                required property int index

                property int wsId: root.wsBaseIndex + index
                property var workspace: null

                property bool active: workspace?.active ?? false
                property bool hasWin: root.hasWindows(wsId)

                width: Scales.dp(12)
                height: Scales.dp(12)

                Component.onCompleted: {
                    const ws = Hyprland.workspaces.values.find(w => w.id === wsId)
                    if (ws) workspace = ws
                }

                Connections {
                    target: Hyprland.workspaces
                    function onObjectInsertedPost(ws) {
                        if (ws.id === wsItem.wsId)
                            wsItem.workspace = ws
                    }
                }

                onActiveChanged: {
                    if (active) root.currentIndex = wsId
                }

                Rectangle {
                    id: box
                    anchors.centerIn: parent
                    width: Scales.dp(active ? 12 : 6)
                    height: Scales.dp(active ? 12 : 6)
                    radius: Scales.dp(3)

                    color: {
                        if (active && hasWin)
                            return Theme.accent
                        if (active && !hasWin)
                            return Qt.rgba(
                                Theme.accent.r,
                                Theme.accent.g,
                                Theme.accent.b,
                                0.4
                            )
                        if (!active && hasWin)
                            return Theme.textPrimary
                        return "transparent"
                    }

                    border.width: (!active && !hasWin) ? Scales.dp(1) : 0
                    border.color: Theme.textPrimary

                    Behavior on width {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    Behavior on height {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }
                    Behavior on radius {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                }

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    onClicked: Hyprland.dispatch(`workspace ${wsId}`)
                }
            }
        }
    }
}
