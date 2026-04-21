// ─────────────────────────────────────────────────────────────────────────────
//  Copyright 2026 - MagabeLab (Tanzania). All Rights Reserved.
//  Author: Edwin Magabe
//  Kamusi ya Kiswahili-Kiingereza | Swahili-English Dictionary
//  Words: 996
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import Qt.labs.settings 1.0

Rectangle {
    id: app
    width:  parent ? parent.width  : 400
    height: parent ? parent.height : 800
    color:  "#020d0d"
    clip:   true

    // ── BaoGame / IQTest deep-space cyan palette ──────────────────────────────
    readonly property color iqBg0:      "#020d0d"
    readonly property color iqBg1:      "#031515"
    readonly property color iqBg2:      "#061c1c"
    readonly property color iqCard:     "#071e1e"
    readonly property color iqGold:     "#00e5ff"
    readonly property color iqGoldDim:  "#005f6b"
    readonly property color iqGoldGlow: "#80f0ff"
    readonly property color iqAccent:   "#00b8d4"
    readonly property color iqDanger:   "#ef4444"
    readonly property color iqSuccess:  "#22c55e"
    readonly property color iqTextPri:  "#ffffff"
    readonly property color iqTextSec:  "#a0d8d8"
    readonly property color iqTextDim:  "#2e7070"

    // ── Responsive sizing ─────────────────────────────────────────────────────
    readonly property real shortSide: Math.min(width, height)
    readonly property real fntSm:     Math.max(11, shortSide * 0.030)
    readonly property real fntMd:     Math.max(13, shortSide * 0.038)
    readonly property real fntLg:     Math.max(16, shortSide * 0.050)
    readonly property real fntXl:     Math.max(20, shortSide * 0.065)
    readonly property real pad:       Math.max(8,  shortSide * 0.022)
    readonly property real radius:    Math.max(10, shortSide * 0.028)
    readonly property real btnH:      Math.max(44, shortSide * 0.092)
    readonly property real rowH:      Math.max(52, shortSide * 0.120)
    readonly property real headerH:   Math.max(56, shortSide * 0.140)

    // ── App wrapper helpers ───────────────────────────────────────────────────
    function cleanParent(t) {
        return t ? t.replace(/\s*\(.*?\)\s*/g, "").trim() : "";
    }
    function isPrimaryResultsApp() { return (typeof n3ctaApp !== "undefined"); }
    function isSecondaryResultsApp() { return (typeof loader !== "undefined"); }
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

    // ── Maneno yote ───────────────────────────────────────────────────────────
    property var allWords: []

    // ── Hali ya programu ──────────────────────────────────────────────────────
    property string searchText:  ""
    property int    sortMode:    0
    property var    currentWord: null
    property bool   showDetail:  false
    property bool   langMode:    false

    // ── Hali ya upakuaji ──────────────────────────────────────────────────────
    property bool   isLoading:   false
    property string loadStatus:  ""

    // ── QSettings ────────────────────────────────────────────────────────────
    readonly property string settingsKey: "kamusi_json_cache"

    Settings { id: appSettings }

    // ── Jaza maneno kutoka JSON string ────────────────────────────────────────
    function loadWordsFromJson(jsonStr) {
        if (!jsonStr || jsonStr.trim().length === 0) return false;
        try {
            var parsed = JSON.parse(jsonStr);
            if (!Array.isArray(parsed) || parsed.length === 0) return false;
            allWords = parsed;
            rebuildFilter();
            return true;
        } catch (e) {
            return false;
        }
    }

    // ── Download JSON kutoka GitHub ───────────────────────────────────────────
    function downloadWords() {
        isLoading = true;
        loadStatus = "Inapakia kamusi...";
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://raw.githubusercontent.com/magabe26/mgb/refs/heads/master/kamusi/kamusi.json", true);
        xhr.timeout = 15000;
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;
            isLoading = false;
            if (xhr.status === 200) {
                var body = xhr.responseText;
                if (body && body.trim().length > 0) {
                    var ok = loadWordsFromJson(body);
                    if (ok) {
                        appSettings.setValue(settingsKey, body);
                        loadStatus = "";
                    } else {
                        loadStatus = "JSON batili — data si sahihi.";
                    }
                } else {
                    loadStatus = "Jibu tupu kutoka seva.";
                }
            } else {
                loadStatus = "Hitilafu ya mtandao (" + xhr.status + ")";
            }
        };
        xhr.ontimeout = function() {
            isLoading = false;
            loadStatus = "Muda umekwisha — hakuna mtandao.";
        };
        xhr.send();
    }

    // ── Anzisha ───────────────────────────────────────────────────────────────
    function initKamusi() {
        var cached = appSettings.value(settingsKey, "");
        if (cached && cached.trim().length > 0) {
            var ok = loadWordsFromJson(cached);
            if (ok) {
                loadStatus = "";
                downloadWords();
                return;
            }
        }
        downloadWords();
    }

    // ── Maneno yaliyochujwa ───────────────────────────────────────────────────
    property var filteredWords: []

    function rebuildFilter() {
        var q = searchText.trim().toLowerCase();
        var result = [];
        for (var i = 0; i < allWords.length; i++) {
            var w = allWords[i];
            if (q !== "") {
                var swMatch = w.sw.toLowerCase().indexOf(q) !== -1;
                var enMatch = w.en.toLowerCase().indexOf(q) !== -1;
                if (!swMatch && !enMatch) continue;
            }
            result.push(w);
        }
        result.sort(function(a, b) {
            if (sortMode === 1) return a.en.localeCompare(b.en);
            return a.sw.localeCompare(b.sw);
        });
        filteredWords = result;
    }

    Component.onCompleted: { initKamusi(); }
    onSearchTextChanged:   { rebuildFilter(); }
    onSortModeChanged:     { rebuildFilter(); }

    // ─────────────────────────────────────────────────────────────────────────
    //  MAIN LAYOUT  (flat — watoto wa moja kwa moja wa app)
    //
    //  app
    //  ├── Canvas          starsBg
    //  ├── Rectangle       header
    //  │     ├── Rectangle   bg gradient
    //  │     ├── Rectangle   bottom divider
    //  │     ├── Item        headerRow   (logo | title | langToggle | closeBtn)
    //  │     └── Rectangle   searchBar
    //  ├── ListView        wordList
    //  ├── Rectangle       bottomBar
    //  ├── Item            brandBar
    //  ├── Rectangle       loading overlay   (z:15)
    //  └── Rectangle       detailOverlay     (z:20)
    // ─────────────────────────────────────────────────────────────────────────

    // ── Mandharinyuma ya nyota ────────────────────────────────────────────────
    Canvas {
        id: starsBg
        anchors.fill: parent
        opacity: 0.35
        property real tick: 0
        NumberAnimation on tick { from: 0; to: 1; duration: 8000; loops: Animation.Infinite }
        onTickChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            for (var i = 0; i < 60; i++) {
                var x = ((i * 173 + 29) % width);
                var y = ((i * 97  + 53) % height);
                var r = (i % 3 === 0) ? 1.2 : 0.7;
                var alpha = 0.3 + 0.25 * Math.sin(tick * Math.PI * 2 + i * 0.7);
                ctx.beginPath();
                ctx.arc(x, y, r, 0, Math.PI * 2);
                ctx.fillStyle = Qt.rgba(0, 0.9, 1, alpha);
                ctx.fill();
            }
        }
    }

    // ── HEADER ────────────────────────────────────────────────────────────────
    Rectangle {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: headerRow.height + searchBar.height + app.pad * 2.4
        color: "transparent"
        z: 10

        // Mandharinyuma
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0.08, 0.08, 0.98) }
                GradientStop { position: 1.0; color: Qt.rgba(2/255, 13/255, 13/255, 0.85) }
            }
        }

        // Mstari wa chini
        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.3; color: Qt.rgba(0, 0.9, 1, 0.4) }
                GradientStop { position: 0.7; color: Qt.rgba(0, 0.9, 1, 0.4) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // ── Safu ya kichwa ────────────────────────────────────────────────────
        Item {
            id: headerRow
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: app.pad }
            height: app.headerH

            // Nembo
            Item {
                id: logoBox
                anchors { verticalCenter: parent.verticalCenter; left: parent.left }
                width: app.headerH * 0.80; height: app.headerH * 0.80

                Rectangle {
                    anchors.fill: parent
                    radius: width * 0.24
                    color: Qt.rgba(0, 0.9, 1, 0.06)
                    border.color: Qt.rgba(0, 0.9, 1, 0.30); border.width: 1.5
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 1.15; height: parent.height * 1.15
                    radius: width * 0.24
                    color: "transparent"
                    border.color: Qt.rgba(0, 0.9, 1, 0.10); border.width: 2
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.2; duration: 1800; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0; duration: 1800; easing.type: Easing.InOutSine }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    text: "📖"; font.pixelSize: Math.round(parent.height * 0.50)
                }
            }

            // Jina la app + takwimu
            Column {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: logoBox.right; leftMargin: app.pad * 0.9
                }
                spacing: 3

                Row {
                    spacing: 8
                    Rectangle {
                        width: 3; height: titleTxt.font.pixelSize * 0.85
                        radius: 2; color: iqGold
                        anchors.verticalCenter: parent.verticalCenter
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.3; duration: 1200; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1.0; duration: 1200; easing.type: Easing.InOutSine }
                        }
                    }
                    Text {
                        id: titleTxt
                        text: "KAMUSI"
                        font.pixelSize: app.fntXl; font.bold: true; font.letterSpacing: 4
                        color: iqGold
                        style: Text.Glow; styleColor: Qt.rgba(0, 0.9, 1, 0.40)
                    }
                }

                Row {
                    spacing: 5
                    Text {
                        text: "SW"; font.pixelSize: app.fntSm - 1; font.bold: true
                        color: Qt.rgba(0, 0.9, 1, 0.9)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "⇄"; font.pixelSize: app.fntSm - 1
                        color: Qt.rgba(0, 0.9, 1, 0.45)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "EN"; font.pixelSize: app.fntSm - 1; font.bold: true
                        color: Qt.rgba(0.7, 0.95, 1, 0.9)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        width: 1; height: 11; color: Qt.rgba(0, 0.9, 1, 0.25)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: filteredWords.length + " / " + allWords.length + " maneno"
                        font.pixelSize: app.fntSm - 1; color: iqTextDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Kitufe: badilisha lugha
            Rectangle {
                id: langToggle
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: closeBtn.left; rightMargin: app.pad * 0.6
                }
                width: app.btnH * 1.5; height: app.btnH * 0.72
                radius: height / 2
                color: langMA.pressed ? Qt.rgba(0, 0.9, 1, 0.15) : Qt.rgba(0, 0.9, 1, 0.07)
                border.color: Qt.rgba(0, 0.9, 1, 0.35); border.width: 1
                Behavior on color { ColorAnimation { duration: 80 } }
                Text {
                    anchors.centerIn: parent
                    text: app.langMode ? "EN→SW" : "SW→EN"
                    font.pixelSize: app.fntSm; font.bold: true
                    color: iqAccent; font.letterSpacing: 0.5
                }
                MouseArea {
                    id: langMA; anchors.fill: parent
                    onClicked: { app.langMode = !app.langMode; }
                }
            }

            // Kitufe: funga
            Rectangle {
                id: closeBtn
                anchors { verticalCenter: parent.verticalCenter; right: parent.right }
                width: app.btnH * 0.85; height: app.btnH * 0.85
                radius: height / 2
                color: closeMA2.pressed ? Qt.rgba(1, 0.2, 0.2, 0.25) : Qt.rgba(1, 0.15, 0.15, 0.10)
                border.color: iqDanger; border.width: 1.5
                Behavior on color { ColorAnimation { duration: 80 } }
                Text {
                    anchors.centerIn: parent
                    text: "X"; font.pixelSize: app.fntMd; font.bold: true
                    color: iqDanger
                }
                MouseArea {
                    id: closeMA2; anchors.fill: parent
                    onClicked: { app.close(); }
                }
            }
        }

        // ── Kisanduku cha kutafuta ─────────────────────────────────────────────
        Rectangle {
            id: searchBar
            anchors {
                top: headerRow.bottom; topMargin: app.pad * 0.7
                left: parent.left; right: parent.right
                leftMargin: app.pad; rightMargin: app.pad
            }
            height: app.btnH
            radius: height / 2
            color: Qt.rgba(0, 0.9, 1, 0.05)
            border.color: searchField.activeFocus ? Qt.rgba(0, 0.9, 1, 0.6) : Qt.rgba(0, 0.9, 1, 0.2)
            border.width: 1.5
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Text {
                anchors { left: parent.left; leftMargin: app.pad * 1.4; verticalCenter: parent.verticalCenter }
                text: "🔍"; font.pixelSize: app.fntMd
                visible: searchField.text.length === 0
                opacity: 0.5
            }

            TextInput {
                id: searchField
                anchors {
                    left: parent.left; leftMargin: app.pad * 3.2
                    right: clearBtn.left; rightMargin: 4
                    verticalCenter: parent.verticalCenter
                }
                text: app.searchText
                font.pixelSize: app.fntMd; color: iqTextPri
                cursorVisible: activeFocus
                onTextChanged: { app.searchText = text; }
                clip: true
            }

            Rectangle {
                id: clearBtn
                anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                width: app.btnH * 0.65; height: app.btnH * 0.65
                radius: width / 2
                visible: app.searchText.length > 0
                color: clrMA.pressed ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.07)
                Text {
                    anchors.centerIn: parent; text: "×"
                    font.pixelSize: app.fntLg; color: iqTextSec
                }
                MouseArea {
                    id: clrMA; anchors.fill: parent
                    onClicked: { searchField.text = ""; app.searchText = ""; }
                }
            }
        }
    }

    // ── ORODHA YA MANENO ──────────────────────────────────────────────────────
    ListView {
        id: wordList
        anchors {
            top: header.bottom; topMargin: 4
            left: parent.left; right: parent.right
            bottom: bottomBar.top; bottomMargin: 2
        }
        model: app.filteredWords
        spacing: 3
        clip: true
        cacheBuffer: 400

        ScrollIndicator.vertical: ScrollIndicator {
            contentItem: Rectangle {
                implicitWidth: 3; color: Qt.rgba(0, 0.9, 1, 0.35); radius: 2
            }
        }

        Text {
            anchors.centerIn: parent
            visible: app.filteredWords.length === 0 && !app.isLoading
            text: "Hakuna neno linalolingana\nNo matching word"
            color: iqTextDim; font.pixelSize: app.fntMd
            horizontalAlignment: Text.AlignHCenter
        }

        delegate: Rectangle {
            id: wordRow
            property var word: modelData
            width: wordList.width
            height: app.rowH
            color: rowMA.pressed
                   ? Qt.rgba(0, 0.9, 1, 0.11)
                   : (index % 2 === 0 ? Qt.rgba(0, 0.9, 1, 0.035) : Qt.rgba(0, 0, 0, 0.15))
            Behavior on color { ColorAnimation { duration: 80 } }

            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: 1; color: Qt.rgba(0, 0.9, 1, 0.06)
            }

            Row {
                anchors {
                    left: parent.left; leftMargin: app.pad + 6
                    right: parent.right; rightMargin: app.pad
                    verticalCenter: parent.verticalCenter
                }
                spacing: app.pad * 0.75

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3
                    width: parent.width - arrowTxt.implicitWidth - app.pad * 2

                    Text {
                        text: app.langMode ? word.en : word.sw
                        font.pixelSize: app.fntMd; font.bold: true
                        color: app.langMode ? Qt.rgba(0.82, 0.96, 1, 1) : iqGold
                        elide: Text.ElideRight; width: parent.width
                    }
                    Text {
                        text: app.langMode ? word.sw : word.en
                        font.pixelSize: app.fntSm
                        color: iqTextSec; opacity: 0.85
                        elide: Text.ElideRight; width: parent.width
                    }
                }

                Text {
                    id: arrowTxt
                    anchors.verticalCenter: parent.verticalCenter
                    text: "›"; font.pixelSize: app.fntLg
                    color: rowMA.pressed ? Qt.rgba(0, 0.9, 1, 0.8) : Qt.rgba(0, 0.9, 1, 0.25)
                    Behavior on color { ColorAnimation { duration: 80 } }
                }
            }

            MouseArea {
                id: rowMA; anchors.fill: parent
                onClicked: { app.currentWord = word; app.showDetail = true; }
            }
        }
    }

    // ── BAR YA CHINI ──────────────────────────────────────────────────────────
    Rectangle {
        id: bottomBar
        anchors { bottom: brandBar.top; left: parent.left; right: parent.right }
        height: app.btnH * 0.78
        color: Qt.rgba(0, 0.08, 0.08, 0.97)

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.4; color: Qt.rgba(0, 0.9, 1, 0.25) }
                GradientStop { position: 0.6; color: Qt.rgba(0, 0.9, 1, 0.25) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: app.pad * 0.5

            Repeater {
                model: [
                    { label: "A-Z SW", mode: 0 },
                    { label: "A-Z EN", mode: 1 }
                ]
                delegate: Rectangle {
                    property bool isActive: app.sortMode === modelData.mode
                    height: bottomBar.height * 0.72
                    width: sortLbl.implicitWidth + app.pad * 1.4
                    radius: height / 2
                    color: isActive ? Qt.rgba(0, 0.9, 1, 0.15) : (srtMA.pressed ? Qt.rgba(0, 0.9, 1, 0.08) : "transparent")
                    border.color: isActive ? iqGold : Qt.rgba(0, 0.9, 1, 0.2)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 80 } }
                    Text {
                        id: sortLbl; anchors.centerIn: parent
                        text: modelData.label; font.pixelSize: app.fntSm; font.bold: isActive
                        color: isActive ? iqGold : iqTextDim
                    }
                    MouseArea {
                        id: srtMA; anchors.fill: parent
                        onClicked: { app.sortMode = modelData.mode; }
                    }
                }
            }
        }
    }

    // ── MAGABE LAB BRANDING — music beat ─────────────────────────────────────
    Item {
        id: brandBar
        anchors {
            bottom: parent.bottom
            bottomMargin: Math.max(4, app.height * 0.008)
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width; height: 44

        property int beatIdx: 0
        property var beatAmp: [1.0, 0.4, 0.7, 0.3, 1.0, 0.5, 0.0, 0.9, 0.4, 1.0]
        property int activeLetter: -1

        Timer {
            interval: 90; repeat: true; running: true
            onTriggered: {
                brandBar.activeLetter = brandBar.beatIdx;
                brandBar.beatIdx = (brandBar.beatIdx + 1) % 10;
            }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: 100; height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: Qt.rgba(0, 0.9, 1, 0.3) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: 2

            Rectangle {
                width: 10; height: 1; radius: 1
                color: Qt.rgba(0, 1, 1, 0.25)
                anchors.verticalCenter: parent.verticalCenter
            }

            Repeater {
                model: ["M","A","G","A","B","E","·","L","A","B"]
                delegate: Item {
                    id: kLtr
                    property int idx: index
                    property bool isSpace: modelData === "·"
                    property bool active: !isSpace && (brandBar.activeLetter === idx)
                    property real amp: brandBar.beatAmp[idx]

                    width: isSpace ? 6 : kTxt.implicitWidth + 3
                    height: 38
                    anchors.verticalCenter: parent.verticalCenter

                    property real lift: active ? -(amp * 8) : 0
                    Behavior on lift { NumberAnimation { duration: 60; easing.type: Easing.OutBack } }

                    Text {
                        id: kTxt
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: kLtr.lift
                        text: modelData
                        font.pixelSize: Math.max(10, app.fntSm - 1)
                        font.bold: true
                        visible: !kLtr.isSpace
                        color: kLtr.active ? Qt.rgba(0, 1, 0.9, 1.0) : Qt.rgba(0, 0.75, 0.65, 0.65)
                        Behavior on color { ColorAnimation { duration: 80 } }
                        scale: kLtr.active ? (1.0 + kLtr.amp * 0.35) : 1.0
                        Behavior on scale { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                    }

                    Rectangle {
                        visible: !kLtr.isSpace
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 2
                        height: kLtr.active ? (kLtr.amp * 5 + 1) : 1
                        radius: 1
                        color: kLtr.active ? iqAccent : Qt.rgba(0, 1, 1, 0.18)
                        Behavior on height { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                        Behavior on color  { ColorAnimation { duration: 80 } }
                    }
                }
            }

            Rectangle {
                width: 10; height: 1; radius: 1
                color: Qt.rgba(0, 1, 1, 0.25)
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  LOADING / ERROR OVERLAY  (z: 15)
    // ─────────────────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.75)
        visible: app.isLoading || (app.allWords.length === 0 && app.loadStatus.length > 0)
        z: 15

        Column {
            anchors.centerIn: parent
            spacing: app.pad

            Rectangle {
                id: spinner
                anchors.horizontalCenter: parent.horizontalCenter
                width: 48; height: 48; radius: 24
                color: "transparent"
                border.color: iqGold; border.width: 3
                visible: app.isLoading
                Rectangle {
                    width: 12; height: 12; radius: 6
                    color: iqGold
                    anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: -5 }
                }
                RotationAnimation on rotation {
                    from: 0; to: 360; duration: 900
                    loops: Animation.Infinite; running: app.isLoading
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: app.loadStatus
                color: app.isLoading ? iqTextSec : iqDanger
                font.pixelSize: app.fntMd
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                width: Math.min(app.width - 48, 300)
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !app.isLoading && app.allWords.length === 0
                width: retryLbl.implicitWidth + app.pad * 2; height: app.btnH * 0.85
                radius: height / 2
                color: retryMA.pressed ? Qt.rgba(0, 0.9, 1, 0.2) : Qt.rgba(0, 0.9, 1, 0.08)
                border.color: iqAccent; border.width: 1.5
                Behavior on color { ColorAnimation { duration: 80 } }
                Text {
                    id: retryLbl; anchors.centerIn: parent
                    text: "🔄 Jaribu Tena"
                    font.pixelSize: app.fntMd; font.bold: true; color: iqAccent
                }
                MouseArea { id: retryMA; anchors.fill: parent; onClicked: { app.downloadWords(); } }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  DETAIL OVERLAY  (z: 20)
    // ─────────────────────────────────────────────────────────────────────────
    Rectangle {
        id: detailOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.82)
        visible: app.showDetail && app.currentWord !== null
        z: 20

        MouseArea { anchors.fill: parent; onClicked: { app.showDetail = false; } }

        Rectangle {
            id: detailCard
            anchors.centerIn: parent
            width:  app.width  - app.pad * 2
            height: Math.min(app.height * 0.90, detailFlick.contentHeight + app.pad * 3)
            radius: app.radius * 1.5
            color: iqCard
            border.color: iqGold; border.width: 2
            clip: true

            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: parent.height * 0.35; radius: parent.radius
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0, 0.9, 1, 0.09) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 3; radius: parent.radius
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.2; color: iqGold }
                    GradientStop { position: 0.8; color: iqAccent }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            MouseArea { anchors.fill: parent }

            Flickable {
                id: detailFlick
                anchors { fill: parent; margins: app.pad * 1.2 }
                contentWidth: width
                contentHeight: detailCol.implicitHeight + app.pad
                clip: true
                ScrollIndicator.vertical: ScrollIndicator {
                    contentItem: Rectangle { implicitWidth: 3; color: Qt.rgba(0, 0.9, 1, 0.4); radius: 2 }
                }

                Column {
                    id: detailCol
                    width: detailFlick.width
                    spacing: app.pad

                    Item { width: 1; height: app.pad * 0.5 }

                    Column {
                        width: parent.width
                        spacing: app.pad * 0.4
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: app.currentWord ? app.currentWord.sw : ""
                            font.pixelSize: app.fntXl * 1.15; font.bold: true; font.letterSpacing: 2
                            color: iqGold
                            style: Text.Glow; styleColor: Qt.rgba(0, 0.9, 1, 0.35)
                            wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
                            width: parent.width
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: app.currentWord ? app.currentWord.en : ""
                            font.pixelSize: app.fntLg; font.bold: true
                            color: Qt.rgba(0.82, 0.96, 1, 1)
                            wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
                            width: parent.width
                        }
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width * 0.7; height: 1
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.5; color: Qt.rgba(0, 0.9, 1, 0.25) }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    // ── Mfano wa sentensi ─────────────────────────────────────
                    Column {
                        width: parent.width
                        spacing: app.pad * 0.5
                        visible: app.currentWord && (app.currentWord.ex_sw || app.currentWord.ex_en)

                        Text {
                            text: "📝 Mfano"
                            font.pixelSize: app.fntSm - 1; font.bold: true; font.letterSpacing: 1.5
                            color: Qt.rgba(0, 0.9, 1, 0.45)
                        }

                        Rectangle {
                            width: parent.width
                            height: exCol.implicitHeight + app.pad * 1.2
                            radius: app.radius * 0.7
                            color: Qt.rgba(0, 0.9, 1, 0.04)
                            border.color: Qt.rgba(0, 0.9, 1, 0.12); border.width: 1

                            Column {
                                id: exCol
                                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: app.pad * 0.9 }
                                spacing: 6

                                Text {
                                    width: parent.width
                                    visible: app.currentWord && app.currentWord.ex_sw
                                    text: app.currentWord ? (app.currentWord.ex_sw || "") : ""
                                    font.pixelSize: app.fntSm; color: iqGold; opacity: 0.9
                                    wrapMode: Text.WordWrap; font.italic: true
                                }
                                Text {
                                    width: parent.width
                                    visible: app.currentWord && app.currentWord.ex_en
                                    text: app.currentWord ? (app.currentWord.ex_en || "") : ""
                                    font.pixelSize: app.fntSm; color: iqTextSec; opacity: 0.8
                                    wrapMode: Text.WordWrap; font.italic: true
                                }
                            }
                        }
                    }

                    // ── Kategoria ─────────────────────────────────────────────
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        visible: app.currentWord && app.currentWord.cat

                        Text {
                            text: "🏷"
                            font.pixelSize: app.fntSm
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: app.currentWord ? (app.currentWord.cat || "") : ""
                            font.pixelSize: app.fntSm; font.bold: true; font.letterSpacing: 1
                            color: Qt.rgba(0.7, 0.95, 1, 0.55)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width * 0.7; height: 1
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.5; color: Qt.rgba(0, 0.9, 1, 0.15) }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 12

                        Rectangle {
                            width: Math.max(130, app.width * 0.32); height: app.btnH
                            radius: height / 2
                            color: backMA.pressed ? Qt.rgba(0, 0.9, 1, 0.20) : Qt.rgba(0, 0.9, 1, 0.08)
                            border.color: iqAccent; border.width: 1.5
                            Behavior on color { ColorAnimation { duration: 80 } }
                            Text {
                                anchors.centerIn: parent; text: "← RUDI"
                                font.pixelSize: app.fntMd; font.bold: true
                                color: iqAccent; font.letterSpacing: 1
                            }
                            MouseArea { id: backMA; anchors.fill: parent; onClicked: { app.showDetail = false; } }
                        }

                        Rectangle {
                            width: Math.max(130, app.width * 0.32); height: app.btnH
                            radius: height / 2
                            color: detCloseMA.pressed ? Qt.rgba(1, 0.2, 0.2, 0.22) : Qt.rgba(1, 0.15, 0.15, 0.09)
                            border.color: iqDanger; border.width: 1.5
                            Behavior on color { ColorAnimation { duration: 80 } }
                            Text {
                                anchors.centerIn: parent; text: "❌ FUNGA"
                                font.pixelSize: app.fntMd; font.bold: true
                                color: iqDanger; font.letterSpacing: 1
                            }
                            MouseArea { id: detCloseMA; anchors.fill: parent; onClicked: { app.close(); } }
                        }
                    }

                    Item { width: 1; height: app.pad }
                }
            }
        }

        NumberAnimation {
            id: detailIn
            target: detailCard
            property: "scale"
            from: 0.88; to: 1.0
            duration: 180; easing.type: Easing.OutBack
            running: app.showDetail
        }
    }
}
