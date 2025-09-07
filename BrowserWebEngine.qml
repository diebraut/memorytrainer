import QtQuick 2.15
import QtWebEngine 1.12

Item {
    id: root
    property alias url: view.url
    WebEngineView {
        id: view
        anchors.fill: parent
        url: "about:blank"
    }
}
