import QtQuick
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    BaseMetric {
        metricName: "PROCESS"
        stateKey: "Process"
        valueText: {
            if (!sysSvc) return "0"
            return sysSvc.processCount.toString()
        }
    }
}
