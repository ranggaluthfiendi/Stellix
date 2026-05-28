import QtQuick
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    BaseMetric {
        metricName: "GPU MEM"
        stateKey: "GpuMem"
        valueText: {
            if (!sysSvc || sysSvc.gpuMemTotal === 0) return "N/A"
            return Math.round(sysSvc.gpuMemUsage) + "%"
        }
    }
}
