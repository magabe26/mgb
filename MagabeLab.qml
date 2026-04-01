// ─────────────────────────────────────────────────────────────────────────────
//  Copyright 2026 - MagabeLab (Tanzania). All Rights Reserved.
//  Author Edwin Magabe
// ─────────────────────────────────────────────────────────────────────────────

import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import Qt.labs.settings 1.0

Rectangle {
    id: app
    width:  parent ? parent.width  : 400
    height: parent ? parent.height : 800
    color: "#020d0d"


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
    function close() {
        typeTimer.stop();
        pauseTimer.stop();

        closeIfInsideApp();
        closeIfQMLDialogApp();
        ad();
    }


    Connections{
        target: parent
        ignoreUnknownSignals: true
        onVisibleChanged:{
            if(visible && !typeTimer.running){
                if (frogSettings.savedName !== "") {
                    // Jina linajulikana — ruka moja kwa moja kwenye chat
                    frogScene.startChat(frogSettings.savedName);
                } else {
                    // Uliza jina
                    frogScene.greetMode = "ask";
                    bubbleText.startTypewriter("Unaitwa nani? 🐸");
                }
            }
        }
    }

    // ── Frog programmer in a pond ────────────────────────────────────
    Item {
        id: frogScene
        width: app.width
        height: frogScene.greetMode === "promo" ? 460 : 300
        Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        clip: true

        // ── Sky color shift (dusk → night → dawn loop) ────────────────
        Rectangle {
            id: skyBg
            anchors.fill: parent
            radius: 10
            z: 0
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

        // ── QSettings — kukumbuka jina na phrases zilizosomwa ─────────
        Settings {
            id: frogSettings
            category: "FrogGreeting"
            property string savedName: ""
            property string seenPhrases: ""  // phrases zilizosomwa, separator "||"
        }

        // ── State: "ask" | "chat" ─────────────────────────────────────
        property string greetMode: "ask"
        property string userName: ""

        // ── Contacts (badilisha maelezo hapa) ─────────────────────────
        readonly property string contactWhatsApp: "https://wa.me/255789081122?text=Habari%2C%20nataka%20kujua%20zaidi%20kuhusu%20huduma%20zako"
        readonly property string contactWebsite:  "https://magabelab-tz.web.app"
        readonly property string contactEmail:    "mailto:magabelab.tz@gmail.com?subject=Nahitaji%20Huduma%20za%20Tech"

        function showPromo() {
            typeTimer.stop();
            pauseTimer.stop();
            frogScene.greetMode = "promo";
        }

        function hidePromo() {
            frogScene.greetMode = "chat";
            if (frogScene.sessionPhrases.length > 0) {
                frogScene.typeNextPhrase();
            }
        }

        // ── Pool kubwa ya phrases (elimu + sayansi) ───────────────────
        // Zinachanganywa kwa nasibu kila app inapoanza
        property var allPhrases: [
            // --- KOMPYUTA, CODING NA AI ---
            "Coding ni kutatua matatizo kwa herufi! ⌨️",
            "Usihofu 'Error', hiyo ni fursa ya kujifunza 🐛",
            "AI haitachukua kazi yako, mtu anayeijua AI ndiye atakayeichukua! 🤖",
            "Kila programu kubwa ilianza na 'Hello World' 🌍",
            "Programmer ni mchawi anayetumia 'logic' badala ya fimbo! ✨",
            "Python siyo nyoka tu, ni lugha ya kutajirika! 🐍",
            "Data ndiyo dhahabu mpya ya karne hii 💎",
            "Keyboard yako ni silaha ya ukombozi wa fikra ⚔️",
            "Algorithm ndiyo ramani ya kuelekea kwenye jibu 🗺️",
            "Internet ni darasa kubwa zaidi duniani — fungua mlango! 🌐",
            "Simu yako ina nguvu kuliko kompyuta iliyopeleka watu mwezini! 🚀",
            "Jifunze kutoa amri kwa kompyuta, siyo kupewa amri na simu 📱",
            "Kusoma 'Code' za wengine ni kama kusoma kitabu cha siri 📖",
            "Debugging ni kama kuwa mpelelezi kwenye sinema ya kusisimua 🔍",
            "Open Source: Ujuzi wa pamoja unajenga dunia bora 🤝",
            "Usiwe mtumiaji tu wa apps, uwe mtengenezaji! 🛠️",
            "Cloud Computing: Ofisi yako iko popote ulipo ☁️",
            "Cyber Security: Linda taarifa zako, linda mustakabali wako 🛡️",
            "Blockchain siyo Bitcoin tu, ni mfumo wa uaminifu wa kidijitali ⛓️",
            "Kila 'Click' unayofanya ina hesabu nyuma yake 🖱️",

            // --- HISABATI (Lugha ya Ulimwengu) ---
            "Hesabu ni muziki wa akili 🎵",
            "Pi (π) haina mwisho, kama ndoto zako! ♾️",
            "Maisha ni equation; ukitaka matokeo bora, badili 'Variables' 🧮",
            "Kujua hesabu ni kuwa na jicho la tatu la kuona dunia 👁️",
            "Zero (0) ilianzia hapa Afrika — nguvu ya kitu ambacho hakipo! 0️⃣",
            "Asilimia ni mchezo wa namba, uelewe uwe tajiri 📈",
            "Fibonacci yuko kwenye ua, konokono, na hata galaxy! 🌀",
            "Jiometri: Jifunze pembe za dunia ili usichanganywe 📐",
            "Hisabati ni lugha pekee ambayo haina uongo 💯",
            "Ukielewa hesabu, umeelewa jinsi ulimwengu unavyopumua 🌍",

            // --- SAYANSI NA TEKNOLOJIA (General Science) ---
            "Sayansi siyo somo, ni jinsi unavyofikiri 🧠",
            "Atomu ni ndogo, lakini nguvu yake inatikisa dunia 💥",
            "Mvuto wa dunia (Gravity) unatuweka sote pamoja 🌏",
            "Mwanga una kasi, lakini mawazo yako yana kasi zaidi! ⚡",
            "DNA ni 'Source Code' ya mwili wako 🧬",
            "Seli trilioni 37 zinafanya kazi ili wewe uweze kucheka leo 😊",
            "Kila unachokiona kimeundwa na nyota zilizolipuka miaka bilioni iliyopita ✨",
            "Biolojia ni teknolojia ya asili — isome! 🌿",
            "Kemia ni mapenzi kati ya elementi mbili 🧪",
            "Fizikia inakufundisha kwanini ndege inapaa na jiwe linaanguka ✈️",

            // --- MOTISHA NA UJASIRI (Growth Mindset) ---
            "Tanzania inasubiri 'Silicon Valley' yake — ianzishe wewe! 🇹🇿",
            "Hakuna akili ndogo, kuna akili ambayo haijachokozwa tu ⚡",
            "Elimu ni ufunguo, lakini 'Action' ndiyo inayofungua mlango 🔑",
            "Ujuzi ni mali ambayo mwizi hawezi kuiba 📚",
            "Kufeli ni sehemu ya 'Beta Testing' ya maisha yako 🛠️",
            "Usilinganishe 'Step 1' yako na 'Step 100' ya mtu mwingine 🌱",
            "Mtaalamu yeyote alianza kama mgeni anayeuliza maswali ❓",
            "Akili yako ni kama misuli; itumie ili ikue 💪",
            "Soma leo ili uongoze kesho 🎓",
            "Kutaka kujua (Curiosity) ni chanzo cha uvumbuzi wote 🔭",
            "Ubunifu hauna kikomo, labda tu kile unachojiwekea akilini 🌈",
            "Wenye ndoto kubwa hawalali, wanafanya kazi! 🚀",
            "Mazingira yako yasikuamulie ukubwa wa fikra zako 🏔️",
            "Jifunze kitu kipya kila siku, hata kama ni kidogo 🤏",
            "Teknolojia ni daraja la kumtoa kijana wa kijijini na kumpeleka duniani 🌉",
            "Kuwa 'Problem Solver', siyo 'Problem Complainer' 💡",
            "Dunia haina upendeleo, inajali nani ana ujuzi zaidi 🌍",
            "Usiogope kuuliza 'Kwa nini?'; hapo ndipo sayansi huanzia 🧐",
            "Kila kosa ni 'Log' ya kukuonyesha wapi pa kurekebisha 📝",
            "Wewe ni mbunifu wa maisha yako mwenyewe 🎨",

            // --- AI NA FUTURE TRENDS ---
            "AI ni msaidizi wako, mfundishe akusaidie kazi 🤖",
            "Machine Learning: Mashine zinajifunza, na wewe je? 🧠",
            "Magari yanayojiendesha yanakuja, yaandae barabara zetu kidijitali 🚗",
            "Roboti hazitachukua nafasi ya binadamu, zitachukua kazi zenye kuchosha 🦾",
            "Virtual Reality (VR): Tembelea ulimwengu mwingine ukiwa chumbani kwako 🽽",
            "3D Printing: Badili mawazo yako kuwa vitu halisi papo hapo 🖨️",
            "Big Data: Maamuzi bora yanatolewa na namba, siyo hisia 📊",
            "Internet of Things (IoT): Hebu fikiria jokofu likikuambia maziwa yameisha! 🥛",
            "SpaceX inaenda Mars, Tanzania iende wapi? Anza kufikiri 🚀",
            "Teknolojia ya kijani (Green Tech) ndiyo itakayookoa dunia yetu 🌳",

            // --- ZAIDI KWA AJILI YA VIJANA WA TZ (Local Touch) ---
            "Kijana wa kitanzania: Coding ni ajira bila kusubiri barua! 💼",
            "Tumia bando lako kupata ujuzi, siyo kupata 'likes' tu 📱",
            "Mwanza kumenoga kwa mawe, iweke Mwanza kwenye ramani ya tech 💎",
            "Dar es Salaam ina joto, lakini akili yako iwe na 'Cool' ya AI 🧊",
            "Kilimo kwanza, teknolojia mbele — tumia Drone shambani! 🚁",
            "Utalii wetu unaweza kuboreshwa kwa Apps bora zaidi 🦁",
            "Kiswahili ni lugha yetu, kitafsiri kwenye msimbo wa kompyuta 🇹🇿",
            "Usiishie kuwa 'Technician', kuwa 'Engineer' wa fikra 🏗️",
            "Vijana wa Arusha: Chuga ina vipaji, vigeuze kuwa Programu! 🏔️",
            "Kutoka Mbeya hadi Mtwara, internet ni moja — jifunze! 🌊",
            "Biashara ya sasa hivi inahitaji 'Website', siyo bango pekee 🏢",
            "Software Engineering ni biashara isiyohitaji fremu ya duka 🏪",
            "Unajua kurekebisha simu? Jifunze na kutengeneza mifumo yake 📲",
            "Dunia ni kijiji, na wewe ni mkazi wa kidijitali 🏠",
            "Kuwa 'Blogger' ni vizuri, lakini kuwa 'Developer' ni bora zaidi 💻",
            "Afya ya jamii inaweza kuimarishwa na Data unazokusanya 🏥",
            "Elimu ya bure iko YouTube, nidhamu ya kuisoma iko kwako 📺",
            "Usiogope Hesabu, hesabu ndiyo lugha ya mzungu, mwarabu na mwafrika 🤝",
            "Kompyuta haina ubaguzi; inakupa unachostahili kulingana na juhudi zako ⚖️",
            "Kazi za kesho hazijavumbuliwa bado — zivumbue wewe! 🧪",
            "Uvumbuzi ni kuona kile kila mtu anakiona, na kufikiri kile hakuna aliyefikiri 💭",
            "Mwanasayansi wa kwanza wa Tanzania anaweza kuwa wewe 🥇",
            "Tanzania ya kidijitali inajengwa na mistari ya code unayoandika leo 🏗️",
            "Weka 'Comment' kwenye code zako, na weka 'Impact' kwenye jamii yako ✍️",
            "Sayansi ni urithi wetu sote, siyo wa watu fulani tu 🏛️",
            "Usiishie kusoma vitabu, anza kuandika historia yako ya tech 🖋️",
            "Kila mtoto wa kitanzania ana uwezo wa kuwa Elon Musk wa Afrika 🦁",
            "Ubunifu ni kutumia rasilimali chache kupata matokeo makubwa 💡",
            "Nguvu ya atomu iko ndani ya elimu unayopata sasa ⚛️",
            "Maisha ni kama mchezo wa video; pambana uende 'Level' inayofuata! 🎮",

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

        // Phrases za session hii (hazijasomwa bado)
        property var sessionPhrases: []
        property int phraseIdx: 0

        // ── Seen-set helpers ──────────────────────────────────────────

        // Soma seen set kutoka QSettings → JavaScript Set-like object (plain object)
        function loadSeenSet() {
            var raw = frogSettings.seenPhrases;
            if (raw === "" || raw === undefined) { return {}; }
            var obj = {};
            var parts = raw.split("||");
            for (var i = 0; i < parts.length; i++) {
                if (parts[i] !== "") { obj[parts[i]] = true; }
            }
            return obj;
        }

        // Hifadhi seen set kwenye QSettings
        function saveSeenSet(obj) {
            var keys = [];
            for (var k in obj) { if (obj.hasOwnProperty(k)) { keys.push(k); } }
            frogSettings.seenPhrases = keys.join("||");
        }

        // Ongeza phrase moja kwenye seen set na hifadhi
        function markSeen(phrase) {
            var obj = loadSeenSet();
            obj[phrase] = true;
            saveSeenSet(obj);
        }

        // Chuja phrases ambazo hazijasomwa bado
        function getUnseen() {
            var seen = loadSeenSet();
            var unseen = [];
            for (var i = 0; i < frogScene.allPhrases.length; i++) {
                var p = frogScene.allPhrases[i];
                if (!seen[p]) { unseen.push(p); }
            }
            return unseen;
        }

        // Fisher-Yates shuffle
        function shufflePhrases(arr) {
            var a = arr.slice();
            for (var i = a.length - 1; i > 0; i--) {
                var j = Math.floor(Math.random() * (i + 1));
                var tmp = a[i]; a[i] = a[j]; a[j] = tmp;
            }
            return a;
        }

        // Jenga session — greetings + unseen phrases zilizoshufflewa
        function buildSession(name) {
            var unseen = getUnseen();
            if (unseen.length === 0) {
                // Bank imeisha — futa seen set, anza upya na zote
                frogSettings.seenPhrases = "";
                unseen = frogScene.allPhrases.slice();
            }
            var greetings = [
                        "Habari " + name + "! 😊",
                        "Karibu " + name + "! 🐸",
                        name + ", tujifunze pamoja! 📚",
                        name + ", wewe ni programu inayokua! 💻"
                    ];
            return greetings.concat(shufflePhrases(unseen));
        }

        // Anza maongezi
        function startChat(name) {
            frogScene.userName = name;
            frogScene.greetMode = "chat";
            frogScene.sessionPhrases = buildSession(name);
            frogScene.phraseIdx = 0;
            typeNextPhrase();
        }

        // Andika phrase — inaita markSeen BAADA ya phrase kukamilika (katika pauseTimer)
        function typeNextPhrase() {
            if (frogScene.sessionPhrases.length === 0) { return; }
            var p = frogScene.sessionPhrases[frogScene.phraseIdx];
            if (p === undefined) { return; }
            bubbleText.startTypewriter(p);
        }

        // confirmName iko katika frogScene scope — inafanya kazi!
        function confirmName() {
            var name = nameInput.text.trim();
            if (name.length === 0) { return; }
            frogSettings.savedName = name;
            frogSettings.seenPhrases = "";  // anza upya kwa jina jipya
            nameInput.text = "";
            nameInput.focus = false;
            Qt.inputMethod.hide();
            frogScene.startChat(name);
        }

        // Badili jina — rudi kwenye ask mode
        function resetName() {
            typeTimer.stop();
            pauseTimer.stop();
            frogSettings.savedName = "";
            frogSettings.seenPhrases = "";
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
            // Max upana = scene - margins pande zote
            width: Math.min(bubbleRect.width, frogScene.width - 24)
            height: bubbleRect.height + 12
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 96

            SequentialAnimation on anchors.bottomMargin {
                loops: Animation.Infinite
                NumberAnimation { to: 100; duration: 1200; easing.type: Easing.SineCurve }
                NumberAnimation { to: 96;  duration: 1200; easing.type: Easing.SineCurve }
            }

            Rectangle {
                id: bubbleRect
                // Upana unazingatia scene — maneno marefu yatafanya wrap
                width: Math.min(bubbleText.implicitWidth + 24,
                                frogScene.width - 24)
                height: bubbleText.implicitHeight + 18
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 12; color: "white"
                border.color: "#3cb043"; border.width: 2
                Behavior on height { NumberAnimation { duration: 150 } }
                Behavior on width  { NumberAnimation { duration: 150 } }

                Text {
                    id: bubbleText
                    anchors {
                        left: parent.left;   leftMargin: 12
                        right: parent.right; rightMargin: 12
                        top: parent.top;     topMargin: 9
                        bottom: parent.bottom; bottomMargin: 9
                    }
                    color: "#1a1a1a"
                    font.pointSize: Qt.platform.os === "android" ? 11 : 9
                    font.bold: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter

                    property string fullText: ""
                    property int charCount: 0
                    text: fullText.substring(0, charCount)

                    function startTypewriter(txt) {
                        if (txt === undefined || txt === null) { return; }
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
                        interval: 5500
                        repeat: false
                        onTriggered: {
                            // Hifadhi phrase iliyosomwa kikamilifu
                            var current = frogScene.sessionPhrases[frogScene.phraseIdx];
                            if (current !== undefined) {
                                frogScene.markSeen(current);
                            }

                            var nextIdx = frogScene.phraseIdx + 1;

                            if (nextIdx >= frogScene.sessionPhrases.length) {
                                // Session imeisha — jenga upya na phrases mpya (unseen)
                                frogScene.sessionPhrases = frogScene.buildSession(frogScene.userName);
                                nextIdx = 0;
                            }

                            frogScene.phraseIdx = nextIdx;
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
            width: nameField.width + okBtn.width + 14
            height: 48
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            visible: frogScene.greetMode === "ask"

            onVisibleChanged: {
                if (visible) {
                    nameInput.forceActiveFocus();
                }
            }

            Rectangle {
                id: nameField
                width: 180; height: 44; radius: 8
                color: "#1a2e1a"
                border.color: nameInput.activeFocus ? "#00ff88" : "#3cb043"
                border.width: nameInput.activeFocus ? 2 : 1
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                Behavior on border.width { NumberAnimation { duration: 100 } }

                TextInput {
                    id: nameInput
                    anchors.fill: parent; anchors.margins: 10
                    color: "#00ff88"
                    font.pointSize: Qt.platform.os === "android" ? 15 : 12
                    font.bold: true
                    maximumLength: 18; clip: true
                    verticalAlignment: TextInput.AlignVCenter

                    Text {
                        anchors.fill: parent
                        text: "Jina lako..."
                        color: "#336633"
                        font.pointSize: Qt.platform.os === "android" ? 15 : 12
                        verticalAlignment: Text.AlignVCenter
                        visible: nameInput.text.length === 0 && !nameInput.activeFocus
                    }

                    Keys.onReturnPressed: { frogScene.confirmName(); }
                    Keys.onEnterPressed:  { frogScene.confirmName(); }
                }
            }

            Rectangle {
                id: okBtn
                width: okTxt.implicitWidth + 22; height: 44; radius: 8
                color: okMA.pressed ? "#2a8a30" : "#3cb043"
                anchors.left: nameField.right; anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    id: okTxt
                    anchors.centerIn: parent
                    text: "Sawa ✓"; color: "white"
                    font.pointSize: Qt.platform.os === "android" ? 15 : 12
                    font.bold: true
                }
                MouseArea {
                    id: okMA
                    anchors.fill: parent
                    onClicked: { frogScene.confirmName(); }
                }
            }
        }


        // ── Kitufe cha close ───────────────────
        Rectangle {
            id: closeBtn
            visible: frogScene.greetMode === "chat" || frogScene.greetMode === "ask"
            z: 10
            width: closeTxt.implicitWidth + 22
            height: 34
            radius: 17
            color: "red"
            border.color: "red"
            border.width: 1
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.top: parent.top
            anchors.topMargin: 8
            Behavior on color { ColorAnimation { duration: 100 } }

            Text {
                id: closeTxt
                anchors.centerIn: parent
                text: "X Funga"
                color: Qt.lighter("red",1.8)
                font.pointSize: Qt.platform.os === "android" ? 12 : 10
                font.bold: true
            }
            MouseArea {
                anchors.fill: parent
                onClicked: { app.close(); }
            }
        }

        // ── Kitufe cha "Badili jina" (chat mode tu) ───────────────────
        Rectangle {
            id: changeNameBtn
            visible: frogScene.greetMode === "chat"
            z: 10
            width: changeTxt.implicitWidth + 22
            height: 34
            radius: 17
            color: changeMA.pressed ? "#1a4a1a" : "#0d2e0d"
            border.color: "#3cb043"
            border.width: 1
            anchors.right: closeBtn.left
            anchors.rightMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 8
            Behavior on color { ColorAnimation { duration: 100 } }

            Text {
                id: changeTxt
                anchors.centerIn: parent
                text: "✏️ " + frogScene.userName
                color: "#00cc66"
                font.pointSize: Qt.platform.os === "android" ? 12 : 10
                font.bold: true
            }
            MouseArea {
                id: changeMA
                anchors.fill: parent
                onClicked: { frogScene.resetName(); }
            }
        }

        // ── Kitufe cha promo — juu-kushoto (ask + chat mode) ─────────
        Rectangle {
            id: promoTriggerBtn
            visible: frogScene.greetMode === "chat" || frogScene.greetMode === "ask"
            z: 10
            width: promoTriggerTxt.implicitWidth + 22
            height: 34
            radius: 17
            color: promoTrigMA.pressed ? "#002244" : "#001a33"
            border.color: "#00aaff"
            border.width: 1
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 8
            Behavior on color { ColorAnimation { duration: 100 } }

            Text {
                id: promoTriggerTxt
                anchors.centerIn: parent
                text: "🌐 Huduma zangu"
                color: "#00aaff"
                font.pointSize: Qt.platform.os === "android" ? 12 : 10
                font.bold: true
            }
            MouseArea {
                id: promoTrigMA
                anchors.fill: parent
                onClicked: { frogScene.showPromo(); }
            }
        }

        // ── Panel ya promo ────────────────────────────────────────────
        Rectangle {
            id: promoPanel
            visible: frogScene.greetMode === "promo"
            anchors.fill: parent
            radius: 10
            color: "#050f1a"

            Column {
                anchors.centerIn: parent
                spacing: 10
                width: parent.width - 32

                // Kichwa
                Text {
                    width: parent.width
                    text: "🐸 Je, unahitaji tovuti au aplikesheni?"
                    color: "#00ff88"
                    font.pointSize: Qt.platform.os === "android" ? 14 : 11
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                // Mstari mdogo wa maelezo
                Text {
                    width: parent.width
                    text: "Wasiliana nami kupitia:"
                    color: "#558866"
                    font.pointSize: Qt.platform.os === "android" ? 10 : 8
                    horizontalAlignment: Text.AlignHCenter
                }

                // Vitufe vitatu vya contacts
                // ── Website ───────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: webRow.implicitHeight + 18
                    radius: 10
                    color: webMA.pressed ? "#003322" : "#001a11"
                    border.color: "#00cc66"; border.width: 2
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Row {
                        id: webRow
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: "🌐"
                            font.pointSize: Qt.platform.os === "android" ? 20 : 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            Text {
                                text: "Tovuti / Website"
                                color: "#00cc66"
                                font.pointSize: Qt.platform.os === "android" ? 13 : 10
                                font.bold: true
                            }
                            Text {
                                text: "https://magabelab-tz.web.app"
                                color: "#447755"
                                font.pointSize: Qt.platform.os === "android" ? 10 : 8
                            }
                        }
                    }
                    MouseArea {
                        id: webMA
                        anchors.fill: parent
                        onClicked: { Qt.openUrlExternally(frogScene.contactWebsite); }
                    }
                }

                // ── WhatsApp ──────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: waRow.implicitHeight + 18
                    radius: 10
                    color: waMA2.pressed ? "#1a4d2e" : "#0a2e1a"
                    border.color: "#25D366"; border.width: 2
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Row {
                        id: waRow
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: "💬"
                            font.pointSize: Qt.platform.os === "android" ? 20 : 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            Text {
                                text: "WhatsApp"
                                color: "#25D366"
                                font.pointSize: Qt.platform.os === "android" ? 13 : 10
                                font.bold: true
                            }
                            Text {
                                text: "+255 789 081 122"
                                color: "#1a7a40"
                                font.pointSize: Qt.platform.os === "android" ? 10 : 8
                            }
                        }
                    }
                    MouseArea {
                        id: waMA2
                        anchors.fill: parent
                        onClicked: { Qt.openUrlExternally(frogScene.contactWhatsApp); }
                    }
                }

                // ── Email ─────────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: emailRow.implicitHeight + 18
                    radius: 10
                    color: emailMA.pressed ? "#1a1a33" : "#0a0a22"
                    border.color: "#aaaaff"; border.width: 2
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Row {
                        id: emailRow
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: "📧"
                            font.pointSize: Qt.platform.os === "android" ? 20 : 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            Text {
                                text: "Barua pepe / Email"
                                color: "#aaaaff"
                                font.pointSize: Qt.platform.os === "android" ? 13 : 10
                                font.bold: true
                            }
                            Text {
                                text: "magabelab.tz@gmail.com"
                                color: "#555588"
                                font.pointSize: Qt.platform.os === "android" ? 10 : 8
                            }
                        }
                    }
                    MouseArea {
                        id: emailMA
                        anchors.fill: parent
                        onClicked: { Qt.openUrlExternally(frogScene.contactEmail); }
                    }
                }

                // ── Kitufe cha kurudi ─────────────────────────────────
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: backTxt.implicitWidth + 30
                    height: 36
                    radius: 18
                    color: backMA.pressed ? "#1a1a1a" : "#0d0d0d"
                    border.color: "#444"; border.width: 1
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text {
                        id: backTxt
                        anchors.centerIn: parent
                        text: "← Rudi"
                        color: "#888888"
                        font.pointSize: Qt.platform.os === "android" ? 12 : 10
                        font.bold: true
                    }
                    MouseArea {
                        id: backMA
                        anchors.fill: parent
                        onClicked: { frogScene.hidePromo(); }
                    }
                }
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
