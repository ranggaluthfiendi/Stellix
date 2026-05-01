pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Singleton {
    readonly property bool showClock: true
    readonly property bool showWorkspace: true
    readonly property bool showMenu: true

    readonly property string clockFormat: "hh:mm:ss"

    readonly property bool barTop: true
    readonly property bool barFloating: false

    readonly property bool debug: false
}
