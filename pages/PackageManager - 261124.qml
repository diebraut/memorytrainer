// TODO: Packagename in Listbox

import QtQuick 2.6
import QtQuick.Controls 2.1
//import QtQuick.Controls.Styles 1.0
//import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 6.4

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
        distBetweenListGroupB = gbCreateRandomPackage.y - (listPackages.y + listPackages.height);
        console.log("dist=" + parseInt(distBetweenListGroupB));
    }


    MessageDialog {

        id: deletePackage;
        objectName: "msgBox";
        //icon : StandardIcon.Information
        title: "Information";
        buttons: MessageDialog.Yes | MessageDialog.No
        property string packName
        onButtonClicked: function (button, role) {
            switch (button) {
            case MessageDialog.Yes:
                console.log("delete package")
                var  result = {};
                if (!dataModel.removePackage(packName,result)) {
                    console.debug("delete package" + packName + "failed");
                    msgDialog.text = result.RETURN_VALUE;
                    msgDialog.openDlg(result.RETURN_TYPE,result.RETURN_VALUE);
                    return;
                }
            }
            entryModelAvailablePackagesId.clear();
            entryModelAvailablePackagesId.loadData();
        }

        function displayMessageBox(packageName) {
            packName = packageName
            deletePackage.text = "Soll das Paket (" + packName  + ") endgültig gelöscht werden?";
            deletePackage.open();

            console.log("Got message:", deletePackage.text);
        }
     }

    MessageDialog
    {
        id: msgDialog
        title: "Nachricht"
        text: "default"
        //informativeText: "default"
        //icon: StandardIcon.Information
        visible: false
        function openDlg(type,textIn) {
            if (type === "INFO") {
                icon = StandardIcon.Information;
            }
            if (type === "Warning") {
                icon = StandardIcon.Warning;
            }
            if (type === "ERROR") {
                icon = StandardIcon.Critical;
            }
            text = textIn;
            open();
        }
    }


    Rectangle
    {
        id: parentRect
        anchors.fill: parent
        color: "lightgray"
    }

    ListModel {
        id: entryModelAvailablePackagesId

        Component.onCompleted: {
            loadData();
        }
        function createListElement(packageName,cnt) {
            return {
                name: packageName,
                count: cnt,
                selected: false
            };
        }
        function descCnt(idx) {
            setProperty(idx, "count", get(idx).count - 1)

        }
        function loadData() {
            var list = dataModel.getPackages();
            for (var i = 0; i < list.length; i++) {
                append(createListElement(list[i],dataModel.getPackageEntries(list[i])));
            }
        }
    }

    Component {
        id: packageListDelegate
        Item {
            id: compId
            width: listPackages.width - 60;
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
                        acceptedButtons: Qt.RightButton | Qt.LeftButton
                        onClicked: {
                            if (mouse.button === Qt.RightButton) {
                                contextMenu.popup()
                            }
                            else if (mouse.button === Qt.LeftButton) {
                                listPackages.currentIndex = index
                            }
                        }
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
                                   deletePackage.displayMessageBox(name)
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
                      if (name.substr(0,1) === "_") {
                         false;
                      }
                      else
                         true;
                   }
                   id : cbSelectPackage
                   height: compId.height
                   width:40
                   checked: {
                       if (name.substr(0,1) === "_" || !selected) {
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
          width: parent.width - 20

          anchors.bottom: viewSinglePackage.top
          anchors.bottomMargin:  2 * bCollectPackages.height
          //height:200

          //height:rectAvailPackages.height -30
          model: entryModelAvailablePackagesId
          clip:true

          property int pWidth: parent.width



          delegate: packageListDelegate
          highlight: Rectangle { x:20; color: "lightsteelblue"; radius: 5 }
          focus: true
          onCurrentItemChanged: {
              //console.log(model.get(listPackages.currentIndex).name + ' selected')
              console.log("idx=" + listPackages.currentIndex)
              if ((listPackages.currentIndex) >= 0 ) {
                view.loadPackage(model.get(listPackages.currentIndex).name)
                searchId.setText("");
              }
          }
    }


    Rectangle {
        id: sepLine
        anchors.top: listPackages.bottom
        width: pagePackageManager.width
        height:1
        color: "gray"
    }


    Button {
        id: bCollectPackages
        anchors.top: sepLine.bottom
        anchors.topMargin: 15;
        anchors.right: parent.right
        anchors.rightMargin: 10
        height: gbCreateRandomPackage.buttonSizeHeight;
        //width:  gbCreateRandomPackage.buttonSizeWidth;
        font.pointSize: 10
        font.bold: true
        text: "Erzeuge Auswahl-Paket"
        background: Rectangle {
            height: parent.height;
            width:  parent.width;
            color: bCollectPackages.down ? "#d6d6d6" : "#f6f6f6"
            border.color: "black"
            border.width: 2
            radius: 4
        }
        onClicked: {
            gbCreateRandomPackage.enablePackageCreation(true);
        }
    }

    GroupBox {
        id: gbCreateRandomPackage

        visible:false
        property int buttonSizeHeight:50
        property int buttonSizeWidth:120

        title: qsTr("GroupBox")
        width: pagePackageManager.width
        height:buttonSizeHeight * 4.5
        //anchors.top :  cbAllPackages.top
        anchors.bottom : parent.bottom

        background: CustomBox {
            y: gbCreateRandomPackage.topPadding - gbCreateRandomPackage.padding
            width: pagePackageManager.width
            height: parent.height - gbCreateRandomPackage.topPadding + gbCreateRandomPackage.padding
            borderColor: "black"
            borderWidth: 1
            textWidthFactor:0.35
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
                id: titleGBLearnListId
                text: qsTr("Paket aus Übungen zusammenstellen.")
                anchors.centerIn: parent
                font.pixelSize: 12
            }
         }
         Button {
             id: bCancel
             enabled: false;
             width:my_text.width +10
             anchors.right: parent.right
             anchors.bottom: bCreatePackages.top
             anchors.bottomMargin: 10
             height: gbCreateRandomPackage.buttonSizeHeight;
             background: Rectangle {
                 height: parent.height;
                 width:  parent.width;
                 color: bCreatePackages.down ? "#d6d6d6" : "#f6f6f6"
                 border.color: "black"
                 border.width: 2
                 radius: 4
             }
             Text {
                 id: my_text
                 anchors {centerIn: parent }
                 text: "Abbrechen"
                 font.pointSize: 12
                 font.bold: true
             }
             onClicked: {
                 gbCreateRandomPackage.enablePackageCreation(false);
             }
         }

         Button {
             id: bCreatePackages
             anchors.left: bCancel.left
             anchors.right: parent.right
             //anchors.rightMargin: 5
             anchors.bottom: parent.bottom
             anchors.bottomMargin: 5
             height: gbCreateRandomPackage.buttonSizeHeight;
             font.pointSize: 12
             font.bold: true
             text: "Erstellen"
             property var usePackages: []

             background: Rectangle {
                 height: parent.height;
                 width:  parent.width;
                 color: bCancel.down ? "#d6d6d6" : "#f6f6f6"
                 border.color: "black"
                 border.width: 2
                 radius: 4
             }
             onClicked: {
                 var usePackages = []

                 for (var i = 0; i < entryModelAvailablePackagesId.count; i++) {
                     if (entryModelAvailablePackagesId.get(i).selected) {
                         console.debug("put" + entryModelAvailablePackagesId.get(i).name);
                         usePackages.push([entryModelAvailablePackagesId.get(i,0).name,entryModelAvailablePackagesId.get(i,0).count]);
                     }
                 }
                 var  result = {};
                 if (!dataModel.createMixPackage(packageName.text,sPCountEcerzises.value,usePackages,result)) {
                     console.debug("create package failed");
                     msgDialog.text = result.RETURN_VALUE;
                     msgDialog.openDlg(result.RETURN_TYPE,result.RETURN_VALUE);
                     return;
                 }
                 entryModelAvailablePackagesId.clear();
                 entryModelAvailablePackagesId.loadData();
                 gbCreateRandomPackage.enablePackageCreation(false);
             }
         }

         CheckBox {
             id: cbAllPackages
             enabled: false;
             height: parent.height / 4
             anchors.bottom: sPCountEcerzises.top
             anchors.bottomMargin: 20
             anchors.left: parent.left
             anchors.leftMargin: -7
             text: qsTr("Alle Packete")
             onCheckedChanged: {
                for (var i=0;i < entryModelAvailablePackagesId.rowCount();i++) {
                   entryModelAvailablePackagesId.setProperty(i,"selected",checked);
                }
             }
         }

         SpinBox {
             id: sPCountEcerzises
             enabled: false;
             height: bCancel.height
             Text {
                 anchors.bottom: parent.top
                 text: qsTr("Anzahl Einträge")
             }
             anchors.right: packageName.right
             anchors.bottom: packageName.top
             anchors.bottomMargin: 25
             anchors.left:packageName.left
             anchors.leftMargin:-2
             font.pointSize: 14
             value: 50
             from: 1
             to: 999
             editable: true;
         }

         TextField {
             id:packageName
             enabled: false;
             height: bCancel.height
             anchors.bottom: parent.bottom
             anchors.bottomMargin: 5
             anchors.left: parent.left
             anchors.leftMargin: 3
             anchors.right: bCancel.left
             anchors.rightMargin: 100
             font.pointSize: 12
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
                 text: qsTr("Packetname")
             }
         }


         function enablePackageCreation(on) {
             //bCreatePackages.enabled = on;
             sPCountEcerzises.enabled = on;
             cbAllPackages.enabled = on;
             bCancel.enabled = on;
             packageName.enabled = on;
             viewSinglePackage.visible = !on;
             bCollectPackages.enabled = !on;
             if (on) {
                 gbCreateRandomPackage.visible = true;
                 viewSinglePackage.visible = false;
                 listPackages.anchors.bottomMargin -= distBetweenListGroupB;
                 bCollectPackages.visible = false;
                 sepLine.visible = false;

                 listPackages.delegate = packageSelectDelegate;
                 listPackages.currentIndex = -1;
                 pagePackageManager.selectPackageMode = false
             }
             else {
                 listPackages.anchors.bottomMargin += distBetweenListGroupB;
                 bCollectPackages.visible = true;
                 sepLine.visible = true;

                 gbCreateRandomPackage.visible = false;

                 listPackages.delegate = packageListDelegate;
                 listPackages.currentIndex = 0;
                 pagePackageManager.selectPackageMode = true
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
            anchors.bottom: pageIndicator.top
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
                                if (Qt.platform.os == "ios") {
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
        SearchBox {
            id: searchId;
            anchors.bottom: parent.bottom
            property bool changedBySearch:false
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.5
            //KeyNavigation.tab: search2;
            //KeyNavigation.backtab: search3;
            focus: true
            onSearchTextChanged: {
                var txt = getText();
                //console.debug("key pressed="+txt);
                if (txt !== "") {
                    var pos = dataModel.getMatchingEntry(txt);
                    if (pos >= 0) {
                        changedBySearch = true;
                        view.currentIndex = pos;
                        changedBySearch = false;
                    }
                 }
            }
            function resetSearchtext () {
                if (changedBySearch) {
                    changedBySearch = false;
                }
                else {
                    setText("")
                }
            }
        }

        Button {
            id: forwardId
            //checkable: false
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3
            anchors.left: parent.left
            property int sideLength : pageIndicator.height * 2.5
            Image {
                source: "qrc:/icons/icon_forward_332.png"
                height: parent.sideLength;
                width:  parent.sideLength;
                //fillMode: Image.Tile
            }
            height: sideLength;
            width: sideLength;
            onClicked: {
                searchId.setText("");
                if (view.currentIndex < view.count)
                    view.currentIndex++
            }
        }

        Button {
            id: backwardId
            //checkable: false
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3
            anchors.right: parent.right
            property int sideLength : pageIndicator.height * 2.5
            Image {
                source: "qrc:/icons/icon_back_293.png"
                height: parent.sideLength;
                width:  parent.sideLength;
                //fillMode: Image.Tile
            }
            height: sideLength;
            width: sideLength;
            onClicked: {
                searchId.setText("");
                if (view.currentIndex > 0)
                    view.currentIndex--
            }
        }

        PageIndicator {
            id: pageIndicator
            property bool currentIndexChangeFromPageView:false

            //anchors.top: repeaterId.bottom
            anchors.bottom: searchId.top
            anchors.bottomMargin: 5

            anchors.horizontalCenter :parent.horizontalCenter
            width:  parent.width * 0.7
            height: parent.height * 0.075

            //clip: true
            padding: 0
            spacing: 5
            /*
            count: {
                if (view.count <= 12) {
                    count = 12
                } else {
                    count = view.count
                }
            }
            */
            count:view.count
            currentIndex: 0
            onCurrentIndexChanged: {
                if (currentIndexChangeFromPageView) {
                    currentIndexChangeFromPageView = false
                }
                else {
                    searchId.resetSearchtext();
                    view.currentIndexChangeFromPageIndicator = true
                    if (view.count > 20) {
                        var newC = ((currentIndex * (view.count+1))/count).toFixed();
                        if (newC  > (view.count - 1)) {
                            newC--
                        }
                        view.currentIndex = newC
                    }
                    else {
                        view.currentIndex = currentIndex;
                    }
                }
            }

            delegate: Rectangle {

                implicitWidth : (pageIndicator.width - ((pageIndicator.count-1)*pageIndicator.spacing)) / pageIndicator.count
                implicitHeight: 15//implicitWidth
                anchors.topMargin: 5

                radius: width / 2
                color: index === pageIndicator.currentIndex ? "black" : "gray"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageIndicator.currentIndex = index;
                        return;
                    }
                }
            }
        }

    }
}
