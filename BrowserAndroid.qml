import QtQuick 2.15
import QtWebView 1.1

Item {
    id: root
    anchors.fill: parent
    visible: true      // Loader steuert Sichtbarkeit
    z: 9999

    // URL Schnittstelle
    property string url: ""
    signal loadStarted()
    signal loadFinished(bool ok)
    signal loadFailed(string errorString)

    Rectangle {
        anchors.fill: parent
        color: "#20000000"   // Debug: leicht dunkler Hintergrund
        z: -1
    }

    Component.onCompleted: {
        console.log("[Android Web] ROOT completed:", width, height)
        Qt.callLater(applyUrl)
    }

    WebView {
        id: web
        anchors.fill: parent

        Component.onCompleted: {
            console.log("[Android Web] WebView completed:", width, height)
            Qt.callLater(applyUrl)
        }

        onLoadingChanged: function(req) {
            if (req.status === WebView.LoadStartedStatus) {
                console.log("[Android Web] load started:", req.url)
                root.loadStarted()
            }
            if (req.status === WebView.LoadSucceededStatus) {
                console.log("[Android Web] load OK")
                root.loadFinished(true)
            }
            if (req.status === WebView.LoadFailedStatus) {
                console.log("[Android Web] load FAILED:", req.errorString)
                root.loadFailed(req.errorString)
            }
        }
    }

    function applyUrl() {
        if (!url || url.length === 0)
            return

        console.log("[Android Web] applying URL:", url)

        // Kritisch: URL erst NACH Sichtbarkeit setzen
        Qt.callLater(() => {
            web.url = url
        })
    }

    function load(u) {
        url = u
        applyUrl()
    }

    function clear() {
        // kein Stop! → verhindert „connection invalid“
        url = "about:blank"
        Qt.callLater(() => web.url = "about:blank")
    }
}
