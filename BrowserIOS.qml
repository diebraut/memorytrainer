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

        // iOS: im selben View bleiben
        onNewViewRequested: function(req) { if (req?.url) view.url = req.url }
        onNavigationRequested: function(req) {
            const u = req.url.toString()
            if (u.startsWith("http")) req.action = WebView.AcceptRequest
            else { req.action = WebView.IgnoreRequest; console.log("[WebView] blocked:", u) }
        }

        onLoadingChanged: function(ev) {
            if (ev.status === WebView.LoadStartedStatus) root.loadStarted()
            else if (ev.status === WebView.LoadSucceededStatus) root.loadFinished(true)
            else if (ev.status === WebView.LoadFailedStatus) { root.loadFinished(false); root.loadFailed(ev.errorString||"unknown") }
        }
    }

    function load(u) { url = u }
    function stop()  { view.stop() }
    function clear() { url = "about:blank" }
}
