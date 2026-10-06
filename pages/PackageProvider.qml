import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

Page {
    id: pagePackageProvider
    title: qsTr("Pakete importieren")

    property bool loading: false
    property bool downloading: false
    property bool installing: false
    property string selectedPackageName: ""
    property string selectedDownloadedPackageName: ""
    property string overwritePackageName: ""
    property string overwriteInstalledName: ""
    property string errorMessage: ""
    property string statusMessage: ""
    property real downloadFraction: -1

    function loadDownloaded() {
        downloadedModel.clear()
        var packages = packageProviderBackend.getDownloadedPackages()
        for (var i = 0; i < packages.length; ++i)
            downloadedModel.append(packages[i])
    }

    function refresh() {
        errorMessage = ""
        statusMessage = ""
        selectedPackageName = ""
        selectedDownloadedPackageName = ""
        serverModel.clear()
        loadDownloaded()
        loading = true
        packageProviderBackend.refreshAvailablePackages()
    }

    function installDownloaded(overwrite) {
        errorMessage = ""
        statusMessage = qsTr("Installiere ") + selectedDownloadedPackageName + " ..."
        installing = true
        packageProviderBackend.installDownloadedPackage(selectedDownloadedPackageName, overwrite)
    }

    function formatSize(bytes) {
        if (bytes < 1024)
            return bytes + " B"
        if (bytes < 1024 * 1024)
            return (bytes / 1024).toFixed(1) + " KB"
        return (bytes / (1024 * 1024)).toFixed(1) + " MB"
    }

    function formatDate(value) {
        var date = new Date(value)
        return isNaN(date.getTime()) ? "" : Qt.formatDateTime(date, "dd.MM.yyyy hh:mm")
    }

    Component.onCompleted: refresh()

    Connections {
        target: packageProviderBackend
        function onAvailablePackagesLoaded(packages) {
            serverModel.clear()
            for (var i = 0; i < packages.length; ++i)
                serverModel.append(packages[i])
            pagePackageProvider.loading = false
        }
        function onAvailablePackagesError(message) {
            pagePackageProvider.errorMessage = qsTr("Paketliste konnte nicht geladen werden: ") + message
            pagePackageProvider.loading = false
        }
        function onDownloadStarted(packageName) {
            pagePackageProvider.downloading = true
            pagePackageProvider.downloadFraction = -1
            pagePackageProvider.errorMessage = ""
            pagePackageProvider.statusMessage = qsTr("Lade ") + packageName + " ..."
        }
        function onDownloadProgress(packageName, received, total) {
            pagePackageProvider.downloadFraction = total > 0 ? received / total : -1
            pagePackageProvider.statusMessage = qsTr("Lade ") + packageName + ": "
                    + pagePackageProvider.formatSize(received)
                    + (total > 0 ? " / " + pagePackageProvider.formatSize(total) : "")
        }
        function onDownloadFinished(packageName) {
            pagePackageProvider.downloading = false
            pagePackageProvider.downloadFraction = -1
            pagePackageProvider.statusMessage = packageName + qsTr(" wurde heruntergeladen.")
            pagePackageProvider.selectedPackageName = ""
            for (var i = 0; i < serverModel.count; ++i) {
                if (serverModel.get(i).name === packageName) {
                    serverModel.remove(i)
                    break
                }
            }
            pagePackageProvider.loadDownloaded()
        }
        function onDownloadError(packageName, message) {
            pagePackageProvider.downloading = false
            pagePackageProvider.downloadFraction = -1
            pagePackageProvider.statusMessage = ""
            pagePackageProvider.errorMessage = qsTr("Download fehlgeschlagen: ") + message
        }
        function onInstallationNeedsOverwrite(packageName, installedName) {
            pagePackageProvider.installing = false
            pagePackageProvider.statusMessage = ""
            pagePackageProvider.overwritePackageName = packageName
            pagePackageProvider.overwriteInstalledName = installedName
            overwriteDialog.open()
        }
        function onInstallationFinished(packageName, installedName) {
            pagePackageProvider.installing = false
            pagePackageProvider.statusMessage = qsTr("Paket ") + installedName + qsTr(" wurde installiert.")
            pagePackageProvider.loadDownloaded()
        }
        function onInstallationError(packageName, message) {
            pagePackageProvider.installing = false
            pagePackageProvider.statusMessage = ""
            pagePackageProvider.errorMessage = qsTr("Installation fehlgeschlagen: ") + message
        }
        function onInstallationWarning(message) {
            pagePackageProvider.errorMessage = message
        }
    }

    ListModel { id: serverModel }
    ListModel { id: downloadedModel }

    Dialog {
        id: overwriteDialog
        anchors.centerIn: parent
        width: 420
        modal: true
        title: qsTr("Paket überschreiben?")
        standardButtons: Dialog.Yes | Dialog.No
        Label {
            width: 380
            padding: 12
            wrapMode: Text.Wrap
            text: qsTr("Das Paket „") + pagePackageProvider.overwriteInstalledName
                  + qsTr("“ ist bereits installiert. Soll es überschrieben werden?")
        }
        onAccepted: {
            pagePackageProvider.selectedDownloadedPackageName = pagePackageProvider.overwritePackageName
            pagePackageProvider.installDownloaded(true)
        }
    }

    background: Rectangle { color: "#f3f4f6" }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: qsTr("Pakete importieren")
                font.pixelSize: 22
                font.bold: true
                color: "#111827"
            }
            Button {
                text: qsTr("Aktualisieren")
                enabled: !pagePackageProvider.loading && !pagePackageProvider.downloading
                         && !pagePackageProvider.installing
                onClicked: pagePackageProvider.refresh()
            }
        }

        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: pagePackageProvider.loading
            visible: running
        }

        Label {
            Layout.fillWidth: true
            visible: pagePackageProvider.errorMessage.length > 0
            text: pagePackageProvider.errorMessage
            wrapMode: Text.Wrap
            color: "#b91c1c"
        }

        Label {
            Layout.fillWidth: true
            visible: pagePackageProvider.statusMessage.length > 0
            text: pagePackageProvider.statusMessage
            wrapMode: Text.Wrap
            color: "#1d4ed8"
        }

        ProgressBar {
            Layout.fillWidth: true
            visible: pagePackageProvider.downloading
            from: 0
            to: 1
            value: pagePackageProvider.downloadFraction < 0 ? 0 : pagePackageProvider.downloadFraction
            indeterminate: pagePackageProvider.downloadFraction < 0
        }

        RowLayout {
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: qsTr("Auf dem Server verfügbar (") + serverModel.count + ")"
                font.pixelSize: 17
                font.bold: true
                color: "#111827"
            }
            Button {
                text: qsTr("Herunterladen")
                enabled: pagePackageProvider.selectedPackageName.length > 0
                         && !pagePackageProvider.loading && !pagePackageProvider.downloading
                         && !pagePackageProvider.installing
                onClicked: packageProviderBackend.downloadPackage(pagePackageProvider.selectedPackageName)
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 130

            ListView {
                id: serverList
                anchors.fill: parent
                clip: true
                spacing: 6
                model: serverModel
                ScrollBar.vertical: ScrollBar { }

                delegate: Rectangle {
                    width: serverList.width
                    height: 68
                    radius: 8
                    color: name === pagePackageProvider.selectedPackageName ? "#dbeafe" : "white"
                    border.color: name === pagePackageProvider.selectedPackageName ? "#2563eb" : "#d1d5db"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 3
                        Label {
                            Layout.fillWidth: true
                            text: name
                            font.pixelSize: 15
                            font.bold: true
                            elide: Text.ElideMiddle
                            color: "#111827"
                        }
                        Label {
                            text: pagePackageProvider.formatSize(size)
                                  + (modified ? " · " + pagePackageProvider.formatDate(modified) : "")
                            color: "#4b5563"
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: pagePackageProvider.selectedPackageName = name
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                visible: !pagePackageProvider.loading && !pagePackageProvider.errorMessage
                         && serverModel.count === 0
                text: qsTr("Keine weiteren Pakete verfügbar.")
                color: "#4b5563"
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: qsTr("Heruntergeladen (") + downloadedModel.count + ")"
                font.pixelSize: 17
                font.bold: true
                color: "#111827"
            }
            Button {
                text: qsTr("Installieren")
                enabled: pagePackageProvider.selectedDownloadedPackageName.length > 0
                         && !pagePackageProvider.loading && !pagePackageProvider.downloading
                         && !pagePackageProvider.installing
                onClicked: pagePackageProvider.installDownloaded(false)
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 130

            ListView {
                id: downloadedList
                anchors.fill: parent
                clip: true
                spacing: 6
                model: downloadedModel
                ScrollBar.vertical: ScrollBar { }

                delegate: Rectangle {
                    width: downloadedList.width
                    height: 68
                    radius: 8
                    color: name === pagePackageProvider.selectedDownloadedPackageName ? "#dbeafe" : "white"
                    border.color: name === pagePackageProvider.selectedDownloadedPackageName ? "#2563eb" : "#d1d5db"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 3
                        Label {
                            Layout.fillWidth: true
                            text: name
                            font.pixelSize: 15
                            font.bold: true
                            elide: Text.ElideMiddle
                            color: "#111827"
                        }
                        Label {
                            text: pagePackageProvider.formatSize(size)
                                  + (modified ? " · " + pagePackageProvider.formatDate(modified) : "")
                            color: "#4b5563"
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: pagePackageProvider.selectedDownloadedPackageName = name
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                visible: downloadedModel.count === 0
                text: qsTr("Noch keine Pakete heruntergeladen.")
                color: "#4b5563"
            }
        }
    }
}
