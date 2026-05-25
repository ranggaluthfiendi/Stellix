import QtQuick
import qs.services

Item {
    id: root

    BaseMetric {
        metricName: "TEMP"
        stateKey: "Temp"
        valueText: sysSvc && sysSvc.temperature ? sysSvc.temperature : "0°C"
    }
}
