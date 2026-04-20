// ─────────────────────────────────────────────────────────────────────────────
//  Copyright 2026 - MagabeLab (Tanzania). All Rights Reserved.
//  Author: Edwin Magabe
//  Kamusi ya Kiswahili-Kiingereza | Swahili-English Dictionary
//  Words: 996  |  Categories: 21
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

    // ── Maneno yote — yanajazwa baada ya download/QSettings ──────────────────
    property var allWords: []

    // ── Hali ya programu ──────────────────────────────────────────────────────
    property string searchText:     ""
    property string filterCategory: "all"
    property string filterPOS:      ""
    property int    sortMode:       0       // 0=A-Z sw, 1=A-Z en, 2=POS
    property var    currentWord:    null    // neno lililochaguliwa (detail view)
    property bool   showDetail:     false
    property bool   langMode:       false   // false=SW→EN, true=EN→SW

    // ── Hali ya upakuaji ──────────────────────────────────────────────────────
    property bool   isLoading:      false
    property string loadStatus:     ""     // ujumbe wa hali (loading/error/ok)

    // ── QSettings key ────────────────────────────────────────────────────────
    readonly property string settingsKey: "kamusi_json_cache"

    // ── QSettings object ─────────────────────────────────────────────────────
    Settings {
        id: appSettings
    }

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

    // ── Anzisha: jaribu QSettings kwanza, kisha download ─────────────────────
    function initKamusi() {
        var cached = appSettings.value(settingsKey, "");
        if (cached && cached.trim().length > 0) {
            var ok = loadWordsFromJson(cached);
            if (ok) {
                loadStatus = "";
                // Refresh kimya kimya nyuma ili kupata data mpya
                downloadWords();
                return;
            }
        }
        // Hakuna cache — lazima tudownload
        downloadWords();
    }

    // ── Orodha ya makundi ─────────────────────────────────────────────────────
    readonly property var categories: ["all","agriculture","animal","body","clothing","color","education","emotion","family","finance","food","general","health","home","nature","religion","sport","technology","time","travel","weather","work"]
    readonly property var posLabels: {
        "noun": "Nomino", "verb": "Kitenzi", "adjective": "Kivumishi",
        "adverb": "Kielelezo", "number": "Nambari", "": "Zote"
    }
    readonly property var catEmoji: {
        "all": "📚", "general": "💬", "emotion": "❤️", "family": "👨‍👩‍👧",
        "body": "🫀", "health": "🏥", "food": "🍲", "home": "🏠",
        "nature": "🌿", "weather": "🌦️", "animal": "🦁", "travel": "✈️",
        "time": "🕐", "color": "🎨", "clothing": "👔", "work": "💼",
        "education": "📖", "sport": "⚽", "finance": "💰",
        "agriculture": "🌾", "religion": "🕌", "technology": "💻"
    }

    // ── Maneno yaliyochujwa ───────────────────────────────────────────────────
    property var filteredWords: []

    function rebuildFilter() {
        var q = searchText.trim().toLowerCase();
        var result = [];
        for (var i = 0; i < allWords.length; i++) {
            var w = allWords[i];
            if (filterCategory !== "all" && w.cat !== filterCategory) continue;
            if (filterPOS !== "" && w.pos !== filterPOS) continue;
            if (q !== "") {
                var swMatch = w.sw.toLowerCase().indexOf(q) !== -1;
                var enMatch = w.en.toLowerCase().indexOf(q) !== -1;
                if (!swMatch && !enMatch) continue;
            }
            result.push(w);
        }
        // Panga
        result.sort(function(a, b) {
            if (sortMode === 1) return a.en.localeCompare(b.en);
            if (sortMode === 2) return a.pos.localeCompare(b.pos) || a.sw.localeCompare(b.sw);
            return a.sw.localeCompare(b.sw);
        });
        filteredWords = result;
    }

    Component.onCompleted: { initKamusi(); }
    onSearchTextChanged:    { rebuildFilter(); }
    onFilterCategoryChanged:{ rebuildFilter(); }
    onFilterPOSChanged:     { rebuildFilter(); }
    onSortModeChanged:      { rebuildFilter(); }

    function posColor(pos) {
        if (pos === "verb")      return "#22c55e";
        if (pos === "noun")      return "#00e5ff";
        if (pos === "adjective") return "#f59e0b";
        if (pos === "adverb")    return "#a78bfa";
        if (pos === "number")    return "#f97316";
        return iqTextSec;
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  MAIN LAYOUT
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
            var rng = Qt.createQmlObject('import QtQuick 2.14; Item {}', app);
            // Dots za kudumu - seed-based
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
        height: app.headerH + searchBar.height + catBar.height + app.pad * 2
        color: "transparent"
        z: 10

        // Gradient ya chini ya header
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0,0.08,0.08,0.98) }
                GradientStop { position: 1.0; color: Qt.rgba(2/255,13/255,13/255,0.85) }
            }
        }

        // Mstari wa chini wa header
        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.3; color: Qt.rgba(0,0.9,1,0.4) }
                GradientStop { position: 0.7; color: Qt.rgba(0,0.9,1,0.4) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Column {
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: app.pad }
            spacing: app.pad * 0.7

            // Kichwa cha app + close button
            Item {
                width: parent.width
                height: app.headerH - app.pad

                // Nembo / icon
                Rectangle {
                    id: logoBox
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    width: app.headerH * 0.68; height: app.headerH * 0.68
                    radius: width * 0.22
                    color: Qt.rgba(0, 0.9, 1, 0.08)
                    border.color: Qt.rgba(0, 0.9, 1, 0.35); border.width: 1.5
                    Text {
                        anchors.centerIn: parent
                        text: "📖"; font.pixelSize: Math.round(parent.height * 0.52)
                    }
                }

                // Jina la app
                Column {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: logoBox.right; leftMargin: app.pad * 0.8
                    }
                    spacing: 2
                    Text {
                        text: "KAMUSI"
                        font.pixelSize: app.fntXl; font.bold: true
                        font.letterSpacing: 3
                        color: iqGold
                        style: Text.Glow; styleColor: Qt.rgba(0,0.9,1,0.35)
                    }
                    Row {
                        spacing: 6
                        Text {
                            text: "Kiswahili • English"
                            font.pixelSize: app.fntSm; color: iqTextSec
                        }
                        Rectangle {
                            width: 1; height: 12
                            color: Qt.rgba(0,0.9,1,0.3)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: filteredWords.length + " / " + allWords.length
                            font.pixelSize: app.fntSm; color: iqTextDim
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Kitufe cha kubadilisha lugha
                Rectangle {
                    id: langToggle
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: closeBtn.left; rightMargin: app.pad * 0.6
                    }
                    width: app.btnH * 1.5; height: app.btnH * 0.72
                    radius: height / 2
                    color: langMA.pressed ? Qt.rgba(0,0.9,1,0.15) : Qt.rgba(0,0.9,1,0.07)
                    border.color: Qt.rgba(0,0.9,1,0.35); border.width: 1

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
                    Behavior on color { ColorAnimation { duration: 80 } }
                }

                // Kitufe cha kufunga (CLOSE)
                Rectangle {
                    id: closeBtn
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                    }
                    width: app.btnH * 0.85; height: app.btnH * 0.85
                    radius: height / 2
                    color: closeMA2.pressed ? Qt.rgba(1,0.2,0.2,0.25) : Qt.rgba(1,0.15,0.15,0.10)
                    border.color: iqDanger; border.width: 1.5
                    Behavior on color { ColorAnimation { duration: 80 } }
                    Text {
                        anchors.centerIn: parent
                        text: "✕"; font.pixelSize: app.fntMd; font.bold: true
                        color: iqDanger
                    }
                    MouseArea {
                        id: closeMA2; anchors.fill: parent
                        onClicked: { app.close(); }
                    }
                }
            }

            // Kisanduku cha kutafuta
            Rectangle {
                id: searchBar
                width: parent.width
                height: app.btnH
                radius: height / 2
                color: Qt.rgba(0,0.9,1,0.05)
                border.color: searchField.activeFocus
                    ? Qt.rgba(0,0.9,1,0.6) : Qt.rgba(0,0.9,1,0.2)
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

                // Futa maandishi
                Rectangle {
                    id: clearBtn
                    anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                    width: app.btnH * 0.65; height: app.btnH * 0.65
                    radius: width / 2
                    visible: app.searchText.length > 0
                    color: clrMA.pressed ? Qt.rgba(1,1,1,0.15) : Qt.rgba(1,1,1,0.07)
                    Text {
                        anchors.centerIn: parent; text: "×"
                        font.pixelSize: app.fntLg; color: iqTextSec
                    }
                    MouseArea { id: clrMA; anchors.fill: parent; onClicked: { searchField.text = ""; app.searchText = ""; } }
                }
            }

            // Category filter bar
            Item {
                id: catBar
                width: parent.width
                height: app.btnH * 0.72

                ListView {
                    id: catList
                    anchors.fill: parent
                    orientation: ListView.Horizontal
                    spacing: 6
                    clip: true
                    model: app.categories
                    delegate: Rectangle {
                        property bool isActive: app.filterCategory === modelData
                        height: catBar.height
                        width: catLbl.implicitWidth + app.pad * 1.6
                        radius: height / 2
                        color: isActive
                            ? Qt.rgba(0,0.9,1,0.18)
                            : (catDelegMA.pressed ? Qt.rgba(0,0.9,1,0.10) : Qt.rgba(0,0.9,1,0.04))
                        border.color: isActive ? iqGold : Qt.rgba(0,0.9,1,0.18)
                        border.width: isActive ? 1.5 : 1
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            id: catLbl
                            anchors.centerIn: parent
                            text: (app.catEmoji[modelData] || "•") + " " + modelData
                            font.pixelSize: app.fntSm; font.bold: isActive
                            color: isActive ? iqGold : iqTextSec
                        }
                        MouseArea {
                            id: catDelegMA; anchors.fill: parent
                            onClicked: { app.filterCategory = modelData; }
                        }
                    }
                    ScrollIndicator.horizontal: ScrollIndicator {}
                }
            }
        }
    }

    // ── ORODHA YA MANENO ─────────────────────────────────────────────────────
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
                implicitWidth: 3; color: Qt.rgba(0,0.9,1,0.35); radius: 2
            }
        }

        // Kama hakuna matokeo
        Text {
            anchors.centerIn: parent
            visible: app.filteredWords.length === 0
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
                ? Qt.rgba(0,0.9,1,0.10)
                : (index % 2 === 0 ? Qt.rgba(0,0.9,1,0.03) : "transparent")
            Behavior on color { ColorAnimation { duration: 80 } }

            // Mstari wa chini (divider)
            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: app.pad; rightMargin: app.pad }
                height: 1; color: Qt.rgba(0,0.9,1,0.07)
            }

            Row {
                anchors {
                    left: parent.left; leftMargin: app.pad
                    right: parent.right; rightMargin: app.pad
                    verticalCenter: parent.verticalCenter
                }
                spacing: app.pad * 0.8

                // Beji ya POS
                Rectangle {
                    width: posTag.implicitWidth + 12
                    height: Math.max(22, app.fntSm + 8)
                    radius: height / 2
                    color: Qt.rgba(0,0,0,0.3)
                    border.color: Qt.rgba(app.posColor(word.pos).r, app.posColor(word.pos).g, app.posColor(word.pos).b, 0.4)
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        id: posTag
                        anchors.centerIn: parent
                        text: word.pos.substring(0,3).toUpperCase()
                        font.pixelSize: app.fntSm - 1; font.bold: true; font.letterSpacing: 1
                        color: app.posColor(word.pos)
                    }
                }

                // Maneno (Swahili / Kiingereza)
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    width: parent.width - posTag.implicitWidth - 24 - arrowTxt.implicitWidth - app.pad * 2

                    Text {
                        text: app.langMode ? word.en : word.sw
                        font.pixelSize: app.fntMd; font.bold: true
                        color: app.langMode ? Qt.rgba(0.8,0.95,1,1) : iqGold
                        elide: Text.ElideRight; width: parent.width
                    }
                    Text {
                        text: app.langMode ? word.sw : word.en
                        font.pixelSize: app.fntSm
                        color: iqTextSec
                        elide: Text.ElideRight; width: parent.width
                    }
                }

                // Mshale wa detail
                Text {
                    id: arrowTxt
                    anchors.verticalCenter: parent.verticalCenter
                    text: "›"; font.pixelSize: app.fntLg; color: Qt.rgba(0,0.9,1,0.3)
                }
            }

            MouseArea {
                id: rowMA; anchors.fill: parent
                onClicked: { app.currentWord = word; app.showDetail = true; }
            }
        }
    }

    // ── BAR YA CHINI (Sort + Stats) ───────────────────────────────────────────
    Rectangle {
        id: bottomBar
        anchors { bottom: brandBar.top; left: parent.left; right: parent.right }
        height: app.btnH * 0.78
        color: Qt.rgba(0,0.08,0.08,0.97)

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.4; color: Qt.rgba(0,0.9,1,0.25) }
                GradientStop { position: 0.6; color: Qt.rgba(0,0.9,1,0.25) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Row {
            anchors { centerIn: parent }
            spacing: app.pad * 0.5

            Repeater {
                model: [
                    { label: "A-Z SW", mode: 0 },
                    { label: "A-Z EN", mode: 1 },
                    { label: "AINA",   mode: 2 }
                ]
                delegate: Rectangle {
                    property bool isActive: app.sortMode === modelData.mode
                    height: bottomBar.height * 0.72
                    width: sortLbl.implicitWidth + app.pad * 1.4
                    radius: height / 2
                    color: isActive ? Qt.rgba(0,0.9,1,0.15) : (srtMA.pressed ? Qt.rgba(0,0.9,1,0.08) : "transparent")
                    border.color: isActive ? iqGold : Qt.rgba(0,0.9,1,0.2)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 80 } }
                    Text {
                        id: sortLbl; anchors.centerIn: parent
                        text: modelData.label; font.pixelSize: app.fntSm; font.bold: isActive
                        color: isActive ? iqGold : iqTextDim
                    }
                    MouseArea { id: srtMA; anchors.fill: parent; onClicked: { app.sortMode = modelData.mode; } }
                }
            }

            Rectangle { width: 1; height: parent.height * 0.6; color: Qt.rgba(0,0.9,1,0.2); anchors.verticalCenter: parent.verticalCenter }

            // Kichujio cha POS
            Repeater {
                model: [
                    { label: "ZOTE", pos: "" },
                    { label: "NOM",  pos: "noun" },
                    { label: "KIT",  pos: "verb" },
                    { label: "ADJ",  pos: "adjective" }
                ]
                delegate: Rectangle {
                    property bool isActive: app.filterPOS === modelData.pos
                    height: bottomBar.height * 0.72
                    width: posFilterLbl.implicitWidth + app.pad * 1.4
                    radius: height / 2
                    color: isActive ? Qt.rgba(0,0.9,1,0.15) : (posMA.pressed ? Qt.rgba(0,0.9,1,0.08) : "transparent")
                    border.color: isActive ? app.posColor(modelData.pos === "" ? "noun" : modelData.pos) : Qt.rgba(0,0.9,1,0.2)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 80 } }
                    Text {
                        id: posFilterLbl; anchors.centerIn: parent
                        text: modelData.label; font.pixelSize: app.fntSm; font.bold: isActive
                        color: isActive ? app.posColor(modelData.pos === "" ? "noun" : modelData.pos) : iqTextDim
                    }
                    MouseArea { id: posMA; anchors.fill: parent; onClicked: { app.filterPOS = modelData.pos; } }
                }
            }
        }
    }

    // ── MAGABE LAB BRANDING ───────────────────────────────────────────────────
    Item {
        id: brandBar
        anchors { bottom: parent.bottom; bottomMargin: Math.max(6, app.height * 0.010); horizontalCenter: parent.horizontalCenter }
        width: parent.width; height: 26

        Rectangle {
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
            width: 80; height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: Qt.rgba(0,0.9,1,0.2) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: 6
            Rectangle { width: 3; height: 3; radius: 2; color: iqGold; opacity: 0.5; anchors.verticalCenter: parent.verticalCenter }
            Text {
                text: "MAGABE LAB"
                font.pixelSize: Math.max(10, app.fntSm - 1)
                font.bold: true; font.letterSpacing: 2.5
                color: Qt.rgba(0, 0.9, 1, 0.7)
                anchors.verticalCenter: parent.verticalCenter
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.4; duration: 2200; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 2200; easing.type: Easing.InOutSine }
                }
            }
            Rectangle { width: 3; height: 3; radius: 2; color: iqGold; opacity: 0.5; anchors.verticalCenter: parent.verticalCenter }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  LOADING / ERROR OVERLAY
    // ─────────────────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0,0,0,0.75)
        visible: app.isLoading || (app.allWords.length === 0 && app.loadStatus.length > 0)
        z: 15

        Column {
            anchors.centerIn: parent
            spacing: app.pad

            // Spinner wa mzunguko
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

            // Kitufe cha kujaribu tena (kinaonyesha tu kama kuna hitilafu)
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !app.isLoading && app.allWords.length === 0
                width: retryLbl.implicitWidth + app.pad * 2; height: app.btnH * 0.85
                radius: height / 2
                color: retryMA.pressed ? Qt.rgba(0,0.9,1,0.2) : Qt.rgba(0,0.9,1,0.08)
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
    //  DETAIL OVERLAY — neno lililochaguliwa
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
            width: Math.min(app.width - 32, 380)
            height: detailCol.implicitHeight + app.pad * 3
            radius: app.radius * 1.5
            color: iqCard
            border.color: iqGold; border.width: 2

            // Mwanga wa glow juu ya kadi
            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: parent.height * 0.5; radius: parent.radius
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0,0.9,1,0.07) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            MouseArea { anchors.fill: parent } // zuia kufunga kwa kubonyeza kadi

            Column {
                id: detailCol
                anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: app.pad * 1.5; margins: app.pad * 1.2 }
                spacing: app.pad * 0.9

                // Neno kuu
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: app.currentWord ? app.currentWord.sw : ""
                    font.pixelSize: app.fntXl; font.bold: true; font.letterSpacing: 1.5
                    color: iqGold
                    style: Text.Glow; styleColor: Qt.rgba(0,0.9,1,0.3)
                    wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
                    width: parent.width
                }

                // Tafsiri ya Kiingereza
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: app.currentWord ? app.currentWord.en : ""
                    font.pixelSize: app.fntLg; font.bold: true
                    color: iqTextSec
                    wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
                    width: parent.width
                }

                // Beji za POS na Kikundi
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    Rectangle {
                        height: Math.max(26, app.fntSm + 10)
                        width: posDetailLbl.implicitWidth + 16; radius: height / 2
                        color: Qt.rgba(0,0,0,0.4)
                        border.color: app.currentWord ? app.posColor(app.currentWord.pos) : iqTextDim
                        border.width: 1.5
                        Text {
                            id: posDetailLbl; anchors.centerIn: parent
                            text: app.currentWord ? (app.posLabels[app.currentWord.pos] || app.currentWord.pos) : ""
                            font.pixelSize: app.fntSm; font.bold: true
                            color: app.currentWord ? app.posColor(app.currentWord.pos) : iqTextDim
                        }
                    }

                    Rectangle {
                        height: Math.max(26, app.fntSm + 10)
                        width: catDetailLbl.implicitWidth + 16; radius: height / 2
                        color: Qt.rgba(0,0,0,0.3)
                        border.color: Qt.rgba(0,0.9,1,0.25); border.width: 1
                        Text {
                            id: catDetailLbl; anchors.centerIn: parent
                            text: app.currentWord
                                ? ((app.catEmoji[app.currentWord.cat] || "•") + " " + app.currentWord.cat)
                                : ""
                            font.pixelSize: app.fntSm; color: iqTextSec
                        }
                    }
                }

                // Mstari
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.75; height: 1
                    color: Qt.rgba(0,0.9,1,0.18)
                }

                // Mfano wa sentensi (Kiswahili)
                Column {
                    width: parent.width
                    spacing: 4
                    visible: app.currentWord && app.currentWord.ex_sw && app.currentWord.ex_sw.length > 0

                    Text {
                        text: "Mfano:"; font.pixelSize: app.fntSm; font.bold: true
                        color: Qt.rgba(0,0.9,1,0.4); font.letterSpacing: 1
                    }
                    Rectangle {
                        width: parent.width; height: exSwTxt.implicitHeight + 14
                        radius: app.radius * 0.6
                        color: Qt.rgba(0,0.9,1,0.04)
                        border.color: Qt.rgba(0,0.9,1,0.12); border.width: 1
                        Text {
                            id: exSwTxt
                            anchors { left: parent.left; right: parent.right; margins: 10; verticalCenter: parent.verticalCenter }
                            text: app.currentWord ? app.currentWord.ex_sw : ""
                            font.pixelSize: app.fntSm; color: iqTextSec
                            wrapMode: Text.WordWrap; font.italic: true
                        }
                    }
                    Rectangle {
                        width: parent.width; height: exEnTxt.implicitHeight + 14
                        radius: app.radius * 0.6
                        color: Qt.rgba(0,0.9,1,0.03)
                        border.color: Qt.rgba(0,0.9,1,0.08); border.width: 1
                        Text {
                            id: exEnTxt
                            anchors { left: parent.left; right: parent.right; margins: 10; verticalCenter: parent.verticalCenter }
                            text: app.currentWord ? app.currentWord.ex_en : ""
                            font.pixelSize: app.fntSm; color: Qt.rgba(0.6,0.85,0.85,1)
                            wrapMode: Text.WordWrap; font.italic: true
                        }
                    }
                }

                // Vifungo
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    // Rudi
                    Rectangle {
                        width: Math.max(120, app.width * 0.28); height: app.btnH * 0.88
                        radius: height / 2
                        color: backMA.pressed ? Qt.rgba(0,0.9,1,0.18) : Qt.rgba(0,0.9,1,0.07)
                        border.color: iqAccent; border.width: 1.5
                        Behavior on color { ColorAnimation { duration: 80 } }
                        Text {
                            anchors.centerIn: parent; text: "← RUDI"
                            font.pixelSize: app.fntSm; font.bold: true
                            color: iqAccent; font.letterSpacing: 1
                        }
                        MouseArea { id: backMA; anchors.fill: parent; onClicked: { app.showDetail = false; } }
                    }

                    // Funga app
                    Rectangle {
                        width: Math.max(120, app.width * 0.28); height: app.btnH * 0.88
                        radius: height / 2
                        color: detCloseMA.pressed ? Qt.rgba(1,0.2,0.2,0.2) : Qt.rgba(1,0.15,0.15,0.08)
                        border.color: iqDanger; border.width: 1.5
                        Behavior on color { ColorAnimation { duration: 80 } }
                        Text {
                            anchors.centerIn: parent; text: "❌ FUNGA"
                            font.pixelSize: app.fntSm; font.bold: true
                            color: iqDanger; font.letterSpacing: 1
                        }
                        MouseArea { id: detCloseMA; anchors.fill: parent; onClicked: { app.close(); } }
                    }
                }

                Item { width: 1; height: app.pad * 0.3 }
            }
        }

        // Slide-in animation
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
