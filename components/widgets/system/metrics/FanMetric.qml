import QtQuick
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    BaseMetric {
        metricName: "FAN"
        stateKey: "Fan"
        valueText: {
            if (!sysSvc) return "0 RPM"
            return sysSvc.fanSpeedText
        }
    }
}
