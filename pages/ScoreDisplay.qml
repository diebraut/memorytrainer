import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: scoreDisplay
    width: parent.width
    height: parent.height

    property int secondsElapsed: elapsedTimeId.secondsElapsed
    property alias elapsedTimerRunning: elapsedTimeId.elapsedTimerRunning
    property alias elapsedTimeIdText: elapsedTimeId.text
    property alias evalGroupIdVisible: evalGroupId.visible

    GroupBox {
        id: evalGroupId
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        anchors.topMargin: 30

        background: CustomBox {
            id: custBoxId
            y: evalGroupId.topPadding - evalGroupId.padding
            width: page.width * 0.9
            height: parent.height - evalGroupId.topPadding + evalGroupId.padding
            borderColor: "black"
            borderWidth: 2
            textWidthFactor:0.42
        }

        Rectangle {
            id: label
            anchors.horizontalCenter: parent.horizontalCenter  // Zentriert das Rectangle horizontal in der GroupBox
            anchors.top: parent.top
            color: "transparent"
            width: parent.width * 0.5
            height: titleEvalGroupId.font.pixelSize * 2  // oder eine feste Höhe setzen

            Text {
                id: titleEvalGroupId
                text: qsTr("Auswertung")
                anchors.horizontalCenter: parent.horizontalCenter  // Zentriert den Text horizontal im Rectangle
                anchors.bottom: parent.top
                font.pixelSize: 14
                font.bold: true
                color: "black"  // Stellen Sie sicher, dass die Textfarbe auf einem transparenten Hintergrund sichtbar ist
            }
        }

        Item {
            id: evalSummaryId
            width: parent.width
            height: (totalQuestionsFalseId.y - elapsedTimeId.y) + totalQuestionsFalseId.height

            // Elapsed Time Section
            Label {
                id: elapsedTimeId
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 10
                font.pixelSize: 17
                //font.bold: true
                color: "black"
                text: "Gesamtzeit: " + scoreDisplay.fancyTimeFormat(0);

                property int dummyCnt: 0
                property double startTime: 0
                property double startPauseTime: 0
                property int secondsElapsed: 0
                property int secondsPaused: 0
                property alias elapsedTimerRunning: elapsedTimer.running

                Timer {
                    id: elapsedTimer
                    interval: 1000
                    running: false
                    repeat: true
                    onTriggered: timeChanged()
                    triggeredOnStart: true
                    function timeChanged() {
                        var currentTime = new Date().getTime();
                        if (elapsedTimeId.startPauseTime !== 0) {
                            elapsedTimeId.secondsPaused += (currentTime - elapsedTimeId.startPauseTime) / 1000;
                            elapsedTimeId.startPauseTime = 0;
                        }

                        if (elapsedTimeId.startTime === 0) {
                            elapsedTimeId.startTime = new Date().getTime();
                        }
                        elapsedTimeId.secondsElapsed =
                            (currentTime - elapsedTimeId.startTime) / 1000 - elapsedTimeId.secondsPaused;
                    }
                }
            }

            Label {
                id: totalQuestionsId
                anchors.top: elapsedTimeId.top
                anchors.left: elapsedTimeId.right
                anchors.leftMargin: 10
                text:"Fragen gesamt:"
                font.pixelSize: 17
            }
            Label {
                id: totalQuestionsCntId
                anchors.top: elapsedTimeId.top
                anchors.left: totalQuestionsId.right
                anchors.leftMargin: 5
                text:"0"
                font.pixelSize: 17
            }
            Label {
                id: totalQuestionsRightId
                anchors.top: elapsedTimeId.bottom
                anchors.topMargin: 5
                anchors.left:  totalQuestionsId.left
                text:"Fragen richtig:"
                font.pixelSize: 17
                color: "green"  // Hier wird die Textfarbe gesetzt
            }
            Label {
                id: totalQuestionsRightCntId
                anchors.top: elapsedTimeId.bottom
                anchors.topMargin: 5
                anchors.left: totalQuestionsId.right
                anchors.leftMargin: 5
                text:"0"
                font.pixelSize: 17
                color: "green"  // Hier wird die Textfarbe gesetzt
            }
            Label {
                id: totalQuestionsFalseId
                anchors.top: totalQuestionsRightId.bottom
                anchors.left: totalQuestionsId.left
                text:"Fragen falsch: "
                font.pixelSize: 17
                color: "red"  // Hier wird die Textfarbe gesetzt
            }
            Label {
                id: totalQuestionsFalseCntId
                anchors.top: totalQuestionsRightId.bottom
                anchors.left: totalQuestionsId.right
                anchors.leftMargin: 5
                text:"0"
                font.pixelSize: 17
                color: "red"  // Hier wird die Textfarbe gesetzt
            }
            Rectangle {
                id: pictureMemoryStateId
                anchors.top: parent.top
                anchors.topMargin:10
                //anchors.verticalCenter: parent.verticalCenter  // Zentriert das Rechteck vertikal im übergeordneten Element
                anchors.left: totalQuestionsFalseCntId.right
                anchors.leftMargin: parent.width / 4
                height:parent.height * 1.1
                width: parent.height * 1.1 // Breite ist gleich der Höhe
                color: "transparent"  // Setze das Rechteck auf transparent
                //color: "yellow"
                Image {
                    id : pictureMemoryStateImageId
                    anchors.fill: parent  // Füllt das gesamte Rechteck
                    //source: "qrc:/arrow.png"  // Pfad zu deinem Bild
                    source: "qrc:/exercize_start.png"  // Pfad zu deinem Bild
                    fillMode: Image.PreserveAspectCrop  // Das Bild wird zugeschnitten, um das Rechteck zu füllen, ohne das Seitenverhältnis zu verzerren
                }
            }
        }
        Rectangle {
            id: evalTableId
            anchors.top: evalSummaryId.bottom
            anchors.topMargin: 25
            width: parent.width
            height: 200
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                width: evalTableId.width

                // Table header
                RowLayout {
                    spacing: 2 // Set spacing for the layout
                    width: parent.width // Adjust header width to fit the table width

                    Rectangle {
                        color: "darkgray"
                        width: (parent.width - (4 * 2)) / 5  // Adjust based on the spacing
                        height: 40
                        border.color: "black"
                        border.width: 2
                        radius: 4
                        z: 1

                        Text {
                            anchors.centerIn: parent
                            text: qsTr("Runde")
                            font.bold: true
                            color: "white"
                        }
                    }

                    Rectangle {
                        color: "darkgray"
                        width: (parent.width - (4 * 2)) / 5  // Adjust based on the spacing
                        height: 40
                        border.color: "black"
                        border.width: 2
                        radius: 4
                        z: 1

                        Text {
                            anchors.centerIn: parent
                            text: qsTr("Anzahl Fragen")
                            font.bold: true
                            color: "white"
                        }
                    }

                    Rectangle {
                        color: "darkgray"
                        width: (parent.width - (4 * 2)) / 5  // Adjust based on the spacing
                        height: 40
                        border.color: "black"
                        border.width: 2
                        radius: 4
                        z: 1

                        Text {
                            anchors.centerIn: parent
                            text: qsTr("Richtig beantwortet")
                            font.bold: true
                            color: "white"
                        }
                    }

                    Rectangle {
                        color: "darkgray"
                        width: (parent.width - (4 * 2)) / 5  // Adjust based on the spacing
                        height: 40
                        border.color: "black"
                        border.width: 2
                        radius: 4
                        z: 1

                        Text {
                            anchors.centerIn: parent
                            text: qsTr("Falsch beantwortet")
                            font.bold: true
                            color: "white"
                        }
                    }

                    Rectangle {
                        color: "darkgray"
                        width: (parent.width - (4 * 2)) / 5  // Adjust based on the spacing
                        height: 40
                        border.color: "black"
                        border.width: 2
                        radius: 4
                        z: 1

                        Text {
                            anchors.centerIn: parent
                            text: qsTr("Benötigte Zeit")
                            font.bold: true
                            color: "white"
                        }
                    }
                }

                // Table content with ScrollBar
                ListView {
                    id: tableView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: tableModel
                    clip: true
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded  // Show scroll bar only when needed
                    }

                    delegate: RowLayout {
                        spacing: 2 // Ensure same spacing as header
                        width: parent ? parent.width : 0
                        height: 40  // Match height of header

                        Rectangle {
                            width: (parent.width - (4 * 2)) / 5
                            height: 40
                            color: model.richtigBeantwortet === model.anzahlFragen ? "lightgreen" : "lightcoral"
                            border.color: "black"

                            Text {
                                anchors.centerIn: parent
                                text: model.round
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        Rectangle {
                            width: (parent.width - (4 * 2)) / 5
                            height: 40
                            color: model.richtigBeantwortet === model.anzahlFragen ? "lightgreen" : "lightcoral"
                            border.color: "black"

                            Text {
                                anchors.centerIn: parent
                                text: model.anzahlFragen
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        Rectangle {
                            width: (parent.width - (4 * 2)) / 5
                            height: 40
                            color: model.richtigBeantwortet === model.anzahlFragen ? "lightgreen" : "lightcoral"
                            border.color: "black"

                            Text {
                                anchors.centerIn: parent
                                text: model.richtigBeantwortet
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        Rectangle {
                            width: (parent.width - (4 * 2)) / 5
                            height: 40
                            color: model.richtigBeantwortet === model.anzahlFragen ? "lightgreen" : "lightcoral"
                            border.color: "black"

                            Text {
                                anchors.centerIn: parent
                                text: model.falschBeantwortet
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        Rectangle {
                            width: (parent.width - (4 * 2)) / 5
                            height: 40
                            color: model.richtigBeantwortet === model.anzahlFragen ? "lightgreen" : "lightcoral"
                            border.color: "black"

                            Text {
                                anchors.centerIn: parent
                                text: model.benoetigteZeit
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }

            ListModel {
                id: tableModel
            }
        }
    }

    // Function to add a new row
    function addRow(richtigBeantwortet, falschBeantwortet) {
        var roundNumber = tableModel.count + 1;
        var anzahlFragen = richtigBeantwortet + falschBeantwortet;
        var lastSecondsElapsed = 0
        for (var i=0; i < tableModel.count;i++) {
            var row = tableModel.get(i);
            lastSecondsElapsed += timeToSeconds(row.benoetigteZeit);
        }
        var formattedTime = fancyTimeFormat(elapsedTimeId.secondsElapsed - lastSecondsElapsed);
        // Insert new row
        tableModel.insert(0, {
            "round": roundNumber,
            "anzahlFragen": anzahlFragen,
            "richtigBeantwortet": richtigBeantwortet,
            "falschBeantwortet": falschBeantwortet,
            "benoetigteZeit": formattedTime
        });
        updateTotals();
    }

    // Helper function to convert formatted time (HH:MM:SS or MM:SS) back to seconds
    function timeToSeconds(timeString) {
        var parts = timeString.split(":");
        var hours = 0;
        var minutes = 0;
        var secs = 0;
        var seconds = 0;

        if (parts.length === 3) { // Format HH:MM:SS
            hours = parseInt(parts[0], 10);
            minutes = parseInt(parts[1], 10);
            secs = parseInt(parts[2], 10);
            seconds = (hours * 3600) + (minutes * 60) + secs;
        } else if (parts.length === 2) { // Format MM:SS
            minutes = parseInt(parts[0], 10);
            secs = parseInt(parts[1], 10);
            seconds = (minutes * 60) + secs;
        }

        return seconds;
    }

    // Function to calculate and update the total values
    // Update function (Zeiten in Sekunden summieren)
    function updateTotals() {
        var totalRight = 0;
        var totalWrong = 0;

        // Der Wert von totalQuestions wird nur von der letzten Zeile übernommen
        var totalQuestions = (tableModel.count > 0) ? tableModel.get(tableModel.count - 1).anzahlFragen : 0;

        // Summiere totalRight und die Zeiten
        for (var i = 0; i < tableModel.count; i++) {
            var row = tableModel.get(i);
            totalRight += row.richtigBeantwortet;
        }

        // Berechne totalWrong als Differenz zwischen totalQuestions und totalRight
        totalWrong = totalQuestions - totalRight;

        // Aktualisiere die Labels
        totalQuestionsCntId.text = totalQuestions.toString();
        totalQuestionsRightCntId.text = totalRight.toString();
        totalQuestionsFalseCntId.text = totalWrong.toString();
        if (totalWrong === 0) {
            pictureMemoryStateImageId.source = "qrc:/exercize_finish.png"
            elapsedTimeId.text = "Gesamtzeit:"
        } else {
            elapsedTimeId.text = "Zwischenzeit:"
            pictureMemoryStateImageId.source = "qrc:/exercize_running.png"
        }
        elapsedTimeId.text += fancyTimeFormat(elapsedTimeId.secondsElapsed);  // Formatierte Zeit anzeigen
    }

    // Function to reset the table
    function resetTable() {
        tableModel.clear();  // Clear all rows
    }

    function restartCounter() {
        elapsedTimeId.startTime = 0;
        elapsedTimeId.secondsPaused = 0;
    }

    function startPause() {
        elapsedTimeId.startPauseTime = new Date().getTime();
    }

    // Helper function for time formatting
    function fancyTimeFormat(time) {
        var hrs = Math.floor(time / 3600);
        var mins = Math.floor((time % 3600) / 60);
        var secs = Math.floor(time % 60);
        var ret = "";
        if (hrs > 0) {
            ret += hrs + ":" + (mins < 10 ? "0" : "");
        }
        ret += mins + ":" + (secs < 10 ? "0" : "") + secs;
        return ret;
    }
}

