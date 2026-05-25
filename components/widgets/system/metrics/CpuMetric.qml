import QtQuick
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    BaseMetric {
        metricName: "CPU"
        stateKey: "Cpu"
        valueText: {
            if (!sysSvc) return "0%"
            return (Math.round(sysSvc.cpuCount * 4) + "%")
        }
    }
}
