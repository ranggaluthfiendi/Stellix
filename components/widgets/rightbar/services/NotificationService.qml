import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    property int notifCount: 0

    readonly property var trackedNotifs: notifServer.trackedNotifications && notifServer.trackedNotifications.values
        ? notifServer.trackedNotifications.values
        : []
    readonly property var latestNotif: notifCount > 0 ? trackedNotifs[notifCount - 1] : null

    NotificationServer {
        id: notifServer
        actionsSupported: true
        bodySupported: true
        persistenceSupported: true
        keepOnReload: true
        imageSupported: true

        onNotification: function(notification) {
            notification.tracked = true
        }
    }

    onTrackedNotifsChanged: root.notifCount = trackedNotifs.length

    function formatNotifTime(ts) {
        if (!ts) return ""
        var d = new Date(ts * 1000)
        var now = new Date()
        var diff = Math.floor((now - d) / 1000)
        if (diff < 60) return "Just now"
        if (diff < 3600) return Math.floor(diff / 60) + "m ago"
        if (diff < 86400) return Math.floor(diff / 3600) + "h ago"
        var day = d.getDate()
        var month = d.getMonth() + 1
        var hours = d.getHours()
        var mins = d.getMinutes()
        return day + "/" + month + " " + hours + ":" + (mins < 10 ? "0" : "") + mins
    }

    function dismissAll() {
        var arr = root.trackedNotifs || []
        for (var i = 0; i < arr.length; i++) {
            if (!arr[i]) continue
            try { arr[i].dismiss() } catch (e) {}
        }
    }

    function dismissOne(n) {
        if (!n) return
        try { n.dismiss() } catch (e) {}
    }
}
