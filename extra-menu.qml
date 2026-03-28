import QtQuick 2.6
import QtQuick.Window 2.2

Rectangle {
    id: root
    color: "#004d4d"

    // ── Menu items ────────────────────────────────────────────────────────
    readonly property var extraMenu: [
        {
            text: "Nukuu",
            icon: "fa::book",
            cmd1: "nukuu",
            cmd2: "",
            section: "content"
        },
        {
            text: "Upakiaji",
            icon: "fa::cog",
            cmd1: "upakiaji",
            cmd2: "",
            section: "content"
        },
        {
            text: "Elimu",
            icon: "fa::bello",
            cmd1: "#imageDialog;https://raw.githubusercontent.com/magabe26/mgb/master/Ads/elimu2.png;#showGoogleAd;0.98;0.8;500",
            cmd2: "",
            section: "content"
        },
        {
            text: "Tujifunze Sayansi",
            icon: "fa::eyedropper",
            cmd1: "#imageDialog;https://raw.githubusercontent.com/magabe26/mgb/master/Ads/tujifunze-sayansi.png;#showGoogleAd;0.98;0.5;500",
            cmd2: "#imageDialog;https://raw.githubusercontent.com/magabe26/mgb/master/Ads/sayansi-3.png;#showGoogleAd;0.98;0.5;500",
            section: "content"
        },
        
        {
            text: "Pima uwezo wa akili yako sasa",
            icon: "fa::hourglass",
            cmd1: "#openApp;IQTest.qml;https://raw.githubusercontent.com/magabe26/mgb/refs/heads/master/;Please wait!;dependencies.txt;#;2;1;1;100;",
            cmd2: "",
            section: "links"
        },
        {
            text: "Cheza mchezo wa neno",
            icon: "fa::gamepad",
            cmd1: "#openApp;NenoGame.qml;https://raw.githubusercontent.com/magabe26/mgb/refs/heads/master/;Please wait;dependencies.txt;#;2;1;1;600;",
            cmd2: "",
            section: "links"
        },
        {
            text: "Cheza mchezo wa nyoka",
            icon: "fa::gamepad",
            cmd1: "#openApp;Snake.qml;https://raw.githubusercontent.com/magabe26/mgb/refs/heads/master/;Please wait!;dependencies.txt;#;2;1;1;100;",
            cmd2: "",
            section: "links"
        },
        {
            text: "Cheza mchezo wa bao",
            icon: "fa::gamepad",
            cmd1: "#openApp;BaoGame.qml;https://raw.githubusercontent.com/magabe26/mgb/refs/heads/master/;Please wait!;dependencies.txt;#;2;1;1;100;",
            cmd2: "",
            section: "links"
        },

    ]

    // ── Helpers ───────────────────────────────────────────────────────────
    function getIconSource(name, color) {
        return "image://iconprovider/iconname:" + name + "*color:" + color;
    }

    function executeCommand(cmd, argv) {
        loader.executeCommand(cmd, argv);
        nectaMainResultsPageDownloaderHtmlToXmlConveterAndSaver.closeSavedResultsDialog();
        n3ctaQmlConnectionsPipe.doCloseMenu();
    }

    // ── Ad system (ported from tztourism.qml) ────────────────────────────
    //
    // adsPool  — list of Component ids, one per ad
    // adsLang  — parallel list of "en" | "sw" | "both"
    //
    // To add a client ad:
    //   1. Create  Component { id: adClientX … }  below
    //   2. Append it to adsPool
    //   3. Append its lang at the same index in adsLang
    // ─────────────────────────────────────────────────────────────────────
    property var adsPool: [ adOwnerEN, adOwnerSW ]
    property var adsLang: [ "en",      "sw"      ]

    property int adRandomSeed: Math.floor(Math.random() * 9999)

    // Rotate ad seed every 3 minutes
    Timer {
        interval: 180000
        repeat: true
        running: true
        onTriggered: {
            root.adRandomSeed = Math.floor(Math.random() * 9999);
        }
    }

    // Pick an ad index matching the supplied language ("en" | "sw")
    function pickAd(language) {
        var pool = [];
        for (var i = 0; i < adsPool.length; i++) {
            var l = (adsLang[i] !== undefined) ? adsLang[i] : "both";
            if (l === language || l === "both") {
                pool.push(i);
            }
        }
        if (pool.length === 0) return -1;
        return pool[root.adRandomSeed % pool.length];
    }

    // Detect host app context (mirrors tztourism helpers)
    function isPrimaryResultsApp() {
        return (typeof n3ctaApp !== "undefined");
    }

    function isSecondaryResultsApp() {
        return (typeof loader !== "undefined");
    }

    function showToastMessage(msg) {
        if (isPrimaryResultsApp()) {
            n3ctaApp.showToastMessage(msg);
        } else if (isSecondaryResultsApp()) {
            nectaMainResultsPageDownloaderHtmlToXmlConveterAndSaver.showToastMessage(msg);
        }
    }

    // ── EN owner ad ───────────────────────────────────────────────────────
    Component {
        id: adOwnerEN
        Rectangle {
            width: parent ? parent.width : 0
            height: _enCol.height + 20
            color: "#ffffff"; radius: 8
            border.color: "#dadce0"; border.width: 1; clip: true

            Rectangle {
                anchors.top: parent.top; anchors.left: parent.left
                anchors.topMargin: 8; anchors.leftMargin: 10
                width: _enBadge.implicitWidth + 8
                height: _enBadge.implicitHeight + 4
                radius: 3; color: "#f0f0f0"; border.color: "#bbbbbb"; border.width: 1
                Text {
                    id: _enBadge
                    anchors.centerIn: parent
                    text: "Ad"
                    font.pointSize: Qt.platform.os === "android" ? 9 : 7
                    color: "#555555"
                }
            }

            Column {
                id: _enCol
                anchors.top: parent.top; anchors.topMargin: 30
                anchors.left: parent.left; anchors.right: parent.right
                anchors.leftMargin: 10; anchors.rightMargin: 10
                spacing: 6

                Text {
                    width: parent.width; wrapMode: Text.WordWrap; font.bold: true; color: "#1a0dab"
                    font.pointSize: Qt.platform.os === "android" ? 13 : 11
                    text: "📢 Advertise on this App!"
                }
                Text {
                    text: "matokeo.app › advertise"
                    font.pointSize: Qt.platform.os === "android" ? 10 : 8; color: "#006621"
                }
                Text {
                    width: parent.width; wrapMode: Text.WordWrap; color: "#333333"
                    font.pointSize: Qt.platform.os === "android" ? 11 : 9
                    text: "Reach thousands of users daily! List your Hotel, Hostel, Rental House e.t.c and get noticed by visitors from around the world."
                }
                Rectangle {
                    height: _enPrice.implicitHeight + 8; width: _enPrice.implicitWidth + 16
                    radius: 4; color: "#e8f5e9"; border.color: "#4caf50"; border.width: 1
                    Text {
                        id: _enPrice
                        anchors.centerIn: parent; font.bold: true; color: "#2e7d32"
                        font.pointSize: Qt.platform.os === "android" ? 11 : 9
                        text: "💰 From TZS 50,000/= per month"
                    }
                }
                Row {
                    spacing: 8
                    Rectangle {
                        id: _enCall; radius: 4; color: "#1a73e8"
                        height: _enCallTxt.implicitHeight + 10; width: _enCallTxt.implicitWidth + 20
                        property bool pressed: false; scale: pressed ? 0.96 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        Text {
                            id: _enCallTxt; anchors.centerIn: parent; font.bold: true; color: "white"
                            font.pointSize: Qt.platform.os === "android" ? 12 : 10; text: "📞  0789 081 122"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onPressed:  _enCall.pressed = true
                            onReleased: _enCall.pressed = false
                            onCanceled: _enCall.pressed = false
                            onClicked:  Qt.openUrlExternally("tel:+255789081122")
                        }
                    }
                    Rectangle {
                        id: _enWa; radius: 4; color: "#25D366"
                        height: _enWaTxt.implicitHeight + 10; width: _enWaTxt.implicitWidth + 20
                        property bool pressed: false; scale: pressed ? 0.96 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        Text {
                            id: _enWaTxt; anchors.centerIn: parent; font.bold: true; color: "white"
                            font.pointSize: Qt.platform.os === "android" ? 12 : 10; text: "💬 WhatsApp"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onPressed:  _enWa.pressed = true
                            onReleased: _enWa.pressed = false
                            onCanceled: _enWa.pressed = false
                            onClicked:  Qt.openUrlExternally("https://wa.me/255789081122?text=Hello%2C%20I%20want%20to%20advertise")
                        }
                    }
                    Rectangle {
                        id: _enBook; radius: 4; color: "#f8f9fa"; border.color: "#dadce0"; border.width: 1
                        height: _enBookTxt.implicitHeight + 10; width: _enBookTxt.implicitWidth + 20
                        property bool pressed: false; scale: pressed ? 0.96 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        Text {
                            id: _enBookTxt; anchors.centerIn: parent; font.bold: true; color: "#1a73e8"
                            font.pointSize: Qt.platform.os === "android" ? 12 : 10; text: "Book →"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onPressed:  _enBook.pressed = true
                            onReleased: _enBook.pressed = false
                            onCanceled: _enBook.pressed = false
                            onClicked:  root.showToastMessage("Call or WhatsApp 0789 081 122 to book your slot!")
                        }
                    }
                }
                Item { width: 1; height: 4 }
            }
        }
    }

    // ── SW owner ad ───────────────────────────────────────────────────────
    Component {
        id: adOwnerSW
        Rectangle {
            width: parent ? parent.width : 0
            height: _swCol.height + 20
            color: "#ffffff"; radius: 8
            border.color: "#dadce0"; border.width: 1; clip: true

            Rectangle {
                anchors.top: parent.top; anchors.left: parent.left
                anchors.topMargin: 8; anchors.leftMargin: 10
                width: _swBadge.implicitWidth + 8
                height: _swBadge.implicitHeight + 4
                radius: 3; color: "#f0f0f0"; border.color: "#bbbbbb"; border.width: 1
                Text {
                    id: _swBadge
                    anchors.centerIn: parent
                    text: "Tangazo"
                    font.pointSize: Qt.platform.os === "android" ? 9 : 7
                    color: "#555555"
                }
            }

            Column {
                id: _swCol
                anchors.top: parent.top; anchors.topMargin: 30
                anchors.left: parent.left; anchors.right: parent.right
                anchors.leftMargin: 10; anchors.rightMargin: 10
                spacing: 6

                Text {
                    width: parent.width; wrapMode: Text.WordWrap; font.bold: true; color: "#1a0dab"
                    font.pointSize: Qt.platform.os === "android" ? 13 : 11
                    text: "📢 Tangaza kwenye Aplikesheni hii!"
                }
                Text {
                    text: "matokeo.app › matangazo"
                    font.pointSize: Qt.platform.os === "android" ? 10 : 8; color: "#006621"
                }
                Text {
                    width: parent.width; wrapMode: Text.WordWrap; color: "#333333"
                    font.pointSize: Qt.platform.os === "android" ? 11 : 9
                    text: "Fikia maelfu ya watumiaji kila siku! Tangaza Bidhaa, Shule, Biashara, Hoteli, Hostel, Nyumba ya Kupanga n.k na uonekane na watumiaji kutoka duniani kote."
                }
                Rectangle {
                    height: _swPrice.implicitHeight + 8; width: _swPrice.implicitWidth + 16
                    radius: 4; color: "#e8f5e9"; border.color: "#4caf50"; border.width: 1
                    Text {
                        id: _swPrice
                        anchors.centerIn: parent; font.bold: true; color: "#2e7d32"
                        font.pointSize: Qt.platform.os === "android" ? 11 : 9
                        text: "💰 Kuanzia TZS 50,000/= kwa mwezi"
                    }
                }
                Row {
                    spacing: 8
                    Rectangle {
                        id: _swCall; radius: 4; color: "#1a73e8"
                        height: _swCallTxt.implicitHeight + 10; width: _swCallTxt.implicitWidth + 20
                        property bool pressed: false; scale: pressed ? 0.96 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        Text {
                            id: _swCallTxt; anchors.centerIn: parent; font.bold: true; color: "white"
                            font.pointSize: Qt.platform.os === "android" ? 12 : 10; text: "📞  0789 081 122"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onPressed:  _swCall.pressed = true
                            onReleased: _swCall.pressed = false
                            onCanceled: _swCall.pressed = false
                            onClicked:  Qt.openUrlExternally("tel:+255789081122")
                        }
                    }
                    Rectangle {
                        id: _swWa; radius: 4; color: "#25D366"
                        height: _swWaTxt.implicitHeight + 10; width: _swWaTxt.implicitWidth + 20
                        property bool pressed: false; scale: pressed ? 0.96 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        Text {
                            id: _swWaTxt; anchors.centerIn: parent; font.bold: true; color: "white"
                            font.pointSize: Qt.platform.os === "android" ? 12 : 10; text: "💬 WhatsApp"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onPressed:  _swWa.pressed = true
                            onReleased: _swWa.pressed = false
                            onCanceled: _swWa.pressed = false
                            onClicked:  Qt.openUrlExternally("https://wa.me/255789081122?text=Habari%2C%20nataka%20kutangaza")
                        }
                    }
                    Rectangle {
                        id: _swBook; radius: 4; color: "#f8f9fa"; border.color: "#dadce0"; border.width: 1
                        height: _swBookTxt.implicitHeight + 10; width: _swBookTxt.implicitWidth + 20
                        property bool pressed: false; scale: pressed ? 0.96 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        Text {
                            id: _swBookTxt; anchors.centerIn: parent; font.bold: true; color: "#1a73e8"
                            font.pointSize: Qt.platform.os === "android" ? 12 : 10; text: "Nafasi →"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onPressed:  _swBook.pressed = true
                            onReleased: _swBook.pressed = false
                            onCanceled: _swBook.pressed = false
                            onClicked:  root.showToastMessage("Piga simu au WhatsApp 0789 081 122 kuhifadhi nafasi yako!")
                        }
                    }
                }
                Item { width: 1; height: 4 }
            }
        }
    }

    // ── CLIENT ADS — add your client Component + pool/lang entries here ───
    // Component { id: adClient1 … }

    // ── Layout ────────────────────────────────────────────────────────────
    Rectangle {
        id: topLine
        color: "cyan"
        width: parent.width
        height: 2
        anchors.top: parent.top
    }

    Column {
        id: menu
        anchors.top: topLine.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0                          // items manage their own spacing

        Repeater {
            model: root.extraMenu

            Column {
                width: root.width
                spacing: 0
                visible: modelData.cmd1 !== ""

                // ── Section divider (shown when section changes) ──────────
                Rectangle {
                    width: parent.width
                    height: modelData.section === "video" && index > 0 ? 1 : 0
                    color: "#007070"
                    visible: height > 0
                }

                // ── Menu row ──────────────────────────────────────────────
                Rectangle {
                    id: menuRow
                    width: root.width
                    height: 44
                    color: rowMA.containsPress ? "#003535" : "#004d4d"
                    readonly property real iconWidth: 34

                    // Left accent stripe — colour by section
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 3
                        color: {
                            var s = modelData.section;
                            if (s === "video")   return "#00b3b3";
                            if (s === "links")   return "#4caf50";
                            if (s === "content") return "#00e6e6";
                            return "transparent";
                        }
                        opacity: 0.85
                    }

                    Image {
                        width: parent.iconWidth
                        height: parent.height - 8
                        sourceSize.width: width
                        sourceSize.height: height
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        source: getIconSource(modelData.icon, rowMA.containsPress ? "cyan" : "#00cccc")
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: parent.iconWidth + 16
                        anchors.verticalCenter: parent.verticalCenter
                        color: rowMA.containsPress ? "white" : Qt.lighter("gray", 1.7)
                        text: modelData.text
                        font.pointSize: Qt.platform.os === "android" ? 12 : 10
                    }

                    // Chevron hint for items with two commands
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.cmd2 !== "" ? "⇄" : "›"
                        color: "#007070"
                        font.pointSize: Qt.platform.os === "android" ? 12 : 10
                        visible: modelData.cmd1 !== ""
                    }

                    MouseArea {
                        id: rowMA
                        anchors.fill: parent
                        property string cmd: modelData.cmd1
                        onReleased: {
                            root.executeCommand(cmd, []);
                            if (modelData.cmd2 !== "") {
                                if (cmd === modelData.cmd1) {
                                    cmd = modelData.cmd2;
                                } else {
                                    cmd = modelData.cmd1;
                                }
                            }
                        }
                    }

                    Behavior on color { ColorAnimation { duration: 80 } }
                }

                // ── Thin separator below every row ───────────────────────
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#005a5a"
                }

                // ── Ad banner — inserted after the middle item ────────────
                Item {
                    width: root.width
                    height: (index === Math.floor(root.extraMenu.length / 2) - 1 && adBannerLoader.visible)
                            ? adBannerLoader.height + 16 : 0
                    visible: height > 0

                    Loader {
                        id: adBannerLoader
                        property int adIdx: root.pickAd("sw")
                        visible: adIdx >= 0
                        width: root.width - 16
                        height: visible && item ? item.height : 0
                        x: (parent.width - width) / 2
                        anchors.top: parent.top
                        anchors.topMargin: 8
                        sourceComponent: adIdx >= 0 ? root.adsPool[adIdx] : null

                        Connections {
                            target: root
                            onAdRandomSeedChanged: {
                                adBannerLoader.adIdx = root.pickAd("sw");
                            }
                        }
                    }
                }
            }
        }


        // ── Tanzania flag animation ───────────────────────────────────────
        AnimatedImage {
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.width
            height: 90
            source: "./tzflag.gif"
            onStatusChanged: {
                visible = (status !== AnimatedImage.Error);
            }
        }
    }

    // Bottom cyan line — always sits just below the Column
    Rectangle {
        color: "cyan"
        width: parent.width
        height: 2
        anchors.top: menu.bottom
        anchors.topMargin: 8
    }
}
