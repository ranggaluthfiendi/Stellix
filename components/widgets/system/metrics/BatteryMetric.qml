import QtQuick
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    BaseMetric {
        metricName: "BATTERY"
        stateKey: "Battery"
        valueText: {
            if (!sysSvc) return "0%"
            return Math.round(sysSvc.batteryLevel) + "%"
        }
    }
}
