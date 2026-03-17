import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Rectangle {
    id: app
    width:  parent ? parent.width  : 400
    height: parent ? parent.height : 800
    color: "#0a0a0a"

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

    readonly property color gold:       "#c9a84c"
    readonly property color goldDim:    "#7a6128"
    readonly property color cream:      "#f5f0e8"
    readonly property color creamDim:   "#9e9888"
    readonly property color darkCard:   "#141414"
    readonly property color green:      "#1a5c2e"
    readonly property color greenLight: "#2a8c46"
    readonly property real  dp:         Math.min(width, height) / 400

    property int section: 0

    // Background grid
    Canvas {
        anchors.fill: parent; opacity: 0.03
        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "#c9a84c"; ctx.lineWidth = 0.5;
            for (var x=0; x<width; x+=40) { ctx.beginPath(); ctx.moveTo(x,0); ctx.lineTo(x,height); ctx.stroke(); }
            for (var y=0; y<height; y+=40) { ctx.beginPath(); ctx.moveTo(0,y); ctx.lineTo(width,y); ctx.stroke(); }
        }
    }

    // ── FLAG STRIPE helper ─────────────────────────────────
    // Used at top and bottom of cover

    // ════════════════════════════════════════════════
    // COVER
    // ════════════════════════════════════════════════
    Item {
        anchors.fill: parent
        visible: section === 0
        opacity: section === 0 ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        Rectangle {
            anchors.top: parent.top; width: parent.width; height: Math.round(4*dp)
            gradient: Gradient { orientation: Gradient.Horizontal
                GradientStop { position: 0.0;  color: "#1a5c2e" }
                GradientStop { position: 0.44; color: "#1a5c2e" }
                GradientStop { position: 0.46; color: "#c9a84c" }
                GradientStop { position: 0.54; color: "#c9a84c" }
                GradientStop { position: 0.56; color: "#000000" }
                GradientStop { position: 1.0;  color: "#000000" }
            }
        }

        Flickable {
            anchors.fill: parent; contentWidth: width
            contentHeight: coverCol.implicitHeight + Math.round(60*dp)
            clip: true; boundsBehavior: Flickable.StopAtBounds

            Column {
                id: coverCol
                width: parent.width - Math.round(40*dp)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.topMargin: Math.round(36*dp)
                spacing: 0

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.round(160*dp); height: Math.round(160*dp); radius: Math.round(80*dp)
                    color: "#1a1a1a";
                    Image { id: coverImg; anchors.fill: parent; anchors.margins: Math.round(4*dp); fillMode: Image.PreserveAspectCrop; source: "./magufuli0.jpeg" /* ← "qrc:/images/magufuli.jpg" */ }
                    Column { anchors.centerIn: parent; visible: coverImg.status !== Image.Ready; spacing: Math.round(4*dp)
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "\uD83D\uDDBC"; font.pointSize: 28 }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Picha Hapa"; font.pointSize: 8; color: goldDim }
                    }
                }

                Item { width:1; height: Math.round(18*dp) }

                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "29 Oktoba 1959  —  17 Machi 2021"; font.pointSize: Math.round(9*dp); font.letterSpacing: Math.round(2*dp); color: goldDim }

                Item { width:1; height: Math.round(8*dp) }

                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "John Pombe\nMagufuli"; font.pointSize: Math.round(26*dp); font.bold: true; color: cream; horizontalAlignment: Text.AlignHCenter; lineHeight: 1.2; lineHeightMode: Text.ProportionalHeight }

                Item { width:1; height: Math.round(10*dp) }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: Math.round(28*dp); width: cheoT.implicitWidth + Math.round(24*dp); radius: Math.round(14*dp); color: green; border.color: greenLight; border.width: 1
                    Text { id: cheoT; anchors.centerIn: parent; text: "Rais wa 5 wa Jamhuri ya Tanzania"; font.pointSize: Math.round(8*dp); font.bold: true; color: cream }
                }

                Item { width:1; height: Math.round(18*dp) }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter; width: parent.width
                    height: cQ.implicitHeight + Math.round(28*dp); radius: Math.round(12*dp); color: darkCard
                    border.color: Qt.rgba(0.79,0.66,0.30,0.2); border.width: 1
                    Text { anchors.top: parent.top; anchors.left: parent.left; anchors.margins: Math.round(8*dp); text: "\u201C"; font.pointSize: 32; color: goldDim; lineHeight: 0.6; lineHeightMode: Text.ProportionalHeight }
                    Text { id: cQ; anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: Math.round(18*dp); rightMargin: Math.round(18*dp) }
                        text: "Hii nchi ni yetu, tuilinde, tuijenga kwa nguvu zetu wenyewe."; font.pointSize: Math.round(10*dp); font.italic: true; color: cream; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter; lineHeight: 1.5; lineHeightMode: Text.ProportionalHeight }
                }

                Item { width:1; height: Math.round(28*dp) }

                Grid {
                    anchors.horizontalCenter: parent.horizontalCenter; columns: 2; spacing: Math.round(10*dp)
                    Repeater {
                        model: [ {label:"Wasifu",icon:"\uD83D\uDCCC",sec:1}, {label:"Mafanikio",icon:"\u2605",sec:2}, {label:"Maneno",icon:"\uD83D\uDCAC",sec:3}, {label:"Picha",icon:"\uD83D\uDDBC",sec:4}, {label:"Funga",icon:"X",sec:5} ]
                        delegate: Rectangle {
                            width: Math.round(138*dp); height: Math.round(56*dp); radius: Math.round(12*dp); color: darkCard
                            border.color: Qt.rgba(0.79,0.66,0.30,0.25); border.width: 1
                            Row { anchors.centerIn: parent; spacing: Math.round(8*dp)
                                Text { text: modelData.icon; font.pointSize: Math.round(16*dp); anchors.verticalCenter: parent.verticalCenter }
                                Text { text: modelData.label; font.pointSize: Math.round(10*dp); font.bold: true; color: cream; anchors.verticalCenter: parent.verticalCenter }
                            }
                            MouseArea { anchors.fill: parent; onPressed: parent.scale=0.95;
                                onReleased: {
                                    if(modelData.sec === 5){
                                       app.close();
                                        return;
                                    }
                                    parent.scale=1.0;
                                    section=modelData.sec;
                                }
                                onCanceled: parent.scale=1.0 }
                            Behavior on scale { NumberAnimation { duration: 100 } }
                        }
                    }
                }

                Item { width:1; height: Math.round(24*dp) }
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom; width: parent.width; height: Math.round(4*dp)
            gradient: Gradient { orientation: Gradient.Horizontal
                GradientStop { position: 0.0;  color: "#1a5c2e" }
                GradientStop { position: 0.44; color: "#1a5c2e" }
                GradientStop { position: 0.46; color: "#c9a84c" }
                GradientStop { position: 0.54; color: "#c9a84c" }
                GradientStop { position: 0.56; color: "#000000" }
                GradientStop { position: 1.0;  color: "#000000" }
            }
        }
    }

    // ════════════════════════════════════════════════
    // WASIFU
    // ════════════════════════════════════════════════
    Item {
        anchors.fill: parent; visible: section===1; opacity: section===1 ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        Rectangle {
            id: h1; anchors.top: parent.top; width: parent.width; height: Math.round(54*dp); color: "#111111"
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Qt.rgba(0.79,0.66,0.30,0.3) }
            Rectangle { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: Math.round(14*dp)
                width: Math.round(36*dp); height: Math.round(36*dp); radius: Math.round(18*dp); color: Qt.rgba(0.79,0.66,0.30,0.1); border.color: Qt.rgba(0.79,0.66,0.30,0.3); border.width: 1
                Text { anchors.centerIn: parent; text: "\u2190"; font.pointSize: Math.round(14*dp); color: gold }
                MouseArea { anchors.fill: parent; onClicked: section=0 }
            }
            Row { anchors.centerIn: parent; spacing: Math.round(8*dp)
                Text { text: "\uD83D\uDCCC"; font.pointSize: Math.round(14*dp); anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Wasifu"; font.pointSize: Math.round(12*dp); font.bold: true; color: cream; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Flickable {
            anchors.top: h1.bottom; anchors.bottom: parent.bottom; width: parent.width
            contentWidth: width; contentHeight: wCol.implicitHeight + Math.round(40*dp)
            clip: true; boundsBehavior: Flickable.StopAtBounds

            Column {
                id: wCol; width: parent.width - Math.round(32*dp)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.topMargin: Math.round(16*dp)
                spacing: Math.round(12*dp)

                Row {
                    width: parent.width; spacing: Math.round(12*dp)
                    Rectangle {
                        width: Math.round(90*dp); height: Math.round(110*dp); radius: Math.round(10*dp); color: "#1a1a1a"; border.color: goldDim; border.width: 1
                        Image { anchors.fill: parent; anchors.margins: 2; fillMode: Image.PreserveAspectCrop; source: "./magufuli0.jpeg" /* ← "qrc:/images/w.jpg" */ }
                    }
                    Column {
                        spacing: Math.round(5*dp); width: parent.width - Math.round(102*dp)
                        Repeater {
                            model: [ {l:"Jina Kamili",v:"John Pombe Joseph Magufuli"}, {l:"Kuzaliwa",v:"29 Oktoba 1959, Chato"}, {l:"Kufariki",v:"17 Machi 2021"}, {l:"Umri",v:"Miaka 61"}, {l:"Kabila",v:"Msukuma"} ]
                            delegate: Row { spacing: Math.round(4*dp); width: parent.width
                                Text { text: modelData.l+":"; font.pointSize: Math.round(7.5*dp); font.bold: true; color: goldDim; width: Math.round(68*dp) }
                                Text { text: modelData.v; font.pointSize: Math.round(7.5*dp); color: cream; wrapMode: Text.WordWrap; width: parent.width - Math.round(72*dp) }
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Qt.rgba(0.79,0.66,0.30,0.15) }

                Repeater {
                    model: [ {l:"Elimu",v:"BSc, MSc, PhD Chemistry — UDSM (2009)"}, {l:"Awamu",v:"Rais wa 5 (2015–2021)"}, {l:"Chama",v:"CCM"}, {l:"Makamu",v:"Samia Suluhu Hassan"}, {l:"Kazi ya awali",v:"Mbunge Chato (1995)\nWaziri Ujenzi (2000–2015)"} ]
                    delegate: Row { spacing: Math.round(8*dp); width: parent.width
                        Text { text: modelData.l+":"; font.pointSize: Math.round(8*dp); font.bold: true; color: goldDim; width: Math.round(95*dp) }
                        Text { text: modelData.v; font.pointSize: Math.round(8*dp); color: cream; wrapMode: Text.WordWrap; width: parent.width-Math.round(103*dp); lineHeight: 1.4; lineHeightMode: Text.ProportionalHeight }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Qt.rgba(0.79,0.66,0.30,0.15) }

                Repeater {
                    model: [
                        {t:"Maisha ya Kisiasa", b:"Alianza kama Mbunge wa Chato (1995), akawa Waziri wa Ujenzi (2000–2015). Alichaguliwa Rais mwaka 2015 na 2020 kwa wingi mkubwa. Alijulikana kwa utendaji mkali wa kazi na kupigana na ufisadi."},
                        {t:"Asili yake",       b:"Alizaliwa Chato, Geita. Familia ya hali ya chini. Alipata elimu kwa bidii na akawa mmoja wa viongozi wachache Afrika wenye shahada ya uzamivu (PhD) katika Sayansi."}
                    ]
                    delegate: Column { width: parent.width; spacing: Math.round(6*dp)
                        Text { text: modelData.t; font.pointSize: Math.round(10*dp); font.bold: true; color: gold }
                        Text { text: modelData.b; font.pointSize: Math.round(9*dp); color: creamDim; wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.5; lineHeightMode: Text.ProportionalHeight }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════
    // MAFANIKIO
    // ════════════════════════════════════════════════
    Item {
        anchors.fill: parent; visible: section===2; opacity: section===2 ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        Rectangle {
            id: h2; anchors.top: parent.top; width: parent.width; height: Math.round(54*dp); color: "#111111"
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Qt.rgba(0.79,0.66,0.30,0.3) }
            Rectangle { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: Math.round(14*dp)
                width: Math.round(36*dp); height: Math.round(36*dp); radius: Math.round(18*dp); color: Qt.rgba(0.79,0.66,0.30,0.1); border.color: Qt.rgba(0.79,0.66,0.30,0.3); border.width: 1
                Text { anchors.centerIn: parent; text: "\u2190"; font.pointSize: Math.round(14*dp); color: gold }
                MouseArea { anchors.fill: parent; onClicked: section=0 }
            }
            Row { anchors.centerIn: parent; spacing: Math.round(8*dp)
                Text { text: "\u2605"; font.pointSize: Math.round(14*dp); color: gold; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Mafanikio"; font.pointSize: Math.round(12*dp); font.bold: true; color: cream; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Flickable {
            anchors.top: h2.bottom; anchors.bottom: parent.bottom; width: parent.width
            contentWidth: width; contentHeight: mafCol.implicitHeight + Math.round(40*dp)
            clip: true; boundsBehavior: Flickable.StopAtBounds

            Column {
                id: mafCol; width: parent.width - Math.round(32*dp)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.topMargin: Math.round(16*dp)
                spacing: Math.round(10*dp)

                Repeater {
                    model: [
                        {i:"\uD83D\uDE82", t:"Standard Gauge Railway (SGR)", d:"Reli ya kisasa ya umeme inayounganisha Dar es Salaam na nchi za jirani — mradi mkubwa wa kihistoria."},
                        {i:"\uD83D\uDCA1", t:"Bwawa la Nyerere (JNHPP)",     d:"Bwawa la umeme MW 2,115 kwenye Mto Rufiji — kubwa zaidi Afrika Mashariki. Linabeba jina lake kwa heshima."},
                        {i:"\uD83C\uDFEB", t:"Elimu Bure",                    d:"Sera ya elimu ya msingi na sekondari bila malipo — ongezeko kubwa la watoto wanaosoma."},
                        {i:"\uD83D\uDCB0", t:"Kupambana na Ufisadi",          d:"Alifuta posho, akafukuza watumishi waovu, akasimamisha safari za anasa — alipewa jina 'Bulldozer'."},
                        {i:"\uD83C\uDF31", t:"Upandaji Miti",                 d:"Alipanda miti mamilioni na kuhamasisha taifa kulinda mazingira."},
                        {i:"\uD83C\uDFD7", t:"Barabara na Miundombinu",      d:"Ujenzi na ukarabati wa kilomita elfu za barabara Tanzania yote."},
                        {i:"\u26A1",       t:"Umeme Vijijini (REA)",           d:"Alipanua umeme vijijini — mwanga katika vijiji vilivyokuwa gizani."},
                        {i:"\uD83C\uDF0A", t:"Utalii na Hifadhi za Taifa",   d:"Hatua kali dhidi ya ujangili na ongezeko la mapato ya utalii."}
                    ]
                    delegate: Rectangle {
                        width: parent.width; height: mR.implicitHeight + Math.round(20*dp)
                        radius: Math.round(12*dp); color: darkCard; border.color: Qt.rgba(0.79,0.66,0.30,0.15); border.width: 1
                        Row {
                            id: mR; anchors { left:parent.left; right:parent.right; verticalCenter:parent.verticalCenter; leftMargin:Math.round(14*dp); rightMargin:Math.round(14*dp) }
                            spacing: Math.round(12*dp)
                            Text { text: modelData.i; font.pointSize: Math.round(20*dp); anchors.verticalCenter: parent.verticalCenter }
                            Column { spacing: Math.round(4*dp); width: parent.width - Math.round(32*dp) - Math.round(24*dp)
                                Text { text: modelData.t; font.pointSize: Math.round(10*dp); font.bold: true; color: gold; wrapMode: Text.WordWrap; width: parent.width }
                                Text { text: modelData.d; font.pointSize: Math.round(8.5*dp); color: creamDim; wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.4; lineHeightMode: Text.ProportionalHeight }
                            }
                        }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════
    // MANENO
    // ════════════════════════════════════════════════
    Item {
        anchors.fill: parent; visible: section===3; opacity: section===3 ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        Rectangle {
            id: h3; anchors.top: parent.top; width: parent.width; height: Math.round(54*dp); color: "#111111"
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Qt.rgba(0.79,0.66,0.30,0.3) }
            Rectangle { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: Math.round(14*dp)
                width: Math.round(36*dp); height: Math.round(36*dp); radius: Math.round(18*dp); color: Qt.rgba(0.79,0.66,0.30,0.1); border.color: Qt.rgba(0.79,0.66,0.30,0.3); border.width: 1
                Text { anchors.centerIn: parent; text: "\u2190"; font.pointSize: Math.round(14*dp); color: gold }
                MouseArea { anchors.fill: parent; onClicked: section=0 }
            }
            Row { anchors.centerIn: parent; spacing: Math.round(8*dp)
                Text { text: "\uD83D\uDCAC"; font.pointSize: Math.round(14*dp); anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Maneno ya Hekima"; font.pointSize: Math.round(12*dp); font.bold: true; color: cream; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Flickable {
            anchors.top: h3.bottom; anchors.bottom: parent.bottom; width: parent.width
            contentWidth: width; contentHeight: manenoCol.implicitHeight + Math.round(40*dp)
            clip: true; boundsBehavior: Flickable.StopAtBounds

            Column {
                id: manenoCol; width: parent.width - Math.round(32*dp)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.topMargin: Math.round(16*dp)
                spacing: Math.round(12*dp)

                Repeater {
                    model: [
                        {q:"Hii nchi ni yetu, tuilinde, tuijenga kwa nguvu zetu wenyewe.",                   c:"Hotuba ya uchaguzi"},
                        {q:"Kazi ndiyo ibada. Mtu asiyefanya kazi bado ni mtoto wa bure.",                    c:"Kauli yake maarufu"},
                        {q:"Tunaweza. Tunaweza. Tunaweza kufanya mambo makubwa.",                             c:"Hotuba, 2015"},
                        {q:"Nilikuwa maskini, lakini elimu ilinipa nguvu. Watoto wetu wote wanahitaji elimu.",c:"Siku ya Elimu"},
                        {q:"Serikali ya watu ni serikali inayowajibika kwa watu, sio kwa wachache tu.",       c:"Bungeni, 2016"},
                        {q:"Ufisadi ni adui mkubwa wa maendeleo. Hatutasimama akiba yetu ikiibiwa.",          c:"Kampeni ya ufisadi"},
                        {q:"Tanzania ina rasilimali za kutosha. Tatizo ni usimamizi mbaya tu.",               c:"Mkutano wa viongozi"},
                        {q:"Napenda Tanzania. Kila sehemu yake ni ya kipekee na inastahili kulindwa.",        c:"Ziara ya hifadhi"}
                    ]
                    delegate: Rectangle {
                        width: parent.width; height: qInner.implicitHeight + Math.round(24*dp)
                        radius: Math.round(14*dp); color: darkCard; border.color: Qt.rgba(0.79,0.66,0.30,0.2); border.width: 1
                        Rectangle { anchors.left:parent.left; anchors.top:parent.top; anchors.bottom:parent.bottom; anchors.margins:Math.round(10*dp); width:Math.round(3*dp); radius:Math.round(2*dp); color:gold }
                        Column {
                            id: qInner
                            anchors { left:parent.left; right:parent.right; verticalCenter:parent.verticalCenter; leftMargin:Math.round(18*dp); rightMargin:Math.round(14*dp) }
                            spacing: Math.round(6*dp)
                            Text { text: "\u201C" + modelData.q + "\u201D"; font.pointSize: Math.round(10*dp); font.italic: true; color: cream; wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.5; lineHeightMode: Text.ProportionalHeight }
                            Text { text: "— " + modelData.c; font.pointSize: Math.round(8*dp); color: goldDim; font.italic: true }
                        }
                    }
                }

                Rectangle {
                    width: parent.width; height: memC.implicitHeight + Math.round(28*dp); radius: Math.round(14*dp)
                    gradient: Gradient { orientation: Gradient.Horizontal; GradientStop { position: 0.0; color: "#0a1f0e" }
                        GradientStop { position: 1.0; color: "#0e2a14" } }
                    border.color: greenLight; border.width: 1
                    Column {
                        id: memC; anchors { left:parent.left; right:parent.right; verticalCenter:parent.verticalCenter; margins:Math.round(20*dp) }
                        spacing: Math.round(8*dp)
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "\uD83C\uDF39 Pumzika kwa Amani \uD83C\uDF39"; font.pointSize: Math.round(12*dp); font.bold: true; color: greenLight }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "29 Oktoba 1959 – 17 Machi 2021"; font.pointSize: Math.round(9*dp); color: creamDim }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Kumbukumbu yake itadumu daima mioyoni mwa Watanzania"; font.pointSize: Math.round(9*dp); font.italic: true; color: gold; wrapMode: Text.WordWrap; width: parent.width; horizontalAlignment: Text.AlignHCenter }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════
    // PICHA
    // ════════════════════════════════════════════════
    Item {
        anchors.fill: parent; visible: section===4; opacity: section===4 ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        Rectangle {
            id: h4; anchors.top: parent.top; width: parent.width; height: Math.round(54*dp); color: "#111111"
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Qt.rgba(0.79,0.66,0.30,0.3) }
            Rectangle { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: Math.round(14*dp)
                width: Math.round(36*dp); height: Math.round(36*dp); radius: Math.round(18*dp); color: Qt.rgba(0.79,0.66,0.30,0.1); border.color: Qt.rgba(0.79,0.66,0.30,0.3); border.width: 1
                Text { anchors.centerIn: parent; text: "\u2190"; font.pointSize: Math.round(14*dp); color: gold }
                MouseArea { anchors.fill: parent; onClicked: section=0 }
            }
            Row { anchors.centerIn: parent; spacing: Math.round(8*dp)
                Text { text: "\uD83D\uDDBC"; font.pointSize: Math.round(14*dp); anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Picha za Kumbukumbu"; font.pointSize: Math.round(12*dp); font.bold: true; color: cream; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Flickable {
            anchors.top: h4.bottom; anchors.bottom: parent.bottom; width: parent.width
            contentWidth: width; contentHeight: pichaCol.implicitHeight + Math.round(40*dp)
            clip: true; boundsBehavior: Flickable.StopAtBounds

            Column {
                id: pichaCol; width: parent.width - Math.round(32*dp)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.topMargin: Math.round(16*dp)
                spacing: Math.round(12*dp)


                // Picha kubwa (full width)
                Rectangle {
                    width: parent.width; height: Math.round(200*dp); radius: Math.round(12*dp)
                    color: "#1a1a1a"; border.color: Qt.rgba(0.79,0.66,0.30,0.2); border.width: 1; clip: true
                    Image { anchors.fill: parent; fillMode: Image.PreserveAspectCrop; source: "./magufuli0.jpeg" /* ← "./magufuli0.jpeg" */ }

                }

                // Grid 2x3
                Grid { width: parent.width; columns: 2; spacing: Math.round(8*dp)
                    Repeater {
                        model: [ {n:"Picha 1",s:"./magufuli1.jpeg"}, {n:"Picha 2",s:"./magufuli2.jpeg"}, {n:"Picha 3",s:"./magufuli3.jpeg"}, {n:"Picha 4",s:"./magufuli4.jpeg"}, {n:"Picha 5",s:"./magufuli5.jpeg"}, {n:"Picha 6",s:"./magufuli6.jpeg"} ]
                        delegate: Rectangle {
                            width: (parent.width - Math.round(8*dp)) / 2; height: width * 0.72
                            radius: Math.round(10*dp); color: "#1a1a1a"; border.color: Qt.rgba(0.79,0.66,0.30,0.15); border.width: 1; clip: true
                            Image { anchors.fill: parent; fillMode: Image.PreserveAspectCrop; source: modelData.s }
                            Column { anchors.centerIn: parent; visible: modelData.s === ""; spacing: Math.round(3*dp)
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "\uD83D\uDDBC"; font.pointSize: Math.round(18*dp) }
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.n; font.pointSize: Math.round(7*dp); color: goldDim }
                            }
                        }
                    }
                }


            }
        }
    }
}
