import QtQuick 2.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

Rectangle {
    id: app
    width: parent.width
    height: parent.height
    color: "white"

    function executeCommand(url)
    {
        n3ctaQmlConnectionsPipe.onUrlVisited(url);
        nectaMainResultsPageDownloaderHtmlToXmlConveterAndSaver.closeQMLDialog();
    }

    Text {
        id:header
        text: "TANZANIA"
        font.pointSize: Qt.platform.os === "android" ? 24 : 22
        wrapMode: Text.WordWrap
        font.bold: true
        color: "#00c000"
        anchors.top: app.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    AnimatedImage{
        id: flag
        source: "./tzflag.gif"
        width: parent.width
        height: parent.height * 0.4
        anchors.top: header.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }


    Rectangle{
        id:rec1
        width: parent.width
        height: txt1.height + txt2.height
        color: "transparent"
        anchors.top: flag.bottom
        anchors.topMargin: 10

        Text {
            id:txt1
            text: "<font color=\"gray\"><i>Rais wa Jamhuri ya Muungano wa Tanzania</i></font>"
            width: app.width
            anchors.top: parent.top
            font.pointSize: 12
            font.bold: true
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            id:txt2
            text: "<font color=\"green\">MHE. DKT. SAMIA SULUHU HASSAN</font>"
            width: app.width
            anchors.top: txt1.bottom
            font.pointSize: Qt.platform.os === "android" ? 16 : 14
            font.bold: true
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            anchors.horizontalCenter: parent.horizontalCenter
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                app.executeCommand("#imageDialog;https://raw.githubusercontent.com/magabe26/mgb/refs/heads/master/Ads/Samia-Suluhu-Hassan-2.jpg.jpg;#showGoogleAd;0.9;0.45;500");
            }
        }

    }

    Rectangle{
        id: rec2
        anchors.top: rec1.bottom
        anchors.topMargin: 18
        width: parent.width
        height: txt3.height + txt4.height
        color: "transparent"

        Text {
            id:txt3
            text: "<font color=\"gray\"><i>Rais wa Zanzibar na Mwenyekiti wa Baraza la Mapinduzi</i></font>"
            width: app.width
            anchors.top: parent.top
            font.pointSize: 12
            font.bold: true
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            id:txt4
            text: "<font color=\"green\">MHE. DKT. HUSSEIN ALI MWINYI</font>"
            width: app.width
            anchors.top: txt3.bottom
            font.pointSize: Qt.platform.os === "android" ? 16 : 14
            font.bold: true
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            anchors.horizontalCenter: parent.horizontalCenter
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                app.executeCommand("#imageDialog;https://raw.githubusercontent.com/magabe26/mgb/refs/heads/master/Ads/Hussein-Ali-Mwinyi.jpg;#showGoogleAd;0.9;0.45;500");
            }
        }

    }

    Rectangle{
        id:rec3
        width: parent.width
        height: txt5.height + txt6.height
        anchors.top: rec2.bottom
        color: "transparent"
        anchors.topMargin: 10

        Text {
            id:txt5
            text: "<font color=\"gray\"><i>Makamu wa Rais wa Jamhuri ya Muungano wa Tanzania</i></font>"
            width: app.width
            anchors.top: parent.top
            font.pointSize: 12
            font.bold: true
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            id:txt6
            text: "<font color=\"green\">MHE. DKT. EMMANUEL JOHN NCHIMBI</font>"
            width: app.width
            anchors.top: txt5.bottom
            font.pointSize: Qt.platform.os === "android" ? 16 : 14
            font.bold: true
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            anchors.horizontalCenter: parent.horizontalCenter
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                app.executeCommand("#imageDialog;https://raw.githubusercontent.com/magabe26/mgb/refs/heads/master/Ads/H.E_E.J.NCHIMBI.jpeg;#showGoogleAd;0.9;0.45;500");
            }
        }

    }

    Text {
        text: "*** <i>Amani na Umoja <font color=\"gray\">==</font> Ma-vibe ya Kijanja</i> ***"
        anchors.topMargin: 26
        width: app.width
        anchors.top: rec3.bottom
        font.pointSize: 8
        font.bold: true
        textFormat: Text.RichText
        wrapMode: Text.WordWrap
        anchors.horizontalCenter: parent.horizontalCenter
        color: "blue"
    }
}
