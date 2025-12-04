import QtQuick 2.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

Rectangle {
    id: app
    width: parent.width
    height: parent.height
    color: "transparent"

    function text(){
        if(typeof n3ctaApp !== "undefined"){
            return "Mfumo uko kwenye maboresho.";
        }else if(typeof loader !== "undefined"){
            return "System is under maintainance.";
        }
    }

    function executeCommand(url)
    {
        if(typeof n3ctaApp !== "undefined"){
            n3ctaApp.onUrlVisited(url);
        }else if(typeof loader !== "undefined"){
            n3ctaQmlConnectionsPipe.onUrlVisited(url);
        }
    }

    function img(){

        return "./systemImg.png";

        if(typeof n3ctaApp !== "undefined"){
            return "qrc:/images/processing.gif";
        }else if(typeof loader !== "undefined"){
            return "qrc:/processing.gif";
        }
    }

    AnimatedImage{
        id: img
        width: parent.width * 0.90
        height: parent.height * 0.50
        source: app.img()
        anchors.centerIn: parent
    }

    Rectangle{
        width: parent.width - 2
        anchors.leftMargin: 1
        anchors.rightMargin: 1
        anchors.topMargin: 16
        height: header.height
        color: "transparent"
        opacity: 0.6
        anchors.top: img.bottom

        Text {
            id:header
            text: app.text()
            font.pointSize: Qt.platform.os === "android" ? 18 : 16
            wrapMode: Text.WordWrap
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

    }

    MouseArea{
        anchors.fill: parent
        onClicked: {
            if(typeof n3ctaApp !== "undefined"){
                n3ctaApp.showToastMessage("Tafadhali subiri.");
            }else if(typeof loader !== "undefined"){
                nectaMainResultsPageDownloaderHtmlToXmlConveterAndSaver.showToastMessage("Please wait.");
            }
            app.executeCommand("#showGoogleAd");
        }
    }
}
