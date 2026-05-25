import QtQuick

Item {
    id: root

    function calculate(expr) {
        try {
            var sanitized = expr.replace(/[^0-9+\-*/().%\s]/g, "")
            if (sanitized.length === 0) return null
            var result = eval(sanitized)
            return result
        } catch (e) {
            return null
        }
    }
}
