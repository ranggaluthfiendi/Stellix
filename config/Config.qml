pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Singleton {
    // === Features ===
    readonly property bool showClock: true
    readonly property bool showWorkspace: true
    readonly property bool showMenu: true

    // === Clock ===
    readonly property string clockFormat: "hh:mm:ss"

    // === Layout ===
    readonly property bool barTop: true
    readonly property bool barFloating: false

    // === Debug ===
    readonly property bool debug: false
}
