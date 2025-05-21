// TODO: Packagename in Listbox

import QtQuick 2.15
import QtQuick.Controls 2.15

import QtQuick.Dialogs

import QtQuick.Controls.Material

import QtCore 6.5 as QtCore  // Verwende die passende Qt-Version

import QtQuick.Layouts 1.12

import "../model"

Page {
    DataModel {
      id: dataModel
    }

    id: pagePackageManager
    property bool isLoaded: false
    property double orgPageWidth
    property double orgPageHeight
    property int entrySize:0

    property bool selectPackageMode:true
    property int actualPageHeight: height

    property int distBetweenListGroupB:0

    Component.onCompleted: {
        distBetweenListGroupB = gbCreateRandomPackageId.y - (listPackages.y + listPackages.height);
        console.log("dist=" + parseInt(distBetweenListGroupB));
    }


    MessageDialog {

        id: deletePackage;
        objectName: "msgBox";
        //icon : StandardIcon.Information
        title: "Information";
        buttons: MessageDialog.Yes | MessageDialog.No
        property string packName
        property bool   isCustomPackage
        onButtonClicked: function (button, role) {
            switch (button) {
            case MessageDialog.Yes:
                console.log("delete package")
                var  result = {};
                if (!dataModel.removePackage(packName,isCustomPackage,result)) {
                    console.debug("delete package" + packName + "failed");
                    msgDialog.text = result.RETURN_VALUE;
                    msgDialog.buttons =  msgDialog.buttons | MessageDialog.Ok; // Setze Icon für Fehler
                    msgDialog.open();
                    return;
                }
            }
            entryModelAvailablePackagesId.clear();
            entryModelAvailablePackagesId.loadData();
        }

        function displayMessageBox(packageName,isCustPackage) {

            Material.theme = Material.Light;

            packName = packageName
            isCustomPackage = isCustPackage
            deletePackage.text = "Soll das Paket (" + packName  + ") endgültig gelöscht werden?";
            deletePackage.open();

            console.log("Got message:", deletePackage.text);
        }
     }

    MessageDialog {
        id: msgDialog
        title:"Hinweis"
        visible: false
    }


    Rectangle
    {
        id: parentRect
        anchors.fill: parent
        color: "lightgray"
    }

    GroupBox {
        id: activePackages
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 10
        width: parent.width - 20
        height: parent.height / 3

        background: CustomBox {
            id: custBoxId
            y: activePackages.topPadding - activePackages.padding
            width: parent.width
            height: parent.height - activePackages.topPadding + activePackages.padding
            borderColor: "black"
            borderWidth: 2
            textWidthFactor:0.38
        }

        Rectangle {
            id: label
            anchors.horizontalCenter: parent.horizontalCenter  // Zentriert das Rectangle horizontal in der GroupBox
            anchors.top: parent.top
            color: "transparent"
            //width: parent.width * 0.7
            height: titleGBPacketsId.font.pixelSize * 2  // oder eine feste Höhe setzen

            Text {
                id: titleGBPacketsId
                text: qsTr("Aktive-Übungspakete")
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

            // Funktion zur Erstellung eines Listenelements
            function createListElement(packageName, cnt, isCustomPackage) {
                return {
                    name: packageName,
                    count: cnt,
                    selected: false,
                    isCustomPackage: isCustomPackage
                };
            }

            // Funktion zur Reduktion des Zählers
            function descCnt(idx) {
                setProperty(idx, "count", get(idx).count - 1);
            }

            // Daten laden und Einträge ins Model einfügen
            function loadData(selectOnlyMainQuestions) {
                clear();
                var list = dataModel.getPackages(true, true); // Pakete laden
                for (var i = 0; i < list.length; i++) {
                    var packageName = list[i];
                    var isCustomPackage = false;

                    // Prüfen, ob das Präfix "CUST//" vorhanden ist
                    if (packageName.startsWith("CUST//")) {
                        isCustomPackage = true;
                        packageName = packageName.slice(6); // Präfix entfernen
                    }

                    // Eintrag in das Model einfügen
                    var countEntries;
                    if (selectOnlyMainQuestions) {
                        countEntries = dataModel.getPackageEntries(packageName,isCustomPackage,true)
                    } else {
                        countEntries = dataModel.getPackageEntries(packageName,isCustomPackage,false)
                    }
                    append(createListElement(packageName, countEntries, isCustomPackage));
                }
            }
        }

        Component {
            id: packageListDelegate
            Item {
                id: compId
                width: listPackages.width - 80;
                height: 30
                Column {
                    Label {
                        id: lCompId
                        width: compId.width
                        height: compId.height
                        text: name + '(' + count + ')'
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        MouseArea {
                            anchors.fill: parent
                            // Funktion zur Behandlung von Klicks
                            function handleClick(mouse) {
                                if (mouse.button === Qt.RightButton) {
                                    contextMenu.popup()
                                } else if (mouse.button === Qt.LeftButton) {
                                    listPackages.currentIndex = index
                                }
                            }

                            // Signal-Handler, der die Funktion aufruft
                            onClicked: (mouse) => handleClick(mouse)
                            acceptedButtons: Qt.RightButton | Qt.LeftButton
                            onPressAndHold: {
                                contextMenu.popup()
                                if (Qt.platform.os === "ios") {
                                    contextMenu.x = compId.width / 10;
                                    contextMenu.y = compId.height / 2;
                                }
                            }

                            Menu {
                                id: contextMenu
                                width: contTxt.paintedWidth + 10;
                                MenuItem {
                                    id: control
                                    text: "Lösche Paket :" + name
                                    contentItem: Text {
                                         anchors.fill: parent
                                         id: contTxt
                                         text: control.text
                                         font: control.font
                                         color: control.down ? "#17a81a" : "#21be2b"
                                         horizontalAlignment: Text.AlignHCenter
                                         verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: {
                                       deletePackage.displayMessageBox(name,isCustomPackage)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Component {
            id: packageSelectDelegate
            Item {
                id: compId
                width: listPackages.width - 60;
                height: 40
                Column {
                    id : colCB
                    CheckBox {
                       enabled: {
                          console.log("name=" + name)
                          if (isCustomPackage === true) {
                             false;
                          }
                          else
                             true;
                       }
                       id : cbSelectPackage
                       height: compId.height
                       width:40
                       checked: {
                           if (isCustomPackage === true || !selected) {
                             false;
                           } else
                               true

                       }
                       onClicked: {
                           entryModelAvailablePackagesId.setProperty(index,"selected",checked);
                       }
                    }
                }
                Column {
                    x:40
                    Label {
                        width: compId.width
                        height: compId.height
                        font.pointSize: 12
                        font.bold: true
                        text:  name + '(' + count + ')'
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        ListView {
              id: listPackages
              ScrollBar.vertical: ScrollBar {
                  policy: listPackages.contentHeight > listPackages.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                  anchors.right: listPackages.right
                  anchors.rightMargin: 20
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
              anchors.top: parent.top
              anchors.topMargin: 20
              anchors.left: parent.left
              anchors.leftMargin: 10
              property int parentWidth: parent.width
              width: parentWidth * 0.7
              height: parent.height - 20

              model: entryModelAvailablePackagesId
              clip:true

              property int pWidth: parent.width

              delegate: packageListDelegate
              highlight: Rectangle { x:20; color: "lightsteelblue"; radius: 5 }
              focus: true
        }
        GroupBox {
            id: gbCreateRandomPackageId
            visible: false
            title: qsTr("GroupBox")
            anchors.left: listPackages.right
            anchors.right : parent.right
            anchors.top: bCollectPackages.top
            height: parent.height * 0.75

            background: CustomBox {
                y: gbCreateRandomPackageId.topPadding - gbCreateRandomPackageId.padding
                width: parent.width
                height: parent.height - gbCreateRandomPackageId.topPadding + gbCreateRandomPackageId.padding
                borderColor: "black"
                borderWidth: 1
                textWidthFactor:0.13
            }

            label: Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.top
                anchors.bottomMargin: -height/2
                //color: "transparent"
                color: "yellow"
                width: parent.width
                //height: title.font.pixelSize
                Text {
                    text: qsTr("Paket aus Übungen zusammenstellen")
                    anchors.centerIn: parent
                    font.pixelSize: 12
                }
            }
            TextField {
                id:packageNameId
                //enabled: false;
                anchors.bottom: sPCountEcerzisesId.top
                anchors.bottomMargin: 35
                anchors.left: parent.left
                anchors.leftMargin: 3
                anchors.right: parent.right
                anchors.rightMargin: 5
                font.pointSize: 10
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                text:'Mixed-Package'
                background: Rectangle {
                    color: "white"
                    width: parent.width
                    height: parent.height
                }
                Text {
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 2
                    text: qsTr("Packetname")
                }
            }
            SpinBox {
                id: sPCountEcerzisesId
                //enabled: false;
                height: 40
                Text {
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 2
                    text: qsTr("Anzahl Einträge")
                }
                //anchors.right: packageNameId.right
                anchors.bottom: cbAllPackagesId.top
                anchors.bottomMargin: 5
                anchors.left:packageNameId.left
                font.pointSize: 12
                value: 50
                from: 1
                to: 999
                editable: true;
                Component.onCompleted: {
                    width = width * 0.8
                }

            }
            CheckBox {
                id: cbAllPackagesId
                anchors.bottom: parent.bottom
                anchors.left:sPCountEcerzisesId.left
                text: qsTr("Alle Packete")
                onCheckedChanged: {
                   for (var i=0;i < entryModelAvailablePackagesId.rowCount();i++) {
                      entryModelAvailablePackagesId.setProperty(i,"selected",checked);
                   }
                }
            }
            function enablePackageCreation(on) {
                if (on) {
                    gbCreateRandomPackageId.visible = true;
                    bCollectPackages.visible = false;
                    listPackages.width = listPackages.parentWidth * 0.6

                    viewSinglePackage.visible = false;
                    listPackages.anchors.bottomMargin -= distBetweenListGroupB;

                    listPackages.delegate = packageSelectDelegate;
                    listPackages.currentIndex = -1;
                    pagePackageManager.selectPackageMode = false
                }
                else {
                    gbCreateRandomPackageId.visible = false;
                    bCollectPackages.visible = true;
                    listPackages.width = listPackages.parentWidth * 0.7

                    listPackages.anchors.bottomMargin += distBetweenListGroupB;
                    listPackages.delegate = packageListDelegate;
                    listPackages.currentIndex = 0;
                    pagePackageManager.selectPackageMode = true
                }
            }
            Button {
                id: bCancelId
                anchors.right: parent.right
                anchors.bottom: bCreatePackagesId.top
                background: Rectangle {
                    color: "red"
                    border.color: "black"
                    border.width: 1
                    radius: 15
                }
                text: "Abbrechen"
                onClicked: {
                    gbCreateRandomPackageId.enablePackageCreation(false);
                }
            }
            Button {
                id: bCreatePackagesId
                width: bCancelId.width
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                background: Rectangle {
                    color: "green"
                    border.color: "black"
                    border.width: 1
                    radius: 15
                }
                text: "Erstellen"
                property var usePackages: []
                onClicked: {
                    createMixPackage(false)
                }
                MessageDialog {
                    id: msgCreateDialogId
                    title:"Hinweis"
                    visible: false
                    buttons:  MessageDialog.Cancel
                    onButtonClicked: function (button, role) {
                        switch (button) {
                        case MessageDialog.Yes:
                            bCreatePackagesId.createMixPackage(true);
                            break;
                        }
                    }
                }
                function createMixPackage(override) {
                    var usePackages = []
                    for (var i = 0; i < entryModelAvailablePackagesId.count; i++) {
                        if (entryModelAvailablePackagesId.get(i).selected) {
                            console.debug("put" + entryModelAvailablePackagesId.get(i).name);
                            usePackages.push([entryModelAvailablePackagesId.get(i).name,entryModelAvailablePackagesId.get(i).count]);
                        }
                    }
                    var  result = {};
                    if (!dataModel.createMixPackage(packageNameId.text,sPCountEcerzisesId.value,usePackages,override,!selectOnlyMainQuestions.checked,result)) {
                        console.debug("create package failed");
                        if ( result.RETURN_TYPE === "ERROR_PACKAGE_EXIST") {
                            msgCreateDialogId.buttons =  msgCreateDialogId.buttons | MessageDialog.Yes
                        }
                        msgCreateDialogId.text =  result.RETURN_VALUE;
                        msgCreateDialogId.open();
                        return;
                    }
                    entryModelAvailablePackagesId.clear();
                    entryModelAvailablePackagesId.loadData(selectOnlyMainQuestions);
                    gbCreateRandomPackageId.enablePackageCreation(false);
                }
            }
        }
        CheckBox {
            id: selectOnlyMainQuestions
            anchors.left: gbCreateRandomPackageId.left
            anchors.bottom: parent.bottom
            font.pointSize: 8
            font.bold: true
            checked:false
            text: "Nur Hauptfragen"
            onCheckStateChanged: {
                entryModelAvailablePackagesId.loadData(checked)
            }
        }
        Button {
            id: bCollectPackages
            anchors.top: parent.top
            anchors.topMargin: 10;
            anchors.right: parent.right
            anchors.rightMargin: 10
            //height: gbCreateRandomPackage.buttonSizeHeight;
            //width:  gbCreateRandomPackage.buttonSizeWidth;
            font.pointSize: 10
            font.bold: true
            text: "Erzeuge Auswahl-Paket"
            background: Rectangle {
                color: "green"
                border.color: "darkgreen"
                border.width: 2
                radius: 15
            }

            onClicked: {
                gbCreateRandomPackageId.enablePackageCreation(true);
            }
        }
    }

    Rectangle {
        id: viewSinglePackage
        width: parent.width
        height: pagePackageManager.height / 3
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        color: "transparent"
        SwipeView {
            id:view
            currentIndex: 0
            property bool currentIndexChangeFromPageIndicator:false
            onCurrentIndexChanged: {

                if (currentIndexChangeFromPageIndicator) {
                    currentIndexChangeFromPageIndicator = false;
                }
                else {
                    searchId.resetSearchtext();
                    var newIdx = parseInt((currentIndex * (pageIndicator.count/count)));
                    if (newIdx !== pageIndicator.currentIndex) {
                        pageIndicator.currentIndexChangeFromPageView = true;
                        pageIndicator.currentIndex = newIdx
                    }

                }
                return
            }
            anchors.bottomMargin: 20
            anchors.top : parent.top
            //anchors.topMargin: 15
            anchors.left: parent.left
            anchors.right: parent.right
            //height:parent.height
            property string currentPackageName

            Repeater {
                id:repeaterId
                property bool doNotLoad:false
                Loader {
                    id: loaderId
                    active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem

                    sourceComponent: Rectangle {
                        id: inputContainer
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 30
                        width: parent.width *0.9
                        border.width:2
                        border.color: "gray"
                        height:200
                        color:"transparent"
                        property int myIndex:10

                        Image {
                            id: imageId
                            anchors.horizontalCenter: parent.horizontalCenter
                            height : parent.height * 0.7
                            property string lastImageName
                            anchors.top: parent.top
                            anchors.topMargin: parent.height * 0.05
                            width: ( (parent.height * 0.8))/(sourceSize.height) * sourceSize.width
                        }

                        Label {
                            //enabled: false
                            z: lbImagename.z+1
                            anchors.left : parent.left
                            anchors.leftMargin:  5
                            anchors.bottom: lbImagename.bottom

                            id: pageNumber
                            font.pixelSize: 14;
                            text: (repeaterId.itemAt(index).SwipeView.index+1)  + " (" + view.count + ")"
                        }

                        TextInput {
                            id: lbImagename
                            width:parent.width
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: parent.height * 0.05
                            //anchors.top: repeaterId.itemAt(0).bottom
                            //text: colImgId.imageName;
                            font.pixelSize: 10;
                            horizontalAlignment :  Text.Center

                            property var rect : Qt.inputMethod.keyboardRectangle;
                            onFocusChanged: {
                                if (focus) {
                                    pbDelete.visible = false;
                                    pbRename.visible = true;
                                }
                            }
                            onEditingFinished: {
                                console.log("onEditingFinished");
                                if (Qt.platform.os === "ios") {
                                    console.log("ios detected");
                                    return;
                                }

                                if (lbImagename.text.trim().length > 0) {
                                    if (utilID.ifMobile()) {
                                        if (inputContainer.keyReturnPressed) {
                                            inputContainer.keyReturnPressed = false;
                                            if (!dataModel.changeCustomImageName(columnNr,lbImagename.text)) {
                                                console.debug("rename failed");
                                                return;
                                            }
                                            pbDelete.visible = true;
                                            pbRename.visible = false;
                                            lbImagename.focus = false;
                                        }
                                    }
                                }
                            }
                            Keys.onPressed: {
                                if (event.key === Qt.Key_Return) {
                                  if (Qt.platform.os == "ios") {
                                      if (!inputContainer.renameImageName(columnNr,newName)) {
                                          return;
                                      }
                                  }
                                  else {
                                      inputContainer.keyReturnPressed = true;
                                  }

                                  return;
                                }
                            }
                        }
                        Button {
                            id: pbDelete
                            checkable: false
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: parent.height * 0.05
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            property int sideLength : 30 //colImgId.height * (20/100)
                            Image {
                                source: "qrc:/icons/delete-image.png"
                                height: parent.sideLength;
                                width:  parent.sideLength;
                                //fillMode: Image.Tile
                            }
                            height: sideLength;
                            width: sideLength;
                            onClicked: {
                                messageDialog.open()
                            }
                        }
                        Button {
                            id: pbRename
                            checkable: false
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: parent.height * 0.05
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            property int sideLength : 30 //colImgId.height * (20/100)
                            Image {
                                source: "qrc:/icons/save-icon.png"
                                height: parent.sideLength;
                                width:  parent.sideLength;
                                //fillMode: Image.Tile
                            }
                            height: sideLength;
                            width: sideLength;
                            visible: false;

                            onClicked: {
                                var listIndex = repeaterId.itemAt(index).SwipeView.index + 1
                                if (!inputContainer.renameImageName(listIndex,lbImagename.text)) {
                                    console.debug("rename failed");

                                    return;
                                }
                                pbDelete.visible = true;
                                pbRename.visible = false;
                                console.debug("rename ok");
                            }
                        }
                        function renameImageName(columnNr,newName) {
                            if (newName === imageId.lastImageName) {
                                return true;
                            }
                            else if (!dataModel.changeEntryName(columnNr,newName)) {
                                return false;
                            }
                            imageId.lastImageName = newName;
                            return true;
                        }

                        Component.onCompleted: {
                            console.log("created: DoNotLoad=" + repeaterId.doNotLoad)
                            if (repeaterId.doNotLoad) {
                                repeaterId.doNotLoad = false;
                            }
                            var listIndex = repeaterId.itemAt(index).SwipeView.index + 1
                            imageId.source  = dataModel.getEntryFilename(listIndex);
                            lbImagename.text = dataModel.getEntryName(listIndex);
                            imageId.lastImageName = lbImagename.text
                            inputContainer.myIndex = listIndex;
                        }

                        Component.onDestruction: {
                            console.log("destroyed:", index)
                        }

                        MessageDialog {
                            property bool errorByOnYes: false
                            id: messageDialog
                            title: "Nachricht"
                            text: "Soll der Eintrag " + lbImagename.text + " wirklich entfernt werden! "        //visible: messageDialogVisible.checked
                            buttons: MessageDialog.Yes | MessageDialog.No;

                           onButtonClicked: function (button, role) {

                               switch (button) {
                               case MessageDialog.Yes:
                                   console.log("delete item");
                                   delete entry
                                   var loopIdx = repeaterId.itemAt(index).SwipeView.index + 1
                                   while (repeaterId.itemAt(loopIdx) !== null) {
                                       if (repeaterId.itemAt(loopIdx).SwipeView.index !== -1) {
                                           if (repeaterId.itemAt(loopIdx).SwipeView.index === repeaterId.itemAt(index).SwipeView.index + 1) {
                                               repeaterId.doNotLoad = true
                                               view.setCurrentIndex(repeaterId.itemAt(loopIdx).SwipeView.index)
                                               break;
                                           }
                                       }
                                       loopIdx++;
                                   }
                                   if (!dataModel.deleteEntry(repeaterId.itemAt(index).SwipeView.index+1)) {
                                       text = "Fehler beim entfernen";
                                       buttons = StandardButton.Abort;
                                       visible = true;
                                       return;
                                   }
                                   for (var i=1; i <= dataModel.getEntriesSize();i++) {
                                       console.debug("imgename="+dataModel.getEntryName(i))
                                   }
                                   entryModelAvailablePackagesId.descCnt(listPackages.currentIndex);
                                   view.removeItem(repeaterId.itemAt(index).SwipeView.index);
                                   break;

                                }
                            }
                        }
                    }
                }
            }
            function loadPackage (packageName) {
                //repeaterId.destroy()
                repeaterId.model =  dataModel.loadPackage(packageName);
                currentPackageName = packageName
            }
        }
    }
}
