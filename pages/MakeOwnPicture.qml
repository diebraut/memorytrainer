import QtQuick 2.9
import QtQuick.Controls 2.9

import QtMultimedia 5.4

//used for > Qt6
//import QtQuick3D

import ProcessaImagemQml 1.0

import "../model"
import "../global"

//Q_IMPORT_PLUGIN(QIOSIntegrationPlugin)

Page {

    id:pageCamera

    DataModel {
      id: dataModel
    }

    Util {
        id: utilID
    }

    visible: true

    title: "Camera Preview Test"

    Component.onCompleted: {

    }

    Rectangle {
        id: principal

        anchors.fill: parent
        color: "lightGrey"

        property bool cameraIsWide: false

        Component.onCompleted: {
            if (height > width) {
                cameraIsWide: false;
            }
            else {
                cameraIsWide: true;
            }
        }
        ProcessaImagem {
            id: processaImagem

            caminhoImagem: camera.caminhoPreview
            caminhoSalvar: camera.caminhoSalvar
            //rectRecorte: camera.rectRecorte
            //tamanhoImagem: camera.tamanhoImagem
            anguloOrientacaoCamera: camera.orientation
            posicaoCamera: camera.position

            onCaminhoImagemChanged: {
                //rectRecorte = cameraView.mapRectToSource(Qt.rect(cameraView.x, cameraView.y, cameraView.width, cameraView.height));
                tamanhoImagem = Qt.size(cameraView.sourceRect.width, cameraView.sourceRect.height);
                ProvedorImagem.carregaImagem(processaImagem.carregaImagem());
            }

            onCaminhoSalvarChanged: {
                removeImagemSalva();
            }
        }

        Rectangle {
            id: cameraRectangle

            height: parent.height
            width: parent.width;
            anchors.top: parent.top

            color: "lightGrey"

            visible: true


            onHeightChanged: {
                if (parent.height > parent.width) {
                    console.log("long format or="+camera.orientation);
                    width = parent.width;
                    parent.cameraIsWide = false;
                    x = 0;
                }
                else {
                    console.log("wide format");
                    width = parent.height * 1.2;
                    anchors.leftMargin = (parent.width -width)/2;
                    console.log("al"+anchors.leftMargin);
                    parent.cameraIsWide = true;
                    x = x + (parent.width -width)/2;
                }
            }
            Camera  {
                id: camera

                property string caminhoPreview: ""
                property string caminhoSalvar: ""
                property int numeroImagem: 0

                captureMode: Camera.CaptureStillImage

                Component.onCompleted: {
                    if (cameraState != Camera.ActiveState)  {
                       imagemPreview.source = "\/exercisepackages\/pack1\/Ben Affleck.jpg";
                       imagemPreviewRectangle.visible = true;
                    }
                }


                imageCapture {
                    onImageCaptured: {
                        console.log("img captured1 orientation=" + camera.orientation);
                        camera.caminhoPreview = preview;
                        camera.stop();
                        imagemPreview.source = "image://provedor/imagemEditada_" + camera.numeroImagem.toString();
                        camera.numeroImagem = camera.numeroImagem + 1;
                        imagemPreviewRectangle.visible = true;
                        cameraRectangle.visible = false;
                    }

                    onImageSaved: {
                        console.log("img is saved("+path+")");
                        camera.caminhoSalvar = path;
                    }
                }
            }
            VideoOutput {
                id: cameraView
                visible: true
                focus: visible
                anchors.fill: parent
                source: camera
                autoOrientation: true;
                fillMode: VideoOutput.PreserveAspectCrop
            }
        }

        Rectangle {
            id: imagemPreviewRectangle

            width: parent.width
            height: parent.height * 0.8
            anchors.top: parent.top
            color: "lightGrey"
            //color: "yellow"
            visible: false

            Image {
                id: imagemPreview
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                autoTransform: true

                rotation: {
                    if (!principal.cameraIsWide) {
                        //processaImagem.anguloOrientacaoCamera = 0;
                        return 0;
                    }
                    else {
                        //processaImagem.anguloOrientacaoCamera = 270;
                        return 270;
                    }
                }

            }
        }
        Button {
            id: imageSave
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Bild speichern")
            text: "Bild Speichern."

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5

            //anchors.left: imagemPreview.left
            //anchors.leftMargin: 5

            height: 28

            //enabled: false;
            visible: false;

            background: Rectangle {
                border.color: "green"
                border.width: 3
                radius: 4
            }
            onClicked: {
                console.log("Clicked Speichern");
                if (!utilID.ifMobile()) {
                    enabled = false;
                }
                //check input
                if (Qt.platform.os != "android" || inputContainer.imageNameAvailable) {
                    controleRectangle.callSaveImage(inputName.text,principal.cameraIsWide);
                    if (inputContainer.imageNameAvailable) {
                        inputContainer.imageNameAvailable = false;
                    }
                }
            }
        }
        Item {
            id: inputContainer
            visible: false;
            //anchors.centerIn: parent
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.left: imageSave.right
            width : parent.width - (imageSave.width + 10)
            anchors.leftMargin: 5
            height: 28

            property bool keyReturnPressed: false;
            property bool imageNameAvailable: false;

            BorderImage {
                source: "qrc:/images/lineedit.sci"
                anchors.fill: parent
            }
            TextInput {
                id: inputName
                //text : "";
                color: "#151515"; selectionColor: "green"
                font.pixelSize: 16;
                width: parent.width

                maximumLength: 16
                //horizontalAlignment : TextInput.AlignHCenter
                verticalAlignment : TextInput.AlignVCenter

                property var rect : Qt.inputMethod.keyboardRectangle;
                focus: true

                Component.objectName: {
                    x = x + 5;
                }

                onRectChanged: {
                    if (rect.height === 0) {
                      inputContainer.anchors.bottomMargin = 0;
                      imageSave.anchors.bottomMargin = 0;
                    }
                    else {
                        inputContainer.anchors.bottomMargin = 10;
                        imageSave.anchors.bottomMargin = 10;
                    }
                }
                onEditingFinished: {
                    console.log("onEditingFinished");
                    if (Qt.platform.os == "ios") {
                        console.log("ios detected");
                        return;
                    }

                    if (inputName.text.trim().length > 0) {
                        if (utilID.ifMobile()) {
                            if (inputContainer.keyReturnPressed) {
                                inputContainer.keyReturnPressed = false;
                                if (controleRectangle.callSaveImage(inputName.text,principal.cameraIsWide)) {
                                    //inputName.text = "";
                                    imageSave.enabled = true;
                                }
                            }
                            else {
                                inputContainer.imageNameAvailable = true;
                            }
                        }
                    }
                    else {
                        imageSave.enabled = false;
                    }
                }

                Keys.onPressed: {
                    if (event.key === Qt.Key_Return) {
                      if (Qt.platform.os == "ios") {
                         if (controleRectangle.callSaveImage(inputName.text,principal.cameraIsWide)) {
                            //text = "";
                            imageSave.enabled = true;
                         }
                         else {
                            imageSave.enabled = false;
                         }
                      }
                      else {
                          inputContainer.keyReturnPressed = true;
                      }

                      return;
                    }
                    if (!utilID.ifMobile()) {
                        if (text.trim().length > 0)
                            imageSave.enabled = true;
                        else
                            imageSave.enabled = false;
                    }
                }
            }
        }
        Rectangle {
            id: controleRectangle

            width: parent.width
            //height: parent.height - cameraRectangle.height
            //color: "grey"
            color: "yellow"
            //anchors.bottom: inputContainer.top
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1

            Button {
                id: novaFotoButton

                ToolTip.visible: hovered
                ToolTip.text: qsTr("Neue Aufnahme")
                enabled: false;
                visible: false;

                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.bottom: parent.top
                anchors.bottomMargin:  37

                height: 60;
                width:  60;

                background: Rectangle {
                    border.color: "yellow"
                    border.width: 3
                    radius: 4
                }

                Image {
                    id:getPhoto
                    source: "qrc:/icons/photo-640.png"
                    height: parent.height - 8;
                    width:  parent.width - 8;
                    x:4
                    y:4
                }

                onClicked: {
                    inputName.text = "";
                    camera.start();
                    imagemPreviewRectangle.visible = false;
                    cameraRectangle.visible = true;
                    enabled = false;
                    visible = false;
                    tirarFotoButton.enabled = true
                    tirarFotoButton.visible = true
                    inputContainer.visible =  false;
                    imageSave.visible      =  false;
                    if (!utilID.ifMobile()) {
                        imageSave.enabled = false;
                        imageSave.visible = false;
                    }
                }
            }
            Button {
                id: tirarFotoButton
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Bild aufnehmen")

                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.bottom: parent.bottom
                anchors.bottomMargin:  5

                height: 60;
                width:  60;

                background: Rectangle {
                    border.color: "black"
                    border.width: 3
                    radius: 4
                }

                Image {
                    source: "qrc:/icons/photo-save_640.png"
                    height: parent.height - 8;
                    width:  parent.width - 8;
                    x:4
                    y:4
                }

                onClicked: {
                    camera.imageCapture.capture();
                    dataModel.setSaveToPackage("pack1");
                    enabled = false;
                    visible = false;

                    novaFotoButton.enabled = true;
                    novaFotoButton.visible = true;
                    inputContainer.visible = true;
                    imageSave.visible      = true;

                    if (!utilID.ifMobile()) {
                        imageSave.enabled = false;
                        imageSave.visible = true;
                    }
                }
            }
            Label {
                id:meldungsLog
                //width:parent.width
                anchors.bottom: parent.top
                anchors.bottomMargin:  37
                anchors.right: novaFotoButton.left
                anchors.rightMargin:5
                horizontalAlignment :  Text.Right
                color:"green"
                font.pixelSize: 20;
                //background: "yellow"
                //text:"meldung"
            }
            Timer {
                id:meldungsTimer;
                interval: 3000;
                running: false;
                repeat: false;
                onTriggered: {
                    meldungsLog.text = "";
                    running = false;
                }
            }
            //save image
            function callSaveImage(txt,isWideFormat) {
                if (dataModel.existImage(txt) ) {
                    meldungsLog.text = "Bereits gespeichert!";
                    return false;
                }
                else {
                    console.log("called saveLastPictureTaken");
                    if (dataModel.saveLastPictureTaken(txt,isWideFormat))
                    {
                        meldungsLog.text = "Gespeichert";
                    }
                    else {
                        meldungsLog.text = "Fehler bei der Speicherung!";
                        return false;
                    }
                }
                meldungsTimer.start();
                return true;
            }
        }
    }
}
