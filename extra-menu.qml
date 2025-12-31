import QtQuick 2.6
import QtQuick.Window 2.2

Rectangle{
    id: root
    color: "#004d4d"

    function getIconSource(name,color)
    {
        return "image://iconprovider/iconname:"+name+"*color:"+color;
    }

    function executeCommand(cmd,argv)
    {
        loader.executeCommand(cmd, argv);
        nectaMainResultsPageDownloaderHtmlToXmlConveterAndSaver.closeSavedResultsDialog();
        n3ctaQmlConnectionsPipe.doCloseMenu();
    }

    Rectangle{
        id: topLine
        color: "cyan"
        width: parent.width
        height: 2
        anchors.top: parent.top
    }

    Column{
        id:menu
        anchors.top: topLine.bottom
        anchors.topMargin: 8
        spacing: 10

        property real imgLeftMargin: 2
        property real textLeftMargin: 6


        Rectangle{
            z: root.z + 1
            color: "transparent"
            width: root.width
            height: icon1.paintedHeight

            Image {
                id: icon2
                width: 68
                height: width
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: menu.imgLeftMargin
                source: getIconSource("fa::book","#00e6e6")
            }

            Text {
                anchors.left: icon2.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menu.textLeftMargin
                color: Qt.lighter("gray",1.7)
                text: "Nukuu"
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    root.executeCommand("nukuu", []);
                }
            }
        }


        Rectangle{
            z: root.z + 1
            color: "transparent"
            width: root.width
            height: icon1.paintedHeight

            Image {
                id: icon1
                width: 68
                height: width
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: menu.imgLeftMargin
                source: getIconSource("fa::cog","#00e6e6")
            }

            Text {
                anchors.left: icon1.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menu.textLeftMargin
                color: Qt.lighter("gray",1.7)
                text: "Upakiaji"
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    root.executeCommand("upakiaji", []);
                }
            }
        }


        Rectangle{
            z: root.z + 1
            color: "transparent"
            width: root.width
            height: icon1.paintedHeight

            Image {
                id: icon3
                width: 68
                height: width
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: menu.imgLeftMargin
                source: getIconSource("fa::bello","#00e6e6")
            }

            Text {
                anchors.left: icon3.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menu.textLeftMargin
                color: Qt.lighter("gray",1.7)
                text: "Elimu"
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    root.executeCommand("#imageDialog;https://raw.githubusercontent.com/magabe26/mgb/master/Ads/elimu2.png;#showGoogleAd;0.98;0.8;500", []);
                }
            }
        }


        Rectangle{
            z: root.z + 1
            color: "transparent"
            width: root.width
            height: icon1.paintedHeight

            Image {
                id: icon9
                width: 68
                height: width
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: menu.imgLeftMargin
                source: getIconSource("fa::bello","#00e6e6")
            }

            Text {
                anchors.left: icon9.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menu.textLeftMargin
                color: Qt.lighter("gray",1.7)
                text: "Baada ya kufaulu"
            }


            MouseArea{
                anchors.fill: parent
                property string img: "dr-samia1.png"
                onClicked: {
                    root.executeCommand("#imageDialog;https://raw.githubusercontent.com/magabe26/mgb/master/Ads/" + img + ";#showGoogleAd;0.98;0.8;500", []);
                    img = (img === "dr-samia1.png") ? "dr-samia2.png" : "dr-samia1.png";
                }
            }
        }


        Rectangle{
            z: root.z + 1
            color: "transparent"
            width: root.width
            height: icon1.paintedHeight

            Image {
                id: icon4
                width: 68
                height: width
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: menu.imgLeftMargin
                source: getIconSource("fa::star","#00e6e6")
            }

            Text {
                anchors.left: icon4.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menu.textLeftMargin
                color: Qt.lighter("gray",1.7)
                text: "Nyerere"
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    root.executeCommand("#saveAndPlayVideoAd;https://raw.githubusercontent.com/magabe26/mgb/refs/heads/master/Ads/nyerere.mp4;#showGoogleAd;Baba wa Taifa la Tanzania;#004040;nyerere.mp4;", []);
                }
            }
        }


        Rectangle{
            z: root.z + 1
            color: "transparent"
            width: root.width
            height: icon1.paintedHeight

            Image {
                id: icon6
                width: 68
                height: width
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: menu.imgLeftMargin
                source: getIconSource("fa::star","#00e6e6")
            }

            Text {
                anchors.left: icon6.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menu.textLeftMargin
                color: Qt.lighter("gray",1.7)
                text: "Samia"
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    root.executeCommand("#saveAndPlayVideoAd;https://raw.githubusercontent.com/magabe26/mgb/refs/heads/master/Ads/samia.mp4;#;Rais wa Tanzania;#004040;samia.mp4;", []);
                }
            }
        }


        Rectangle{
            z: root.z + 1
            color: "transparent"
            width: root.width
            height: icon1.paintedHeight

            Image {
                id: icon5
                width: 68
                height: width
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: menu.imgLeftMargin
                source: getIconSource("fa::graduationcap","#00e6e6")
            }

            Text {
                anchors.left: icon5.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menu.textLeftMargin
                color: Qt.lighter("gray",1.7)
                text: "Samia scholarship"
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    root.executeCommand("#openurl;https://olas.heslb.go.tz/olams/pre-applicant/apply-for-scholarship", []);
                }
            }
        }

        Rectangle{
            z: root.z + 1
            color: "transparent"
            width: root.width
            height: icon1.paintedHeight

            Image {
                id: icon10
                width: 68
                height: width
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: menu.imgLeftMargin
                source: getIconSource("fa::snowflakeo","#00e6e6")
            }

            Text {
                anchors.left: icon10.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menu.textLeftMargin
                color: Qt.lighter("gray",1.7)
                text: "🎆Heri ya mwaka mpya 2026🙏🏾"
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    root.executeCommand("#imageDialog;https://raw.githubusercontent.com/magabe26/mgb/master/Ads/new-year-2026-2.png;#showGoogleAd;0.98;0.5;500", []);
                }
            }
        }

        AnimatedImage{
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.width
            height: 90
            source: "./tzflag.gif"
            onStatusChanged: {
                visible = (status !==  AnimatedImage.Error);
            }
        }

    }

    Rectangle{
        color: "cyan"
        width: parent.width
        height: 2
        anchors.top: menu.bottom
        anchors.topMargin: 8
    }
}
