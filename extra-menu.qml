import QtQuick 2.6
import QtQuick.Window 2.2
import Qt.labs.settings 1.0

Rectangle {
    id: root
    color: "#004d4d"

    // ── Menu items ────────────────────────────────────────────────────────
    readonly property var extraMenu: [
        
        {
            text: "Upakiaji",
            icon: "fa::cog",
            cmd1: "upakiaji",
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
    property var adsPool: [  adOwnerEN, adOwnerSW  ]
    property var adsLang: [  "en",      "sw"      ]

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
                    height: 68
                    color: rowMA.containsPress ? "#003535" : "#004d4d"
                    readonly property real iconWidth: 68

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
                        height: parent.iconWidth
                        sourceSize.width: width
                        sourceSize.height: height
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        source: getIconSource(modelData.icon, rowMA.containsPress ? "cyan" : "#00cccc")
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: parent.iconWidth + 22
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


        // ── Frog programmer in a pond ────────────────────────────────────
        Item {
            id: frogScene
            width: root.width
            height: 220
            clip: true

            // ── Sky color shift (dusk → night → dawn loop) ────────────────
            Rectangle {
                id: skyBg
                anchors.fill: parent
                radius: 10
                color: "#0a1a0a"
                SequentialAnimation on color {
                    loops: Animation.Infinite
                    ColorAnimation { to: "#0a0a2a"; duration: 4000 }
                    ColorAnimation { to: "#1a0a2a"; duration: 4000 }
                    ColorAnimation { to: "#2a1a0a"; duration: 4000 }
                    ColorAnimation { to: "#0a1a0a"; duration: 4000 }
                }
            }

            // Moon
            Rectangle {
                width: 18; height: 18; radius: 9
                x: parent.width - 36; y: 10
                color: "#fffde7"
                opacity: 0.85
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.5; duration: 6000 }
                    NumberAnimation { to: 0.85; duration: 6000 }
                }
                // Crescent shadow
                Rectangle {
                    width: 14; height: 14; radius: 7
                    x: 6; y: -2
                    color: skyBg.color
                }
            }

            // Stars
            Repeater {
                model: 14
                Rectangle {
                    x: (index * 73 + 17) % (frogScene.width - 10)
                    y: (index * 41 + 5)  % 44
                    width: 2; height: 2; radius: 1
                    color: "white"
                    opacity: 0.0
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        PauseAnimation  { duration: index * 320 }
                        NumberAnimation { to: 0.9; duration: 600 }
                        NumberAnimation { to: 0.1; duration: 700 }
                    }
                }
            }

            // Rain drops
            Repeater {
                model: 18
                Rectangle {
                    id: rainDrop
                    property real startX: (index * 43 + 7) % (frogScene.width - 4)
                    x: startX
                    y: -12
                    width: 1; height: 8
                    color: "#88ccff"
                    opacity: 0.0
                    radius: 1
                    SequentialAnimation on y {
                        loops: Animation.Infinite
                        PauseAnimation  { duration: index * 190 + 100 }
                        NumberAnimation { from: -12; to: frogScene.height; duration: 900; easing.type: Easing.Linear }
                    }
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        PauseAnimation  { duration: index * 190 + 100 }
                        NumberAnimation { to: 0.55; duration: 100 }
                        NumberAnimation { to: 0.55; duration: 700 }
                        NumberAnimation { to: 0.0;  duration: 100 }
                    }
                }
            }

            // ── Pond ──────────────────────────────────────────────────────
            Rectangle {
                id: pond
                x: 8
                anchors.bottom: parent.bottom
                width: parent.width - 16
                height: 90
                color: "#0d3b2e"
                radius: 14

                // Water shimmer overlay
                Rectangle {
                    anchors.fill: parent; radius: parent.radius
                    color: "transparent"
                    Rectangle {
                        width: parent.width * 0.6
                        height: 3; radius: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 18
                        color: "#1a6a50"; opacity: 0.4
                        SequentialAnimation on width {
                            loops: Animation.Infinite
                            NumberAnimation { to: pond.width * 0.3; duration: 1800; easing.type: Easing.SineCurve }
                            NumberAnimation { to: pond.width * 0.6; duration: 1800; easing.type: Easing.SineCurve }
                        }
                    }
                }

                // Water ripple rings
                Repeater {
                    model: 3
                    Rectangle {
                        property real baseSize: 28 + index * 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 18
                        width: baseSize; height: baseSize * 0.32
                        radius: width / 2
                        color: "transparent"
                        border.color: "#1a7a5a"; border.width: 1
                        opacity: 0.0
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            PauseAnimation  { duration: index * 700 + 200 }
                            NumberAnimation { to: 0.7; duration: 400 }
                            NumberAnimation { to: 0.0; duration: 900 }
                        }
                        SequentialAnimation on width {
                            loops: Animation.Infinite
                            PauseAnimation  { duration: index * 700 + 200 }
                            NumberAnimation { to: baseSize * 1.7; duration: 1300 }
                            NumberAnimation { to: baseSize;       duration: 0    }
                        }
                    }
                }

                // ── Fish swimming ─────────────────────────────────────────
                Item {
                    id: fish
                    width: 28; height: 12
                    y: 52
                    x: -30

                    SequentialAnimation on x {
                        loops: Animation.Infinite
                        NumberAnimation { from: -30; to: pond.width + 10; duration: 5000; easing.type: Easing.Linear }
                        PauseAnimation  { duration: 800 }
                    }

                    // Fish body
                    Rectangle {
                        width: 20; height: 10; radius: 6
                        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        color: "#ff8844"
                        // Eye
                        Rectangle {
                            width: 3; height: 3; radius: 2
                            anchors.right: parent.right; anchors.rightMargin: 3
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: -1
                            color: "black"
                        }
                    }
                    // Tail fin
                    Rectangle {
                        width: 10; height: 12; radius: 3
                        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                        color: "#ff6622"
                        rotation: 0
                        SequentialAnimation on rotation {
                            loops: Animation.Infinite
                            NumberAnimation { to:  20; duration: 250 }
                            NumberAnimation { to: -20; duration: 250 }
                        }
                    }
                }
            }

            // Lily pad
            Rectangle {
                id: lilyPad
                width: 72; height: 26
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 32
                color: "#2d7a2d"; radius: 36
                Rectangle {
                    width: 16; height: 16; radius: 8
                    color: "#0d3b2e"
                    anchors.right: parent.right; anchors.rightMargin: -4
                    anchors.verticalCenter: parent.verticalCenter
                }
                SequentialAnimation on anchors.bottomMargin {
                    loops: Animation.Infinite
                    NumberAnimation { to: 30; duration: 900; easing.type: Easing.SineCurve }
                    NumberAnimation { to: 32; duration: 900; easing.type: Easing.SineCurve }
                }
            }

            // ── Frog ──────────────────────────────────────────────────────
            Item {
                id: frog
                width: 54; height: 62
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 40

                // Wobble rotation while typing
                SequentialAnimation on rotation {
                    loops: Animation.Infinite
                    NumberAnimation { to:  2; duration: 200 }
                    NumberAnimation { to: -2; duration: 200 }
                    NumberAnimation { to:  0; duration: 200 }
                    PauseAnimation  { duration: 1400 }
                }

                SequentialAnimation on anchors.bottomMargin {
                    loops: Animation.Infinite
                    NumberAnimation { to: 42; duration: 900; easing.type: Easing.SineCurve }
                    NumberAnimation { to: 40; duration: 900; easing.type: Easing.SineCurve }
                }

                // Body
                Rectangle {
                    id: frogBody
                    width: 44; height: 34
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom; anchors.bottomMargin: 10
                    radius: 18; color: "#3cb043"
                    border.color: "#2a8a30"; border.width: 1

                    // Belly
                    Rectangle {
                        width: 28; height: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 2
                        radius: 12; color: "#a8e6a0"
                    }

                    // ── Mouth (opens/closes while speaking) ───────────────
                    Rectangle {
                        id: mouthOuter
                        width: 18; height: 6; radius: 3
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 4
                        color: "#1a5c1a"
                        clip: true

                        Rectangle {
                            id: mouthInner
                            width: parent.width - 4; height: 4; radius: 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom; anchors.bottomMargin: 0
                            color: "#cc2222"
                            // Tongue tip
                            Rectangle {
                                width: 6; height: 3; radius: 2
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                color: "#ff4444"
                            }
                        }

                        // Mouth open/close sync with typing
                        SequentialAnimation on height {
                            loops: Animation.Infinite
                            NumberAnimation { to: 10; duration: 150 }
                            NumberAnimation { to: 3;  duration: 150 }
                            NumberAnimation { to: 8;  duration: 150 }
                            NumberAnimation { to: 3;  duration: 150 }
                            PauseAnimation  { duration: 1800 }
                        }
                    }
                }

                // Left eye
                Rectangle {
                    width: 12; height: 12; radius: 6
                    x: frogBody.x - 2
                    anchors.bottom: frogBody.top; anchors.bottomMargin: -6
                    color: "#3cb043"; border.color: "#2a8a30"; border.width: 1
                    Rectangle {
                        width: 7; height: 7; radius: 4
                        anchors.centerIn: parent; color: "black"
                        Rectangle {
                            width: 2; height: 2; radius: 1
                            anchors.top: parent.top; anchors.left: parent.left
                            anchors.topMargin: 1; anchors.leftMargin: 1
                            color: "white"
                        }
                    }
                }

                // Right eye — blinks
                Rectangle {
                    id: rightEyeBall
                    width: 12; height: 12; radius: 6
                    x: frogBody.x + frogBody.width - 10
                    anchors.bottom: frogBody.top; anchors.bottomMargin: -6
                    color: "#3cb043"; border.color: "#2a8a30"; border.width: 1
                    Rectangle {
                        width: 7; height: 7; radius: 4
                        anchors.centerIn: parent; color: "black"
                        Rectangle {
                            width: 2; height: 2; radius: 1
                            anchors.top: parent.top; anchors.left: parent.left
                            anchors.topMargin: 1; anchors.leftMargin: 1
                            color: "white"
                        }
                    }
                    SequentialAnimation on height {
                        loops: Animation.Infinite
                        PauseAnimation  { duration: 3200 }
                        NumberAnimation { to: 1;  duration: 80 }
                        NumberAnimation { to: 12; duration: 80 }
                    }
                }

                // Left arm
                Rectangle {
                    id: leftArm
                    width: 18; height: 7; radius: 4
                    color: "#3cb043"
                    anchors.left: frogBody.left; anchors.leftMargin: -12
                    anchors.bottom: frogBody.bottom; anchors.bottomMargin: 12
                    rotation: -30
                    // Left finger tap
                    SequentialAnimation on anchors.bottomMargin {
                        loops: Animation.Infinite
                        NumberAnimation { to: 14; duration: 160 }
                        NumberAnimation { to: 12; duration: 160 }
                        PauseAnimation  { duration: 480 }
                    }
                }

                // Right arm
                Rectangle {
                    id: rightArm
                    width: 18; height: 7; radius: 4
                    color: "#3cb043"
                    anchors.right: frogBody.right; anchors.rightMargin: -12
                    anchors.bottom: frogBody.bottom; anchors.bottomMargin: 12
                    rotation: 30
                    // Right finger tap (offset timing)
                    SequentialAnimation on anchors.bottomMargin {
                        loops: Animation.Infinite
                        PauseAnimation  { duration: 320 }
                        NumberAnimation { to: 14; duration: 160 }
                        NumberAnimation { to: 12; duration: 160 }
                        PauseAnimation  { duration: 320 }
                    }
                }
            }

            // ── Laptop ────────────────────────────────────────────────────
            Item {
                id: laptop
                width: 52; height: 36
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom; anchors.bottomMargin: 36

                SequentialAnimation on anchors.bottomMargin {
                    loops: Animation.Infinite
                    NumberAnimation { to: 38; duration: 900; easing.type: Easing.SineCurve }
                    NumberAnimation { to: 36; duration: 900; easing.type: Easing.SineCurve }
                }

                Rectangle {
                    id: laptopScreen
                    width: 46; height: 28
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    radius: 3; color: "#1a1a2e"
                    border.color: "#555"; border.width: 1

                    // Cursor blink
                    Rectangle {
                        id: cursor
                        width: 2; height: 8
                        x: 6; y: 6
                        color: "#00ff88"
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.0; duration: 500 }
                            NumberAnimation { to: 1.0; duration: 500 }
                        }
                        // Cursor moves right as frog "types"
                        SequentialAnimation on x {
                            loops: Animation.Infinite
                            NumberAnimation { from: 6; to: 38; duration: 3000; easing.type: Easing.Linear }
                            NumberAnimation { to: 6; duration: 0 }
                        }
                    }

                    // Code lines that grow as typed
                    Repeater {
                        model: 3
                        Rectangle {
                            x: 6
                            y: 6 + index * 7
                            width: 0
                            height: 2
                            color: ["#00ff88","#66aaff","#ffaa44"][index]
                            opacity: 0.85
                            SequentialAnimation on width {
                                loops: Animation.Infinite
                                PauseAnimation  { duration: index * 1000 }
                                NumberAnimation { from: 0; to: [24, 32, 20][index]; duration: 1200; easing.type: Easing.OutCubic }
                                PauseAnimation  { duration: 3000 - index * 1000 }
                                NumberAnimation { to: 0; duration: 0 }
                            }
                        }
                    }
                }

                // Laptop base
                Rectangle {
                    width: 52; height: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    radius: 2; color: "#888"
                    border.color: "#555"; border.width: 1
                }
            }

            // ── QSettings — kukumbuka jina ────────────────────────────────
            Settings {
                id: frogSettings
                category: "FrogGreeting"
                property string savedName: ""
            }

            // ── State: "ask" | "chat" ─────────────────────────────────────
            property string greetMode: "ask"
            property string userName: ""

            // ── Pool kubwa ya phrases (elimu + sayansi) ───────────────────
            // Zinachanganywa kwa nasibu kila app inapoanza
            property var allPhrases: [
                // Sayansi ya jumla
                "Sayansi ni uchawi wa kweli! ✨",
                "Ulimwengu una siri nyingi — tafuta! 🔭",
                "Newton aliona toffa, akapata sheria! 🍎",
                "DNA ni msimbo wa maisha yetu 🧬",
                "Angani kuna nyota zaidi ya mchanga! 🌌",
                "Mwanga husafiri kwa km 300,000 kwa sekunde ⚡",
                "Octopusi ana akili tisa! 🐙",
                "Mvuto wa dunia hushikilia kila kitu 🌍",
                "Sauti ni mawimbi ya hewa inayotetemeka 🎵",
                "Jua ni nyota — iliyo karibu nawe! ☀️",
                // Kompyuta & coding
                "Msimbo ni lugha ya siku zijazo 💻",
                "Hitilafu ni mwalimu bora wa programu 🐛",
                "Algorithm ni njia ya kufikia jibu 🗺️",
                "Python, Java, C++ — chagua silaha yako! ⚔️",
                "Kila app ilianza na mstari mmoja wa code",
                "Binary: 0 na 1 zinajenga dunia yote 🔢",
                "Internet ilianza na kompyuta 4 tu! 🌐",
                "Debug leo, shangilia kesho 🎉",
                "Open source = ujuzi wa pamoja 🤝",
                "Kompyuta ya kwanza ilikuwa kubwa kama chumba 🏠",
                // Hisabati
                "Hisabati ni lugha ya ulimwengu 📐",
                "Pi = 3.14159... haina mwisho! ♾️",
                "Fibonacci yuko kila mahali asiliani 🌀",
                "Hesabu ni nguvu ya uchumi 💰",
                "Zero ilivumbua nguvu kubwa ya hesabu! 0️⃣",
                // Elimu & motisha
                "Ujuzi ni utajiri usioibwa 📚",
                "Soma leo, ongoza kesho 🎓",
                "Akili ni mali — itumie vizuri! 🧠",
                "Elimu haina mwisho wala kikomo",
                "Swali moja linaweza kubadilisha dunia ❓",
                "Einstein alipofeli — aliendelea tu! 💪",
                "Jifunza kwa makosa, siyo kwa hofu",
                "Kila mtaalamu alikuwa mgeni kwanza 🌱",
                "Soma, jaribu, anguka, simama, rudia ♻️",
                "Tanzania ina akili nyingi — itumie! 🇹🇿",
                // Mazingira & biolojia
                "Miti inazalisha hewa tunayopumua 🌳",
                "Bahari inafunika 71% ya dunia 🌊",
                "Mwili wako una seli trilioni 37! 🦠",
                "Moyo hudunda mara 100,000 kwa siku ❤️",
                "Ubongo wako ni kompyuta bora zaidi 🧠"
            ]

            // Phrases zilizochaguliwa kwa nasibu kwa session hii
            property var sessionPhrases: []
            property int phraseIdx: 0

            // Changanya nasibu (Fisher-Yates)
            function shufflePhrases(arr) {
                var a = arr.slice();
                for (var i = a.length - 1; i > 0; i--) {
                    var j = Math.floor(Math.random() * (i + 1));
                    var tmp = a[i]; a[i] = a[j]; a[j] = tmp;
                }
                return a;
            }

            // Anza maongezi — inaita baada ya jina kupatikana
            function startChat(name) {
                frogScene.userName = name;
                frogScene.greetMode = "chat";

                // Unda phrases za kibinafsi + pool iliyochanganywa
                var greetings = [
                    "Habari " + name + "! 😊",
                    "Karibu " + name + "! 🐸",
                    name + ", tujifunze pamoja! 📚",
                    name + ", wewe ni programu inayokua! 💻"
                ];
                var pool = shufflePhrases(frogScene.allPhrases);
                // Salamu mbele, kisha pool
                frogScene.sessionPhrases = greetings.concat(pool);
                frogScene.phraseIdx = 0;
                typeNextPhrase();
            }

            // Andika phrase inayofuata kwa typewriter
            function typeNextPhrase() {
                var p = frogScene.sessionPhrases[frogScene.phraseIdx];
                bubbleText.startTypewriter(p);
            }

            // confirmName iko katika frogScene scope — inafanya kazi!
            function confirmName() {
                var name = nameInput.text.trim();
                if (name.length === 0) { return; }
                frogSettings.savedName = name;
                nameInput.text = "";
                frogScene.startChat(name);
            }

            // Badili jina — rudi kwenye ask mode
            function resetName() {
                typeTimer.stop();
                pauseTimer.stop();
                frogSettings.savedName = "";
                nameInput.text = "";
                bubbleText.fullText = "";
                bubbleText.charCount = 0;
                frogScene.greetMode = "ask";
                Qt.callLater(function() {
                    bubbleText.startTypewriter("Unaitwa nani? 🐸");
                });
            }

            // Angalia QSettings wakati wa kuanza
            Component.onCompleted: {
                if (frogSettings.savedName !== "") {
                    // Jina linajulikana — ruka moja kwa moja kwenye chat
                    frogScene.startChat(frogSettings.savedName);
                } else {
                    // Uliza jina
                    frogScene.greetMode = "ask";
                    bubbleText.startTypewriter("Unaitwa nani? 🐸");
                }
            }

            // ── Speech bubble ─────────────────────────────────────────────
            Item {
                id: speechBubble
                width: bubbleRect.width + 4
                height: bubbleRect.height + 12
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 20
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 96

                SequentialAnimation on anchors.bottomMargin {
                    loops: Animation.Infinite
                    NumberAnimation { to: 100; duration: 1200; easing.type: Easing.SineCurve }
                    NumberAnimation { to: 96;  duration: 1200; easing.type: Easing.SineCurve }
                }

                Rectangle {
                    id: bubbleRect
                    width: Math.max(bubbleText.implicitWidth, 110) + 22
                    height: bubbleText.implicitHeight + 14
                    radius: 10; color: "white"
                    border.color: "#3cb043"; border.width: 2
                    Behavior on width { NumberAnimation { duration: 180 } }

                    Text {
                        id: bubbleText
                        anchors.centerIn: parent
                        color: "#1a1a1a"
                        font.pointSize: Qt.platform.os === "android" ? 10 : 8
                        font.bold: true

                        property string fullText: ""
                        property int charCount: 0
                        text: fullText.substring(0, charCount)

                        function startTypewriter(txt) {
                            fullText = txt;
                            charCount = 0;
                            typeTimer.restart();
                        }

                        Timer {
                            id: typeTimer
                            interval: 72
                            repeat: true
                            running: false
                            onTriggered: {
                                if (bubbleText.charCount < bubbleText.fullText.length) {
                                    bubbleText.charCount++;
                                } else {
                                    stop();
                                    if (frogScene.greetMode === "chat") {
                                        pauseTimer.restart();
                                    }
                                }
                            }
                        }

                        Timer {
                            id: pauseTimer
                            interval: 2800
                            repeat: false
                            onTriggered: {
                                frogScene.phraseIdx =
                                    (frogScene.phraseIdx + 1) % frogScene.sessionPhrases.length;
                                frogScene.typeNextPhrase();
                            }
                        }
                    }
                }

                // Bubble tail
                Canvas {
                    width: 14; height: 12
                    anchors.left: bubbleRect.left; anchors.leftMargin: 8
                    anchors.top: bubbleRect.bottom; anchors.topMargin: -2
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        ctx.fillStyle   = "white";
                        ctx.strokeStyle = "#3cb043";
                        ctx.lineWidth   = 2;
                        ctx.beginPath();
                        ctx.moveTo(0, 0);
                        ctx.lineTo(14, 0);
                        ctx.lineTo(4, 12);
                        ctx.closePath();
                        ctx.fill();
                        ctx.stroke();
                    }
                }
            }

            // ── Input ya jina (inaonekana tu mode "ask") ──────────────────
            Item {
                id: inputPanel
                width: nameField.width + okBtn.width + 10
                height: 34
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 6
                visible: frogScene.greetMode === "ask"

                onVisibleChanged: {
                    if (visible) {
                        nameInput.forceActiveFocus();
                    }
                }

                Rectangle {
                    id: nameField
                    width: 130; height: 30; radius: 6
                    color: "#1a2e1a"
                    border.color: nameInput.activeFocus ? "#00ff88" : "#3cb043"
                    border.width: nameInput.activeFocus ? 2 : 1
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on border.width { NumberAnimation { duration: 100 } }

                    TextInput {
                        id: nameInput
                        anchors.fill: parent; anchors.margins: 6
                        color: "#00ff88"
                        font.pointSize: Qt.platform.os === "android" ? 11 : 9
                        font.bold: true
                        maximumLength: 18; clip: true

                        Text {
                            anchors.fill: parent
                            text: "Jina lako..."
                            color: "#336633"
                            font.pointSize: Qt.platform.os === "android" ? 11 : 9
                            visible: nameInput.text.length === 0 && !nameInput.activeFocus
                        }

                        Keys.onReturnPressed: { frogScene.confirmName(); }
                        Keys.onEnterPressed:  { frogScene.confirmName(); }
                    }
                }

                Rectangle {
                    id: okBtn
                    width: okTxt.implicitWidth + 16; height: 30; radius: 6
                    color: okMA.pressed ? "#2a8a30" : "#3cb043"
                    anchors.left: nameField.right; anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text {
                        id: okTxt
                        anchors.centerIn: parent
                        text: "Sawa ✓"; color: "white"
                        font.pointSize: Qt.platform.os === "android" ? 11 : 9
                        font.bold: true
                    }
                    MouseArea {
                        id: okMA
                        anchors.fill: parent
                        onClicked: { frogScene.confirmName(); }
                    }
                }
            }

            // ── Kitufe cha "Badili jina" (chat mode tu) ───────────────────
            Rectangle {
                id: changeNameBtn
                visible: frogScene.greetMode === "chat"
                width: changeTxt.implicitWidth + 16
                height: 22
                radius: 11
                color: changeMA.pressed ? "#1a4a1a" : "#0d2e0d"
                border.color: "#3cb043"
                border.width: 1
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 6
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    id: changeTxt
                    anchors.centerIn: parent
                    text: "✏️ " + frogScene.userName
                    color: "#00cc66"
                    font.pointSize: Qt.platform.os === "android" ? 8 : 7
                    font.bold: true
                }
                MouseArea {
                    id: changeMA
                    anchors.fill: parent
                    onClicked: { frogScene.resetName(); }
                }
            }

            // Fireflies
            Repeater {
                model: 6
                Rectangle {
                    x: (index * 57 + 30) % (frogScene.width - 40) + 10
                    y: 50 + (index * 23) % 55
                    width: 3; height: 3; radius: 2
                    color: "#ccff66"
                    opacity: 0.0
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        PauseAnimation  { duration: index * 900 + 400 }
                        NumberAnimation { to: 0.9; duration: 400 }
                        PauseAnimation  { duration: 300 }
                        NumberAnimation { to: 0.0; duration: 600 }
                    }
                    SequentialAnimation on x {
                        loops: Animation.Infinite
                        NumberAnimation { to: (index * 57 + 30) % (frogScene.width - 40) + 18; duration: 2000; easing.type: Easing.SineCurve }
                        NumberAnimation { to: (index * 57 + 30) % (frogScene.width - 40) + 10; duration: 2000; easing.type: Easing.SineCurve }
                    }
                }
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
