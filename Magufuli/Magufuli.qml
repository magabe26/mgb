import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Rectangle {
    id: app
    width:  parent ? parent.width  : 400
    height: parent ? parent.height : 800
    color: "#050f05"

    // ── App wrapper helpers (kwa mazingira ya nje) ────────────────────────────
    function cleanParent(t) {
        return t ? t.replace(/\s*\(.*?\)\s*/g, "").trim() : "";
    }
    function isPrimaryResultsApp() {
        return (typeof n3ctaApp !== "undefined");
    }
    function isSecondaryResultsApp() {
        return (typeof loader !== "undefined");
    }
    function isInsideApp() {
        var t = cleanParent(String(parent.parent.parent.parent));
        if (isPrimaryResultsApp()) return t === "QQuickRootItem";
        var i = t.indexOf("_");
        return i !== -1 && t.substr(0, i) === "SwipeView";
    }
    function isQMLDialogApp() {
        return cleanParent(String(parent.parent.parent)) === "QQuickRectangle";
    }
    function closeIfInsideApp() {
        if (!isInsideApp()) return;
        if (isPrimaryResultsApp()) {
            n3ctaApp.closeCustomPage();
        } else if (isSecondaryResultsApp()) {
            loader.isMenuWindowVisible = true;
            loader.isMainResultsWindowVisible = true;
            loader.isFooterVisible = true;
            if (typeof loader.mode !== "undefined") loader.mode = 2;
            loader.closeCustomPage();
        }
    }
    function closeIfQMLDialogApp() {
        if (!isQMLDialogApp()) return;
        if (isPrimaryResultsApp()) {
            n3ctaApp.closeQMLDialog();
        } else if (isSecondaryResultsApp()) {
            nectaMainResultsPageDownloaderHtmlToXmlConveterAndSaver.closeQMLDialog();
        }
    }
    function cmd(url) {
        if (isPrimaryResultsApp()) {
            n3ctaApp.onUrlVisited(url);
        } else if (isSecondaryResultsApp()) {
            if (isQMLDialogApp()) {
                n3ctaQmlConnectionsPipe.onUrlVisited(url);
            } else if (isInsideApp()) {
                loader.onUrlVisited(url);
            }
        }
    }
    function showToastMessage(msg) {
        if (isPrimaryResultsApp()) {
            n3ctaApp.showToastMessage(msg);
        } else if (isSecondaryResultsApp()) {
            nectaMainResultsPageDownloaderHtmlToXmlConveterAndSaver.showToastMessage(msg);
        }
    }
    function ad() { cmd("#showGoogleAd"); }
    function close() { closeIfInsideApp(); closeIfQMLDialogApp(); ad(); }

    // ── Palette ───────────────────────────────────────────────────────────────
    readonly property color gold:       "#f5c400"
    readonly property color goldDim:    "#a88b00"
    readonly property color cream:      "#ffffff"
    readonly property color creamDim:   "#cccccc"
    readonly property color darkCard:   "#0d1a0f"
    readonly property color green:      "#006400"
    readonly property color greenLight: "#00aa00"
    readonly property real  dp:         Math.min(width, height) / 400

    // ── Navigation & lightbox state ───────────────────────────────────────────
    property int    section:        0
    property string lightboxSource: ""
    property bool   lightboxOpen:   false

    // ── Background grid ───────────────────────────────────────────────────────
    Canvas {
        anchors.fill: parent; opacity: 0.05
        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "#f5c400";
            ctx.lineWidth = 0.5;
            for (var x = 0; x < width; x += 40) {
                ctx.beginPath();
                ctx.moveTo(x, 0);
                ctx.lineTo(x, height);
                ctx.stroke();
            }
            for (var y = 0; y < height; y += 40) {
                ctx.beginPath();
                ctx.moveTo(0, y);
                ctx.lineTo(width, y);
                ctx.stroke();
            }
        }
    }

    // ════════════════════════════════════════════════
    // COVER  (section 0)
    // ════════════════════════════════════════════════
    Item {
        id: coverItem
        anchors.fill: parent
        visible: opacity > 0
        opacity: section === 0 ? 1.0 : 0.0
        x:       section === 0 ? 0 : -app.width * 0.18
        Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        Behavior on x       { NumberAnimation { duration: 350; easing.type: Easing.OutCubic  } }

        // Green gradient header banner behind photo
        Rectangle {
            anchors.top: parent.top; width: parent.width
            height: Math.round(220 * dp)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#006400" }
                GradientStop { position: 0.7; color: "#003a00" }
                GradientStop { position: 1.0; color: "#050f05" }
            }
        }
        // Top CCM flag stripe over banner
        Rectangle {
            anchors.top: parent.top; width: parent.width; height: Math.round(4 * dp)
            gradient: Gradient {
                GradientStop { position: 0.0;  color: "#006400" }
                GradientStop { position: 0.44; color: "#006400" }
                GradientStop { position: 0.46; color: "#f5c400" }
                GradientStop { position: 0.54; color: "#f5c400" }
                GradientStop { position: 0.56; color: "#000000" }
                GradientStop { position: 1.0;  color: "#000000" }
            }
        }

        Flickable {
            anchors.fill: parent; contentWidth: width
            contentHeight: coverCol.implicitHeight + Math.round(60 * dp)
            clip: true; boundsBehavior: Flickable.StopAtBounds

            Column {
                id: coverCol
                width: parent.width - Math.round(40 * dp)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.topMargin: Math.round(36 * dp)
                spacing: 0

                // ── Sentensi juu ya picha — neno moja moja fade-in ──────
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: memorialRow.implicitHeight + Math.round(10 * dp)

                    Row {
                        id: memorialRow
                        anchors.centerIn: parent
                        spacing: Math.round(4 * dp)
                        // Kila neno — delay inazidi kwa 150ms
                        Repeater {
                            model: ["Miaka", "5", "tangu", "kifo", "cha", "Dr.", "John", "Pombe", "Joseph", "Magufuli"]
                            delegate: Text {
                                text: modelData
                                font.pointSize: Math.round(6 * dp)
                                font.bold: modelData === "Magufuli" || modelData === "5"
                                color: modelData === "5" ? gold :
                                       modelData === "Magufuli" ? gold : cream
                                opacity: 0
                                SequentialAnimation on opacity {
                                    PauseAnimation  { duration: 600 + (index * 150) }
                                    NumberAnimation { from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                    }
                }

                Item { width: 1; height: Math.round(4 * dp) }

                // ── Profile photo with gold border rect ──────────────────
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    property int photoSize: Math.round(160 * dp)
                    width:  photoSize + Math.round(12 * dp)
                    height: photoSize + Math.round(12 * dp)

                    // Growing gold border rect — expands outward and fades, loops
                    Rectangle {
                        anchors.centerIn: parent
                        width:  photoWrapper2.photoSize + Math.round(8 * dp)
                        height: photoWrapper2.photoSize + Math.round(8 * dp)
                        radius: Math.round(16 * dp)
                        color: "transparent"
                        border.color: gold
                        border.width: Math.round(3 * dp)
                        SequentialAnimation on scale {
                            loops: Animation.Infinite; running: section === 0
                            NumberAnimation { to: 1.0;  duration: 0 }
                            NumberAnimation { to: 1.20; duration: 1400; easing.type: Easing.OutCubic }
                            PauseAnimation  { duration: 200 }
                        }
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite; running: section === 0
                            NumberAnimation { to: 1.0; duration: 0 }
                            NumberAnimation { to: 0.0; duration: 1400; easing.type: Easing.OutCubic }
                            PauseAnimation  { duration: 200 }
                        }
                    }

                    // Photo — full quality, layer.enabled clips to rounded rect
                    Rectangle {
                        id: photoWrapper2
                        anchors.centerIn: parent
                        property int photoSize: Math.round(160 * dp)
                        width:  photoSize
                        height: photoSize
                        radius: Math.round(14 * dp)
                        color:  "#0f1f0f"
                        layer.enabled: true
                        Image {
                            id: coverImg
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            source: "./magufuli0.jpeg"
                            smooth: true
                        }
                        Column {
                            anchors.centerIn: parent
                            visible: coverImg.status !== Image.Ready
                            spacing: Math.round(4 * dp)
                        }
                    }
                }
                Item { width: 1; height: Math.round(18 * dp) }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "29 Oktoba 1959  —  17 Machi 2021"
                    font.pointSize: Math.round(9 * dp); font.letterSpacing: Math.round(2 * dp); color: goldDim
                }

                Item { width: 1; height: Math.round(6 * dp) }

                // CCM slogan + torch — fade-in then inawaka inazima
                Row {
                    id: sloganRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Math.round(6 * dp)
                    opacity: 0
                    Text { text: "\uD83D\uDD25"; font.pointSize: Math.round(11 * dp); anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        id: sloganText
                        text: "UMOJA NI NGUVU"
                        font.pointSize: Math.round(9 * dp); font.bold: true; font.letterSpacing: Math.round(1.5 * dp)
                        color: gold; anchors.verticalCenter: parent.verticalCenter
                    }
                    Text { text: "\uD83D\uDD25"; font.pointSize: Math.round(11 * dp); anchors.verticalCenter: parent.verticalCenter }
                    // Hatua 1: fade-in baada ya jina
                    SequentialAnimation on opacity {
                        id: sloganFadeIn
                        PauseAnimation  { duration: 900 }
                        NumberAnimation { from: 0; to: 1; duration: 700; easing.type: Easing.OutCubic }
                        onStopped: { sloganBlink.start(); }
                    }
                    // Hatua 2: inawaka inazima milele
                    SequentialAnimation {
                        id: sloganBlink
                        loops: Animation.Infinite
                        NumberAnimation { target: sloganText; property: "opacity"; to: 0.15; duration: 600; easing.type: Easing.InOutSine }
                        NumberAnimation { target: sloganText; property: "opacity"; to: 1.0;  duration: 600; easing.type: Easing.InOutSine }
                        PauseAnimation  { duration: 400 }
                    }
                    Component.onCompleted: { sloganFadeIn.start(); }
                }

                Item { width: 1; height: Math.round(6 * dp) }

                // ── Name with fade-in entrance ───────────────────────────
                // No y animation — animating y inside a Column causes layout overlap onto photo.
                Text {
                    id: nameText
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "John Pombe\nMagufuli"
                    font.pointSize: Math.round(26 * dp); font.bold: true
                    color: cream
                    horizontalAlignment: Text.AlignHCenter
                    lineHeight: 1.2; lineHeightMode: Text.ProportionalHeight
                    opacity: 0
                    NumberAnimation on opacity { id: nameOpAnim; from: 0; to: 1; duration: 800; easing.type: Easing.OutCubic }
                    Component.onCompleted: { nameOpAnim.start(); }
                }

                Item { width: 1; height: Math.round(10 * dp) }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: Math.round(28 * dp); width: cheoT.implicitWidth + Math.round(24 * dp)
                    radius: Math.round(14 * dp); color: green; border.color: greenLight; border.width: 1
                    Text { id: cheoT; anchors.centerIn: parent; text: "Rais wa 5 wa Jamhuri ya Tanzania"; font.pointSize: Math.round(8 * dp); font.bold: true; color: cream }
                }

                Item { width: 1; height: Math.round(18 * dp) }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter; width: parent.width
                    height: cQ.implicitHeight + Math.round(28 * dp); radius: Math.round(12 * dp)
                    border.color: Qt.rgba(0.0, 0.70, 0.0, 0.50); border.width: 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#0d2e0d" }
                        GradientStop { position: 1.0; color: "#051405" }
                    }
                    Text {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.margins: Math.round(8 * dp)
                        text: "\u201C"; font.pointSize: 32; color: goldDim; lineHeight: 0.6; lineHeightMode: Text.ProportionalHeight
                    }
                    Text {
                        id: cQ
                        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: Math.round(18 * dp); rightMargin: Math.round(18 * dp) }
                        text: "Hii nchi ni yetu, tuilinde, tuijenga kwa nguvu zetu wenyewe."
                        font.pointSize: Math.round(10 * dp); font.italic: true; color: cream
                        wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
                        lineHeight: 1.5; lineHeightMode: Text.ProportionalHeight
                    }
                }

                Item { width: 1; height: Math.round(28 * dp) }

                // ── Nav grid ─────────────────────────────────────────────
                Grid {
                    anchors.horizontalCenter: parent.horizontalCenter
                    columns: 2; spacing: Math.round(10 * dp)
                    Repeater {
                        model: [
                            {label:"Wasifu",    icon:"\uD83D\uDCCC", sec:1},
                            {label:"Mafanikio", icon:"\u2605",        sec:2},
                            {label:"Maneno",    icon:"\uD83D\uDCAC",  sec:3},
                            {label:"Picha",     icon:"\uD83D\uDDBC",  sec:4}
                        ]
                        delegate: Rectangle {
                            id: navBtn
                            width: Math.round(138 * dp); height: Math.round(56 * dp)
                            radius: Math.round(12 * dp)
                            color:        navMA.pressed ? Qt.rgba(0.0, 0.55, 0.0, 0.25) : darkCard
                            border.color: navMA.pressed ? gold : Qt.rgba(0.0, 0.50, 0.0, 0.35)
                            border.width: navMA.pressed ? 2 : 1
                            Behavior on color        { ColorAnimation { duration: 120 } }
                            Behavior on border.color { ColorAnimation { duration: 120 } }
                            Behavior on scale        { NumberAnimation { duration: 100 } }
                            Row {
                                anchors.centerIn: parent; spacing: Math.round(8 * dp)
                                Text {
                                    text: modelData.icon; font.pointSize: Math.round(16 * dp)
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: navMA.pressed ? gold : cream
                                }
                                Text {
                                    text: modelData.label; font.pointSize: Math.round(10 * dp); font.bold: true
                                    color: navMA.pressed ? gold : cream
                                    anchors.verticalCenter: parent.verticalCenter
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }
                            }
                            // CCM flag stripe at bottom of nav button
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left; anchors.right: parent.right
                                height: Math.round(3 * dp); radius: Math.round(12 * dp)
                                gradient: Gradient {
                                    GradientStop { position: 0.0;  color: "#006400" }
                                    GradientStop { position: 0.40; color: "#006400" }
                                    GradientStop { position: 0.42; color: "#f5c400" }
                                    GradientStop { position: 0.58; color: "#f5c400" }
                                    GradientStop { position: 0.60; color: "#000000" }
                                    GradientStop { position: 1.0;  color: "#000000" }
                                }
                            }
                            MouseArea {
                                id: navMA
                                anchors.fill: parent
                                onPressed:  { navBtn.scale = 0.92; }
                                onReleased: {
                                    section = modelData.sec;
                                    navBtnSpring.start();
                                }
                                onCanceled: { navBtn.scale = 1.0; }
                            }
                            SequentialAnimation {
                                id: navBtnSpring
                                NumberAnimation { target: navBtn; property: "scale"; to: 1.08; duration: 120; easing.type: Easing.OutQuad }
                                NumberAnimation { target: navBtn; property: "scale"; to: 0.96; duration: 80;  easing.type: Easing.InQuad  }
                                NumberAnimation { target: navBtn; property: "scale"; to: 1.0;  duration: 100; easing.type: Easing.OutQuad }
                            }
                        }
                    }
                }

                Item { width: 1; height: Math.round(14 * dp) }

                // ── Funga button — dedicated pill below grid ──────────────
                Rectangle {
                    id: fungaBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.round(100 * dp); height: Math.round(36 * dp)
                    radius: Math.round(18 * dp)
                    color:        fuangaMA.pressed ? Qt.rgba(0.8, 0.1, 0.1, 0.25) : Qt.rgba(0.8, 0.1, 0.1, 0.10)
                    border.color: fuangaMA.pressed ? "#c0392b" : Qt.rgba(0.8, 0.1, 0.1, 0.4)
                    border.width: 1
                    Behavior on color        { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    Behavior on scale        { NumberAnimation { duration: 100 } }
                    Row {
                        anchors.centerIn: parent; spacing: Math.round(6 * dp)
                        Text { text: "X"; font.pointSize: Math.round(10 * dp); color: "#e57373"; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Funga"; font.pointSize: Math.round(10 * dp); font.bold: true; color: "#e57373"; anchors.verticalCenter: parent.verticalCenter }
                    }
                    MouseArea {
                        id: fuangaMA
                        anchors.fill: parent
                        onPressed:  { fungaBtn.scale = 0.95; }
                        onReleased: { fungaBtn.scale = 1.0; app.close(); }
                        onCanceled: { fungaBtn.scale = 1.0; }
                    }
                }

                Item { width: 1; height: Math.round(24 * dp) }
            }
        }

        // Bottom flag stripe
        Rectangle {
            anchors.bottom: parent.bottom; width: parent.width; height: Math.round(4 * dp)
            gradient: Gradient {
                GradientStop { position: 0.0;  color: "#006400" }
                GradientStop { position: 0.44; color: "#006400" }
                GradientStop { position: 0.46; color: "#f5c400" }
                GradientStop { position: 0.54; color: "#f5c400" }
                GradientStop { position: 0.56; color: "#000000" }
                GradientStop { position: 1.0;  color: "#000000" }
            }
        }
    }

    // ════════════════════════════════════════════════
    // WASIFU  (section 1)
    // ════════════════════════════════════════════════
    Item {
        anchors.fill: parent
        visible: opacity > 0
        opacity: section === 1 ? 1.0 : 0.0
        x:       section === 1 ? 0 : (section < 1 ? app.width * 0.18 : -app.width * 0.18)
        Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        Behavior on x       { NumberAnimation { duration: 350; easing.type: Easing.OutCubic  } }

        Rectangle {
            id: h1
            anchors.top: parent.top; width: parent.width; height: Math.round(54 * dp); color: "#0a160a"
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Qt.rgba(0.0, 0.50, 0.0, 0.40) }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom
                height: 2; radius: 1; color: gold; width: 0
                NumberAnimation on width { to: h1TitleRow.implicitWidth + Math.round(16 * dp); duration: 350; easing.type: Easing.OutCubic; running: true }
            }
            Rectangle {
                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: Math.round(14 * dp)
                width: Math.round(36 * dp); height: Math.round(36 * dp); radius: Math.round(18 * dp)
                color: h1BackMA.pressed ? Qt.rgba(0.0, 0.55, 0.0, 0.30) : Qt.rgba(0.0, 0.50, 0.0, 0.12)
                border.color: Qt.rgba(0.0, 0.50, 0.0, 0.35); border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
                Text { anchors.centerIn: parent; text: "\u2190"; font.pointSize: Math.round(14 * dp); color: gold }
                MouseArea { id: h1BackMA; anchors.fill: parent; onClicked: { section = 0; } }
            }
            Row {
                id: h1TitleRow
                anchors.centerIn: parent; spacing: Math.round(8 * dp)
                Text { text: "\uD83D\uDCCC"; font.pointSize: Math.round(14 * dp); anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Wasifu"; font.pointSize: Math.round(12 * dp); font.bold: true; color: cream; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Flickable {
            anchors.top: h1.bottom; anchors.bottom: parent.bottom; anchors.bottomMargin: Math.round(52 * dp); width: parent.width
            contentWidth: width; contentHeight: wCol.implicitHeight + Math.round(40 * dp)
            clip: true; boundsBehavior: Flickable.StopAtBounds

            Column {
                id: wCol; width: parent.width - Math.round(32 * dp)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.topMargin: Math.round(16 * dp)
                spacing: Math.round(12 * dp)

                Row {
                    width: parent.width; spacing: Math.round(12 * dp)
                    Rectangle {
                        width: Math.round(90 * dp); height: Math.round(110 * dp); radius: Math.round(10 * dp)
                        color: "#0f1f0f"; border.color: goldDim; border.width: 1
                        layer.enabled: true
                        Image { anchors.fill: parent; fillMode: Image.PreserveAspectCrop; source: "./magufuli0.jpeg"; smooth: true }
                    }
                    Column {
                        spacing: Math.round(5 * dp); width: parent.width - Math.round(102 * dp)
                        Repeater {
                            model: [
                                {l:"Jina",     v:"Dr. John Pombe Joseph Magufuli"},
                                {l:"Kuzaliwa", v:"29 Oktoba 1959, Chato"},
                                {l:"Kufariki", v:"17 Machi 2021"},
                                {l:"Umri",     v:"Miaka 61"},
                                {l:"Kabila",   v:"Msukuma"}
                            ]
                            delegate: Row { spacing: Math.round(4 * dp); width: parent.width
                                Text { text: modelData.l + ":"; font.pointSize: Math.round(7.5 * dp); font.bold: true; color: goldDim; width: Math.round(68 * dp) }
                                Text { text: modelData.v; font.pointSize: Math.round(7.5 * dp); color: cream; wrapMode: Text.WordWrap; width: parent.width - Math.round(72 * dp) }
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Qt.rgba(0.0, 0.50, 0.0, 0.22) }

                Repeater {
                    model: [
                        {l:"Elimu",        v:"BSc, MSc, PhD Chemistry — UDSM (2009)"},
                        {l:"Awamu",        v:"Rais wa 5 (2015–2021)"},
                        {l:"Chama",        v:"CCM"},
                        {l:"Makamu",       v:"Dr. Samia Suluhu Hassan"},
                        {l:"Kazi ya awali",v:"Mbunge Chato (1995)\nWaziri Ujenzi (2000–2015)"}
                    ]
                    delegate: Row { spacing: Math.round(8 * dp); width: parent.width
                        Text { text: modelData.l + ":"; font.pointSize: Math.round(8 * dp); font.bold: true; color: goldDim; width: Math.round(95 * dp) }
                        Text { text: modelData.v; font.pointSize: Math.round(8 * dp); color: cream; wrapMode: Text.WordWrap; width: parent.width - Math.round(103 * dp); lineHeight: 1.4; lineHeightMode: Text.ProportionalHeight }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Qt.rgba(0.0, 0.50, 0.0, 0.22) }

                Repeater {
                    model: [
                        {t:"Maisha ya Kisiasa", b:"Alianza kama Mbunge wa Chato (1995), akawa Waziri wa Ujenzi (2000–2015). Alichaguliwa Rais mwaka 2015 na 2020 kwa wingi mkubwa. Alijulikana kwa utendaji mkali wa kazi na kupigana na ufisadi."},
                        {t:"Asili yake",        b:"Alizaliwa Chato, Geita. Familia ya hali ya chini. Alipata elimu kwa bidii na akawa mmoja wa viongozi wachache Afrika wenye shahada ya uzamivu (PhD) katika Sayansi."}
                    ]
                    delegate: Column { width: parent.width; spacing: Math.round(6 * dp)
                        Text { text: modelData.t; font.pointSize: Math.round(10 * dp); font.bold: true; color: gold }
                        Text { text: modelData.b; font.pointSize: Math.round(9 * dp); color: creamDim; wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.5; lineHeightMode: Text.ProportionalHeight }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════
    // MAFANIKIO  (section 2)
    // ════════════════════════════════════════════════
    Item {
        anchors.fill: parent
        visible: opacity > 0
        opacity: section === 2 ? 1.0 : 0.0
        x:       section === 2 ? 0 : (section < 2 ? app.width * 0.18 : -app.width * 0.18)
        Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        Behavior on x       { NumberAnimation { duration: 350; easing.type: Easing.OutCubic  } }

        Rectangle {
            id: h2
            anchors.top: parent.top; width: parent.width; height: Math.round(54 * dp); color: "#0a160a"
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Qt.rgba(0.0, 0.50, 0.0, 0.40) }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom
                height: 2; radius: 1; color: gold; width: 0
                NumberAnimation on width { to: h2TitleRow.implicitWidth + Math.round(16 * dp); duration: 350; easing.type: Easing.OutCubic; running: true }
            }
            Rectangle {
                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: Math.round(14 * dp)
                width: Math.round(36 * dp); height: Math.round(36 * dp); radius: Math.round(18 * dp)
                color: h2BackMA.pressed ? Qt.rgba(0.0, 0.55, 0.0, 0.30) : Qt.rgba(0.0, 0.50, 0.0, 0.12)
                border.color: Qt.rgba(0.0, 0.50, 0.0, 0.40); border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
                Text { anchors.centerIn: parent; text: "\u2190"; font.pointSize: Math.round(14 * dp); color: gold }
                MouseArea { id: h2BackMA; anchors.fill: parent; onClicked: { section = 0; } }
            }
            Row {
                id: h2TitleRow
                anchors.centerIn: parent; spacing: Math.round(8 * dp)
                Text { text: "\u2605"; font.pointSize: Math.round(14 * dp); color: gold; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Mafanikio"; font.pointSize: Math.round(12 * dp); font.bold: true; color: cream; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Flickable {
            anchors.top: h2.bottom; anchors.bottom: parent.bottom; anchors.bottomMargin: Math.round(52 * dp); width: parent.width
            contentWidth: width; contentHeight: mafCol.implicitHeight + Math.round(40 * dp)
            clip: true; boundsBehavior: Flickable.StopAtBounds

            Column {
                id: mafCol; width: parent.width - Math.round(32 * dp)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.topMargin: Math.round(16 * dp)
                spacing: Math.round(10 * dp)

                Repeater {
                    model: [
                        {i:"\uD83D\uDE82", t:"Standard Gauge Railway (SGR)",  d:"Reli ya kisasa ya umeme inayounganisha Dar es Salaam na nchi za jirani — mradi mkubwa wa kihistoria."},
                        {i:"\uD83D\uDCA1", t:"Bwawa la Nyerere (JNHPP)",      d:"Bwawa la umeme MW 2,115 kwenye Mto Rufiji — kubwa zaidi Afrika Mashariki. Linabeba jina lake kwa heshima."},
                        {i:"\uD83C\uDFEB", t:"Elimu Bure",                    d:"Sera ya elimu ya msingi na sekondari bila malipo — ongezeko kubwa la watoto wanaosoma."},
                        {i:"\uD83D\uDCB0", t:"Kupambana na Ufisadi",          d:"Alifuta posho, akafukuza watumishi waovu, akasimamisha safari za anasa — alipewa jina 'Bulldozer'."},
                        {i:"\uD83C\uDF31", t:"Upandaji Miti",                 d:"Alipanda miti mamilioni na kuhamasisha taifa kulinda mazingira."},
                        {i:"\uD83C\uDFD7", t:"Barabara na Miundombinu",       d:"Ujenzi na ukarabati wa kilomita elfu za barabara Tanzania yote."},
                        {i:"\u26A1",       t:"Umeme Vijijini (REA)",           d:"Alipanua umeme vijijini — mwanga katika vijiji vilivyokuwa gizani."},
                        {i:"\uD83C\uDF0A", t:"Utalii na Hifadhi za Taifa",    d:"Hatua kali dhidi ya ujangili na ongezeko la mapato ya utalii."}
                    ]
                    delegate: Rectangle {
                        id: mafCard
                        width: parent.width; height: mR.implicitHeight + Math.round(20 * dp)
                        radius: Math.round(12 * dp)
                        color: mafMA.pressed ? "#142a14" : darkCard
                        border.color: Qt.rgba(0.0, 0.50, 0.0, 0.22); border.width: 1
                        opacity: 0
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        SequentialAnimation on opacity {
                            PauseAnimation  { duration: index * 80 }
                            NumberAnimation { from: 0; to: 1; duration: 350; easing.type: Easing.OutCubic }
                        }
                        SequentialAnimation on anchors.topMargin {
                            PauseAnimation  { duration: index * 80 }
                            NumberAnimation { from: Math.round(18 * dp); to: 0; duration: 350; easing.type: Easing.OutCubic }
                        }

                        // Alternating CCM stripe: even=gold, odd=green
                        Rectangle {
                            anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                            anchors.margins: Math.round(10 * dp); width: Math.round(3 * dp); radius: Math.round(2 * dp)
                            color: (index % 2 === 0) ? gold : greenLight
                        }

                        Row {
                            id: mR
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: Math.round(20 * dp); rightMargin: Math.round(14 * dp) }
                            spacing: Math.round(12 * dp)

                            // Icon circle
                            Rectangle {
                                width: Math.round(38 * dp); height: Math.round(38 * dp); radius: Math.round(19 * dp)
                                color: Qt.rgba(0.0, 0.50, 0.0, 0.18)
                                border.color: Qt.rgba(0.0, 0.50, 0.0, 0.35); border.width: 1
                                anchors.verticalCenter: parent.verticalCenter
                                Text { anchors.centerIn: parent; text: modelData.i; font.pointSize: Math.round(16 * dp) }
                            }

                            Column {
                                spacing: Math.round(4 * dp)
                                width: parent.width - Math.round(50 * dp) - Math.round(24 * dp)
                                anchors.verticalCenter: parent.verticalCenter
                                Text { text: modelData.t; font.pointSize: Math.round(10 * dp); font.bold: true; color: gold; wrapMode: Text.WordWrap; width: parent.width }
                                Text { text: modelData.d; font.pointSize: Math.round(8.5 * dp); color: creamDim; wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.4; lineHeightMode: Text.ProportionalHeight }
                            }
                        }

                        MouseArea {
                            id: mafMA
                            anchors.fill: parent
                            onPressed:  { mafCard.scale = 0.97; }
                            onReleased: { mafCard.scale = 1.0; }
                            onCanceled: { mafCard.scale = 1.0; }
                        }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════
    // MANENO  (section 3)
    // ════════════════════════════════════════════════
    Item {
        anchors.fill: parent
        visible: opacity > 0
        opacity: section === 3 ? 1.0 : 0.0
        x:       section === 3 ? 0 : (section < 3 ? app.width * 0.18 : -app.width * 0.18)
        Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        Behavior on x       { NumberAnimation { duration: 350; easing.type: Easing.OutCubic  } }

        Rectangle {
            id: h3
            anchors.top: parent.top; width: parent.width; height: Math.round(54 * dp); color: "#0a160a"
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Qt.rgba(0.0, 0.50, 0.0, 0.40) }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom
                height: 2; radius: 1; color: gold; width: 0
                NumberAnimation on width { to: h3TitleRow.implicitWidth + Math.round(16 * dp); duration: 350; easing.type: Easing.OutCubic; running: true }
            }
            Rectangle {
                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: Math.round(14 * dp)
                width: Math.round(36 * dp); height: Math.round(36 * dp); radius: Math.round(18 * dp)
                color: h3BackMA.pressed ? Qt.rgba(0.0, 0.55, 0.0, 0.30) : Qt.rgba(0.0, 0.50, 0.0, 0.12)
                border.color: Qt.rgba(0.0, 0.50, 0.0, 0.40); border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
                Text { anchors.centerIn: parent; text: "\u2190"; font.pointSize: Math.round(14 * dp); color: gold }
                MouseArea { id: h3BackMA; anchors.fill: parent; onClicked: { section = 0; } }
            }
            Row {
                id: h3TitleRow
                anchors.centerIn: parent; spacing: Math.round(8 * dp)
                Text { text: "\uD83D\uDCAC"; font.pointSize: Math.round(14 * dp); anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Maneno ya Hekima"; font.pointSize: Math.round(12 * dp); font.bold: true; color: cream; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Flickable {
            anchors.top: h3.bottom; anchors.bottom: parent.bottom; anchors.bottomMargin: Math.round(52 * dp); width: parent.width
            contentWidth: width; contentHeight: manenoCol.implicitHeight + Math.round(40 * dp)
            clip: true; boundsBehavior: Flickable.StopAtBounds

            Column {
                id: manenoCol; width: parent.width - Math.round(32 * dp)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.topMargin: Math.round(16 * dp)
                spacing: Math.round(12 * dp)

                Repeater {
                    model: [
                        {q:"Hii nchi ni yetu, tuilinde, tuijenga kwa nguvu zetu wenyewe.",                    c:"Hotuba ya uchaguzi"},
                        {q:"Kazi ndiyo ibada. Mtu asiyefanya kazi bado ni mtoto wa bure.",                    c:"Kauli yake maarufu"},
                        {q:"Tunaweza. Tunaweza. Tunaweza kufanya mambo makubwa.",                              c:"Hotuba, 2015"},
                        {q:"Nilikuwa maskini, lakini elimu ilinipa nguvu. Watoto wetu wote wanahitaji elimu.", c:"Siku ya Elimu"},
                        {q:"Serikali ya watu ni serikali inayowajibika kwa watu, sio kwa wachache tu.",        c:"Bungeni, 2016"},
                        {q:"Ufisadi ni adui mkubwa wa maendeleo. Hatutasimama akiba yetu ikiibiwa.",           c:"Kampeni ya ufisadi"},
                        {q:"Tanzania ina rasilimali za kutosha. Tatizo ni usimamizi mbaya tu.",                c:"Mkutano wa viongozi"},
                        {q:"Napenda Tanzania. Kila sehemu yake ni ya kipekee na inastahili kulindwa.",         c:"Ziara ya hifadhi"}
                    ]
                    delegate: Rectangle {
                        id: quoteCard
                        width: parent.width; height: qInner.implicitHeight + Math.round(24 * dp)
                        radius: Math.round(14 * dp)
                        color: quoteMA.pressed ? "#142a14" : darkCard
                        border.color: Qt.rgba(0.0, 0.50, 0.0, 0.30); border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        Rectangle {
                            anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                            anchors.margins: Math.round(10 * dp); width: Math.round(3 * dp); radius: Math.round(2 * dp); color: gold
                        }
                        Column {
                            id: qInner
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: Math.round(18 * dp); rightMargin: Math.round(14 * dp) }
                            spacing: Math.round(6 * dp)
                            Text { text: "\u201C" + modelData.q + "\u201D"; font.pointSize: Math.round(10 * dp); font.italic: true; color: cream; wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.5; lineHeightMode: Text.ProportionalHeight }
                            Text { text: "— " + modelData.c; font.pointSize: Math.round(8 * dp); color: goldDim; font.italic: true }
                        }
                        MouseArea {
                            id: quoteMA
                            anchors.fill: parent
                            onPressed:  { quoteCard.scale = 0.97; }
                            onReleased: { quoteCard.scale = 1.0; }
                            onCanceled: { quoteCard.scale = 1.0; }
                        }
                    }
                }

                // Memorial card
                Rectangle {
                    width: parent.width; height: memC.implicitHeight + Math.round(28 * dp); radius: Math.round(14 * dp)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#002800" }
                        GradientStop { position: 1.0; color: "#003800" }
                    }
                    border.color: greenLight; border.width: 1
                    Column {
                        id: memC
                        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: Math.round(20 * dp) }
                        spacing: Math.round(8 * dp)
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "\uD83C\uDF39 Pumzika kwa Amani \uD83C\uDF39"; font.pointSize: Math.round(12 * dp); font.bold: true; color: greenLight }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "29 Oktoba 1959 – 17 Machi 2021"; font.pointSize: Math.round(9 * dp); color: creamDim }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Kumbukumbu yake itadumu daima mioyoni mwa Watanzania"; font.pointSize: Math.round(9 * dp); font.italic: true; color: gold; wrapMode: Text.WordWrap; width: parent.width; horizontalAlignment: Text.AlignHCenter }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════
    // PICHA  (section 4)
    // ════════════════════════════════════════════════
    Item {
        anchors.fill: parent
        visible: opacity > 0
        opacity: section === 4 ? 1.0 : 0.0
        x:       section === 4 ? 0 : (section < 4 ? app.width * 0.18 : -app.width * 0.18)
        Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        Behavior on x       { NumberAnimation { duration: 350; easing.type: Easing.OutCubic  } }

        Rectangle {
            id: h4
            anchors.top: parent.top; width: parent.width; height: Math.round(54 * dp); color: "#0a160a"
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Qt.rgba(0.0, 0.50, 0.0, 0.40) }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom
                height: 2; radius: 1; color: gold; width: 0
                NumberAnimation on width { to: h4TitleRow.implicitWidth + Math.round(16 * dp); duration: 350; easing.type: Easing.OutCubic; running: true }
            }
            Rectangle {
                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: Math.round(14 * dp)
                width: Math.round(36 * dp); height: Math.round(36 * dp); radius: Math.round(18 * dp)
                color: h4BackMA.pressed ? Qt.rgba(0.0, 0.55, 0.0, 0.30) : Qt.rgba(0.0, 0.50, 0.0, 0.12)
                border.color: Qt.rgba(0.0, 0.50, 0.0, 0.40); border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
                Text { anchors.centerIn: parent; text: "\u2190"; font.pointSize: Math.round(14 * dp); color: gold }
                MouseArea { id: h4BackMA; anchors.fill: parent; onClicked: { section = 0; } }
            }
            Row {
                id: h4TitleRow
                anchors.centerIn: parent; spacing: Math.round(8 * dp)
                Text { text: "\uD83D\uDDBC"; font.pointSize: Math.round(14 * dp); anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Picha za Kumbukumbu"; font.pointSize: Math.round(12 * dp); font.bold: true; color: cream; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Flickable {
            anchors.top: h4.bottom; anchors.bottom: parent.bottom; anchors.bottomMargin: Math.round(52 * dp); width: parent.width
            contentWidth: width; contentHeight: pichaCol.implicitHeight + Math.round(40 * dp)
            clip: true; boundsBehavior: Flickable.StopAtBounds

            Column {
                id: pichaCol; width: parent.width - Math.round(32 * dp)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.topMargin: Math.round(16 * dp)
                spacing: Math.round(12 * dp)

                // Picha kubwa — tappable, layer.enabled + CCM gold border
                Rectangle {
                    id: heroTile
                    width: parent.width; height: Math.round(200 * dp); radius: Math.round(12 * dp)
                    color: "#0f1f0f"
                    border.color: gold
                    border.width: Math.round(2 * dp)
                    layer.enabled: true
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    Image { id: heroImg; anchors.fill: parent; fillMode: Image.PreserveAspectCrop; source: "./magufuli0.jpeg"; smooth: true }
                    MouseArea {
                        anchors.fill: parent
                        onPressed:  { heroTile.scale = 0.97; }
                        onReleased: { heroTile.scale = 1.0; lightboxSource = heroImg.source; lightboxOpen = true; }
                        onCanceled: { heroTile.scale = 1.0; }
                    }
                }

                // Grid 2x3 — tappable → lightbox
                Grid {
                    width: parent.width; columns: 2; spacing: Math.round(8 * dp)
                    Repeater {
                        model: [
                            {n:"Picha 1", s:"./magufuli1.jpeg"},
                            {n:"Picha 2", s:"./magufuli2.jpeg"},
                            {n:"Picha 3", s:"./magufuli3.jpeg"},
                            {n:"Picha 4", s:"./magufuli4.jpeg"},
                            {n:"Picha 5", s:"./magufuli5.jpeg"},
                            {n:"Picha 6", s:"./magufuli6.jpeg"}
                        ]
                        delegate: Rectangle {
                            id: gridTile
                            width: (parent.width - Math.round(8 * dp)) / 2; height: width * 0.72
                            radius: Math.round(10 * dp); color: "#0f1f0f"
                            border.color: Qt.rgba(0.0, 0.50, 0.0, 0.22); border.width: 1; clip: true
                            Behavior on scale { NumberAnimation { duration: 100 } }
                            Image {
                                id: tileImg
                                anchors.fill: parent; fillMode: Image.PreserveAspectCrop; source: modelData.s
                            }
                            Column {
                                anchors.centerIn: parent
                                visible: tileImg.status !== Image.Ready
                                spacing: Math.round(3 * dp)
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "\uD83D\uDDBC"; font.pointSize: Math.round(18 * dp) }
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.n; font.pointSize: Math.round(7 * dp); color: goldDim }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onPressed:  { gridTile.scale = 0.95; }
                                onReleased: { gridTile.scale = 1.0; lightboxSource = tileImg.source; lightboxOpen = true; }
                                onCanceled: { gridTile.scale = 1.0; }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Bottom nav bar ────────────────────────────────────────────────────────
    Rectangle {
        id: bottomNav
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height: Math.round(52 * dp)
        color: "#0a160a"
        visible: section >= 1 && !lightboxOpen
        opacity: section >= 1 ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 250 } }
        Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: Qt.rgba(0.0, 0.50, 0.0, 0.40) }
        Rectangle {
            anchors.top: parent.top; width: parent.width; height: Math.round(2 * dp)
            gradient: Gradient {
                GradientStop { position: 0.0;  color: "#006400" }
                GradientStop { position: 0.44; color: "#006400" }
                GradientStop { position: 0.46; color: "#f5c400" }
                GradientStop { position: 0.54; color: "#f5c400" }
                GradientStop { position: 0.56; color: "#000000" }
                GradientStop { position: 1.0;  color: "#000000" }
            }
        }
        Row {
            anchors.centerIn: parent
            spacing: 0
            Repeater {
                model: [
                    {icon:"\uD83D\uDCCC", label:"Wasifu",    sec:1},
                    {icon:"\u2605",        label:"Mafanikio", sec:2},
                    {icon:"\uD83D\uDCAC",  label:"Maneno",    sec:3},
                    {icon:"\uD83D\uDDBC",  label:"Picha",     sec:4}
                ]
                delegate: Item {
                    width: Math.round(app.width / 4)
                    height: Math.round(52 * dp)
                    Rectangle {
                        id: navDot
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: section === modelData.sec ? Math.round(2 * dp) : -Math.round(4 * dp)
                        width: section === modelData.sec ? Math.round(20 * dp) : Math.round(8 * dp)
                        height: Math.round(2 * dp); radius: 1
                        color: gold
                        opacity: section === modelData.sec ? 1.0 : 0.0
                        Behavior on opacity     { NumberAnimation { duration: 200 } }
                        Behavior on anchors.topMargin { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
                        Behavior on width       { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }
                    Column {
                        anchors.centerIn: parent
                        spacing: Math.round(2 * dp)
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.icon
                            font.pointSize: Math.round(14 * dp)
                            color: section === modelData.sec ? gold : creamDim
                            opacity: section === modelData.sec ? 1.0 : 0.5
                            Behavior on color   { ColorAnimation  { duration: 200 } }
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.label
                            font.pointSize: Math.round(6.5 * dp); font.bold: section === modelData.sec
                            color: section === modelData.sec ? gold : creamDim
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: { section = modelData.sec; }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════
    // LIGHTBOX OVERLAY
    // ════════════════════════════════════════════════
    Rectangle {
        id: lightbox
        anchors.fill: parent
        color: "#000000"
        opacity: lightboxOpen ? 0.95 : 0.0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 280; easing.type: Easing.InOutQuad } }

        Image {
            anchors.centerIn: parent
            width:  parent.width  - Math.round(24 * dp)
            height: parent.height - Math.round(80 * dp)
            fillMode: Image.PreserveAspectFit
            source: lightboxSource
            smooth: true
            scale: lightboxOpen ? 1.0 : 0.85
            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
        }

        // CCM-styled close button
        Rectangle {
            id: lbCloseBtn
            anchors.bottom: parent.bottom; anchors.bottomMargin: Math.round(20 * dp)
            anchors.horizontalCenter: parent.horizontalCenter
            width: lbCloseRow.implicitWidth + Math.round(28 * dp)
            height: Math.round(38 * dp); radius: Math.round(19 * dp)
            color: lbCloseMA.pressed ? Qt.rgba(0.96, 0.77, 0.0, 0.25) : Qt.rgba(0.96, 0.77, 0.0, 0.12)
            border.color: gold; border.width: 1
            Behavior on color { ColorAnimation { duration: 120 } }
            Behavior on scale { NumberAnimation { duration: 100 } }
            // Mini CCM stripe at bottom of button
            Rectangle {
                anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                height: Math.round(3 * dp); radius: Math.round(19 * dp)
                gradient: Gradient {
                    GradientStop { position: 0.0;  color: "#006400" }
                    GradientStop { position: 0.40; color: "#006400" }
                    GradientStop { position: 0.42; color: "#f5c400" }
                    GradientStop { position: 0.58; color: "#f5c400" }
                    GradientStop { position: 0.60; color: "#000000" }
                    GradientStop { position: 1.0;  color: "#000000" }
                }
            }
            Row {
                id: lbCloseRow
                anchors.centerIn: parent; spacing: Math.round(6 * dp)
                Text { text: "X"; font.pointSize: Math.round(10 * dp); color: gold; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Funga"; font.pointSize: Math.round(9 * dp); font.bold: true; color: gold; anchors.verticalCenter: parent.verticalCenter }
            }
            MouseArea {
                id: lbCloseMA
                anchors.fill: parent
                onPressed:  { lbCloseBtn.scale = 0.95; }
                onReleased: { lbCloseBtn.scale = 1.0; lightboxOpen = false; }
                onCanceled: { lbCloseBtn.scale = 1.0; }
            }
        }

        // Tap anywhere else to close
        MouseArea {
            anchors.fill: parent
            onClicked: { lightboxOpen = false; }
        }
    }
}
