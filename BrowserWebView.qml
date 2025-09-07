import QtQuick 2.15
import QtWebView 1.1

Item {
    id: root
    property alias url: view.url
    WebView {
        id: view
        anchors.fill: parent
        url: "about:blank"
    }
}
