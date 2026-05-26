pragma ComponentBehavior: Bound;

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.config
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    readonly property int focusedId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    readonly property int wsCount: BarLayoutState.workspaceCount

    property int wsBaseIndex: {
        if (focusedId <= wsCount) return 1;
        return focusedId - wsCount + 1;
    }
    
    property int scrollAccumulator: 0
    property int currentIndex: 1

    property var workspacesWithClients: []

    implicitWidth: wsRow.implicitWidth
    implicitHeight: Scales.dp(24)

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
        id: wsRow
        anchors.centerIn: parent
        spacing: Scales.dp(BarLayoutState.workspaceSpacing)

        Repeater {
            model: root.wsCount

            Item {
                id: wsItem
                required property int index

                property int wsId: root.wsBaseIndex + index
                property var workspace: null

                property bool active: workspace?.active ?? false
                property bool hasWin: root.hasWindows(wsId)
                property bool shouldShow: BarLayoutState.workspaceShowEmpty || hasWin || active

                visible: shouldShow
                width: {
                    if (BarLayoutState.workspaceStyle === "pills") return active ? Scales.dp(BarLayoutState.workspaceActiveDotSize * 2) : Scales.dp(BarLayoutState.workspaceDotSize)
                    return Scales.dp(BarLayoutState.workspaceActiveDotSize)
                }
                height: root.height

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
                    
                    width: {
                        if (BarLayoutState.workspaceStyle === "pills") return active ? Scales.dp(BarLayoutState.workspaceActiveDotSize * 2) : Scales.dp(BarLayoutState.workspaceDotSize)
                        if (BarLayoutState.workspaceStyle === "lines") return Scales.dp(active ? BarLayoutState.workspaceActiveDotSize : BarLayoutState.workspaceDotSize)
                        if (BarLayoutState.workspaceStyle === "numbers") return Scales.dp(20)
                        return Scales.dp(active ? BarLayoutState.workspaceActiveDotSize : BarLayoutState.workspaceDotSize)
                    }
                    
                    height: {
                        if (BarLayoutState.workspaceStyle === "lines") return Scales.dp(2)
                        if (BarLayoutState.workspaceStyle === "numbers") return Scales.dp(20)
                        if (BarLayoutState.workspaceStyle === "dots") return Scales.dp(active ? BarLayoutState.workspaceActiveDotSize : BarLayoutState.workspaceDotSize)
                        return Scales.dp(BarLayoutState.workspaceDotSize)
                    }
                    
                    radius: {
                        if (BarLayoutState.workspaceStyle === "geometric") return 0
                        if (BarLayoutState.workspaceStyle === "pills") return height / 2
                        if (BarLayoutState.workspaceStyle === "dots") return active ? Scales.dp(BarLayoutState.workspaceRadius * 2) : Scales.dp(BarLayoutState.workspaceRadius)
                        return Scales.dp(BarLayoutState.workspaceRadius)
                    }
                    rotation: BarLayoutState.workspaceStyle === "geometric" ? 45 : 0

                    color: {
                        if (BarLayoutState.workspaceStyle === "dots") {
                            if (wsMouse.containsMouse) {
                                if (active && hasWin)
                                    return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85)
                                if (active && !hasWin)
                                    return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.6)
                                if (!active && hasWin)
                                    return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35)
                                return Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.15)
                            }
                            if (active && hasWin)
                                return Theme.accent
                            if (active && !hasWin)
                                return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4)
                            if (!active && hasWin)
                                return Theme.textPrimary
                            return "transparent"
                        }

                        let baseColor = Theme.textMuted
                        if (active) {
                            if (BarLayoutState.workspaceActiveColorMode === "accent") baseColor = Theme.accent
                            else if (BarLayoutState.workspaceActiveColorMode === "success") baseColor = Theme.success
                            else baseColor = Theme.textPrimary
                        } else if (hasWin) {
                            if (BarLayoutState.workspaceHasWinColorMode === "accent") baseColor = Theme.accent
                            else if (BarLayoutState.workspaceHasWinColorMode === "text_muted") baseColor = Theme.textMuted
                            else baseColor = Theme.textPrimary
                        }

                        if (wsMouse.containsMouse) return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.8)
                        
                        if (!active && !hasWin) return "transparent"
                        
                        return baseColor
                    }

                    border.width: (!active && !hasWin) ? Scales.dp(1) : 0
                    border.color: BarLayoutState.workspaceStyle === "dots" ? Theme.textPrimary : Theme.textMuted

                    Text {
                        anchors.centerIn: parent
                        visible: BarLayoutState.workspaceShowNumbers || BarLayoutState.workspaceStyle === "numbers"
                        text: wsItem.wsId.toString()
                        color: active ? Theme.bgPrimary : Theme.textPrimary
                        font.pixelSize: Scales.dp(10)
                        font.weight: Font.Bold
                        rotation: -parent.rotation
                    }

                    Behavior on width {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }
                    Behavior on height {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }
                    Behavior on radius {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    // Nerves style extra lines
                    Rectangle {
                        visible: BarLayoutState.workspaceStyle === "nerves" && active
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.bottom
                        anchors.topMargin: Scales.dp(2)
                        width: parent.width * 0.6
                        height: Scales.dp(1)
                        color: Theme.accent
                    }
                }

                MouseArea {
                    id: wsMouse
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    hoverEnabled: true
                    onClicked: Hyprland.dispatch(`workspace ${wsId}`)
                }
            }
        }
    }
}
