import QtQuick 2.15

Item {
    id: root
    property url url: "about:blank"
    // iOS/Android => WebView, sonst WebEngine
    readonly property bool useWebView: (Qt.platform.os === "ios" || Qt.platform.os === "android")

    Loader {
        id: l
        anchors.fill: parent
        source: useWebView ? "BrowserWebView.qml" : "BrowserWebEngine.qml"
        onLoaded: {
            if (item && item.hasOwnProperty("url")) item.url = root.url;
        }
    }

    onUrlChanged: {
        if (l.item && l.item.hasOwnProperty("url")) l.item.url = url;
    }
}
