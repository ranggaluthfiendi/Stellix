pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Singleton {

    // Global Scale
    property real scaleFactor: 1.0

    // Optional helper
    function dp(x) { return Math.round(x * scaleFactor) }
}
