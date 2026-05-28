import QtQuick
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    BaseMetric {
        metricName: "RAM"
        stateKey: "Mem"
        valueText: {
            if (!sysSvc) return "0%"
            return Math.round(sysSvc.memUsage) + "%"
        }
    }
}
