// ─────────────────────────────────────────────────────────────────────────────
//  Copyright 2026 - MagabeLab (Tanzania). All Rights Reserved.
//  Author: Edwin Magabe
//  Kamusi ya Kiswahili-Kiingereza | Swahili-English Dictionary
//  Words: 2768+
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

    // ── Neno la Siku ──────────────────────────────────────────────────────────
    property var    wordOfDay:      null
    property bool   wotdRevealed:   false

    function pickWordOfDay() {
        if (!allWords || allWords.length === 0) return;
        // Tumia tarehe ya leo kama mbegu ili neno libadilike kila siku
        var d = new Date();
        var seed = d.getFullYear() * 10000 + (d.getMonth() + 1) * 100 + d.getDate();
        var idx  = seed % allWords.length;
        wordOfDay    = allWords[idx];
        wotdRevealed = false;
    }

    // ── Hali ya programu ──────────────────────────────────────────────────────
    property string searchText:  ""
    property int    sortMode:    0
    property var    currentWord: null
    property bool   showDetail:  false
    property bool   langMode:    false

    // ── Quiz Mode ─────────────────────────────────────────────────────────────
    property bool   showQuiz:       false
    property var    quizQuestion:   null    // neno linaloulizwa
    property var    quizChoices:    []      // maneno 4 (pamoja na jibu sahihi)
    property int    quizAnswered:   -1      // index ya jibu lililobonyezwa (-1 = halijibwa)
    property bool   quizSwToEn:     true   // true = onyesha SW, jibu EN; false = kinyume
    property int    quizScore:      0
    property int    quizTotal:      0
    property int    quizStreak:     0
    property int    quizBestStreak: 0

    function quizShuffle(arr) {
        var a = arr.slice();
        for (var i = a.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var tmp = a[i]; a[i] = a[j]; a[j] = tmp;
        }
        return a;
    }

    function quizNext() {
        if (!allWords || allWords.length < 4) return;
        quizAnswered = -1;
        // Chagua neno la kuuliza
        var qIdx = Math.floor(Math.random() * allWords.length);
        var correct = allWords[qIdx];
        // Chagua majibu 3 ya uwongo tofauti na jibu sahihi
        var pool = [];
        var tries = 0;
        while (pool.length < 3 && tries < 200) {
            tries++;
            var r = Math.floor(Math.random() * allWords.length);
            if (r === qIdx) continue;
            var dup = false;
            for (var k = 0; k < pool.length; k++) {
                if (pool[k] === r) { dup = true; break; }
            }
            if (!dup) pool.push(r);
        }
        var choices = [correct];
        for (var p = 0; p < pool.length; p++) { choices.push(allWords[pool[p]]); }
        quizQuestion = correct;
        quizChoices  = quizShuffle(choices);
    }

    function quizAnswer(idx) {
        if (quizAnswered !== -1) return;
        quizAnswered = idx;
        quizTotal++;
        if (quizChoices[idx] === quizQuestion) {
            quizScore++;
            quizStreak++;
            if (quizStreak > quizBestStreak) quizBestStreak = quizStreak;
        } else {
            quizStreak = 0;
        }
    }

    function quizStart() {
        quizScore      = 0;
        quizTotal      = 0;
        quizStreak     = 0;
        quizBestStreak = 0;
        quizSwToEn     = true;
        quizNext();
        showQuiz = true;
    }

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
            pickWordOfDay();
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
        buildAlphaIndex();
    }

    // ── Alphabet Index ────────────────────────────────────────────────────────
    // Ramani: herufi → index ya kwanza katika filteredWords
    property var alphaIndexMap: ({})

    function buildAlphaIndex() {
        var map = {};
        for (var i = 0; i < filteredWords.length; i++) {
            var w = filteredWords[i];
            var key = langMode ? w.en : w.sw;
            if (!key || key.length === 0) continue;
            var ch = key[0].toUpperCase();
            if (!(ch in map)) map[ch] = i;
        }
        alphaIndexMap = map;
    }

    function jumpToLetter(ch) {
        if (ch in alphaIndexMap) {
            wordList.positionViewAtIndex(alphaIndexMap[ch], ListView.Beginning);
        }
    }

    onLangModeChanged: { buildAlphaIndex(); }

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
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0
                        Text {
                            id: titleTxt
                            text: "KAMUSI"
                            font.pixelSize: app.fntXl; font.bold: true; font.letterSpacing: 4
                            color: iqGold
                            style: Text.Glow; styleColor: Qt.rgba(0, 0.9, 1, 0.40)
                        }
                        Text {
                            text: "Dictionary"
                            font.pixelSize: app.fntSm - 2; font.italic: true; font.letterSpacing: 1
                            color: Qt.rgba(0, 0.9, 1, 0.40)
                        }
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

    // ── NENO LA SIKU ──────────────────────────────────────────────────────────
    Rectangle {
        id: wotdCard
        anchors {
            top: header.bottom; topMargin: 6
            left: parent.left; leftMargin: app.pad
            right: parent.right; rightMargin: app.pad
        }
        height: app.wordOfDay ? wotdInner.implicitHeight + app.pad * 1.6 : 0
        visible: app.wordOfDay !== null
        radius: app.radius
        color: Qt.rgba(0, 0.9, 1, 0.055)
        border.color: Qt.rgba(0, 0.9, 1, 0.28); border.width: 1.5
        clip: true
        z: 5

        // Shimmer ya juu
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 2; radius: parent.radius
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.35; color: Qt.rgba(0, 0.9, 1, 0.55) }
                GradientStop { position: 0.65; color: Qt.rgba(0, 0.9, 1, 0.55) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // Mwanga wa mandharinyuma
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: parent.height * 0.5; radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0.9, 1, 0.045) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Column {
            id: wotdInner
            anchors {
                top: parent.top; topMargin: app.pad * 0.9
                left: parent.left; leftMargin: app.pad * 1.1
                right: wotdArrow.left; rightMargin: app.pad * 0.5
            }
            spacing: 4

            // Kichwa — lebo "Neno la Siku"
            Row {
                spacing: 6
                Rectangle {
                    width: 3; height: 11; radius: 2; color: iqGold
                    anchors.verticalCenter: parent.verticalCenter
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.25; duration: 900; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0;  duration: 900; easing.type: Easing.InOutSine }
                    }
                }
                Text {
                    text: "✨ NENO LA SIKU"
                    font.pixelSize: app.fntSm - 2; font.bold: true; font.letterSpacing: 2
                    color: Qt.rgba(0, 0.9, 1, 0.50)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Neno kuu la Kiswahili
            Text {
                text: app.wordOfDay ? app.wordOfDay.sw : ""
                font.pixelSize: app.fntLg * 1.05; font.bold: true; font.letterSpacing: 1
                color: iqGold
                style: Text.Glow; styleColor: Qt.rgba(0, 0.9, 1, 0.30)
                width: parent.width
                elide: Text.ElideRight
            }

            // Tafsiri ya Kiingereza — inafichwa mpaka mtumiaji abonyeze
            Item {
                width: parent.width
                height: enRevealRow.implicitHeight

                Row {
                    id: enRevealRow
                    spacing: 6

                    Text {
                        visible: app.wotdRevealed
                        text: app.wordOfDay ? app.wordOfDay.en : ""
                        font.pixelSize: app.fntMd; color: Qt.rgba(0.82, 0.96, 1, 0.92)
                        elide: Text.ElideRight
                        width: wotdInner.width - 60
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        visible: !app.wotdRevealed
                        width: Math.min(160, wotdInner.width - 20)
                        height: app.fntMd + 4; radius: 4
                        color: Qt.rgba(0, 0.9, 1, 0.10)
                        border.color: Qt.rgba(0, 0.9, 1, 0.22); border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "Gusa kuona tafsiri"
                            font.pixelSize: app.fntSm - 2; color: Qt.rgba(0, 0.9, 1, 0.40)
                            font.italic: true
                        }
                    }
                }
            }

            // Mfano — inaonekana tu baada ya kufunua
            Text {
                visible: app.wotdRevealed && app.wordOfDay && app.wordOfDay.ex_sw
                text: app.wordOfDay ? ("📝 " + (app.wordOfDay.ex_sw || "")) : ""
                font.pixelSize: app.fntSm - 1; font.italic: true
                color: Qt.rgba(0, 0.9, 1, 0.52)
                width: parent.width; wrapMode: Text.WordWrap
            }

            Item { width: 1; height: 2 }
        }

        // Mshale wa kulia / kitufe cha maelezo kamili
        Text {
            id: wotdArrow
            anchors { right: parent.right; rightMargin: app.pad * 0.9; verticalCenter: parent.verticalCenter }
            text: "›"; font.pixelSize: app.fntXl
            color: wotdMA.pressed ? Qt.rgba(0, 0.9, 1, 0.9) : Qt.rgba(0, 0.9, 1, 0.30)
            Behavior on color { ColorAnimation { duration: 80 } }
        }

        MouseArea {
            id: wotdMA
            anchors.fill: parent
            onClicked: {
                if (!app.wotdRevealed) {
                    app.wotdRevealed = true;
                } else {
                    app.currentWord = app.wordOfDay;
                    app.showDetail  = true;
                }
            }
        }

        // Mstari wa kupumzika chini
        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 1; color: Qt.rgba(0, 0.9, 1, 0.08)
        }
    }

    // ── ORODHA YA MANENO ──────────────────────────────────────────────────────
    ListView {
        id: wordList
        anchors {
            top: wotdCard.bottom; topMargin: 4
            left: parent.left
            right: alphaBar.left; rightMargin: 2
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

    // ── ALPHABET INDEX BAR ────────────────────────────────────────────────────
    Item {
        id: alphaBar
        anchors {
            top: wotdCard.bottom; topMargin: 4
            right: parent.right; rightMargin: 2
            bottom: bottomBar.top; bottomMargin: 2
        }
        width: Math.max(18, app.shortSide * 0.048)
        z: 6
        clip: true

        // herufi za alfabeti
        property var letters: ["A","B","C","D","E","F","G","H","I","J","K","L","M",
                               "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

        // Lebo inayoelea inayoonekana wakati wa kugusa
        property string hoverLetter: ""
        property bool   hoverVisible: false

        Timer {
            id: hoverHide; interval: 700; repeat: false
            onTriggered: { alphaBar.hoverVisible = false; alphaBar.hoverLetter = ""; }
        }

        Column {
            anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            spacing: 0

            Repeater {
                model: alphaBar.letters
                delegate: Item {
                    id: alphaCell
                    property string ch: modelData
                    property bool   hasWords: ch in app.alphaIndexMap
                    width: alphaBar.width
                    height: alphaBar.height / alphaBar.letters.length

                    Rectangle {
                        anchors.centerIn: parent
                        width: alphaBar.width - 2; height: width; radius: width / 2
                        color: alphaMA.pressed ? Qt.rgba(0, 0.9, 1, 0.25)
                               : (alphaCell.hasWords ? Qt.rgba(0, 0.9, 1, 0.06) : "transparent")
                        Behavior on color { ColorAnimation { duration: 80 } }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: Math.max(8, alphaBar.width * 0.52)
                        font.bold: alphaCell.hasWords
                        color: alphaMA.pressed    ? iqGold
                               : alphaCell.hasWords ? iqAccent
                               : Qt.rgba(0, 0.9, 1, 0.18)
                        Behavior on color { ColorAnimation { duration: 80 } }
                    }

                    MouseArea {
                        id: alphaMA
                        anchors.fill: parent
                        onPressed: {
                            if (alphaCell.hasWords) {
                                app.jumpToLetter(alphaCell.ch);
                                alphaBar.hoverLetter  = alphaCell.ch;
                                alphaBar.hoverVisible = true;
                                hoverHide.restart();
                            }
                        }
                        // Drag: ruka bila ku-lift kidole
                        onPositionChanged: {
                            if (!pressed) return;
                            var mapped = mapToItem(alphaBar, mouseX, mouseY);
                            var idx = Math.floor(mapped.y / (alphaBar.height / alphaBar.letters.length));
                            idx = Math.max(0, Math.min(alphaBar.letters.length - 1, idx));
                            var targetCh = alphaBar.letters[idx];
                            if (targetCh in app.alphaIndexMap) {
                                app.jumpToLetter(targetCh);
                                alphaBar.hoverLetter  = targetCh;
                                alphaBar.hoverVisible = true;
                                hoverHide.restart();
                            }
                        }
                    }
                }
            }
        }

        // Lebo inayoelea (popup ya herufi inayoonekana kushoto)
        Rectangle {
            id: alphaPopup
            visible: alphaBar.hoverVisible && alphaBar.hoverLetter !== ""
            anchors { right: alphaBar.left; rightMargin: 6; verticalCenter: parent.verticalCenter }
            width: app.fntXl + 14; height: width; radius: width * 0.22
            color: iqGoldDim
            border.color: iqGold; border.width: 1.5
            z: 20

            Text {
                anchors.centerIn: parent
                text: alphaBar.hoverLetter
                font.pixelSize: app.fntXl * 0.85; font.bold: true
                color: iqGold
                style: Text.Glow; styleColor: Qt.rgba(0, 0.9, 1, 0.50)
            }

            SequentialAnimation on scale {
                running: alphaBar.hoverVisible
                NumberAnimation { to: 1.15; duration: 80; easing.type: Easing.OutBack }
                NumberAnimation { to: 1.00; duration: 80 }
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

        // A-Z chips — kushoto
        Row {
            anchors { left: parent.left; leftMargin: app.pad; verticalCenter: parent.verticalCenter }
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

        // Kitufe cha Quiz — kulia
        Rectangle {
            anchors { right: parent.right; rightMargin: app.pad; verticalCenter: parent.verticalCenter }
            height: bottomBar.height * 0.72
            width: quizBarLbl.implicitWidth + app.pad * 1.6
            radius: height / 2
            color: quizBarMA.pressed ? Qt.rgba(1, 0.85, 0, 0.22) : Qt.rgba(1, 0.85, 0, 0.10)
            border.color: "#ffd700"; border.width: 1
            Behavior on color { ColorAnimation { duration: 80 } }
            Text {
                id: quizBarLbl; anchors.centerIn: parent
                text: "🎯 MCHEZO"
                font.pixelSize: app.fntSm; font.bold: true
                color: "#ffd700"
            }
            MouseArea {
                id: quizBarMA; anchors.fill: parent
                onClicked: {
                    if (app.allWords.length >= 4) { app.quizStart(); }
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
    //  DETAIL OVERLAY  (z: 20)  — Bottom Sheet style
    // ─────────────────────────────────────────────────────────────────────────
    Rectangle {
        id: detailOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0)
        visible: app.showDetail && app.currentWord !== null
        z: 20

        // Dimming ya mandharinyuma — inaonekana polepole
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.75)
            opacity: detailSheet.sheetOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 280 } }
        }

        MouseArea {
            anchors { top: parent.top; left: parent.left; right: parent.right; bottom: detailSheet.top }
            onClicked: { detailSheet.sheetOpen = false; }
        }

        // ── Bottom Sheet ──────────────────────────────────────────────────────
        Rectangle {
            id: detailSheet
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: Math.min(app.height * 0.88, sheetInnerCol.implicitHeight + heroSection.height + app.pad * 3)
            radius: app.radius * 2
            color: iqCard
            clip: true

            property bool sheetOpen: false

            // Slide-in ya chini kwenda juu
            transform: Translate {
                y: detailSheet.sheetOpen ? 0 : detailSheet.height
                Behavior on y { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
            }

            onSheetOpenChanged: {
                if (!sheetOpen) {
                    // Subiri animation imalize kisha ficha overlay
                    closeTimer.restart();
                }
            }

            Timer {
                id: closeTimer; interval: 330; repeat: false
                onTriggered: { app.showDetail = false; }
            }

            // ── Hero Section — rangi kulingana na herufi ──────────────────────
            Rectangle {
                id: heroSection
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: app.height * 0.22
                radius: parent.radius
                clip: true

                // Rangi ya hero inatokana na herufi ya kwanza ya neno
                property string firstLetter: app.currentWord ? app.currentWord.sw[0].toUpperCase() : "A"
                property color heroColor: {
                    var ch = firstLetter;
                    if      ("ABCD".indexOf(ch) >= 0) return Qt.rgba(0.00, 0.70, 0.80, 1);
                    else if ("EFGH".indexOf(ch) >= 0) return Qt.rgba(0.10, 0.60, 0.50, 1);
                    else if ("IJKL".indexOf(ch) >= 0) return Qt.rgba(0.20, 0.50, 0.85, 1);
                    else if ("MNOP".indexOf(ch) >= 0) return Qt.rgba(0.55, 0.25, 0.85, 1);
                    else if ("QRST".indexOf(ch) >= 0) return Qt.rgba(0.85, 0.40, 0.10, 1);
                    else                               return Qt.rgba(0.15, 0.65, 0.55, 1);
                }

                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(heroSection.heroColor.r, heroSection.heroColor.g, heroSection.heroColor.b, 0.55) }
                    GradientStop { position: 1.0; color: Qt.rgba(heroSection.heroColor.r, heroSection.heroColor.g, heroSection.heroColor.b, 0.08) }
                }

                // Mstari wa shimmer juu
                Rectangle {
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: 3; radius: parent.radius
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.3; color: Qt.rgba(heroSection.heroColor.r, heroSection.heroColor.g, heroSection.heroColor.b, 0.9) }
                        GradientStop { position: 0.7; color: Qt.rgba(heroSection.heroColor.r, heroSection.heroColor.g, heroSection.heroColor.b, 0.9) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                // ── Herufi kubwa ya mandharinyuma (watermark) ─────────────────
                Text {
                    anchors { right: parent.right; rightMargin: app.pad * 0.5; verticalCenter: parent.verticalCenter }
                    text: heroSection.firstLetter
                    font.pixelSize: heroSection.height * 1.1; font.bold: true
                    color: Qt.rgba(heroSection.heroColor.r, heroSection.heroColor.g, heroSection.heroColor.b, 0.18)
                    style: Text.Outline
                    styleColor: Qt.rgba(heroSection.heroColor.r, heroSection.heroColor.g, heroSection.heroColor.b, 0.10)
                }

                // Drag handle juu ya kadi — mdogo
                Rectangle {
                    anchors { top: parent.top; topMargin: app.pad * 0.7; horizontalCenter: parent.horizontalCenter }
                    width: 36; height: 4; radius: 2
                    color: Qt.rgba(1, 1, 1, 0.30)
                }

                // Neno kuu la Kiswahili
                Column {
                    anchors {
                        left: parent.left; leftMargin: app.pad * 1.4
                        right: parent.right; rightMargin: app.pad * 1.4
                        bottom: parent.bottom; bottomMargin: app.pad * 1.1
                    }
                    spacing: 6

                    // Kiswahili — cyan mkali (iqGold)
                    Text {
                        text: app.currentWord ? app.currentWord.sw : ""
                        font.pixelSize: app.fntXl * 1.1; font.bold: true; font.letterSpacing: 2
                        color: "#00e5ff"
                        style: Text.Glow
                        styleColor: Qt.rgba(0, 0.9, 1, 0.55)
                        wrapMode: Text.WordWrap; width: parent.width
                    }

                    Rectangle {
                        width: parent.width * 0.35; height: 1
                        color: Qt.rgba(0, 0.9, 1, 0.25)
                    }

                    // Kiingereza — cyan hafifu (iqTextSec)
                    Text {
                        text: app.currentWord ? app.currentWord.en : ""
                        font.pixelSize: app.fntLg; font.bold: true
                        color: "#a0d8d8"
                        style: Text.Glow
                        styleColor: Qt.rgba(0, 0.9, 1, 0.18)
                        wrapMode: Text.WordWrap; width: parent.width
                    }
                }

                // X — funga — juu kulia
                Rectangle {
                    anchors { top: parent.top; topMargin: app.pad * 0.8; right: parent.right; rightMargin: app.pad * 0.8 }
                    width: app.btnH * 0.72; height: width; radius: width / 2
                    color: xMA.pressed ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(1, 1, 1, 0.12)
                    Behavior on color { ColorAnimation { duration: 80 } }
                    Text { anchors.centerIn: parent; text: "X"; font.pixelSize: app.fntMd; font.bold: true; color: "white" }
                    MouseArea { id: xMA; anchors.fill: parent; onClicked: { detailSheet.sheetOpen = false; } }
                }
            }

            // ── Maudhui ya chini (scrollable) ─────────────────────────────────
            Flickable {
                anchors {
                    top: heroSection.bottom
                    left: parent.left; right: parent.right; bottom: parent.bottom
                    margins: app.pad * 1.2
                }
                contentWidth: width
                contentHeight: sheetInnerCol.implicitHeight + app.pad
                clip: true
                ScrollIndicator.vertical: ScrollIndicator {
                    contentItem: Rectangle { implicitWidth: 3; color: Qt.rgba(0, 0.9, 1, 0.4); radius: 2 }
                }

                Column {
                    id: sheetInnerCol
                    width: parent.width
                    spacing: app.pad

                    Item { width: 1; height: app.pad * 0.3 }

                    // ── Ornament divider ──────────────────────────────────────
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8

                        Rectangle {
                            width: app.width * 0.18; height: 1
                            anchors.verticalCenter: parent.verticalCenter
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 1.0; color: Qt.rgba(0, 0.9, 1, 0.35) }
                            }
                        }
                        Repeater {
                            model: 3
                            Rectangle {
                                width: 4; height: 4; radius: 2
                                anchors.verticalCenter: parent.verticalCenter
                                color: Qt.rgba(0, 0.9, 1, index === 1 ? 0.7 : 0.30)
                            }
                        }
                        Rectangle {
                            width: app.width * 0.18; height: 1
                            anchors.verticalCenter: parent.verticalCenter
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: Qt.rgba(0, 0.9, 1, 0.35) }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
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

                    Item { width: 1; height: app.pad * 2 }
                }
            }
        }

        // Fungua sheet mara inapoonekana
        onVisibleChanged: {
            if (visible) { detailSheet.sheetOpen = true; }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  QUIZ OVERLAY  (z: 30)
    // ─────────────────────────────────────────────────────────────────────────
    Rectangle {
        id: quizOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0.04, 0.06, 0.96)
        visible: app.showQuiz
        opacity: 0
        z: 30

        // Mandharinyuma ya nyota
        Canvas {
            anchors.fill: parent; opacity: 0.18
            property real t: 0
            NumberAnimation on t { from: 0; to: 1; duration: 10000; loops: Animation.Infinite }
            onTChanged: requestPaint()
            onPaint: {
                var ctx = getContext("2d"); ctx.clearRect(0, 0, width, height);
                for (var i = 0; i < 40; i++) {
                    var x = (i * 211 + 17) % width; var y = (i * 131 + 37) % height;
                    var a = 0.25 + 0.2 * Math.sin(t * Math.PI * 2 + i * 0.9);
                    ctx.beginPath(); ctx.arc(x, y, 0.8, 0, Math.PI * 2);
                    ctx.fillStyle = Qt.rgba(0, 0.9, 1, a); ctx.fill();
                }
            }
        }

        NumberAnimation {
            id: quizIn
            target: quizOverlay
            property: "opacity"
            from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic
            running: app.showQuiz
        }

        // ── Maudhui ya Quiz ───────────────────────────────────────────────────
        Flickable {
            anchors { fill: parent; margins: app.pad }
            contentWidth: width
            contentHeight: quizMainCol.implicitHeight + app.pad * 2
            clip: true

            Column {
                id: quizMainCol
                width: parent.width
                spacing: app.pad * 0.8

                // ── Header ya Quiz ────────────────────────────────────────────
                Item {
                    width: parent.width; height: app.headerH * 0.85

                    Column {
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                        spacing: 4

                        Row {
                            spacing: 6
                            Text { text: "🎯"; font.pixelSize: app.fntLg; anchors.verticalCenter: parent.verticalCenter }
                            Text {
                                text: "MCHEZO WA KAMUSI"
                                font.pixelSize: app.fntMd; font.bold: true; font.letterSpacing: 2
                                color: iqGold; style: Text.Glow; styleColor: Qt.rgba(0, 0.9, 1, 0.30)
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Toggle mwelekeo wa swali
                        Rectangle {
                            height: app.btnH * 0.55
                            width: qDirLbl.implicitWidth + app.pad * 1.2
                            radius: height / 2
                            color: qDirMA.pressed ? Qt.rgba(0, 0.9, 1, 0.18) : Qt.rgba(0, 0.9, 1, 0.08)
                            border.color: Qt.rgba(0, 0.9, 1, 0.35); border.width: 1
                            Behavior on color { ColorAnimation { duration: 80 } }
                            Text {
                                id: qDirLbl; anchors.centerIn: parent
                                text: app.quizSwToEn ? "SW → EN" : "EN → SW"
                                font.pixelSize: app.fntSm - 1; font.bold: true; color: iqAccent
                            }
                            MouseArea {
                                id: qDirMA; anchors.fill: parent
                                onClicked: { app.quizSwToEn = !app.quizSwToEn; app.quizNext(); }
                            }
                        }
                    }

                    // Alama za Score
                    Column {
                        anchors { right: qCloseBtn.left; rightMargin: app.pad * 0.7; verticalCenter: parent.verticalCenter }
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: app.quizScore + " / " + app.quizTotal
                            font.pixelSize: app.fntLg; font.bold: true; color: iqGold
                        }
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 6
                            Text {
                                text: "🔥 " + app.quizStreak
                                font.pixelSize: app.fntSm
                                color: app.quizStreak >= 3 ? "#ff9500" : iqTextDim
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            Text { text: "🏆 " + app.quizBestStreak; font.pixelSize: app.fntSm; color: iqTextDim }
                        }
                    }

                    // Funga Quiz
                    Rectangle {
                        id: qCloseBtn
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        width: app.btnH * 0.80; height: app.btnH * 0.80; radius: height / 2
                        color: qCloseMA.pressed ? Qt.rgba(1, 0.2, 0.2, 0.25) : Qt.rgba(1, 0.15, 0.15, 0.10)
                        border.color: iqDanger; border.width: 1.5
                        Behavior on color { ColorAnimation { duration: 80 } }
                        Text { anchors.centerIn: parent; text: "X"; font.pixelSize: app.fntMd; font.bold: true; color: iqDanger }
                        MouseArea { id: qCloseMA; anchors.fill: parent; onClicked: { app.showQuiz = false; } }
                    }
                }

                // Mstari wa mgawanyo
                Rectangle {
                    width: parent.width; height: 1
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.3; color: Qt.rgba(0, 0.9, 1, 0.35) }
                        GradientStop { position: 0.7; color: Qt.rgba(0, 0.9, 1, 0.35) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                // ── Swali Kuu ─────────────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: qQuestionCol.implicitHeight + app.pad * 2.2
                    radius: app.radius * 1.2
                    color: Qt.rgba(0, 0.9, 1, 0.06)
                    border.color: Qt.rgba(0, 0.9, 1, 0.25); border.width: 1.5

                    Rectangle {
                        anchors { top: parent.top; left: parent.left; right: parent.right }
                        height: 2; radius: parent.radius
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.4; color: Qt.rgba(0, 0.9, 1, 0.50) }
                            GradientStop { position: 0.6; color: Qt.rgba(0, 0.9, 1, 0.50) }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    Column {
                        id: qQuestionCol
                        anchors {
                            top: parent.top; topMargin: app.pad
                            left: parent.left; right: parent.right
                        }
                        spacing: 6

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: app.quizSwToEn ? "Tafsiri ya Kiingereza ni nini?" : "Tafsiri ya Kiswahili ni nini?"
                            font.pixelSize: app.fntSm - 1; color: Qt.rgba(0, 0.9, 1, 0.45); font.letterSpacing: 1
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: app.quizQuestion
                                  ? (app.quizSwToEn ? app.quizQuestion.sw : app.quizQuestion.en)
                                  : ""
                            font.pixelSize: app.fntXl * 1.05; font.bold: true; font.letterSpacing: 1.5
                            color: iqGold; style: Text.Glow; styleColor: Qt.rgba(0, 0.9, 1, 0.35)
                            wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
                            width: parent.width - app.pad * 2
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: app.quizQuestion && app.quizQuestion.cat
                            text: app.quizQuestion ? ("🏷 " + (app.quizQuestion.cat || "")) : ""
                            font.pixelSize: app.fntSm - 2; color: Qt.rgba(0.7, 0.95, 1, 0.40); font.italic: true
                        }
                    }
                }

                // ── Majibu 4 ─────────────────────────────────────────────────
                Column {
                    width: parent.width
                    spacing: app.pad * 0.65

                    Repeater {
                        model: 4
                        delegate: Rectangle {
                            id: choiceRect
                            property int  ci:        index
                            property var  cword:     app.quizChoices.length > ci ? app.quizChoices[ci] : null
                            property bool isCorrect: cword !== null && cword === app.quizQuestion
                            property bool isChosen:  app.quizAnswered === ci
                            property bool answered:  app.quizAnswered !== -1

                            width: parent.width; height: app.btnH * 1.05
                            radius: app.radius; border.width: 1.8; clip: true

                            color: !answered
                                   ? (choiceMA.pressed ? Qt.rgba(0, 0.9, 1, 0.14) : Qt.rgba(0, 0.9, 1, 0.055))
                                   : isCorrect  ? Qt.rgba(0.13, 0.77, 0.37, 0.22)
                                   : isChosen   ? Qt.rgba(0.94, 0.27, 0.27, 0.20)
                                   : Qt.rgba(0, 0.9, 1, 0.03)

                            border.color: !answered
                                          ? (choiceMA.pressed ? Qt.rgba(0, 0.9, 1, 0.60) : Qt.rgba(0, 0.9, 1, 0.20))
                                          : isCorrect ? "#22c55e"
                                          : isChosen  ? "#ef4444"
                                          : Qt.rgba(0, 0.9, 1, 0.10)

                            Behavior on color        { ColorAnimation { duration: 160 } }
                            Behavior on border.color { ColorAnimation { duration: 160 } }

                            Row {
                                anchors {
                                    left: parent.left; leftMargin: app.pad * 0.9
                                    right: parent.right; rightMargin: app.pad * 0.9
                                    verticalCenter: parent.verticalCenter
                                }
                                spacing: app.pad * 0.7

                                // Badge A B C D
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: app.fntMd + 10; height: app.fntMd + 10; radius: width / 2
                                    color: !answered          ? Qt.rgba(0, 0.9, 1, 0.10)
                                           : isCorrect        ? Qt.rgba(0.13, 0.77, 0.37, 0.35)
                                           : isChosen         ? Qt.rgba(0.94, 0.27, 0.27, 0.30)
                                           : Qt.rgba(0, 0.9, 1, 0.05)
                                    Behavior on color { ColorAnimation { duration: 160 } }
                                    Text {
                                        anchors.centerIn: parent
                                        text: ["A","B","C","D"][index]
                                        font.pixelSize: app.fntSm; font.bold: true
                                        color: !answered ? iqAccent
                                               : isCorrect ? "#22c55e"
                                               : isChosen  ? "#ef4444"
                                               : iqTextDim
                                        Behavior on color { ColorAnimation { duration: 160 } }
                                    }
                                }

                                // Maandishi ya chaguo
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - (app.fntMd + 14) - app.pad * 0.7 - resultIco.implicitWidth - 4
                                    text: choiceRect.cword
                                          ? (app.quizSwToEn ? choiceRect.cword.en : choiceRect.cword.sw)
                                          : ""
                                    font.pixelSize: app.fntMd
                                    font.bold: choiceRect.answered && choiceRect.isCorrect
                                    color: !answered ? iqTextPri
                                           : isCorrect ? "#22c55e"
                                           : isChosen  ? "#ef4444"
                                           : iqTextDim
                                    wrapMode: Text.WordWrap
                                    Behavior on color { ColorAnimation { duration: 160 } }
                                }

                                // Ikoni matokeo
                                Text {
                                    id: resultIco
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: choiceRect.answered && (choiceRect.isCorrect || choiceRect.isChosen)
                                    text: choiceRect.isCorrect ? "✅" : "❌"
                                    font.pixelSize: app.fntMd
                                }
                            }

                            MouseArea {
                                id: choiceMA; anchors.fill: parent
                                onClicked: {
                                    if (!choiceRect.answered && choiceRect.cword !== null) {
                                        app.quizAnswer(choiceRect.ci);
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Mfano wa jibu + Kitufe cha swali jipya ───────────────────
                Row {
                    width: parent.width
                    spacing: app.pad
                    layoutDirection: Qt.RightToLeft

                    // Kitufe cha swali jipya
                    Rectangle {
                        id: nextBtn
                        height: app.btnH; width: nextLbl.implicitWidth + app.pad * 2
                        radius: height / 2
                        color: nextMA.pressed ? Qt.rgba(0, 0.9, 1, 0.22) : Qt.rgba(0, 0.9, 1, 0.10)
                        border.color: iqGold; border.width: 1.5
                        Behavior on color { ColorAnimation { duration: 80 } }
                        Text {
                            id: nextLbl; anchors.centerIn: parent
                            text: app.quizAnswered === -1 ? "Ruka ⏭" : "Jipya ▶"
                            font.pixelSize: app.fntMd; font.bold: true; color: iqGold
                        }
                        MouseArea { id: nextMA; anchors.fill: parent; onClicked: { app.quizNext(); } }
                    }

                    // Mfano wa sentensi (baada ya kujibu)
                    Rectangle {
                        visible: app.quizAnswered !== -1 && app.quizQuestion && app.quizQuestion.ex_sw
                        height: nextBtn.height
                        width: parent.width - nextBtn.width - app.pad
                        radius: app.radius * 0.8
                        color: Qt.rgba(0, 0.9, 1, 0.05)
                        border.color: Qt.rgba(0, 0.9, 1, 0.15); border.width: 1
                        Text {
                            anchors { fill: parent; margins: app.pad * 0.6 }
                            text: app.quizQuestion ? ("📝 " + (app.quizQuestion.ex_sw || "")) : ""
                            font.pixelSize: app.fntSm - 1; font.italic: true
                            color: Qt.rgba(0, 0.9, 1, 0.55)
                            wrapMode: Text.WordWrap; verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Item { width: 1; height: app.pad * 2 }
            }
        }
    }
}
