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
    // COVER  (section 0) — redesigned for Nyerere
    // ════════════════════════════════════════════════
    Item {
        id: coverItem
        anchors.fill: parent
        visible: opacity > 0
        opacity: section === 0 ? 1.0 : 0.0
        x:       section === 0 ? 0 : -app.width * 0.18
        Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        Behavior on x       { NumberAnimation { duration: 350; easing.type: Easing.OutCubic  } }

        // Full background
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#020a02" }
                GradientStop { position: 0.5; color: "#050f05" }
                GradientStop { position: 1.0; color: "#020a02" }
            }
        }

        // Diagonal gold lines texture
        Canvas {
            anchors.fill: parent; opacity: 0.06
            onPaint: {
                var ctx = getContext("2d");
                ctx.strokeStyle = "#f5c400";
                ctx.lineWidth = 1;
                for (var i = -height; i < width + height; i += Math.round(32 * dp)) {
                    ctx.beginPath(); ctx.moveTo(i, 0); ctx.lineTo(i + height, height); ctx.stroke();
                }
            }
        }

        // Top flag stripe
        Rectangle {
            anchors.top: parent.top; width: parent.width; height: Math.round(5 * dp)
            gradient: Gradient {
                GradientStop { position: 0.0;  color: "#006400" }
                GradientStop { position: 0.38; color: "#006400" }
                GradientStop { position: 0.40; color: "#f5c400" }
                GradientStop { position: 0.60; color: "#f5c400" }
                GradientStop { position: 0.62; color: "#000000" }
                GradientStop { position: 1.0;  color: "#000000" }
            }
        }

        Flickable {
            anchors.fill: parent; contentWidth: width
            contentHeight: coverMain.implicitHeight + Math.round(60 * dp)
            clip: true; boundsBehavior: Flickable.StopAtBounds

            Column {
                id: coverMain
                width: parent.width
                anchors.top: parent.top; anchors.topMargin: Math.round(20 * dp)
                spacing: 0

                // TOP HERO ROW — picha kushoto, maelezo kulia
                Item {
                    width: parent.width
                    height: Math.round(210 * dp)

                    // Photo left
                    Rectangle {
                        id: heroPhoto
                        anchors.left: parent.left; anchors.leftMargin: Math.round(16 * dp)
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.round(150 * dp); height: Math.round(190 * dp)
                        radius: Math.round(16 * dp); color: "#0f1f0f"; layer.enabled: true
                        Rectangle {
                            anchors.fill: parent; radius: parent.radius; color: "transparent"
                            border.color: gold; border.width: Math.round(2 * dp)
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite; running: section === 0
                                NumberAnimation { to: 0.3; duration: 1200; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 1.0; duration: 1200; easing.type: Easing.InOutSine }
                            }
                        }
                        Image { anchors.fill: parent; fillMode: Image.PreserveAspectCrop; source: "./nyerere0.jpeg"; smooth: true }
                        Rectangle {
                            anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                            height: parent.height * 0.3; radius: parent.radius
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 1.0; color: "#0f1f0f" }
                            }
                        }
                        opacity: 0
                        SequentialAnimation on opacity {
                            PauseAnimation  { duration: 200 }
                            NumberAnimation { from: 0; to: 1; duration: 600; easing.type: Easing.OutCubic }
                        }
                    }

                    // Right info
                    Column {
                        anchors.left: heroPhoto.right; anchors.leftMargin: Math.round(14 * dp)
                        anchors.right: parent.right; anchors.rightMargin: Math.round(16 * dp)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Math.round(8 * dp)

                        // MWALIMU pill
                        Rectangle {
                            height: Math.round(22 * dp); width: mwalimuLbl.implicitWidth + Math.round(16 * dp)
                            radius: Math.round(11 * dp)
                            color: Qt.rgba(0.96, 0.77, 0.0, 0.15); border.color: gold; border.width: 1
                            opacity: 0
                            NumberAnimation on opacity { from: 0; to: 1; duration: 600; running: true }
                            Text { id: mwalimuLbl; anchors.centerIn: parent; text: "MWALIMU"; font.pointSize: Math.round(7 * dp); font.bold: true; font.letterSpacing: Math.round(2 * dp); color: gold }
                        }

                        // Name
                        Text {
                            width: parent.width
                            text: "Julius\nKambarage\nNyerere"
                            font.pointSize: Math.round(18 * dp); font.bold: true
                            color: cream; lineHeight: 1.15; lineHeightMode: Text.ProportionalHeight; wrapMode: Text.WordWrap
                            opacity: 0
                            SequentialAnimation on opacity {
                                PauseAnimation { duration: 300 }
                                NumberAnimation { from: 0; to: 1; duration: 700; easing.type: Easing.OutCubic }
                            }
                        }

                        // Gold underline
                        Rectangle {
                            width: parent.width * 0.7; height: Math.round(2 * dp); radius: 1
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: gold }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                        }

                        // Years
                        Text { text: "1922 \u2013 1999"; font.pointSize: Math.round(8 * dp); color: goldDim; font.letterSpacing: Math.round(1 * dp) }

                        // Cheo badge
                        Rectangle {
                            height: Math.round(26 * dp); width: cheoCoverTxt.implicitWidth + Math.round(14 * dp)
                            radius: Math.round(6 * dp); color: green; border.color: greenLight; border.width: 1
                            Rectangle {
                                anchors.fill: parent; radius: parent.radius; color: "transparent"; border.color: gold; border.width: Math.round(1 * dp)
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite; running: section === 0
                                    NumberAnimation { to: 0.0; duration: 1000; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: 0.8; duration: 1000; easing.type: Easing.InOutSine }
                                }
                            }
                            Text { id: cheoCoverTxt; anchors.centerIn: parent; text: "Baba wa Taifa"; font.pointSize: Math.round(7.5 * dp); font.bold: true; color: cream }
                        }
                    }
                }

                Item { width: 1; height: Math.round(16 * dp) }

                // Slogan bar
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - Math.round(32 * dp); height: Math.round(38 * dp); radius: Math.round(10 * dp)
                    color: Qt.rgba(0.96, 0.77, 0.0, 0.08); border.color: Qt.rgba(0.96, 0.77, 0.0, 0.25); border.width: 1
                    Row {
                        anchors.centerIn: parent; spacing: Math.round(10 * dp)
                        Text { text: "\uD83D\uDD25"; font.pointSize: Math.round(13 * dp); anchors.verticalCenter: parent.verticalCenter }
                        Text {
                            id: sloganText
                            text: "UHURU NA UMOJA"; font.pointSize: Math.round(10 * dp); font.bold: true
                            font.letterSpacing: Math.round(2 * dp); color: gold; anchors.verticalCenter: parent.verticalCenter
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite; running: section === 0
                                NumberAnimation { to: 0.4; duration: 900; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
                            }
                        }
                        Text { text: "\uD83D\uDD25"; font.pointSize: Math.round(13 * dp); anchors.verticalCenter: parent.verticalCenter }
                    }
                }

                Item { width: 1; height: Math.round(14 * dp) }

                // Quote card
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - Math.round(32 * dp); height: cQNew.implicitHeight + Math.round(28 * dp)
                    radius: Math.round(14 * dp); border.color: Qt.rgba(0.0, 0.70, 0.0, 0.40); border.width: 1; opacity: 0
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#0d2e0d" }
                        GradientStop { position: 1.0; color: "#051405" }
                    }
                    SequentialAnimation on opacity {
                        PauseAnimation  { duration: 800 }
                        NumberAnimation { from: 0; to: 1; duration: 700; easing.type: Easing.OutCubic }
                    }
                    Rectangle {
                        anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                        anchors.margins: Math.round(10 * dp); width: Math.round(3 * dp); radius: Math.round(2 * dp); color: gold
                    }
                    Text {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.margins: Math.round(8 * dp)
                        text: "\u201C"; font.pointSize: 28; color: goldDim; lineHeight: 0.6; lineHeightMode: Text.ProportionalHeight
                    }
                    Text {
                        id: cQNew
                        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: Math.round(22 * dp); rightMargin: Math.round(14 * dp) }
                        text: "Uhuru wa kweli ni zaidi ya uhuru wa kisiasa \u2014 ni uhuru wa kiuchumi, kijamii na kiakili."
                        font.pointSize: Math.round(9.5 * dp); font.italic: true; color: cream
                        wrapMode: Text.WordWrap; lineHeight: 1.5; lineHeightMode: Text.ProportionalHeight
                    }
                }

                Item { width: 1; height: Math.round(16 * dp) }

                // CCM divider
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter; width: parent.width * 0.75; height: Math.round(1 * dp)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.3; color: Qt.rgba(0.96, 0.77, 0.0, 0.4) }
                        GradientStop { position: 0.7; color: Qt.rgba(0.96, 0.77, 0.0, 0.4) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                Item { width: 1; height: Math.round(16 * dp) }

                // Nav buttons — full width with subtitle
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - Math.round(32 * dp); spacing: Math.round(10 * dp)
                    Repeater {
                        model: [
                            {label:"Wasifu",    icon:"\uD83D\uDCCC", sub:"Maisha ya Mwalimu",    sec:1},
                            {label:"Maisha",    icon:"\uD83D\uDDD3",  sub:"Safari ya maisha yake", sec:2},
                            {label:"Mafanikio", icon:"\u2605",        sub:"Kazi na mchango",      sec:3},
                            {label:"Maneno",    icon:"\uD83D\uDCAC",  sub:"Maneno ya hekima",     sec:4},
                            {label:"Picha",     icon:"\uD83D\uDDBC",  sub:"Kumbukumbu za picha",  sec:5}
                        ]
                        delegate: Rectangle {
                            id: navBtnNew
                            width: parent.width; height: Math.round(52 * dp); radius: Math.round(12 * dp)
                            color: navMANew.pressed ? Qt.rgba(0.0, 0.55, 0.0, 0.25) : darkCard
                            border.color: navMANew.pressed ? gold : Qt.rgba(0.0, 0.50, 0.0, 0.30); border.width: 1
                            Behavior on color        { ColorAnimation { duration: 120 } }
                            Behavior on border.color { ColorAnimation { duration: 120 } }
                            Behavior on scale        { NumberAnimation { duration: 100 } }
                            opacity: 0
                            SequentialAnimation on opacity {
                                PauseAnimation  { duration: 900 + (index * 100) }
                                NumberAnimation { from: 0; to: 1; duration: 350; easing.type: Easing.OutCubic }
                            }
                            Rectangle {
                                anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                                anchors.margins: Math.round(10 * dp); width: Math.round(3 * dp); radius: Math.round(2 * dp)
                                color: (index % 2 === 0) ? gold : greenLight
                            }
                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left; anchors.leftMargin: Math.round(22 * dp)
                                anchors.right: parent.right; anchors.rightMargin: Math.round(14 * dp)
                                height: Math.round(34 * dp)
                                Row {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Math.round(12 * dp)
                                    Rectangle {
                                        width: Math.round(34 * dp); height: Math.round(34 * dp); radius: Math.round(17 * dp)
                                        color: Qt.rgba(0.0, 0.50, 0.0, 0.18); border.color: Qt.rgba(0.0, 0.50, 0.0, 0.35); border.width: 1
                                        anchors.verticalCenter: parent.verticalCenter
                                        Text { anchors.centerIn: parent; text: modelData.icon; font.pointSize: Math.round(14 * dp) }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: Math.round(2 * dp)
                                        Text { text: modelData.label; font.pointSize: Math.round(11 * dp); font.bold: true; color: navMANew.pressed ? gold : cream }
                                        Text { text: modelData.sub;   font.pointSize: Math.round(7.5 * dp); color: creamDim }
                                    }
                                }
                                Text {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    text: "\u203a"; font.pointSize: Math.round(18 * dp); font.bold: true
                                    color: navMANew.pressed ? gold : Qt.rgba(0.96, 0.77, 0.0, 0.45)
                                }
                            }
                            MouseArea {
                                id: navMANew; anchors.fill: parent
                                onPressed:  { navBtnNew.scale = 0.97; }
                                onReleased: { navBtnNew.scale = 1.0; section = modelData.sec; }
                                onCanceled: { navBtnNew.scale = 1.0; }
                            }
                        }
                    }
                }

                Item { width: 1; height: Math.round(14 * dp) }

                // Funga button
                Rectangle {
                    id: fungaBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.round(100 * dp); height: Math.round(36 * dp); radius: Math.round(18 * dp)
                    color:        fuangaMA.pressed ? Qt.rgba(0.8, 0.1, 0.1, 0.25) : Qt.rgba(0.8, 0.1, 0.1, 0.10)
                    border.color: fuangaMA.pressed ? "#c0392b" : Qt.rgba(0.8, 0.1, 0.1, 0.4); border.width: 1
                    Behavior on color        { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    Behavior on scale        { NumberAnimation { duration: 100 } }
                    Row {
                        anchors.centerIn: parent; spacing: Math.round(6 * dp)
                        Text { text: "X"; font.pointSize: Math.round(10 * dp); color: "#e57373"; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Funga"; font.pointSize: Math.round(10 * dp); font.bold: true; color: "#e57373"; anchors.verticalCenter: parent.verticalCenter }
                    }
                    MouseArea {
                        id: fuangaMA; anchors.fill: parent
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
                        id: wasifuThumb
                        width: Math.round(90 * dp); height: Math.round(110 * dp); radius: Math.round(10 * dp)
                        color: "#0f1f0f"; border.color: goldDim; border.width: 1
                        layer.enabled: true
                        opacity: 0
                        SequentialAnimation on opacity {
                            PauseAnimation  { duration: 100 }
                            NumberAnimation { from: 0; to: 1; duration: 500; easing.type: Easing.OutCubic }
                        }
                        SequentialAnimation on x {
                            PauseAnimation  { duration: 100 }
                            NumberAnimation { from: -Math.round(30 * dp); to: 0; duration: 500; easing.type: Easing.OutCubic }
                        }
                        Image { anchors.fill: parent; fillMode: Image.PreserveAspectCrop; source: "./nyerere0.jpeg"; smooth: true }
                    }
                    Column {
                        spacing: Math.round(5 * dp); width: parent.width - Math.round(102 * dp)
                        Repeater {
                            model: [
                                {l:"Jina",     v:"Julius Kambarage Nyerere"},
                                {l:"Kuzaliwa", v:"13 Aprili 1922, Butiama"},
                                {l:"Kufariki", v:"14 Oktoba 1999"},
                                {l:"Umri",     v:"Miaka 77"},
                                {l:"Kabila",   v:"Mzanaki"}
                            ]
                            delegate: Row {
                                spacing: Math.round(4 * dp); width: parent.width
                                opacity: 0
                                SequentialAnimation on opacity {
                                    PauseAnimation  { duration: 200 + (index * 80) }
                                    NumberAnimation { from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic }
                                }
                                SequentialAnimation on x {
                                    PauseAnimation  { duration: 200 + (index * 80) }
                                    NumberAnimation { from: Math.round(16 * dp); to: 0; duration: 300; easing.type: Easing.OutCubic }
                                }
                                Text { text: modelData.l + ":"; font.pointSize: Math.round(7.5 * dp); font.bold: true; color: goldDim; width: Math.round(68 * dp) }
                                Text { text: modelData.v; font.pointSize: Math.round(7.5 * dp); color: cream; wrapMode: Text.WordWrap; width: parent.width - Math.round(72 * dp) }
                            }
                        }
                    }
                }


                // CCM divider
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.8; height: Math.round(1 * dp)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.3; color: Qt.rgba(0.96, 0.77, 0.0, 0.4) }
                        GradientStop { position: 0.7; color: Qt.rgba(0.96, 0.77, 0.0, 0.4) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                Repeater {
                    model: [
                        {l:"Elimu",        v:"BA Makerere (1952); MA Edinburgh (1958)"},
                        {l:"Awamu",        v:"Rais wa 1 (1964–1985)"},
                        {l:"Chama",        v:"CCM"},
                        {l:"Makamu",       v:"Aboud Jumbe"},
                        {l:"Chama",        v:"TANU → CCM"},
                        {l:"Kazi ya awali",v:"Mwalimu Tabora (1945)\nMwasisi TANU (1954)"}
                    ]
                    delegate: Row { spacing: Math.round(8 * dp); width: parent.width
                        Text { text: modelData.l + ":"; font.pointSize: Math.round(8 * dp); font.bold: true; color: goldDim; width: Math.round(95 * dp) }
                        Text { text: modelData.v; font.pointSize: Math.round(8 * dp); color: cream; wrapMode: Text.WordWrap; width: parent.width - Math.round(103 * dp); lineHeight: 1.4; lineHeightMode: Text.ProportionalHeight }
                    }
                }


                // CCM divider
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.8; height: Math.round(1 * dp)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.3; color: Qt.rgba(0.96, 0.77, 0.0, 0.4) }
                        GradientStop { position: 0.7; color: Qt.rgba(0.96, 0.77, 0.0, 0.4) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                Repeater {
                    model: [
                        {t:"Maisha ya Kisiasa", b:"Alianzisha TANU mwaka 1954 na kupigana kwa amani kwa uhuru wa Tanganyika, uliofikiwa Desemba 9, 1961. Akawa Waziri Mkuu, kisha Rais wa kwanza, na mwasisi wa Tanzania iliyoundwa mwaka 1964."},
                        {t:"Asili yake",        b:"Alizaliwa Butiama, Mara, katika familia ya chifu mdogo. Alijifunza Kiingereza akiwa mkubwa, akasomea Makerere na Edinburgh — akarudi kuongoza taifa lake kwa unyenyekevu na hekima."}
                    ]
                    delegate: Rectangle {
                        width: parent.width
                        height: bioInner.implicitHeight + Math.round(16 * dp)
                        color: darkCard; radius: Math.round(10 * dp)
                        border.color: Qt.rgba(0.0, 0.50, 0.0, 0.20); border.width: 1
                        opacity: 0
                        SequentialAnimation on opacity {
                            PauseAnimation  { duration: 400 + (index * 150) }
                            NumberAnimation { from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic }
                        }
                        // CCM left border — gold kwa wa kwanza, green kwa wa pili
                        Rectangle {
                            anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                            anchors.margins: Math.round(10 * dp); width: Math.round(3 * dp); radius: Math.round(2 * dp)
                            color: index === 0 ? gold : greenLight
                        }
                        Column {
                            id: bioInner
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: Math.round(18 * dp); rightMargin: Math.round(12 * dp) }
                            spacing: Math.round(5 * dp)
                            Text { text: modelData.t; font.pointSize: Math.round(10 * dp); font.bold: true; color: gold }
                            Text { text: modelData.b; font.pointSize: Math.round(9 * dp); color: creamDim; wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.5; lineHeightMode: Text.ProportionalHeight }
                        }
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
        opacity: section === 3 ? 1.0 : 0.0
        x:       section === 3 ? 0 : (section < 3 ? app.width * 0.18 : -app.width * 0.18)
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
                        {i:"\uD83C\uDDF9\uD83C\uDDFF", t:"Uhuru wa Tanganyika (1961)",   d:"Aliongoza harakati za amani — Tanganyika ilipata uhuru bila kumwaga damu, Desemba 9, 1961."},
                        {i:"\uD83E\uDD1D", t:"Muungano wa Tanzania (1964)",   d:"Aliunda Muungano wa Tanganyika na Zanzibar — mfano wa umoja Afrika."},
                        {i:"\uD83D\uDCDA", t:"Elimu kwa Wote (UPE)",          d:"Sera ya Elimu ya Msingi kwa Wote iliyoongeza haraka watoto wanaosoma nchini kote."},
                        {i:"\uD83C\uDFD8", t:"Azimio la Arusha (1967)",       d:"Alitangaza Ujamaa na Kujitegemea — sera ya maendeleo inayotegemea nguvu za wananchi."},
                        {i:"\uD83C\uDF0D", t:"Mwasisi wa OAU (1963)",         d:"Alishiriki kuanzisha Umoja wa Afrika na kupigana dhidi ya ubaguzi wa rangi barani Afrika."},
                        {i:"\u270F\uFE0F",  t:"Tafsiri ya Kiswahili",          d:"Alitafsiri vitabu vya Shakespeare kwa Kiswahili — kutukuza lugha ya Taifa."},
                        {i:"\uD83E\uDD4A", t:"Ukombozi wa Uganda (1979)",     d:"Alituma jeshi kupambana na uvamizi wa Idi Amin — ukombozi wa wananchi wa Uganda."},
                        {i:"\uD83C\uDFC5", t:"Mwalimu wa Taifa",              d:"Alijulikana duniani kama 'Mwalimu' — kiongozi mwenye hekima na unyenyekevu wa kipekee."}
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
        opacity: section === 4 ? 1.0 : 0.0
        x:       section === 4 ? 0 : (section < 4 ? app.width * 0.18 : -app.width * 0.18)
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
                        {q:"Uhuru wa kweli ni zaidi ya kutowekwa mikononi — ni haki ya kufanya maamuzi ya maisha yako.",  c:"Hotuba ya Uhuru, 1961"},
                        {q:"Elimu haitoshi kama haifundishi mtu kujitegemea na kuhudumia jamii yake.",                   c:"Azimio la Arusha, 1967"},
                        {q:"Tunataka watu wenye akili, si watu wanaotegemea msaada wa nje kila siku.",                    c:"Sera ya Ujamaa"},
                        {q:"Sikatai kuwa maskini. Ninakataa kuwa mtumwa.",                                                c:"Kauli maarufu"},
                        {q:"Afrika ni moja. Mgawanyiko wetu ni urithi wa ukoloni, si hali yetu ya asili.",               c:"Mkutano wa OAU, 1963"},
                        {q:"Nitawaachia serikali safi, si hazina kubwa. Hazina ya kweli ni watu wenye elimu.",            c:"Hotuba ya kujiuzulu, 1985"},
                        {q:"Kiswahili ni lugha yetu ya umoja — inamaanisha zaidi ya maneno, ni utambulisho.",        c:"Bungeni, Dodoma"},
                        {q:"Demokrasia bila usawa wa kiuchumi ni mchezo tu wa maneno.",                                   c:"Hotuba ya kimataifa"}
                    ]
                    delegate: Rectangle {
                        id: quoteCard
                        width: parent.width; height: qInner.implicitHeight + Math.round(24 * dp)
                        radius: Math.round(14 * dp)
                        color: quoteMA.pressed ? "#142a14" : darkCard
                        border.color: Qt.rgba(0.0, 0.50, 0.0, 0.30); border.width: 1
                        opacity: 0
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        SequentialAnimation on opacity {
                            PauseAnimation  { duration: index * 90 }
                            NumberAnimation { from: 0; to: 1; duration: 350; easing.type: Easing.OutCubic }
                        }
                        SequentialAnimation on anchors.topMargin {
                            PauseAnimation  { duration: index * 90 }
                            NumberAnimation { from: Math.round(14 * dp); to: 0; duration: 350; easing.type: Easing.OutCubic }
                        }

                        Rectangle {
                            anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                            anchors.margins: Math.round(10 * dp); width: Math.round(3 * dp); radius: Math.round(2 * dp); color: gold
                        }
                        Column {
                            id: qInner
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: Math.round(18 * dp); rightMargin: Math.round(14 * dp) }
                            spacing: Math.round(6 * dp)
                            Text { text: "\u201C" + modelData.q + "\u201D"; font.pointSize: Math.round(10 * dp); font.italic: true; color: cream; wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.5; lineHeightMode: Text.ProportionalHeight }
                            Item {
                                width: parent.width
                                height: quoteSource.implicitHeight
                                Text {
                                    id: quoteSource
                                    anchors.left: parent.left
                                    text: "— " + modelData.c
                                    font.pointSize: Math.round(8 * dp); color: goldDim; font.italic: true
                                }
                                Text {
                                    anchors.right: parent.right
                                    text: (index + 1) + "/8"
                                    font.pointSize: Math.round(7 * dp); color: Qt.rgba(0.96, 0.77, 0.0, 0.35)
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                        MouseArea {
                            id: quoteMA
                            anchors.fill: parent
                            onPressed:  { quoteCard.scale = 0.95; }
                            onReleased: { quoteSpring.start(); }
                            onCanceled: { quoteCard.scale = 1.0; }
                        }
                        SequentialAnimation {
                            id: quoteSpring
                            NumberAnimation { target: quoteCard; property: "scale"; to: 1.04; duration: 100; easing.type: Easing.OutQuad }
                            NumberAnimation { target: quoteCard; property: "scale"; to: 0.98; duration: 70;  easing.type: Easing.InQuad  }
                            NumberAnimation { target: quoteCard; property: "scale"; to: 1.0;  duration: 90;  easing.type: Easing.OutQuad }
                        }
                    }
                }

                // Memorial card
                Rectangle {
                    id: memCard
                    width: parent.width; height: memC.implicitHeight + Math.round(28 * dp); radius: Math.round(14 * dp)
                    opacity: 0
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#002800" }
                        GradientStop { position: 1.0; color: "#003800" }
                    }
                    border.color: greenLight; border.width: 1
                    // Fade-in baada ya quotes zote
                    SequentialAnimation on opacity {
                        PauseAnimation  { duration: 8 * 90 + 400 }
                        NumberAnimation { from: 0; to: 1; duration: 600; easing.type: Easing.OutCubic }
                    }
                    // GreenLight border pulse
                    SequentialAnimation on border.color {
                        loops: Animation.Infinite
                        ColorAnimation { to: greenLight;                        duration: 1400; easing.type: Easing.InOutSine }
                        ColorAnimation { to: Qt.rgba(0.0, 0.40, 0.0, 0.4);     duration: 1400; easing.type: Easing.InOutSine }
                    }
                    Column {
                        id: memC
                        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: Math.round(20 * dp) }
                        spacing: Math.round(8 * dp)
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "\uD83C\uDF39 Pumzika kwa Amani \uD83C\uDF39"; font.pointSize: Math.round(12 * dp); font.bold: true; color: greenLight }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "13 Aprili 1922 – 14 Oktoba 1999"; font.pointSize: Math.round(9 * dp); color: creamDim }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Mwalimu Nyerere — Baba wa Taifa, mwanga wa Afrika, roho yake itaishi milele"; font.pointSize: Math.round(9 * dp); font.italic: true; color: gold; wrapMode: Text.WordWrap; width: parent.width; horizontalAlignment: Text.AlignHCenter }
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
        opacity: section === 5 ? 1.0 : 0.0
        x:       section === 5 ? 0 : (section < 5 ? app.width * 0.18 : -app.width * 0.18)
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
                    Image { id: heroImg; anchors.fill: parent; fillMode: Image.PreserveAspectCrop; source: "./nyerere0.jpeg"; smooth: true }
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
                            {n:"Picha 1", s:"./nyerere1.jpeg"},
                            {n:"Picha 2", s:"./nyerere2.jpeg"},
                            {n:"Picha 3", s:"./nyerere3.jpeg"},
                            {n:"Picha 4", s:"./nyerere4.jpeg"},
                            {n:"Picha 5", s:"./nyerere5.jpeg"},
                            {n:"Picha 6", s:"./nyerere6.jpeg"}
                        ]
                        delegate: Rectangle {
                            id: gridTile
                            width: (parent.width - Math.round(8 * dp)) / 2; height: width * 0.72
                            radius: Math.round(10 * dp); color: "#0f1f0f"
                            border.color: Qt.rgba(0.0, 0.50, 0.0, 0.22); border.width: 1
                            layer.enabled: true
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


    // ════════════════════════════════════════════════
    // MCHEZO — Memory Card Game  (section 5)
    // ════════════════════════════════════════════════
    Item {
        id: gameSection
        anchors.fill: parent
        visible: opacity > 0
        opacity: section === 6 ? 1.0 : 0.0
        x:       section === 6 ? 0 : (section < 6 ? app.width * 0.18 : -app.width * 0.18)
        Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        Behavior on x       { NumberAnimation { duration: 350; easing.type: Easing.OutCubic  } }

        // ── Game state ───────────────────────────────────────────────────────
        property var  cardData:    [
            {pid:0, icon:"\uD83C\uDDF9\uD83C\uDDFF", label:"Uhuru"},
            {pid:1, icon:"\uD83E\uDD1D",               label:"Muungano"},
            {pid:2, icon:"\uD83C\uDFD8",               label:"Arusha"},
            {pid:3, icon:"\uD83D\uDCDA",               label:"Elimu"},
            {pid:4, icon:"\uD83C\uDF0D",               label:"OAU"},
            {pid:5, icon:"\uD83C\uDFC5",               label:"Mwalimu"},
            {pid:0, icon:"\uD83C\uDDF9\uD83C\uDDFF", label:"Uhuru"},
            {pid:1, icon:"\uD83E\uDD1D",               label:"Muungano"},
            {pid:2, icon:"\uD83C\uDFD8",               label:"Arusha"},
            {pid:3, icon:"\uD83D\uDCDA",               label:"Elimu"},
            {pid:4, icon:"\uD83C\uDF0D",               label:"OAU"},
            {pid:5, icon:"\uD83C\uDFC5",               label:"Mwalimu"}
        ]
        property var  shuffled:    []
        property var  flipped:     []
        property var  matched:     []
        property int  firstPick:   -1
        property int  secondPick:  -1
        property bool busy:        false
        property int  moves:       0
        property bool gameWon:        false
        property bool showInstructions: true
        property real score:          0
        property bool showMatchAnim:  false
        property bool showMissAnim:   false

        function shuffle(arr) {
            var a = arr.slice();
            for (var i = a.length - 1; i > 0; i--) {
                var j = Math.floor(Math.random() * (i + 1));
                var tmp = a[i]; a[i] = a[j]; a[j] = tmp;
            }
            return a;
        }

        function initGame() {
            var s = [];
            for (var i = 0; i < cardData.length; i++) { s.push(i); }
            shuffled   = shuffle(s);
            flipped    = [];
            matched    = [];
            firstPick  = -1;
            secondPick = -1;
            busy       = false;
            moves      = 0;
            gameWon    = false;
            score      = 0;
            showMatchAnim = false;
            showMissAnim  = false;
            score      = 0;
            showMatchAnim = false;
            showMissAnim  = false;
        }

        function cardFlipped(pos) {
            if (busy) return;
            if (flipped.indexOf(pos) !== -1) return;
            if (matched.indexOf(cardData[shuffled[pos]].pid) !== -1) return;

            var f = flipped.slice();
            f.push(pos);
            flipped = f;

            if (firstPick === -1) {
                firstPick = pos;
            } else {
                secondPick = pos;
                moves = moves + 1;
                busy = true;
                checkTimer.start();
            }
        }

        function checkMatch() {
            var a = cardData[shuffled[firstPick]];
            var b = cardData[shuffled[secondPick]];
            if (a.pid === b.pid) {
                score = Math.round((score + (100 / (gameSection.cardData.length / 2))) * 10) / 10;
                showMatchAnim = true;
                matchAnimTimer.start();
                var m = matched.slice();
                m.push(a.pid);
                matched = m;
                if (matched.length === 6) { gameWon = true; }
            } else {
                score = score - 3;
                showMissAnim = true;
                missAnimTimer.start();
                score = score - 3;
                showMissAnim = true;
                missAnimTimer.start();
                var f2 = flipped.slice();
                f2.splice(f2.indexOf(firstPick), 1);
                f2.splice(f2.indexOf(secondPick), 1);
                flipped = f2;
            }
            firstPick  = -1;
            secondPick = -1;
            busy       = false;
        }

        Timer {
            id: checkTimer
            interval: 900; repeat: false
            onTriggered: { gameSection.checkMatch(); }
        }
        Timer { id: matchAnimTimer; interval: 700; repeat: false; onTriggered: { gameSection.showMatchAnim = false; } }
        Timer { id: missAnimTimer;  interval: 700; repeat: false; onTriggered: { gameSection.showMissAnim  = false; } }

        Component.onCompleted: { initGame(); }

        // ── Header ───────────────────────────────────────────────────────────
        Rectangle {
            id: hGame
            anchors.top: parent.top; width: parent.width; height: Math.round(54 * dp); color: "#0a160a"
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Qt.rgba(0.0, 0.50, 0.0, 0.40) }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom
                height: 2; radius: 1; color: gold; width: 0
                NumberAnimation on width { to: hGameTitleRow.implicitWidth + Math.round(16 * dp); duration: 350; easing.type: Easing.OutCubic; running: true }
            }
            Rectangle {
                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: Math.round(14 * dp)
                width: Math.round(36 * dp); height: Math.round(36 * dp); radius: Math.round(18 * dp)
                color: hGameBackMA.pressed ? Qt.rgba(0.0, 0.55, 0.0, 0.30) : Qt.rgba(0.0, 0.50, 0.0, 0.12)
                border.color: Qt.rgba(0.0, 0.50, 0.0, 0.40); border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
                Text { anchors.centerIn: parent; text: "\u2190"; font.pointSize: Math.round(14 * dp); color: gold }
                MouseArea { id: hGameBackMA; anchors.fill: parent; onClicked: { section = 0; } }
            }
            Row {
                id: hGameTitleRow
                anchors.centerIn: parent; spacing: Math.round(8 * dp)
                Text { text: "\uD83C\uDFAE"; font.pointSize: Math.round(14 * dp); anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Mchezo wa Kumbukumbu"; font.pointSize: Math.round(11 * dp); font.bold: true; color: cream; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        // ── Stats bar ────────────────────────────────────────────────────────
        Rectangle {
            id: statsBar
            anchors.top: hGame.bottom; width: parent.width; height: Math.round(36 * dp)
            color: "#060f06"
            Row {
                anchors.centerIn: parent; spacing: Math.round(16 * dp)
                Row { spacing: Math.round(4 * dp)
                    Text { text: "\uD83C\uDFAF"; font.pointSize: Math.round(9 * dp); anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Hatua: " + gameSection.moves; font.pointSize: Math.round(8 * dp); color: cream; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                }
                Rectangle { width: 1; height: Math.round(16 * dp); color: Qt.rgba(1,1,1,0.2); anchors.verticalCenter: parent.verticalCenter }
                Row { spacing: Math.round(4 * dp)
                    Text { text: "\u2705"; font.pointSize: Math.round(9 * dp); anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Pairs: " + gameSection.matched.length + "/6"; font.pointSize: Math.round(8 * dp); color: gold; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                }
                Rectangle { width: 1; height: Math.round(16 * dp); color: Qt.rgba(1,1,1,0.2); anchors.verticalCenter: parent.verticalCenter }
                Row { spacing: Math.round(4 * dp)
                    Text { text: "\u2B50"; font.pointSize: Math.round(9 * dp); anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: Math.round(gameSection.score) + "/100"
                        font.pointSize: Math.round(8 * dp); font.bold: true; anchors.verticalCenter: parent.verticalCenter
                        color: gameSection.score >= 0 ? gold : "#ff6666"
                    }
                }
            }
        }

        // ── Floating score indicators ────────────────────────────────────────
        Item {
            anchors.fill: parent; z: 10
            Rectangle {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: gameSection.showMatchAnim ? -Math.round(40 * dp) : 0
                Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                width: matchPopTxt.implicitWidth + Math.round(24 * dp)
                height: Math.round(36 * dp); radius: Math.round(18 * dp)
                color: "#cc003300"; border.color: "#00ff88"; border.width: Math.round(2 * dp)
                visible: gameSection.showMatchAnim
                opacity: gameSection.showMatchAnim ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 300 } }
                Text { id: matchPopTxt; anchors.centerIn: parent; text: "+" + Math.round(1000 / (gameSection.cardData.length / 2)) / 10 + " \uD83C\uDF89"; font.pointSize: Math.round(12 * dp); font.bold: true; color: "#00ff88" }
            }
            Rectangle {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: gameSection.showMissAnim ? Math.round(40 * dp) : 0
                Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                width: missPopTxt.implicitWidth + Math.round(24 * dp)
                height: Math.round(36 * dp); radius: Math.round(18 * dp)
                color: "#cc330000"; border.color: "#ff4444"; border.width: Math.round(2 * dp)
                visible: gameSection.showMissAnim
                opacity: gameSection.showMissAnim ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 300 } }
                Text { id: missPopTxt; anchors.centerIn: parent; text: "-3 \uD83D\uDE15"; font.pointSize: Math.round(12 * dp); font.bold: true; color: "#ff4444" }
            }
        }

        // ── Card grid ────────────────────────────────────────────────────────
        Grid {
            id: cardGrid
            anchors.top: statsBar.bottom; anchors.topMargin: Math.round(16 * dp)
            anchors.bottom: parent.bottom; anchors.bottomMargin: Math.round(52 * dp + 16 * dp)
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - Math.round(32 * dp)
            columns: 3
            spacing: Math.round(10 * dp)

            Repeater {
                model: 12
                delegate: Item {
                    id: cardItem
                    width:  (cardGrid.width  - 2 * Math.round(10 * dp)) / 3
                    height: (cardGrid.height - 3 * cardGrid.spacing) / 4

                    property bool isFlipped: gameSection.flipped.indexOf(index) !== -1
                    property bool isMatched: {
                        var d = gameSection.cardData[gameSection.shuffled[index]];
                        return d ? gameSection.matched.indexOf(d.pid) !== -1 : false;
                    }
                    property bool faceUp: isFlipped || isMatched

                    Behavior on scale { NumberAnimation { duration: 100 } }
                    SequentialAnimation on scale {
                        running: cardItem.isMatched && gameSection.showMatchAnim
                        NumberAnimation { to: 1.12; duration: 120; easing.type: Easing.OutQuad }
                        NumberAnimation { to: 1.0;  duration: 120; easing.type: Easing.InQuad }
                    }

                    // Back face (green CCM card)
                    Rectangle {
                        anchors.fill: parent
                        radius: Math.round(10 * dp)
                        color: darkCard
                        border.color: isMatched ? gold : Qt.rgba(0.0, 0.50, 0.0, 0.45)
                        border.width: isMatched ? Math.round(2 * dp) : 1
                        visible: !cardItem.faceUp
                        Behavior on border.color { ColorAnimation { duration: 200 } }

                        // JPM on back
                        Column {
                            anchors.centerIn: parent; spacing: Math.round(2 * dp)
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Nyerere"
                                font.pointSize: Math.round(8 * dp); font.bold: false
                                color: gold; font.letterSpacing: Math.round(3 * dp)
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "\u2605"
                                font.pointSize: Math.round(9 * dp); color: Qt.rgba(0.96, 0.77, 0.0, 0.5)
                            }
                        }

                        // CCM flag stripe bottom
                        Rectangle {
                            anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                            height: Math.round(3 * dp); radius: Math.round(10 * dp)
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
                            anchors.fill: parent
                            onPressed:  { cardItem.scale = 0.92; }
                            onReleased: {
                                cardItem.scale = 1.0;
                                if (!gameSection.gameWon) { gameSection.cardFlipped(index); }
                            }
                            onCanceled: { cardItem.scale = 1.0; }
                        }
                    }

                    // Front face (gold — shows icon + label)
                    Rectangle {
                        anchors.fill: parent
                        radius: Math.round(10 * dp)
                        color: cardItem.isMatched ? "#1a3a00" : "#1a2e00"
                        border.color: cardItem.isMatched ? gold : Qt.rgba(0.96, 0.77, 0.0, 0.45)
                        border.width: Math.round(2 * dp)
                        visible: cardItem.faceUp

                        // Matched shimmer overlay
                        Rectangle {
                            anchors.fill: parent; radius: parent.radius
                            color: "transparent"; border.color: gold; border.width: 1
                            visible: cardItem.isMatched
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite; running: cardItem.isMatched
                                NumberAnimation { to: 0.1; duration: 900; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 0.8; duration: 900; easing.type: Easing.InOutSine }
                            }
                        }

                        Column {
                            anchors.centerIn: parent; spacing: Math.round(4 * dp)
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: {
                                    var d = gameSection.cardData[gameSection.shuffled[index]];
                                    return d ? d.icon : "";
                                }
                                font.pointSize: Math.round(20 * dp)
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: {
                                    var d = gameSection.cardData[gameSection.shuffled[index]];
                                    return d ? d.label : "";
                                }
                                font.pointSize: Math.round(7 * dp); font.bold: true
                                color: cardItem.isMatched ? gold : cream
                            }
                        }
                    }
                }
            }
        }

        // ── INSTRUCTIONS overlay — inaonyeshwa kwanza kabla mchezo haujaanza ──
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.88)
            visible: gameSection.showInstructions
            opacity: gameSection.showInstructions ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 350 } }

            Column {
                anchors.centerIn: parent
                width: parent.width - Math.round(48 * dp)
                spacing: Math.round(14 * dp)

                // Kichwa
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\uD83C\uDFAE Mchezo wa Kumbukumbu"
                    font.pointSize: Math.round(13 * dp); font.bold: true; color: gold
                    horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; width: parent.width
                }

                // CCM divider
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.8; height: Math.round(1 * dp)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.3; color: Qt.rgba(0.96, 0.77, 0.0, 0.5) }
                        GradientStop { position: 0.7; color: Qt.rgba(0.96, 0.77, 0.0, 0.5) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                // Maelezo ya mchezo — hatua kwa hatua
                Repeater {
                    model: [
                        {n:"1", t:"Gusa card yoyote kuigeua"},
                        {n:"2", t:"Kisha gusa card nyingine"},
                        {n:"3", t:"Zikifanana — zinabaki wazi \u2705, unapata pointi"},
                        {n:"4", t:"Hazifanani — zinarudi nyuma \uD83D\uDD04, unapoteza pointi"},
                        {n:"5", t:"Pata pairs zote 6 kushinda!"}
                    ]
                    delegate: Item {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: instrNumCircle.width + Math.round(10 * dp) + instrTxt.implicitWidth
                        height: Math.round(28 * dp)
                        Rectangle {
                            id: instrNumCircle
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                            width: Math.round(22 * dp); height: Math.round(22 * dp)
                            radius: Math.round(11 * dp); color: green
                            border.color: greenLight; border.width: 1
                            Text { anchors.centerIn: parent; text: modelData.n; font.pointSize: Math.round(8 * dp); font.bold: true; color: gold }
                        }
                        Text {
                            id: instrTxt
                            anchors.left: instrNumCircle.right; anchors.leftMargin: Math.round(10 * dp)
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.t; font.pointSize: Math.round(9 * dp); color: cream
                        }
                    }
                }

                // CCM divider
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.8; height: Math.round(1 * dp)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.3; color: Qt.rgba(0.0, 0.55, 0.0, 0.5) }
                        GradientStop { position: 0.7; color: Qt.rgba(0.0, 0.55, 0.0, 0.5) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                // Kitufe cha kuanza
                Rectangle {
                    id: startBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: startRow.implicitWidth + Math.round(36 * dp)
                    height: Math.round(46 * dp); radius: Math.round(23 * dp)
                    color: startMA.pressed ? Qt.rgba(0.96, 0.77, 0.0, 0.30) : Qt.rgba(0.96, 0.77, 0.0, 0.15)
                    border.color: gold; border.width: Math.round(2 * dp)
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    // CCM stripe
                    Rectangle {
                        anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                        height: Math.round(3 * dp); radius: Math.round(23 * dp)
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
                        id: startRow
                        anchors.centerIn: parent; spacing: Math.round(8 * dp)
                        Text { text: "\uD83C\uDFAE"; font.pointSize: Math.round(14 * dp); anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Anza Mchezo"; font.pointSize: Math.round(12 * dp); font.bold: true; color: gold; anchors.verticalCenter: parent.verticalCenter }
                    }
                    MouseArea {
                        id: startMA
                        anchors.fill: parent
                        onPressed:  { startBtn.scale = 0.95; }
                        onReleased: { startBtn.scale = 1.0; gameSection.showInstructions = false; }
                        onCanceled: { startBtn.scale = 1.0; }
                    }
                }
            }
        }

        // ── WIN overlay ───────────────────────────────────────────────────────
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.82)
            visible: gameSection.gameWon
            opacity: gameSection.gameWon ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 400 } }

            Column {
                anchors.centerIn: parent; spacing: Math.round(16 * dp)

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\uD83C\uDF89"; font.pointSize: Math.round(40 * dp)
                    SequentialAnimation on scale {
                        loops: Animation.Infinite; running: gameSection.gameWon
                        NumberAnimation { to: 1.15; duration: 600; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0;  duration: 600; easing.type: Easing.InOutSine }
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Hongera!"; font.pointSize: Math.round(22 * dp); font.bold: true; color: gold
                }
                // Stats card
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: winStatsRow.implicitWidth + Math.round(48 * dp)
                    height: Math.round(64 * dp)
                    radius: Math.round(14 * dp); color: darkCard
                    border.color: gold; border.width: Math.round(1 * dp)
                    Row {
                        id: winStatsRow
                        anchors.centerIn: parent; spacing: Math.round(22 * dp)
                        Column { spacing: Math.round(2 * dp)
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "\uD83C\uDFAF"; font.pointSize: Math.round(14 * dp) }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: gameSection.moves; font.pointSize: Math.round(12 * dp); font.bold: true; color: cream }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Hatua"; font.pointSize: Math.round(7 * dp); color: creamDim }
                        }
                        Rectangle { width: 1; height: Math.round(36 * dp); color: Qt.rgba(1,1,1,0.15); anchors.verticalCenter: parent.verticalCenter }
                        Column { spacing: Math.round(2 * dp)
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "\u2B50"; font.pointSize: Math.round(14 * dp) }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Math.round(gameSection.score) + "/100"
                                font.pointSize: Math.round(12 * dp); font.bold: true
                                color: gameSection.score >= 75 ? gold : gameSection.score >= 50 ? greenLight : gameSection.score >= 0 ? cream : "#ff6666"
                            }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Pointi"; font.pointSize: Math.round(7 * dp); color: creamDim }
                        }
                        Rectangle { width: 1; height: Math.round(36 * dp); color: Qt.rgba(1,1,1,0.15); anchors.verticalCenter: parent.verticalCenter }
                        Column { spacing: Math.round(2 * dp)
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "\uD83C\uDFC6"; font.pointSize: Math.round(14 * dp) }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: gameSection.score >= 100 ? "Bora!"
                                    : gameSection.score >= 75  ? "Safi!"
                                    : gameSection.score >= 50  ? "Vizuri"
                                    : gameSection.score >= 0   ? "Jaribu"
                                    :                            "Rudia"
                                font.pointSize: Math.round(12 * dp); font.bold: true
                                color: gameSection.score >= 75 ? gold : gameSection.score >= 50 ? greenLight : gameSection.score >= 0 ? cream : "#ff6666"
                            }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Daraja"; font.pointSize: Math.round(7 * dp); color: creamDim }
                        }
                    }
                }

                // Restart button
                Rectangle {
                    id: restartBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: restartRow.implicitWidth + Math.round(32 * dp)
                    height: Math.round(44 * dp); radius: Math.round(22 * dp)
                    color: restartMA.pressed ? Qt.rgba(0.96, 0.77, 0.0, 0.30) : Qt.rgba(0.96, 0.77, 0.0, 0.15)
                    border.color: gold; border.width: Math.round(2 * dp)
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    Rectangle {
                        anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                        height: Math.round(3 * dp); radius: Math.round(22 * dp)
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
                        id: restartRow
                        anchors.centerIn: parent; spacing: Math.round(8 * dp)
                        Text { text: "\uD83D\uDD04"; font.pointSize: Math.round(14 * dp); anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Cheza Tena"; font.pointSize: Math.round(11 * dp); font.bold: true; color: gold; anchors.verticalCenter: parent.verticalCenter }
                    }
                    MouseArea {
                        id: restartMA
                        anchors.fill: parent
                        onPressed:  { restartBtn.scale = 0.95; }
                        onReleased: { restartBtn.scale = 1.0; gameSection.initGame(); gameSection.showInstructions = false; }
                        onCanceled: { restartBtn.scale = 1.0; }
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
        visible: section >= 1 && section <= 6 && !lightboxOpen
        opacity: (section >= 1 && section <= 6) ? 1.0 : 0.0
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
                    {icon:"\uD83D\uDDD3",  label:"Maisha",    sec:2},
                    {icon:"\u2605",        label:"Mafanikio", sec:3},
                    {icon:"\uD83D\uDCAC",  label:"Maneno",    sec:4},
                    {icon:"\uD83D\uDDBC",  label:"Picha",     sec:5},
                    {icon:"\uD83C\uDFAE",  label:"Mchezo",    sec:6}
                ]
                delegate: Item {
                    width: Math.round(app.width / 6)
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

    // ════════════════════════════════════════════════
    // TIMELINE  (section 6)
    // ════════════════════════════════════════════════
    Item {
        anchors.fill: parent
        visible: opacity > 0
        opacity: section === 2 ? 1.0 : 0.0
        x:       section === 2 ? 0 : (section < 2 ? app.width * 0.18 : -app.width * 0.18)
        Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        Behavior on x       { NumberAnimation { duration: 350; easing.type: Easing.OutCubic  } }

        Rectangle {
            id: h6
            anchors.top: parent.top; width: parent.width; height: Math.round(54 * dp); color: "#0a160a"
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Qt.rgba(0.0, 0.50, 0.0, 0.40) }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom
                height: 2; radius: 1; color: gold; width: 0
                NumberAnimation on width { to: h6TitleRow.implicitWidth + Math.round(16 * dp); duration: 350; easing.type: Easing.OutCubic; running: true }
            }
            Rectangle {
                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: Math.round(14 * dp)
                width: Math.round(36 * dp); height: Math.round(36 * dp); radius: Math.round(18 * dp)
                color: h6BackMA.pressed ? Qt.rgba(0.0, 0.55, 0.0, 0.30) : Qt.rgba(0.0, 0.50, 0.0, 0.12)
                border.color: Qt.rgba(0.0, 0.50, 0.0, 0.40); border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
                Text { anchors.centerIn: parent; text: "\u2190"; font.pointSize: Math.round(14 * dp); color: gold }
                MouseArea { id: h6BackMA; anchors.fill: parent; onClicked: { section = 0; } }
            }
            Row {
                id: h6TitleRow
                anchors.centerIn: parent; spacing: Math.round(8 * dp)
                Text { text: "\uD83D\uDDD3"; font.pointSize: Math.round(14 * dp); anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Safari ya Maisha"; font.pointSize: Math.round(12 * dp); font.bold: true; color: cream; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Flickable {
            anchors.top: h6.bottom; anchors.bottom: parent.bottom
            anchors.bottomMargin: Math.round(52 * dp)
            width: parent.width
            contentWidth: width
            contentHeight: tlCol.implicitHeight + Math.round(40 * dp)
            clip: true; boundsBehavior: Flickable.StopAtBounds

            Column {
                id: tlCol
                width: parent.width - Math.round(24 * dp)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.topMargin: Math.round(20 * dp)
                spacing: 0

                Repeater {
                    model: [
                        {yr:"1922", icon:"\uD83C\uDF1F", title:"Kuzaliwa Butiama",
                         body:"Julius Kambarage Nyerere alizaliwa tarehe 13 Aprili 1922 huko Butiama, Mara. Alikuwa mtoto wa chifu Nyerere Burito.",
                         hi:"#f5c400"},
                        {yr:"1937", icon:"\uD83C\uDFEB", title:"Kuanza Masomo",
                         body:"Alianza masomo ya msingi akiwa na miaka 12. Bidii yake ilimsaidia kupita haraka na kujitofautisha na wenzake.",
                         hi:"#00aa00"},
                        {yr:"1943", icon:"\uD83C\uDF93", title:"Chuo cha Makerere",
                         body:"Alikubaliwa Chuo Kikuu cha Makerere, Uganda. Alihitimu BA mwaka 1945 na kurudi Tanzania kufundisha.",
                         hi:"#f5c400"},
                        {yr:"1949", icon:"\u2708\uFE0F",  title:"Edinburgh, Scotland",
                         body:"Alipata nafari ya kusomea MA katika Chuo Kikuu cha Edinburgh. Alihitimu mwaka 1952 — mmoja wa Watanzania wa kwanza kusomea Ulaya.",
                         hi:"#00aa00"},
                        {yr:"1954", icon:"\uD83C\uDDF9\uD83C\uDDFF", title:"Kuanzisha TANU",
                         body:"Alianzisha Tanganyika African National Union (TANU) — chama kilichopigana kwa amani kupata uhuru wa Tanganyika.",
                         hi:"#f5c400"},
                        {yr:"1958", icon:"\uD83D\uDDE3\uFE0F",  title:"Uchaguzi Mkubwa",
                         body:"TANU ilishinda uchaguzi mkubwa. Serikali ya Uingereza ilianza mazungumzo ya kujitoa Tanzania.",
                         hi:"#00aa00"},
                        {yr:"1961", icon:"\uD83C\uDF89", title:"Uhuru wa Tanganyika",
                         body:"Tanganyika ilipata uhuru tarehe 9 Desemba 1961. Nyerere akawa Waziri Mkuu, halafu Rais wa kwanza mwaka 1962.",
                         hi:"#f5c400"},
                        {yr:"1964", icon:"\uD83E\uDD1D", title:"Muungano wa Tanzania",
                         body:"Tanganyika na Zanzibar ziliungana tarehe 26 Aprili 1964. Nyerere akawa Rais wa kwanza wa Tanzania.",
                         hi:"#00aa00"},
                        {yr:"1967", icon:"\uD83C\uDFD8", title:"Azimio la Arusha",
                         body:"Alitangaza Azimio la Arusha — dira ya Ujamaa na Kujitegemea. Benki na mashirika vikataifishwa kwa manufaa ya wananchi.",
                         hi:"#f5c400"},
                        {yr:"1967", icon:"\uD83D\uDCDA", title:"Elimu kwa Wote (UPE)",
                         body:"Sera ya Elimu ya Msingi kwa Wote ilisababisha ongezeko kubwa — kutoka 25% hadi zaidi ya 90% ya watoto wanaosoma.",
                         hi:"#00aa00"},
                        {yr:"1979", icon:"\uD83E\uDD4A", title:"Ukombozi wa Uganda",
                         body:"Baada ya Idi Amin kuvamia Tanzania, alituma jeshi na kuushinda. Uganda ilipata uhuru wake mwaka 1979.",
                         hi:"#f5c400"},
                        {yr:"1985", icon:"\uD83D\uDC4B", title:"Kujiuzulu kwa Heshima",
                         body:"Alijiuzulu urais kwa hiari — mfano wa kipekee barani Afrika. 'Nitawaachia serikali safi, si hazina kubwa.'",
                         hi:"#00aa00"},
                        {yr:"1990", icon:"\uD83C\uDF0D", title:"Upatanishi Afrika",
                         body:"Aliendelea kupigana dhidi ya ubaguzi wa rangi Afrika Kusini na kusaidia upatanishi wa migogoro ya Afrika kama Burundi.",
                         hi:"#f5c400"},
                        {yr:"1999", icon:"\uD83C\uDF39", title:"Kufariki kwa Amani",
                         body:"Mwalimu alifariki tarehe 14 Oktoba 1999 London, akiwa na miaka 77. Alizikwa Butiama — nyumbani kwake.",
                         hi:"#00aa00"}
                    ]

                    delegate: Item {
                        width: parent.width
                        height: tlCard.height + Math.round(8 * dp)

                        // Vertical line
                        Rectangle {
                            anchors.left: parent.left; anchors.leftMargin: Math.round(28 * dp)
                            anchors.top: parent.top; anchors.bottom: parent.bottom
                            width: Math.round(2 * dp)
                            color: Qt.rgba(0.96, 0.77, 0.0, 0.15)
                        }

                        // Dot on line
                        Rectangle {
                            anchors.left: parent.left; anchors.leftMargin: Math.round(22 * dp)
                            anchors.top: parent.top; anchors.topMargin: Math.round(16 * dp)
                            width: Math.round(14 * dp); height: Math.round(14 * dp)
                            radius: Math.round(7 * dp)
                            color: modelData.hi
                            border.color: "#050f05"; border.width: Math.round(2 * dp)
                            opacity: 0
                            SequentialAnimation on opacity {
                                PauseAnimation  { duration: index * 70 }
                                NumberAnimation { from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic }
                            }
                            // Pulse ring
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width + Math.round(8 * dp)
                                height: parent.height + Math.round(8 * dp)
                                radius: width / 2; color: "transparent"
                                border.color: modelData.hi; border.width: 1
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite; running: section === 2
                                    PauseAnimation  { duration: index * 100 }
                                    NumberAnimation { from: 0.5; to: 0.0; duration: 1200; easing.type: Easing.OutCubic }
                                    PauseAnimation  { duration: 300 }
                                    NumberAnimation { from: 0.0; to: 0.5; duration: 0 }
                                }
                            }
                        }

                        // Card
                        Rectangle {
                            id: tlCard
                            anchors.left: parent.left; anchors.leftMargin: Math.round(48 * dp)
                            anchors.right: parent.right
                            height: tlInner.implicitHeight + Math.round(16 * dp)
                            radius: Math.round(12 * dp)
                            color: darkCard
                            border.color: Qt.rgba(0.96, 0.77, 0.0, 0.12); border.width: 1
                            opacity: 0
                            SequentialAnimation on opacity {
                                PauseAnimation  { duration: 100 + index * 70 }
                                NumberAnimation { from: 0; to: 1; duration: 350; easing.type: Easing.OutCubic }
                            }
                            SequentialAnimation on anchors.leftMargin {
                                PauseAnimation  { duration: 100 + index * 70 }
                                NumberAnimation { from: Math.round(64 * dp); to: Math.round(48 * dp); duration: 350; easing.type: Easing.OutCubic }
                            }
                            // Color left border
                            Rectangle {
                                anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                                anchors.margins: Math.round(8 * dp); width: Math.round(3 * dp); radius: Math.round(2 * dp)
                                color: modelData.hi
                            }
                            Column {
                                id: tlInner
                                anchors.left: parent.left; anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: Math.round(18 * dp); anchors.rightMargin: Math.round(12 * dp)
                                spacing: Math.round(4 * dp)
                                Row {
                                    spacing: Math.round(8 * dp)
                                    Rectangle {
                                        height: Math.round(20 * dp); width: yrLbl.implicitWidth + Math.round(12 * dp)
                                        radius: Math.round(10 * dp)
                                        color: Qt.rgba(0.96, 0.77, 0.0, 0.12)
                                        border.color: modelData.hi; border.width: 1
                                        Text { id: yrLbl; anchors.centerIn: parent; text: modelData.yr; font.pointSize: Math.round(7 * dp); font.bold: true; color: modelData.hi }
                                    }
                                    Text { text: modelData.icon; font.pointSize: Math.round(12 * dp); anchors.verticalCenter: parent.verticalCenter }
                                }
                                Text { text: modelData.title; font.pointSize: Math.round(10 * dp); font.bold: true; color: cream; wrapMode: Text.WordWrap; width: parent.width }
                                Text { text: modelData.body;  font.pointSize: Math.round(8.5 * dp); color: creamDim; wrapMode: Text.WordWrap; width: parent.width; lineHeight: 1.4; lineHeightMode: Text.ProportionalHeight }
                            }
                        }
                    }
                }

                Item { width: 1; height: Math.round(16 * dp) }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.7; height: Math.round(1 * dp)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.3; color: Qt.rgba(0.96, 0.77, 0.0, 0.35) }
                        GradientStop { position: 0.7; color: Qt.rgba(0.96, 0.77, 0.0, 0.35) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                Item { width: 1; height: Math.round(10 * dp) }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\uD83C\uDF39 1922 – 1999 \uD83C\uDF39"
                    font.pointSize: Math.round(9 * dp); color: goldDim; font.italic: true
                }
                Item { width: 1; height: Math.round(16 * dp) }
            }
        }
    }

}
