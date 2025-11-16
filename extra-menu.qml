import QtQuick 2.6
import QtQuick.Window 2.2
import mydevice 1.0


Rectangle{
    id: root
    color: "#004d4d"

    MyDevice { id: device }

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
        spacing: 8

        property real itemHeight: 48 * device.dp
        property real iconWidht: 68
        property real iconHeight: 68

        property real imgLeftMargin: 0.1 * iconWidht
        property real textLeftMargin: 0.3 * iconWidht

        property color textColor: Qt.lighter("gray",1.7)
        property color iconColor: "#00e6e6"

        Rectangle{
            z: root.z + 1
            color: "transparent"
            width: root.width
            height: menu.itemHeight

            Image {
                width: menu.iconWidht
                height: menu.iconHeight
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: menu.imgLeftMargin
                source: getIconSource("fa::book",menu.iconColor)
            }

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menu.iconWidht + menu.textLeftMargin
                color: menu.textColor
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
            height: menu.itemHeight

            Image {
                width: menu.iconWidht
                height: menu.iconHeight
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: menu.imgLeftMargin
                source: getIconSource("fa::cog",menu.iconColor)
            }

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menu.iconWidht + menu.textLeftMargin
                color: menu.textColor
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
            height: menu.itemHeight

            Image {
                width: menu.iconWidht
                height: menu.iconHeight
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: menu.imgLeftMargin
                source: getIconSource("fa::bello",menu.iconColor)
            }

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menu.iconWidht + menu.textLeftMargin
                color: menu.textColor
                text: "Elimu"
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    root.executeCommand("#imageDialog;https://raw.githubusercontent.com/magabe26/mgb/master/Ads/elimu.png;#showGoogleAd;0.9;0.8;500", []);
                }
            }
        }

        Rectangle{
            z: root.z + 1
            color: "transparent"
            width: root.width
            height: menu.itemHeight

            Image {
                width: menu.iconWidht
                height: menu.iconHeight
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: menu.imgLeftMargin
                source: getIconSource("fa::handoright",menu.iconColor)
            }

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menu.iconWidht + menu.textLeftMargin
                color: menu.textColor
                text: "Mengineyo"
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    root.executeCommand("#showGoogleAd", []);
                }
            }
        }

        Rectangle{
            z: root.z + 1
            color: "transparent"
            width: root.width
            height: menu.itemHeight

            Image {
                width: menu.iconWidht
                height: menu.iconHeight
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: menu.imgLeftMargin
                source: getIconSource("fa::star",menu.iconColor)
            }

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menu.iconWidht + menu.textLeftMargin
                color: menu.textColor
                text: "Nyerere"
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    root.executeCommand("#saveAndPlayVideoAd;https://raw.githubusercontent.com/magabe26/mgb/master/Ads/nyerere.mp4;#;Baba wa Taifa la Tanzania;#004040;nyerere.mp4;", []);

                }
            }
        }


        Rectangle{
            z: root.z + 1
            color: "transparent"
            width: root.width
            height: menu.itemHeight

            Image {
                width: menu.iconWidht
                height: menu.iconHeight
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: menu.imgLeftMargin
                source: getIconSource("fa::graduationcap",menu.iconColor)
            }

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menu.iconWidht + menu.textLeftMargin
                color: menu.textColor
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
            height: menu.itemHeight

            Image {
                width: menu.iconWidht
                height: menu.iconHeight
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: menu.imgLeftMargin
                source: getIconSource("fa::flag",menu.iconColor)
            }

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: menu.iconWidht + menu.textLeftMargin
                color: menu.textColor
                text: "TZ"
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    root.executeCommand("#tz", []);
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
