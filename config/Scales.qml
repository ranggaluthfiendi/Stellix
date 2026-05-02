pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Singleton {
    id: root

    property real _uiScale: 1

    property real uiScale: Math.max(1.0, Math.min(2.0, _uiScale))

    function setScale(value) {
        var clamped = Math.max(1.0, Math.min(2.0, value))
        if (clamped === _uiScale)
            return
        _uiScale = clamped
    }

    function increase(step) {
        setScale(_uiScale + (step || 0.1))
    }

    function decrease(step) {
        setScale(_uiScale - (step || 0.1))
    }

    function dp(x) {
        return Math.round(x * uiScale)
    }

    function sp(x) {
        return Math.round(x * uiScale)
    }

    function px(x) {
        return x * uiScale
    }
}
