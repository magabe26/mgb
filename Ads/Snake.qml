/*
 *  Copyright 2026 - MagabeLab (Tanzania). All Rights Reserved.
 *  Author Edwin Magabe
 *
 *  Mchezo wa Nyoka  (Snake Game) B
 *  ─────────────────────────────────────────────────────────
 *  Lugha     : Kiswahili
 *  Jukwaa    : Android (Qt 5.14.2)
 *  Udhibiti  : Telezesha kidole (swipe) au vitufe vya mshale
 *
 */


import QtQuick 2.14
import QtQuick.Window 2.14

Rectangle {
    id: app
    width: parent.width
    height: parent.height
    visible: true
    color:  "#0a0f0a"

    function cleanParent(text)
    {
        if (!text) return "";
        return text.replace(/\s*\(.*?\)\s*/g, "").trim();
    }

    function isPrimaryResultsApp()
    {
        return (typeof n3ctaApp !== "undefined");
    }

    function isSecondaryResultsApp()
    {
        return (typeof loader !== "undefined");
    }

    function isInsideApp()
    {
        let type = cleanParent(String(parent.parent.parent.parent));
        if(isPrimaryResultsApp()){
            return (type === "QQuickRootItem");
        } else {
            const index = type.indexOf("_");
            return ((index !== -1) && (type.substr(0,index) === "SwipeView"));
        }
    }

    function isQMLDialogApp()
    {
        const type = cleanParent(String(parent.parent.parent));
        return (type === "QQuickRectangle");
    }

    function closeIfInsideApp()
    {
        if(isInsideApp()){
            if(isPrimaryResultsApp()){
                n3ctaApp.closeCustomPage();
            }else if(isSecondaryResultsApp()){
                loader.isMenuWindowVisible = true;
                loader.isMainResultsWindowVisible = true;
                loader.isFooterVisible = true;
                if(typeof loader.mode !== "undefined"){
                    loader.mode = 2;
                }
                loader.closeCustomPage();
            }
        }
    }

    function closeIfQMLDialogApp()
    {
        if(isQMLDialogApp()){
            if(isPrimaryResultsApp()){
                n3ctaApp.closeQMLDialog();
            }else if(isSecondaryResultsApp()){
                nectaMainResultsPageDownloaderHtmlToXmlConveterAndSaver.closeQMLDialog();
            }
        }
    }

    function cmd(url)
    {
        if(isPrimaryResultsApp()) {
            n3ctaApp.onUrlVisited(url);
        }else if(isSecondaryResultsApp()){
            if(isQMLDialogApp()){
                n3ctaQmlConnectionsPipe.onUrlVisited(url)
            } else if(isInsideApp()){
                loader.onUrlVisited(url);
            }
        }
    }

    function showToastMessage(msg)
    {
        if(isPrimaryResultsApp()){
            n3ctaApp.showToastMessage(msg);
        }else if(isSecondaryResultsApp()){
            nectaMainResultsPageDownloaderHtmlToXmlConveterAndSaver.showToastMessage(msg);
        }
    }

    function ad()
    {
        if(isPrimaryResultsApp()){
            cmd("#showGoogleAd");
        }else if(isSecondaryResultsApp()){
            cmd("#showGoogleAd");
        }
    }

    function close()
    {
        closeIfInsideApp();
        closeIfQMLDialogApp();
        ad();
    }

    // ── Colors ────────────────────────────────────────────
    readonly property string clrBg:     "#0a0f0a";
    readonly property string clrGrid:   "#141a14";
    readonly property string clrBorder: "#00bcd4";
    readonly property string clrHead:   "#00bcd4";
    readonly property string clrFood:   "#ff3c3c";
    readonly property string clrHud:    "#00bcd4";
    readonly property string clrPause:  "#ffdd00";
    readonly property string clrOver:   "#ff3c3c";
    readonly property string clrBtn:    "#1a2e1a";
    readonly property string clrBtnPrs: "#2a5a2a";

    // ── Grid layout ───────────────────────────────────────
    readonly property int cols: 20;
    // HUD bar height (top) and D-Pad area height (bottom)
    readonly property int hudH:  dp(72);
    readonly property int dpadH: dp(220);
    // Available pixel area for the game canvas.
    // A 4px safety margin keeps cells away from the D-Pad edge.
    readonly property int availW: app.width;
    readonly property int availH: app.height - hudH - dpadH - 4;
    // Cell size is driven by width / cols only — no reference to rows,
    // which avoids a circular dependency in the QML property binding graph.
    readonly property int cell: Math.max(1, Math.floor(availW / cols));
    // Row count is derived from availH / cell so the game area is always
    // fully visible above the D-Pad, on any screen size or DPI.
    readonly property int rows: Math.max(1, Math.floor(availH / cell));
    readonly property int gameW: cols * cell;
    readonly property int gameH: rows * cell;
    // Centre horizontally; pin top edge directly under the HUD.
    // No extra vertical centering — bottom edge stays above the D-Pad.
    readonly property int offsetX: Math.floor((app.width - gameW) / 2);
    readonly property int offsetY: hudH;

    // ── Game state ────────────────────────────────────────
    property var  snake:   [];
    property var  food:    ({ x: 0, y: 0 });
    property int  dx:      1;
    property int  dy:      0;
    property int  nextDx:  1;
    property int  nextDy:  0;
    property int  score:   0;
    property int  best:    0;
    property bool alive:   false;
    property bool paused:  false;
    property bool started: false;

    // ── Speed (milliseconds per tick) ─────────────────────
    readonly property int baseSpeed: 200;   // slightly slower on mobile
    readonly property int minSpeed:  60;

    // ── Convert dp units to real pixels ───────────────────
    // Screen.pixelDensity is in dots/mm; 160dpi baseline = 1dp
    function dp(n) {
        var scale = Screen.pixelDensity * 25.4 / 160.0;
        return Math.round(n * Math.max(scale, 1.0));
    }

    // ── Recalculate tick interval based on current score ──
    function updateSpeed() {
        var s = baseSpeed - Math.floor(score / 5) * 10;
        ticker.interval = Math.max(s, minSpeed);
    }

    // ── Canvas helper: draw a rounded rectangle ───────────
    // Qt 5.14 Canvas API does not have ctx.roundedRect()
    function roundRect(ctx, x, y, w, h, r) {
        ctx.beginPath();
        ctx.moveTo(x + r, y);
        ctx.lineTo(x + w - r, y);
        ctx.arcTo(x + w, y,      x + w, y + r,      r);
        ctx.lineTo(x + w, y + h - r);
        ctx.arcTo(x + w, y + h,  x + w - r, y + h,  r);
        ctx.lineTo(x + r, y + h);
        ctx.arcTo(x,      y + h,  x,     y + h - r,  r);
        ctx.lineTo(x,      y + r);
        ctx.arcTo(x,      y,      x + r, y,           r);
        ctx.closePath();
    }

    // ── Initialise / restart the game ─────────────────────
    function initGame() {
        score          = 0;
        dx             = 1;
        dy             = 0;
        nextDx         = 1;
        nextDy         = 0;
        ticker.interval = baseSpeed;

        var cx = Math.floor(cols / 2);
        var cy = Math.floor(rows / 2);
        var s  = [];
        for (var i = 4; i >= 0; i--) {
            s.push({ x: cx - i, y: cy });
        }
        snake = s;

        spawnFood();
        alive   = true;
        paused  = false;
        started = true;
        ticker.start();
        canvas.requestPaint();
    }

    // ── Place food on a random free cell ──────────────────
    function spawnFood() {
        var free = [];
        for (var fx = 0; fx < cols; fx++) {
            for (var fy = 0; fy < rows; fy++) {
                var blocked = false;
                for (var k = 0; k < snake.length; k++) {
                    if (snake[k].x === fx && snake[k].y === fy) {
                        blocked = true;
                        break;
                    }
                }
                if (!blocked) {
                    free.push({ x: fx, y: fy });
                }
            }
        }
        if (free.length > 0) {
            food = free[Math.floor(Math.random() * free.length)];
        }
    }

    // ── One game tick: move snake, check collisions ────────
    function tick() {
        if (!alive || paused) { return; }

        dx = nextDx;
        dy = nextDy;

        var nx = snake[snake.length - 1].x + dx;
        var ny = snake[snake.length - 1].y + dy;

        // Wall collision
        if (nx < 0 || nx >= cols || ny < 0 || ny >= rows) {
            triggerGameOver();
            return;
        }

        // Self collision
        for (var i = 0; i < snake.length; i++) {
            if (snake[i].x === nx && snake[i].y === ny) {
                triggerGameOver();
                return;
            }
        }

        // Build new snake array (slice avoids QML var-property mutation bugs)
        var ns = snake.slice();
        ns.push({ x: nx, y: ny });

        if (nx === food.x && ny === food.y) {
            // Ate food — grow snake
            score++;
            if (score > best) { best = score; }
            updateSpeed();
            snake = ns;
            spawnFood();
        } else {
            // Normal move — remove tail segment
            ns.shift();
            snake = ns;
        }

        canvas.requestPaint();
    }

    // ── End the game ──────────────────────────────────────
    function triggerGameOver() {
        alive = false;
        ticker.stop();
        canvas.requestPaint();
    }

    // ── Change direction (prevents 180-degree reversal) ───
    function setDirection(newDx, newDy) {
        if (newDx !== 0 && dx === 0) { nextDx = newDx; nextDy = 0; }
        if (newDy !== 0 && dy === 0) { nextDx = 0;     nextDy = newDy; }
    }

    // ── Game ticker ───────────────────────────────────────
    Timer {
        id: ticker;
        interval: app.baseSpeed;
        repeat:   true;
        running:  false;
        onTriggered: app.tick();
    }

    // ── Splash screen blink timer ─────────────────────────
    Timer {
        id: splashBlink;
        property bool on: true;
        interval: 600;
        repeat:   true;
        running:  !app.started;
        onTriggered: { on = !on; canvas.requestPaint(); }
    }

    // ── Keyboard input (emulator / desktop debug only) ────
    Item {
        anchors.fill: parent;
        focus: true;

        Keys.onPressed: {
            event.accepted = true;

            // Any key starts the game from splash screen
            if (!app.started) { app.initGame(); return; }

            // Keys on game-over screen
            if (!app.alive) {
                if (event.key === Qt.Key_R) { app.initGame(); }
                if (event.key === Qt.Key_Q || event.key === Qt.Key_Escape) { Qt.quit(); }
                return;
            }

            // In-game direction keys
            switch (event.key) {
            case Qt.Key_Up:
            case Qt.Key_W:
                app.setDirection(0, -1);
                break;
            case Qt.Key_Down:
            case Qt.Key_S:
                app.setDirection(0, 1);
                break;
            case Qt.Key_Left:
            case Qt.Key_A:
                app.setDirection(-1, 0);
                break;
            case Qt.Key_Right:
            case Qt.Key_D:
                app.setDirection(1, 0);
                break;
            case Qt.Key_P:
                if (app.alive) {
                    app.paused = !app.paused;
                    canvas.requestPaint();
                }
                break;
            case Qt.Key_Q:
            case Qt.Key_Escape:
                Qt.quit();
                break;
            }
        }
    }

    // ═══════════════════════════════════════════════════════
    //  HUD — Score bar at the top of the screen
    // ═══════════════════════════════════════════════════════
    Rectangle {
        id: hud;
        x: 0;
        y: 0;
        width:  app.width;
        height: app.hudH;
        color:  "#0d130d";

        // Bottom separator line
        Rectangle {
            anchors.bottom: parent.bottom;
            width: parent.width;
            height: 1;
            color: app.clrBorder;
            opacity: 0.3;
        }

        Row {
            anchors.centerIn: parent;
            spacing: dp(24);

            // Score column
            Column {
                spacing: dp(2);
                Text { text: "ALAMA";   color: "#4a6a4a"; font.pixelSize: dp(11); font.family: "sans-serif"; font.letterSpacing: 1; }
                Text { text: app.score; color: app.clrHud; font.pixelSize: dp(28); font.bold: true; font.family: "monospace"; }
            }

            Rectangle { width: 1; height: dp(46); color: "#1e2e1e"; }

            // Best / high-score column
            Column {
                spacing: dp(2);
                Text { text: "REKODI"; color: "#4a6a4a"; font.pixelSize: dp(11); font.family: "sans-serif"; font.letterSpacing: 1; }
                Text { text: app.best;  color: "#ffdd55"; font.pixelSize: dp(28); font.bold: true; font.family: "monospace"; }
            }

            Rectangle { width: 1; height: dp(46); color: "#1e2e1e"; }

            // Level column
            Column {
                spacing: dp(2);
                Text { text: "KIWANGO"; color: "#4a6a4a"; font.pixelSize: dp(11); font.family: "sans-serif"; font.letterSpacing: 1; }
                Text {
                    text:  Math.min(Math.floor(app.score / 5) + 1, 10);
                    color: "#ff9944";
                    font.pixelSize: dp(28);
                    font.bold: true;
                    font.family: "monospace";
                }
            }

            Rectangle { width: 1; height: dp(46); color: "#1e2e1e"; }

            // Pause / resume button
            Rectangle {
                width:  dp(56);
                height: dp(56);
                radius: dp(8);
                color:  pauseTap.pressed ? app.clrBtnPrs : app.clrBtn;
                border.color: app.clrBorder;
                border.width: 1;
                opacity: app.started ? 1.0 : 0.3;

                Text {
                    anchors.centerIn: parent;
                    text:  app.paused ? "||>" : "||";
                    color: app.clrPause;
                    font.pixelSize: dp(18);
                    font.bold: true;
                }

                MouseArea {
                    id: pauseTap;
                    anchors.fill: parent;
                    onClicked: {
                        if (app.alive) {
                            app.paused = !app.paused;
                            canvas.requestPaint();
                        }
                    }
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════
    //  Game canvas
    // ═══════════════════════════════════════════════════════
    Canvas {
        id: canvas;
        x: app.offsetX;
        y: app.offsetY;
        width:  app.gameW;
        height: app.gameH;

        // ── Swipe gesture detection for Android ───────────
        property real swipeStartX: 0;
        property real swipeStartY: 0;
        readonly property int swipeThreshold: dp(30); // minimum swipe distance in px

        MouseArea {
            anchors.fill: parent;

            onPressed: {
                canvas.swipeStartX = mouse.x;
                canvas.swipeStartY = mouse.y;
            }

            onReleased: {
                var deltaX = mouse.x - canvas.swipeStartX;
                var deltaY = mouse.y - canvas.swipeStartY;
                var absDx  = Math.abs(deltaX);
                var absDy  = Math.abs(deltaY);

                // Short tap (no significant swipe)
                if (absDx < canvas.swipeThreshold && absDy < canvas.swipeThreshold) {
                    if (!app.started) { app.initGame(); return; }

                    // Game-over screen — check which button was tapped
                    if (!app.alive) {
                        var W2      = canvas.width;
                        var H2      = canvas.height;
                        var btnW2   = dp(200);
                        var btnH2   = dp(58);
                        var btnGap2 = dp(14);
                        var btnY2   = H2 / 2 + dp(16);
                        var restX2  = W2 / 2 - btnW2 - btnGap2 / 2;
                        var closeX2 = W2 / 2 + btnGap2 / 2;

                        if (mouse.x >= restX2  && mouse.x <= restX2  + btnW2 &&
                            mouse.y >= btnY2    && mouse.y <= btnY2   + btnH2) {
                            app.initGame();
                            return;
                        }
                        if (mouse.x >= closeX2 && mouse.x <= closeX2 + btnW2 &&
                            mouse.y >= btnY2    && mouse.y <= btnY2   + btnH2) {
                            app.close();
                            return;
                        }
                        return;
                    }
                    return;
                }

                if (!app.started) { app.initGame(); return; }
                if (!app.alive)   { return; }

                // Determine swipe axis and call setDirection
                if (absDx > absDy) {
                    app.setDirection(deltaX > 0 ? 1 : -1, 0);
                } else {
                    app.setDirection(0, deltaY > 0 ? 1 : -1);
                }
            }
        }

        onPaint: {
            var ctx = getContext("2d");
            var C   = app.cell;
            var W   = width;
            var H   = height;

            // ── Background ────────────────────────────────
            ctx.fillStyle = app.clrBg;
            ctx.fillRect(0, 0, W, H);

            // ── Grid lines ────────────────────────────────
            ctx.strokeStyle = app.clrGrid;
            ctx.lineWidth   = 0.5;
            for (var gx = 0; gx <= app.cols; gx++) {
                ctx.beginPath();
                ctx.moveTo(gx * C, 0);
                ctx.lineTo(gx * C, H);
                ctx.stroke();
            }
            for (var gy = 0; gy <= app.rows; gy++) {
                ctx.beginPath();
                ctx.moveTo(0,  gy * C);
                ctx.lineTo(W,  gy * C);
                ctx.stroke();
            }

            // ── Splash screen (before first game) ────────
            if (!app.started) {
                ctx.textAlign    = "center";
                ctx.textBaseline = "middle";

                // Title
                ctx.fillStyle = app.clrHead;
                ctx.font      = "bold " + dp(50) + "px sans-serif";
                ctx.fillText("NYOKA", W / 2, H / 2 - dp(80));

                // Instructions
                ctx.fillStyle = "#888888";
                ctx.font      = dp(15) + "px sans-serif";
                ctx.fillText("Tumia mishale kumwongoza", W / 2, H / 2 - dp(24));
                ctx.fillText("Kula chakula. Epuka ukuta!", W / 2, H / 2 + dp(4));

                // Blinking start button
                app.roundRect(ctx, W/2 - dp(130), H/2 + dp(38), dp(260), dp(52), dp(10));
                ctx.fillStyle = splashBlink.on ? app.clrHead : "#004d5a";
                ctx.fill();
                ctx.fillStyle = splashBlink.on ? "#002a30" : "#007a8a";
                ctx.font      = "bold " + dp(15) + "px sans-serif";
                ctx.fillText("ANZA", W / 2, H / 2 + dp(64));
                return;
            }

            // ── Snake body segments ───────────────────────
            var s = app.snake;
            for (var bi = 0; bi < s.length - 1; bi++) {
                var t  = bi / s.length;
                var gr = Math.floor(70 + t * 110); // gradient: dark at tail, bright near head
                ctx.fillStyle = "rgb(0," + gr + "," + gr + ")";
                app.roundRect(ctx, s[bi].x * C + 2, s[bi].y * C + 2, C - 4, C - 4, dp(4));
                ctx.fill();
            }

            // ── Snake head ────────────────────────────────
            if (s.length > 0) {
                var hd = s[s.length - 1];
                ctx.fillStyle = app.alive ? app.clrHead : "#666666";
                app.roundRect(ctx, hd.x * C + 1, hd.y * C + 1, C - 2, C - 2, dp(5));
                ctx.fill();

                // Draw eyes only when alive
                if (app.alive) {
                    var es  = dp(3);
                    var off = dp(6);
                    var ex1, ey1, ex2, ey2;

                    if      (app.dx ===  1) { ex1 = hd.x*C+C-off; ey1 = hd.y*C+off;   ex2 = hd.x*C+C-off; ey2 = hd.y*C+C-off; }
                    else if (app.dx === -1) { ex1 = hd.x*C+off;   ey1 = hd.y*C+off;   ex2 = hd.x*C+off;   ey2 = hd.y*C+C-off; }
                    else if (app.dy === -1) { ex1 = hd.x*C+off;   ey1 = hd.y*C+off;   ex2 = hd.x*C+C-off; ey2 = hd.y*C+off;   }
                    else                     { ex1 = hd.x*C+off;   ey1 = hd.y*C+C-off; ex2 = hd.x*C+C-off; ey2 = hd.y*C+C-off; }

                    // Pupils
                    ctx.fillStyle = "#000000";
                    ctx.beginPath(); ctx.arc(ex1, ey1, es, 0, Math.PI * 2); ctx.fill();
                    ctx.beginPath(); ctx.arc(ex2, ey2, es, 0, Math.PI * 2); ctx.fill();
                    // Eye shine
                    ctx.fillStyle = "#ffffff";
                    ctx.beginPath(); ctx.arc(ex1 + dp(1), ey1 - dp(1), dp(1.2), 0, Math.PI * 2); ctx.fill();
                    ctx.beginPath(); ctx.arc(ex2 + dp(1), ey2 - dp(1), dp(1.2), 0, Math.PI * 2); ctx.fill();
                }
            }

            // ── Food (apple with glow + shine) ────────────
            var foX = app.food.x * C + C / 2;
            var foY = app.food.y * C + C / 2;
            var fr  = C / 2 - dp(3);

            // Radial glow halo
            var grd = ctx.createRadialGradient(foX, foY, 1, foX, foY, fr + dp(8));
            grd.addColorStop(0,   "#ff3c3c");
            grd.addColorStop(0.5, "#cc000044");
            grd.addColorStop(1,   "transparent");
            ctx.fillStyle = grd;
            ctx.beginPath(); ctx.arc(foX, foY, fr + dp(8), 0, Math.PI * 2); ctx.fill();

            // Apple body
            ctx.fillStyle = app.clrFood;
            ctx.beginPath(); ctx.arc(foX, foY, fr, 0, Math.PI * 2); ctx.fill();

            // Specular highlight
            ctx.fillStyle = Qt.rgba(255,255,255,0.30);
            ctx.beginPath(); ctx.arc(foX - fr * 0.28, foY - fr * 0.28, fr * 0.38, 0, Math.PI * 2); ctx.fill();

            // Stem
            ctx.strokeStyle = "#8b5e00";
            ctx.lineWidth   = dp(2);
            ctx.beginPath();
            ctx.moveTo(foX, foY - fr);
            ctx.lineTo(foX + dp(3), foY - fr - dp(6));
            ctx.stroke();

            // ── Paused overlay ────────────────────────────
            if (app.paused) {
                ctx.fillStyle = Qt.rgba(0,0,0,0.60);
                ctx.fillRect(0, 0, W, H);
                ctx.textAlign    = "center";
                ctx.textBaseline = "middle";
                ctx.fillStyle    = app.clrPause;
                ctx.font         = "bold " + dp(38) + "px sans-serif";
                ctx.fillText("IMESIMAMA", W / 2, H / 2 - dp(18));
                ctx.fillStyle = "#aaaaaa";
                ctx.font      = dp(15) + "px sans-serif";
                ctx.fillText("Bonyeza || kuendelea", W / 2, H / 2 + dp(20));
            }

            // ── Game-over overlay ─────────────────────────
            if (!app.alive && app.started) {
                ctx.fillStyle = Qt.rgba(0,0,0,0.72);
                ctx.fillRect(0, 0, W, H);
                ctx.textAlign    = "center";
                ctx.textBaseline = "middle";

                // Title
                ctx.fillStyle = app.clrOver;
                ctx.font      = "bold " + dp(40) + "px sans-serif";
                ctx.fillText("MCHEZO UMEISHA!", W / 2, H / 2 - dp(52));

                // Score summary
                ctx.fillStyle = "#ffffff";
                ctx.font      = dp(18) + "px sans-serif";
                ctx.fillText("Alama: " + app.score + "   Rekodi: " + app.best, W / 2, H / 2 - dp(12));

                // Shared button dimensions
                var btnW   = dp(200);
                var btnH   = dp(58);
                var btnGap = dp(14);
                var btnY   = H / 2 + dp(16);
                var restX  = W / 2 - btnW - btnGap / 2;
                var closeX = W / 2 + btnGap / 2;

                // ── Restart button (green) ────────────────
                var gRestart = ctx.createLinearGradient(restX, btnY, restX, btnY + btnH);
                gRestart.addColorStop(0, "#00e5ff");
                gRestart.addColorStop(1, "#007a8a");
                app.roundRect(ctx, restX, btnY, btnW, btnH, dp(12));
                ctx.fillStyle   = gRestart;
                ctx.fill();
                ctx.strokeStyle = "#00bcd4";
                ctx.lineWidth   = dp(1.5);
                app.roundRect(ctx, restX, btnY, btnW, btnH, dp(12));
                ctx.stroke();
                ctx.fillStyle = "#002a30";
                ctx.font      = "bold " + dp(17) + "px sans-serif";
                ctx.fillText("CHEZA TENA", restX + btnW / 2, btnY + btnH / 2);

                // ── Close button (red) ────────────────────
                // Outer crimson glow halo
                var haloGrd = ctx.createRadialGradient(
                    closeX + btnW / 2, btnY + btnH / 2, dp(8),
                    closeX + btnW / 2, btnY + btnH / 2, btnW * 0.8);
                haloGrd.addColorStop(0, "rgba(255,0,0,0.20)");
                haloGrd.addColorStop(1, "transparent");
                ctx.fillStyle = haloGrd;
                ctx.beginPath();
                ctx.arc(closeX + btnW / 2, btnY + btnH / 2, btnW * 0.8, 0, Math.PI * 2);
                ctx.fill();
                // Dark-red to bright-red gradient fill
                var gClose = ctx.createLinearGradient(closeX, btnY, closeX, btnY + btnH);
                gClose.addColorStop(0,   "#ff2222");
                gClose.addColorStop(0.5, "#cc0000");
                gClose.addColorStop(1,   "#7a0000");
                app.roundRect(ctx, closeX, btnY, btnW, btnH, dp(12));
                ctx.fillStyle   = gClose;
                ctx.fill();
                // Glowing red border
                ctx.strokeStyle = "#ff4444";
                ctx.lineWidth   = dp(2);
                app.roundRect(ctx, closeX, btnY, btnW, btnH, dp(12));
                ctx.stroke();
                // Shine strip at top edge
                app.roundRect(ctx, closeX + dp(8), btnY + dp(4), btnW - dp(16), dp(12), dp(5));
                ctx.fillStyle = "rgba(255,180,180,0.18)";
                ctx.fill();
                // Label
                ctx.fillStyle = "#ffffff";
                ctx.font      = "bold " + dp(17) + "px sans-serif";
                ctx.fillText("FUNGA", closeX + btnW / 2, btnY + btnH / 2);
            }
        }
    }

    // ── Canvas border glow ────────────────────────────────
    Rectangle {
        x: app.offsetX;
        y: app.offsetY;
        width:  app.gameW;
        height: app.gameH;
        color:  "transparent";
        border.color: app.clrBorder;
        border.width: 2;
        opacity: 0.45;
    }

    // ═══════════════════════════════════════════════════════
    //  D-Pad — Beautiful glowing directional pad
    // ═══════════════════════════════════════════════════════
    Item {
        id: dpad;
        x: 0;
        y: app.height - app.dpadH;
        width:  app.width;
        height: app.dpadH;

        // Teal gradient background for the whole D-Pad area
        Rectangle {
            anchors.fill: parent;
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#001a1f"; }
                GradientStop { position: 1.0; color: "#003040"; }
            }
        }

        // Top glowing separator line
        Rectangle {
            width: parent.width;
            height: 2;
            gradient: Gradient {
                orientation: Gradient.Horizontal;
                GradientStop { position: 0.0; color: "transparent"; }
                GradientStop { position: 0.3; color: "#00bcd4"; }
                GradientStop { position: 0.7; color: "#00bcd4"; }
                GradientStop { position: 1.0; color: "transparent"; }
            }
            opacity: 0.8;
        }

        // Shared button size and layout constants
        readonly property int btnSize: dp(78);
        readonly property int gap:     dp(8);
        readonly property int centerX: Math.floor(width  / 2);
        readonly property int centerY: Math.floor(height / 2);

        // ── Reusable D-Pad button component ───────────────
        // Each button: circular, teal glowing border, arrow icon, press animation

        // ── UP button ─────────────────────────────────────
        Rectangle {
            id: upBtn;
            x: dpad.centerX - dpad.btnSize / 2;
            y: dpad.centerY - dpad.btnSize - dpad.gap - dpad.btnSize / 2;
            width:  dpad.btnSize;
            height: dpad.btnSize;
            radius: dpad.btnSize / 2;  // fully circular
            color:  upArea.pressed ? "#00bcd4" : "#002530";
            border.color: upArea.pressed ? "#00e5ff" : "#00bcd4";
            border.width: dp(2);

            // Outer glow ring
            Rectangle {
                anchors.centerIn: parent;
                width:  parent.width  + dp(8);
                height: parent.height + dp(8);
                radius: (parent.width + dp(8)) / 2;
                color:  "transparent";
                border.color: "#00bcd4";
                border.width: 1;
                opacity: upArea.pressed ? 0.9 : 0.25;
            }

            // Inner shine arc at top
            Rectangle {
                x: parent.width * 0.25;
                y: parent.height * 0.12;
                width:  parent.width * 0.50;
                height: parent.height * 0.18;
                radius: parent.height * 0.09;
                color:  Qt.rgba(255,255,255,0.12);
            }

            // Arrow — triangle pointing UP
            Canvas {
                anchors.centerIn: parent;
                width:  dp(28);
                height: dp(24);
                onPaint: {
                    var c = getContext("2d");
                    c.clearRect(0, 0, width, height);
                    c.beginPath();
                    c.moveTo(width / 2, 0);
                    c.lineTo(width, height);
                    c.lineTo(0, height);
                    c.closePath();
                    c.fillStyle = upArea.pressed ? "#001a1f" : "#00bcd4";
                    c.fill();
                }
                Connections { target: upArea; function onPressedChanged() { canvas.requestPaint(); } }
            }

            scale: upArea.pressed ? 0.88 : 1.0;
            Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutQuad; } }

            MouseArea {
                id: upArea;
                anchors.fill: parent;
                onPressed: {
                    if (!app.started) { app.initGame(); }
                    else               { app.setDirection(0, -1); }
                }
            }
        }

        // ── DOWN button ───────────────────────────────────
        Rectangle {
            id: downBtn;
            x: dpad.centerX - dpad.btnSize / 2;
            y: dpad.centerY + dpad.gap + dpad.btnSize / 2;
            width:  dpad.btnSize;
            height: dpad.btnSize;
            radius: dpad.btnSize / 2;
            color:  downArea.pressed ? "#00bcd4" : "#002530";
            border.color: downArea.pressed ? "#00e5ff" : "#00bcd4";
            border.width: dp(2);

            Rectangle {
                anchors.centerIn: parent;
                width:  parent.width  + dp(8);
                height: parent.height + dp(8);
                radius: (parent.width + dp(8)) / 2;
                color:  "transparent";
                border.color: "#00bcd4";
                border.width: 1;
                opacity: downArea.pressed ? 0.9 : 0.25;
            }

            Rectangle {
                x: parent.width * 0.25;
                y: parent.height * 0.12;
                width:  parent.width * 0.50;
                height: parent.height * 0.18;
                radius: parent.height * 0.09;
                color:  Qt.rgba(255,255,255,0.12);
            }

            // Arrow — triangle pointing DOWN
            Canvas {
                anchors.centerIn: parent;
                width:  dp(28);
                height: dp(24);
                onPaint: {
                    var c = getContext("2d");
                    c.clearRect(0, 0, width, height);
                    c.beginPath();
                    c.moveTo(0, 0);
                    c.lineTo(width, 0);
                    c.lineTo(width / 2, height);
                    c.closePath();
                    c.fillStyle = downArea.pressed ? "#001a1f" : "#00bcd4";
                    c.fill();
                }
                Connections { target: downArea; function onPressedChanged() { canvas.requestPaint(); } }
            }

            scale: downArea.pressed ? 0.88 : 1.0;
            Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutQuad; } }

            MouseArea {
                id: downArea;
                anchors.fill: parent;
                onPressed: {
                    if (!app.started) { app.initGame(); }
                    else               { app.setDirection(0, 1); }
                }
            }
        }

        // ── LEFT button ───────────────────────────────────
        Rectangle {
            id: leftBtn;
            x: dpad.centerX - dpad.btnSize - dpad.gap - dpad.btnSize / 2;
            y: dpad.centerY - dpad.btnSize / 2;
            width:  dpad.btnSize;
            height: dpad.btnSize;
            radius: dpad.btnSize / 2;
            color:  leftArea.pressed ? "#00bcd4" : "#002530";
            border.color: leftArea.pressed ? "#00e5ff" : "#00bcd4";
            border.width: dp(2);

            Rectangle {
                anchors.centerIn: parent;
                width:  parent.width  + dp(8);
                height: parent.height + dp(8);
                radius: (parent.width + dp(8)) / 2;
                color:  "transparent";
                border.color: "#00bcd4";
                border.width: 1;
                opacity: leftArea.pressed ? 0.9 : 0.25;
            }

            Rectangle {
                x: parent.width * 0.25;
                y: parent.height * 0.12;
                width:  parent.width * 0.50;
                height: parent.height * 0.18;
                radius: parent.height * 0.09;
                color:  Qt.rgba(255,255,255,0.12);
            }

            // Arrow — triangle pointing LEFT
            Canvas {
                anchors.centerIn: parent;
                width:  dp(24);
                height: dp(28);
                onPaint: {
                    var c = getContext("2d");
                    c.clearRect(0, 0, width, height);
                    c.beginPath();
                    c.moveTo(0, height / 2);
                    c.lineTo(width, 0);
                    c.lineTo(width, height);
                    c.closePath();
                    c.fillStyle = leftArea.pressed ? "#001a1f" : "#00bcd4";
                    c.fill();
                }
                Connections { target: leftArea; function onPressedChanged() { canvas.requestPaint(); } }
            }

            scale: leftArea.pressed ? 0.88 : 1.0;
            Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutQuad; } }

            MouseArea {
                id: leftArea;
                anchors.fill: parent;
                onPressed: {
                    if (!app.started) { app.initGame(); }
                    else               { app.setDirection(-1, 0); }
                }
            }
        }

        // ── RIGHT button ──────────────────────────────────
        Rectangle {
            id: rightBtn;
            x: dpad.centerX + dpad.gap + dpad.btnSize / 2;
            y: dpad.centerY - dpad.btnSize / 2;
            width:  dpad.btnSize;
            height: dpad.btnSize;
            radius: dpad.btnSize / 2;
            color:  rightArea.pressed ? "#00bcd4" : "#002530";
            border.color: rightArea.pressed ? "#00e5ff" : "#00bcd4";
            border.width: dp(2);

            Rectangle {
                anchors.centerIn: parent;
                width:  parent.width  + dp(8);
                height: parent.height + dp(8);
                radius: (parent.width + dp(8)) / 2;
                color:  "transparent";
                border.color: "#00bcd4";
                border.width: 1;
                opacity: rightArea.pressed ? 0.9 : 0.25;
            }

            Rectangle {
                x: parent.width * 0.25;
                y: parent.height * 0.12;
                width:  parent.width * 0.50;
                height: parent.height * 0.18;
                radius: parent.height * 0.09;
                color:  Qt.rgba(255,255,255,0.12);
            }

            // Arrow — triangle pointing RIGHT
            Canvas {
                anchors.centerIn: parent;
                width:  dp(24);
                height: dp(28);
                onPaint: {
                    var c = getContext("2d");
                    c.clearRect(0, 0, width, height);
                    c.beginPath();
                    c.moveTo(0, 0);
                    c.lineTo(width, height / 2);
                    c.lineTo(0, height);
                    c.closePath();
                    c.fillStyle = rightArea.pressed ? "#001a1f" : "#00bcd4";
                    c.fill();
                }
                Connections { target: rightArea; function onPressedChanged() { canvas.requestPaint(); } }
            }

            scale: rightArea.pressed ? 0.88 : 1.0;
            Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutQuad; } }

            MouseArea {
                id: rightArea;
                anchors.fill: parent;
                onPressed: {
                    if (!app.started) { app.initGame(); }
                    else               { app.setDirection(1, 0); }
                }
            }
        }

        // ── Centre logo ───────────────────────────────────
        Rectangle {
            x: dpad.centerX - dpad.btnSize / 2;
            y: dpad.centerY - dpad.btnSize / 2;
            width:  dpad.btnSize;
            height: dpad.btnSize;
            radius: dpad.btnSize / 2;
            color:  "#001a20";
            border.color: "#00bcd4";
            border.width: dp(2);
            opacity: 0.85;

            // Outer pulse ring
            Rectangle {
                anchors.centerIn: parent;
                width:  parent.width  + dp(8);
                height: parent.height + dp(8);
                radius: (parent.width + dp(8)) / 2;
                color:  "transparent";
                border.color: "#00bcd4";
                border.width: 1;
                opacity: 0.20;
            }

            Text {
                anchors.centerIn: parent;
                text:           "TZ";
                color:          "#00bcd4";
                font.pixelSize: dp(22);
                font.bold:      true;
                opacity:        0.90;
            }
        }
    }
}
