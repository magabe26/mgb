// ─────────────────────────────────────────────────────────────────────────────
//  Copyright 2026 - MagabeLab (Tanzania). All Rights Reserved.
//  Author Edwin Magabe
//
//
//  Mpangilio wa ubao (safu 0-3, nguzo 0-7):
//    safu 0  AI  safu ya nje  (juu)
//    safu 1  AI  safu ya ndani
//    safu 2  Mchezaji safu ya ndani
//    safu 3  Mchezaji safu ya nje  (chini)
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14

Rectangle {
    id: app
    width:  parent ? parent.width  : 400
    height: parent ? parent.height : 800
    color: "#0a0800"

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

    // ── Vipimo vya kujibu ────────────────────────────────────────────────────
    readonly property real shortSide: Math.min(width, height)
    readonly property real appGap:    Math.max(4, Math.round(shortSide * 0.013))
    readonly property real holeSize:  Math.floor((shortSide - appGap * 9 - 24) / 8)
    readonly property real touchMin:  44
    readonly property real fntHole:   Math.max(11, holeSize * 0.30)
    readonly property real fntUI:     Math.max(13, shortSide * 0.038)
    readonly property real fntTitle:  Math.max(16, shortSide * 0.055)
    readonly property real badgeH:    Math.max(touchMin, shortSide * 0.085)
    readonly property real statusH:   Math.max(56, shortSide * 0.14)
    readonly property real btnH:      Math.max(touchMin, shortSide * 0.092)

    // ── Hali ya mchezo ───────────────────────────────────────────────────────
    readonly property int appCols: 8
    // Mchezaji = 1 (chini), AI = 2 (juu)
    readonly property int human: 1
    readonly property int ai:    2

    property var    board:           []
    property int    currentPlayer:   human
    property bool   plantingPhase:   true
    property int    p1Hand:          16
    property int    p2Hand:          16
    property string statusMsg:       ""
    property string subMsg:          ""
    property bool   gameOver:        false
    property int    winner:          0
    property int    lastCapture:     0
    property bool   aiThinking:      false
    property int    aiLevel:         0
    property bool   showLevelScreen: true

    // ── Msaada wa mantiki ────────────────────────────────────────────────────
    function idx(r, c) {
        return r * appCols + c;
    }
    function innerRow(p) {
        return p === human ? 2 : 1;
    }
    function outerRow(p) {
        return p === human ? 3 : 0;
    }
    function isMyRow(r, p) {
        return p === human ? (r === 2 || r === 3) : (r === 0 || r === 1);
    }
    function handOf(p) {
        return p === human ? p1Hand : p2Hand;
    }
    function setHand(p, v) {
        if (p === human) p1Hand = v; else p2Hand = v;
    }

    function seedColor(n) {
        if (n === 0)  return "#1c0e04";
        if (n <= 3)   return "#7A4A26";
        if (n <= 7)   return "#B87428";
        if (n <= 12)  return "#D4921C";
        return "#F0BC1E";
    }

    // ── Anzisha ubao ─────────────────────────────────────────────────────────
    function initBoard() {
        var b = [];
        for (var i = 0; i < 32; i++) b.push(0);
        board = b;
        currentPlayer = human;
        plantingPhase = true;
        p1Hand = 16;
        p2Hand = 16;
        gameOver = false;
        winner = 0;
        lastCapture = 0;
        aiThinking = false;
        showLevelScreen = false;
        refreshStatus();
    }

    function refreshStatus() {
        if (gameOver) return;
        var mimi = currentPlayer === human;
        if (plantingPhase) {
            statusMsg = mimi ? "Zamu yako  —  Awamu ya Kupanda"
                             : "Magabe AI inachagua  —  Awamu ya Kupanda";
            subMsg = mimi
                ? "Gusa safu yako ya ndani  •  mbegu " + handOf(human) + " zimebaki"
                : "Subiri Magabe AI ipande mbegu zake...";
        } else {
            statusMsg = mimi ? "Zamu yako  —  Awamu ya Kupiga"
                             : "Magabe AI inafikiria...";
            subMsg = mimi
                ? (lastCapture > 0
                    ? "Umetwaa mbegu " + lastCapture + "! Gusa shimo lenye mbegu 2+"
                    : "Gusa shimo lolote lenye mbegu 2 au zaidi")
                : levelLabel(aiLevel) + " inacheza...";
        }
    }

    function levelLabel(lv) {
        if (lv === 0) return "Magabe AI (Rahisi)";
        if (lv === 1) return "Magabe AI (Wastani)";
        return "Magabe AI (Ngumu)";
    }

    // ── Piga mbegu (sow) ─────────────────────────────────────────────────────
    function sowSeeds(b, startIdx, player) {
        var seeds = b[startIdx];
        if (seeds === 0) return null;
        var nb = b.slice();
        nb[startIdx] = 0;

        var ir  = innerRow(player);
        var or_ = outerRow(player);
        var circuit = [];
        for (var c = 0; c < appCols; c++)         circuit.push(idx(ir,  c));
        for (var c2 = appCols - 1; c2 >= 0; c2--) circuit.push(idx(or_, c2));

        var pos = -1;
        for (var i = 0; i < circuit.length; i++) {
            if (circuit[i] === startIdx) { pos = i; break; }
        }
        if (pos === -1) return null;

        var landIdx = -1;
        while (seeds > 0) {
            pos = (pos + 1) % circuit.length;
            nb[circuit[pos]]++;
            seeds--;
            landIdx = circuit[pos];
        }

        var captures = 0;
        var landRow = Math.floor(landIdx / appCols);
        var landCol = landIdx % appCols;
        var oppIR   = innerRow(player === human ? ai : human);
        if (landRow === ir && nb[landIdx] > 1) {
            var oppH = idx(oppIR, landCol);
            if (nb[oppH] > 0) {
                captures = nb[oppH];
                nb[oppH] = 0;
                nb[landIdx] += captures;
                var relay = nb[landIdx];
                nb[landIdx] = 0;
                pos = circuit.indexOf(landIdx);
                while (relay > 0) {
                    pos = (pos + 1) % circuit.length;
                    nb[circuit[pos]]++;
                    relay--;
                }
            }
        }
        return { newBoard: nb, captures: captures };
    }

    function canMove(player) {
        var ir  = innerRow(player);
        var or_ = outerRow(player);
        for (var c = 0; c < appCols; c++) {
            if (board[idx(ir, c)] > 1 || board[idx(or_, c)] > 1) return true;
        }
        return handOf(player) > 0;
    }

    function checkGameOver() {
        var over = false;
        if (!canMove(human)) {
            gameOver = true;
            winner = ai;
            statusMsg = "Magabe AI Imeshinda! 🤖";
            subMsg = "Huna mwendo wowote. Jaribu tena!";
            over = true;
        }
        if (!canMove(ai)) {
            gameOver = true;
            winner = human;
            statusMsg = "Umeshinda! 🎉";
            subMsg = "Magabe AI haina mwendo wowote. Hongera!";
            over = true;
        }
        if(over){
            app.ad();
        }
        return over;
    }

    // ── Mchezaji agusa shimo ─────────────────────────────────────────────────
    function onHoleTapped(row, col) {
        if (gameOver || currentPlayer !== human || aiThinking) return;
        if (!isMyRow(row, human)) { subMsg = "Hiyo si upande wako!"; return; }
        var h = idx(row, col);

        if (plantingPhase) {
            if (row !== innerRow(human)) { subMsg = "Panda kwenye safu yako ya ndani tu"; return; }
            if (handOf(human) <= 0)      { subMsg = "Hakuna mbegu zilizobaki mkononi"; return; }
            var nb = board.slice();
            nb[h]++;
            board = nb;
            setHand(human, handOf(human) - 1);
            if (p1Hand === 0 && p2Hand === 0) {
                plantingPhase = false;
                currentPlayer = human;
                lastCapture = 0;
                if (!checkGameOver()) refreshStatus();
                return;
            }
            currentPlayer = ai;
            refreshStatus();
            aiPlantTimer.start();
            return;
        }

        if (board[h] < 2) { subMsg = "Unahitaji mbegu 2 au zaidi kupiga"; return; }
        var res = sowSeeds(board, h, human);
        if (!res) { subMsg = "Mwendo batili"; return; }
        board = res.newBoard;
        lastCapture = res.captures;
        if (checkGameOver()) return;
        currentPlayer = ai;
        refreshStatus();
        aiMoveTimer.start();
    }

    // ── Panda haraka ─────────────────────────────────────────────────────────
    function autoPlant() {
        if (currentPlayer !== human || aiThinking) return;
        var nb  = board.slice();
        var ir1 = innerRow(human);
        var ir2 = innerRow(ai);
        var ph1 = Math.floor(p1Hand / appCols);
        var ph2 = Math.floor(p2Hand / appCols);
        for (var c = 0; c < appCols; c++) {
            nb[idx(ir1, c)] += ph1;
            nb[idx(ir2, c)] += ph2;
        }
        for (var c2 = 0; c2 < p1Hand - ph1 * appCols; c2++) nb[idx(ir1, c2)]++;
        for (var c3 = 0; c3 < p2Hand - ph2 * appCols; c3++) nb[idx(ir2, c3)]++;
        p1Hand = 0;
        p2Hand = 0;
        board = nb;
        plantingPhase = false;
        currentPlayer = human;
        lastCapture = 0;
        if (!checkGameOver()) refreshStatus();
    }

    // ── Timer ya AI kupanda ──────────────────────────────────────────────────
    Timer {
        id: aiPlantTimer
        interval: 600
        repeat: false
        onTriggered: {
            if (gameOver) return;
            var ir = innerRow(ai);
            var choices = [];
            for (var c = 0; c < appCols; c++) choices.push(c);

            var col;
            if (aiLevel === 0) {
                col = choices[Math.floor(Math.random() * choices.length)];
            } else {
                var bestCol   = choices[Math.floor(Math.random() * choices.length)];
                var bestScore = -999;
                for (var i = 0; i < choices.length; i++) {
                    var sc = aiLevel === 2 ? -board[idx(ir, choices[i])] : Math.random() * 2;
                    if (sc > bestScore) { bestScore = sc; bestCol = choices[i]; }
                }
                col = bestCol;
            }

            var nb = board.slice();
            nb[idx(ir, col)]++;
            board = nb;
            setHand(ai, handOf(ai) - 1);

            if (p1Hand === 0 && p2Hand === 0) {
                plantingPhase = false;
                currentPlayer = human;
                lastCapture = 0;
                if (!checkGameOver()) refreshStatus();
                return;
            }
            currentPlayer = human;
            refreshStatus();
        }
    }

    // ── Timer ya AI kupiga ───────────────────────────────────────────────────
    Timer {
        id: aiMoveTimer
        interval: aiLevel === 0 ? 700 : (aiLevel === 1 ? 900 : 1100)
        repeat: false
        onTriggered: {
            if (gameOver) return;
            aiThinking = true;
            var move = chooseAiMove();
            aiThinking = false;
            if (move === -1) { checkGameOver(); return; }
            var res = sowSeeds(board, move, ai);
            if (!res) { checkGameOver(); return; }
            board = res.newBoard;
            lastCapture = res.captures;
            if (checkGameOver()) return;
            currentPlayer = human;
            refreshStatus();
        }
    }

    // ── Akili bandia: chagua mwendo bora ────────────────────────────────────
    function chooseAiMove() {
        var ir  = innerRow(ai);
        var or_ = outerRow(ai);
        var moves = [];
        for (var c = 0; c < appCols; c++) {
            if (board[idx(ir,  c)] >= 2) moves.push(idx(ir,  c));
            if (board[idx(or_, c)] >= 2) moves.push(idx(or_, c));
        }
        if (moves.length === 0) return -1;

        if (aiLevel === 0) {
            return moves[Math.floor(Math.random() * moves.length)];
        }

        if (aiLevel === 1) {
            var best    = -1;
            var bestCap = 0;
            for (var i = 0; i < moves.length; i++) {
                var res = sowSeeds(board, moves[i], ai);
                if (res && res.captures > bestCap) { bestCap = res.captures; best = moves[i]; }
            }
            if (best !== -1) return best;
            return moves[Math.floor(Math.random() * moves.length)];
        }

        return minimaxBestMove();
    }

    function evaluateBoard(b) {
        var score = 0;
        var ir1 = innerRow(human);
        var or1 = outerRow(human);
        var ir2 = innerRow(ai);
        var or2 = outerRow(ai);
        var aiSeeds    = 0;
        var humanSeeds = 0;
        for (var c = 0; c < appCols; c++) {
            aiSeeds    += b[idx(ir2, c)] + b[idx(or2, c)];
            humanSeeds += b[idx(ir1, c)] + b[idx(or1, c)];
        }
        score += (aiSeeds - humanSeeds) * 2;
        for (var c2 = 0; c2 < appCols; c2++) {
            if (b[idx(ir2, c2)] >= 2) score += 1;
            if (b[idx(or2, c2)] >= 2) score += 1;
        }
        return score;
    }

    function getMovesFor(b, player) {
        var ir  = innerRow(player);
        var or_ = outerRow(player);
        var mvs = [];
        for (var c = 0; c < appCols; c++) {
            if (b[idx(ir,  c)] >= 2) mvs.push(idx(ir,  c));
            if (b[idx(or_, c)] >= 2) mvs.push(idx(or_, c));
        }
        return mvs;
    }

    function minimaxBestMove() {
        var moves = getMovesFor(board, ai);
        if (moves.length === 0) return -1;
        var bestMove  = moves[0];
        var bestScore = -99999;
        for (var i = 0; i < moves.length; i++) {
            var res = sowSeeds(board, moves[i], ai);
            if (!res) continue;
            var sc = res.captures * 5 + minimaxHuman(res.newBoard, 1);
            if (sc > bestScore) { bestScore = sc; bestMove = moves[i]; }
        }
        return bestMove;
    }

    function minimaxHuman(b, depth) {
        if (depth <= 0) return evaluateBoard(b);
        var moves = getMovesFor(b, human);
        if (moves.length === 0) return 1000;
        var worst = 99999;
        for (var i = 0; i < moves.length; i++) {
            var res = sowSeeds(b, moves[i], human);
            if (!res) continue;
            var sc = evaluateBoard(res.newBoard) - res.captures * 4;
            if (sc < worst) worst = sc;
        }
        return worst;
    }

    Component.onCompleted: { /* onyesha skrini ya kiwango kwanza */ }

    // ── Mandhari ─────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0c0700" }
            GradientStop { position: 1.0; color: "#1e1000" }
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    //  SKRINI YA KIWANGO
    // ════════════════════════════════════════════════════════════════════════
    Rectangle {
        id: levelScreen
        visible: app.showLevelScreen
        anchors.fill: parent
        color: "transparent"

        MouseArea { anchors.fill: parent }

        Column {
            anchors.centerIn: parent
            spacing: Math.max(14, app.height * 0.025)
            width: Math.min(app.width - 48, 340)

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🇹🇿"
                    font.pixelSize: Math.round(app.holeSize * 1.1)
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "BAO LA WASWAHILI"
                    color: "#D4A853"
                    font.pixelSize: app.fntTitle
                    font.bold: true; font.letterSpacing: 3
                    style: Text.Outline; styleColor: "#4a2006"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Mchezaji dhidi ya Magabe AI"
                    color: "#8a6030"
                    font.pixelSize: Math.max(12, app.fntUI - 1)
                    font.letterSpacing: 1
                }
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.7; height: 1
                color: "#3a2008"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Chagua Kiwango cha Magabe AI"
                color: "#C4884A"
                font.pixelSize: app.fntUI; font.bold: true
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                width: parent.width

                // Rahisi
                Rectangle {
                    width: parent.width; height: app.btnH * 1.25
                    radius: 16
                    color: lvEasyMA.pressed ? "#1a3010" : "#0e2008"
                    border.color: "#3a8020"; border.width: 2
                    Behavior on color { ColorAnimation { duration: 80 } }
                    MouseArea {
                        id: lvEasyMA; anchors.fill: parent
                        onClicked: { app.aiLevel = 0; app.initBoard(); }
                    }
                    Row {
                        anchors.centerIn: parent; spacing: 12
                        Text { text: "🌱"; font.pixelSize: app.fntUI + 4; anchors.verticalCenter: parent.verticalCenter }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter; spacing: 1
                            Text { text: "RAHISI";              color: "#70C040"; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 2 }
                            Text { text: "AI inacheza nasibu";  color: "#507030"; font.pixelSize: Math.max(10, app.fntUI - 3) }
                        }
                    }
                }

                // Wastani
                Rectangle {
                    width: parent.width; height: app.btnH * 1.25
                    radius: 16
                    color: lvMedMA.pressed ? "#2a1800" : "#1a1000"
                    border.color: "#C48020"; border.width: 2
                    Behavior on color { ColorAnimation { duration: 80 } }
                    MouseArea {
                        id: lvMedMA; anchors.fill: parent
                        onClicked: { app.aiLevel = 1; app.initBoard(); }
                    }
                    Row {
                        anchors.centerIn: parent; spacing: 12
                        Text { text: "🌿"; font.pixelSize: app.fntUI + 4; anchors.verticalCenter: parent.verticalCenter }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter; spacing: 1
                            Text { text: "WASTANI";                  color: "#E09030"; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 2 }
                            Text { text: "AI hunasa mbegu ikiweza";  color: "#806020"; font.pixelSize: Math.max(10, app.fntUI - 3) }
                        }
                    }
                }

                // Ngumu
                Rectangle {
                    width: parent.width; height: app.btnH * 1.25
                    radius: 16
                    color: lvHardMA.pressed ? "#300a0a" : "#200606"
                    border.color: "#C02020"; border.width: 2
                    Behavior on color { ColorAnimation { duration: 80 } }
                    MouseArea {
                        id: lvHardMA; anchors.fill: parent
                        onClicked: { app.aiLevel = 2; app.initBoard(); }
                    }
                    Row {
                        anchors.centerIn: parent; spacing: 12
                        Text { text: "🔥"; font.pixelSize: app.fntUI + 4; anchors.verticalCenter: parent.verticalCenter }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter; spacing: 1
                            Text { text: "NGUMU";                       color: "#E04040"; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 2 }
                            Text { text: "AI hutumia mkakati wa kina";  color: "#804040"; font.pixelSize: Math.max(10, app.fntUI - 3) }
                        }
                    }
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    //  UBAO WA MCHEZO
    // ════════════════════════════════════════════════════════════════════════
    Column {
        id: mainCol
        visible: !app.showLevelScreen
        anchors {
            top: parent.top; topMargin: Math.max(8, app.height * 0.012)
            left: parent.left; leftMargin: 12
            right: parent.right; rightMargin: 12
        }
        spacing: Math.max(4, app.height * 0.007)

        // Kichwa + beji ya kiwango
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            Text {
                text: "BAO LA WASWAHILI"
                font.pixelSize: app.fntTitle; font.bold: true; font.letterSpacing: 3
                color: "#D4A853"; style: Text.Outline; styleColor: "#4a2006"
                anchors.verticalCenter: parent.verticalCenter
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                height: Math.max(22, app.fntTitle * 0.72)
                width: lvBadgeTxt.implicitWidth + 16; radius: height / 2
                color: app.aiLevel === 0 ? "#0e2008" : (app.aiLevel === 1 ? "#1a1000" : "#200606")
                border.color: app.aiLevel === 0 ? "#3a8020" : (app.aiLevel === 1 ? "#C48020" : "#C02020")
                border.width: 1
                Text {
                    id: lvBadgeTxt; anchors.centerIn: parent
                    text: app.aiLevel === 0 ? "🌱 Rahisi" : (app.aiLevel === 1 ? "🌿 Wastani" : "🔥 Ngumu")
                    color: app.aiLevel === 0 ? "#70C040" : (app.aiLevel === 1 ? "#E09030" : "#E04040")
                    font.pixelSize: Math.max(10, app.fntUI - 3); font.bold: true
                }
                MouseArea { anchors.fill: parent; onClicked: app.showLevelScreen = true; }
            }
        }

        // ── Beji ya AI (juu) ──────────────────────────────────────────────────
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width, 320); height: app.badgeH
            radius: height / 2
            color:        app.currentPlayer === app.ai && !app.gameOver ? "#0e1a28" : "#080e14"
            border.color: app.currentPlayer === app.ai && !app.gameOver ? "#3090E0" : "#182030"
            border.width: app.currentPlayer === app.ai ? 2 : 1
            Behavior on color        { ColorAnimation { duration: 220 } }
            Behavior on border.color { ColorAnimation { duration: 220 } }
            Row {
                anchors.centerIn: parent; spacing: 12
                Text {
                    text: "🤖  Magabe AI"
                    color: app.currentPlayer === app.ai ? "#5AB0FF" : "#304060"
                    font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 1.5
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 1; height: parent.parent.height * 0.45
                    color: "#182030"; anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "✋ " + app.p2Hand
                    color: "#406080"; font.pixelSize: app.fntUI
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    visible: app.aiThinking || (app.currentPlayer === app.ai && !app.gameOver)
                    width: 10; height: 10; radius: 5
                    color: "#3090E0"; anchors.verticalCenter: parent.verticalCenter
                    SequentialAnimation on opacity {
                        running: app.currentPlayer === app.ai && !app.gameOver && !app.showLevelScreen
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.0; duration: 400 }
                        NumberAnimation { to: 0.1; duration: 400 }
                    }
                }
            }
        }

        // ── Ubao ─────────────────────────────────────────────────────────────
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            readonly property real bw: app.holeSize * 8 + app.appGap * 9 + 10
            readonly property real bh: app.holeSize * 4 + app.appGap * 5 + 10
            width: bw; height: bh
            radius: 14; color: "#3A1A00"
            border.color: "#8B5826"; border.width: 3
            Rectangle {
                anchors { fill: parent; margins: 3 }
                radius: 11; color: "transparent"
                border.color: "#0c0500"; border.width: 2
            }
            Grid {
                anchors.centerIn: parent
                rows: 4; columns: 8
                rowSpacing: app.appGap; columnSpacing: app.appGap
                Repeater {
                    model: 32
                    delegate: Item {
                        id: cell
                        readonly property int  hRow:    Math.floor(index / 8)
                        readonly property int  hCol:    index % 8
                        readonly property int  seeds:   app.board.length > index ? app.board[index] : 0
                        readonly property bool isP1:    hRow === 2 || hRow === 3
                        readonly property bool isAi:    hRow === 0 || hRow === 1
                        readonly property bool isInner: (isP1 && hRow === 2) || (!isP1 && hRow === 1)
                        readonly property bool validMove:
                            !app.gameOver && !app.aiThinking &&
                            app.currentPlayer === app.human && isP1 &&
                            (app.plantingPhase
                                ? isInner && app.handOf(app.human) > 0
                                : seeds >= 2)

                        width: app.holeSize; height: app.holeSize

                        // Mwanga wa mwendo halali
                        Rectangle {
                            visible: cell.validMove
                            anchors { fill: parent; margins: -3 }
                            radius: (app.holeSize + 6) / 2
                            color: "transparent"
                            border.color: "#FFD060"; border.width: 2
                            SequentialAnimation on opacity {
                                running: cell.validMove; loops: Animation.Infinite
                                NumberAnimation { to: 1.0; duration: 550; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 0.3; duration: 550; easing.type: Easing.InOutSine }
                            }
                        }

                        // Mwanga wa AI inafikiria
                        Rectangle {
                            visible: cell.isAi && app.currentPlayer === app.ai && !app.gameOver
                            anchors { fill: parent; margins: -2 }
                            radius: (app.holeSize + 4) / 2
                            color: "transparent"
                            border.color: Qt.rgba(0.2, 0.55, 0.9, 0.35); border.width: 1
                        }

                        // Shimo
                        Rectangle {
                            id: holeBody
                            anchors.fill: parent
                            radius: app.holeSize / 2
                            color: app.seedColor(cell.seeds)
                            Behavior on color { ColorAnimation { duration: 220 } }
                            Rectangle {
                                anchors.fill: parent; radius: parent.radius; color: "transparent"
                                border.color: Qt.rgba(0, 0, 0, 0.5); border.width: 2
                            }
                            Rectangle {
                                anchors { top: parent.top; left: parent.left; margins: app.holeSize * 0.1 }
                                width: app.holeSize * 0.28; height: app.holeSize * 0.14
                                radius: height / 2; color: Qt.rgba(1, 1, 1, 0.13); rotation: -25
                            }
                            Text {
                                anchors.centerIn: parent
                                text: cell.seeds > 0 ? cell.seeds : ""
                                color: cell.seeds > 10 ? "#160800" : "#FFF4E0"
                                font.pixelSize: app.fntHole; font.bold: true
                            }
                        }

                        // Alama ya safu ya ndani
                        Rectangle {
                            visible: cell.isInner
                            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 3 }
                            width:  Math.max(8, app.holeSize * 0.14)
                            height: Math.max(4, app.holeSize * 0.08)
                            radius: height / 2
                            color:  cell.isP1 ? "#E05828" : "#2890E0"
                            opacity: 0.85
                        }

                        // Flash ya mguso
                        Rectangle {
                            id: pressFlash
                            anchors.fill: parent; radius: app.holeSize / 2
                            color: Qt.rgba(1, 1, 1, 0.18); visible: false
                        }

                        MouseArea {
                            readonly property real ext: Math.max(0, (app.touchMin - app.holeSize) / 2)
                            anchors { fill: parent; margins: -ext }
                            enabled: cell.isP1
                            onPressed:  pressFlash.visible = true
                            onReleased: pressFlash.visible = false
                            onCanceled: pressFlash.visible = false
                            onClicked:  app.onHoleTapped(cell.hRow, cell.hCol)
                        }
                    }
                }
            }
        }

        // ── Beji ya Mchezaji (chini) ──────────────────────────────────────────
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width, 320); height: app.badgeH
            radius: height / 2
            color:        app.currentPlayer === app.human && !app.gameOver ? "#2c1600" : "#140a00"
            border.color: app.currentPlayer === app.human && !app.gameOver ? "#D4A853" : "#381c00"
            border.width: app.currentPlayer === app.human ? 2 : 1
            Behavior on color        { ColorAnimation { duration: 220 } }
            Behavior on border.color { ColorAnimation { duration: 220 } }
            Row {
                anchors.centerIn: parent; spacing: 12
                Text {
                    text: "▼  WEWE"
                    color: app.currentPlayer === app.human ? "#D4A853" : "#604020"
                    font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 1.5
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 1; height: parent.parent.height * 0.45
                    color: "#3a1e00"; anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "✋ " + app.p1Hand
                    color: "#A07030"; font.pixelSize: app.fntUI
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // ── Paneli ya Hali ────────────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: app.statusH
            radius: 12
            color:        app.gameOver ? "#2a1400" : "#160b00"
            border.color: app.gameOver ? "#D4A853" : "#2e1600"
            border.width: app.gameOver ? 2 : 1
            Column {
                anchors.centerIn: parent; spacing: 3; width: parent.width - 20
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: app.statusMsg
                    color: app.gameOver ? "#FFD060" : (app.currentPlayer === app.ai ? "#5AB0FF" : "#C08040")
                    font.pixelSize: app.fntUI; font.bold: true
                    wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter; width: parent.width
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: app.subMsg
                    color: "#7a4c28"; font.pixelSize: Math.max(11, app.fntUI - 2)
                    wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter; width: parent.width
                }
            }
        }

        // ── Vitufe ────────────────────────────────────────────────────────────
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Rectangle {
                width: Math.round(app.width * 0.28); height: app.btnH; radius: height / 2
                color: ngMA.pressed ? "#7a5020" : "#4a2e0c"
                border.color: "#D4A853"; border.width: 2
                Behavior on color { ColorAnimation { duration: 80 } }
                Text {
                    anchors.centerIn: parent; text: "⟳  MPYA"
                    color: "#D4A853"; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 1
                }
                MouseArea { id: ngMA; anchors.fill: parent; onClicked: app.showLevelScreen = true; }
            }

            Rectangle {
                visible: app.plantingPhase && !app.gameOver && app.currentPlayer === app.human
                width: Math.round(app.width * 0.32); height: app.btnH; radius: height / 2
                color: apMA.pressed ? "#3a2808" : "#201408"
                border.color: "#6a4818"; border.width: 1
                Behavior on color { ColorAnimation { duration: 80 } }
                Text {
                    anchors.centerIn: parent; text: "⚡ HARAKA"
                    color: "#8a6030"; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 0.5
                }
                MouseArea { id: apMA; anchors.fill: parent; onClicked: app.autoPlant(); }
            }

            Rectangle {
                width: Math.round(app.width * 0.28); height: app.btnH; radius: height / 2
                color: closeMA.pressed ? "#3a0808" : "#200606"
                border.color: "#C02020"; border.width: 1
                Behavior on color { ColorAnimation { duration: 80 } }
                Text {
                    anchors.centerIn: parent; text: "✕  FUNGA"
                    color: "#E04040"; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 1
                }
                MouseArea { id: closeMA; anchors.fill: parent; onClicked: app.close(); }
            }
        }

        // Beji ya Awamu
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            height: Math.max(28, app.btnH * 0.60)
            width: phaseLbl.implicitWidth + 28; radius: height / 2
            color:        app.plantingPhase ? "#101c08" : "#10081e"
            border.color: app.plantingPhase ? "#387016" : "#502896"; border.width: 1
            Text {
                id: phaseLbl; anchors.centerIn: parent
                text:  app.plantingPhase ? "🌱  AWAMU YA KUPANDA" : "🌀  AWAMU YA KUPIGA"
                color: app.plantingPhase ? "#68B030" : "#9858D8"
                font.pixelSize: Math.max(11, app.fntUI - 2); font.bold: true; font.letterSpacing: 1
            }
        }

    } // Column ya mchezo

    // ════════════════════════════════════════════════════════════════════════
    //  SKRINI YA USHINDI
    // ════════════════════════════════════════════════════════════════════════
    Rectangle {
        visible: app.gameOver && !app.showLevelScreen
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.80)
        MouseArea { anchors.fill: parent }

        Rectangle {
            anchors.centerIn: parent
            width:  Math.min(app.width - 48, 360)
            height: winnerCol.implicitHeight + 52
            radius: 22; color: "#1e0e00"
            border.color: app.winner === app.human ? "#D4A853" : "#3090E0"
            border.width: 3

            Column {
                id: winnerCol
                anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 24 }
                spacing: 16

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: app.winner === app.human ? "🏆" : "🤖"
                    font.pixelSize: Math.round(app.holeSize * 0.9)
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: app.winner === app.human ? "UMESHINDA!" : "MAGABE AI IMESHINDA!"
                    color: app.winner === app.human ? "#FFD060" : "#5AB0FF"
                    font.pixelSize: Math.max(20, app.fntTitle * 0.85)
                    font.bold: true; font.letterSpacing: 3
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: app.subMsg; color: "#8a5828"
                    font.pixelSize: app.fntUI
                    wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
                    width: Math.min(app.width - 80, 300)
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Kiwango: " + app.levelLabel(app.aiLevel)
                    color: app.aiLevel === 0 ? "#70C040" : (app.aiLevel === 1 ? "#E09030" : "#E04040")
                    font.pixelSize: Math.max(11, app.fntUI - 2)
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    Rectangle {
                        width: Math.max(130, app.width * 0.35); height: app.btnH; radius: height / 2
                        color: ctMA.pressed ? "#7a5020" : "#4a2e0c"
                        border.color: "#D4A853"; border.width: 2
                        Behavior on color { ColorAnimation { duration: 80 } }
                        Text {
                            anchors.centerIn: parent; text: "CHEZA TENA"
                            color: "#D4A853"; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 1
                        }
                        MouseArea { id: ctMA; anchors.fill: parent; onClicked: app.initBoard(); }
                    }

                    Rectangle {
                        width: Math.max(130, app.width * 0.35); height: app.btnH; radius: height / 2
                        color: bkMA.pressed ? "#1a1008" : "#100c04"
                        border.color: "#6a4818"; border.width: 1
                        Behavior on color { ColorAnimation { duration: 80 } }
                        Text {
                            anchors.centerIn: parent; text: "BADILISHA"
                            color: "#8a6030"; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 1
                        }
                        MouseArea { id: bkMA; anchors.fill: parent; onClicked: app.showLevelScreen = true; }
                    }
                }
                Item { width: 1; height: 4 }
            }
        }
    }
}
