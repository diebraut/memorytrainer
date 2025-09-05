import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Controls.Material 2.15
import QtCore 6.5 as QtCore  // Verwende die passende Qt-Version
import QtQuick.Layouts 1.12
import QtWebEngine 1.12 // Import WebEngine module // Import WebEngine module

import "../model"

import com.memorytrainer.LearnListEntryManager 1.0
import com.memoryhandler.EntryHandler 1.0
import com.memoryhandler.EntryDesc 1.0
import com.memoryhandler.PackageDesc 1.0
import com.memoryhandler.LicenceInfo 1.0

import com.memorytrainer.network 1.0

import "../pages" as ScoreDisplayComponent



Page {

    id: page

    DataModel {
      id: dataModel
    }

    property bool isLoaded: false
    property bool inProcess: false  // Standardstatus
    property string source: "pages/Exercise.qml"  // Pfad zur Seite

    property string work_datastore: ""

    enum ActionActivated {
        PressedLeftButton,
        PressedRightButton,
        ActivatedLearnMode,
        ActivatedShowFalseEntries,
        DeactivatedLearnMode,
        DeactivatedShowFalseEntries
    }

    enum LearnModeState {
        LearnModeFirst,
        LearnModeNext,
        NotInLearnMode
    }

    property int learnModeState:Exercise.NotInLearnMode

    enum ExerciseModeState {
        ExerciseModeChoose,     //bekannt/nicht
        ExerciseModeResponse,   // ok/leider falsch oder
        ExerciseModeEvualation, // evaluation
        NotInExerciseMode
    }

    property bool   singlePackageLearning:false
    property var    singlePackageLearningPackagename
    property var    singlePackageLearningParts
    property var    singlePackageLearningPackagenameIdx

    property int exerciseModeState:Exercise.NotInExerciseMode

    property bool chosenAsKnown:false
    property bool lastEntryReached:false
    property bool preLastEntryReached:false
    property bool evalStartReached:true

    property int initHeightWideFormat:0
    property int initHeightLongFormat:0

    // neben deinen Text-Items anlegen
    TextMetrics { id: tm }       // für Breite
    FontMetrics { id: fm }       // für Höhe

    function widthOf(item) {
        tm.font = item.font
        tm.text = item.text
        return tm.advanceWidth        // robust & schnell
    }

    function heightOf(item) {
        fm.font = item.font
        return fm.height              // Zeilenhöhe der aktuellen Font
    }

    Rectangle
    {
        id:pageRectId
        anchors.fill: parent
        color: "lightgray"
        property string backColorPage: color
    }

    Rectangle {
        id: scoreText
        height: 40
        width: parent.width * 0.9;
        anchors.top: parent.top
        anchors.topMargin: 15
        anchors.left: parent.left
        anchors.leftMargin:  parent.width * 0.052
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.052

        property int cntRecognized :0
        property int cntNotRecognized :0
        property int cntAll:0
        property int allQuestions :0

        color: "#4DA527"

        radius: 5 // optional, für abgerundete Ecken

        Rectangle {
            id: border
            anchors.fill: parent
            anchors.margins: -2 // Die Breite des Borders
            color: "#000000" // Border-Farbe
            radius: scoreText.radius
            z: scoreText.z - 1 // Make sure the border is behind the main rectangle
        }

        Rectangle {
            id: shadow
            anchors.fill: parent
            anchors.margins: 3
            color: "#000000"
            opacity: 0.3 // Transparenz für den Schatteneffekt
            radius: scoreText.radius
            z: scoreText.z - 2 // Make sure the shadow is behind the border
        }

        Label {
            x: 5;
            id: constText;
            anchors.verticalCenter: scoreText.verticalCenter
            font.pixelSize: 20;
        }
        Label {
            id: recognized
            anchors.left: constText.right
            anchors.leftMargin: 15
            anchors.verticalCenter: scoreText.verticalCenter
            color:"white"
            text: qsTr("Erkannt ");
            font.pixelSize: 20;
        }
        Label {
            id: recognizedNr
            anchors.left: recognized.right
            anchors.leftMargin: 2
            anchors.verticalCenter: scoreText.verticalCenter
            color:"white"
            text: qsTr("___");
            font.pixelSize: 20;
        }

        Label {
            id: notRecognized
            anchors.left: recognizedNr.right
            anchors.leftMargin: 10
            anchors.verticalCenter: scoreText.verticalCenter
            font.pixelSize: 20;
            text: qsTr(" Nicht:");
            color:"red"
        }
        Label {
            id: notRecognizedNr
            anchors.left: notRecognized.right
            anchors.leftMargin: 2
            anchors.verticalCenter: scoreText.verticalCenter
            color:"red"
            text: qsTr("___");
            font.pixelSize: 20;
        }

        Label {
            id: elapsedTimeLabelId
            font.pixelSize: 30;
            font.bold: true
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: scoreText.verticalCenter
            text: scoreDisplay.fancyTimeFormat(scoreDisplay.secondsElapsed)
        }
        function undoLastRecognized() {
            recognizedNr.text = qsTr(signPad(--cntRecognized,3));
            notRecognizedNr.text = qsTr(signPad(++cntNotRecognized,3));
        }
        function incRecognized() {
            if (!lastEntryReached) cntEntry()
            recognizedNr.text = qsTr(signPad(++cntRecognized,3));

        }
        function incNotRecognized() {
            if (!lastEntryReached) cntEntry()
            notRecognizedNr.text = qsTr(signPad(++cntNotRecognized,3));

        }
        function signPad(num, places, sign = "_") {
          var zero = places - num.toString().length + 1;
          return Array(+(zero > 0 && zero)).join(sign) + num;
        }
        function initScoring() {
            cntAll = 0;
            allQuestions =  dataModel.countEntries();
            cntEntry()
            cntRecognized = 0;
            cntNotRecognized = 0;
            recognizedNr.text = qsTr(signPad(0,3));
            notRecognizedNr.text = qsTr(signPad(0,3));
            //cntAll = 0;
            //cntEntry()
        }

        function cntEntry() {
            constText.text = qsTr("Frage " + (++cntAll) + " von " + allQuestions + " Fragen" );
        }

        function showEntryCounter(onlyCounter) {
            scoreText.visible = true;
            if (onlyCounter) {
                recognized.visible = false;
                recognizedNr.visible = false;
                notRecognized.visible = false;
                notRecognizedNr.visible = false;
            }
            else {
                recognized.visible = true;
                recognizedNr.visible = true;
                notRecognized.visible = true;
                notRecognizedNr.visible = true;
            }
        }
    }


    function serializePackageOptions() {
        return {
            mainOrderIsSelected: showMainQuestionId.checked,
            revertedOrderIsSelected: showMainQuestionRevertedId.checked,
            sequentiellOrderIsSelected: presentInOrderId.checked
        };
    }

    function myCleanup() {
        customProgressBar.stopProgressBar()
        console.log("Cleaning up resources for", page);
        // Führe hier spezifische Aufräumarbeiten aus
        var dModel = []
        for (var i = 0; i < entryModelPackagesId.count; ++i) {
            var elem = entryModelPackagesId.get(i);
            dModel.push(entryModelPackagesId.get(i))
        }
        //push PackageLearning Modus
        dModel.push(singlePackageLearning);
        if (singlePackageLearning) {
            dModel.push(singlePackageLearningPackagename);
            dModel.push(singlePackageLearningParts);
            dModel.push(singlePackageLearningPackagenameIdx);
        } else {
            for (i=0;i<3;i++) dModel.push("");
        }
        var serializedGroupBox = serializePackageOptions();
        dModel.push(serializedGroupBox);
        settings.datastore = JSON.stringify(dModel)
        work_datastore = settings.datastore
        console.log("MyCleanupDatastore-Wert nach setzen:", settings.datastore);

    }

    Component.onDestruction: {
        myCleanup()
    }

    function myStartup(customStartupDatastore) {
        //console.debug("onCompleted");
        customProgressBar.stopProgressBar()
        appButtonRight.text           = "Start";
        appButtonLeft.visible         = false;
        repeatWrongEntriesId.enabled  = false;

        showScores(false);

        var packageList = dataModel.initExercisePackages();

        console.log("MyCleanup: customStartupDataStore", customStartupDatastore);
        if (settings.datastore) {
            console.log("MyStartup: Datastore-Wert nach setzen:", settings.datastore);
            //dataModel.debugPt();
            //var entryModelPackagesId = []
            var dModel
            if (customStartupDatastore) {
                listViewPacketsId.model.clear()
                dModel = JSON.parse(customStartupDatastore)
            } else {
                dModel = JSON.parse(settings.datastore)
            }
            for (var i = 0; i < dModel.length-5; ++i) {
                listViewPacketsId.model.append(dModel[i])
                var pName = dModel[i].name
                dataModel.addExercisePackage(dModel[i].name,dModel[i].isCustomPackage);
            }
            if (customStartupDatastore) {
                entryModelAvailablePackagesId.clear()
                entryModelAvailablePackagesId.loadData();
            }
            singlePackageLearning = dModel[dModel.length-5];
            singlePackageLearningPackagename = dModel[dModel.length-4];
            singlePackageLearningParts = dModel[dModel.length-3];
            singlePackageLearningPackagenameIdx = dModel[dModel.length-2];
            if (singlePackageLearning) {
                listViewPacketsId.setPackageParts(singlePackageLearningPackagename,singlePackageLearningParts,singlePackageLearningPackagenameIdx);
            }

            var orderOptions      = dModel[dModel.length-1];
            showMainQuestionId.checked = orderOptions.mainOrderIsSelected;
            showMainQuestionRevertedId.checked = orderOptions.revertedOrderIsSelected;
            presentInOrderId.checked = orderOptions.sequentiellOrderIsSelected;

        }
        startEvaluationId.setQuestionOptions(false);
        activateLearnListId.actualizeCountLearnList();
    }


    Component.onCompleted: {
        myStartup();
    }

    QtCore.Settings {
        id: settings
        category: "General"
        property string datastore: "user_value"
    }

    onHeightChanged: {
        var factor;
        if (height > width) {
            initHeightLongFormat = height
            factor = initHeightWideFormat / height;
        }
        else {
            initHeightWideFormat = height
            factor = initHeightLongFormat / height;
        }
        imageId.height /= factor;
        imageId.width  /= factor;
    }

    ListModel {
        id: entryModelPackagesId

        onCountChanged: {
            appButtonRight.enabled = true;
            if (count <= 0 ) {
                appButtonRight.enabled = false;
            }
        }
        function updateCountAtIndex(index, newCount) {
            if (index >= 0 && index < entryModelPackagesId.count) {
                entryModelPackagesId.setProperty(index, "count", newCount);
            } else {
                console.log("Index out of range");
            }
        }

    }


    Rectangle {
        id: startEvaluationId
        width: parent.width * 0.9;
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.05
        anchors.top:parent.top
        anchors.topMargin: 10
        anchors.bottom:navSection.top
        anchors.bottomMargin: 30
        color: "#D3DEE4"
        //color: "yellow"
        visible:true
        z:1



        GroupBox {
            id: gbLearnListId
            property bool expanded: false
            title: qsTr("GroupBox")
            width: parent.width
            height: parent.height * 0.35
            visible: false
            background: CustomBox {
                y: packetChoiceId.topPadding - packetChoiceId.padding
                width: page.width * 0.9
                height: parent.height - packetChoiceId.topPadding + packetChoiceId.padding
                borderColor: "black"
                borderWidth: 2
                textWidthFactor:0.4
            }

            label: Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.top
                anchors.bottomMargin: -height/2
                color: "transparent"
                width: parent.width * 0.5
                //height: title.font.pixelSize
                Text {
                    id: titleGBLearnListId
                    text: qsTr("Lernliste")
                    anchors.centerIn: parent
                    font.pixelSize: 12
                }
            }
            Label {
                id: lbTxt001
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: ""
                font.pixelSize: 16

            }
            Label {
                anchors.top: lbTxt001.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                //anchors.verticalCenter: parent.verticalCenter
                text: qsTr("aufrufen");
                font.pixelSize: 16

            }
        }

        GroupBox {
            id: packetChoiceId
            property bool expanded: false
            width: parent.width
            height: parent.height * 0.35
            background: CustomBox {
                id: custBoxId
                y: packetChoiceId.topPadding - packetChoiceId.padding
                width: page.width * 0.9
                height: parent.height - packetChoiceId.topPadding + packetChoiceId.padding
                borderColor: "black"
                borderWidth: 2
                textWidthFactor:0.35
            }

            Rectangle {
                id: label
                anchors.horizontalCenter: parent.horizontalCenter  // Zentriert das Rectangle horizontal in der GroupBox
                anchors.top: parent.top
                color: "transparent"
                width: parent.width * 0.5
                height: titleGBPacketsId.font.pixelSize * 2  // oder eine feste Höhe setzen

                Text {
                    id: titleGBPacketsId
                    text: qsTr("gewählte Übungspakete")
                    anchors.horizontalCenter: parent.horizontalCenter  // Zentriert den Text horizontal im Rectangle
                    anchors.bottom: parent.top
                    font.pixelSize: 14
                    font.bold: true
                    color: "black"  // Stellen Sie sicher, dass die Textfarbe auf einem transparenten Hintergrund sichtbar ist
                }
            }

            ListView {
                id: listViewPacketsId
                //anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top : parent.top
                anchors.topMargin: 20
                width: parent.width
                height : parent.height * 0.8
                property int delegateWidth: width * 0.80 ;
                property int delegateHeight: parent.height / 4  - 7;
                spacing: 5
                ScrollBar.vertical: ScrollBar {
                    policy: listViewPacketsId.contentHeight > listViewPacketsId.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    anchors.left: listViewPacketsId.left
                    anchors.leftMargin: 20
                    width: 20
                    active: true
                    background: Item {
                        Rectangle {
                            anchors.centerIn: parent
                            height: parent.height
                            width: parent.width * 0.2
                            color: 'grey'
                            radius: width / 2
                        }
                    }

                    contentItem: Rectangle {
                        radius: width / 3
                        color: 'yellow'
                    }

                }

                property int dragItemIndex: -1

                model: entryModelPackagesId

                delegate: Item {
                    id: delegateItem
                    property int my_width: listViewPacketsId.delegateWidth
                    width: my_width
                    anchors.horizontalCenter: {
                        if (parent.horizontalCenter) anchors.horizontalCenter = parent.horizontalCenter;
                    }
                    height: listViewPacketsId.delegateHeight
                    property double itemOpacity:1.0


                    Rectangle {
                        id: dragRect
                        width: delegateItem.width
                        height: delegateItem.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        border.color: Qt.darker(color)
                        radius: 15
                        color:"#eee"
                        opacity: {
                            opacity = delegateItem.itemOpacity
                        }
                        Row {

                            id: itemRowId
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3
                            Text {
                                id: itemRowIdTxt1
                                font.pixelSize: 14
                                text:(index === -1)?"":(isPackagePart)?"(P" + index + ") " + name:name
                            }
                            Text {
                                id: itemRowIdTxt2
                                font.pixelSize: 14
                                text: '(' + count + ')'
                            }

                        }
                        Component.onCompleted: {
                            var isPart = listViewPacketsId.model.get(index).isPackagePart;
                            if (isPart && index > 0) { //parts starts from 1 index
                                //delegateItem.activatePackagePart((index===1)?true:false,index);
                                width = width * 0.9
                                itemRowIdTxt1.font.pixelSize = 13
                                itemRowIdTxt1.font.italic = true
                                itemRowIdTxt2.font.pixelSize = 13
                                itemRowIdTxt2.font.italic = true
                                var isPartActive = listViewPacketsId.model.get(index).isPackagePartActive;
                                if (isPartActive) {
                                    delegateItem.opacity = 1;
                                }
                                else {
                                    delegateItem.opacity = 0.3;
                                }
                            }
                        }
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            drag.target: dragRect

                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            drag.onActiveChanged: {
                                if (mouseArea.drag.active) {
                                    listViewPacketsId.dragItemIndex = index;
                                }
                                dragRect.Drag.drop();
                            }
                            // Verwende formale Parameter für den onClicked-Handler
                            onClicked: (mouse) => {
                                console.log("mouse clicked");
                                if (mouse.button === Qt.LeftButton) {
                                    var itemScript = listViewPacketsId.createPopUpItemScript(index);
                                    var newObject = Qt.createQmlObject(itemScript, delegateItem);
                                    newObject.popup();
                                    if (Qt.platform.os === "ios") {
                                        newObject.x = dragRect.width / 10;
                                        newObject.y = dragRect.height / 2;
                                    }
                                } else if (mouse.button === Qt.RightButton) {
                                    console.log("Right");
                                }
                            }
                        }
                        states: [
                            State {
                                when: dragRect.Drag.active
                                ParentChange {
                                    target: dragRect
                                    parent: page
                                }

                                AnchorChanges {
                                    target: dragRect
                                    anchors.horizontalCenter: undefined
                                    anchors.verticalCenter: undefined
                                }

                            }
                        ]

                        Drag.active: mouseArea.drag.active
                        Drag.hotSpot.x: dragRect.width / 2
                        Drag.hotSpot.y: dragRect.height / 2

                    }
                    function activatePackagePart(activatePart,idxPart) {
                        opacity = (activatePart)?1:0.5
                        entryModelPackagesId.setProperty(idxPart,"isPackagePartActive",activatePart);
                        dataModel.setSinglePackageLearningPart(activatePart,idxPart-1);
                    }
                }

                function getMenuWidth(firstTextLen,secondTextLen) {
                    var textComputed = 0;
                    if (firstTextLen > secondTextLen) {
                        textComputed = firstTextLen
                    } else {
                        textComputed = secondTextLen
                    }
                    return textComputed + textComputed * 0.2;
                }

                function getMenuHeight(firstTextHeight) {
                    return (firstTextHeight * 2) + firstTextHeight * 0.2 +10;
                }


                function createPopUpItemScript(packageIdx) {
                    var itemScript =
                                'import QtQuick.Controls 2.15; import QtQuick 2.15;
                                Menu
                                {
                                    id: myContextMenu \n'
                    if (singlePackageLearning) {
                           itemScript +=  ' width: contTxt.paintedWidth + 10;height: contTxt.height
                           MenuItem {
                             id: control
                             text: qsTr("##text##");
                             contentItem: Text {
                                 anchors.fill: parent
                                 id: contTxt
                                 text: control.text
                                 font: control.font
                                 color: control.down ? "#17a81a" : "#21be2b"
                                 horizontalAlignment: Text.AlignHCenter
                                 verticalAlignment: Text.AlignVCenter
                             }
                             background: Rectangle {
                                 border.width: 1
                                 radius: 5
                             }
                             onTriggered: { ##func## }
                        }';

                        if (entryModelPackagesId.get(packageIdx).isPackagePart) {
                            // TODO: decorate MenuItem
                            if (entryModelPackagesId.get(packageIdx).isPackagePartActive) {
                                itemScript = itemScript.replace("##text##","Part-Deaktivieren")
                                itemScript = itemScript.replace("##func##","activatePackagePart(false," + packageIdx + ")")
                            } else {
                                itemScript = itemScript.replace("##text##","Part-Aktivieren")
                                itemScript = itemScript.replace("##func##","activatePackagePart(true," + packageIdx + ")")
                            }
                        } else {
                            itemScript = itemScript.replace("##text##","Packet-Lernmodus beeenden")
                            itemScript = itemScript.replace("##func##","listViewPacketsId.finishSinglePackageLearnig(false," + packageIdx + ")")

                        }

                    } else {
                        itemScript += ' width: listViewPacketsId.getMenuWidth(txt1.paintedWidth,txt2.paintedWidth)
                                    Rectangle {
                                        height: listViewPacketsId.getMenuHeight(txt1.paintedHeight);
                                        border.width: 1
                                        color: "#D3DEE4"
                                        Text {
                                            id: txt1
                                            anchors.top: parent.top
                                            anchors.topMargin: 5
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: "' + entryModelPackagesId.get(packageIdx).name + '"
                                        }
                                        Text {
                                            id: txt2
                                            anchors.bottom: parent.bottom
                                            anchors.bottomMargin: 5
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.topMargin: 5
                                            text: "-- Aufteilen in --"
                                        }
                                    }'
                        //dataModel.debugPt();
                        var parts = computeCountParts(entryModelPackagesId.get(packageIdx).count);
                        //dataModel.debugPt();
                        for (var z=0; z < parts.length; z++) {
                            var parList = "[";
                            for (var y=0; y < parts[z].length;y++) {
                                if (y > 0) {
                                  parList = parList + ","
                                }
                                parList = parList + "'" + parts[z][y] + "'";
                            }
                            parList = parList + "]";
                            itemScript +=
                                    'MenuItem {
                                         hoverEnabled: true
                                         Text {
                                             anchors.horizontalCenter: parent.horizontalCenter
                                             anchors.verticalCenter: parent.verticalCenter
                                             text: ' + '"' + (z+2) + '-Teile"
                                         }
                                         background: Rectangle {
                                            color: parent.down ? "#17a81a" : "#21be2b"
                                         }
                                         MouseArea {
                                             anchors.fill: parent
                                             hoverEnabled: true
                                             onEntered: {
                                                parent.background.color = "#f0f0f0"
                                             }
                                             onExited: {
                                                parent.background.color = "#21be2b"
                                             }
                                             onClicked: {
                                                listViewPacketsId.createPackageParts(' + '"' + entryModelPackagesId.get(packageIdx).name + '",' + parList + "," + packageIdx + ')
                                                myContextMenu.close()
                                             }
                                         }
                                     }';
                        }
                    }
                    return itemScript + "\n }"

                }
                                                               function countDigits(i)  {
                  return (i + "").length;
                }

                function computeCountParts(cntItems)
                {

                    var arr = [];
                    var leadingZeros = "0";
                    for(var i = 0; i < 10; i++) {
                        arr[i] = i;
                    }
                    arr.push(10);
                    console.log(arr[i]);
                    //dataModel.debugPt();
                    var parts = [];
                    if (cntItems > 7) {
                        if (cntItems === 8) {
                            parts[0] = [4,4];
                        }
                        else if (cntItems === 9) {
                            parts[0] = [5,4];
                        }
                        else {
                            //var mod = cntItems % 5;
                            //var div = parseInt(cntItems / 5);

                            var divider = 1;
                            do {
                              divider++;

                              var mod = cntItems % divider;
                              var div = parseInt(cntItems / divider);

                              if (div >= 5) {
                                  mod = cntItems % divider;
                                  var itemCount = [];
                                  for (var y=0; y < divider;y++) {
                                      if (mod > 0) {
                                         itemCount.push(div+1);
                                         mod--;
                                      }
                                      else {
                                         itemCount.push(div);
                                      }
                                      parts[divider-2]= itemCount;
                                  }
                                  parts[divider-2]= itemCount;
                              }
                            } while (div >= 5)
                            return parts;
                        }
                    }
                    return 0;
                } // end function computeCountParts

                function setPackageParts(packageName,packList,idxPackage) {
                    dataModel.setSinglePackageLearning(true,packList,packageName);
                    for (var i=0; i < packList.length; i++) {
                        var isPartActive = listViewPacketsId.model.get(i+1).isPackagePartActive;
                        dataModel.setSinglePackageLearningPart(isPartActive,i);
                    }
                    packetAvailableId.enabled = false;
                    packetAvailableId.opacity = 0.3;
                    singlePackageLearning = true;
                }

                function createPackageParts(packageName,packList,idxPackage)
                {
                    console.log("choice:packageName:<" + packageName + ">--packageList=" + packList)
                    //disable all other
                    //put to first
                    dataModel.debugPt();
                    dataModel.setSinglePackageLearning(true,packList,packageName);
                    for (var i=packList.length-1; i >= 0;i--) {
                        listViewPacketsId.model.insert(1,{"name":packageName,"count":parseInt(packList[i]),"isPackagePart":true,"isPackagePartActive":(i===0)?true:false});
                        dataModel.setSinglePackageLearningPart((i!== 0)?false:true,i)
                        //decorate
                    }
                    packetAvailableId.enabled = false;
                    packetAvailableId.opacity = 0.3;

                    singlePackageLearning = true;
                    singlePackageLearningPackagename    = packageName;
                    singlePackageLearningParts          = packList
                    singlePackageLearningPackagenameIdx = idxPackage
                }

                function finishSinglePackageLearnig(packetIdx) {
                    for (var i= listViewPacketsId.model.count-1; i >= 0;i--) {
                        if (listViewPacketsId.model.get(i).isPackagePart) {
                            listViewPacketsId.model.remove(i);
                        }
                    }
                    dataModel.setSinglePackageLearning(false,[],singlePackageLearningPackagename);
                    packetAvailableId.enabled = true;
                    packetAvailableId.opacity = 1
                    singlePackageLearning = false;
                }
            }
            Button {
                id: showAvailablePacketsId

                anchors.right: parent.right
                anchors.rightMargin: -10
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -8
                property bool show: true

                height: 35;
                width:  35;
                background: Rectangle {
                    color: "#D3DEE4"
                    //border.width: 3
                    //radius: 4
                }
                Image {
                    id:getPhoto
                    source: "qrc:/icons/arrow_up.png"
                    height: parent.height;
                    width:  parent.width;
                }

                onClicked: {
                    showActivePackages(show);
                }

                function showActivePackages(showPackages) {
                    if (showPackages) {
                        getPhoto.source = "qrc:/icons/arrow_down.png"
                        packetAvailableId.visible = false
                        showScores(true);
                        show = false
                    } else {
                        getPhoto.source = "qrc:/icons/arrow_up.png"
                        packetAvailableId.visible = true
                        showScores(false);
                        show = true
                    }
                }
            }
            DropArea {
                //id: dropArea
                anchors.fill: parent
                onDropped: {
                    if (listViewAvailablePacketsId.dragItemIndex >= 0) {
                        var listElement = listViewAvailablePacketsId.model.get(listViewAvailablePacketsId.dragItemIndex);
                        if (listElement.count > 0) {
                            listViewPacketsId.model.insert(0,listElement)
                            dataModel.addExercisePackage(listElement.name,listElement.isCustomPackage);
                            startEvaluationId.setQuestionOptions(true);
                            listViewAvailablePacketsId.model.remove(listViewAvailablePacketsId.dragItemIndex)
                            listViewAvailablePacketsId.dragItemIndex = -1;
                            listViewPacketsId.positionViewAtBeginning()
                        }
                    }
                }
            }
        }

        GroupBox {
            id: packetAvailableId
            property bool expanded: false
            title: qsTr("")
            anchors.top: packetChoiceId.bottom
            anchors.topMargin: parent.height * 0.03
            width: parent.width
            height: parent.height * 0.40
            background: CustomBox {
                y: packetChoiceId.topPadding - packetChoiceId.padding
                width: page.width * 0.9
                height: parent.height - packetChoiceId.topPadding + packetChoiceId.padding
                borderColor: "black"
                borderWidth: 2
                textWidthFactor:0.37
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter  // Zentriert das Rectangle horizontal in der GroupBox
                anchors.top: parent.top
                color: "transparent"
                width: parent.width * 0.5
                height: titleGBPacketsId.font.pixelSize * 2  // oder eine feste Höhe setzen

                Text {
                    text: qsTr("alle aktiven Pakete("  + entryModelAvailablePackagesId.count + ")")
                    anchors.horizontalCenter: parent.horizontalCenter  // Zentriert den Text horizontal im Rectangle
                    anchors.bottom: parent.top
                    font.pixelSize: 14
                    font.bold: true
                    color: "black"  // Stellen Sie sicher, dass die Textfarbe auf einem transparenten Hintergrund sichtbar ist
                }
            }
            ListModel {
                id: entryModelAvailablePackagesId

                Component.onCompleted: {
                    loadData();
                }

                function loadData() {
                    var list = dataModel.getPackages(false, true); // Pakete laden
                    for (var i = 0; i < list.length; i++) {
                        var packageName = list[i];
                        var isCustomPackage = false;

                        // Prüfen, ob das Präfix "CUST//" vorhanden ist
                        if (packageName.startsWith("CUST//")) {
                            isCustomPackage = true;
                            packageName = packageName.slice(6); // Präfix entfernen
                        }

                        // Prüfen, ob Paket schon existiert
                        if (!find(listViewPacketsId.model, packageName)) {
                            append(createListElement(packageName, dataModel.getPackageEntries(packageName,isCustomPackage), false, isCustomPackage));
                        }
                    }
                }

                function find(model, criteria) {
                    for (var i = 0; i < model.count; ++i) {
                        if (model.get(i).name === criteria) {
                            return true;
                        }
                    }
                    return false;
                }

                function createListElement(packageName, cnt, isPackagePartActive, isCustomPackage) {
                    return {
                        name: packageName,
                        count: cnt,
                        isPackagePart: false,
                        isPackagePartActive: isPackagePartActive, // Bleibt wie bisher
                        isCustomPackage: isCustomPackage // Neues Attribut hinzufügen
                    };
                }

                function updateCountWithInitValue(index) {
                    if (index >= 0 && index < entryModelAvailablePackagesId.count) {
                        // Überprüfen, ob isCustomPackage true ist
                        var isCustom = entryModelAvailablePackagesId.get(index).isCustomPackage;
                        var packageName = entryModelAvailablePackagesId.get(index).name;

                        // Zweiter Parameter basierend auf isCustomPackage setzen
                        var count = dataModel.getPackageEntries(packageName, isCustom);

                        // Wert aktualisieren
                        entryModelAvailablePackagesId.setProperty(index, "count", count);
                    } else {
                        console.log("Index out of range");
                    }
                }
            }

            ListView {
                id: listViewAvailablePacketsId
                spacing: 5
                clip:true
                width: parent.width
                height : parent.height * 0.8

                anchors.right: parent.right
                anchors.left: parent.left
                anchors.top : parent.top
                anchors.topMargin: 20
                property int delegateWidth:width * 0.8 ;
                property int delegateHeight: parent.height / 4  - 7;

                ScrollBar.vertical: ScrollBar {
                    policy: listViewAvailablePacketsId.contentHeight > listViewAvailablePacketsId.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    anchors.left: listViewAvailablePacketsId.left
                    anchors.leftMargin: 20
                    width: 20
                    active: true
                    background: Item {
                        Rectangle {
                            anchors.centerIn: parent
                            height: parent.height
                            width: parent.width * 0.2
                            color: 'grey'
                            radius: width / 2
                        }
                    }

                    contentItem: Rectangle {
                        radius: width / 3
                        color: 'yellow'
                    }
                }

                property int dragItemIndex: -1

                model: entryModelAvailablePackagesId

                delegate: Item {
                    id: delegateItem01
                    anchors.horizontalCenter: {
                        if (parent.horizontalCenter) anchors.horizontalCenter = parent.horizontalCenter;
                    }
                    width: listViewAvailablePacketsId.delegateWidth
                    height: listViewAvailablePacketsId.delegateHeight
                    Rectangle {
                        id: dragRect01
                        width: delegateItem01.width
                        height: delegateItem01.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        border.color: Qt.darker(color)
                        radius: 15
                        color:"#eee"

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3
                            Text {
                                font.pixelSize: 14
                                text: name
                            }
                            Text {
                                font.pixelSize: 14
                                text: '(' + count + ')'
                            }
                        }

                        MouseArea {
                            id: mouseArea01
                            anchors.fill: parent
                            drag.target: dragRect01

                            drag.onActiveChanged: {
                                if (mouseArea01.drag.active) {
                                    listViewAvailablePacketsId.dragItemIndex = index;
                                }
                                dragRect01.Drag.drop();
                            }
                        }

                        states: [
                            State {
                                when: dragRect01.Drag.active
                                ParentChange {
                                    target: dragRect01
                                    parent: page
                                }

                                AnchorChanges {
                                    target: dragRect01
                                    anchors.horizontalCenter: undefined
                                    anchors.verticalCenter: undefined
                                }

                            }
                        ]

                        Drag.active: mouseArea01.drag.active
                        Drag.hotSpot.x: dragRect01.width / 2
                        Drag.hotSpot.y: dragRect01.height / 2

                    }
                }
            }

            DropArea {
                //id: dropArea
                anchors.fill: parent
                onDropped: {
                    console.debug("index=" + listViewPacketsId.dragItemIndex)
                    if (listViewPacketsId.dragItemIndex >= 0) {
                        var listElement = listViewPacketsId.model.get(listViewPacketsId.dragItemIndex);
                        listViewAvailablePacketsId.model.insert(0,listElement);
                        dataModel.removeExercisePackage(listElement.name);
                        entryModelAvailablePackagesId.updateCountWithInitValue(0);
                        startEvaluationId.setQuestionOptions(true);
                        listViewPacketsId.model.remove(listViewPacketsId.dragItemIndex)
                        listViewPacketsId.dragItemIndex = -1;
                        listViewAvailablePacketsId.positionViewAtBeginning()
                    }
                }
            }
        }
        // Füge hier das ScoreDisplay ein
        ScoreDisplayComponent.ScoreDisplay {
            id: scoreDisplay
            anchors.top: packetChoiceId.bottom
            anchors.topMargin: 10
            width: parent.width
            height: parent.height * 0.38

        }
        GroupBox {
            id: optionenId
            title: qsTr("")
            width: startEvaluationId.width
            anchors.bottom: parent.bottom
            height:parent.height * 0.19

            background: CustomBox {
                y: optionenId.topPadding - optionenId.padding
                width: page.width * 0.9
                height: parent.height - optionenId.topPadding + optionenId.padding
                borderColor: "black"
                borderWidth: 2
                textWidthFactor:0.45
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter  // Zentriert das Rectangle horizontal in der GroupBox
                anchors.top: parent.top
                color: "transparent"
                width: parent.width * 0.5
                height: titleOptionenId.font.pixelSize * 2  // oder eine feste Höhe setzen

                Text {
                    id: titleOptionenId
                    text: qsTr("Optionen")
                    anchors.horizontalCenter: parent.horizontalCenter  // Zentriert den Text horizontal im Rectangle
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 5
                    font.pixelSize: 12
                    font.bold: true
                    color: "black"  // Stellen Sie sicher, dass die Textfarbe auf einem transparenten Hintergrund sichtbar ist
                }
            }


            CheckBox {
                id : repeatWrongEntriesId
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.1
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.05
                checked: false
                indicator.width: parent.height/5
                indicator.height: parent.height/5
                text: qsTr("Nur falsche vorlegen.")
                font.pixelSize: 12
                onCheckStateChanged: {
                    if (checked) {
                        learnModusId.text = qsTr("Lernmodus (Falsche Elemente einzeln anzeigen)")
                    }
                    else {
                        learnModusId.text = qsTr("Lernmodus (Alle Elemente einzeln anzeigen)")
                    }
                }
            }

            CheckBox {
                id : showMainQuestionId
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.1
                anchors.left: showMainQuestionRevertedId.left
                anchors.rightMargin: parent.width * 0.05
                checked: true
                indicator.width: parent.height/5
                indicator.height: parent.height/5
                text: qsTr("Direkte Fragen (Frage => Antwort)")
                font.pixelSize: 12
                onCheckStateChanged: {
                    startEvaluationId.setExcersizeEntries();
                    if (checked) {
                        if (showMainQuestionRevertedId.checked) {
                            startEvaluationId.setQuestionDisplayOption(2)
                        } else {
                            startEvaluationId.setQuestionDisplayOption(0)
                        }
                    } else if (showMainQuestionRevertedId.checked) {
                        startEvaluationId.setQuestionDisplayOption(1)
                    } else {
                        startEvaluationId.setQuestionDisplayOption(3)
                    }
                }
            }

            CheckBox {
                id : activateLearnListId
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.4
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.05
                checked: false
                indicator.width: parent.height/5
                indicator.height: parent.height/5
                text: qsTr("Lernliste abspielen") +  "(" + cnt + ")"
                font.pixelSize: 12
                property int cnt
                onCheckStateChanged: {
                    showScores(false);
                    if (checked) {
                        setCheckBoxes(false)
                        gbLearnListId.visible = true;
                        packetChoiceId.visible = false;
                        packetAvailableId.visible = false;
                        lbTxt001.text= qsTr("Die Einträge der Lernliste (" + cnt + ")");
                        dataModel.loadLearnListPackage();
                        appButtonRight.enabled = true;
                    } else {
                        setCheckBoxes(true)
                        gbLearnListId.visible = false;
                        packetChoiceId.visible = true;
                        packetAvailableId.visible = true;
                        dataModel.initExercisePackages();
                        for (var i= 0;i < entryModelPackagesId.count;i++) {
                            dataModel.addExercisePackage(entryModelPackagesId.get(i).name,entryModelPackagesId.get(i).customPackage);
                        }
                        startEvaluationId.setQuestionOptions(false)
                        if (entryModelPackagesId.count === 0) {
                            appButtonRight.enabled = false;
                        }
                    }
                }
                function setCheckBoxes(state) {
                    if (showMainQuestionId.visible) {
                        showMainQuestionId.enabled = state
                    }
                    if (showMainQuestionRevertedId.visible) {
                        showMainQuestionRevertedId.enabled = state
                    }
                }
                function actualizeCountLearnList () {
                    cnt = LearnListEntryManager.getTotalPositionCount();
                    if (cnt <= 0 ) {
                        activateLearnList(false)
                    } else {
                        activateLearnList(true)
                        if (checked) {
                            //adjust act list. remove all entries that are no longer on the learning list
                            dataModel.adjustEntryListWithLearnList();
                            lbTxt001.text= qsTr("Die Einträge der Lernliste (" + cnt + ")");
                        }
                    }
                    return cnt;
                }
                function activateLearnList(activate) {
                    //activateLearnListId.checked = activate;
                    activateLearnListId.enabled = activate
                    clearLearnListButton.visible = activate;
                }

            }

            // Neuer Button neben der CheckBox
            Button {
                id: clearLearnListButton
                height: implicitHeight * 0.6
                text: qsTr("Leere Lernliste")
                font.pixelSize: 12
                anchors.verticalCenter: activateLearnListId.verticalCenter
                anchors.left: activateLearnListId.right
                onClicked: {
                    confirmDialog.open()
                }
            }

            // Bestätigungsdialog
            MessageDialog {
                id: confirmDialog
                title:"Hinweis"
                text: qsTr("Die Lernliste enthält Einträge.")
                informativeText: qsTr("Möchten Sie wirklich alle Einträge löschen?")
                buttons: MessageDialog.Ok | MessageDialog.Cancel  // Standard-Buttons

                onAccepted: {
                    console.log("Einträge gelöscht.")
                    LearnListEntryManager.clearAllEntries()  // Aktion bei Bestätigung
                    activateLearnListId.cnt = 0
                    activateLearnListId.activateLearnList(false);
                    activateLearnListId.checked = false
                }

                onRejected: {
                    console.log("Aktion abgebrochen.")  // Aktion bei Abbrechen
                }
            }

            CheckBox {
                id : showMainQuestionRevertedId
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.4
                anchors.right: parent.right
                anchors.rightMargin: parent.width * 0.05
                indicator.width: parent.height/5
                indicator.height: parent.height/5
                text: qsTr("Indirekte Fragen (Antwort als Frage => Antwort)")
                font.pixelSize: 12
                checked: false
                onCheckStateChanged: {
                    startEvaluationId.setExcersizeEntries();
                    if (checked) {
                        if (showMainQuestionId.checked) {
                            startEvaluationId.setQuestionDisplayOption(2)
                        } else {
                            startEvaluationId.setQuestionDisplayOption(1)
                        }
                    } else if (showMainQuestionId.checked) {
                        startEvaluationId.setQuestionDisplayOption(0)
                    } else {
                        startEvaluationId.setQuestionDisplayOption(3)
                    }
                }
            }


            CheckBox {
                id : presentInOrderId
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.7
                anchors.left: showMainQuestionRevertedId.left
                indicator.width: parent.height/5
                indicator.height: parent.height/5
                text: qsTr("In Reihenfolge vorlegen")
                font.pixelSize: 12
                checked: false
                onCheckStateChanged: {
                    dataModel.setDisplayExercizesInSequenceInActPackageIdx(0,checked);
                }
            }


            CheckBox {
                id : learnModusId
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.7
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.05
                onCheckedChanged: {
                    if (checked) {
                        learnModeState = Exercise.LearnModeFirst;
                        appButtonRight.text = "Anzeigen"
                    }
                    else {
                        learnModeState = Exercise.NotInLearnMode
                        appButtonRight.text = "Start"
                    }
                }
                checked: false
                indicator.width: parent.height/5
                indicator.height: parent.height/5
                text: qsTr("Lern-Modus (Alle Elemente einzeln anzeigen)")
                font.pixelSize: 12;
            }
        }

        function setQuestionDisplayOption (option) {
            dataModel.setQuestionOptionInActPackageIdx(0,option);
        }

        function setQuestionOptions(init) {
            //check count of actual selected Packages
            showMainQuestionRevertedId.visible = false;
            showMainQuestionId.visible = false;
            //presentInOrderId.visible = false;
            if (dataModel.sizeActExercisePackages() === 1 ) {
                var packageDesc = dataModel.getActPackageDescriptionIdx(0)
                if (packageDesc.isXMLDescripted) {
                    showMainQuestionRevertedId.enabled = true;
                    showMainQuestionId.visible = true;
                    if (!packageDesc.mainQuestionReverse) {
                       showMainQuestionRevertedId.checked = false;
                       showMainQuestionRevertedId.enabled = false;
                    } else {
                        showMainQuestionRevertedId.enabled = true;
                    }
                    showMainQuestionRevertedId.visible = true;
                    //presentInOrderId.visible = true;
                    if (init) {
                        if (packageDesc.mainQuestions > 0) {
                            showMainQuestionId.checked = showMainQuestionId.checked || init;
                        }
                        if (packageDesc.reverseQuestions > 0) {
                            showMainQuestionRevertedId.checked = showMainQuestionRevertedId.checked || init;
                        }
                        if (packageDesc.displayExercizesInSequence) {
                            presentInOrderId.checked = presentInOrderId.checked || init;
                        }
                        var entries = 0;
                        if (showMainQuestionId.checked) entries += packageDesc.mainQuestions;
                        if (showMainQuestionRevertedId.checked) entries += packageDesc.reverseQuestions ;
                        entryModelPackagesId.updateCountAtIndex(0,entries);
                    }
                    if (showMainQuestionId.checked && showMainQuestionRevertedId.checked) {
                        dataModel.setQuestionOptionInActPackageIdx(0,2)
                    } else if (showMainQuestionId.checked) {
                        dataModel.setQuestionOptionInActPackageIdx(0,0); //main
                    } else if (showMainQuestionRevertedId.checked) {
                        dataModel.setQuestionOptionInActPackageIdx(0,1)
                    } else {
                        dataModel.setQuestionOptionInActPackageIdx(0,3)
                    }
                    dataModel.setDisplayExercizesInSequenceInActPackageIdx(0,presentInOrderId.checked)
                }
            }
        }

        function setExcersizeEntries() {

            var packageDesc = dataModel.getActPackageDescriptionIdx(0)
            var entries = 0;
            if (packageDesc.isXMLDescripted) {
                if (showMainQuestionId.checked) entries += packageDesc.mainQuestions;
                if (showMainQuestionRevertedId.checked) entries += packageDesc.reverseQuestions ;
                entryModelPackagesId.updateCountAtIndex(0,entries);
            }
        }

        function setOKScore() {
            var  percentOK = (scoreText.cntRecognized * 100) / dataModel.countEntries() ;
            recognized.text =  "Richtig " + scoreText.cntRecognized;
            //scoreDisplay.txtPercentOKIdText = Math.round(percentOK) + "%";
        }

        function setNotOKScore() {
            var  percentNotOK = (scoreText.cntNotRecognized * 100) / dataModel.countEntries() ;
            notRecognized.text =  "Falsch " + scoreText.cntNotRecognized;
            //scoreDisplay.txtPercentWrongIdText = Math.round(percentNotOK) + "%";

        }
    }
    Rectangle {
        id: container
        width: parent.width * 0.9
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.05
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.05
        anchors.bottom: navSection.top
        //anchors.bottomMargin: parent.height * 0.05

        //property int containerHeight: (navSection.y - navSection.height - parent.y)
        //height: containerHeight
        visible: false
        color:"transparent"

        // MouseArea for handling swipe only
        /****/
        MouseArea {
            id: swipeArea
            anchors.fill: parent
            preventStealing: true
            //z:10
            property bool isSwipe: false

            onPressed: {
                if ((exerciseModeState === Exercise.ExerciseModeChoose) || (learnModeState !== Exercise.NotInLearnMode)) {
                    isSwipe = true; // Reset swipe detection
                }
            }

            onReleased: {
                if (isSwipe) {
                    // Trigger swipe functionality
                    container.handleSwipeLeft();
                    isSwipe = false
                }
            }
        }
        /**/

        // Function to handle swipe left action
        function handleSwipeLeft() {
            // Call the method to handle the logic of appButtonRight
            handleAppButtonRightClick();
        }

        Rectangle {
            id: questionArea
            width: parent.width
            height: parent.height * 0.12
            anchors.top: parent.top
            anchors.topMargin: 15
            color: "#C2B5B5" // Hitnergrundfarbe des Rechtecks
            visible: true
            border.color: "black" // Farbe der Grenze
            border.width: 2 // Breite der Grenze

            Column {
                anchors.centerIn: parent
                width: parent.width - 20

                Text {
                    id: questionText
                    text: ""
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    id: subjectText
                    text: ""
                    color: "black"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    id: followingText
                    text: ""
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.NoWrap
                    textFormat: Text.PlainText  // damit „< >“ nicht als HTML interpretiert werden
                    anchors.horizontalCenter: parent.horizontalCenter
                    renderType: Text.NativeRendering   // (optional) stabilere Metriken

                }
            }

            function fitFontToBoxPx(item, maxH, maxW, startPx, minPx, capPx) {
                const min = Math.max(1, minPx || 6)
                const cap = Math.max(min, capPx || 512)

                // wir arbeiten *nur* mit pixelSize – punktgrößen bitte nicht mischen
                item.font.pixelSize = Math.max(min, Math.round(startPx || 16))

                function fits(px) {
                    item.font.pixelSize = px
                    const w = widthOf(item)
                    const h = heightOf(item)
                    return h <= maxH && (maxW <= 0 || w <= maxW)
                }

                // obere Schranke finden (exponentiell erhöhen bis es nicht mehr passt oder cap)
                let lo = min
                let hi = Math.min(cap, Math.max(item.font.pixelSize, min))
                while (hi < cap && fits(hi)) {
                    lo = hi
                    hi = Math.min(cap, Math.floor(hi * 1.5) + 1)
                }
                if (lo < min) lo = min
                if (hi < lo) hi = lo

                // binäre Suche: größtes px das noch passt
                let best = lo
                let L = lo, R = hi
                for (let i = 0; i < 20; i++) {           // 2^20 ~ fein genug
                    const mid = Math.floor((L + R) / 2)
                    if (fits(mid)) { best = mid; L = mid + 1 } else { R = mid - 1 }
                }
                item.font.pixelSize = best
            }

            function writeQuestion(question, subject, subjektPrefix) {
                const h = questionArea.height
                const parts = question.split("[FrageSubjekt]")

                const qMaxPx  = Math.round(h * 0.15)
                const qNoSub  = Math.round(h * 0.40)
                const sMaxPx  = Math.round(h * 0.40)
                const fMaxPx  = Math.round(h * 0.30)

                if (parts.length > 1) {
                    questionText.text = (parts[0] || "") + subjektPrefix
                    subjectText.text  = "<" + subject + ">"
                    followingText.text = (parts[1] || "") + "?"

                    // 1) Links/Rechts nur auf Höhe fitten
                    fitFontToBoxPx(questionText,  h * 0.30, 0, qMaxPx)
                    fitFontToBoxPx(followingText, h * 0.30, 0, fMaxPx)

                    // 2) Verfügbare Breite für das Subjekt (100% – links – rechts – kleine Luft)
                    const gap = 2
                    const usedLeft  = widthOf(questionText)
                    const usedRight = widthOf(followingText)
                    const avail = Math.max(0, questionArea.width - usedLeft - usedRight - gap)
                    // 3) Subjekt: Höhe *und* Breite fitten, maximal groß
                    fitFontToBoxPx(subjectText, h * 0.40, avail, sMaxPx)

                } else {
                    questionText.text = question
                    subjectText.text  = ""
                    followingText.text = ""
                    fitFontToBoxPx(questionText, h * 0.40, 0, qNoSub)
                }
            }
        }
        Rectangle {
            id: answerArea
            anchors.top: questionArea.top
            width: parent.width
            height: parent.height * 0.12
            border.color: "black" // Farbe der Grenze
            color: "#CDEEBF" // Hintergrundfarbe des Bildes
            visible: false
            border.width: 2 // Breite der Grenze

            Text {
                id: answerHeader
                text: "Antwort"
                color: "#484C49"
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10
            }

            Text {
                id: answerText
                text: ""
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: answerHeader.bottom
                // Anpassung der vertikalen Position
                anchors.verticalCenterOffset: (answerArea.height - answerHeader.height - answerText.height) / 2 - answerText.height / 2
            }

            function adjustFontSizeToFit(textWebPageUrl, maxHeight, initialFontSize) {
                textWebPageUrl.font.pointSize = initialFontSize;
                while (textWebPageUrl.height > maxHeight && textWebPageUrl.font.pointSize > 1) {
                    textWebPageUrl.font.pointSize -= 1;
                }
            }

            function writeAnswer(answer) {
                // Texte setzen
                answerText.text = answer;

                // Startgrößen (in px, nicht pointSize mischen!)
                const H = answerArea.height;
                const W = Math.max(0, answerArea.width - 2); // kleine Luft
                const headerStartPx = Math.round(H * 0.20);
                const textStartPx   = Math.round(H * 0.30);

                // 1) Header: max. 30% Höhe, volle Breite
                questionArea.fitFontToBoxPx(answerHeader, H * 0.30, W, headerStartPx, 6, 512);

                // 2) Text: max. 60% Höhe, volle Breite
                questionArea.fitFontToBoxPx(answerText,   H * 0.60, W, textStartPx,   6, 1024);

                // 3) Block (Header+Text) vertikal in answerArea zentrieren
                const blockH = answerHeader.height + answerText.height;
                const topY   = Math.max(0, (H - blockH) / 2);

                // y-Position direkt setzen (achte darauf, dass keine kollidierenden anchors aktiv sind)
                answerHeader.anchors.top = undefined;
                answerText.anchors.top   = undefined;
                answerText.anchors.verticalCenter = undefined;

                answerHeader.y = topY;
                answerText.y   = topY + answerHeader.height;
            }
            Rectangle {
                id: answerAreaQuestionTxt
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: 15
                width: parent.height
                height: parent.height * 1 / 4
                color: "transparent" // Hintergrundfarbe des Bildes

                property string textToShow

                TextMetrics {
                    id: txtMeter
                    font.bold: true
                    font.pixelSize: 14 // Setze initiale Schriftgröße auf maximal 12
                    text: answerAreaQuestionTxt.textToShow

                    onTextChanged: {
                        // Verkleinere die Schriftgröße, aber nicht unter 12 Pixel
                        while (txtMeter.width > answerAreaQuestionTxt.width && txtMeter.font.pixelSize > 7) {
                            txtMeter.font.pixelSize--;
                        }
                        // Vergrößere die Schriftgröße, aber nicht über 12 Pixel
                        while (txtMeter.width < answerAreaQuestionTxt.width && txtMeter.font.pixelSize < 7) {
                            txtMeter.font.pixelSize++;
                        }
                    }
                }

                // Text-Element, das in der Größe angepasst und zentriert wird
                Text {
                    anchors.centerIn: parent // Zentriert das Text-Element
                    font: txtMeter.font
                    text: answerAreaQuestionTxt.textToShow
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap // Damit der Text bei Bedarf umbricht
                }
            }
            Rectangle {
                id: answerAreaQuestionImg
                anchors.top: answerAreaQuestionTxt.bottom
                anchors.horizontalCenter: answerAreaQuestionTxt.horizontalCenter
                anchors.topMargin: 10
                height: parent.height - answerAreaQuestionTxt.height - anchors.topMargin - 10 // 10px Abstand zum unteren Rand
                anchors.bottomMargin: 10 // Unterer Rand von 10px
                color: "transparent"
                visible: true
                /*
                Image {
                    id: answerAreaQuestionImage
                    height: parent.height / 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    visible: true
                    //fillMode: Image.PreserveAspectFit
                    source: ""
                }
                */
            }
        }
        Image {
            id: imageId
            anchors.top: questionArea.top
            anchors.topMargin: 4
            anchors.bottom: parent.bottom
            anchors.bottomMargin: customProgressBar.height + 50
            anchors.left: parent.left
            anchors.right: parent.right
            visible: true
            fillMode: Image.PreserveAspectFit
            source: ""

            onStatusChanged: if (status === Image.Ready) updateExcludeRects()

            property var  excludeAereaList: [] // Liste von ExcludeAerea-Objekten

            function updateExcludeRects() {
                // Nur rechnen, wenn das Bild fertig ist
                if (imageId.status !== Image.Ready || imageId.paintedWidth <= 0 || imageId.paintedHeight <= 0)
                    return;

                // vorhandene Overlays entfernen
                for (var i = excludeRectContainer.children.length - 1; i >= 0; i--) {
                    excludeRectContainer.children[i].destroy();
                }

                if (!excludeAereaList || excludeAereaList.length === 0)
                    return;

                // PreserveAspectFit: ein einheitlicher Scale + Offsets (Letterboxing)
                var scale = imageId.paintedWidth / imageId.sourceSize.width;
                var offX  = (imageId.width  - imageId.paintedWidth ) / 2;
                var offY  = (imageId.height - imageId.paintedHeight) / 2;

                for (var i = 0; i < excludeAereaList.length; i++) {
                    var area = excludeAereaList[i];

                    var rectX = offX + area.rect.x      * scale;
                    var rectY = offY + area.rect.y      * scale;
                    var rectW =        area.rect.width  * scale;
                    var rectH =        area.rect.height * scale;

                    var rectColor      = area.color;
                    var rectTextColor  = area.color;
                    var rectBorderWith = 2;
                    var rectBorderColor = "black";
                    var showQuestionText = false;

                    if (area.isBackgroundRectancle) {
                        rectBorderWith   = 0;
                        rectBorderColor  = pageRectId.backColorPage;
                        rectColor        = pageRectId.backColorPage;
                        showQuestionText = true;
                    }

                    rectangleComponent.createObject(excludeRectContainer, {
                        x: rectX,
                        y: rectY,
                        width: rectW,
                        height: rectH,
                        rotation: area.rotationAngle,   // wird gleich um die Mitte rotiert (siehe Patch 2)
                        backColor: rectColor,
                        textColor: rectTextColor,
                        borderWidth: rectBorderWith,
                        borderColor: rectBorderColor,
                        showQuestionText: showQuestionText
                    });
                }
            }
            Component.onCompleted: {
                //setRealImageDimensions()
            }

            onWidthChanged: updateExcludeRects();
            onHeightChanged: updateExcludeRects();

            // Container für dynamisch erstellte Rechtecke
            Item {
                id: excludeRectContainer
                anchors.fill: parent
            }

            // Definition des Rectangle-Components, das dynamisch erzeugt wird
            Component {
                id: rectangleComponent
                Rectangle {
                    property int borderWidth: 2
                    property string borderColor: "black"
                    // Text-Props
                    property bool   showQuestionText: true
                    property color  backColor: "black"
                    property color  textColor: "black"

                    antialiasing: false
                    color: backColor
                    border.color: borderColor
                    border.width: borderWidth
                    // zentrierter „?“-Teppich, einzeilig, ~90% der Rechteckgröße
                    //erstmal raus
                    /*
                    Text {
                        id: q
                        anchors.centerIn: parent
                        width:  parent.width  * 0.8
                        height: parent.height * 0.8
                        visible: parent.showQuestionText
                        font.family: "monospace"

                        color: parent.textColor
                        wrapMode: Text.NoWrap
                        elide: Text.ElideNone
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment:   Text.AlignVCenter
                        renderType: Text.NativeRendering

                        // WICHTIG: niemals 0/NaN
                        font.pixelSize: Math.max(1, Math.floor(parent.height * 0.8))

                        // Ergebnis
                        property string computedText: ""
                        text: computedText

                        // --- Messung per TextMetrics (kein Scenegraph-Layout nötig) ---
                        TextMetrics {
                            id: measure
                            font: q.font
                            text: ""
                            elide: Text.ElideNone
                        }

                        // Cache für Strings
                        property var _cache: ({})
                        function _qs(n) { if (!_cache[n]) _cache[n] = Array(n + 1).join("?"); return _cache[n]; }

                        function widthOf(n) {
                            measure.text = _qs(n);
                            var w = measure.advanceWidth;                 // stabiler als paintedWidth
                            return (isFinite(w) && w >= 0) ? w : 1e12;    // Guard gegen NaN
                        }

                        // Reentrancy-Guard gegen Kettenevents
                        property bool _busy: false

                        function recompute() {
                            if (_busy) return;
                            _busy = true;
                            try {
                                const W = q.width;
                                if (!(W > 0)) { computedText = ""; return; }

                                const EPS = 1;       // kleine Toleranz in px
                                const MAX = 20000;   // harte Obergrenze

                                // 1) Exponentiell hoch
                                let low = 0, high = 1;
                                while (high < MAX && widthOf(high) <= W + EPS) { low = high; high <<= 1; }

                                // 2) Binärsuche
                                while (low + 1 < high) {
                                    const mid = (low + high) >> 1;
                                    if (widthOf(mid) <= W + EPS) low = mid; else high = mid;
                                }

                                // 3) Letztes bisschen „auffüllen“
                                while (low + 1 <= MAX && widthOf(low + 1) <= W + EPS) low++;

                                computedText = _qs(Math.max(1, low));
                            } finally {
                                _busy = false;
                            }
                        }

                        Component.onCompleted: recompute()
                        onWidthChanged:        recompute()
                        onHeightChanged:       recompute()
                        onFontChanged:         recompute()
                        onVisibleChanged:      if (visible) recompute()
                    }
                    **/
                }
            }
        }

        function setXMLBasedMode(xmlMode) {
            if (xmlMode) {
               imageId.anchors.top = questionArea.bottom
               questionArea.visible = true;
               answerArea.visible = true;
               imageId.height = container.containerHeight * 0.6
               imageId.width = container.width * 0.6
            } else {
                imageId.anchors.top = container.top
                imageId.height = container.containerHeight
                imageId.width = container.width
                questionArea.visible = false;
                answerArea.visible = false;
            }
        }
        // Dünne Linie unterhalb des Bildes
        Rectangle {
            id: imageLicenseSeparator
            height: 1
            width: imageId.paintedWidth
            color: "#808080"                // dezentes Grau
            anchors.horizontalCenter: imageId.horizontalCenter
            anchors.top: imageId.top
            anchors.topMargin: (imageId.height - imageId.paintedHeight) / 2
                             + imageId.paintedHeight + 10
            z: imageId.z + 1
            visible: licencelink.visible    // nur zeigen, wenn Lizenztext sichtbar ist
        }
        Rectangle {
            id: licencelink
            z: imageId.z + 1
            width: imageId.paintedWidth
            anchors.top: imageLicenseSeparator.bottom
            //anchors.topMargin: (imageId.height - imageId.paintedHeight) / 2 + imageId.paintedHeight + 2
            anchors.horizontalCenter: imageId.horizontalCenter
            height: 25
            color: "transparent"

            property bool isQuestionImage: true
            property var linkPositions: [] // Speichert die Positionen und URLs der Links

            Text {
                id: licensceInfoId
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter  // Horizontales Zentrieren im parent
                anchors.topMargin: 2
                text: ""
                color: "black"
                font.pointSize: 10
                textFormat: Text.RichText
                renderType: Text.NativeRendering   // präzisere Glyph-Layouts
                //wrapMode: Text.WordWrap            // wenn du umbrechen lässt
                // Aktiviert den Link bei direktem Klick auf den Text
                onLinkActivated: function(link) {
                    licencelink.showLink(link);
                }
            }

            // Maussteuerung exakt über dem Text
            MouseArea {
                id: linkMouseArea
                anchors.fill: licensceInfoId          // exakt gleiche Fläche
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                cursorShape: hoveredHref ? Qt.PointingHandCursor : Qt.ArrowCursor

                // aktuell „getroffener“ href (genau der Wert aus dem <a href="...">)
                property string hoveredHref: ""

                // kleine vertikale Toleranz, falls Baseline knapp verfehlt wird
                property int vTol: 6
                property int vStep: 2

                onPositionChanged: (mouse) => {
                    const p = mapToItem(licensceInfoId, mouse.x, mouse.y);
                    let href = licensceInfoId.linkAt(p.x, p.y);

                    // vertikale Toleranz prüfen
                    if (!href) {
                        for (let dy = -vTol; dy <= vTol && !href; dy += vStep) {
                            href = licensceInfoId.linkAt(p.x, Math.max(0, Math.min(p.y + dy, licensceInfoId.height - 1)));
                        }
                    }

                    hoveredHref = href || "";
                    cursorShape = hoveredHref ? Qt.PointingHandCursor : Qt.ArrowCursor;
                }

                onClicked: (mouse) => {
                    if (!hoveredHref) return;
                    licencelink.showLink(hoveredHref);   // deine bestehende Normalisierung/Öffnen
                }
            }
            // ------- Helper: HTML Escapes -------
            function escapeHtml(s) {
                if (s === undefined || s === null) return "";
                return String(s)
                        .replace(/&/g, "&amp;")
                        .replace(/</g, "&lt;")
                        .replace(/>/g, "&gt;");
            }
            function escapeHtmlAttr(s) {
                if (s === undefined || s === null) return "";
                return String(s)
                        .replace(/&/g, "&amp;")
                        .replace(/"/g, "&quot;");
            }

            // ------- Helper: URL normalisieren für href und zum Öffnen -------
            function _decodeAmp(u) {
                // doppelt kodiertes &amp; entschärfen (2x reicht praktisch)
                return String(u).replace(/&amp;/gi, '&').replace(/&amp;/gi, '&');
            }
            function normalizeForHref(raw) {
                if (!raw) return "";
                var u = _decodeAmp(String(raw).trim());
                if (u.indexOf("//") === 0) u = "https:" + u;
                else if (!/^https?:\/\//i.test(u)) u = "https://" + u;
                // am Ende einmal korrekt fürs HTML-Attribut escapen
                return escapeHtmlAttr(u);
            }
            function normalizeForOpen(raw) {
                if (!raw) return "";
                var u = _decodeAmp(String(raw).trim());
                if (u.indexOf("//") === 0) u = "https:" + u;
                else if (!/^https?:\/\//i.test(u)) u = "https://" + u;
                // Leerzeichen absichern
                return u.replace(/\s/g, "%20");
            }
            function showLink(link) {
                if (!link) return;

                let u = String(link).trim();

                // HTML-Entities entschärfen (auch doppelte)
                // erst mehrfach &amp; -> &, dann normalisieren Leerzeichen
                u = u.replace(/&amp;/gi, '&');
                u = u.replace(/&amp;/gi, '&'); // falls doppelt kodiert

                // Protokoll ergänzen
                if (u.startsWith("//")) {
                    u = "https:" + u;
                } else if (!/^https?:\/\//i.test(u)) {
                    u = "https://" + u;  // nackte Domains wie "commons.wikimedia.org/..."
                }

                // Leerzeichen absichern
                u = u.replace(/\s/g, "%20");

                // Öffnen
                if (typeof mainFocusScope?.showWebPage === "function") {
                    mainFocusScope.showWebPage(u);
                } else {
                    Qt.openUrlExternally(u);
                }
            }

            // ------- Öffentliche API: von außen aufrufen (z.B. nach Bild/Seite-Laden) -------
            function setLicenseInfo(isQuestionImage) {
                var licenceInfo = dataModel.getActLicenceInfo && dataModel.getActLicenceInfo();
                if (licenceInfo) {
                    buildLicenceInfoLink(licensceInfoId, licenceInfo, isQuestionImage);
                } else {
                    licensceInfoId.text = "";
                    licencelink.linkPositions = [];
                }
            }

            function estimateTextWidth(text, font) {
                // Schätzfunktion für die Breite eines Texts basierend auf der Zeichenanzahl und Punktgröße
                var averageCharWidth = font.pointSize * 0.6; // Durchschnittliche Breite eines Zeichens
                return text.length * averageCharWidth;
            }

            function ensureHttps(u) {
                if (!u) return "";
                if (u.startsWith("//")) return "https:" + u;
                if (u.startsWith("http://") || u.startsWith("https://")) return u;
                // falls mal nur ein Pfad kommt, versuche https:// davor
                return "https://" + u.replace(/^\/+/, "");
            }
            function hrefToOpenUrl(raw) {
                if (!raw) return "";
                var u = String(raw);

                // &amp;amp; -> &amp; -> &
                for (var i = 0; i < 3; ++i) u = u.replace(/&amp;/gi, '&');

                // Protokoll ergänzen
                if (u.indexOf("//") === 0) u = "https:" + u;
                else if (!/^https?:\/\//i.test(u)) u = "https://" + u.replace(/^\/+/, "");

                // Leerzeichen absichern
                u = u.replace(/\s/g, "%20");

                return u;
            }

            function openHref(rawHref) {
                var url = hrefToOpenUrl(rawHref);
                if (!url) return;
                if (typeof mainFocusScope.showWebPage === "function") mainFocusScope.showWebPage(url);
                else Qt.openUrlExternally(url);
            }

            // ------- Kernfunktion: baut den Text (mit/ohne Links je nach Daten) -------
            //  licenceInfo Felder (deinem Schema gemäß):
            //   - infoURLFrage / infoURLAntwort
            //   - imageFrageBildDescription / imageAntwortBildDescription
            //   - imageFrageAuthor / imageAntwortAuthor         -> "Name[URL]" oder nur "Name"
            //   - imageFrageLizenz / imageAntwortLizenz         -> "Lizenzname[URL]" oder nur "Lizenzname"
            function buildLicenceInfoLink(textItem, licenceInfo, isQuestion, withoutAuthor) {
                if (!textItem || !licenceInfo) return;

                // --- Helper: Hostname extrahieren (ohne www.)
                function extractHostname(u) {
                    if (!u) return "";
                    // bereits normalisiert für Öffnen
                    var m = String(u).match(/^https?:\/\/([^\/?#:]+)([:\/?#]|$)/i);
                    var host = m ? m[1] : "";
                    // "www." entfernen
                    host = host.replace(/^www\./i, "");
                    return host;
                }
                function isWikipediaHost(host) {
                    host = String(host || "").toLowerCase();
                    // trifft z. B. de.wikipedia.org, en.m.wikipedia.org, wikipedia.org
                    return /(^|\.)wikipedia\.org$/.test(host);
                }

                // --- URLs / Rohdaten holen ---
                var wikiUrl   = isQuestion ? licenceInfo.infoURLFrage               : licenceInfo.infoURLAntwort;
                var fileUrl   = isQuestion ? licenceInfo.imageFrageBildDescription  : licenceInfo.imageAntwortBildDescription;

                var authorRaw = isQuestion ? licenceInfo.imageFrageAuthor           : licenceInfo.imageAntwortAuthor;
                if (typeof isHideAuthor === "function" && isHideAuthor() && isQuestion) {
                    authorRaw = ""; // Autor ggf. in der Frage ausblenden
                }
                var licenseRaw= isQuestion ? licenceInfo.imageFrageLizenz           : licenceInfo.imageAntwortLizenz;

                // --- Autor parsen: "Name[URL]" oder nur "Name"
                var authorName = "";
                var authorUrl  = "";
                if (authorRaw && !withoutAuthor) {
                    var mA = String(authorRaw).match(/^(.*?)\[(.*?)\]$/);
                    if (mA) { authorName = (mA[1] || "").trim(); authorUrl = (mA[2] || "").trim(); }
                    else    { authorName = String(authorRaw).trim(); }
                }

                // --- Lizenz parsen: "Lizenz[URL]" oder nur "Lizenz"
                var licenseName = "";
                var licenseUrl  = "";
                if (licenseRaw) {
                    var mL = String(licenseRaw).match(/^(.*?)\[(.*?)\]$/);
                    if (mL) { licenseName = (mL[1] || "").trim(); licenseUrl = (mL[2] || "").trim(); }
                    else    { licenseName = String(licenseRaw).trim(); }
                }

                // --- Hrefs erzeugen (nur wenn URLs vorhanden) ---
                var wikiHref    = wikiUrl   ? normalizeForHref(wikiUrl)   : "";
                var fileHref    = fileUrl   ? normalizeForHref(fileUrl)   : "";
                var authorHref  = authorUrl ? normalizeForHref(authorUrl) : "";
                var licenseHref = licenseUrl? normalizeForHref(licenseUrl): "";

                var parts = [];
                var candidates = []; // für MouseArea/Click-Mapping (url + sichtbarer Linktext)

                // --- "Info aus …" mit Wikipedia- oder Domain-Label ---
                if (wikiHref) {
                    var wikiOpen  = normalizeForOpen(wikiUrl);
                    var host      = extractHostname(wikiOpen);
                    var wikiLabel = isWikipediaHost(host) ? "Wikipedia" : host;
                    parts.push('Info aus <a href="' + wikiHref + '">' + escapeHtml(wikiLabel) + '</a>');
                    candidates.push({ url: wikiOpen, label: wikiLabel });
                }

                // --- "Bildquelle:" nur wenn Bildbeschreibung-URL vorhanden ---
                if (fileHref) {
                    var fileOpen = normalizeForOpen(fileUrl);
                    var fileLabel = "Wikimedia Commons";
                    parts.push('Bildquelle: <a href="' + fileHref + '">' + fileLabel + '</a>');
                    candidates.push({ url: fileOpen, label: fileLabel });
                }

                // --- "von <Autor>" nur wenn Autorname vorhanden (Link optional) ---
                if (authorName) {
                    var authorHtml;
                    if (authorHref) {
                        var authorOpen = normalizeForOpen(authorUrl);
                        authorHtml = '<a href="' + authorHref + '">' + escapeHtml(authorName) + '</a>';
                        candidates.push({ url: authorOpen, label: authorName });
                    } else {
                        authorHtml = escapeHtml(authorName);
                    }
                    parts.push('von ' + authorHtml);
                }

                // --- "unter Lizenz: <Lizenz>" nur wenn Lizenzname vorhanden (Link optional) ---
                if (licenseName) {
                    var licenseHtml;
                    if (licenseHref) {
                        var licenseOpen = normalizeForOpen(licenseUrl);
                        licenseHtml = '<a href="' + licenseHref + '">' + escapeHtml(licenseName) + '</a>';
                        candidates.push({ url: licenseOpen, label: licenseName });
                    } else {
                        licenseHtml = '<b>' + escapeHtml(licenseName) + '</b>';
                    }
                    parts.push('unter Lizenz: ' + licenseHtml);
                }

                // Ergebnis setzen oder leeren
                var formatted = parts.join(', ');
                textItem.text = formatted;
                licencelink.linkPositions = [];

                if (!formatted) return;

                // --- Linkpositionen grob ermitteln (Raster-Sampling) ---
                var y = 0;
                while (y < textItem.height) {
                    var x = 0;
                    while (x < textItem.width) {
                        var linkAtPoint = textItem.linkAt(x, y);
                        if (linkAtPoint) {
                            for (var i = 0; i < candidates.length; ++i) {
                                var c = candidates[i];
                                var already = licencelink.linkPositions.some(function (l) { return l.url === c.url; });
                                if (!already) {
                                    var w = licencelink.estimateTextWidth(c.label, textItem.font);
                                    licencelink.linkPositions.push({ url: c.url, x: x, y: y, width: w });
                                }
                            }
                        }
                        x += 8;
                    }
                    y += 8;
                }
            }
        }
        function callSetImage(isQuestion,imgName, entryDesc) {
            imageId.source = imgName;
            if (entryDesc) {
                imageId.excludeAereaList = entryDesc.excludeAerea;
                imageId.updateExcludeRects();
                licencelink.setLicenseInfo(isQuestion)
            }
        }
    }

    Rectangle {
        id: customProgressBar
        anchors.bottom: navSection.top
        anchors.bottomMargin: 5
        //anchors.horizontalCenter: imageId.horizontalCenter
        anchors.left: container.left
        width: parent.width - (parent.width * 0.1)
        height: 20
        radius: 10
        color: "transparent"
        property bool stoppedManually: false  // Hier wird die Property definiert

        // Container für den Fortschrittsbalken
        Rectangle {
            id: progressBarContainer
            width: 0  // Starten Sie mit einer Breite von 0
            height: customProgressBar.height
            radius: 10
            color: "transparent"
            clip: true  // Clip, um das Bild innerhalb des Rechtecks zu halten

            Image {
                id: barImage
                source: "qrc:/progressbar.jpg"
                width: customProgressBar.width  // Die Breite des Bildes bleibt konstant
                height: customProgressBar.height
                fillMode: Image.Stretch
                anchors.left: parent.left
            }
        }

        PropertyAnimation {
            id: progressStartAnimation
            target: progressBarContainer
            property: "width"
            from: 0
            to: customProgressBar.width
            duration: 10000
            running: false
            onRunningChanged: {
                if (!running) {
                    if (!customProgressBar.stoppedManually) {
                        appButtonLeft.doOnClicked();
                    } else {
                        customProgressBar.stoppedManually = false;
                    }
                }
            }
        }

        function startProgressBar() {
            stopProgressBar();
            progressStartAnimation.running = true;
        }

        function stopProgressBar() {
            stoppedManually = true;
            progressStartAnimation.stop();
            progressBarContainer.width = 0;
            appButtonUuups.visible = false;
        }
    }

    // Text außerhalb der ProgressBar-Komponente
    Text {
        id: imageTextId
        anchors.horizontalCenter: customProgressBar.horizontalCenter
        anchors.verticalCenter: customProgressBar.verticalCenter
        font.pixelSize: customProgressBar.height * 0.8
        font.italic: true
        font.bold: true
        color: "black"
        text: ""  // Setzen Sie hier den gewünschten Text
    }

    Rectangle {
        id: navSection
        height: parent.height*0.12
        width:(startEvaluationId.visible)?startEvaluationId.width:(parent.width - parent.width*0.1)

        anchors.left        :(startEvaluationId.visible)?startEvaluationId.left:parent.left
        anchors.leftMargin  :(startEvaluationId.visible)?0:(parent.width*0.05)
        anchors.bottom: parent.bottom
        //anchors.bottomMargin: parent.height*0.01

        property bool isLastImgeReached: false
        property bool isRecognizedByKnown: false

        color:"transparent"

        Button {
            id: appButtonLeft
            width: parent.width*0.3
            height: parent.height * 0.5
            checkable: true
            enabled: true
            anchors.top: parent.top
            font.pointSize: 17
            background: Rectangle {
                color: "red"
                border.color: "darkred"
                border.width: 2
                radius: 15
            }
            // Verhindern, dass sich die Textfarbe ändert
            contentItem: Text {
                text: parent.text // Dein Button-Text hier
                color: "black"  // Textfarbe bleibt konstant
                font.pointSize: 17
                anchors.centerIn: parent  // Zentriere den Text im Button
                horizontalAlignment: Text.AlignHCenter  // Horizontale Ausrichtung
                verticalAlignment: Text.AlignVCenter    // Vertikale Ausrichtung
            }

            onClicked: {
              doOnClicked();
            }
            function doOnClicked () {
                //dataModel.debugPt();
                if (dataModel.getActImageName() !== "") {
                        imageTextId.text = "Vorher: " + setAnswerInLearnMode()
                }

                if (!lastEntryReached) {
                    exerciseModeState = Exercise.ExerciseModeChoose;
                    customProgressBar.startProgressBar();
                }
                else {
                    exerciseModeState = Exercise.ExerciseModeResponse;
                }
                customProgressBar.startProgressBar();
                stepToNextImage(false,true,true);
                setEnvironmentForeMode(Exercise.PressedLeftButton);
                customProgressBar.stoppedManually = false
                return;
            }
        }
        Rectangle {
            id: recLearnListId
            visible: false;
            color:"transparent"
            anchors.top: parent.top
            height: parent.height
            width:parent.width * 0.25
            anchors.horizontalCenter: parent.horizontalCenter
            property bool stateAdd:true;

            Button {
                id: pbLearnListId
                anchors.horizontalCenter: parent.horizontalCenter
                ToolTip.visible: hovered
                ToolTip.text: (recLearnListId.stateAdd)?qsTr("Auf Lernliste setzen"):qsTr("von Lernliste entfernen")
                checkable: true;

                height: 35;
                width:  35;

                background: Rectangle {
                    color: "transparent"
                }

                Image {
                    source: (recLearnListId.stateAdd)?"qrc:/icons/add.ico":"qrc:/icons/minus.ico"
                    height: parent.height ;
                    width:  parent.width ;
                }

                onClicked: {
                    //dataModel.debugPt();
                    var packageDesc = dataModel.getActPackageDescription()
                    var entryDesc   = dataModel.getActEntryDescription()
                    if (recLearnListId.stateAdd) {
                        LearnListEntryManager.putExerciceInList(packageDesc.packageName,entryDesc.exercizeNumber,entryDesc.reverse);
                        recLearnListId.visible = false;
                    } else {
                        LearnListEntryManager.removeExerciceFromList(packageDesc.packageName,entryDesc.exercizeNumber,entryDesc.reverse);
                        recLearnListId.visible = false;
                    }
                    activateLearnListId.actualizeCountLearnList();
                }
            }
            Label {
                anchors.top: pbLearnListId.bottom
                anchors.topMargin: 2
                anchors.horizontalCenter: parent.horizontalCenter
                text:(recLearnListId.stateAdd)?qsTr("Auf Lernliste setzen"):qsTr("von Lernliste entfernen")
            }

        }

        Button {
            id: appButtonRight
            enabled: false
            focus: true
            //checkable: true
            width: parent.width*0.3
            height: parent.height * 0.5
            anchors.top: parent.top
            anchors.right: parent.right
            font.pointSize: 17
            property int entryCounter: 0
            background: Rectangle {
                color: "green"
                border.color: "darkgreen"
                border.width: 2
                radius: 15
            }
            onClicked: {
                //dataModel.debugPt();
                handleAppButtonRightClick()
            }
        }
        Button {
            id: appButtonUuups
            enabled: true
            visible: false
            anchors.bottom: parent.bottom  // Am unteren Rand des übergeordneten Elements ausrichten
            anchors.bottomMargin: 10
            anchors.right: appButtonRight.right  // Den rechten Rand mit appButtonRight teilen
            width: appButtonRight.width * 6 / 8  // Breite relativ zu appButtonRight
            height: appButtonRight.height * 5 / 8  // Höhe relativ zu appButtonRight
            background: Rectangle {
                color: "red"
                border.color: "darkred"
                border.width: 2
                radius: 15
            }

            contentItem: Text {
                text: qsTr("Verdrückt zuletzt nicht OK!")
                color: "black"
                anchors.centerIn: parent  // Zentriert den Text im Button
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                visible = false;
                dataModel.setLastEntryRecognizedState(false);
                scoreText.undoLastRecognized();
                setEnvironmentForeMode(Exercise.PressedRightButton);
                visible = false;
            }
        }
    }
    function setAnswerInLearnMode () {
        if (isXMLBased()) {
            var entryDesc   = dataModel.getActEntryDescription()
            imageTextId.text = entryDesc.antwortSubjekt
        } else {
            if (dataModel.getActImageName() !== "") {
                imageTextId.text = stripFileExtension(dataModel.getActImageName());
            }
        }
        return imageTextId.text
    }


    function stepToNextImage (recognized,setRecognized=true,pressedLeftButton=false) {

        if (!preLastEntryReached) {
            if (recognized) {
                scoreText.incRecognized();
            }
            else {
                scoreText.incNotRecognized();
            }
        }
        if (lastEntryReached) {
            //dataModel.debugPt();
            if (!preLastEntryReached && learnModeState === Exercise.NotInLearnMode && !pressedLeftButton) { //wait a moment
                preLastEntryReached = true;
                appButtonUuups.visible = true;
                return;
            }
            exerciseModeState = Exercise.ExerciseModeEvualation;
            if (setRecognized) dataModel.setActEntryRecognizedState(recognized)
            page.evaluate();
            lastEntryReached = false;
            evalStartReached = true;
            preLastEntryReached = false;
            return;
        }
        else if (evalStartReached) {
            //dataModel.debugPt();
            page.start();
            evalStartReached = false;
            startEvaluationId.visible = false;
            container.visible = true;
        }
        else {
            if (setRecognized) dataModel.setActEntryRecognizedState(recognized)
        }

        dataModel.setNextQuestion();
        container.setXMLBasedMode(isXMLBased());
        setActQuestion();
        dataModel.debugPt();
        if(!recLearnListId.stateAdd) {
            recLearnListId.visible = true;
        } else {
            var packageDesc = dataModel.getActPackageDescription()
            var entryDesc   = dataModel.getActEntryDescription()
            var entryExist = LearnListEntryManager.entryExists(packageDesc.packageName,entryDesc.exercizeNumber,entryDesc.reverse);
            if (!entryExist) {
                recLearnListId.visible = true;
            }
            else {
                recLearnListId.visible = false;
            }
        }
        if (dataModel.isLastImage()) {
            lastEntryReached = true;
        }
    }

    function handleAppButtonRightClick() {
        // Logic that was originally inside the onClicked of appButtonRight
        if (learnModeState !== Exercise.NotInLearnMode) {
            stepToNextImage(true, false);
            setAnswerInLearnMode();
            if (learnModeState === Exercise.LearnModeFirst) {
                learnModeState = Exercise.LearnModeNext;
            }
        } else if (exerciseModeState === Exercise.ExerciseModeEvualation) {
            stepToNextImage(true, false);
            exerciseModeState = Exercise.ExerciseModeChoose;
            customProgressBar.startProgressBar();
        } else if (exerciseModeState === Exercise.ExerciseModeChoose) {
            setActAnswer();
            exerciseModeState = Exercise.ExerciseModeResponse;
            customProgressBar.stopProgressBar();
        } else {
            if (!lastEntryReached) {
                exerciseModeState = Exercise.ExerciseModeChoose;
                customProgressBar.startProgressBar();
            }
            stepToNextImage(true);
        }
        setEnvironmentForeMode(Exercise.PressedRightButton);
        customProgressBar.stoppedManually = false;
    }


    function setEnvironmentForeMode(action) {
        if (dataModel.isFirstEntry()) {
            if (learnModeState !== Exercise.NotInLearnMode)  { //is in learn mode
                scoreText.showEntryCounter(true);
            }
            else {
                scoreText.showEntryCounter(false);
            }
            if (activateLearnListId.checked) {
                recLearnListId.stateAdd = false
                recLearnListId.visible = true;
            }
            else {
                recLearnListId.stateAdd = true
            }
        }
        if (evalStartReached) {
            //dataModel.debugPt();
            recLearnListId.visible = false;
            scoreText.visible = false;
            appButtonLeft.visible  = false;
            appButtonRight.text ="Start"
            if (learnModeState!== Exercise.NotInLearnMode) { //is in learnmode
                imageTextId.text = "";
                learnModusId.checked = false;
                learnModeState = Exercise.NotInLearnMode
            }
            else {
                if (chosenAsKnown) {
                    imageTextId.text = "";
                    chosenAsKnown = false;
                }
                startEvaluationId.setOKScore();
                startEvaluationId.setNotOKScore();
                if (dataModel.getNotRecognizedEntries() <= 0 ) {
                    repeatWrongEntriesId.enabled = false;
                    repeatWrongEntriesId.checked = false;
                    if (!activateLearnListId.checked) {
                        showMainQuestionRevertedId.enabled = true;
                        showMainQuestionId.enabled = true;
                    }
                    presentInOrderId.enabled = true;
                }
                else {
                    repeatWrongEntriesId.checked = true;
                    repeatWrongEntriesId.enabled = true;
                    if (!activateLearnListId.checked) {
                        showMainQuestionId.enabled = false;
                        showMainQuestionRevertedId.enabled = false;
                    }
                    presentInOrderId.enabled = false
                }
            }
        }
        else if (action === Exercise.PressedLeftButton) {
            //dataModel.debugPt();
            appButtonLeft.text  ="Unbekannt"
            appButtonRight.text ="Kenn ich"
            if (chosenAsKnown) {
                imageTextId.text = "";
                chosenAsKnown = false;
            }

        }
        else if (action === Exercise.PressedRightButton) {
            //dataModel.debugPt();
            appButtonLeft.visible = true;
            if (learnModeState !== Exercise.NotInLearnMode) {
                appButtonLeft.visible = false
                appButtonRight.text ="Weiter"
            }
            else if (exerciseModeState === Exercise.ExerciseModeChoose) {
                appButtonLeft.visible = false
                appButtonRight.text ="Erkannt?"
                if (chosenAsKnown) {
                    imageTextId.text = "";
                    chosenAsKnown = false;
                }
                if (!dataModel.isFirstEntry())
                    appButtonUuups.visible = true;
            }
            else if (exerciseModeState === Exercise.ExerciseModeResponse) {
                appButtonLeft.visible = true
                if (!preLastEntryReached) {
                    appButtonLeft.text  ="Leider nicht"
                    appButtonRight.text ="Erkannt!"
                } else {
                    appButtonLeft.visible = false
                    appButtonRight.text ="Auswerten"
                }
                //imageTextId.text = "";
                chosenAsKnown = true; //changed from ExerciseModeChoose
            }
        }
    }

    function evaluate() {
        customProgressBar.stopProgressBar();
        startEvaluationId.visible   = true;
        container.visible             = false;
        startEvaluationId.visible   = true;
        elapsedTimeLabelId.visible  = true
        showScores(true);

        if (learnModeState !== Exercise.NotInLearnMode) {
            elapsedTimeLabelId.visible  = false
        }
        else {

            elapsedTimeLabelId.visible  = true
            dataModel.debugPt();
            if (dataModel.getNotRecognizedEntries() <= 0) {
                scoreDisplay.elapsedTimeIdText = "Gesamtzeit:" + scoreDisplay.fancyTimeFormat(scoreDisplay.secondsElapsed);
                scoreDisplay.restartCounter();
            }
            else {
                scoreDisplay.elapsedTimeIdText = "Zwischenzeit:" + scoreDisplay.fancyTimeFormat(scoreDisplay.secondsElapsed);
                scoreDisplay.startPause();
            }
            scoreDisplay.addRow(scoreText.cntRecognized,scoreText.cntNotRecognized)
            scoreDisplay.elapsedTimerRunning = false;
        }
        inProcess = false;
    }

    function start() {
        // container.setXMLBasedMode(isXMLBased());
        var packageDesc = dataModel.getActPackageDescriptionIdx(0)

        dataModel.debugPt();
        if (learnModeState !== Exercise.NotInLearnMode) {
            elapsedTimeLabelId.visible  = false
        }
        else {
            elapsedTimeLabelId.visible  = true
            scoreDisplay.elapsedTimerRunning = true;
        }

        appButtonLeft.visible = true;
        appButtonLeft.text  =  "Unbekannt";
        appButtonRight.text =  "Kenn ich"
        if (repeatWrongEntriesId.checked && repeatWrongEntriesId.visible) {
           dataModel.setEntryList(false,false,activateLearnListId.checked);
        }
        else {
            scoreDisplay.resetTable()
            dataModel.setEntryList(true,false,activateLearnListId.checked);
        }
        //not in packagepart learning learnModusId
        // if (singlePackageLearning == false) //should be parameterized
        console.log("--- randomize ist ----")
        packageDesc = dataModel.getActPackageDescriptionIdx(0)
        if (!packageDesc.displayExercizesInSequence) {
            dataModel.randomizeEntryList();
        }
        scoreText.initScoring();
        showAvailablePacketsId.showActivePackages(true)
        inProcess = true;
    }

    function setActQuestion() {
        answerArea.visible = false
        questionArea.visible = false
        if (isXMLBased()) {
            questionArea.visible = true
        }
        var packageDesc = dataModel.getActPackageDescription()
        var entryDesc   = dataModel.getActEntryDescription()

        var imageFileName = packageDesc.fullPathToPackage + "/" + entryDesc.imageFilenameFrage

        answerArea.writeAnswer("")

        licencelink.visible = false
        if (entryDesc.imageFilenameFrage) {
            licencelink.visible = true
            container.callSetImage(true,imageFileName,entryDesc)
        }
        else
            container.callSetImage(true,"qrc:/images/Question mark.jpg")
        if (entryDesc.reverse) {
            questionArea.writeQuestion(packageDesc.mainQuestionReverse,entryDesc.frageSubjekt,entryDesc.subjektPrefixFrage)
        }
        else {
            questionArea.writeQuestion(packageDesc.mainQuestion,entryDesc.frageSubjekt,entryDesc.subjektPrefixFrage)
        }
    }

    function setActAnswer() {
        questionArea.visible = false
        answerArea.visible = false
        if (isXMLBased()) {
            answerArea.visible = true
            var packageDesc = dataModel.getActPackageDescription()
            var entryDesc   = dataModel.getActEntryDescription()
            answerArea.writeAnswer("")
            licencelink.visible = false
            if (entryDesc.imageFilenameAntwort) {
                licencelink.visible = true
                container.callSetImage(false,packageDesc.fullPathToPackage + "/" + entryDesc.imageFilenameAntwort,true)
                //answerAreaQuestionImage.source = packageDesc.fullPathToPackage + "/" + entryDesc.imageFilenameFrage;
                answerAreaQuestionTxt.textToShow = (entryDesc.frageSubjekt.indexOf("Frage_") !== -1)?"": entryDesc.frageSubjekt;
            } else if (imageId.visible) { //ev. bleibt fragebild sichtbar.
                licencelink.visible = true
            }

            answerArea.writeAnswer(entryDesc.antwortSubjekt)
        } else {
            imageTextId.text = stripFileExtension(dataModel.getActImageName());
        }
    }

    function isHideAuthor() {
        var packageDesc = dataModel.getActPackageDescription()
        return packageDesc.hideAuthorByQuestion
    }

    function isXMLBased() {
        var packageDesc = dataModel.getActPackageDescription()
        return packageDesc.isXMLDescripted
    }

    function isXMLBasedFromIdx(idx) {
        var packageDesc = dataModel.getActPackageDescriptionIdx(idx)
        return packageDesc.isXMLDescripted
    }

    function stripFileExtension(file) {
        var lastDotIndex = file.lastIndexOf(".");
        if (lastDotIndex !== -1) {
            var answer = file.slice(0, lastDotIndex);
            return answer;
        }
        return file;
    }

    function showScores(showScore) {
        scoreDisplay.evalGroupIdVisible = showScore
        elapsedTimeLabelId.visible  = showScore;
    }

}
