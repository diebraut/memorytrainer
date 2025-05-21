import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15


import com.memorytrainer.network 1.0

Rectangle {
    id: statusBar
    width: parent.width / 2
    height: 40
    color: "transparent"

    // Simulate an enum using a JavaScript object
    property var statusEnum: ({ connected: 0, unconnected: 1 })

    // Associated status strings
    readonly property var statusTexts: ({
        [statusEnum.connected]: "Bereit (Internetverbindung verfügbar)",
        [statusEnum.unconnected]: "Bereit (Keine Internetverbindung)"
    })

    // Associated colors
    readonly property var statusColors: ({
        [statusEnum.connected]: "lightgreen",
        [statusEnum.unconnected]: "lightcoral"
    })

    // Property to hold current status
    property int status: statusEnum.unconnected

    // Timer to automatically hide the status text rectangle
    Timer {
        id: hideStatusTimer
        interval: 3000  // 3 seconds
        repeat: false
        onTriggered: {
            statusTextRectangle.visible = false; // Hide after 3 seconds
        }
    }

    Button {
        id: toggleButton
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        height: 50  // Explicit height for button
        width: 60

        background: Rectangle {
            color: statusColors[status]
            radius: 8
        }

        Image {
            id: toggleIcon
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: statusTextRectangle.visible ? "qrc:/images/state_off.png" : "qrc:/images/state_on.png"
            width: toggleButton.height * 0.6 // Scale icon to be 60% of button height
            height: toggleButton.height * 0.6
        }

        onClicked: {
            statusTextRectangle.visible = !statusTextRectangle.visible
            if (statusTextRectangle.visible) {
                hideStatusTimer.start();
            }
        }
    }

    // Rectangle for status text
    Rectangle {
        id: statusTextRectangle
        visible: false
        width: 300
        height: toggleButton.height - 15  // Align height exactly with button
        anchors.left: toggleButton.right
        anchors.leftMargin: 5
        anchors.verticalCenter: toggleButton.verticalCenter // Align vertically
        color: statusColors[status]
        radius: 5  // Set the rounded corners

        Label {
            id: statusLabel
            text: statusTexts[status]
            anchors.centerIn: parent
            font.pixelSize: 16
            color: "#333333"
        }
    }

    // Create a NetworkChecker object
    NetworkChecker {
        id: networkChecker
        onNetworkStatusChanged: function(isOnline) {
            // Set the status based on network connectivity
            status = isOnline ? statusEnum.connected : statusEnum.unconnected;
            appId.isInternetAvailable = isOnline;
            // If the status has changed, show the message window and start the timer
            if (statusBar.status !== status) {
                statusBar.status = status;
                statusTextRectangle.visible = true;
                hideStatusTimer.start();
            }
        }
    }

    // Timer to periodically check the network status
    Timer {
        interval: 2000  // 2 seconds in milliseconds
        repeat: true
        running: true

        onTriggered: {
            // Check the internet connection
            networkChecker.checkInternetConnection();
        }
    }

    // Check the network status immediately when the component is completed
    Component.onCompleted: {
        networkChecker.checkInternetConnection();
    }
}
