import QtQuick
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    BaseMetric {
        metricName: "TEMP"
        stateKey: "Temp"
        valueText: sysSvc && sysSvc.temperature ? sysSvc.temperature : "0°C"
    }
}
