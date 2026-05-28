import QtQuick
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings

Item {
    id: root

    BaseMetric {
        metricName: "GPU"
        stateKey: "Gpu"
        valueText: {
            if (!sysSvc || sysSvc.gpus.length === 0) return "N/A"
            for (var i = 0; i < sysSvc.gpus.length; i++) {
                var gpu = sysSvc.gpus[i]
                if (gpu.includes("NVIDIA") && gpu.includes("%")) {
                    var parts = gpu.split(":")
                    if (parts.length >= 2) return parts[1].trim()
                }
            }
            for (var j = 0; j < sysSvc.gpus.length; j++) {
                if (sysSvc.gpus[j].includes("%")) return sysSvc.gpus[j]
            }
            return "N/A"
        }
    }
}
