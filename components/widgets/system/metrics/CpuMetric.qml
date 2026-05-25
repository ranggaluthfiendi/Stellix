import QtQuick
import qs.services

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
