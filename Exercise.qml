import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import QtCore 6.5 as QtCore  // Verwende die passende Qt-Version

import QtQuick.Layouts 1.12

import Qt.labs.settings 1.1

import QtWebView 1.1  // Import WebEngine module

import "../model"

import com.memoryhandler.EntryHandler 1.0
import com.memoryhandler.EntryDesc 1.0
import com.memoryhandler.PackageDesc 1.0

import com.memorytrainer.network 1.0

import "../pages" as ScoreDisplayComponent

Page {

    id: page

    DataModel {
      id: dataModel
    }

    // Container for dynamically created WebEngineView
    FocusScope {
        id: mainFocusScope
        anchors.fill: parent
        focus: true
        activeFocusOnTab: true
        z: 1

        // External property to bind to the ApplicationWindow's internet status
        //property alias isInternetAvailable: appId.isInternetAvailable
        property var webEngineInstance: null
        // URL to be loaded
        property string webUrl: "https://www.wikipedia.org"

        Item {
            id: webViewContainerId
            anchors.fill: parent
            Keys.onPressed: (event) => {
                console.log("Key (Component) pressed, current focus:", Qt.application.focusObject);
                if (event.key === Qt.Key_Escape) {  // Check for the Escape key
                    mainFocusScope.closeWebPage();
                    event.accepted = true;
                    console.log("Escape key pressed, WebEngineView closed.");
                }
            }
        }

        function showWebPage(url) {
            // Check for internet connection using the parent property
            if (appId.isInternetAvailable) {
                console.log("Internet connection available. Loading page...");
                openWebPage(url);
            } else {
                console.log("No internet connection available.");
                // Show a message to the user, or handle accordingly
            }
        }

        function openWebPage(url) {
            closeWebPage(); // Clear any existing WebEngineView instances

            // Create the WebEngineView instance and store it in webEngineInstance
            webEngineInstance = webViewComponentId.createObject(webViewContainerId, {
                width: webViewContainerId.width,
                height: webViewContainerId.height,
                focus: true // Give focus to the WebEngineView if necessary
            });

            // Ensure `webEngineInstance` is correctly created and has a child WebEngineView
            if (webEngineInstance) {
                // Access the WebEngineView and set its URL
                const webEngineView = webEngineInstance.children[0]; // Assuming WebEngineView is the first child
                if (webEngineView) {
                    webEngineView.url = url || webUrl; // Set the URL
                }
            }
            appId.setWebView(webEngineInstance)
            webViewContainerId.forceActiveFocus(); // Make sure the container has focus
        }

        function closeWebPage() {
            if (webEngineInstance) {
                webEngineInstance.destroy();
                webEngineInstance = null;
            }
        }

        // Definition of the WebEngineView Component
        Component {
            id: webViewComponentId
            Item {
                // Container for the WebEngineView and the exit button
                width: parent.width
                height: parent.height

                WebView {
                    id: webEngineViewId
                    url: ""
                    anchors.fill: parent  // Fill the container
                    focus: false
                }
            }
        }
    }

    property bool isLoaded: false

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


    Rectangle
    {
        id:pageRectId
        anchors.fill: parent
        color: "lightgray"
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
            cntEntry()
            cntRecognized = 0;
            cntNotRecognized = 0;
            recognizedNr.text = qsTr(signPad(0,3));
            notRecognizedNr.text = qsTr(signPad(0,3));
        }

        function initScoringCounter() {
            cntAll = 0;
            cntEntry()
        }

        function cntEntry() {
            constText.text = qsTr("Frage " + (++cntAll) + " von " + dataModel.countEntries() + " Fragen" );
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

    property alias datastore: settings.datastore

    function serializePackageOptions() {
        return {
            mainOrderIsSelected: showMainQuestionId.checked,
            revertedOrderIsSelected: showMainQuestionRevertedId.checked,
            sequentiellOrderIsSelected: presentInOrderId.checked
        };
    }

    Component.onDestruction: {

        var dModel = []
        for (var i = 0; i < entryModelPackagesId.count; ++i) {
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
        datastore = JSON.stringify(dModel)
    }

    Component.onCompleted: {

      //console.debug("onCompleted");
      appButtonRight.text           = "Start";
      appButtonLeft.visible         = false;
      repeatWrongEntriesId.enabled  = false;

      showScores(false);

      var packageList = dataModel.initExercisePackages();

      if (datastore) {
          //dataModel.debugPt();
          //var entryModelPackagesId = []
          var dModel = JSON.parse(datastore)
          for (var i = 0; i < dModel.length-5; ++i) {
              listViewPacketsId.model.append(dModel[i])
              dataModel.addExercisePackage(dModel[i].name);
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
      activateLearnListId.setPlayable(dataModel.getPackageEntries(dataModel.getNameOfLearnList()) > 0 )
      startEvaluationId.setQuestionOptions(false);
      return;
    }

    QtCore.Settings {
        id: settings
        property string datastore: "default_value"
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
            if (count > 0) {
                appButtonRight.enabled = true;
            } else {
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

        /*

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
                text: qsTr("Die Einträge der Lernliste(" + dataModel.getSizeOfLearnList() + ")");
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
        */
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
                    text: qsTr("gewählte Übungspakete(" + dataModel.getSizeOfLearnList() + ")")
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
                            dataModel.addExercisePackage(listElement.name);
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
                    var list = dataModel.getPackages();
                    //dataModel.debugPt();
                    for (var i = 0; i < list.length; i++) {
                        if (!find(listViewPacketsId.model, list[i] )) {
                            append(createListElement(list[i],dataModel.getPackageEntries(list[i])))
                        }
                    }
                }
                function find(model, criteria) {
                  for(var i = 0; i < model.count; ++i) {
                      if (model.get(i).name === criteria) {
                          return true
                      }
                  }
                  return false
                }

                function createListElement(packageName,cnt) {
                    return {
                        name: packageName,
                        count: cnt,
                        isPackagePart: false,
                        isPackagePartActive: false
                    };
                }
                function updateCountWithInitValue(index) {
                    if (index >= 0 && index < entryModelPackagesId.count) {
                        entryModelAvailablePackagesId.setProperty(index, "count", dataModel.getPackageEntries(entryModelAvailablePackagesId.get(index).name));
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
                text: qsTr("Lernliste abspielen")
                font.pixelSize: 12
                onCheckStateChanged: {
                    showScores(false);
                    if (checked) {
                        gbLearnListId.visible = true;
                        packetChoiceId.visible = false;
                        packetAvailableId.visible = false;
                        var cnt =dataModel.loadLearnListPackage();
                        lbTxt001.text= qsTr("Die Einträge der Lernliste (" + cnt + ")");

                    } else {
                        gbLearnListId.visible = false;
                        packetChoiceId.visible = true;
                        if (!scoreNotOKId.visible)
                            packetAvailableId.visible = true;
                        //set packets
                        dataModel.initExercisePackages();
                        for (var i= 0;i < entryModelPackagesId.count;i++) {
                            dataModel.addExercisePackage(entryModelPackagesId.get(i).name);
                        }
                    }
                }
                function setPlayable(playAble) {
                    if (playAble) {
                        enabled = true;
                        font.pixelSize= 10
                        font.bold = true
                    }
                    else {
                        enabled = false;
                        font.pixelSize= 12
                        font.bold = false
                    }
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
            presentInOrderId.visible = false;
            if (dataModel.sizeActExercisePackages() === 1 ) {
                var packageDesc = dataModel.getActPackageDescriptionIdx(0)
                if (packageDesc.isXMLDescripted) {
                    showMainQuestionRevertedId.enabled = true;
                    showMainQuestionId.visible = true;
                    if (!packageDesc.mainQuestionReverse) {
                       showMainQuestionRevertedId.checked = false;
                    }
                    showMainQuestionRevertedId.visible = true;
                    presentInOrderId.visible = true;
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
            if (showMainQuestionId.checked) entries += packageDesc.mainQuestions;
            if (showMainQuestionRevertedId.checked) entries += packageDesc.reverseQuestions ;
            entryModelPackagesId.updateCountAtIndex(0,entries);
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
                    wrapMode: Text.WordWrap
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            function adjustFontSize(textItem, maxHeight, maxFontSize) {
                var currentFontSize = maxFontSize;
                textItem.font.pointSize = currentFontSize;

                while (textItem.height > maxHeight && currentFontSize > 1) {
                    currentFontSize -= 1;
                    textItem.font.pointSize = currentFontSize;
                }
            }

            function writeQuestion(question, subject, subjektPrefix) {
                var parts = question.split("[FrageSubjekt]");
                var formattedQuestion = parts[0] || "";

                // Berechne die maximale Schriftgröße basierend auf der Höhe von questionArea
                var questionMaxFontSize = Math.round(questionArea.height * 0.15);
                var questionMaxFontSizeNoSubjekt = Math.round(questionArea.height * 0.40);
                var subjectMaxFontSize = Math.round(questionArea.height * 0.40);
                var followingMaxFontSize = Math.round(questionArea.height * 0.30);

                if (parts.length > 1) {
                    var followingTextVar = parts[1];
                    questionText.text = formattedQuestion + subjektPrefix;
                    subjectText.text = "<" + subject + ">";
                    followingText.text = followingTextVar + "?";

                    // Passe die Schriftgrößen dynamisch an, um in das Rechteck zu passen
                    adjustFontSize(questionText, questionArea.height * 0.3, questionMaxFontSize);
                    adjustFontSize(subjectText, questionArea.height * 0.4, subjectMaxFontSize);
                    adjustFontSize(followingText, questionArea.height * 0.3, followingMaxFontSize);
                } else {
                    // Kein [FrageSubjekt] gefunden
                    questionText.text = question;
                    subjectText.text = "";
                    followingText.text = "";

                    // Passe die Schriftgröße des questionText auf 40% der Höhe an
                    adjustFontSize(questionText, questionArea.height * 0.4, questionMaxFontSizeNoSubjekt);
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

            function adjustFontSizeToFit(textItem, maxHeight, initialFontSize) {
                textItem.font.pointSize = initialFontSize;
                while (textItem.height > maxHeight && textItem.font.pointSize > 1) {
                    textItem.font.pointSize -= 1;
                }
            }

            function writeAnswer(answer) {
                // Setze den Text für answerText
                answerText.text = answer;

                // Berechne die anfängliche Schriftgröße basierend auf der Höhe von answerArea
                var headerInitialFontSize = Math.round(answerArea.height * 0.20);
                var textInitialFontSize = Math.round(answerArea.height * 0.30);

                // Setze die initiale Schriftgröße
                answerHeader.font.pointSize = headerInitialFontSize;
                answerText.font.pointSize = textInitialFontSize;

                // Passe die Schriftgröße an, falls der Text nicht in den Bereich passt
                adjustFontSizeToFit(answerHeader, answerArea.height * 0.30, headerInitialFontSize);
                adjustFontSizeToFit(answerText, answerArea.height * 0.60, textInitialFontSize);

                // Positioniere answerText vertikal zwischen answerHeader und dem unteren Rand
                var remainingSpace = answerArea.height - answerHeader.height - answerText.height;
                answerText.anchors.verticalCenterOffset = remainingSpace / 2 - answerArea.height / 2;
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
                    //font.family: "Courier"
                    font.pixelSize: 14 // Setze initiale Schriftgröße auf maximal 12
                    text: answerAreaQuestionTxt.textToShow

                    onTextChanged: {
                        // Verkleinere die Schriftgröße, aber nicht unter 12 Pixel
                        while (txtMeter.width > answerAreaQuestionTxt.width && txtMeter.font.pixelSize > 14) {
                            txtMeter.font.pixelSize--;
                        }
                        // Vergrößere die Schriftgröße, aber nicht über 12 Pixel
                        while (txtMeter.width < answerAreaQuestionTxt.width && txtMeter.font.pixelSize < 14) {
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

                Image {
                    id: answerAreaQuestionImage
                    height: parent.height - 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    visible: true
                    fillMode: Image.PreserveAspectFit
                    source: ""
                }
            }
        }
        Image {
            id: imageId
            anchors.top: questionArea.top
            anchors.topMargin: 4
            anchors.bottom: parent.bottom
            anchors.bottomMargin: customProgressBar.height + 30
            anchors.left: parent.left
            anchors.right: parent.right
            visible: true
            fillMode: Image.PreserveAspectFit
            source: ""

            property var  excludeAereaList: [] // Liste von ExcludeAerea-Objekten
            property real imgRealWidth: 0
            property real imgRealHeight: 0

            function setRealImageDimensions() {
                var imgAspectRatio = imageId.sourceSize.width / imageId.sourceSize.height;
                var displayAspectRatio = imageId.width / imageId.height;
                if (imgAspectRatio > displayAspectRatio) {
                    imgRealWidth = imageId.width;
                    imgRealHeight = imgRealWidth / imgAspectRatio;
                } else {
                    imgRealHeight = imageId.height;
                    imgRealWidth = imgRealHeight * imgAspectRatio;
                }
            }

            function updateExcludeRects() {
                setRealImageDimensions()
                // Entferne alle existierenden Rechtecke
                for (var i = excludeRectContainer.children.length - 1; i >= 0; i--) {
                    excludeRectContainer.children[i].destroy();
                }

                if (excludeAereaList && excludeAereaList.length > 0) {

                    var scaleX = imgRealWidth / imageId.sourceSize.width;
                    var scaleY = imgRealHeight / imageId.sourceSize.height;

                    for (i = 0; i < excludeAereaList.length; i++) {
                        var area = excludeAereaList[i];
                        var rectX = area.rect.x * scaleX + (imageId.width - imgRealWidth) / 2;
                        var rectY = area.rect.y * scaleY + (imageId.height - imgRealHeight) / 2;
                        var rectWidth = area.rect.width * scaleX;
                        var rectHeight = area.rect.height * scaleY;

                        var rectObject = rectangleComponent.createObject(excludeRectContainer, {
                            x: rectX,
                            y: rectY,
                            width: rectWidth,
                            height: rectHeight,
                            rotation: area.rotationAngle
                        });
                    }
                }
            }

            function callSetImage(imgName, excludeAereaList) {
                source = imgName;
                imageId.excludeAereaList = excludeAereaList;
                updateExcludeRects();
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
                    color: "red"
                    border.color: "black"
                    border.width: 2
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
        Rectangle {
            id: licencelink
            anchors.top: imageId.bottom
            anchors.topMargin: 2
            anchors.horizontalCenter: parent.horizontalCenter
            height: 18
            width: Math.max(imageId.imgRealWidth, textItem.implicitWidth) // Adjust width to fit text or image
            color: "transparent"  // Transparent background to show the image underneath
            border.color: "darkgray"
            border.width: 3

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    mainFocusScope.showWebPage("https://www.wikipedia.org");
                }
            }

            // Centered text with hyperlink styling
            Text {
                id: textItem
                anchors.centerIn: parent // Center text within the Rectangle
                text: "Image by <User:SKopp>, licensed under the <CC BY-SA 3.0>, via <WebPage>"
                color: "blue"   // Text color
                font.pointSize: 10  // Set the font size to 10px
                font.bold: false    // Ensure the text is not bold
                font.underline: true  // Underline the text to resemble a link
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
                    if (recLearnListId.stateAdd) {
                        if (dataModel.copyToLearnList(dataModel.getActEntryPos())) {
                            recLearnListId.visible = false;
                        }
                    } else {
                        if (dataModel.removeFromLearnList(dataModel.getActImageName())) {
                            recLearnListId.visible = false;
                        }
                    }
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
                if (learnModeState !== Exercise.NotInLearnMode) {
                    stepToNextImage(true,false);
                    setAnswerInLearnMode();
                    if (learnModeState === Exercise.LearnModeFirst) {
                        learnModeState = Exercise.LearnModeNext;
                    }
                }
                else if (exerciseModeState === Exercise.ExerciseModeEvualation) {
                    stepToNextImage(true,false);
                    exerciseModeState = Exercise.ExerciseModeChoose;
                    customProgressBar.startProgressBar();
                }

                else if (exerciseModeState === Exercise.ExerciseModeChoose) {
                    setActAnswer();
                    exerciseModeState = Exercise.ExerciseModeResponse;
                    customProgressBar.stopProgressBar();
                }
                else
                {
                    if (!lastEntryReached) {
                        exerciseModeState = Exercise.ExerciseModeChoose;
                        customProgressBar.startProgressBar();
                    }
                    stepToNextImage(true)
                }
                setEnvironmentForeMode(Exercise.PressedRightButton);
                customProgressBar.stoppedManually = false;
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
            if (!dataModel.isOnLearnList(dataModel.getActImageName())) {
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
                if (dataModel.getNotRecognizedEntries() <= 0) {
                    repeatWrongEntriesId.enabled = false;
                    repeatWrongEntriesId.checked = false;
                    showMainQuestionId.enabled = true;
                    showMainQuestionRevertedId.enabled = true;
                    presentInOrderId.enabled = true;
                }
                else {
                    repeatWrongEntriesId.checked = true;
                    repeatWrongEntriesId.enabled = true;
                    showMainQuestionId.enabled = false
                    showMainQuestionRevertedId.enabled = false
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
                appButtonLeft.text  ="Unbekannt"
                appButtonRight.text ="Kenn ich"
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
                    appButtonLeft.text  ="Leider falsch"
                    appButtonRight.text ="OK erkannt"
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

        if (activateLearnListId.checked) {
            var cnt = dataModel.removeFilesFromEntryList();
            lbTxt001.text = qsTr("Die Einträge der Lernliste(" + cnt + ")");
            if (cnt === 0) {
                activateLearnListId.checked = false;
            }
        }
        if (dataModel.getSizeOfLearnList() > 0) {
            activateLearnListId.setPlayable(true);
        }
        else {
            activateLearnListId.setPlayable(false);
        }

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
    }

    function start() {
        // container.setXMLBasedMode(isXMLBased());
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
           dataModel.setEntryList(false,false);
        }
        else {
            scoreDisplay.resetTable()
            dataModel.setEntryList(true,false);
        }
        if (learnModeState !== Exercise.NotInLearnMode) { //in learn mode
            scoreText.initScoringCounter();
        }
        else {
            //not in packagepart learning learnModusId
            // if (singlePackageLearning == false) //should be parameterized
            console.log("--- randomize ist ----")
            var packageDesc = dataModel.getActPackageDescriptionIdx(0)
            if (!packageDesc.displayExercizesInSequence) {
                dataModel.randomizeEntryList();
            }
            scoreText.initScoring();
        }
        showAvailablePacketsId.showActivePackages(true)
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
        if (entryDesc.imageFilenameFrage)
            imageId.callSetImage(imageFileName,entryDesc.excludeAerea)
        else
            imageId.callSetImage("qrc:/images/Question mark.jpg")
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
            if (entryDesc.imageFilenameAntwort) {
                imageId.callSetImage(packageDesc.fullPathToPackage + "/" + entryDesc.imageFilenameAntwort,true)
                answerAreaQuestionImage.source = packageDesc.fullPathToPackage + "/" + entryDesc.imageFilenameFrage;
                answerAreaQuestionTxt.textToShow = (entryDesc.frageSubjekt.indexOf("Frage_") !== -1)?"": entryDesc.frageSubjekt;
            }
            answerArea.writeAnswer(entryDesc.antwortSubjekt)
        } else {
            imageTextId.text = stripFileExtension(dataModel.getActImageName());
        }
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
