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
    color: "#020d0d"

    // ── IQTest deep-space cyan palette ───────────────────────────────────────
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

    // ── Hali ya animation ya kupiga (step-by-step sow) ───────────────────────
    property bool   sowAnimating:    false    // kweli wakati animation inafanya kazi
    property var    sowSteps:        []       // orodha ya hatua: [{holeIdx, delta, label}]
    property int    sowStepIdx:      0        // hatua ya sasa
    property int    activeHole:      -1       // shimo linaloangazwa sasa hivi
    property string activeArrow:     ""       // mshale wa mwelekeo
    property var    pendingResult:   null     // matokeo yaliyohesabiwa mapema

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
        if (n === 0)  return "#041414";
        if (n <= 3)   return "#005060";
        if (n <= 7)   return "#007888";
        if (n <= 12)  return "#00b8d4";
        return "#00e5ff";
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
                    ? "Gusa safu yako ya ndani  •  kete " + handOf(human) + " zimebaki"
                    : "Subiri Magabe AI ipande kete zake...";
        } else {
            statusMsg = mimi ? "Zamu yako  —  Awamu ya Kupiga"
                             : "Magabe AI inafikiria...";
            subMsg = mimi
                    ? (lastCapture > 0
                       ? "Umetwaa kete " + lastCapture + "! Gusa shimo lenye kete 2+"
                       : "Gusa shimo lolote lenye kete 2 au zaidi")
                    : levelLabel(aiLevel) + " inacheza...";
        }
    }

    function levelLabel(lv) {
        if (lv === 0) return "Magabe AI (Rahisi)";
        if (lv === 1) return "Magabe AI (Wastani)";
        return "Magabe AI (Ngumu)";
    }

    // ── Kernel wa kupiga kete — mantiki MOJA inayotumika na wote wawili ────
    // Inarudisha:  { nb, captures, landIdx, steps }
    // steps = [] kama recordSteps=false  (kwa AI evaluation)
    // steps = [...] kama recordSteps=true (kwa animation)
    // ── Kernel wa kupiga kete ──────────────────────────────────────────────
    //
    // Sheria:
    //   Chukua kete ZOTE kutoka shimo la kuanza.
    //   Zigawanye moja kwa moja kwenye circuit — BILA kusimama popote —
    //   mpaka kete ya MWISHO inapoanguka. Hapo angalia:
    //
    //   A)  Shimo TUPU          → simama, zamu inaisha
    //   B1) Nje, ina kete      → chukua zote, anza tena (relay)
    //   B2) Ndani, opp ina kete → capture: chukua opp+yako, anza tena
    //   B3) Ndani, opp tupu, ina kete → chukua zote, anza tena (relay)
    //
    // recordSteps=false  → kwa AI (haraka, hakuna animation data)
    // recordSteps=true   → kwa animation (inajaza steps[])
    function sowKernel(b, startIdx, player, recordSteps) {
        if (b[startIdx] < 1) return null;

        var ir  = innerRow(player);
        var or_ = outerRow(player);
        var circuit = [];
        for (var c = 0; c < appCols; c++)           circuit.push(idx(ir,  c));
        for (var c2 = appCols - 1; c2 >= 0; c2--)  circuit.push(idx(or_, c2));

        var nb       = b.slice();
        var steps    = [];
        var captures = 0;
        var prevH    = startIdx;
        var landIdx  = startIdx;
        var rounds   = 0;
        var MAX_ROUNDS = 300;   // kinga ya infinite loop

        function arrowBetween(fh, th) {
            var fr = Math.floor(fh / appCols), fc = fh % appCols;
            var tr = Math.floor(th / appCols), tc = th % appCols;
            if (fr === tr) return (tc > fc) ? "→" : "←";
            return (tr > fr) ? "↓" : "↑";
        }
        function pushStep(h, arrow) {
            if (recordSteps) steps.push({ holeIdx: h, board: nb.slice(), arrow: arrow });
        }
        function oppOf(h) {
            return idx(innerRow(player === human ? ai : human), h % appCols);
        }

        // Gawanya `count` kete kuanzia pos sasa, rudi landIdx ya mwisho
        function sow(src) {
            rounds++;
            if (rounds > MAX_ROUNDS) return;

            var count = nb[src];
            nb[src] = 0;

            // Pata nafasi ya src kwenye circuit
            var pos = -1;
            for (var i = 0; i < circuit.length; i++) {
                if (circuit[i] === src) { pos = i; break; }
            }
            if (pos === -1) return;

            // Weka kete ZOTE moja kwa moja bila kusimama
            for (var s = 0; s < count; s++) {
                pos = (pos + 1) % circuit.length;
                nb[circuit[pos]]++;
                landIdx = circuit[pos];
                pushStep(landIdx, arrowBetween(prevH, landIdx));
                prevH = landIdx;
            }

            // Angalia sheria kwenye shimo la MWISHO tu
            var row = Math.floor(landIdx / appCols);
            var hadSeeds = nb[landIdx] > 1;   // alikuwa na kete kabla ya seed hii

            if (!hadSeeds) {
                // Sheria A: shimo lilikuwa tupu — simama
                return;
            }

            if (row === or_) {
                // Sheria B1: nje ina kete — relay
                pushStep(landIdx, "👊");
                sow(landIdx);

            } else if (row === ir) {
                var opp = oppOf(landIdx);
                if (nb[opp] > 0) {
                    // Sheria B2: capture
                    captures += nb[opp];
                    nb[landIdx] += nb[opp];
                    nb[opp] = 0;
                    pushStep(opp,     "❌");
                    pushStep(landIdx, "⭐");
                    sow(landIdx);
                } else {
                    // Sheria B3: ndani ina kete, opp tupu — relay
                    pushStep(landIdx, "👊");
                    sow(landIdx);
                }
            }
        }

        sow(startIdx);
        return { nb: nb, captures: captures, landIdx: landIdx, steps: steps };
    }

    // ── Wrappers ─────────────────────────────────────────────────────────────
    function sowSeeds(b, startIdx, player) {
        var r = sowKernel(b, startIdx, player, false);
        if (!r) return null;
        return { newBoard: r.nb, captures: r.captures };
    }

    function buildSowSteps(b, startIdx, player) {
        var r = sowKernel(b, startIdx, player, true);
        if (!r) return null;
        return { steps: r.steps, finalBoard: r.nb, captures: r.captures };
    }

    // ── Timer ya kupiga hatua moja kwa wakati ────────────────────────────────
    Timer {
        id: sowStepTimer
        interval: 450        // ms kila hatua — polepole kuona mabadiliko
        repeat: true
        onTriggered: {
            if (sowStepIdx >= sowSteps.length) {
                // Animation imekamilika
                sowStepTimer.stop();
                activeHole  = -1;
                activeArrow = "";
                sowAnimating = false;

                // Tekeleza matokeo ya mwisho
                var pr = pendingResult;
                pendingResult = null;
                board = pr.finalBoard;
                lastCapture = pr.captures;

                if (checkGameOver()) return;
                currentPlayer = (pr.player === human) ? ai : human;
                refreshStatus();
                if (pr.player === human) {
                    aiMoveTimer.start();
                }
                return;
            }

            var step = sowSteps[sowStepIdx];
            board       = step.board;
            activeHole  = step.holeIdx;
            activeArrow = step.arrow;
            sowStepIdx++;
        }
    }

    // ── Anzisha animation ya kupiga ──────────────────────────────────────────
    function startSowAnimation(startIdx, player) {
        var result = buildSowSteps(board, startIdx, player);
        if (!result) return false;

        // Hifadhi ubao wa awali — ondoa kete kutoka shimo la kuanza
        var nb = board.slice();
        nb[startIdx] = 0;
        board = nb;

        sowSteps     = result.steps;
        sowStepIdx   = 0;
        sowAnimating = true;
        activeHole   = startIdx;
        activeArrow  = "";
        pendingResult = { finalBoard: result.finalBoard, captures: result.captures, player: player };
        sowStepTimer.start();
        return true;
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
        if (gameOver || currentPlayer !== human || aiThinking || sowAnimating) return;
        if (!isMyRow(row, human)) { subMsg = "Hiyo si upande wako!"; return; }
        var h = idx(row, col);

        if (plantingPhase) {
            if (row !== innerRow(human)) { subMsg = "Panda kwenye safu yako ya ndani tu"; return; }
            if (handOf(human) <= 0)      { subMsg = "Hakuna kete zilizobaki mkononi"; return; }
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

        if (board[h] < 2) { subMsg = "Unahitaji kete 2 au zaidi kupiga"; return; }
        subMsg = "Inasogeza kete...";
        startSowAnimation(h, human);
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
            startSowAnimation(move, ai);
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

    // ── Mandhari — IQTest style ──────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: iqBg1 }
            GradientStop { position: 1.0; color: iqBg0 }
        }
    }
    Canvas {
        anchors.fill: parent; opacity: 0.06; z: 0
        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "#00e5ff"; ctx.lineWidth = 0.5;
            var step = 40;
            for (var x = 0; x < width;  x += step) { ctx.beginPath(); ctx.moveTo(x,0); ctx.lineTo(x,height); ctx.stroke(); }
            for (var y = 0; y < height; y += step) { ctx.beginPath(); ctx.moveTo(0,y); ctx.lineTo(width,y);   ctx.stroke(); }
        }
    }
    // Top accent bar
    Rectangle {
        anchors.top: parent.top; z: 1
        width: parent.width; height: 3
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.3; color: iqGold }
            GradientStop { position: 0.7; color: iqGoldGlow }
            GradientStop { position: 1.0; color: "transparent" }
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
                    color: iqGold
                    font.pixelSize: app.fntTitle
                    font.bold: true; font.letterSpacing: 3
                    style: Text.Outline; styleColor: "#003040"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Mchezaji dhidi ya Magabe AI"
                    color: iqTextDim
                    font.pixelSize: Math.max(12, app.fntUI - 1)
                    font.letterSpacing: 1
                }
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.7; height: 1
                color: iqCard
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Chagua Kiwango cha Magabe AI"
                color: iqAccent
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
                    color: lvEasyMA.pressed ? Qt.rgba(0,0.9,1,0.15) : iqCard
                    border.color: iqSuccess; border.width: 2
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
                            Text { text: "RAHISI";              color: iqSuccess; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 2 }
                            Text { text: "AI inacheza bahati nasibu";  color: iqGoldDim; font.pixelSize: Math.max(10, app.fntUI - 3) }
                        }
                    }
                }

                // Wastani
                Rectangle {
                    width: parent.width; height: app.btnH * 1.25
                    radius: 16
                    color: lvMedMA.pressed ? Qt.rgba(0,0.9,1,0.15) : iqCard
                    border.color: iqGold; border.width: 2
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
                            Text { text: "WASTANI";                  color: iqGold; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 2 }
                            Text { text: "AI hunasa kete ikiweza";  color: iqGoldDim; font.pixelSize: Math.max(10, app.fntUI - 3) }
                        }
                    }
                }

                // Ngumu
                Rectangle {
                    width: parent.width; height: app.btnH * 1.25
                    radius: 16
                    color: lvHardMA.pressed ? Qt.rgba(1,0.2,0.2,0.15) : iqCard
                    border.color: iqDanger; border.width: 2
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
                            Text { text: "NGUMU";                       color: iqDanger; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 2 }
                            Text { text: "AI hutumia mkakati wa kina";  color: iqGoldDim; font.pixelSize: Math.max(10, app.fntUI - 3) }
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
        anchors.centerIn: parent
        width: parent.width - 24
        spacing: Math.max(4, app.height * 0.007)

        // Kichwa + beji ya kiwango
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            Text {
                text: "BAO LA WASWAHILI"
                font.pixelSize: app.fntTitle; font.bold: true; font.letterSpacing: 3
                color: "#00e5ff"; style: Text.Outline; styleColor: "#003040"
                anchors.verticalCenter: parent.verticalCenter
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                height: Math.max(22, app.fntTitle * 0.72)
                width: lvBadgeTxt.implicitWidth + 16; radius: height / 2
                color: iqCard
                border.color: app.aiLevel === 0 ? iqSuccess : (app.aiLevel === 1 ? iqGold : iqDanger)
                border.width: 1
                Text {
                    id: lvBadgeTxt; anchors.centerIn: parent
                    text: app.aiLevel === 0 ? "🌱 Rahisi" : (app.aiLevel === 1 ? "🌿 Wastani" : "🔥 Ngumu")
                    color: app.aiLevel === 0 ? iqSuccess : (app.aiLevel === 1 ? iqGold : iqDanger)
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
            color:        app.currentPlayer === app.ai && !app.gameOver ? Qt.rgba(0,0.9,1,0.1) : iqCard
            border.color: app.currentPlayer === app.ai && !app.gameOver ? iqAccent : iqBg2
            border.width: app.currentPlayer === app.ai ? 2 : 1
            Behavior on color        { ColorAnimation { duration: 220 } }
            Behavior on border.color { ColorAnimation { duration: 220 } }
            Row {
                anchors.centerIn: parent; spacing: 12
                Text {
                    text: "🤖  Magabe AI"
                    color: app.currentPlayer === app.ai ? iqGold : iqGoldDim
                    font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 1.5
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 1; height: parent.parent.height * 0.45
                    color: iqCard; anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "✋ " + app.p2Hand
                    color: iqTextSec; font.pixelSize: app.fntUI
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    visible: app.aiThinking || (app.currentPlayer === app.ai && !app.gameOver)
                    width: 10; height: 10; radius: 5
                    color: iqAccent; anchors.verticalCenter: parent.verticalCenter
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
            radius: 14; color: iqCard
            border.color: iqAccent; border.width: 3
            Rectangle {
                anchors { fill: parent; margins: 3 }
                radius: 11; color: "transparent"
                border.color: iqBg0; border.width: 2
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
                        readonly property bool isActive: app.activeHole === index
                        readonly property bool validMove:
                            !app.gameOver && !app.aiThinking && !app.sowAnimating &&
                            app.currentPlayer === app.human && isP1 &&
                            (app.plantingPhase
                             ? isInner && app.handOf(app.human) > 0
                             : seeds >= 2)

                        width: app.holeSize; height: app.holeSize

                        // ── Fuatilia mabadiliko ya seeds kupitia property binding ─
                        property int prevSeeds: seeds

                        // Tumia Timer badala ya onSeedsChanged — inafanya kazi katika Qt 5.14
                        Timer {
                            id: seedWatcher
                            interval: 16
                            repeat: true
                            running: true
                            onTriggered: {
                                var now = app.board.length > index ? app.board[index] : 0;
                                if (now !== cell.prevSeeds) {
                                    cell.prevSeeds = now;
                                    bounceAnim.restart();
                                    numFadeAnim.restart();
                                }
                            }
                        }

                        // ── Bounce scale wakati kete zinabadilika ────────────
                        SequentialAnimation {
                            id: bounceAnim
                            NumberAnimation {
                                target: holeScale; property: "xScale"
                                to: 1.22; duration: 200; easing.type: Easing.OutQuad
                            }
                            NumberAnimation {
                                target: holeScale; property: "xScale"
                                to: 1.0; duration: 420; easing.type: Easing.OutElastic
                            }
                        }

                        // ── Mwanga wa mwendo halali ──────────────────────────
                        Rectangle {
                            visible: cell.validMove
                            anchors { fill: parent; margins: -3 }
                            radius: (app.holeSize + 6) / 2
                            color: "transparent"
                            border.color: iqGold; border.width: 2
                            SequentialAnimation on opacity {
                                running: cell.validMove; loops: Animation.Infinite
                                NumberAnimation { to: 1.0; duration: 550; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 0.3; duration: 550; easing.type: Easing.InOutSine }
                            }
                        }

                        // ── Mwanga wa AI inafikiria ──────────────────────────
                        Rectangle {
                            visible: cell.isAi && app.currentPlayer === app.ai && !app.gameOver && !app.sowAnimating
                            anchors { fill: parent; margins: -2 }
                            radius: (app.holeSize + 4) / 2
                            color: "transparent"
                            border.color: Qt.rgba(0, 0.9, 1, 0.18); border.width: 1
                        }

                        // ── Mwanga wa shimo linalopokea kete (active) ───────
                        Rectangle {
                            visible: cell.isActive
                            anchors { fill: parent; margins: -5 }
                            radius: (app.holeSize + 10) / 2
                            color: "transparent"
                            border.color: app.activeArrow === "✕" ? iqDanger
                                                                  : app.activeArrow === "★" ? "#FFD700"
                                                                                            : app.activeArrow === "↻" ? "#FF8C00"
                                                                                                                      : "#FFFFFF"
                            border.width: 3
                            SequentialAnimation on opacity {
                                running: cell.isActive; loops: Animation.Infinite
                                NumberAnimation { to: 1.0; duration: 180; easing.type: Easing.OutQuad }
                                NumberAnimation { to: 0.4; duration: 180; easing.type: Easing.InQuad }
                            }
                        }

                        // ── Shimo ────────────────────────────────────────────
                        Rectangle {
                            id: holeBody
                            anchors.fill: parent
                            radius: app.holeSize / 2
                            color: app.seedColor(cell.seeds)
                            Behavior on color { ColorAnimation { duration: 380; easing.type: Easing.InOutCubic } }

                            transform: Scale {
                                id: holeScale
                                origin.x: app.holeSize / 2
                                origin.y: app.holeSize / 2
                                xScale: 1.0
                                yScale: xScale
                            }

                            // Rim
                            Rectangle {
                                anchors.fill: parent; radius: parent.radius; color: "transparent"
                                border.color: Qt.rgba(0, 0, 0, 0.5); border.width: 2
                            }
                            // Specular
                            Rectangle {
                                anchors { top: parent.top; left: parent.left; margins: app.holeSize * 0.1 }
                                width: app.holeSize * 0.28; height: app.holeSize * 0.14
                                radius: height / 2; color: Qt.rgba(0, 0.9, 1, 0.10); rotation: -25
                            }

                            // ── Nambari na mshale wa mwelekeo ─────────────────
                            Item {
                                anchors.fill: parent

                                // Nambari — inaingia kwa fade + slide kutoka chini
                                Text {
                                    id: numText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: cell.seeds > 0 ? cell.seeds : ""
                                    color: cell.seeds > 10 ? "#001818" : "#e0f8f8"
                                    font.pixelSize: app.fntHole; font.bold: true
                                    opacity: 1.0
                                    y: 0

                                    SequentialAnimation {
                                        id: numFadeAnim
                                        ParallelAnimation {
                                            NumberAnimation { target: numText; property: "opacity"; to: 0.0; duration: 160; easing.type: Easing.InQuad }
                                            NumberAnimation { target: numText; property: "y"; to: app.fntHole * 0.45; duration: 160 }
                                        }
                                        ParallelAnimation {
                                            NumberAnimation { target: numText; property: "opacity"; to: 1.0; duration: 480; easing.type: Easing.OutCubic }
                                            NumberAnimation { target: numText; property: "y"; to: 0; duration: 480; easing.type: Easing.OutBack }
                                        }
                                    }
                                }

                                // Mshale wa mwelekeo — inaonekana kwenye shimo linalopokea
                                Text {
                                    visible: cell.isActive && app.activeArrow !== ""
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top
                                    anchors.topMargin: 1
                                    text: app.activeArrow
                                    color: app.activeArrow === "✕" ? "#FF6666"
                                                                   : app.activeArrow === "★" ? "#FFD700"
                                                                                             : app.activeArrow === "↻" ? "#FF8C00"
                                                                                                                       : "#FFFFFF"
                                    font.pixelSize: Math.max(9, app.fntHole * 0.72)
                                    font.bold: true
                                }
                            }
                        }

                        // ── Alama ya safu ya ndani ────────────────────────────
                        Rectangle {
                            visible: cell.isInner
                            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 3 }
                            width:  Math.max(8, app.holeSize * 0.14)
                            height: Math.max(4, app.holeSize * 0.08)
                            radius: height / 2
                            color:  cell.isP1 ? iqDanger : iqAccent
                            opacity: 0.85
                        }

                        // ── Flash ya mguso ────────────────────────────────────
                        Rectangle {
                            id: pressFlash
                            anchors.fill: parent; radius: app.holeSize / 2
                            color: Qt.rgba(0, 0.9, 1, 0.15); visible: false
                        }

                        MouseArea {
                            readonly property real ext: Math.max(0, (app.touchMin - app.holeSize) / 2)
                            anchors { fill: parent; margins: -ext }
                            enabled: cell.isP1 && !app.sowAnimating
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
            color:        app.currentPlayer === app.human && !app.gameOver ? Qt.rgba(0,0.9,1,0.1) : iqCard
            border.color: app.currentPlayer === app.human && !app.gameOver ? iqGold : iqBg2
            border.width: app.currentPlayer === app.human ? 2 : 1
            Behavior on color        { ColorAnimation { duration: 220 } }
            Behavior on border.color { ColorAnimation { duration: 220 } }
            Row {
                anchors.centerIn: parent; spacing: 12
                Text {
                    text: "▼  WEWE"
                    color: app.currentPlayer === app.human ? iqGold : iqGoldDim
                    font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 1.5
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 1; height: parent.parent.height * 0.45
                    color: iqCard; anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "✋ " + app.p1Hand
                    color: iqTextSec; font.pixelSize: app.fntUI
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // ── Paneli ya Hali ────────────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: app.statusH
            radius: 12
            color:        app.gameOver ? Qt.rgba(0,0.9,1,0.08) : iqCard
            border.color: app.gameOver ? iqGold : iqBg2
            border.width: app.gameOver ? 2 : 1
            Column {
                anchors.centerIn: parent; spacing: 3; width: parent.width - 20
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: app.statusMsg
                    color: app.gameOver ? iqGold : (app.currentPlayer === app.ai ? iqAccent : iqGold)
                    font.pixelSize: app.fntUI; font.bold: true
                    wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter; width: parent.width
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: app.subMsg
                    color: iqTextDim; font.pixelSize: Math.max(11, app.fntUI - 2)
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
                color: ngMA.pressed ? Qt.rgba(0,0.9,1,0.2) : iqCard
                border.color: iqGold; border.width: 2
                Behavior on color { ColorAnimation { duration: 80 } }
                Text {
                    anchors.centerIn: parent; text: "🔵  MPYA"
                    color: iqGold; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 1
                }
                MouseArea { id: ngMA; anchors.fill: parent; onClicked: app.showLevelScreen = true; }
            }

            Rectangle {
                visible: app.plantingPhase && !app.gameOver && app.currentPlayer === app.human
                width: Math.round(app.width * 0.32); height: app.btnH; radius: height / 2
                color: apMA.pressed ? Qt.rgba(0,0.9,1,0.1) : iqCard
                border.color: iqGoldDim; border.width: 1
                Behavior on color { ColorAnimation { duration: 80 } }
                Text {
                    anchors.centerIn: parent; text: "⚡ HARAKA"
                    color: iqAccent; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 0.5
                }
                MouseArea { id: apMA; anchors.fill: parent; onClicked: app.autoPlant(); }
            }

            Rectangle {
                width: Math.round(app.width * 0.28); height: app.btnH; radius: height / 2
                color: closeMA.pressed ? Qt.rgba(1,0.2,0.2,0.15) : iqCard
                border.color: iqDanger; border.width: 1
                Behavior on color { ColorAnimation { duration: 80 } }
                Text {
                    anchors.centerIn: parent; text: "❌  FUNGA"
                    color: iqDanger; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 1
                }
                MouseArea { id: closeMA; anchors.fill: parent; onClicked: app.close(); }
            }
        }

        // Beji ya Awamu
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            height: Math.max(28, app.btnH * 0.60)
            width: phaseLbl.implicitWidth + 28; radius: height / 2
            color:        app.plantingPhase ? Qt.rgba(0,1,0.5,0.06) : Qt.rgba(0,0.9,1,0.06)
            border.color: app.plantingPhase ? iqSuccess : iqAccent; border.width: 1
            Text {
                id: phaseLbl; anchors.centerIn: parent
                text:  app.plantingPhase ? "🌱  AWAMU YA KUPANDA" : "🌀  AWAMU YA KUPIGA"
                color: app.plantingPhase ? iqSuccess : iqAccent
                font.pixelSize: Math.max(11, app.fntUI - 2); font.bold: true; font.letterSpacing: 1
            }
        }

    } // Column ya mchezo

    // ── MAGABE LAB branding — bottom ─────────────────────────────────────────
    Item {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.max(8, app.height * 0.012)
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width; height: 32
        visible: !app.gameOver

        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
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
            Rectangle {
                width: 3; height: 3; radius: 2
                color: iqGold; opacity: 0.5
                anchors.verticalCenter: parent.verticalCenter
            }
            /*
            Text {
                text: "BY"
                font.pixelSize: Math.max(9, app.fntUI - 4)
                font.letterSpacing: 2
                color: Qt.rgba(0,0.9,1,0.3)
                anchors.verticalCenter: parent.verticalCenter
            }
            */
            Text {
                text: "MAGABE LAB"
                font.pixelSize: Math.max(10, app.fntUI - 3)
                font.bold: true; font.letterSpacing: 2.5
                color: Qt.rgba(0,0.9,1,0.7)
                anchors.verticalCenter: parent.verticalCenter
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.45; duration: 2000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0;  duration: 2000; easing.type: Easing.InOutSine }
                }
            }
            Rectangle {
                width: 3; height: 3; radius: 2
                color: iqGold; opacity: 0.5
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    //  SKRINI YA USHINDI
    // ════════════════════════════════════════════════════════════════════════
    Rectangle {
        visible: app.gameOver && !app.showLevelScreen
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.85)
        MouseArea { anchors.fill: parent }

        Rectangle {
            anchors.centerIn: parent
            width:  Math.min(app.width - 48, 360)
            height: winnerCol.implicitHeight + 52
            radius: 22; color: iqCard
            border.color: app.winner === app.human ? iqGold : iqAccent
            border.width: 3

            Column {
                id: winnerCol
                anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 24 }
                spacing: 16

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: app.winner === app.human ? "🏆" : "MAGABE AI"
                    font.pixelSize: app.winner === app.human ? Math.round(app.holeSize * 0.9) : Math.max(20, app.fntTitle * 0.85)

                    color: app.winner === app.human ? iqGold : iqAccent
                    
                    font.bold: true;
                    font.letterSpacing: 3

                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: app.winner === app.human ? "UMESHINDA!" : "IMESHINDA!"
                    color: app.winner === app.human ? iqGold : iqAccent
                    font.pixelSize: Math.max(20, app.fntTitle * 0.85)
                    font.bold: true; font.letterSpacing: 3
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: app.subMsg; color: "#006878"
                    font.pixelSize: app.fntUI
                    wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
                    width: Math.min(app.width - 80, 300)
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Kiwango: " + app.levelLabel(app.aiLevel)
                    color: app.aiLevel === 0 ? iqSuccess : (app.aiLevel === 1 ? iqGold : iqDanger)
                    font.pixelSize: Math.max(11, app.fntUI - 2)
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    Rectangle {
                        width: Math.max(130, app.width * 0.35); height: app.btnH; radius: height / 2
                        color: ctMA.pressed ? "#7a5020" : "#4a2e0c"
                        border.color: "#00e5ff"; border.width: 2
                        Behavior on color { ColorAnimation { duration: 80 } }
                        Text {
                            anchors.centerIn: parent; text: "CHEZA TENA"
                            color: iqGold; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 1
                        }
                        MouseArea { id: ctMA; anchors.fill: parent; onClicked: app.initBoard(); }
                    }

                    Rectangle {
                        width: Math.max(130, app.width * 0.35); height: app.btnH; radius: height / 2
                        color: bkMA.pressed ? "#1a1008" : "#100c04"
                        border.color: "#005060"; border.width: 1
                        Behavior on color { ColorAnimation { duration: 80 } }
                        Text {
                            anchors.centerIn: parent; text: "BADILISHA"
                            color: "#007888"; font.pixelSize: app.fntUI; font.bold: true; font.letterSpacing: 1
                        }
                        MouseArea { id: bkMA; anchors.fill: parent; onClicked: app.showLevelScreen = true; }
                    }
                }
                Item { width: 1; height: 4 }
            }
        }
    }
}
