// BrowserDesktop.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtWebEngine 1.9

Item {
    id: root
    anchors.fill: parent

    // portable Konstanten (klein anfangen!)
    readonly property int kLoadStarted:   0
    readonly property int kLoadSucceeded: 1
    readonly property int kLoadFailed:    2

    // öffentliche API
    property alias url: view.url
    signal loadStarted()
    signal loadFinished(bool ok)
    signal loadFailed(string errorString)

    WebEngineView {
        id: view
        anchors.fill: parent

        settings {
            javascriptEnabled: true
            javascriptCanOpenWindows: false
            localStorageEnabled: true
            pluginsEnabled: false
        }

        // Navigation im selben View halten
        onNavigationRequested: function(req) {
            const u = req.url.toString()
            if (u.startsWith("http://") || u.startsWith("https://")) {
                req.accept()
            } else {
                req.reject()
                console.log("[WebEngine] blocked:", u)
            }
        }

        // target=_blank / window.open → im selben View laden
        Connections {
            target: view
            ignoreUnknownSignals: true
            function onNewViewRequested(request)     { if (request?.requestedUrl) view.url = request.requestedUrl }
            function onNewWindowRequested(request)   { if (request?.requestedUrl) view.url = request.requestedUrl }
            function onContextMenuRequested(request) { request.accepted = true }
        }

        // Status numerisch vergleichen (versionssicher)
        onLoadingChanged: (lr) => {
            console.log("[WebEngine] status:", lr.status, "url:", lr.url,
                        "domain:", lr.errorDomain, "code:", lr.errorCode, "err:", lr.errorString)

            if (lr.status === kLoadStarted) {
                root.loadStarted()
            } else if (lr.status === kLoadSucceeded) {
                root.loadFinished(true)
            } else if (lr.status === kLoadFailed) {
                root.loadFinished(false)
                root.loadFailed(lr.errorString || "unknown")
            }
        }
    }

    // API nach außen
    function load(u) { url = u }
    function stop()  { view.stop() }
    function clear() { url = "about:blank" }
}
