import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.12
import QtQuick.Controls.Universal 2.3
import QtCore 6.5 as QtCore

import "model"
import "global"

ApplicationWindow {
    id: appId
    visible: true
    title: "Start Training"

    width: 768
    height: 1024

    // Optional: falls du das brauchst
    property bool isInternetAvailable: false

    Util { id: utilID }
    DataModel { id: dataModel }

    /* =======================
       Haupt-FocusScope & Web-Overlay
       ======================= */
    FocusScope {
        id: mainFocusScope
        anchors.fill: parent
        focus: true
        z: 1

        // Web-Overlay-Status & URL-Pipeline
        property bool webShown: false
        property string webUrl: "https://www.wikipedia.org"
        property string __pendingUrl: ""

        // URL anwenden, wenn der Loader ein Item hat
        function __applyPendingUrl() {
            if (!__pendingUrl) return
            if (!webLoader.item) {
                Qt.callLater(__applyPendingUrl)
                return
            }
            const w = webLoader.item
            Qt.callLater(function() {
                if (typeof w.load === "function") w.load(__pendingUrl)
                if (w.hasOwnProperty("url"))      w.url = __pendingUrl
            })
        }

        // API (extern nutzbar)
        function showWebPage(url) { openWebPage(url) }

        function openWebPage(url) {
            __pendingUrl = url || webUrl
            webShown = true                                   // 1) zeigen
            Qt.callLater(() => {                              // 2) nach 1 Frame fokussieren & URL setzen
                webViewContainerId.forceActiveFocus()
                __applyPendingUrl()
            })
        }

        function closeWebPage() {
            mainFocusScope.forceActiveFocus()                 // Fokus weg vom Overlay
            // NICHT stop() auf WKWebView — reduziert "connection invalid"
            if (webLoader.item && typeof webLoader.item.clear === "function")
                webLoader.item.clear()                        // setzt nur about:blank (siehe unten)
            webShown = false
            __pendingUrl = ""
        }

        // Overlay über allem – enthält den persistenten Loader
        Item {
            id: webViewContainerId
            anchors.fill: parent
            z: 1000
            visible: mainFocusScope.webShown

            // Eigener Fokusanker
            FocusScope {
                id: overlayFocus
                anchors.fill: parent
                focus: false   // wird gezielt gesetzt

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        mainFocusScope.closeWebPage()
                        event.accepted = true
                    }
                }

                Loader {
                    id: webLoader
                    anchors.fill: parent
                    active: true
                    asynchronous: true
                    source: (Qt.platform.os === "ios" || Qt.platform.os === "tvos")
                            ? "qrc:/BrowserIOS.qml"
                            : "qrc:/BrowserDesktop.qml"

                    onLoaded: {
                        mainFocusScope.__applyPendingUrl()
                        Qt.callLater(() => overlayFocus.forceActiveFocus())
                    }
                }
            }

            onVisibleChanged: {
                if (visible) Qt.callLater(() => overlayFocus.forceActiveFocus())
            }
        }
    }

    /* =======================
       Lifecycle
       ======================= */
    Component.onCompleted: dataModel.setPlatform(utilID.ifMobile())

    /* =======================
       Shortcuts
       ======================= */
    Shortcut {
        sequence: "Menu"
        onActivated: optionsMenu.open()
    }

    /* =======================
       Header / Toolbar
       ======================= */
    header: ToolBar {
        id: headerId
        Material.foreground: "white"

        RowLayout {
            id: headerRow
            spacing: 20
            anchors.fill: parent
            property QtCore.Settings p;

            QtCore.Settings {
                id: locSetting
                category: "General"
                property string datastore: "user_value"
            }

            ToolButton {
                icon.name: stackView.depth > 1 ? "back" : "drawer"
                property var wrongDatastore: undefined

                onClicked: {
                    if (stackView.depth > 1) {
                        const currentPage = stackView.currentItem
                        if (currentPage && typeof currentPage.inProcess === "boolean") {
                            if (currentPage.inProcess) {
                                console.log("Page is in process, close and recreating...")
                                if (typeof currentPage.myCleanup === "function") {
                                    currentPage.myCleanup()
                                    if (locSetting.datastore) {
                                        console.log("Datastore-Wert:", locSetting.datastore)
                                        wrongDatastore = currentPage.work_datastore
                                        console.log("DatastoreWork-Wert:", wrongDatastore)
                                        if (!wrongDatastore) wrongDatastore = undefined
                                    }
                                } else {
                                    console.warn("Current page has no cleanup method.")
                                }

                                const pageSource = currentPage.source
                                if (pageSource) {
                                    stackView.pop()
                                    const component = Qt.createComponent(pageSource)
                                    if (component.status === Component.Ready) {
                                        stackView.push(pageSource)
                                        if (wrongDatastore && typeof currentPage.myStartup === "function") {
                                            stackView.currentItem.myStartup(wrongDatastore)
                                        }
                                    } else {
                                        console.error("Failed to load component:", component.errorString())
                                    }
                                } else {
                                    console.error("Page source is undefined. Cannot recreate.")
                                }
                            } else {
                                console.log("Page is not in process, navigating to start page...")
                                stackView.pop()
                                listView.currentIndex = -1
                            }
                        } else {
                            console.log("No valid status, returning to start page...")
                            stackView.pop()
                            listView.currentIndex = -1
                        }
                    } else {
                        drawer.open()
                    }
                }
            }

            Label {
                id: titleLabel
                text: listView.currentItem ? listView.currentItem.text : "Memory Trainer (" + Qt.platform.os + ")"
                font.pixelSize: 20
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            ToolButton {
                icon.name: "menu"
                onClicked: optionsMenu.open()

                Menu {
                    id: optionsMenu
                    x: parent.width - width
                    transformOrigin: Menu.TopRight

                    MenuItem { text: "Settings" }
                    MenuItem { text: "About"; onTriggered: aboutDialog.open() }
                }
            }

            Button {
                id: exitWebViewButton
                visible: mainFocusScope.webShown
                height: parent.height
                text: "Webseite schließen"
                font.pixelSize: 14
                font.bold: true
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.rightMargin: 10

                // optional, falls du die Referenz brauchst
                property var webEngineInstance: null
                function setWebView(webView) { webEngineInstance = webView }

                // Wichtig: Direkt die Autorität rufen – kein Rückruf-Loop
                onClicked: mainFocusScope.closeWebPage()
            }
        }
    }

    /* =======================
       Drawer / Navigation
       ======================= */
    Drawer {
        id: drawer
        width: Math.min(appId.width, appId.height) / 3 * 2
        height: appId.height
        interactive: stackView.depth === 1

        ListView {
            id: listView
            focus: true
            currentIndex: -1
            anchors.fill: parent

            delegate: ItemDelegate {
                width: parent.width
                text: model.title
                highlighted: ListView.isCurrentItem
                onClicked: {
                    listView.currentIndex = index
                    stackView.push(model.source)
                    drawer.close()
                }
            }

            model: ListModel {
                ListElement { title: "Training";          source: "pages/Exercise.qml" }
                ListElement { title: "Kamera";            source: "pages/MakeOwnPicture.qml" }
                ListElement { title: "Paket Verwaltung";  source: "pages/PackageManager.qml" }
                ListElement { title: "Paket importieren"; source: "pages/PackageProvider.qml" }
            }

            ScrollIndicator.vertical: ScrollIndicator { }
        }
    }

    /* =======================
       Hauptinhalt
       ======================= */
    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: Pane {
            id: pane

            Image {
                id: logo
                width: pane.width / 2
                height: pane.height / 3
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -100
                fillMode: Image.PreserveAspectFit
                source: "images/app.png"
            }

            Label {
                id: infoLabel
                text: "Bring dein Gedächtnis auf Trab."
                anchors.top: logo.top
                anchors.topMargin: pane.height / 6
                anchors.right: logo.right
                anchors.rightMargin: 70
                z: 1
            }

            Button {
                id: startButton
                text: "Los geht es"
                width: 150
                height: 150
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 50
                font.pixelSize: 24
                background: Rectangle {
                    color: startButton.down ? "#006400" : "#00FF00"
                    radius: 75
                    border.color: "#000000"
                    border.width: 2
                }
                onClicked: stackView.push("pages/Exercise.qml")
            }
        }
    }

    /* =======================
       StatusBar unten
       ======================= */
    StatusBar {
        id: statusBarComponent
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: parent.width / 2
    }

    /* =======================
       About-Dialog
       ======================= */
    Dialog {
        id: aboutDialog
        title: "About"
        standardButtons: Dialog.Ok
        visible: false
        onAccepted: visible = false
        width: 400
        height: 200

        contentItem: Text {
            text: "Memory Trainer\nVersion 1.0\nDeveloped by [Your Name]"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    /* =======================
       Hooks für den Header-Button
       ======================= */
    function setWebView(webView) {
        if (exitWebViewButton && typeof exitWebViewButton.setWebView === "function")
            exitWebViewButton.setWebView(webView)
    }

    function closeWebView() {
        // no-op – Schließen macht ausschließlich mainFocusScope.closeWebPage()
    }
}
