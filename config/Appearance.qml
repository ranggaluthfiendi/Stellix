pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Singleton {

    property real scaleFactor: 1.0

    function dp(x) { return Math.round(x * scaleFactor) }
}
