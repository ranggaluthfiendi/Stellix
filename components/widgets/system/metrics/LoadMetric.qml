import QtQuick
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    BaseMetric {
        metricName: "LOAD"
        stateKey: "Load"
        valueText: {
            if (!sysSvc) return "0.00"
            return sysSvc.loadAvg1
        }
    }
}
