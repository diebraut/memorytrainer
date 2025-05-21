import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

//import Qt.labs.settings 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.3

import QtWebEngine 1.12 // Import WebEngine module

import QtCore 6.5 as QtCore

import "model"
import "global"

ApplicationWindow {
    id: appId
    visible: true
    title: "Start Training"

    property bool isInternetAvailable: false  // Update this based on network status

    width: 768
    height: 1024

    Util {
        id: utilID
    }

    DataModel {
        id: dataModel
    }

    FocusScope {
        id: mainFocusScope
        anchors.fill: parent
        focus: true
        activeFocusOnTab: true
        z: 1

        Timer {
            id: delayedDestroyTimer
            interval: 100  // Warte 100ms
            repeat: false
            onTriggered: {
                if (mainFocusScope.webEngineInstance) {
                    console.log("Destroying WebEngineView instance...");
                    mainFocusScope.webEngineInstance.destroy();
                    mainFocusScope.webEngineInstance = null;
                    gc();  // Garbage Collection
                    console.log("WebEngineView instance destroyed and garbage collected.");
                }
            }
        }

        // URL, die geladen wird
        property string webUrl: "https://www.wikipedia.org"
        property var webEngineInstance: null

        // Container für die dynamische Erstellung der WebEngineView-Instanz
        Item {
            id: webViewContainerId
            anchors.fill: parent
            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    mainFocusScope.closeWebPage();
                    event.accepted = true;
                }
            }
        }

        function showWebPage(url) {
            console.log("Loading page in application window...");
            openWebPage(url);  // Lädt die Seite im Main Window
        }

        function openWebPage(url) {
            closeWebPage();  // Bestehende WebView-Instanz schließen

            // WebEngineView-Instanz dynamisch erstellen
            webEngineInstance = webViewComponentId.createObject(webViewContainerId, {
                width: webViewContainerId.width,
                height: webViewContainerId.height,
                focus: true
            });

            if (webEngineInstance) {
                // Setze die URL für das WebEngineView
                const webEngineView = webEngineInstance.children[0];
                if (webEngineView) {
                    webEngineView.url = url || webUrl;  // URL festlegen
                }
            }
            appId.setWebView(webEngineInstance);
            webViewContainerId.forceActiveFocus();
        }
        function closeWebPage() {
            if (webEngineInstance) {
                 console.log("Initiating close process for WebEngineView...");
                const webView = webEngineInstance.children[0];
                if (webView) {
                    webView.url = "about:blank";  // Entlädt die Seite
                }
                delayedDestroyTimer.start();  // Startet den Timer, um das Objekt verzögert zu zerstören
            }
        }

        // WebEngineView-Komponente
        Component {
            id: webViewComponentId
            Item {
                width: parent.width
                height: parent.height

                WebEngineView  {
                    id: webEngineViewId
                    anchors.fill: parent
                    focus: true
                    url: ""  // Die URL wird später gesetzt
                }
            }
        }
    }

    Component.onCompleted: {
        dataModel.setPlatform(utilID.ifMobile())
    }

    Shortcut {
        sequence: "Menu"
        onActivated: optionsMenu.open()
    }

    header: ToolBar {
        id: headerId
        Material.foreground: "white"
        RowLayout {
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
                        const currentPage = stackView.currentItem;

                        if (currentPage && typeof currentPage.inProcess === "boolean") {
                            if (currentPage.inProcess) {
                                console.log("Page is in process, close and recreating...");
                                // Prüfen, ob die Seite eine Methode cleanup() hat, und diese aufrufen
                                if (typeof currentPage.myCleanup === "function") {
                                    currentPage.myCleanup(); // Cleanup-Methode aufrufen
                                    if (locSetting.datastore) {
                                        //dataModel.debugPt();
                                        //var entryModelPackagesId = []
                                        console.log("Datastore-Wert bei Überprüfung:", locSetting.datastore);
                                        wrongDatastore = currentPage.work_datastore;
                                        console.log("DatastoreWork-Wert bei Überprüfung:", wrongDatastore);
                                        if (!wrongDatastore) {
                                            wrongDatastore = undefined;
                                        }
                                    }
                                } else {
                                    console.warn("Current page has no cleanup method.");
                                }
                                // Prüfen, ob die Quelle der Seite definiert ist
                                const pageSource = currentPage.source;
                                if (pageSource) {
                                    stackView.pop(); // Aktuelle Seite entfernen
                                    // Dynamische Neuanlage
                                    const component = Qt.createComponent(pageSource);
                                    if (component.status === Component.Ready) {
                                        //const newPage = component.createObject(stackView);
                                        stackView.push(pageSource); // Neue Seite hinzufügen
                                        if (wrongDatastore && typeof currentPage.myStartup === "function") {
                                            stackView.currentItem.myStartup(wrongDatastore); // Startup methode aufrufen
                                        }
                                    } else {
                                        console.error("Failed to load component:", component.errorString());
                                    }
                                } else {
                                    console.error("Page source is undefined. Cannot recreate.");
                                }
                            } else {
                                console.log("Page is not in process, navigating to start page...");
                                stackView.pop(); // Zur Startseite zurückkehren
                                listView.currentIndex = -1;
                            }
                        } else {
                            console.log("No valid status, returning to start page...");
                            stackView.pop(); // Fallback
                            listView.currentIndex = -1;
                        }
                    } else {
                        drawer.open();
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

                    MenuItem {
                        text: "Settings"
                        // onTriggered: settingsDialog.open()
                    }
                    MenuItem {
                        text: "About"
                        onTriggered: aboutDialog.open()
                    }
                }
            }

            Button {
                id: exitWebViewButton
                visible: false
                height: parent.height
                text: "Webseite schließen"
                font.pixelSize: 14
                font.bold: true
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.rightMargin: 10

                property var webEngineInstance: null

                // Setzt das WebView-Objekt in der Schließen-Logik
                function setWebView(webView) {
                    webEngineInstance = webView;
                    visible = true;  // Zeige den Button, wenn WebView gesetzt ist
                }

                // Zentrale Funktion zur Schließung
                function closeWebView() {
                    mainFocusScope.closeWebPage();  // Aufruf der zentralen close-Funktion
                    webEngineInstance = null;
                    visible = false;
                }

                onClicked: {
                    closeWebView();  // Aufruf der Schließfunktion bei Button-Klick
                }
            }
        }
    }

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
                ListElement { title: "Training"; source: "pages/Exercise.qml" }
                ListElement { title: "Kamera"; source: "pages/MakeOwnPicture.qml" }
                ListElement { title: "Paket Verwaltung"; source: "pages/PackageManager.qml" }
                ListElement { title: "Paket importieren"; source: "pages/PackageProvider.qml" }
            }

            ScrollIndicator.vertical: ScrollIndicator { }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent


        initialItem: Pane {
            id: pane
            //anchors.fill: parent

            Image {
                id: logo
                width: pane.width / 2
                height: pane.height / 3
                anchors.horizontalCenter: parent.horizontalCenter
                //anchors.top: pane.top
                //anchors.topMargin:300
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
                z:1
                //wrapMode: Label.Wrap
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
                onClicked: {
                    stackView.push("pages/Exercise.qml")
                }
            }
        }
    }

    // Use the StatusBar component at the bottom
    StatusBar {
        id: statusBarComponent
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: parent.width / 2  // If you need a specific width
    }

    Dialog {
        id: aboutDialog
        title: "About"
        standardButtons: Dialog.Ok
        visible: false
        onAccepted: visible = false

        width: 400  // Manuelle Breite setzen
        height: 200  // Manuelle Höhe setzen

        contentItem: Text {
            text: "Memory Trainer\nVersion 1.0\nDeveloped by [Your Name]"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    function setWebView(webView) {
        exitWebViewButton.visible = true
        exitWebViewButton.setWebView(webView);
    }

    function closeWebView(webView) {
        exitWebViewButton.closeWebView(webView);
    }
}
