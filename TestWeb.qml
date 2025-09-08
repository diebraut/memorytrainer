// TestWeb.qml
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtWebEngine 1.9

Window {
    width: 1000
    height: 700
    visible: true
    title: "Embedded Web Test (Desktop)"

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TextField {
                id: urlEdit
                text: "https://www.wikipedia.org"
                Layout.fillWidth: true
            }
            Button {
                text: "Load"
                onClicked: view.url = urlEdit.text
            }
        }

        WebEngineView {
            id: view
            Layout.fillWidth: true
            Layout.fillHeight: true

            settings {
                javascriptEnabled: true
                javascriptCanOpenWindows: false
                localStorageEnabled: true
                pluginsEnabled: false
            }

            onNavigationRequested: function(req) {
                const u = req.url.toString()
                if (u.startsWith("http://") || u.startsWith("https://")) {
                    req.accept()
                } else {
                    req.reject()
                    console.log("[WebEngine] blocked non-http scheme:", u)
                }
            }

            Connections {
                target: view
                ignoreUnknownSignals: true

                function onNewViewRequested(request) {
                    if (request && request.requestedUrl) {
                        console.log("[WebEngine] newViewRequested:", request.requestedUrl)
                        view.url = request.requestedUrl
                    }
                }
                function onNewWindowRequested(request) {
                    if (request && request.requestedUrl) {
                        console.log("[WebEngine] newWindowRequested:", request.requestedUrl)
                        view.url = request.requestedUrl
                    }
                }
                function onContextMenuRequested(request) {
                    request.accepted = true
                }
            }

            onLoadingChanged: (lr) => {
                console.log("[WebEngine] status:", lr.status,
                            "url:", lr.url,
                            "domain:", lr.errorDomain,
                            "code:", lr.errorCode,
                            "err:", lr.errorString)
            }

            // Fortschrittsanzeige robust gegen undefined
            property int lastProgress: -1
            Timer {
                interval: 200; running: true; repeat: true
                onTriggered: {
                    let p = view.loadingProgress
                    if (typeof p === "number" && p !== view.lastProgress) {
                        view.lastProgress = p
                        console.log("[WebEngine] progress:", p)
                    }
                }
            }
        }
    }
    Component.onCompleted: view.url = urlEdit.text
}
