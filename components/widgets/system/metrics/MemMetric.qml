import QtQuick
import qs.services

Item {
    id: root

    BaseMetric {
        metricName: "RAM"
        stateKey: "Mem"
        valueText: sysSvc ? (Math.round(sysSvc.memUsed / 1024) + " GB") : "0 GB"
    }
}
