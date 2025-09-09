import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebView 1.1

Item {
    id: root
    anchors.fill: parent

    property alias url: view.url
    signal loadStarted()
    signal loadFinished(bool ok)
    signal loadFailed(string errorString)

    WebView {
        id: view
        anchors.fill: parent

        Component.onCompleted: console.log("[BrowserIOS] up. url:", view.url)

        onLoadingChanged: function(req) {
            if (req.status === WebView.LoadStartedStatus) {
                console.log("[BrowserIOS] load started:", (req.url || ""))
                root.loadStarted()
                // Nur leichte Logik; evtl. fragwürdige URLs sanft stoppen
                Qt.callLater(function() {
                    const u = (req.url || "").toString()
                    if (u && !u.startsWith("http")) delayedStop.restart()
                })
            } else if (req.status === WebView.LoadSucceededStatus) {
                console.log("[BrowserIOS] load ok")
                root.loadFinished(true)
            } else if (req.status === WebView.LoadFailedStatus) {
                console.log("[BrowserIOS] load failed:", req.errorString)
                root.loadFinished(false)
                root.loadFailed(req.errorString || "unknown")
            }
        }

        Timer {
            id: delayedStop
            interval: 50
            repeat: false
            onTriggered: view.stop()
        }
    }

    function load(u) { url = u }
    function stop()  { view.stop() }
    function clear() {
        // Kein view.stop() → vermeidet "connection invalid" beim frühen Load
        Qt.callLater(function(){ url = "about:blank" })
    }
}
