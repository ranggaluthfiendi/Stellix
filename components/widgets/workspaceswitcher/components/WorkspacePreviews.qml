import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Item {
    id: previewsArea
    required property var wsService
    required property var popup
    required property real previewH

    Layout.fillWidth: true
    Layout.preferredHeight: previewH

    Row {
        anchors.centerIn: parent
        spacing: wsService.previewGap

        Repeater {
            id: wsPreviewsRepeater
            model: wsService.workspaceIdList

            delegate: WorkspacePreview {
                required property int modelData
                wsId: modelData
                wsService: previewsArea.wsService
                popup: previewsArea.popup
                previewsRepeater: wsPreviewsRepeater
            }
        }
    }
}
