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

    QtObject {
        id: nav
        property var stack: stackView
    }


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
                    source: (Qt.platform.os === "ios" || Qt.platform.os === "tvos" || Qt.platform.os === "android")
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
        z: 9999
        visible: true

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
                id: backButton
                z: 999999
                icon.name: stackView.depth > 1 ? "back" : "drawer"

                onPressed: console.log("BACK PRESSED")
                onCanceled: console.log("BACK CANCELED")
                onReleased: console.log("BACK RELEASED")
                onClicked: console.log("BACK CLICKED")

                // HARDCODED FIX: prevent stealing
                TapHandler {
                    id: tap
                    acceptedButtons: Qt.LeftButton
                    gesturePolicy: TapHandler.DragThreshold
                    onTapped: {
                        onClicked: console.log("BACK CLICKED")
                        console.log("Platform:", Qt.platform.os)
                        console.log("stackView.depth:", stackView.depth)

                        if (stackView.depth > 1) {
                            const currentPage = stackView.currentItem
                            console.log("currentPage:", currentPage)

                            if (!currentPage) {
                                console.log("ERROR: currentPage == null → simple pop()")
                                stackView.pop()
                                console.log("---- BACK END ----")
                                return
                            }

                            const hasCleanup = (typeof currentPage.myCleanup === "function")
                            const hasStartup = (typeof currentPage.myStartup === "function")
                            const src        = currentPage.source

                            console.log("currentPage.inProcess:", currentPage.inProcess)
                            console.log("hasCleanup:", hasCleanup, "hasStartup:", hasStartup, "source:", src)

                            if (currentPage.inProcess === true && src) {
                                console.log("PATH: inProcess == TRUE → cleanup & reload")

                                if (hasCleanup) {
                                    console.log("Calling myCleanup()…")
                                    currentPage.myCleanup()
                                } else {
                                    console.log("myCleanup() NOT FOUND")
                                }

                                console.log("Reloading page:", src)
                                stackView.pop()
                                stackView.push(src)

                            } else {
                                console.log("PATH: inProcess == FALSE oder keine source → simple pop()")
                                stackView.pop()
                            }
                        } else {
                            console.log("PATH: depth == 1 → drawer")
                            drawer.open()
                        }
                        console.log("---- BACK END ----")
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
        property alias navigator: stackView


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
