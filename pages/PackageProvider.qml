// TODO: Packagename in Listbox

import QtQuick 2.6
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.1

import "../model"

Page {

    DataModel {
      id: dataModel
    }

    id: pagePackageProvider

    property int actualPageHeight: height

    onHeightChanged: {
        console.log("view changed!!");
    }

    GroupBox {
        id: gbLearnListId
        property bool expanded: false
        title: qsTr("GroupBox")
        width: parent.width
        height: parent.height * 0.35
        anchors.top: parent.top
        anchors.topMargin: 30
        background: CustomBox {
            borderColor: "black"
            borderWidth: 2
            textWidthFactor:0.22
        }       
        Button {
            id: installPackageId

            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5

            height: 80;
            width:  80;

            Image {
                id:getPhoto
                source:"qrc:/icons/installer_icon.png";
                height: parent.height;
                width:  parent.width;
            }
            background: Rectangle {
                border.width: 3
                radius: 10
            }

            onClicked: {
                var  result = {};
                console.log(entryModelAvailablePackagesId.get(listPackages.currentIndex).name + ' selected');
                dataModel.installPackage(entryModelAvailablePackagesId.get(listPackages.currentIndex).name, result);
                console.log(result.RETURN_TXT);
                messageDialog.text = result.RETURN_TXT
                messageDialog.open();
                /* get selected item text */
                //showActivePackages(show);
            }
            MessageDialog {
                id: messageDialog
                title: "Fehler"
                text: ""
                standardButtons: StandardButton.Abort;
            }
        }

        label: Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: -height/2
            //anchors.bottomMargin: -height/2
            color: "transparent"
            width: parent.width * 0.8
            Text {
                id: titleGBLearnListId
                text: qsTr("Liste aller installierbarer Übungspakete ")
                anchors.centerIn: parent
                font.pixelSize: 12
            }
        }
        ListModel {
            id: entryModelAvailablePackagesId
            Component.onCompleted: {
                var list = dataModel.getInstallablePackages();
                for (var i = 0; i < list.length; i++) {
                    append(createListElement(list[i]));
                }
            }
            function createListElement(packageName) {
                return {
                    name: packageName
                };
            }
            function descCnt(idx) {
                setProperty(idx, "count", get(idx).count - 1)

            }
        }

        ListView {
              id: listPackages
              //anchors.horizontalCenter: parent.horizontalCenter
              anchors.top: parent.top
              //anchors.topMargin: 20
              anchors.left: parent.left
              anchors.leftMargin: 10
              width: parent.width * 0.7
              height:parent.height
              model: entryModelAvailablePackagesId
              ScrollBar.vertical: ScrollBar {
                          id: scBarId
                          policy: ScrollBar.AlwaysOn
                          active: ScrollBar.AlwaysOn
              }
              clip:true
              delegate: Component {
                  Item {
                      width: parent.width * 0.9
                      height: 30
                      Row {
                          padding:3
                          //anchors.horizontalCenter: parent.horizontalCenter
                          anchors.verticalCenter: parent.verticalCenter
                          spacing: 2
                          Text {
                              font.pixelSize: 14
                              text: name
                          }
                          Text {
                              font.pixelSize: 14
                          }

                      }
                      MouseArea {
                          anchors.fill: parent
                          onClicked: listPackages.currentIndex = index
                      }
                  }
              }
              highlight: Rectangle {
                  color: 'grey'
                  radius:5
              }

              focus: true
        }
    }
}
