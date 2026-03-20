import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.0
import QtQuick.Window 2.14
import Qt.labs.settings 1.0

Rectangle {
    id: app
    width: parent.width
    height: parent.height
    visible: true
    color: "#020d0d"


    // --- APP PROPERTIES ---
    property int currentIdx: 0
    property int totalScore: 0
    property int timeInterval: 20
    property int timerValue: timeInterval
    property string viewState: "START"
    // Itabadilishwa kuwa ONBOARD Component.onCompleted kama ni mara ya kwanza
    property int maxQuestions: 26
    property int noOfPassedQuestion: 0
    property string answerResult: ""
    property string selectedAnswer: ""
    property int questionsAttempted: maxQuestions
    property int speedBonusTotal: 0
    property int lastSpeedBonus: 0
    property int skippedQuestions: 0

    // --- FEATURES MPYA ---
    property int selectedDifficulty: 0        // 0=Zote, 1=Rahisi, 2=Wastani, 3=Ngumu
    property var selectedCategories: []        // [] = zote, au ["S","M",...] = zilizochaguliwa
    property int countdownValue: 0             // 3,2,1 kabla mchezo haujaanza
    property bool isNewHighscore: false        // true kama IQ mpya ni rekodi

    // --- STREAK ---
    property int currentStreak: 0             // mfululizo wa majibu sahihi
    property int maxStreak: 0                 // rekodi ya streak ya mchezo huu
    property real streakMultiplier: 1.0       // x1, x1.5, x2, x3

    // --- TIME ATTACK MODE ---
    property bool isTimeAttack: false         // true = Time Attack mode
    property int timeAttackSeconds: 120       // sekunde 120 = dakika 2
    property int timeAttackRemaining: 120     // countdown ya Time Attack
    property int timeAttackScore: 0           // maswali sahihi kwenye Time Attack

    // --- FONT SIZE ---
    property real fontScale: 1.0             // 0.85=ndogo, 1.0=kawaida, 1.2=kubwa

    // --- BADGES ---
    property var earnedBadges: []            // badges zilizopatikana mchezo huu

    // Highscore — hifadhiwa kwenye Settings
    Settings {
        id: highscoreSettings
        property int bestIQ: 0
        property bool hasSeenOnboard: false
    }

    // Weka viewState kuwa ONBOARD kama ni mara ya kwanza
    Component.onCompleted: {
        if (!highscoreSettings.hasSeenOnboard) {
            viewState = "ONBOARD";
        }
    }

    // Hifadhi majibu ya kila swali
    ListModel { id: userAnswers }

    Timer {
        id: countdownTimer
        interval: 1000; repeat: true
        onTriggered: {
            if (countdownValue > 1) {
                countdownValue--;
            } else {
                countdownTimer.stop();
                countdownValue = 0;
                startNewGame();
            }
        }
    }

    function startCountdown() {
        countdownValue = 3;
        viewState = "COUNTDOWN";
        countdownTimer.start();
    }

    // --- IQ CATEGORY LOGIC ---
    function getCategory(iq) {
        if (iq >= 140) return "GWIJI";
        if (iq >= 120) return "UPEO WA JUU";
        if (iq >= 110) return "ZAIDI YA WASTANI";
        if (iq >= 90)  return "WASTANI";
        return "UNAHITAJI MAZOEZI";
    }

    function getGrade(iq) {
        if (iq >= 130) return "A+";
        if (iq >= 120) return "A";
        if (iq >= 110) return "B+";
        if (iq >= 100) return "B";
        if (iq >= 90)  return "C";
        if (iq >= 80)  return "D";
        return "E";
    }

    function getGradeColor(iq) {
        if (iq >= 120) return "#00e5ff";
        if (iq >= 100) return "#f0c040";
        if (iq >= 90)  return "#4caf50";
        return "#ef4444";
    }

    // Hesabu mada iliyofanya vizuri zaidi kutoka userAnswers
    function getBestCat() {
        var cats = {}; var bests = {};
        for (var i = 0; i < userAnswers.count; i++) {
            var a = userAnswers.get(i);
            var q = quizModel.count > 0 ? null : null;
            // Find cat from quizModel by matching q text
            for (var j = 0; j < quizModel.count; j++) {
                if (quizModel.get(j).q === a.q) { var c = quizModel.get(j).cat; break; }
            }
            if (!c) c = "?";
            if (!cats[c]) { cats[c] = 0; bests[c] = 0; }
            cats[c]++;
            if (a.wasCorrect) bests[c]++;
        }
        var bestCat = ""; var bestRatio = -1;
        for (var k in cats) {
            var r = cats[k] > 0 ? bests[k] / cats[k] : 0;
            if (r > bestRatio) { bestRatio = r; bestCat = k; }
        }
        var names = {"S":"Sayansi","M":"Hisabati","SP":"Michezo","TK":"Teknolojia",
                     "H":"Historia","A":"Afya","V":"Vitendawili","GEO":"Mitaa & Maeneo",
                     "UR":"Elimu ya Uraia","MK":"Mazingira","BUR":"Burudani",
                     "UT":"Utalii wa TZ","LG":"Mantiki"};
        return bestCat ? (names[bestCat] || bestCat) : "";
    }


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

    function indexToLetter(i){
        return ["A", "B", "C", "D"][i] || "?";
    }


    function cleanOption(text) {
        if (!text) return "";
        // Inafuta mabano na yaliyomo ndani, kisha inafuta nafasi zilizoziada
        return text.replace(/\s*\(.*?\)\s*/g, "").trim();
    }

    // --- QUESTION MODEL (Maswali 26) ---
    ListModel {
        id: iqModel

        ListElement { q: "Ni mwanasayansi gani wa kike aliyegundua mfumo wa hisabati uliowezesha kupatikana kwa GPS?"; a: "Katherine Johnson"; b: "Gladys West"; c: "Marie Curie"; d: "Dorothy Vaughan"; correct: "Gladys West"; cat: "S"; diff: 3 }

        //SAYANSI
        ListElement { q: "Ni gesi gani binadamu anahitaji ili kuishi?"; a: "Nitrogen"; b: "Oxygen"; c: "Carbon"; d: "Hydrogen"; correct: "Oxygen"; cat: "S"; diff: 1 }
        ListElement { q: "Sayari ya karibu zaidi na Jua inaitwa?"; a: "Dunia"; b: "Mercury"; c: "Mars"; d: "Venus"; correct: "Mercury"; cat: "S"; diff: 2 }
        ListElement { q: "Maji huganda (Freezing point) kwenye nyuzi ngapi Celsius?"; a: "100"; b: "0"; c: "50"; d: "-10"; correct: "0"; cat: "S"; diff: 2 }
        ListElement { q: "Sehemu ya seli inayohusika na nishati (Powerhouse) ni?"; a: "Nucleus"; b: "Mitochondria"; c: "Ribosome"; d: "Wall"; correct: "Mitochondria"; cat: "S"; diff: 2 }

        //LOGIC & MATH
        ListElement { q: "Robo ya 200 ikiongezewa 50 unapata?"; a: "100"; b: "150"; c: "75"; d: "250"; correct: "100"; cat: "M"; diff: 2 }
        ListElement { q: "Kama 1=5, 2=25, 3=125, basi 5=?"; a: "625"; b: "1"; c: "3125"; d: "500"; correct: "1"; cat: "LG"; diff: 2 }
        ListElement { q: "Saa kumi na mbili za jioni ni saa ngapi katika mfumo wa saa 24?"; a: "12:00"; b: "18:00"; c: "00:00"; d: "20:00"; correct: "18:00"; cat: "M"; diff: 2 }
        ListElement { q: "Kati ya kilo 1 ya pamba na kilo 1 ya chuma, nini kizito zaidi?"; a: "Chuma"; b: "Pamba"; c: "Zinalingana"; d: "Inategemea"; correct: "Zinalingana"; cat: "LG"; diff: 2 }
        ListElement { q: "Tafuta wastani wa namba hizi: 5, 10, 15, 20, 25"; a: "15"; b: "10"; c: "20"; d: "12"; correct: "15"; cat: "M"; diff: 2 }

        //MICHEZO (SPORTS)
        ListElement { q: "Mchezaji gani wa kwanza wa TZ kucheza Ligi Kuu ya Uingereza (EPL)?"; a: "Samatta"; b: "Msuva"; c: "Ulimwengu"; d: "Ngassa"; correct: "Samatta"; cat: "SP"; diff: 1 }
        ListElement { q: "Timu ya Taifa ya Tanzania inaitwa?"; a: "Taifa Stars"; b: "The Cranes"; c: "Harambee Stars"; d: "Black Stars"; correct: "Taifa Stars"; cat: "SP"; diff: 1 }
        ListElement { q: "Mwanariadha gani alishinda medali ya kwanza ya dhahabu ya Jumuiya ya Madola (1974)?"; a: "Filbert Bayi"; b: "Suleiman Nyambui"; c: "Alphonce Simbu"; d: "Gidamis Shahanga"; correct: "Filbert Bayi"; cat: "SP"; diff: 3 }
        ListElement { q: "Klabu ya Simba SC ilianzishwa mwaka gani?"; a: "1936"; b: "1935"; c: "1940"; d: "1950"; correct: "1936"; cat: "SP"; diff: 1 }

        //COMPUTER SCIENCE & TECHNOLOGY
        ListElement { q: "Katika lugha ya kompyuta, 'RAM' inamaanisha nini?"; a: "Read Access Memory"; b: "Random Access Memory"; c: "Real Access Memory"; d: "Run Access Memory"; correct: "Random Access Memory"; cat: "TK"; diff: 2 }
        ListElement { q: "Ni kifaa kipi ni 'Brain' ya kompyuta?"; a: "Monitor"; b: "CPU"; c: "Hard Disk"; d: "Keyboard"; correct: "CPU"; cat: "TK"; diff: 1 }
        ListElement { q: "Lugha gani inatumika kutengeneza Apps za QML?"; a: "Java"; b: "QML (Qt Quick)"; c: "PHP"; d: "Swift"; correct: "QML (Qt Quick)"; cat: "TK"; diff: 3 }
        ListElement { q: "Kifupi cha 'WWW' ni nini?"; a: "World Wide Web"; b: "Word Wide Web"; c: "World Web Wide"; d: "Web Wide World"; correct: "World Wide Web"; cat: "TK"; diff: 2 }
        ListElement { q: "Ni kampuni gani ilitengeneza mfumo wa Android?"; a: "Apple"; b: "Microsoft"; c: "Google"; d: "Nokia"; correct: "Google"; cat: "TK"; diff: 1 }

        //HESABU & LOGIC
        ListElement { q: "Ni namba gani inafuata?\n2, 5, 11, 23, ..."; a: "35"; b: "47"; c: "46"; d: "50"; correct: "47"; cat: "M"; diff: 2 }
        ListElement { q: "Tafuta thamani ya 'x' kama:\n2x + 10 = 30"; a: "5"; b: "15"; c: "10"; d: "20"; correct: "10"; cat: "M"; diff: 2 }
        ListElement { q: "Kama 3 ni 9, na 4 ni 16, basi 6 ni nini?"; a: "36"; b: "24"; c: "12"; d: "30"; correct: "36"; cat: "LG"; diff: 2 }
        ListElement { q: "Nusu ya robo ya 400 ni ngapi?"; a: "100"; b: "50"; c: "25"; d: "200"; correct: "50"; cat: "M"; diff: 2 }

        //KILIMO NA UVUVI
        ListElement { q: "Zao lipi ni 'Dhahabu ya Kijani' mkoani Kagera na Kilimanjaro?"; a: "Kahawa"; b: "Pamba"; c: "Karafuu"; d: "Chai"; correct: "Kahawa"; cat: "GEO"; diff: 2 }
        ListElement { q: "Ziwa lipi linaongoza kwa uzalishaji wa Sangara Tanzania?"; a: "Victoria"; b: "Tanganyika"; c: "Nyasa"; d: "Eyasi"; correct: "Victoria"; cat: "GEO"; diff: 1 }
        ListElement { q: "Bodi ya Korosho Tanzania (CBT) ina makao makuu mkoa gani?"; a: "Lindi"; b: "Mtwara"; c: "Pwani"; d: "Tanga"; correct: "Mtwara"; cat: "GEO"; diff: 2 }
        ListElement { q: "Zao kuu la biashara visiwani Pemba ni?"; a: "Karafuu"; b: "Tangawizi"; c: "Ulanga"; d: "Mdalasini"; correct: "Karafuu"; cat: "GEO"; diff: 2 }

        //MADINI (MINERALS)
        ListElement { q: "Madini ya kipekee yanayopatikana Tanzania pekee duniani ni?"; a: "Dhahabu"; b: "Tanzanite"; c: "Almasi"; d: "Shaba"; correct: "Tanzanite"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mgodi wa Almasi wa Mwadui unapatikana mkoa gani?"; a: "Geita"; b: "Shinyanga"; c: "Mara"; d: "Mwanza"; correct: "Shinyanga"; cat: "GEO"; diff: 1 }
        ListElement { q: "Mji gani unajulikana kama kitovu cha biashara ya Dhahabu Tanzania?"; a: "Geita"; b: "Chunya"; c: "Mbeya"; d: "Kahama"; correct: "Geita"; cat: "GEO"; diff: 2 }

        //MAPISHI NA CHAKULA (FOOD)
        ListElement { q: "Chakula gani ni maarufu kwa watu wa Kilimanjaro (Ndizi na Nyama)?"; a: "Mtori"; b: "Makande"; c: "Kande"; d: "Kiti moto"; correct: "Mtori"; cat: "BUR"; diff: 1 }
        ListElement { q: "Kande ni mchanganyiko wa maharage na nini?"; a: "Mchele"; b: "Mahindi"; c: "Viazi"; d: "Mtama"; correct: "Mahindi"; cat: "BUR"; diff: 1 }
        ListElement { q: "Pilau ni chakula chenye asili ya wapi nchini?"; a: "Pwani/Zanzibar"; b: "Kanda ya Ziwa"; c: "Kusini"; d: "Kaskazini"; correct: "Pwani/Zanzibar"; cat: "BUR"; diff: 1 }

        //ELIMU NA JAMII
        ListElement { q: "Chuo Kikuu kikongwe zaidi nchini Tanzania ni?"; a: "UDSM"; b: "Mzumbe"; c: "SUA"; d: "UDOM"; correct: "UDSM"; cat: "UR"; diff: 2 }
        ListElement { q: "Lugha ya Taifa ya Tanzania ni?"; a: "Kiingereza"; b: "Kiswahili"; c: "Kiarabu"; d: "Kinyamwezi"; correct: "Kiswahili"; cat: "UR"; diff: 1 }

        //HESABU (LOGIC & MATH)
        ListElement { q: "Kama 5 + x = 12, basi x ni ngapi?"; a: "5"; b: "7"; c: "8"; d: "6"; correct: "7"; cat: "M"; diff: 2 }
        ListElement { q: "Namba inayofuata: 1, 4, 9, 16, ..."; a: "20"; b: "25"; c: "30"; d: "24"; correct: "25"; cat: "M"; diff: 2 }
        ListElement { q: "Pembe tatu (Triangle) ina jumla ya nyuzi (degrees) ngapi?"; a: "90"; b: "180"; c: "360"; d: "270"; correct: "180"; cat: "M"; diff: 2 }
        ListElement { q: "Tafuta wastani wa 10, 20, na 30:"; a: "15"; b: "20"; c: "25"; d: "10"; correct: "20"; cat: "M"; diff: 2 }
        ListElement { q: "Ni namba gani ni namba tasa (Prime number)?"; a: "4"; b: "9"; c: "7"; d: "10"; correct: "7"; cat: "M"; diff: 2 }

        //MICHEZO & BURUDANI
        ListElement { q: "Mshindi wa kwanza wa medali ya Olimpiki kwa Tanzania alikuwa nani?"; a: "Filbert Bayi"; b: "Suleiman Nyambui"; c: "Samson Ramadhani"; d: "Juma Ikangaa"; correct: "Suleiman Nyambui"; cat: "SP"; diff: 2 }
        ListElement { q: "Klabu ya Yanga SC ilianzishwa mwaka gani?"; a: "1935"; b: "1938"; c: "1940"; d: "1932"; correct: "1935"; cat: "SP"; diff: 1 }
        ListElement { q: "Uwanja wa Kaitaba unapatikana mkoa gani?"; a: "Mwanza"; b: "Kagera"; c: "Mara"; d: "Shinyanga"; correct: "Kagera"; cat: "SP"; diff: 1 }
        ListElement { q: "Ni mwanamuziki gani wa Tanzania alishinda tuzo ya BET (Best International Act)?"; a: "Diamond Platnumz"; b: "Rayvanny"; c: "Alikiba"; d: "Harmonize"; correct: "Rayvanny"; cat: "BUR"; diff: 2 }
        ListElement { q: "Shirikisho la Mpira wa Miguu Tanzania linajulikana kwa kifupi kama?"; a: "TFF"; b: "FAT"; c: "BMT"; d: "DRFA"; correct: "TFF"; cat: "SP"; diff: 1 }
        ListElement { q: "Mchezo wa asili wa 'Bao' unachezwa na watu wangapi kwa wakati mmoja?"; a: "3"; b: "2"; c: "4"; d: "1"; correct: "2"; cat: "SP"; diff: 2 }

        //COMPUTER SCIENCE & ICT
        ListElement { q: "Kifupi cha USB ni nini?"; a: "Universal Serial Bus"; b: "United Serial Bus"; c: "User System Bus"; d: "Unit Serial Block"; correct: "Universal Serial Bus"; cat: "TK"; diff: 2 }
        ListElement { q: "Ni nini kazi ya 'Antivirus' kwenye kompyuta?"; a: "Kuongeza kasi"; b: "Kulinda dhidi ya virusi"; c: "Kufuta picha"; d: "Kuhifadhi siri"; correct: "Kulinda dhidi ya virusi"; cat: "TK"; diff: 2 }
        ListElement { q: "Sehemu ya nje ya kompyuta inayoweza kuguswa inaitwa?"; a: "Software"; b: "Hardware"; c: "Firmware"; d: "Malware"; correct: "Hardware"; cat: "TK"; diff: 2 }
        ListElement { q: "Neno 'Email' kirefu chake ni nini?"; a: "Easy Mail"; b: "Electronic Mail"; c: "Electric Mail"; d: "Engine Mail"; correct: "Electronic Mail"; cat: "TK"; diff: 2 }
        ListElement { q: "Ni kifaa kipi kinachotumika kutoa nakala ya karatasi kutoka kwenye kompyuta?"; a: "Scanner"; b: "Printer"; c: "Monitor"; d: "Mouse"; correct: "Printer"; cat: "TK"; diff: 2 }
        ListElement { q: "Lugha ya 'Binary' inatumia namba gani?"; a: "1 na 2"; b: "0 na 1"; c: "1 hadi 10"; d: "0 hadi 9"; correct: "0 na 1"; cat: "TK"; diff: 2 }
        ListElement { q: "Kifaa kinachounganisha kompyuta na internet kinaitwa?"; a: "Router"; b: "Keyboard"; c: "Speaker"; d: "CPU"; correct: "Router"; cat: "TK"; diff: 1 }
        ListElement { q: "Ni zipi kati ya hizi ni 'Operating System'?"; a: "Google"; b: "Windows"; c: "Facebook"; d: "WhatsApp"; correct: "Windows"; cat: "TK"; diff: 1 }

        //KILIMO & UVUVI
        ListElement { q: "Zao lipi la biashara ni maarufu mkoani Tabora?"; a: "Tumbaku"; b: "Chai"; c: "Karafuu"; d: "Sisal"; correct: "Tumbaku"; cat: "GEO"; diff: 2 }
        ListElement { q: "Wizara ya Kilimo nchini Tanzania ina makao makuu mji gani?"; a: "Dar es Salaam"; b: "Dodoma"; c: "Morogoro"; d: "Arusha"; correct: "Dodoma"; cat: "GEO"; diff: 1 }
        ListElement { q: "Chuo kikuu maarufu cha kilimo nchini Tanzania kinaitwa?"; a: "UDSM"; b: "SUA"; c: "SAUT"; d: "Mzumbe"; correct: "SUA"; cat: "MK"; diff: 2 }
        ListElement { q: "Zao la mkonge (Sisal) huzalishwa kwa wingi mkoa gani?"; a: "Tanga"; b: "Mtwara"; c: "Lindi"; d: "Ruvuma"; correct: "Tanga"; cat: "GEO"; diff: 2 }
        ListElement { q: "Dagaa wa Kigoma wanapatikana katika ziwa gani?"; a: "Victoria"; b: "Tanganyika"; c: "Nyasa"; d: "Rukwa"; correct: "Tanganyika"; cat: "GEO"; diff: 2 }
        ListElement { q: "Ni mbinu gani ya kilimo inayozuia mmomonyoko wa udongo milimani?"; a: "Kilimo cha matuta"; b: "Kilimo cha mikingamo"; c: "Kilimo cha kuhamahama"; d: "Kilimo cha umwagiliaji"; correct: "Kilimo cha mikingamo"; cat: "MK"; diff: 2 }

        //MADINI
        ListElement { q: "Madini ya makaa ya mawe yanapatikana kwa wingi mkoa gani?"; a: "Njombe"; b: "Ruvuma"; c: "Geita"; d: "Pwani"; correct: "Ruvuma"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mji wa Mererani unajulikana kwa uchimbaji wa madini gani?"; a: "Dhahabu"; b: "Tanzanite"; c: "Chuma"; d: "Shaba"; correct: "Tanzanite"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mgodi wa dhahabu wa Geita unaitwa?"; a: "GGML"; b: "Bulyanhulu"; c: "North Mara"; d: "Williamson"; correct: "GGML"; cat: "GEO"; diff: 3 }
        ListElement { q: "Tanzania ni nchi ya ngapi Afrika kwa uzalishaji wa Dhahabu?"; a: "Kwanza"; b: "Nne"; c: "Pili"; d: "Tano"; correct: "Nne"; cat: "GEO"; diff: 2 }
        ListElement { q: "Chuma kinapatikana katika eneo gani nchini?"; a: "Liganga"; b: "Mwadui"; c: "Kahama"; d: "Ngerengere"; correct: "Liganga"; cat: "GEO"; diff: 2 }

        //LOGIC & MATH
        ListElement { q: "Kama una dakika 60, na unatumia sekunde 30 kwa kila swali, utajibu maswali mangapi?"; a: "2"; b: "120"; c: "60"; d: "30"; correct: "120"; cat: "M"; diff: 2 }
        ListElement { q: "Tafuta thamani ya 'y':\n3y - 5 = 10"; a: "5"; b: "15"; c: "3"; d: "10"; correct: "5"; cat: "M"; diff: 2 }
        ListElement { q: "Jumla ya pembe za ndani za mraba (Square) ni ngapi?"; a: "180"; b: "360"; c: "90"; d: "270"; correct: "360"; cat: "M"; diff: 2 }

        //MAPISHI NA CHAKULA
        ListElement { q: "Chakula cha asili cha Wahaya kinachoitwa 'Senene' ni nini?"; a: "Samaki"; b: "Panzi"; c: "Kunde"; d: "Mimea"; correct: "Panzi"; cat: "BUR"; diff: 1 }
        ListElement { q: "Ugabigabi ni chakula cha asili cha mkoa gani?"; a: "Dodoma"; b: "Mara"; c: "Mtwara"; d: "Singida"; correct: "Singida"; cat: "BUR"; diff: 1 }
        ListElement { q: "Wali wa nazi ni maarufu sana katika maeneo yapi?"; a: "Pwani"; b: "Nyanda za juu"; c: "Kanda ya ziwa"; d: "Kati"; correct: "Pwani"; cat: "BUR"; diff: 1 }
        ListElement { q: "Kifupi cha neno 'Chai' katika Kiswahili cha zamani ilikuwa 'Mchai'. Jani la mchai linaitwa?"; a: "Mkandaa"; b: "Mchai"; c: "Mchai-chai"; d: "Mchai-bara"; correct: "Mchai-chai"; cat: "BUR"; diff: 1 }
        ListElement { q: "Kiungo gani hukupa pilau harufu nzuri?"; a: "Chumvi"; b: "Binzari"; c: "Sukari"; d: "Mafuta"; correct: "Binzari"; cat: "BUR"; diff: 1 }

        //HISTORIA & SIASA
        ListElement { q: "Bendera ya Tanganyika ilikuwa na rangi gani kabla ya Muungano?"; a: "Kijani, Nyeusi, Kijani"; b: "Kijani, Nyeusi, Njano"; c: "Bluu, Nyeusi, Kijani"; d: "Nyekundu, Nyeusi, Kijani"; correct: "Kijani, Nyeusi, Kijani"; cat: "H"; diff: 2 }
        ListElement { q: "Azimio la Arusha lilitangazwa mwaka gani?"; a: "1961"; b: "1967"; c: "1977"; d: "1964"; correct: "1967"; cat: "H"; diff: 2 }
        ListElement { q: "Chama cha TANU kilianzishwa tarehe 7 Julai mwaka gani?"; a: "1954"; b: "1961"; c: "1950"; d: "1945"; correct: "1954"; cat: "H"; diff: 2 }
        ListElement { q: "Makao makuu ya Umoja wa Afrika (AU) yapo nchi gani?"; a: "Tanzania"; b: "Ethiopia"; c: "Kenya"; d: "Misri"; correct: "Ethiopia"; cat: "H"; diff: 2 }
        ListElement { q: "Rais wa kwanza wa Zanzibar baada ya Mapinduzi alikuwa?"; a: "Abeid Karume"; b: "Idris Abdul Wakil"; c: "Salmin Amour"; d: "Ali Hassan Mwinyi"; correct: "Abeid Karume"; cat: "H"; diff: 2 }
        ListElement { q: "Nyerere alistaafu urais mwaka gani?"; a: "1980"; b: "1985"; c: "1990"; d: "1975"; correct: "1985"; cat: "H"; diff: 2 }

        //ELIMU & JIOGRAFIA
        ListElement { q: "Mlima wa pili kwa urefu nchini Tanzania unaitwa?"; a: "Meru"; b: "Oldonyo Lengai"; c: "Hanang"; d: "Rungwe"; correct: "Meru"; cat: "GEO"; diff: 2 }
        ListElement { q: "Ziwa la pili kwa kina kirefu duniani lililopo Tanzania ni?"; a: "Victoria"; b: "Tanganyika"; c: "Nyasa"; d: "Natron"; correct: "Tanganyika"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mkoa wa Dar es Salaam una wilaya ngapi kwa sasa?"; a: "3"; b: "5"; c: "7"; d: "4"; correct: "5"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mto mrefu kuliko yote nchini Tanzania ni?"; a: "Rufiji"; b: "Pangani"; c: "Ruvuma"; d: "Malagarasi"; correct: "Rufiji"; cat: "GEO"; diff: 2 }
        ListElement { q: "Hifadhi ya Saadani ina upekee gani?"; a: "Ina chui wengi"; b: "Imepakana na bahari"; c: "Ina milima"; d: "Ina baridi kali"; correct: "Imepakana na bahari"; cat: "UT"; diff: 2 }

        //IQ & LOGIC (HESABU)
        ListElement { q: "Nusu ya nusu ya 100 ni ngapi?"; a: "50"; b: "25"; c: "12.5"; d: "75"; correct: "25"; cat: "M"; diff: 2 }
        ListElement { q: "Kuna miezi mingapi yenye siku 28?"; a: "1"; b: "12"; c: "0"; d: "6"; correct: "12"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama jana ilikuwa Jumatatu, kesho kutwa itakuwa siku gani?"; a: "Jumatano"; b: "Alhamisi"; c: "Ijumaa"; d: "Jumanne"; correct: "Alhamisi"; cat: "LG"; diff: 2 }
        ListElement { q: "Umbo lenye pande 6 linaitwa?"; a: "Pentagon"; b: "Hexagon"; c: "Octagon"; d: "Square"; correct: "Hexagon"; cat: "M"; diff: 2 }
        ListElement { q: "Dazeni moja ni sawa na vitu vingapi?"; a: "10"; b: "12"; c: "24"; d: "6"; correct: "12"; cat: "M"; diff: 2 }

        // MZIKI WA TANZANIA
        ListElement { q: "Aina ya muziki wa asili nchini Tanzania unaotumia ala ya zeze na ilali unaitwa?"; a: "Bongo Fleva"; b: "Mchiriku"; c: "Taarab"; d: "Dansi"; correct: "Taarab"; cat: "BUR"; diff: 2 }
        ListElement { q: "Mwanamuziki gani anafahamika kama 'Mfalme wa Taarab' nchini Tanzania?"; a: "Mzee Yusuf"; b: "Diamond Platnumz"; c: "Alikiba"; d: "Moni Centrozone"; correct: "Mzee Yusuf"; cat: "BUR"; diff: 2 }
        ListElement { q: "Wimbo wa Taifa wa Tanzania unaitwa?"; a: "Tanzania Nakupenda"; b: "Mungu Ibariki Afrika"; c: "Tanzania Tanzania"; d: "Uzendo wa Taifa"; correct: "Mungu Ibariki Afrika"; cat: "UR"; diff: 2 }
        ListElement { q: "Ni mwanamuziki gani aliyeasisi mtindo wa 'Zuku' nchini Tanzania?"; a: "Marijani Rajab"; b: "Bi Kidude"; c: "Hukwe Zawose"; d: "Remmy Ongala"; correct: "Bi Kidude"; cat: "BUR"; diff: 2 }
        ListElement { q: "Tuzo kubwa za muziki duniani ambazo wasanii wa TZ hupania kushinda nchini Marekani ni?"; a: "Grammy"; b: "Kili Awards"; c: "BET"; d: "MTV"; correct: "Grammy"; cat: "BUR"; diff: 2 }

        //LOGIC & MATH
        ListElement { q: "Ni namba gani inafuata?\n1, 2, 4, 7, 11, ..."; a: "15"; b: "16"; c: "14"; d: "18"; correct: "16"; cat: "M"; diff: 2 }
        ListElement { q: "Nusu ya 2 plus 2 ni ngapi?"; a: "2"; b: "3"; c: "4"; d: "1"; correct: "3"; cat: "LG"; diff: 2 }

        // SERIKALI NA BUNGE
        ListElement { q: "Bunge la Jamhuri ya Muungano wa Tanzania linaongozwa na nani kwa sasa?"; a: "Spika"; b: "Waziri Mkuu"; c: "Rais"; d: "Jaji Mkuu"; correct: "Spika"; cat: "UR"; diff: 2 }
        ListElement { q: "Kiongozi wa shughuli za Serikali Bungeni ni nani?"; a: "Rais"; b: "Waziri Mkuu"; c: "Spika"; d: "Mwanasheria Mkuu"; correct: "Waziri Mkuu"; cat: "UR"; diff: 2 }
        ListElement { q: "Uchaguzi mkuu nchini Tanzania hufanyika kila baada ya miaka mingapi?"; a: "4"; b: "5"; c: "10"; d: "6"; correct: "5"; cat: "UR"; diff: 2 }
        ListElement { q: "Mhimili wa Serikali unaohusika na kutafsiri sheria unaitwa?"; a: "Bunge"; b: "Mahakama"; c: "Baraza la Mawaziri"; d: "Tume ya Uchaguzi"; correct: "Mahakama"; cat: "UR"; diff: 2 }

        ListElement { q: "Nani anayemteua Waziri Mkuu wa Tanzania?"; a: "Bunge"; b: "Rais"; c: "Spika"; d: "Wananchi"; correct: "Rais"; cat: "UR"; diff: 2 }
        ListElement { q: "Jumla ya mikoa ya Tanzania Bara na Visiwani ni mingapi kwa sasa?"; a: "26"; b: "31"; c: "30"; d: "21"; correct: "31"; cat: "UR"; diff: 2 }
        ListElement { q: "Kiti cha Spika wa Bunge la Tanzania kipo mji gani?"; a: "Dar es Salaam"; b: "Dodoma"; c: "Arusha"; d: "Zanzibar"; correct: "Dodoma"; cat: "UR"; diff: 1 }

        // UTAMADUNI
        ListElement { q: "Neno 'Ujamaa' lililokuwa falsafa ya Tanzania linamaanisha nini?"; a: "Uhuru wa binadamu"; b: "Undugu/Familia"; c: "Nguvu za pamoja"; d: "Amani na utulivu"; correct: "Undugu/Familia"; cat: "H"; diff: 2 }
        ListElement { q: "Mavazi ya asili ya kabila la Wamasai yanaitwa?"; a: "Kanzu"; b: "Shuka"; c: "Lubega"; d: "Suti"; correct: "Shuka"; cat: "BUR"; diff: 2 }
        ListElement { q: "Sikukuu ya 'Nane Nane' nchini Tanzania huadhimisha nini?"; a: "Wafanyakazi"; b: "Wakulima"; c: "Muungano"; d: "Mapinduzi"; correct: "Wakulima"; cat: "BUR"; diff: 2 }
        ListElement { q: "Ngoma ya asili ya kabila la Wasukuma inayohusisha nyoka inaitwa?"; a: "Bugobogobo"; b: "Bughu"; c: "Mdundiko"; d: "Sindimba"; correct: "Bugobogobo"; cat: "BUR"; diff: 2 }
        ListElement { q: "Chakula gani cha asili ni maarufu sana kwa kabila la Wachaga?"; a: "Ugali"; b: "Kande"; c: "Mtori/Machalari"; d: "Wali"; correct: "Mtori/Machalari"; cat: "BUR"; diff: 2 }
        ListElement { q: "Mwenge wa Uhuru uliwashwa kwa mara ya kwanza kilele cha Kilimanjaro mwaka gani?"; a: "1961"; b: "1964"; c: "1967"; d: "1977"; correct: "1961"; cat: "H"; diff: 2 }
        ListElement { q: "Sanamu ya Askari (Askari Monument) inapatikana katikati ya jiji gani?"; a: "Mwanza"; b: "Dodoma"; c: "Dar es Salaam"; d: "Tanga"; correct: "Dar es Salaam"; cat: "H"; diff: 1 }
        ListElement { q: "Zanzibar ni maarufu kwa mlango wa aina gani wa kitamaduni?"; a: "Mlango wa Chuma"; b: "Mlango wa Nakshi (Zanzibar Door)"; c: "Mlango wa Kioo"; d: "Mlango wa Plastiki"; correct: "Mlango wa Nakshi (Zanzibar Door)"; cat: "BUR"; diff: 2 }

        //LOGIC & MATH
        ListElement { q: "Kama utageuza neno 'KILIMANJARO', herufi ya tatu itakuwa?"; a: "A"; b: "R"; c: "O"; d: "J"; correct: "R"; cat: "LG"; diff: 2 }
        ListElement { q: "Tanzania imepakana na nchi ngapi?"; a: "6"; b: "8"; c: "10"; d: "7"; correct: "8"; cat: "GEO"; diff: 2 }
        ListElement { q: "Rangi za bendera ya Tanzania ni ngapi?"; a: "3"; b: "4"; c: "5"; d: "2"; correct: "4"; cat: "UR"; diff: 2 }
        ListElement { q: "Nchi ya Tanzania ipo upande gani wa bara la Afrika?"; a: "Magharibi"; b: "Kaskazini"; c: "Mashariki"; d: "Kati"; correct: "Mashariki"; cat: "GEO"; diff: 2 }

        //WANYAMAPORI
        ListElement { q: "Mnyama yupi anapatikana katika nembo ya Taifa ya Tanzania (Coat of Arms)?"; a: "Simba"; b: "Twiga"; c: "Chui"; d: "Tembo"; correct: "Twiga"; cat: "S"; diff: 1 }
        ListElement { q: "Ni mnyama yupi anajulikana kama 'Mfalme wa Mwitu'?"; a: "Tembo"; b: "Simba"; c: "Kifaru"; d: "Chui"; correct: "Simba"; cat: "S"; diff: 1 }
        ListElement { q: "Tanzania ina mnyama mrefu zaidi duniani, anaitwa?"; a: "Twiga"; b: "Swala"; c: "Nyumbu"; d: "Duma"; correct: "Twiga"; cat: "S"; diff: 1 }
        ListElement { q: "Ni mnyama yupi kati ya hawa anaunda kundi la 'Big Five' nchini Tanzania?"; a: "Pundamilia"; b: "Kifaru"; c: "Twiga"; d: "Mamba"; correct: "Kifaru"; cat: "S"; diff: 1 }
        ListElement { q: "Ziwa Victoria ni maarufu kwa aina gani ya samaki wa biashara?"; a: "Sangara"; b: "Paremisi"; c: "Mwatiko"; d: "Kibua"; correct: "Sangara"; cat: "GEO"; diff: 1 }

        //IQ & LOGIC (HESABU)
        ListElement { q: "Kama unayo mayai 3 na ukavunja 2, unayo mayai mangapi?"; a: "1"; b: "2"; c: "3"; d: "0"; correct: "3"; cat: "LG"; diff: 2 }
        ListElement { q: "Namba gani inafuata: 10, 20, 40, 80, ..."; a: "100"; b: "160"; c: "120"; d: "140"; correct: "160"; cat: "M"; diff: 2 }
        ListElement { q: "Kama kaka ana miaka 6 na dada ana nusu ya umri wake, kaka akifikisha 10, dada ana miaka mingapi?"; a: "5"; b: "7"; c: "8"; d: "3"; correct: "7"; cat: "M"; diff: 2 }
        ListElement { q: "Ni namba gani kubwa zaidi: 0.5, 0.05, 0.55, 0.1?"; a: "0.5"; b: "0.55"; c: "0.1"; d: "0.05"; correct: "0.55"; cat: "M"; diff: 2 }
        ListElement { q: "Saa 1 ina sekunde ngapi?"; a: "60"; b: "3600"; c: "600"; d: "1200"; correct: "3600"; cat: "M"; diff: 2 }
        ListElement { q: "Tafuta namba inayokosekana: 1, 3, 5, ?, 9"; a: "6"; b: "7"; c: "8"; d: "4"; correct: "7"; cat: "M"; diff: 2 }

        //SAMAKI
        ListElement { q: "Samaki aina ya 'Dagaa wa Kigoma' wanapatikana katika ziwa gani?"; a: "Victoria"; b: "Tanganyika"; c: "Nyasa"; d: "Eyasi"; correct: "Tanganyika"; cat: "GEO"; diff: 1 }
        ListElement { q: "Ni mnyama yupi anaongoza kwa uhamiaji mkubwa wa kila mwaka (Great Migration) Serengeti?"; a: "Simba"; b: "Nyumbu"; c: "Swala"; d: "Tembo"; correct: "Nyumbu"; cat: "UT"; diff: 1 }
        ListElement { q: "Mnyama yupi ni maarufu kwa kuwa na pembe moja au mbili na yupo hatarini kutoweka?"; a: "Kifaru"; b: "Kiboko"; c: "Ngiri"; d: "Punda"; correct: "Kifaru"; cat: "MK"; diff: 1 }
        ListElement { q: "Samaki aina ya Perege (Tilapia) hupatikana kwa wingi katika mazingira gani?"; a: "Maji ya Bahari"; b: "Maji Baridi (Maziwa/Mito)"; c: "Maji ya Chumvi"; d: "Maji ya Mafuta"; correct: "Maji Baridi (Maziwa/Mito)"; cat: "GEO"; diff: 1 }
        ListElement { q: "Mnyama yupi anaishi majini na nchi kavu na anaonekana kwa wingi mto Rufiji?"; a: "Mamba"; b: "Nyati"; c: "Duma"; d: "Sungura"; correct: "Mamba"; cat: "GEO"; diff: 1 }

        //AFYA NA MIMEA

        ListElement { q: "Ni tunda gani linajulikana kwa kuwa na kiasi kikubwa cha Vitamin C?"; a: "Chungwa"; b: "Ndizi"; c: "Tikiti"; d: "Tufaha (Apple)"; correct: "Chungwa"; cat: "A"; diff: 1 }
        ListElement { q: "Mmea unahitaji gesi gani kutoka kwa binadamu ili kutengeneza chakula?"; a: "Oxygen"; b: "Carbon Dioxide"; c: "Nitrogen"; d: "Hydrogen"; correct: "Carbon Dioxide"; cat: "A"; diff: 1 }
        ListElement { q: "Ugonjwa wa Malaria husababishwa na vimelea vya aina gani?"; a: "Virusi"; b: "Bacteria"; c: "Plasmodium"; d: "Fangasi"; correct: "Plasmodium"; cat: "A"; diff: 2 }
        ListElement { q: "Sehemu ya mmea inayohusika na kufyonza maji na madini ardhini ni?"; a: "Matawi"; b: "Mizizi"; c: "Maua"; d: "Shina"; correct: "Mizizi"; cat: "A"; diff: 2 }
        ListElement { q: "Ni vitamin gani inayopatikana kwa urahisi kupitia mwanga wa Jua la asubuhi?"; a: "Vitamin A"; b: "Vitamin C"; c: "Vitamin D"; d: "Vitamin K"; correct: "Vitamin D"; cat: "A"; diff: 2 }

        ListElement { q: "Mmea wa ajabu unaopatikana Tanzania (Kondoa) na huishi miaka mingi sana ni?"; a: "Mbuyu"; b: "Mwembe"; c: "Mnanasi"; d: "Mparachichi"; correct: "Mbuyu"; cat: "A"; diff: 1 }
        ListElement { q: "Kiwango cha kawaida cha joto la mwili wa binadamu ni nyuzi joto (Celsius) ngapi?"; a: "30°C"; b: "37°C"; c: "40°C"; d: "25°C"; correct: "37°C"; cat: "A"; diff: 2 }
        ListElement { q: "Mchakato wa mimea kutengeneza chakula chake kwa kutumia mwanga wa jua unaitwa?"; a: "Respiration"; b: "Photosynthesis"; c: "Digestion"; d: "Evaporation"; correct: "Photosynthesis"; cat: "S"; diff: 3 }

        ListElement { q: "Ni kiungo gani ndani ya mwili wa binadamu kinahusika na kusafisha damu?"; a: "Moyo"; b: "Mapafu"; c: "Figo"; d: "Tumbo"; correct: "Figo"; cat: "A"; diff: 2 }
        ListElement { q: "Upungufu wa madini ya Chuma mwilini husababisha ugonjwa gani?"; a: "Anemia (Upungufu wa damu)"; b: "Kisukari"; c: "Pumu"; d: "Tezi dume"; correct: "Anemia (Upungufu wa damu)"; cat: "A"; diff: 2 }

        //LOGIC & MATH
        ListElement { q: "Kama namba 3 ni 18, na 5 ni 30, basi 10 ni nini?"; a: "60"; b: "50"; c: "100"; d: "80"; correct: "60"; cat: "LG"; diff: 2 }
        ListElement { q: "Tafuta namba inayokosekana:\n100, 95, 85, 70, ?"; a: "50"; b: "60"; c: "55"; d: "45"; correct: "50"; cat: "M"; diff: 2 }
        ListElement { q: "Ni namba gani ikiidhinishwa na 0 jibu linakuwa 0?"; a: "Namba yoyote"; b: "100 pekee"; c: "Hakuna"; d: "1 pekee"; correct: "Namba yoyote"; cat: "M"; diff: 2 }
        ListElement { q: "Kama mti mmoja una matawi 5, na kila tawi lina ndege 5, kuna ndege wangapi jumla?"; a: "10"; b: "25"; c: "20"; d: "15"; correct: "25"; cat: "M"; diff: 2 }
        ListElement { q: "Mfululizo wa namba: 2, 4, 8, 16, ... Namba ya 6 itakuwa?"; a: "32"; b: "64"; c: "48"; d: "128"; correct: "64"; cat: "M"; diff: 2 }

        // --- LOGIC ZA KUTEGA (10 QUESTIONS)

        ListElement { q: "Kama unaniita, mimi huvunjika. Mimi ni nani?"; a: "Kioo"; b: "Ukuta"; c: "Ukimya"; d: "Siri"; correct: "Ukimya"; cat: "LG"; diff: 3 }
        ListElement { q: "Baba yake Juma ana watoto wanne: Januari, Februari, na Machi. Wa nne anaitwa nani?"; a: "Aprili"; b: "Juma"; c: "Mei"; d: "Agosti"; correct: "Juma"; cat: "LG"; diff: 3 }
        ListElement { q: "Ni nini kina kichwa na mguu, lakini hakina mwili?"; a: "Senti/Sarafu"; b: "Msumari"; c: "Kitanda"; d: "Mlima"; correct: "Kitanda"; cat: "LG"; diff: 3 }
        ListElement { q: "Kuna nini katikati ya 'TANZANIA'?"; a: "Z"; b: "N"; c: "A"; d: "I"; correct: "Z"; cat: "LG"; diff: 3 }
        ListElement { q: "Ninaruka bila mabawa na ninalia bila macho. Mimi ni nani?"; a: "Ndege"; b: "Wingu/Mvua"; c: "Upepo"; d: "Moshi"; correct: "Wingu/Mvua"; cat: "LG"; diff: 1 }

        ListElement { q: "Mtu mmoja alikuwa nje kwenye mvua kubwa bila mwavuli wala kofia, lakini unywele wake hata mmoja haukulowa. Kwa nini?"; a: "Alikimbia sana"; b: "Alikuwa na kipara (hana nywele)"; c: "Mvua ilikuwa ndogo"; d: "Alivaa koti"; correct: "Alikuwa na kipara (hana nywele)"; cat: "LG"; diff: 3 }
        ListElement { q: "Ni nini kinaingia majini lakini hakilowi?"; a: "Kivuli"; b: "Chumvi"; c: "Karatasi"; d: "Sifongo"; correct: "Kivuli"; cat: "LG"; diff: 3 }
        ListElement { q: "Ni neno gani limeandikwa vibaya kwenye kamusi zote duniani?"; a: "Makosa"; b: "Vibaya"; c: "Uongo"; d: "Sahihisha"; correct: "Vibaya"; cat: "LG"; diff: 3 }
        ListElement { q: "Ukienda kulala saa mbili usiku na ukategesha saa ya mshale kukuamsha saa tatu asubuhi, utakuwa umelala saa ngapi?"; a: "Saa 13"; b: "Saa 1"; c: "Saa 11"; d: "Saa 9"; correct: "Saa 1"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama mzungu mweusi akivaa koti la bluu na akaingia kwenye Bahari ya Shamu (Red Sea), anakuwa nani?"; a: "Mzungu mwekundu"; b: "Mlowezi"; c: "Mzungu mweusi aliyelowa"; d: "Mfu"; correct: "Mzungu mweusi aliyelowa"; cat: "LG"; diff: 3 }

        // --- VITENDAWILI

        ListElement { q: "Kitendawili: Nyumba yangu haina mlango."; a: "Yai"; b: "Kaburi"; c: "Chumvi"; d: "Tango"; correct: "Yai"; cat: "V"; diff: 2 }
        ListElement { q: "Kitendawili: Askari wangu wote wamevaa kofia nyekundu."; a: "Vidole"; b: "Kiberiti"; c: "Askari kanzu"; d: "Meno"; correct: "Kiberiti"; cat: "V"; diff: 2 }
        ListElement { q: "Kitendawili: Kamba yangu ndefu lakini haifungi kuni."; a: "Nyoka"; b: "Barabara"; c: "Mshipi"; d: "Mto"; correct: "Barabara"; cat: "V"; diff: 2 }
        ListElement { q: "Kitendawili: Babu yangu hacheki mpaka achunwe ngozi."; a: "Mahindi"; b: "Ndizi"; c: "Chungwa"; d: "Kitunguu"; correct: "Mahindi"; cat: "V"; diff: 2 }
        ListElement { q: "Kitendawili: Mvua hapa, mvua kule, lakini katikati pakavu."; a: "Mwavuli"; b: "Nyumba"; c: "Mtu aliyevaa koti"; d: "Daraja"; correct: "Nyumba"; cat: "V"; diff: 3 }

        // --- UKEREWE (3 QUESTIONS) ---
        ListElement { q: "Kisiwa cha Ukerewe kinapatikana ndani ya ziwa gani?"; a: "Tanganyika"; b: "Nyasa"; c: "Victoria"; d: "Eyasi"; correct: "Victoria"; cat: "GEO"; diff: 2 }

        ListElement { q: "Ukerewe ni wilaya inayopatikana katika mkoa gani nchini Tanzania?"; a: "Mwanza"; b: "Mara"; c: "Geita"; d: "Kagera"; correct: "Mwanza"; cat: "GEO"; diff: 2 }

        // --- TEKNOLOJIA YA ANGA
        ListElement { q: "Ni sayari gani inajulikana kama 'Sayari Nyekundu' (Red Planet)?"; a: "Jupiter"; b: "Venus"; c: "Mars"; d: "Saturn"; correct: "Mars"; cat: "S"; diff: 3 }

        ListElement { q: "Chombo cha kwanza kilichompeleka binadamu mwezini (Apollo 11) kilikuwa cha nchi gani?"; a: "Urusi"; b: "Marekani"; c: "China"; d: "Uingereza"; correct: "Marekani"; cat: "S"; diff: 3 }

        ListElement { q: "Ni nini jina la darubini kubwa zaidi na ya kisasa iliyorushwa angani hivi karibuni?"; a: "Hubble"; b: "Galileo"; c: "James Webb"; d: "Newton"; correct: "James Webb"; cat: "S"; diff: 3 }

        ListElement { q: "Gesi gani inapatikana kwa wingi zaidi katika anga la Dunia (Atmosphere)?"; a: "Oxygen"; b: "Nitrogen"; c: "Carbon Dioxide"; d: "Argon"; correct: "Nitrogen"; cat: "S"; diff: 1 }

        // --- ELIMU
        ListElement { q: "Kirefu cha neno NECTA ni nini kwa Kiswahili?"; a: "Baraza la Mitihani la Tanzania"; b: "Wizara ya Elimu"; c: "Bodi ya Mikopo"; d: "Tume ya Vyuo Vikuu"; correct: "Baraza la Mitihani la Tanzania"; cat: "UR"; diff: 1 }
        ListElement { q: "Katika mfumo wa NECTA, daraja 'A' kwenye mtihani wa kidato cha nne huanzia alama ngapi?"; a: "70"; b: "75"; c: "81"; d: "65"; correct: "75"; cat: "UR"; diff: 3 }
        ListElement { q: "Ni mwaka gani Tanzania ilianza rasmi mfumo wa elimu ya bila malipo kwa shule za msingi na sekondari?"; a: "2010"; b: "2015"; c: "2020"; d: "2005"; correct: "2015"; cat: "UR"; diff: 3 }

        ListElement { q: "Siku ya kwanza ya mzunguko wa hedhi huhesabiwa kuanzia lini?"; a: "Siku hedhi inapoisha"; b: "Siku ya kwanza kuona damu"; c: "Siku ya 14"; d: "Siku yoyote"; correct: "Siku ya kwanza kuona damu"; cat: "A"; diff: 3 }
        ListElement { q: "Kirusi kinachosababisha UKIMWI kinaitwa?"; a: "Bacteria"; b: "VVU (HIV)"; c: "Plasmodium"; d: "Fungi"; correct: "VVU (HIV)"; cat: "A"; diff: 3 }
        ListElement { q: "Ni ugonjwa upi wa zinaa unaweza kusababisha upofu kwa mtoto wakati wa kuzaliwa?"; a: "Kaswende"; b: "Kisonono (Gonorrhea)"; c: "Homa ya Ini"; d: "Teepee"; correct: "Kisonono (Gonorrhea)"; cat: "A"; diff: 3 }
        ListElement { q: "Njia ya uhakika zaidi ya kuzuia mimba na magonjwa ya zinaa kwa wakati mmoja ni?"; a: "Vidonge"; b: "Kondomu"; c: "Sindano"; d: "Kalenda"; correct: "Kondomu"; cat: "A"; diff: 3 }
        ListElement { q: "Kipindi ambacho yai la mwanamke linatoka tayari kurutubishwa huitwa?"; a: "Hedhi"; b: "Ovulation (Upevushaji)"; c: "Mimba"; d: "Kukoma hedhi"; correct: "Ovulation (Upevushaji)"; cat: "A"; diff: 3 }

        ListElement { q: "Ugonjwa wa Kaswende husababishwa na nini?"; a: "Virusi"; b: "Bacteria"; c: "Uchafu"; d: "Minyoo"; correct: "Bacteria"; cat: "A"; diff: 3 }
        ListElement { q: "Chanjo ya HPV hutolewa ili kuzuia saratani gani kwa wanawake?"; a: "Saratani ya matiti"; b: "Saratani ya mlango wa uzazi"; c: "Saratani ya ini"; d: "Saratani ya ngozi"; correct: "Saratani ya mlango wa uzazi"; cat: "A"; diff: 3 }
        ListElement { q: "Mimba ya kawaida ya binadamu huchukua wastani wa wiki ngapi?"; a: "30"; b: "36"; c: "40"; d: "45"; correct: "40"; cat: "A"; diff: 3 }
        ListElement { q: "Ni vimelea gani husababisha ugonjwa wa Trichomoniasis?"; a: "Virusi"; b: "Bacteria"; c: "Protozoa"; d: "Fungi"; correct: "Protozoa"; cat: "A"; diff: 3 }
        ListElement { q: "Upasuaji mdogo kwa wanaume ili kuzuia uwezo wa kutoa mbegu za uzazi huitwa?"; a: "Vasectomy"; b: "Circumcision"; c: "Dialysis"; d: "Biopsy"; correct: "Vasectomy"; cat: "A"; diff: 3 }
        ListElement { q: "Kifupi cha PID katika afya ya uzazi inamaanisha?"; a: "Pelvic Inflammatory Disease"; b: "Private Internal Disease"; c: "Period Internal Delay"; d: "Pain In Digestion"; correct: "Pelvic Inflammatory Disease"; cat: "A"; diff: 3 }
        ListElement { q: "Je, mwanamke anaweza kupata mimba akishiriki tendo la ndoa mara moja pekee?"; a: "Hapana"; b: "Ndiyo"; c: "Inategemea umri"; d: "Haiwezekani"; correct: "Ndiyo"; cat: "A"; diff: 3 }
        ListElement { q: "Ni ugonjwa gani wa zinaa unaoshambulia zaidi Ini?"; a: "Kisonono"; b: "Homa ya Ini B (Hepatitis B)"; c: "Kaswende"; d: "Vifundo"; correct: "Homa ya Ini B (Hepatitis B)"; cat: "A"; diff: 3 }
        ListElement { q: "Mbegu za kiume hutengenezwa sehemu gani ya mwili?"; a: "Kibofu"; b: "Mapumbu (Testes)"; c: "Uume"; d: "Mifuko ya mkojo"; correct: "Mapumbu (Testes)"; cat: "A"; diff: 3 }
        ListElement { q: "Kukoma kwa hedhi kabisa kwa mwanamke (Menopause) hutokea wastani wa umri gani?"; a: "20-30"; b: "45-55"; c: "30-40"; d: "60-70"; correct: "45-55"; cat: "A"; diff: 3 }
        ListElement { q: "Ni ipi dalili ya kawaida ya Kisonono kwa wanaume?"; a: "Kutoa usaha kwenye uume"; b: "Kukohoa"; c: "Maumivu ya mgongo"; d: "Kupoteza nywele"; correct: "Kutoa usaha kwenye uume"; cat: "A"; diff: 3 }
        ListElement { q: "Upungufu wa damu kwa mama mjamzito mara nyingi husababishwa na ukosefu wa?"; a: "Sukari"; b: "Madini ya Chuma"; c: "Chumvi"; d: "Mafuta"; correct: "Madini ya Chuma"; cat: "A"; diff: 3 }
        ListElement { q: "Neno 'Uziwi' wa mtoto mchanga unaweza kusababishwa na maambukizi ya?"; a: "Rubella"; b: "Mafua"; c: "Kikohozi"; d: "Fangasi"; correct: "Rubella"; cat: "A"; diff: 3 }
        ListElement { q: "Tendo la kuunganisha yai la kike na mbegu ya kiume huitwa?"; a: "Urutubishaji (Fertilization)"; b: "Upevushaji"; c: "Hedhi"; d: "Uzazi"; correct: "Urutubishaji (Fertilization)"; cat: "A"; diff: 3 }
        ListElement { q: "Je, mtu anaweza kuwa na ugonjwa wa zinaa bila kuonyesha dalili zozote?"; a: "Hapana"; b: "Ndiyo"; c: "Ni nadra"; d: "Haiwezekani"; correct: "Ndiyo"; cat: "A"; diff: 3 }

        ListElement { q: "Tendo la kutoa damu kila mwezi kwa wasichana huitwa?"; a: "Kuvunja ungo"; b: "Hedhi"; c: "Ovulation"; d: "Mimba"; correct: "Hedhi"; cat: "A"; diff: 3 }
        ListElement { q: "Ni homoni ipi inawajibika kwa mabadiliko ya kiume wakati wa kubalehe?"; a: "Estrogen"; b: "Progesterone"; c: "Testosterone"; d: "Insulin"; correct: "Testosterone"; cat: "A"; diff: 3 }
        ListElement { q: "Mabadiliko ya sauti kuwa nzito kwa wavulana ni ishara ya?"; a: "Kubalehe"; b: "Ugonjwa"; c: "Uchovu"; d: "Kukua kwa mapafu"; correct: "Kubalehe"; cat: "A"; diff: 3 }
        ListElement { q: "Kukua kwa matiti na kuanza hedhi ni ishara za kubalehe kwa?"; a: "Wavulana"; b: "Wasichana"; c: "Wote wawili"; d: "Watoto wachanga"; correct: "Wasichana"; cat: "A"; diff: 3 }
        ListElement { q: "Tezi inayodhibiti mwanzo wa mchakato wa kubalehe inaitwa?"; a: "Pituitary"; b: "Thyroid"; c: "Adrenal"; d: "Pancreas"; correct: "Pituitary"; cat: "A"; diff: 3 }

        ListElement { q: "Ni homoni ipi kuu inayosababisha mabadiliko kwa wasichana?"; a: "Estrogen"; b: "Testosterone"; c: "Adrenaline"; d: "Thyroxine"; correct: "Estrogen"; cat: "A"; diff: 3 }
        ListElement { q: "Kuota chunusi wakati wa kubalehe mara nyingi husababishwa na?"; a: "Mabadiliko ya homoni"; b: "Kutokunawa uso"; c: "Kula sukari"; d: "Baridi"; correct: "Mabadiliko ya homoni"; cat: "A"; diff: 3 }
        ListElement { q: "Ndoto za usiku zinazopelekea kutoa mbegu za kiume (Wet dreams) ni jambo la?"; a: "Kawaida/Kutokua"; b: "Kawaida/Afya"; c: "Hatari"; d: "Ugonjwa"; correct: "Kawaida/Afya"; cat: "A"; diff: 3 }
        ListElement { q: "Wastani wa umri wa kuanza kubalehe kwa wasichana ni?"; a: "5-7"; b: "10-14"; c: "18-21"; d: "25-30"; correct: "10-14"; cat: "A"; diff: 3 }
        ListElement { q: "Kupanuka kwa mabega ni tabia ya mabadiliko ya kubalehe kwa?"; a: "Wavulana"; b: "Wasichana"; c: "Wazee"; d: "Hakuna"; correct: "Wavulana"; cat: "A"; diff: 3 }
        ListElement { q: "Mabadiliko ya kihisia na kuanza kuvutiwa na jinsia tofauti huanza kipindi cha?"; a: "Utoto"; b: "Kubalehe"; c: "Uzee"; d: "Uzaliwa"; correct: "Kubalehe"; cat: "A"; diff: 3 }
        ListElement { q: "Kukua kwa 'Adam's Apple' shingoni ni ishara kwa?"; a: "Wavulana"; b: "Wasichana"; c: "Wote"; d: "Wanyama"; correct: "Wavulana"; cat: "A"; diff: 1 }


        ListElement { q: "Kirefu cha AI ni nini?"; a: "Art Intelligent"; b: "Artificial Intelligence"; c: "Automated Info"; d: "Advanced Intel"; correct: "Artificial Intelligence"; cat: "TK"; diff: 3 }
        ListElement { q: "Ni mfumo upi wa AI uliotengenezwa na kampuni ya OpenAI?"; a: "Siri"; b: "ChatGPT"; c: "Alexa"; d: "Bixby"; correct: "ChatGPT"; cat: "TK"; diff: 3 }
        ListElement { q: "Uwezo wa AI kujifunza kupitia data bila kupewa maelekezo ya kila hatua huitwa?"; a: "Machine Learning"; b: "Coding"; c: "Typing"; d: "Hardware"; correct: "Machine Learning"; cat: "TK"; diff: 3 }


        ListElement { q: "AI inayoweza kutengeneza picha au maandishi mapya huitwa?"; a: "Static AI"; b: "Generative AI"; c: "Old AI"; d: "Manual AI"; correct: "Generative AI"; cat: "TK"; diff: 3 }
        ListElement { q: "Robot maarufu mwenye uraia wa Saudi Arabia anaitwa?"; a: "Sophia"; b: "Alexa"; c: "Siri"; d: "Jarvis"; correct: "Sophia"; cat: "TK"; diff: 3 }
        ListElement { q: "Kampuni ya Google imetengeneza AI inayoitwa?"; a: "Gemini"; b: "ChatGPT"; c: "Claude"; d: "Llama"; correct: "Gemini"; cat: "TK"; diff: 1 }
        ListElement { q: "Ni kifaa gani kinatumia AI kutambua uso wa mtu (Face ID)?"; a: "Simu Janja"; b: "Pasi ya umeme"; c: "Redio"; d: "Saa ya ukutani"; correct: "Simu Janja"; cat: "TK"; diff: 3 }
        ListElement { q: "AI inayotumika kuendesha magari bila dereva inaitwa?"; a: "Manual Driving"; b: "Autonomous Driving"; c: "Remote Control"; d: "Flying AI"; correct: "Autonomous Driving"; cat: "TK"; diff: 3 }
        ListElement { q: "Turing Test inatumika kupima nini?"; a: "Uwezo wa AI kufikiri kama binadamu"; b: "Kasi ya intaneti"; c: "Ukubwa wa betri"; d: "Ubora wa kioo"; correct: "Uwezo wa AI kufikiri kama binadamu"; cat: "TK"; diff: 3 }
        ListElement { q: "Lugha ya kompyuta inayotumika zaidi kwenye AI ni?"; a: "Python"; b: "HTML"; c: "CSS"; d: "SQL"; correct: "Python"; cat: "TK"; diff: 3 }
        ListElement { q: "Kifaa kinachotumia AI nyumbani kutoa taarifa kwa sauti (mfano Alexa) huitwa?"; a: "Smart Speaker"; b: "Microphone"; c: "Radio"; d: "TV"; correct: "Smart Speaker"; cat: "TK"; diff: 3 }
        ListElement { q: "AI inaweza kupata 'Hallucinations'. Hii inamaanisha nini?"; a: "Inatoa majibu ya uongo kwa kujiamini"; b: "Inazima yenyewe"; c: "Inapata virusi"; d: "Inafanya kazi haraka"; correct: "Inatoa majibu ya uongo kwa kujiamini"; cat: "TK"; diff: 3 }
        ListElement { q: "Mwasisi wa AI anayefahamika kama baba wa AI ni?"; a: "Alan Turing"; b: "Bill Gates"; c: "Elon Musk"; d: "Steve Jobs"; correct: "Alan Turing"; cat: "TK"; diff: 3 }
        ListElement { q: "Deep Learning ni sehemu ya nini?"; a: "Machine Learning"; b: "Hardware"; c: "Agriculture"; d: "Physics"; correct: "Machine Learning"; cat: "TK"; diff: 3 }
        ListElement { q: "AI inatumia nini ili kufanya maamuzi haraka?"; a: "Algorithms"; b: "Maji"; c: "Upepo"; d: "Petroli"; correct: "Algorithms"; cat: "TK"; diff: 3 }


        ListElement { q: "Kitendawili: Nyumba yangu haina mlango."; a: "Yai"; b: "Chupa"; c: "Kaburi"; d: "Tango"; correct: "Yai"; cat: "V"; diff: 3 }
        ListElement { q: "Kitendawili: Kila nikienda ananifuata."; a: "Kivuli"; b: "Mbwa"; c: "Rafiki"; d: "Upepo"; correct: "Kivuli"; cat: "V"; diff: 3 }
        ListElement { q: "Kitendawili: Babu amebeba gitaa mgongoni."; a: "Kobe"; b: "Konokono"; c: "Mzee"; d: "Kiti"; correct: "Kobe"; cat: "V"; diff: 3 }
        ListElement { q: "Kitendawili: Daima anatazama juu."; a: "Nyasi"; b: "Moshi"; c: "Mvua"; d: "Mbuyu"; correct: "Nyasi"; cat: "V"; diff: 1 }
        ListElement { q: "Kitendawili: Ana meno mengi lakini hali chakula."; a: "Kitana"; b: "Simba"; c: "Msumeno"; d: "Paka"; correct: "Kitana"; cat: "V"; diff: 1 }

        ListElement { q: "Kifupi cha teknolojia ya 'Wi-Fi' inamaanisha nini?"; a: "Wireless Fidelity"; b: "Wireless Fiber"; c: "Wire Filter"; d: "Wide Field"; correct: "Wireless Fidelity"; cat: "TK"; diff: 3 }
        ListElement { q: "Ni kampuni gani ilitengeneza mfumo wa uendeshaji wa Windows?"; a: "Apple"; b: "Microsoft"; c: "IBM"; d: "Google"; correct: "Microsoft"; cat: "TK"; diff: 1 }
        ListElement { q: "Sehemu ya siri ya mtandao ambayo haionekani kirahisi kwenye search engines huitwa?"; a: "Dark Web"; b: "Public Web"; c: "Safe Web"; d: "Open Web"; correct: "Dark Web"; cat: "TK"; diff: 3 }
        ListElement { q: "Kifaa kinachotumika kubadilisha nishati ya jua kuwa umeme huitwa?"; a: "Solar Panel"; b: "Generator"; c: "Battery"; d: "Inverter"; correct: "Solar Panel"; cat: "TK"; diff: 3 }
        ListElement { q: "Katika email, kirefu cha 'BCC' ni nini?"; a: "Blind Carbon Copy"; b: "Best Carbon Copy"; c: "Basic Clear Copy"; d: "Business Case Copy"; correct: "Blind Carbon Copy"; cat: "TK"; diff: 3 }
        ListElement { q: "Ni lugha gani ya programu (Coding) inayotumika zaidi kutengeneza kurasa za tovuti (Websites)?"; a: "HTML"; b: "C++"; c: "Swift"; d: "Kotlin"; correct: "HTML"; cat: "S"; diff: 3 }
        ListElement { q: "Kifaa kinachounganisha kompyuta yako na mtandao wa intaneti huitwa?"; a: "Router"; b: "Scanner"; c: "Printer"; d: "Monitor"; correct: "Router"; cat: "TK"; diff: 3 }
        ListElement { q: "Teknolojia ya kuratibu maeneo kwa kutumia satelaiti inaitwa?"; a: "GPS"; b: "SMS"; c: "UPS"; d: "CCTV"; correct: "GPS"; cat: "TK"; diff: 3 }
        ListElement { q: "Namba ya utambulisho wa kipekee kwa kila simu (IMEI) ina tarakimu ngapi?"; a: "10"; b: "15"; c: "12"; d: "16"; correct: "15"; cat: "TK"; diff: 3 }
        ListElement { q: "Kitufe cha 'F5' kwenye keyboard ya kompyuta mara nyingi hutumika kwa kazi gani?"; a: "Kufuta"; b: "Ku-Refresh"; c: "Kuzima"; d: "Kuhifadhi"; correct: "Ku-Refresh"; cat: "TK"; diff: 3 }
        ListElement { q: "Ni nini kazi ya 'Firewall' kwenye kompyuta?"; a: "Kuzuia virusi na wadukuzi"; b: "Kupunguza joto"; c: "Kuongeza kasi"; d: "Kupiga picha"; correct: "Kuzuia virusi na wadukuzi"; cat: "TK"; diff: 3 }
        ListElement { q: "Teknolojia ya kuhifadhi data kwenye mtandao badala ya diski ya kompyuta huitwa?"; a: "Cloud Storage"; b: "Hard Drive"; c: "Flash Disk"; d: "RAM"; correct: "Cloud Storage"; cat: "TK"; diff: 3 }
        ListElement { q: "Ni nani anayefahamika kama mwanzilishi wa Facebook (Meta)?"; a: "Mark Zuckerberg"; b: "Bill Gates"; c: "Elon Musk"; d: "Jeff Bezos"; correct: "Mark Zuckerberg"; cat: "TK"; diff: 3 }

        ListElement { q: "Ni kiungo gani cha mwili kinachohusika na kusafisha damu?"; a: "Moyo"; b: "Figo"; c: "Mapafu"; d: "Tumbo"; correct: "Figo"; cat: "A"; diff: 3 }
        ListElement { q: "Damu ya binadamu ina rangi nyekundu kwa sababu ya protini iitwayo?"; a: "Hemoglobin"; b: "Insulin"; c: "Keratin"; d: "Melanin"; correct: "Hemoglobin"; cat: "A"; diff: 3 }
        ListElement { q: "Ni tunda gani lina vitamini C kwa wingi zaidi?"; a: "Chungwa"; b: "Ndizi"; c: "Tikiti"; d: "Tufaha (Apple)"; correct: "Chungwa"; cat: "A"; diff: 1 }
        ListElement { q: "Binadamu ana jozi ngapi za kromozomu (Chromosomes)?"; a: "23"; b: "46"; c: "20"; d: "30"; correct: "23"; cat: "A"; diff: 3 }
        ListElement { q: "Ni aina gani ya damu (Blood Group) inayoweza kutoa kwa makundi yote (Universal Donor)?"; a: "Group A"; b: "Group B"; c: "Group AB"; d: "Group O"; correct: "Group O"; cat: "A"; diff: 3 }
        ListElement { q: "Mifupa ya binadamu mtu mzima imegawanyika katika vipande vingapi?"; a: "100"; b: "206"; c: "300"; d: "150"; correct: "206"; cat: "A"; diff: 3 }
        ListElement { q: "Kiungo kikubwa zaidi cha nje cha mwili wa binadamu ni?"; a: "Ngozi"; b: "Mapafu"; c: "Ini"; d: "Miguu"; correct: "Ngozi"; cat: "A"; diff: 1 }
        ListElement { q: "Viumbe hai wanaokula mimea pekee huitwa?"; a: "Herbivores"; b: "Carnivores"; c: "Omnivores"; d: "Parasites"; correct: "Herbivores"; cat: "S"; diff: 3 }
        ListElement { q: "Ni vitamini gani inayopatikana kwa wingi kupitia mwanga wa jua la asubuhi?"; a: "Vitamini A"; b: "Vitamini C"; c: "Vitamini D"; d: "Vitamini K"; correct: "Vitamini D"; cat: "A"; diff: 3 }
        ListElement { q: "Sehemu ya jicho inayohusika na kuingiza mwanga huitwa?"; a: "Pupil"; b: "Retina"; c: "Lens"; d: "Iris"; correct: "Pupil"; cat: "A"; diff: 3 }
        ListElement { q: "Ni wadudu gani wanaosafirisha chavua (Pollination) kwa kiasi kikubwa duniani?"; a: "Nyuki"; b: "Mbu"; c: "Mende"; d: "Nzi"; correct: "Nyuki"; cat: "A"; diff: 3 }
        ListElement { q: "Zoezi la mimea kutengeneza chakula chake kwa kutumia mwanga wa jua huitwa?"; a: "Photosynthesis"; b: "Respiration"; c: "Digestion"; d: "Osmosis"; correct: "Photosynthesis"; cat: "S"; diff: 3 }
        ListElement { q: "Mapigo ya moyo ya binadamu mwenye afya kwa dakika ni wastani wa?"; a: "40-60"; b: "70-80"; c: "100-120"; d: "20-30"; correct: "70-80"; cat: "A"; diff: 3 }

        ListElement { q: "Ni chombo gani kinatumika kupima kiasi cha mvua iliyonyesha?"; a: "Thermometer"; b: "Rain Gauge"; c: "Barometer"; d: "Anemometer"; correct: "Rain Gauge"; cat: "S"; diff: 3 }
        ListElement { q: "Radi hutokea kwa sababu ya msuguano wa nini angani?"; a: "Mawingu"; b: "Ndege"; c: "Nyota"; d: "Mwezi"; correct: "Mawingu"; cat: "S"; diff: 3 }
        ListElement { q: "Mvua inayonyesha baada ya maji ya bahari kupata joto na kupaisha mvuke huitwa?"; a: "Convectional Rain"; b: "Relief Rain"; c: "Cyclonic Rain"; d: "Acid Rain"; correct: "Convectional Rain"; cat: "S"; diff: 3 }
        ListElement { q: "Ni gesi gani inatengeneza asilimia 21 ya hewa ya anga (Atmosphere)?"; a: "Nitrogen"; b: "Oxygen"; c: "Carbon Dioxide"; d: "Hydrogen"; correct: "Oxygen"; cat: "S"; diff: 1 }
        ListElement { q: "Mstari wa kidhahania unaogawanya dunia katika ncha ya kaskazini na kusini ni?"; a: "Equator (Ikweta)"; b: "Longitude"; c: "Tropic of Cancer"; d: "Prime Meridian"; correct: "Equator (Ikweta)"; cat: "S"; diff: 3 }
        ListElement { q: "Sauti ya kishindo inayosikika baada ya mwanga wa radi huitwa?"; a: "Umeme"; b: "Mngurumo"; c: "Upepo"; d: "Mwangwi"; correct: "Mngurumo"; cat: "S"; diff: 3 }
        ListElement { q: "Zoezi la maji kugeuka kuwa mvuke kutokana na joto huitwa?"; a: "Evaporation"; b: "Condensation"; c: "Freezing"; d: "Melting"; correct: "Evaporation"; cat: "S"; diff: 3 }
        ListElement { q: "Ni bahari gani iliyo kubwa zaidi duniani?"; a: "Hindi"; b: "Pasifiki (Pacific)"; c: "Atlantiki"; d: "Shamu"; correct: "Pasifiki (Pacific)"; cat: "S"; diff: 3 }
        ListElement { q: "Safu ya milima mirefu zaidi duniani inaitwa?"; a: "Himalayas"; b: "Andes"; c: "Alps"; d: "Kilimanjaro"; correct: "Himalayas"; cat: "S"; diff: 3 }
        ListElement { q: "Ni mkoa gani nchini Tanzania unaosifika kwa kuwa na mvua nyingi karibu mwaka mzima?"; a: "Dodoma"; b: "Njombe"; c: "Singida"; d: "Simiyu"; correct: "Njombe"; cat: "S"; diff: 1 }
        ListElement { q: "Chombo kinachopima kasi ya upepo huitwa?"; a: "Anemometer"; b: "Hygrometer"; c: "Seismograph"; d: "Compass"; correct: "Anemometer"; cat: "S"; diff: 3 }
        ListElement { q: "Vumbi na moshi vikichanganyika na ukungu angani huitwa?"; a: "Smog"; b: "Snow"; c: "Ice"; d: "Dew"; correct: "Smog"; cat: "S"; diff: 3 }
        ListElement { q: "Maji ya chumvi duniani yanapatikana kwa kiasi gani?"; a: "50%"; b: "97%"; c: "10%"; d: "75%"; correct: "97%"; cat: "S"; diff: 3 }

        ListElement { q: "Ni mbu yupi anayeeneza vimelea vya ugonjwa wa Malaria?"; a: "Anopheles Jike"; b: "Anopheles Dume"; c: "Culex"; d: "Aedes"; correct: "Anopheles Jike"; cat: "A"; diff: 3 }
        ListElement { q: "Vimelea vinavyosababisha ugonjwa wa Malaria huitwa?"; a: "Plasmodium"; b: "Amoeba"; c: "Virusi"; d: "Bacteria"; correct: "Plasmodium"; cat: "A"; diff: 3 }
        ListElement { q: "Ni njia ipi bora ya kuzuia mbu wa malaria wasikufikie ukiwa umelala?"; a: "Chandarua"; b: "Kipepeo"; c: "Kufunga mlango"; d: "Kupaka mafuta ya nazi"; correct: "Chandarua"; cat: "A"; diff: 3 }
        ListElement { q: "Malaria inashambulia zaidi seli zipi mwilini?"; a: "Seli nyekundu za damu"; b: "Seli nyeupe"; c: "Seli za ubongo"; d: "Seli za mifupa"; correct: "Seli nyekundu za damu"; cat: "A"; diff: 3 }
        ListElement { q: "Ni ipi dalili ya kawaida ya ugonjwa wa Malaria?"; a: "Homa na baridi"; b: "Kupoteza nywele"; c: "Kuumwa meno"; d: "Kuvimba miguu"; correct: "Homa na baridi"; cat: "A"; diff: 1 }
        ListElement { q: "Dawa inayopendekezwa na Serikali ya TZ kwa matibabu ya kwanza ya Malaria kwa sasa ni?"; a: "AL (Mseto)"; b: "Quinine"; c: "Panadol"; d: "Asprin"; correct: "AL (Mseto)"; cat: "A"; diff: 3 }
        ListElement { q: "Ni kundi lipi lililo hatarini zaidi kupata madhara makubwa ya Malaria?"; a: "Watoto chini ya miaka 5"; b: "Vijana"; c: "Wanaume"; d: "Wanariadha"; correct: "Watoto chini ya miaka 5"; cat: "A"; diff: 3 }
        ListElement { q: "Mbu wa malaria hupenda kuzaliana sehemu gani?"; a: "Maji yaliyotuama"; b: "Kwenye mchanga"; c: "Ndani ya chupa"; d: "Juu ya miti"; correct: "Maji yaliyotuama"; cat: "A"; diff: 3 }
        ListElement { q: "Kipimo cha haraka cha Malaria kinachotumika kwenye vituo vya afya huitwa?"; a: "mRDT"; b: "X-Ray"; c: "Ultrasound"; d: "MRI"; correct: "mRDT"; cat: "A"; diff: 3 }
        ListElement { q: "Ni kiungo gani mwilini kinachoweza kuvimba kutokana na malaria kali?"; a: "Wengu (Spleen)"; b: "Moyo"; c: "Kidole"; d: "Sikio"; correct: "Wengu (Spleen)"; cat: "A"; diff: 3 }
        ListElement { q: "Kufyeka nyasi na kufukia madimbwi ni njia ya?"; a: "Kuharibu mazalia ya mbu"; b: "Kupamba mji"; c: "Kupata mbolea"; d: "Kuongeza joto"; correct: "Kuharibu mazalia ya mbu"; cat: "A"; diff: 3 }
        ListElement { q: "Siku ya Malaria Duniani huadhimishwa kila mwaka tarehe ngapi?"; a: "Aprili 25"; b: "Desemba 1"; c: "Machi 8"; d: "Januari 1"; correct: "Aprili 25"; cat: "A"; diff: 3 }
        ListElement { q: "Ni mkoa upi Tanzania unaotajwa kuwa na maambukizi makubwa ya Malaria kutokana na hali ya hewa?"; a: "Kigoma/Geita"; b: "Dodoma"; c: "Arusha"; d: "Manyara"; correct: "Kigoma/Geita"; cat: "A"; diff: 1 }

        ListElement { q: "Ni kundi gani la kabila nchini Tanzania linalojulikana kwa kuishi kwa kuwinda na kula mizizi?"; a: "Wamasai"; b: "Wahadzabe"; c: "Wachagga"; d: "Wanyamwezi"; correct: "Wahadzabe"; cat: "BUR"; diff: 3 }
        ListElement { q: "Kabila la Wamakonde linasifika duniani kwa kipaji gani cha asili?"; a: "Ufugaji wa nyuki"; b: "Uchongaji wa vinyago"; c: "Kusuka mikeka"; d: "Ujenzi wa meli"; correct: "Uchongaji wa vinyago"; cat: "BUR"; diff: 3 }
        ListElement { q: "Ngoma ya 'Sindimba' inatokea katika makabila ya mikoa gani ya Kusini?"; a: "Mtwara na Lindi"; b: "Mbeya na Iringa"; c: "Kigoma na Tabora"; d: "Mwanza na Mara"; correct: "Mtwara na Lindi"; cat: "BUR"; diff: 3 }
        ListElement { q: "Kabila gani nchini Tanzania linaongoza kwa idadi kubwa ya watu?"; a: "Wasukuma"; b: "Waha"; c: "Wagogo"; d: "Wazaramo"; correct: "Wasukuma"; cat: "BUR"; diff: 3 }
        ListElement { q: "Chakula cha asili cha Wachagga kinachotengenezwa kwa ndizi na maharage huitwa?"; a: "Ugali"; b: "Mtori"; c: "Kiburu"; d: "Wali"; correct: "Kiburu"; cat: "BUR"; diff: 3 }

        ListElement { q: "Ni sayari gani iliyo kubwa zaidi katika mfumo wetu wa Jua?"; a: "Dunia"; b: "Saturn"; c: "Jupiter"; d: "Neptune"; correct: "Jupiter"; cat: "S"; diff: 3 }
        ListElement { q: "Mwanga wa Jua huchukua takriban dakika ngapi kufika Duniani?"; a: "Sekunde 30"; b: "Dakika 8"; c: "Saa 1"; d: "Siku 2"; correct: "Dakika 8"; cat: "S"; diff: 3 }
        ListElement { q: "Ni sayari gani inayofahamika kama 'Pacha wa Dunia' kwa sababu ya ukubwa wake?"; a: "Venus"; b: "Jupiter"; c: "Mars"; d: "Uranus"; correct: "Venus"; cat: "S"; diff: 3 }
        ListElement { q: "Eneo lenye nguvu kubwa ya uvutano angani ambapo hata mwanga hauwezi kutoroka huitwa?"; a: "Galaxy"; b: "Black Hole"; c: "Asteroid"; d: "Comet"; correct: "Black Hole"; cat: "S"; diff: 3 }

        ListElement { q: "Fuvu la binadamu wa kale (Zinjanthropus) liligunduliwa na kina Leakey katika bonde gani?"; a: "Ngorongoro"; b: "Olduvai Gorge"; c: "Bonde la Ufa"; d: "Kilimatinde"; correct: "Olduvai Gorge"; cat: "H"; diff: 3 }
        ListElement { q: "Michoro ya mapangoni ya Kondoa Irangi inasadikiwa kuchorwa na nani?"; a: "Wajerumani"; b: "Watu wa kale (Bushmen)"; c: "Waarabu"; d: "Wamasai"; correct: "Watu wa kale (Bushmen)"; cat: "UT"; diff: 3 }
        ListElement { q: "Zama ambapo binadamu alianza kutumia mawe kutengeneza vifaa huitwa?"; a: "Zama za Mawe"; b: "Zama za Chuma"; c: "Zama za Viwanda"; d: "Zama za Giza"; correct: "Zama za Mawe"; cat: "H"; diff: 3 }
        ListElement { q: "Mji wa kale wa Kilwa Kisiwani ulikuwa kitovu cha biashara katika pwani ya?"; a: "Bahari ya Hindi"; b: "Bahari ya Shamu"; c: "Ziwa Victoria"; d: "Bahari ya Mediteranea"; correct: "Bahari ya Hindi"; cat: "H"; diff: 3 }

        ListElement { q: "Soko kuu la mwisho la watumwa katika Afrika Mashariki lilikuwa wapi?"; a: "Bagamoyo"; b: "Zanzibar"; c: "Tabora"; d: "Mombasa"; correct: "Zanzibar"; cat: "H"; diff: 3 }
        ListElement { q: "Vita vya Kwanza vya Dunia (WWI) vilianza mwaka gani?"; a: "1914"; b: "1939"; c: "1884"; d: "1945"; correct: "1914"; cat: "H"; diff: 3 }
        ListElement { q: "Ni nchi gani ilivamia Poland na kusababisha kuanza kwa Vita vya Pili vya Dunia?"; a: "Uingereza"; b: "Ujerumani"; c: "Urusi"; d: "Italia"; correct: "Ujerumani"; cat: "H"; diff: 3 }
        ListElement { q: "Kiongozi wa kijeshi wa Ujerumani wakati wa Vita vya Pili vya Dunia alikuwa nani?"; a: "Adolf Hitler"; b: "Winston Churchill"; c: "Benito Mussolini"; d: "Joseph Stalin"; correct: "Adolf Hitler"; cat: "H"; diff: 3 }
        ListElement { q: "Mkataba wa Versailles ulihitimisha vita gani?"; a: "Vita vya Kwanza vya Dunia"; b: "Vita vya Pili vya Dunia"; c: "Vita vya Kagera"; d: "Vita vya Maji Maji"; correct: "Vita vya Kwanza vya Dunia"; cat: "H"; diff: 3 }
        ListElement { q: "Mji mkuu wa kitumwa ambapo watumwa walipewa jina la 'Bwagamoyo' (Bagamoyo) unamaanisha nini?"; a: "Pumzika moyo"; b: "Tupa moyo"; c: "Furahisha moyo"; d: "Fariji moyo"; correct: "Tupa moyo"; cat: "H"; diff: 3 }

        ListElement { q: "Rais gani wa Tanzania alijulikana kama 'Mzee wa Ruksa'?"; a: "Nyerere"; b: "Mwinyi"; c: "Mkapa"; d: "Kikwete"; correct: "Mwinyi"; cat: "H"; diff: 3 }
        ListElement { q: "Vita vya Kagera (1978-1979) vilikuwa kati ya Tanzania na nchi gani?"; a: "Kenya"; b: "Uganda"; c: "Rwanda"; d: "Malawi"; correct: "Uganda"; cat: "H"; diff: 3 }
        ListElement { q: "Ni nani alikuwa Rais wa Uganda wakati wa Vita vya Kagera?"; a: "Milton Obote"; b: "Idi Amin Dada"; c: "Yoweri Museveni"; d: "Tito Okello"; correct: "Idi Amin Dada"; cat: "H"; diff: 3 }
        ListElement { q: "Rais wa awamu ya nne wa Tanzania ni nani?"; a: "Ali Hassan Mwinyi"; b: "Jakaya Kikwete"; c: "Benjamin Mkapa"; d: "John Magufuli"; correct: "Jakaya Kikwete"; cat: "H"; diff: 3 }
        ListElement { q: "Tanzania ilikuwa nchi ya kwanza Afrika Mashariki kupata rais wa kike — hii ilitokea mwaka gani?"; a: "2015"; b: "2019"; c: "2021"; d: "2023"; correct: "2021"; cat: "H"; diff: 2 }
        ListElement { q: "Wimbo maarufu wa kishujaa uliotumika wakati wa Vita vya Kagera unaitwa?"; a: "Tanzania Tanzania"; b: "Mwenge wa Uhuru"; c: "Mvua ya Radi"; d: "Kifochura"; correct: "Kifochura"; cat: "H"; diff: 3 }
        ListElement { q: "Rais Benjamin Mkapa alipewa jina la utani la?"; a: "Mzee wa Mapinduzi"; b: "Mr. Clean"; c: "Bulldozer"; d: "Chuma"; correct: "Mr. Clean"; cat: "H"; diff: 3 }
        ListElement { q: "Ni Rais yupi alifariki akiwa madarakani mwaka 2021?"; a: "Nyerere"; b: "Magufuli"; c: "Mkapa"; d: "Karume"; correct: "Magufuli"; cat: "H"; diff: 3 }

        ListElement { q: "Alama ya kikemia ya dhahabu (Gold) ni ipi?"; a: "Ag"; b: "Fe"; c: "Au"; d: "Gd"; correct: "Au"; cat: "S"; diff: 3 }
        ListElement { q: "Gesi inayotumika kuzima moto inaitwa?"; a: "Oxygen"; b: "Carbon Dioxide"; c: "Hydrogen"; d: "Nitrogen"; correct: "Carbon Dioxide"; cat: "S"; diff: 1 }

        ListElement { q: "PH ya maji yaliyo safi (Pure Water) ni ngapi?"; a: "0"; b: "7"; c: "14"; d: "5"; correct: "7"; cat: "S"; diff: 3 }

        ListElement { q: "Tendo la chuma kupata kutu linahitaji vitu gani viwili?"; a: "Maji na Mafuta"; b: "Maji na Hewa (Oxygen)"; c: "Moto na Hewa"; d: "Mchanga na Maji"; correct: "Maji na Hewa (Oxygen)"; cat: "S"; diff: 1 }

        ListElement { q: "Kizio cha kupimia mkondo wa umeme (Current) ni?"; a: "Volt"; b: "Watt"; c: "Ampere"; d: "Ohm"; correct: "Ampere"; cat: "S"; diff: 3 }
        ListElement { q: "Ncha mbili za sumaku zinazofanana (mfano North na North) zikikutana hufanya nini?"; a: "Huvutana"; b: "Hupingana (Repel)"; c: "Huzima"; d: "Hulipuka"; correct: "Hupingana (Repel)"; cat: "S"; diff: 3 }


        ListElement { q: "Kifaa kinachotumika kubadili nishati ya mwendo kuwa umeme huitwa?"; a: "Motor"; b: "Dynamo/Generator"; c: "Battery"; d: "Switch"; correct: "Dynamo/Generator"; cat: "S"; diff: 3 }
        ListElement { q: "Nyaya za umeme mara nyingi hufunikwa na raba au plastiki kwa sababu ni?"; a: "Kinyeleo (Insulator)"; b: "Kipitisho (Conductor)"; c: "Nzito"; d: "Laini"; correct: "Kinyeleo (Insulator)"; cat: "S"; diff: 3 }

        ListElement { q: "Chombo cha usafiri wa majini kinachoweza kuzama na kutembea chini ya maji huitwa?"; a: "Meli"; b: "Nyambizi (Submarine)"; c: "Mtumbwi"; d: "Pantoni"; correct: "Nyambizi (Submarine)"; cat: "S"; diff: 3 }
        ListElement { q: "Ni nani anasifika kwa kuvumbua ndege ya kwanza duniani?"; a: "Wright Brothers"; b: "Thomas Edison"; c: "Henry Ford"; d: "Nikola Tesla"; correct: "Wright Brothers"; cat: "S"; diff: 3 }
        ListElement { q: "Treni ya mwendokasi inayotumia umeme nchini Tanzania inajulikana kama?"; a: "TAZARA"; b: "SGR"; c: "Mwendokasi"; d: "TRC"; correct: "SGR"; cat: "UR"; diff: 3 }
        ListElement { q: "Kifaa kinachotumika kuongoza meli au ndege kujua upande wa Kaskazini huitwa?"; a: "Thermometer"; b: "Compass"; c: "Barometer"; d: "Radar"; correct: "Compass"; cat: "S"; diff: 3 }
        ListElement { q: "Usafiri wa anga unaotumia puto kubwa lenye hewa ya moto unaitwa?"; a: "Helikopta"; b: "Hot Air Balloon"; c: "Parachute"; d: "Drone"; correct: "Hot Air Balloon"; cat: "S"; diff: 3 }


        ListElement { q: "Kitendawili: Huenda lakini harudi."; a: "Maji ya mto"; b: "Miguu"; c: "Gari"; d: "Muda"; correct: "Maji ya mto"; cat: "V"; diff: 1 }
        ListElement { q: "Kitendawili: Nyumbani kwangu kumesitiriwa kwa kuta nyeupe lakini hakuingiliki."; a: "Yai"; b: "Chumba"; c: "Gereza"; d: "Chupa"; correct: "Yai"; cat: "V"; diff: 3 }
        ListElement { q: "Kitendawili: Anatembea kwa miguu minne asubuhi, miwili mchana, na mitatu jioni."; a: "Binadamu"; b: "Kobe"; c: "Mzee"; d: "Mtoto"; correct: "Binadamu"; cat: "V"; diff: 1 }

        //music
        ListElement { q: "Msanii gani wa Tanzania alikuwa wa kwanza kushinda tuzo ya BET (Viewer's Choice Best New International Act)?"; a: "Diamond Platnumz"; b: "Rayvanny"; c: "Harmonize"; d: "Ali Kiba"; correct: "Rayvanny"; cat: "BUR"; diff: 2 }

        ListElement { q: "Kundi la vichekesho lililojizolea umaarufu mkubwa nchini Tanzania kuanzia miaka ya 2000 linaitwa?"; a: "Orijino Komedi"; b: "Vituko Show"; c: "Mizengwe"; d: "Ze Komedi"; correct: "Orijino Komedi"; cat: "BUR"; diff: 2 }

        ListElement { q: "Marehemu Steven Kanumba alikuwa mwigizaji maarufu aliyejulikana pia kwa jina lipi la kisanii?"; a: "The Great"; b: "The King"; c: "Director"; d: "Chairman"; correct: "The Great"; cat: "BUR"; diff: 2 }

        ListElement { q: "Msanii wa kike wa Bongo Flava anayeshikilia rekodi ya kutazamwa zaidi (Most Viewed) YouTube ni?"; a: "Nandy"; b: "Zuchu"; c: "Shilole"; d: "Maua Sama"; correct: "Zuchu"; cat: "BUR"; diff: 2 }

        ListElement { q: "Mchekeshaji gani nchini Tanzania anajulikana kwa mtindo wake wa kuvaa kama mwanamke na kutumia jina la 'Mkude Simba'?"; a: "Joti"; b: "Kitale"; c: "Mpoki"; d: "Mwijaku"; correct: "Kitale"; cat: "BUR"; diff: 1 }

        ListElement { q: "Filamu ya kwanza ya Kitanzania kuingia katika mashindano makubwa ya 'Oscars' nchini Marekani inaitwa?"; a: "Tug of War (Vuta N'kuvute)"; b: "Bulyanhulu"; c: "Siri ya Mtungi"; d: "Dar ni Njema"; correct: "Tug of War (Vuta N'kuvute)"; cat: "BUR"; diff: 2 }

        ListElement { q: "Msanii wa muziki anayefahamika kama 'King of Bongo Flava' na mmiliki wa lebo ya Kings Music ni?"; a: "Ali Kiba"; b: "Marioo"; c: "Dully Sykes"; d: "Professor Jay"; correct: "Ali Kiba"; cat: "BUR"; diff: 2 }

        ListElement { q: "Mwigizaji gani wa kike nchini Tanzania alishinda tuzo ya 'Best Actress' katika tamasha la AMVCA nchini Nigeria?"; a: "Wema Sepetu"; b: "Elizabeth Michael (Lulu)"; c: "Jacqueline Wolper"; d: "Irene Uwoya"; correct: "Elizabeth Michael (Lulu)"; cat: "BUR"; diff: 2 }

        ListElement { q: "Msanii gani wa vichekesho anayesifika kwa uwezo wa kuigiza sauti za viongozi mbalimbali na watu maarufu?"; a: "Mpoki"; b: "Joti"; c: "Ebitoke"; d: "Bwakila"; correct: "Joti"; cat: "BUR"; diff: 2 }

        ListElement { q: "Lebo ya muziki inayomilikiwa na Diamond Platnumz inaitwa?"; a: "WCB Wasafi"; b: "Konde Gang"; c: "Kings Music"; d: "Next Level"; correct: "WCB Wasafi"; cat: "BUR"; diff: 2 }

        ListElement { q: "Marehemu ambae alikuwa mwigizaji nguli wa maigizo ya runinga na kiongozi wa kundi la Kaole Sanaa Group ni?"; a: "Mzee Small"; b: "Mzee Majuto"; c: "Sajuki"; d: "Steve Kanumba"; correct: "Mzee Majuto"; cat: "BUR"; diff: 2 }

        ListElement { q: "Wimbo wa 'Number One' uliomtangaza Diamond Platnumz kimataifa alimshirikisha msanii gani kutoka Nigeria?"; a: "Davido"; b: "Wizkid"; c: "Burna Boy"; d: "P-Square"; correct: "Davido"; cat: "BUR"; diff: 2 }

        ListElement { q: "Mchekeshaji Coy Mzero anajulikana zaidi kupitia jukwaa gani la vichekesho nchini?"; a: "Cheka Tu"; b: "Comedy Knights"; c: "Stand Up Tanzania"; d: "Funny Fellas"; correct: "Cheka Tu"; cat: "BUR"; diff: 2 }

        // --- MAWASILIANO
        ListElement { q: "Mamlaka inayosimamia mawasiliano ya simu, intaneti, na utangazaji nchini Tanzania inaitwa?"; a: "TRA"; b: "TCRA"; c: "TANESCO"; d: "NIDA"; correct: "TCRA"; cat: "TK"; diff: 2 }

        ListElement { q: "Namba ya utambulisho wa kipekee inayopatikana kwenye simu (IMEI) hutumika kwa kazi gani?"; a: "Kupiga simu"; b: "Kutambua na kufungia simu iliyoibwa"; c: "Kuongeza salio"; d: "Kupima kasi ya intaneti"; correct: "Kutambua na kufungia simu iliyoibwa"; cat: "TK"; diff: 2 }

        ListElement { q: "Ni mfumo upi unaotumiwa na TCRA kusajili laini za simu kwa kutumia alama za vidole?"; a: "Mfumo wa Biometriki"; b: "Mfumo wa Analogi"; c: "Mfumo wa Satelaiti"; d: "Mfumo wa Sensa"; correct: "Mfumo wa Biometriki"; cat: "TK"; diff: 2 }

        ListElement { q: "Kadi ndogo inayowekwa kwenye simu ili kukuunganisha na mtandao (SIM Card) kirefu chake ni nini?"; a: "Subscriber Identity Module"; b: "System Internal Memory"; c: "Signal Integrated Mode"; d: "Social Identity Media"; correct: "Subscriber Identity Module"; cat: "TK"; diff: 2 }


        ListElement { q: "Namba ya huduma kwa wateja kwa kampuni zote za simu Tanzania iliyosanifiwa na TCRA ni ipi?"; a: "100"; b: "911"; c: "112"; d: "101"; correct: "100"; cat: "TK"; diff: 2 }

        // --- SHULE NA HISTORIA
        ListElement { q: "Mwalimu Julius K. Nyerere alisoma elimu yake ya sekondari katika shule gani maarufu?"; a: "Tabora Boys"; b: "Pugu Secondary"; c: "Mzumbe"; d: "Kibaha"; correct: "Tabora Boys"; cat: "UR"; diff: 2 }

        ListElement { q: "Ni shule ipi kati ya hizi inajulikana kama shule ya kitaifa ya wavulana yenye vipaji maalum (Special Talents School)?"; a: "Ilboru"; b: "Msalato"; c: "Jangwani"; d: "Azania"; correct: "Ilboru"; cat: "UR"; diff: 2 }

        ListElement { q: "Shule gani ya wasichana ya serikali mkoani Dodoma inajulikana kwa ufaulu mzuri na ni ya kiwango cha kitaifa?"; a: "Msalato Girls"; b: "Kilakala"; c: "Loleza"; d: "Weruweru"; correct: "Msalato Girls"; cat: "UR"; diff: 1 }

        ListElement { q: "Shule ya sekondari ya Tabora Girls inasifika kwa kuwa shule ya kwanza ya serikali kwa ajili ya?"; a: "Wasichana wenye vipaji"; b: "Walimu wa kike"; c: "Viongozi wa dini"; d: "Kilimo"; correct: "Wasichana wenye vipaji"; cat: "UR"; diff: 2 }

        ListElement { q: "Shule ya sekondari Kibaha (Kibaha Boys) inapatikana katika mkoa gani?"; a: "Dar es Salaam"; b: "Pwani"; c: "Morogoro"; d: "Tanga"; correct: "Pwani"; cat: "UR"; diff: 2 }

        ListElement { q: "Shule ipi ya kiume mkoani Morogoro inasifika kwa nidhamu ya kijeshi na ufaulu mkubwa wa masomo ya sayansi?"; a: "Mzumbe Secondary"; b: "Iyunga"; c: "Kantare"; d: "Milambo"; correct: "Mzumbe Secondary"; cat: "UR"; diff: 2 }

        // --- KILIMO CHA ZABIBU DODOMA
        ListElement { q: "Zao kuu la kibiashara linalosifika kulimwa mkoani Dodoma na kutumika kutengeneza mvinyo (Wine) ni?"; a: "Pamba"; b: "Zabibu"; c: "Karafuu"; d: "Mkonge"; correct: "Zabibu"; cat: "MK"; diff: 1 }


        ListElement { q: "Ni kata gani mkoani Dodoma inayojulikana zaidi kwa kuanzisha na kuendeleza kilimo cha zabibu?"; a: "Makutupora"; b: "Chamwino"; c: "Kizota"; d: "Msalato"; correct: "Makutupora"; cat: "MK"; diff: 1 }

        ListElement { q: "Kwa nini mkoa wa Dodoma unafaa zaidi kwa kilimo cha zabibu kuliko mikoa mingine ya Tanzania?"; a: "Udongo mweusi na baridi"; b: "Hali ya hewa kavu na jua la kutosha"; c: "Mvua nyingi mwaka mzima"; d: "Uwepo wa bahari"; correct: "Hali ya hewa kavu na jua la kutosha"; cat: "MK"; diff: 1 }

        ListElement { q: "Ni mwezi gani mara nyingi wakulima wa zabibu Dodoma hufanya mavuno ya kwanza ya mwaka?"; a: "Januari - Machi"; b: "Juni - Julai"; c: "Oktoba - Novemba"; d: "Septemba"; correct: "Januari - Machi"; cat: "MK"; diff: 1 }

        // --- TABORA BOYS
        ListElement { q: "Shule ya Tabora Boys ilianzishwa mwaka 1922 na Waingereza kwa lengo la kuwasomesha nani?"; a: "Watoto wa machifu"; b: "Wafanyakazi wa reli"; c: "Wakulima wa pamba"; d: "Askari wa vita"; correct: "Watoto wa machifu"; cat: "UR"; diff: 3 }

        ListElement { q: "Mwalimu Julius K. Nyerere alipokuwa mwanafunzi Tabora Boys (1937-1942), alikuwa kiongozi wa klabu gani?"; a: "Klabu ya Mdahalo (Debating Society)"; b: "Klabu ya Mpira"; c: "Klabu ya Skauti"; d: "Klabu ya Kilimo"; correct: "Klabu ya Mdahalo (Debating Society)"; cat: "UR"; diff: 3 }

        ListElement { q: "Jina la awali la shule ya Tabora Boys kabla ya kuitwa jina la sasa lilikuwa nani?"; a: "Pugu School"; b: "Government Central School, Tabora"; c: "Milambo Secondary"; d: "Royal Boys Academy"; correct: "Government Central School, Tabora"; cat: "UR"; diff: 3 }



        ListElement { q: "Mwanangu analia kichakani."; a: "Ndege"; b: "Shoka"; c: "Upepo"; d: "Simba"; correct: "Shoka"; cat: "V"; diff: 1 }
        ListElement { q: "Huku kuku, kule kuku."; a: "Mitungi"; b: "Mayai"; c: "Mitego"; d: "Vichuguu"; correct: "Vichuguu"; cat: "V"; diff: 3 }
        ListElement { q: "Kibakuli cha mfalme hakifuniki."; a: "Bahari"; b: "Kisima"; c: "Jicho"; d: "Sufuria"; correct: "Jicho"; cat: "V"; diff: 3 }
        ListElement { q: "Dada amevaa kilemba."; a: "Nanasi"; b: "Mahindi"; c: "Ndizi"; d: "Karamu"; correct: "Nanasi"; cat: "V"; diff: 3 }
        ListElement { q: "Popoo mbili zavuka mto."; a: "Miguu"; b: "Macho"; c: "Mikono"; d: "Masikio"; correct: "Macho"; cat: "V"; diff: 1 }
        ListElement { q: "Kuku wangu atagia mibani."; a: "Sufuria"; b: "Nanasi"; c: "Chai"; d: "Kiwavi"; correct: "Nanasi"; cat: "V"; diff: 3 }

        ListElement { q: "Umenunua bidhaa kwa 8,000 na kuuza kwa 10,000. Faida ni asilimia ngapi?"; a: "20%"; b: "25%"; c: "10%"; d: "50%"; correct: "25%"; cat: "M"; diff: 3 }
        ListElement { q: "Kikoba kina wanachama 10. Kila mmoja anachangia 5,000 kila wiki. Je, mwezi mmoja (wiki 4) watapata kiasi gani?"; a: "50,000"; b: "100,000"; c: "200,000"; d: "250,000"; correct: "200,000"; cat: "M"; diff: 3 }
        ListElement { q: "Ukichukua mkopo wa 100,000 na riba ni 10% kwa mwezi. Utarudisha jumla ya kiasi gani?"; a: "110,000"; b: "100,000"; c: "120,000"; d: "105,000"; correct: "110,000"; cat: "M"; diff: 3 }
        ListElement { q: "Bidhaa ina bei ya 12,000 ikiwa na punguzo la 50%. Bei mpya ni?"; a: "10,000"; b: "6,000"; c: "8,000"; d: "5,000"; correct: "6,000"; cat: "M"; diff: 3 }
        ListElement { q: "Mkulima ameuza gunia 5 za mahindi kwa 50,000 kila moja. Gharama za kilimo zilikuwa 150,000. Faida yake ni?"; a: "100,000"; b: "250,000"; c: "150,000"; d: "50,000"; correct: "100,000"; cat: "M"; diff: 3 }
        ListElement { q: "Hisa ya kikundi ni 10,000. Edwin ana hisa 15. Thamani ya akiba yake ni?"; a: "150,000"; b: "15,000"; c: "100,000"; d: "200,000"; correct: "150,000"; cat: "M"; diff: 3 }
        ListElement { q: "Mtaji wa biashara ni 1M. Matumizi kwa mwezi ni 200k na mauzo ni 500k. Faida halisi ni?"; a: "300,000"; b: "500,000"; c: "200,000"; d: "700,000"; correct: "300,000"; cat: "M"; diff: 3 }
        ListElement { q: "Ukibadilisha 100 USD kwa kiwango cha 2,500 TZS, utapata kiasi gani?"; a: "250,000"; b: "25,000"; c: "2,500,000"; d: "200,000"; correct: "250,000"; cat: "M"; diff: 3 }
        ListElement { q: "Lipa kwa Simu imekupa 'cashback' ya 2% kwenye muamala wa 50,000. Cashback ni kiasi gani?"; a: "1,000"; b: "500"; c: "2,000"; d: "100"; correct: "1,000"; cat: "M"; diff: 3 }
        ListElement { q: "Duka lina jumla ya lita 100 za maziwa. Limeuza 3/4. Zimebaki lita ngapi?"; a: "25"; b: "75"; c: "50"; d: "10"; correct: "25"; cat: "M"; diff: 3 }


        ListElement { q: "Timu gani ya Tanzania ilitinga hatua ya robo fainali CAF Champions League 2024?"; a: "Simba SC"; b: "Yanga SC"; c: "Azam FC"; d: "Singida FG"; correct: "Simba SC"; cat: "SP"; diff: 1 }
        ListElement { q: "Mchezaji gani wa Tanzania alikuwa wa kwanza kucheza klabu ya PAOK nchini Ugiriki?"; a: "Mbwana Samatta"; b: "Simon Msuva"; c: "Novatus Dismas"; d: "Feisal Salum"; correct: "Mbwana Samatta"; cat: "SP"; diff: 3 }
        ListElement { q: "Dabi ya Kariakoo inahusisha timu zipi?"; a: "Simba na Azam"; b: "Yanga na Azam"; c: "Simba na Yanga"; d: "Coastal na Yanga"; correct: "Simba na Yanga"; cat: "SP"; diff: 1 }
        ListElement { q: "Uwanja mkuu wa michezo jijini Dar es Salaam unaitwa?"; a: "Uhuru"; b: "Benjamin Mkapa"; c: "Azam Complex"; d: "Amaan"; correct: "Benjamin Mkapa"; cat: "SP"; diff: 3 }
        ListElement { q: "Mchezo gani ni maarufu zaidi nchini Tanzania?"; a: "Mpira wa miguu"; b: "Netiboli"; c: "Riadha"; d: "Boxing"; correct: "Mpira wa miguu"; cat: "SP"; diff: 1 }
        ListElement { q: "Filbert Bayi alijipatia umaarufu kupitia mchezo gani?"; a: "Boxing"; b: "Riadha"; c: "Soka"; d: "Tennis"; correct: "Riadha"; cat: "SP"; diff: 3 }
        ListElement { q: "Mechi ya soka hudumu kwa dakika ngapi (muda wa kawaida)?"; a: "45"; b: "60"; c: "90"; d: "120"; correct: "90"; cat: "SP"; diff: 3 }
        ListElement { q: "Wachezaji wangapi huingia uwanjani kwa timu moja ya soka kuanza mchezo?"; a: "11"; b: "7"; c: "12"; d: "10"; correct: "11"; cat: "SP"; diff: 3 }
        ListElement { q: "Kombe la AFCON 2027 litafanyika katika nchi zipi?"; a: "Tanzania pekee"; b: "Tanzania, Kenya & Uganda"; c: "Ivory Coast"; d: "South Africa"; correct: "Tanzania, Kenya & Uganda"; cat: "SP"; diff: 3 }
        ListElement { q: "Klabu ya Azam FC inamilikiwa na nani?"; a: "Mo Dewji"; b: "GSM"; c: "Said Salim Bakhresa"; d: "Manji"; correct: "Said Salim Bakhresa"; cat: "SP"; diff: 3 }

        ListElement { q: "Mti gani maarufu Tanzania unaitwa 'Mti wa Maisha' (Tree of Life)?"; a: "Mwembe"; b: "Mbuyu"; c: "Mkaratusi"; d: "Mnazi"; correct: "Mbuyu"; cat: "MK"; diff: 1 }
        ListElement { q: "Zanzibar inajulikana kimataifa kama 'Kisiwa cha' nini kutokana na zao lake kuu?"; a: "Karafuu"; b: "Kahawa"; c: "Nazi"; d: "Tangawizi"; correct: "Karafuu"; cat: "MK"; diff: 3 }
        ListElement { q: "Mmea gani hutumika kutengeneza kamba na magunia?"; a: "Mkonge"; b: "Mpunga"; c: "Mkatani"; d: "Mwanzi"; correct: "Mkonge"; cat: "MK"; diff: 3 }
        ListElement { q: "Mmea gani hutoa mafuta ya kula kwa wingi mkoani Singida?"; a: "Alizeti"; b: "Pamba"; c: "Karanga"; d: "Ufuta"; correct: "Alizeti"; cat: "MK"; diff: 3 }
        ListElement { q: "Zao la Chai hustawi zaidi katika mkoa gani?"; a: "Dodoma"; b: "Njombe"; c: "Mwanza"; d: "Dar"; correct: "Njombe"; cat: "MK"; diff: 1 }
        ListElement { q: "Mti wa Mnazi hutoa bidhaa gani maarufu pwani?"; a: "Mafuta ya mawese"; b: "Nazi na madafu"; c: "Kahawa"; d: "Zambarau"; correct: "Nazi na madafu"; cat: "MK"; diff: 3 }

        // --- MASWALI MAPYA (47) ---

        // IQ & LOGIC
        ListElement { q: "Kama unaandika namba zote kutoka 1 hadi 20, namba '1' itaonekana mara ngapi?"; a: "10"; b: "11"; c: "12"; d: "13"; correct: "12"; cat: "LG"; diff: 3 }

        ListElement { q: "Ndugu wawili walizaliwa mwaka mmoja, mwezi mmoja, siku moja — lakini si mapacha. Inawezekana vipi?"; a: "Haiwezekani"; b: "Wana baba tofauti"; c: "Ni watatu wa kuzaliwa pamoja"; d: "Walizaliwa mji tofauti"; correct: "Ni watatu wa kuzaliwa pamoja"; cat: "LG"; diff: 3 }

        ListElement { q: "Kama unakata mkate mara 3, unapata vipande vingapi?"; a: "3"; b: "4"; c: "6"; d: "8"; correct: "4"; cat: "LG"; diff: 2 }

        ListElement { q: "Ni namba gani inayofuata: 1, 1, 2, 3, 5, 8, ..."; a: 1; b: "11"; c: "12"; d: "13"; correct: "13"; cat: "M"; diff: 2 }

        // SAYANSI
        ListElement { q: "Nuru inasafiri kwa kasi ya takriban kilomita ngapi kwa sekunde moja?"; a: "300,000 km/s"; b: "3,000 km/s"; c: "30,000 km/s"; d: "3,000,000 km/s"; correct: "300,000 km/s"; cat: "S"; diff: 2 }

        ListElement { q: "Binadamu ana mifupa mingapi mwilini ukiwa mtu mzima?"; a: "206"; b: "250"; c: "180"; d: "300"; correct: "206"; cat: "A"; diff: 2 }

        // TANZANIA
        ListElement { q: "Mji Mkuu wa Tanzania (Makao Makuu ya Serikali) ni upi?"; a: "Dar es Salaam"; b: "Arusha"; c: "Dodoma"; d: "Mwanza"; correct: "Dodoma"; cat: "GEO"; diff: 1 }

        ListElement { q: "Tanzania ilipata Uhuru wake tarehe ngapi mwaka 1961?"; a: "9 Desemba"; b: "26 Aprili"; c: "12 Januari"; d: "1 Julai"; correct: "9 Desemba"; cat: "UR"; diff: 1 }

        // VITENDAWILI
        ListElement { q: "Kitendawili: Nina miguu lakini siwezi kutembea, nina mkono lakini siwezi kushika. Mimi ni nani?"; a: "Sanduku"; b: "Meza"; c: "Kiti"; d: "Kabati"; correct: "Meza"; cat: "V"; diff: 2 }

        // HESABU YA AKILI
        ListElement { q: "Kama mwalimu anasema: 'Nusu ya wanafunzi wangu ni wasichana, robo ni wavulana, waliobaki ni 6.' Darasa lina wanafunzi wangapi?"; a: "18"; b: "24"; c: "12"; d: "30"; correct: "24"; cat: "LG"; diff: 3 }

        // --- MASWALI MAPYA ZAIDI (37) ---

        // LOGIC & IQ
        ListElement { q: "Kama A ni kubwa kuliko B, na B ni kubwa kuliko C, nani ndiye mdogo zaidi?"; a: "A"; b: "B"; c: "C"; d: "Wote ni sawa"; correct: "C"; cat: "LG"; diff: 2 }
        ListElement { q: "Maneno 3 ya kwanza ya alfabeti ya Kiswahili ni?"; a: "A, B, C"; b: "A, E, I"; c: "A, B, D"; d: "A, C, D"; correct: "A, B, C"; cat: "M"; diff: 1 }
        ListElement { q: "Kama leo ni Ijumaa, siku ya 100 ijayo itakuwa siku gani?"; a: "Ijumaa"; b: "Alhamisi"; c: "Jumamosi"; d: "Jumatano"; correct: "Jumamosi"; cat: "LG"; diff: 2 }
        ListElement { q: "Namba ngapi ikiongezwa kwenye yenyewe inatoa 0?"; a: "1"; b: "Haipo"; c: "0"; d: "2"; correct: "0"; cat: "M"; diff: 2 }
        ListElement { q: "Kama gari linasafiri umbali wa km 120 kwa saa 2, kasi yake ni km ngapi kwa saa?"; a: "60 km/h"; b: "240 km/h"; c: "80 km/h"; d: "40 km/h"; correct: "60 km/h"; cat: "M"; diff: 2 }
        ListElement { q: "Pembe zote za mstatili (Rectangle) ni nyuzi ngapi kila moja?"; a: "45"; b: "60"; c: "90"; d: "180"; correct: "90"; cat: "M"; diff: 2 }
        ListElement { q: "Kama unapiga folda katikati mara 7, tabaka ngapi utapata?"; a: "14"; b: "49"; c: "128"; d: "64"; correct: "128"; cat: "LG"; diff: 2 }

        // TANZANIA — JIOGRAFIA & HISTORIA
        ListElement { q: "Mlima Kilimanjaro una urefu wa mita ngapi?"; a: "4,895m"; b: "5,895m"; c: "6,895m"; d: "3,895m"; correct: "5,895m"; cat: "UT"; diff: 2 }
        ListElement { q: "Tanzania iliungana na Zanzibar kuunda Jamhuri mwaka gani?"; a: "1961"; b: "1963"; c: "1964"; d: "1967"; correct: "1964"; cat: "UR"; diff: 2 }
        ListElement { q: "Jiji la pili kwa ukubwa nchini Tanzania ni?"; a: "Arusha"; b: "Mwanza"; c: "Dodoma"; d: "Tanga"; correct: "Mwanza"; cat: "GEO"; diff: 1 }
        ListElement { q: "Hifadhi ya Taifa ya kwanza kuanzishwa Tanzania ni?"; a: "Serengeti"; b: "Ruaha"; c: "Mikumi"; d: "Gombe"; correct: "Serengeti"; cat: "UT"; diff: 2 }
        ListElement { q: "Ziwa Tanganyika ni ziwa la pili kwa kina duniani — kina chake ni mita ngapi?"; a: "800m"; b: "1,200m"; c: "1,470m"; d: "600m"; correct: "1,470m"; cat: "GEO"; diff: 2 }
        ListElement { q: "Rais wa kwanza wa Tanzania Bara (Tanganyika) alikuwa nani?"; a: "Ali Hassan Mwinyi"; b: "Julius Kambarage Nyerere"; c: "Abeid Karume"; d: "Benjamin Mkapa"; correct: "Julius Kambarage Nyerere"; cat: "H"; diff: 2 }
        ListElement { q: "Bandari kubwa zaidi ya Tanzania ipo wapi?"; a: "Tanga"; b: "Mtwara"; c: "Dar es Salaam"; d: "Zanzibar"; correct: "Dar es Salaam"; cat: "GEO"; diff: 2 }

        // SAYANSI
        ListElement { q: "Kemikali inayotumika kufanya picha kwenye X-Ray ni ipi?"; a: "Sodium"; b: "Barium"; c: "Calcium"; d: "Potassium"; correct: "Barium"; cat: "S"; diff: 3 }
        ListElement { q: "Nishati inayotoka kwa mgawanyiko wa atomu inaitwa?"; a: "Nishati ya jua"; b: "Nishati ya nyuklia"; c: "Nishati ya mvuke"; d: "Nishati ya upepo"; correct: "Nishati ya nyuklia"; cat: "S"; diff: 2 }
        ListElement { q: "Damu ya binadamu ina pH ya takriban?"; a: "6.0"; b: "7.4"; c: "8.5"; d: "5.5"; correct: "7.4"; cat: "S"; diff: 3 }
        ListElement { q: "Mwili wa binadamu una asilimia ngapi ya maji?"; a: "40%"; b: "50%"; c: "60%"; d: "70%"; correct: "60%"; cat: "S"; diff: 2 }
        ListElement { q: "Nyota ya karibu zaidi na Jua letu inaitwa?"; a: "Sirius"; b: "Betelgeuse"; c: "Proxima Centauri"; d: "Vega"; correct: "Proxima Centauri"; cat: "S"; diff: 3 }
        ListElement { q: "Gesi inayofanya puto kuruka angani ni?"; a: "Oxygen"; b: "Nitrogen"; c: "Helium"; d: "Carbon Dioxide"; correct: "Helium"; cat: "S"; diff: 1 }

        // TEKNOLOJIA
        ListElement { q: "Kifupi cha 'PDF' ni nini?"; a: "Portable Document Format"; b: "Printed Data File"; c: "Personal Data Form"; d: "Public Document File"; correct: "Portable Document Format"; cat: "TK"; diff: 2 }
        ListElement { q: "Ni kampuni gani ilianzisha mfumo wa iOS?"; a: "Samsung"; b: "Google"; c: "Apple"; d: "Microsoft"; correct: "Apple"; cat: "TK"; diff: 1 }
        ListElement { q: "Kitufe cha 'Ctrl + Z' kwenye kompyuta hufanya nini?"; a: "Kufunga programu"; b: "Kuhifadhi faili"; c: "Kufuta (Undo)"; d: "Kunakili"; correct: "Kufuta (Undo)"; cat: "TK"; diff: 2 }
        ListElement { q: "Namba ya 'byte' moja ina 'bits' ngapi?"; a: "4"; b: "8"; c: "16"; d: "2"; correct: "8"; cat: "TK"; diff: 2 }
        ListElement { q: "Mtandao wa kwanza wa intaneti duniani ulianza mwaka gani?"; a: "1969"; b: "1985"; c: "1991"; d: "1999"; correct: "1969"; cat: "TK"; diff: 2 }

        // MICHEZO
        ListElement { q: "Mbio za marathon zina urefu wa kilomita ngapi?"; a: "40km"; b: "42.195km"; c: "45km"; d: "38km"; correct: "42.195km"; cat: "SP"; diff: 1 }
        ListElement { q: "Mchezo wa 'Volleyball' una wachezaji wangapi kwa timu moja?"; a: "5"; b: "7"; c: "6"; d: "8"; correct: "6"; cat: "SP"; diff: 1 }
        ListElement { q: "Klabu ya Manchester United inacheza uwanjani gani?"; a: "Anfield"; b: "Stamford Bridge"; c: "Old Trafford"; d: "Emirates"; correct: "Old Trafford"; cat: "SP"; diff: 1 }
        ListElement { q: "Kombe la Dunia la Soka hufanyika kila baada ya miaka mingapi?"; a: "2"; b: "3"; c: "4"; d: "5"; correct: "4"; cat: "SP"; diff: 1 }

        // VITENDAWILI VIPYA
        ListElement { q: "Kitendawili: Nina uso lakini sina macho, nina mikono lakini sina vidole. Mimi ni nani?"; a: "Sanamu"; b: "Saa"; c: "Picha"; d: "Mwili"; correct: "Saa"; cat: "V"; diff: 1 }
        ListElement { q: "Kitendawili: Ndugu wawili wanaokimbia daima lakini hawakutani kamwe."; a: "Mikono"; b: "Macho"; c: "Miguu"; d: "Masikio"; correct: "Miguu"; cat: "V"; diff: 1 }
        ListElement { q: "Kitendawili: Ninazidi kukua lakini siwezi kutembea, ninapunguza ninavyokula."; a: "Nyota"; b: "Moto"; c: "Mwaka"; d: "Jiwe"; correct: "Moto"; cat: "V"; diff: 2 }

        // AFYA
        ListElement { q: "Shinikizo la damu la kawaida kwa mtu mzima ni?"; a: "100/60"; b: "120/80"; c: "140/100"; d: "160/90"; correct: "120/80"; cat: "A"; diff: 2 }
        ListElement { q: "Vitamini inayosaidia maono (kuona) vizuri ni?"; a: "Vitamini B"; b: "Vitamini C"; c: "Vitamini A"; d: "Vitamini K"; correct: "Vitamini A"; cat: "A"; diff: 2 }
        ListElement { q: "Ugonjwa wa 'Kisukari' husababishwa na tatizo la homoni gani?"; a: "Adrenaline"; b: "Insulin"; c: "Estrogen"; d: "Testosterone"; correct: "Insulin"; cat: "A"; diff: 2 }
        ListElement { q: "Meno ya binadamu mtu mzima ni mangapi kwa kawaida?"; a: "28"; b: "30"; c: "32"; d: "36"; correct: "32"; cat: "A"; diff: 2 }
        ListElement { q: "Nchi kubwa zaidi duniani kwa eneo ni?"; a: "Canada"; b: "China"; c: "USA"; d: "Russia"; correct: "Russia"; cat: "S"; diff: 2 }

        // --- HISTORIA MPYA (+14) ---
        ListElement { q: "Vita vya Pili vya Dunia vilianza mwaka gani?"; a: "1935"; b: "1939"; c: "1941"; d: "1945"; correct: "1939"; cat: "H"; diff: 1 }
        ListElement { q: "Vita vya Maji Maji dhidi ya Wajerumani vilitokea miaka gani?"; a: "1885-1890"; b: "1905-1907"; c: "1914-1918"; d: "1920-1925"; correct: "1905-1907"; cat: "H"; diff: 2 }
        ListElement { q: "Vita vya Pili vya Dunia vilimalizika mwaka gani?"; a: "1943"; b: "1944"; c: "1945"; d: "1946"; correct: "1945"; cat: "H"; diff: 1 }
        ListElement { q: "Nchi gani ilitumia bomu la atomu mara ya kwanza duniani?"; a: "Urusi"; b: "Uingereza"; c: "Marekani"; d: "Ujerumani"; correct: "Marekani"; cat: "H"; diff: 2 }
        ListElement { q: "Ukuta wa Berlin ulianguka mwaka gani?"; a: "1985"; b: "1987"; c: "1989"; d: "1991"; correct: "1989"; cat: "H"; diff: 2 }
        ListElement { q: "Nani alikuwa Rais wa kwanza wa Marekani?"; a: "Abraham Lincoln"; b: "George Washington"; c: "Thomas Jefferson"; d: "Benjamin Franklin"; correct: "George Washington"; cat: "H"; diff: 1 }
        ListElement { q: "Mapinduzi ya Ufaransa yalitokea mwaka gani?"; a: "1776"; b: "1789"; c: "1799"; d: "1815"; correct: "1789"; cat: "H"; diff: 2 }
        ListElement { q: "Nelson Mandela alitumia miaka mingapi gerezani kabla ya kuwa Rais?"; a: "17"; b: "21"; c: "27"; d: "33"; correct: "27"; cat: "H"; diff: 2 }
        ListElement { q: "Nchi ya kwanza kutua binadamu mwezini ilikuwa ipi?"; a: "Urusi"; b: "China"; c: "Marekani"; d: "Uingereza"; correct: "Marekani"; cat: "H"; diff: 1 }
        ListElement { q: "Mwaka gani Columbus alifika Amerika?"; a: "1388"; b: "1492"; c: "1512"; d: "1620"; correct: "1492"; cat: "H"; diff: 2 }
        ListElement { q: "Dola ya Roma ilianguka mwaka gani?"; a: "476 BK"; b: "395 BK"; c: "410 BK"; d: "550 BK"; correct: "476 BK"; cat: "H"; diff: 3 }
        ListElement { q: "Nchi ya kwanza Afrika kupata uhuru wa kisasa ilikuwa ipi?"; a: "Nigeria"; b: "Ghana"; c: "Ethiopia"; d: "Misri"; correct: "Ghana"; cat: "H"; diff: 3 }
        ListElement { q: "Vita vya Pili vya Dunia viliisha baada ya nchi gani kusalimu amri mnamo Septemba 1945?"; a: "Ujerumani"; b: "Italia"; c: "Japan"; d: "Austria"; correct: "Japan"; cat: "H"; diff: 3 }
        ListElement { q: "Mtu wa kwanza kwenda angani (cosmonaut) alikuwa nani?"; a: "Neil Armstrong"; b: "Yuri Gagarin"; c: "Buzz Aldrin"; d: "Alan Shepard"; correct: "Yuri Gagarin"; cat: "H"; diff: 2 }

        // --- MICHEZO MPYA (+3) ---
        ListElement { q: "Mchezo wa Basketball una wachezaji wangapi kwa timu moja uwanjani?"; a: "4"; b: "5"; c: "6"; d: "7"; correct: "5"; cat: "SP"; diff: 1 }
        ListElement { q: "Mpira wa miguu ulianzishwa rasmi kwa sheria za kwanza nchini gani?"; a: "Ufaransa"; b: "Ujerumani"; c: "Uingereza"; d: "Italia"; correct: "Uingereza"; cat: "SP"; diff: 2 }
        ListElement { q: "Mchezaji gani anajulikana zaidi kama 'GOAT' wa mpira wa miguu duniani?"; a: "Cristiano Ronaldo"; b: "Neymar"; c: "Mbappe"; d: "Lionel Messi"; correct: "Lionel Messi"; cat: "SP"; diff: 1 }

        // --- MICHEZO ZAIDI (+14) ---
        ListElement { q: "Mchezo wa Rugby una wachezaji wangapi kwa timu moja?"; a: "11"; b: "13"; c: "15"; d: "17"; correct: "15"; cat: "SP"; diff: 2 }
        ListElement { q: "Klabu ya Barcelona inacheza uwanjani gani?"; a: "Santiago Bernabeu"; b: "Camp Nou"; c: "Wanda Metropolitano"; d: "Mestalla"; correct: "Camp Nou"; cat: "SP"; diff: 1 }
        ListElement { q: "Nchi gani imeshinda Kombe la Dunia la Soka mara nyingi zaidi?"; a: "Ujerumani"; b: "Argentina"; c: "Ufaransa"; d: "Brazil"; correct: "Brazil"; cat: "SP"; diff: 2 }
        ListElement { q: "Michezo ya Olimpiki hufanyika kila baada ya miaka mingapi?"; a: "2"; b: "3"; c: "4"; d: "5"; correct: "4"; cat: "SP"; diff: 1 }
        ListElement { q: "Urefu wa bwawa la kuogelea la Olympic ni mita ngapi?"; a: "25"; b: "50"; c: "75"; d: "100"; correct: "50"; cat: "SP"; diff: 2 }
        ListElement { q: "Mchezo wa Cricket una wachezaji wangapi kwa timu moja?"; a: "9"; b: "10"; c: "11"; d: "12"; correct: "11"; cat: "SP"; diff: 2 }
        ListElement { q: "Mchezaji wa tenisi aliyeshinda Grand Slam nyingi zaidi duniani ni?"; a: "Rafael Nadal"; b: "Roger Federer"; c: "Novak Djokovic"; d: "Pete Sampras"; correct: "Novak Djokovic"; cat: "SP"; diff: 2 }
        ListElement { q: "Mchezo wa Table Tennis (Ping Pong) ulianzishwa nchi gani?"; a: "China"; b: "Japan"; c: "Uingereza"; d: "Marekani"; correct: "Uingereza"; cat: "SP"; diff: 3 }
        ListElement { q: "Klabu ya Real Madrid ina lakabu gani maarufu?"; a: "Los Blancos"; b: "Los Rojos"; c: "El Clasico"; d: "La Furia"; correct: "Los Blancos"; cat: "SP"; diff: 2 }
        ListElement { q: "Michezo ya Olimpiki ya kisasa ilianzishwa mwaka gani na nchi gani?"; a: "1892 — Ufaransa"; b: "1896 — Ugiriki"; c: "1900 — Uingereza"; d: "1904 — Marekani"; correct: "1896 — Ugiriki"; cat: "SP"; diff: 2 }
        ListElement { q: "Mchezaji wa mpira wa kikapu (NBA) anayejulikana kwa jina 'King James' ni nani?"; a: "Kobe Bryant"; b: "Michael Jordan"; c: "LeBron James"; d: "Stephen Curry"; correct: "LeBron James"; cat: "SP"; diff: 1 }
        ListElement { q: "Mchezo wa Golf unachezwa kwenye mashimo mangapi kwa raundi kamili?"; a: "9"; b: "12"; c: "18"; d: "24"; correct: "18"; cat: "SP"; diff: 2 }
        ListElement { q: "Mbio za kasi zaidi duniani za mita 100 zinashikiliwa na mwanariadha gani?"; a: "Carl Lewis"; b: "Asafa Powell"; c: "Yohan Blake"; d: "Usain Bolt"; correct: "Usain Bolt"; cat: "SP"; diff: 1 }
        ListElement { q: "Timu ya Tanzania ya Netball inaitwa jina gani rasmi?"; a: "Tanzania Leopards"; b: "Twiga Stars"; c: "Serengeti Queens"; d: "Kilimanjaro Stars"; correct: "Twiga Stars"; cat: "SP"; diff: 2 }

        // --- VITENDAWILI ZAIDI (+7) ---
        ListElement { q: "Kitendawili: Nina ndugu wengi lakini hatuzaliwi na mama mmoja. Sisi ni nini?"; a: "Nyota"; b: "Meno"; c: "Vidole"; d: "Matawi"; correct: "Vidole"; cat: "V"; diff: 2 }
        ListElement { q: "Kitendawili: Ninakuona lakini huwezi kunishika. Mimi ni nani?"; a: "Pumzi"; b: "Kivuli"; c: "Ndoto"; d: "Upepo"; correct: "Kivuli"; cat: "V"; diff: 1 }
        ListElement { q: "Kitendawili: Nina miguu mingi lakini siendi popote. Mimi ni nani?"; a: "Meza"; b: "Mti"; c: "Kiti"; d: "Mlango"; correct: "Meza"; cat: "V"; diff: 1 }
        ListElement { q: "Kitendawili: Ninaingia ukuta lakini siuvunji. Mimi ni nani?"; a: "Msumari"; b: "Jicho"; c: "Sindano"; d: "Neno"; correct: "Msumari"; cat: "V"; diff: 2 }
        ListElement { q: "Kitendawili: Kadiri unavyonichimba ndivyo ninavyokukua. Mimi ni nani?"; a: "Mto"; b: "Shimo"; c: "Kisima"; d: "Mazao"; correct: "Shimo"; cat: "V"; diff: 2 }
        ListElement { q: "Kitendawili: Ninazaliwa maji, ninaishi maji, lakini nikitumbukizwa majini, ninakufa. Mimi ni nani?"; a: "Samaki"; b: "Chumvi"; c: "Mchanga"; d: "Barafu"; correct: "Chumvi"; cat: "V"; diff: 3 }
        ListElement { q: "Kitendawili: Ninapita mlangoni bila kusema hodi. Mimi ni nani?"; a: "Mwizi"; b: "Pumzi"; c: "Upepo"; d: "Nuru"; correct: "Upepo"; cat: "V"; diff: 2 }


        // ═══════════════════════════════════════════════════
        ListElement { q: "Mtaa maarufu wa biashara jijini Dar es Salaam unaofahamika kwa soko kubwa ni?"; a: "Kinondoni"; b: "Kariakoo"; c: "Ilala"; d: "Temeke"; correct: "Kariakoo"; cat: "GEO"; diff: 1 }
        ListElement { q: "Wilaya ya Kinondoni ipo katika mkoa gani?"; a: "Pwani"; b: "Morogoro"; c: "Dar es Salaam"; d: "Coast"; correct: "Dar es Salaam"; cat: "GEO"; diff: 1 }
        ListElement { q: "Mji wa Arusha unajulikana kama 'Geneva ya Afrika' kwa sababu gani?"; a: "Una mito mingi"; b: "Una makao ya mashirika ya kimataifa"; c: "Una baridi kali"; d: "Una watalii wengi"; correct: "Una makao ya mashirika ya kimataifa"; cat: "GEO"; diff: 2 }
        ListElement { q: "Wilaya ipi nchini Tanzania inajulikana kwa uzalishaji mkubwa wa kahawa?"; a: "Rungwe"; b: "Kilosa"; c: "Moshi"; d: "Njombe"; correct: "Moshi"; cat: "GEO"; diff: 2 }
        ListElement { q: "Bandari ya Dar es Salaam iko katika bonde la?"; a: "Bonde la Ufa"; b: "Ghuba ya Hindi"; c: "Bahari ya Atlantiki"; d: "Mto Rufiji"; correct: "Ghuba ya Hindi"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mji wa Dodoma ulianza rasmi kuwa Mji Mkuu wa Tanzania mwaka gani?"; a: "1973"; b: "1996"; c: "2005"; d: "1985"; correct: "1996"; cat: "GEO"; diff: 3 }
        ListElement { q: "Jimbo la Zanzibar linajumuisha visiwa vikuu vingapi?"; a: "2"; b: "3"; c: "4"; d: "5"; correct: "2"; cat: "GEO"; diff: 2 }
        ListElement { q: "Kisiwa cha Unguja kina mji mkuu unaeitwa?"; a: "Chake Chake"; b: "Wete"; c: "Zanzibar Town (Stone Town)"; d: "Mkoani"; correct: "Zanzibar Town (Stone Town)"; cat: "GEO"; diff: 1 }
        ListElement { q: "Kisiwa cha Pemba kina mji mkuu unaeitwa?"; a: "Stone Town"; b: "Chake Chake"; c: "Wete"; d: "Mkokotoni"; correct: "Chake Chake"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mkoa wa Kagera unapakana na nchi gani upande wa kaskazini?"; a: "Kenya"; b: "Uganda na Rwanda"; c: "Burundi"; d: "DRC"; correct: "Uganda na Rwanda"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mji wa Mwanza unapigiwa kura kama jiji la pili kwa ukubwa Tanzania — uko karibu na ziwa gani?"; a: "Tanganyika"; b: "Nyasa"; c: "Victoria"; d: "Eyasi"; correct: "Victoria"; cat: "GEO"; diff: 1 }
        ListElement { q: "Wilaya ya Ngorongoro inajulikana zaidi kwa nini?"; a: "Mgodi wa dhahabu"; b: "Bonde la Ngorongoro na wanyama"; c: "Mlima Kilimanjaro"; d: "Hifadhi ya samaki"; correct: "Bonde la Ngorongoro na wanyama"; cat: "UT"; diff: 1 }
        ListElement { q: "Mji wa Tanga uliojulikana kikoloni kama 'Lango la Tanzania' uko mkoa gani?"; a: "Pwani"; b: "Moshi"; c: "Tanga"; d: "Kilimanjaro"; correct: "Tanga"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mkoa ulio na mipaka na nchi nyingi zaidi Tanzania ni?"; a: "Kagera"; b: "Mara"; c: "Kigoma"; d: "Ruvuma"; correct: "Kagera"; cat: "GEO"; diff: 3 }
        ListElement { q: "Hifadhi ya Taifa ya Serengeti ipo mkoa gani?"; a: "Mara"; b: "Arusha"; c: "Manyara"; d: "Simiyu"; correct: "Mara"; cat: "UT"; diff: 2 }
        ListElement { q: "Mji wa Morogoro unajulikana kwa kitu gani?"; a: "Bandari"; b: "Mlima Uluguru na elimu (SUA)"; c: "Mgodi wa almasi"; d: "Pwani ndefu"; correct: "Mlima Uluguru na elimu (SUA)"; cat: "GEO"; diff: 2 }
        ListElement { q: "Wilaya ya Kilosa ipo mkoa gani?"; a: "Dodoma"; b: "Morogoro"; c: "Pwani"; d: "Iringa"; correct: "Morogoro"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mto Rufiji unamwaga maji yake baharini katika eneo lipi?"; a: "Dar es Salaam"; b: "Lindi"; c: "Delta ya Rufiji (Pwani)"; d: "Tanga"; correct: "Delta ya Rufiji (Pwani)"; cat: "GEO"; diff: 3 }
        ListElement { q: "Mkoa wa Iringa unajulikana kwa zao gani kuu?"; a: "Kahawa"; b: "Mahindi na chai"; c: "Tumbaku"; d: "Pamba"; correct: "Mahindi na chai"; cat: "GEO"; diff: 2 }
        ListElement { q: "Jiji la Mbeya linajulikana kama 'Mlango wa Kusini' kwa sababu?"; a: "Lina bandari"; b: "Ni mpakani mwa Zambia na Malawi"; c: "Lina milima mingi"; d: "Lina soko kubwa"; correct: "Ni mpakani mwa Zambia na Malawi"; cat: "GEO"; diff: 2 }
        ListElement { q: "Hifadhi ya Msitu wa Jozani ipo kisiwa gani?"; a: "Pemba"; b: "Unguja (Zanzibar)"; c: "Mafia"; d: "Ukerewe"; correct: "Unguja (Zanzibar)"; cat: "UT"; diff: 2 }
        ListElement { q: "Kisiwa cha Mafia kipo mkoa gani?"; a: "Dar es Salaam"; b: "Lindi"; c: "Pwani"; d: "Mtwara"; correct: "Pwani"; cat: "GEO"; diff: 3 }
        ListElement { q: "Mji wa Tabora uliokuwa kitovu cha njia za biashara ya watumwa unajulikana kwa jina gani la kale?"; a: "Kazeh"; b: "Ujiji"; c: "Kondoa"; d: "Kilwa"; correct: "Kazeh"; cat: "GEO"; diff: 3 }
        ListElement { q: "Mkoa wa Lindi uko upande gani wa Tanzania?"; a: "Kaskazini-Mashariki"; b: "Kusini-Mashariki"; c: "Kaskazini-Magharibi"; d: "Kati"; correct: "Kusini-Mashariki"; cat: "GEO"; diff: 1 }
        ListElement { q: "Ziwa Nyasa (Malawi) linapakana na wilaya zipi za Tanzania upande wa mashariki?"; a: "Songwe na Kyela"; b: "Iringa na Njombe"; c: "Ruvuma na Songea"; d: "Mbeya na Chunya"; correct: "Songwe na Kyela"; cat: "GEO"; diff: 3 }
        ListElement { q: "Mji wa Ujiji karibu na Kigoma unajulikana kwa tukio gani la kihistoria?"; a: "Vita vya Maji Maji"; b: "Stanley kukutana na Livingstone"; c: "Kuanzishwa kwa TANU"; d: "Mapinduzi ya Zanzibar"; correct: "Stanley kukutana na Livingstone"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mkoa wa Geita ulianzishwa mwaka gani?"; a: "2002"; b: "2005"; c: "2012"; d: "2015"; correct: "2012"; cat: "GEO"; diff: 3 }
        ListElement { q: "Wilaya ya Kibaha ipo mkoa gani?"; a: "Dar es Salaam"; b: "Morogoro"; c: "Pwani"; d: "Tanga"; correct: "Pwani"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mji wa Musoma uko pwani ya ziwa gani?"; a: "Tanganyika"; b: "Victoria"; c: "Nyasa"; d: "Natron"; correct: "Victoria"; cat: "GEO"; diff: 2 }
        ListElement { q: "Hifadhi ya Taifa ya Ruaha ipo mkoa gani?"; a: "Iringa"; b: "Morogoro"; c: "Dodoma"; d: "Njombe"; correct: "Iringa"; cat: "UT"; diff: 2 }
        ListElement { q: "Mkoa wa Njombe unajulikana zaidi kwa nini?"; a: "Madini ya dhahabu"; b: "Chai na mbao"; c: "Uvuvi"; d: "Pamba"; correct: "Chai na mbao"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mji wa Songea uko mkoa gani?"; a: "Lindi"; b: "Mtwara"; c: "Ruvuma"; d: "Njombe"; correct: "Ruvuma"; cat: "GEO"; diff: 1 }
        ListElement { q: "Ziwa Rukwa lipo mkoa gani?"; a: "Katavi"; b: "Kigoma"; c: "Tabora"; d: "Mbeya"; correct: "Katavi"; cat: "GEO"; diff: 3 }
        ListElement { q: "Mkoa wa Simiyu ulianzishwa kutoka mkoa gani?"; a: "Mara"; b: "Shinyanga"; c: "Mwanza"; d: "Tabora"; correct: "Shinyanga"; cat: "GEO"; diff: 3 }
        ListElement { q: "Mto Kagera unatoka wapi na kumwaga maji wapi?"; a: "Rwanda → Ziwa Victoria"; b: "Uganda → Ziwa Tanganyika"; c: "Burundi → Bahari ya Hindi"; d: "Kenya → Ziwa Nyasa"; correct: "Rwanda → Ziwa Victoria"; cat: "GEO"; diff: 3 }
        ListElement { q: "Wilaya ya Nzega ipo mkoa gani?"; a: "Shinyanga"; b: "Tabora"; c: "Mwanza"; d: "Simiyu"; correct: "Tabora"; cat: "GEO"; diff: 2 }
        ListElement { q: "Hifadhi ya Taifa ya Mikumi ipo mkoa gani?"; a: "Iringa"; b: "Dodoma"; c: "Morogoro"; d: "Pwani"; correct: "Morogoro"; cat: "UT"; diff: 2 }
        ListElement { q: "Mji wa Babati uko mkoa gani?"; a: "Arusha"; b: "Manyara"; c: "Kilimanjaro"; d: "Singida"; correct: "Manyara"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mkoa wa Katavi ulijulikana zamani kwa jina gani?"; a: "Tabora Kaskazini"; b: "Mpanda"; c: "Kigoma Kusini"; d: "Rukwa Magharibi"; correct: "Mpanda"; cat: "GEO"; diff: 3 }
        ListElement { q: "Wilaya ya Monduli ipo mkoa gani?"; a: "Kilimanjaro"; b: "Manyara"; c: "Arusha"; d: "Tanga"; correct: "Arusha"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mji wa Shinyanga unajulikana kwa kitu gani?"; a: "Uvuvi"; b: "Almasi na pamba"; c: "Kahawa"; d: "Chai"; correct: "Almasi na pamba"; cat: "GEO"; diff: 1 }
        ListElement { q: "Hifadhi ya Taifa ya Gombe ipo mkoa gani na inajulikana kwa nini?"; a: "Kigoma — sokwe"; b: "Mara — simba"; c: "Kagera — ndege"; d: "Katavi — tembo"; correct: "Kigoma — sokwe"; cat: "UT"; diff: 2 }
        ListElement { q: "Wilaya ya Bagamoyo ipo mkoa gani?"; a: "Dar es Salaam"; b: "Tanga"; c: "Pwani"; d: "Morogoro"; correct: "Pwani"; cat: "GEO"; diff: 2 }
        ListElement { q: "Jiji la Dar es Salaam lina wilaya ngapi?"; a: "3"; b: "4"; c: "5"; d: "6"; correct: "5"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mkoa wa Manyara ulianzishwa kutoka mkoa gani?"; a: "Arusha"; b: "Dodoma"; c: "Kilimanjaro"; d: "Singida"; correct: "Arusha"; cat: "GEO"; diff: 3 }
        ListElement { q: "Wilaya ya Muleba ipo mkoa gani?"; a: "Mwanza"; b: "Geita"; c: "Kagera"; d: "Mara"; correct: "Kagera"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mji wa Korogwe uko mkoa gani?"; a: "Morogoro"; b: "Tanga"; c: "Pwani"; d: "Kilimanjaro"; correct: "Tanga"; cat: "GEO"; diff: 2 }
        ListElement { q: "Hifadhi ya Taifa ya Mahale ipo mkoa gani na inajulikana kwa nini?"; a: "Kigoma — sokwe"; b: "Katavi — simba"; c: "Rukwa — ndege wa maji"; d: "Tabora — tembo"; correct: "Kigoma — sokwe"; cat: "UT"; diff: 3 }
        ListElement { q: "Wilaya ya Chato ipo mkoa gani?"; a: "Mwanza"; b: "Kagera"; c: "Geita"; d: "Mara"; correct: "Geita"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mji wa Voi uko upande gani wa mpaka wa Tanzania-Kenya?"; a: "Upande wa Kenya"; b: "Upande wa Tanzania"; c: "Katikati ya mpaka"; d: "Ni jina la ziwa"; correct: "Upande wa Kenya"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mkoa wa Pwani una wilaya ngapi?"; a: "5"; b: "6"; c: "7"; d: "8"; correct: "7"; cat: "GEO"; diff: 3 }
        ListElement { q: "Wilaya ya Ilala ipo jijini gani?"; a: "Mwanza"; b: "Dar es Salaam"; c: "Dodoma"; d: "Arusha"; correct: "Dar es Salaam"; cat: "GEO"; diff: 1 }
        ListElement { q: "Mji wa Bukoba uko pwani ya ziwa gani?"; a: "Tanganyika"; b: "Victoria"; c: "Nyasa"; d: "Rukwa"; correct: "Victoria"; cat: "GEO"; diff: 1 }
        ListElement { q: "Hifadhi ya Taifa ya Kitulo ipo mkoa gani?"; a: "Mbeya"; b: "Njombe"; c: "Iringa"; d: "Songwe"; correct: "Njombe"; cat: "UT"; diff: 3 }
        ListElement { q: "Wilaya ya Moshi ipo mkoa gani?"; a: "Arusha"; b: "Manyara"; c: "Kilimanjaro"; d: "Tanga"; correct: "Kilimanjaro"; cat: "GEO"; diff: 1 }
        ListElement { q: "Mkoa wa Songwe ulianzishwa kutoka mkoa gani mwaka 2016?"; a: "Iringa"; b: "Mbeya"; c: "Njombe"; d: "Rukwa"; correct: "Mbeya"; cat: "GEO"; diff: 3 }
        ListElement { q: "Mji wa Sumbawanga uko mkoa gani?"; a: "Katavi"; b: "Kigoma"; c: "Rukwa"; d: "Tabora"; correct: "Rukwa"; cat: "GEO"; diff: 2 }
        ListElement { q: "Wilaya ya Rombo ipo mkoa gani?"; a: "Arusha"; b: "Manyara"; c: "Kilimanjaro"; d: "Tanga"; correct: "Kilimanjaro"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mji wa Lindi uko mkoa gani na upande gani wa Tanzania?"; a: "Lindi — Kusini-Mashariki"; b: "Mtwara — Kusini"; c: "Ruvuma — Kusini-Magharibi"; d: "Pwani — Mashariki"; correct: "Lindi — Kusini-Mashariki"; cat: "GEO"; diff: 2 }
        ListElement { q: "Wilaya ya Bariadi ipo mkoa gani?"; a: "Shinyanga"; b: "Mwanza"; c: "Simiyu"; d: "Mara"; correct: "Simiyu"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mkoa wa Mara unapakana na nchi gani?"; a: "Uganda"; b: "Kenya"; c: "Rwanda"; d: "Burundi"; correct: "Kenya"; cat: "GEO"; diff: 2 }
        ListElement { q: "Hifadhi ya Taifa ya Udzungwa ipo mkoa gani?"; a: "Iringa"; b: "Morogoro"; c: "Dodoma"; d: "Njombe"; correct: "Morogoro"; cat: "UT"; diff: 3 }
        ListElement { q: "Wilaya ya Masasi ipo mkoa gani?"; a: "Lindi"; b: "Ruvuma"; c: "Mtwara"; d: "Pwani"; correct: "Mtwara"; cat: "GEO"; diff: 2 }

        // ═══════════════════════════════════════════════════
        // MADA MPYA 2: ELIMU YA URAIA (UR) — 60 maswali
        // ═══════════════════════════════════════════════════
        ListElement { q: "Katiba ya sasa ya Tanzania (Jamhuri ya Muungano) ilipitishwa mwaka gani?"; a: "1961"; b: "1977"; c: "1964"; d: "1985"; correct: "1977"; cat: "UR"; diff: 2 }
        ListElement { q: "Mihimili mitatu ya serikali ya Tanzania ni?"; a: "Rais, Bunge, Mahakama"; b: "Serikali, Upinzani, Jeshi"; c: "Bunge, Wizara, Polisi"; d: "Rais, Waziri Mkuu, Spika"; correct: "Rais, Bunge, Mahakama"; cat: "UR"; diff: 1 }
        ListElement { q: "Haki ya kupiga kura Tanzania inaanza umri gani?"; a: "16"; b: "18"; c: "21"; d: "25"; correct: "18"; cat: "UR"; diff: 1 }
        ListElement { q: "Bunge la Tanzania lina aina ngapi za wabunge?"; a: "2"; b: "3"; c: "4"; d: "5"; correct: "3"; cat: "UR"; diff: 3 }
        ListElement { q: "Tume inayosimamia uchaguzi nchini Tanzania inaitwa?"; a: "TRA"; b: "TAKUKURU"; c: "NEC"; d: "CHADEMA"; correct: "NEC"; cat: "UR"; diff: 1 }
        ListElement { q: "Kifupi cha TAKUKURU kinamaanisha nini?"; a: "Taasisi ya Kukuza Uchumi"; b: "Taasisi ya Kuzuia na Kupambana na Rushwa"; c: "Taasisi ya Kudhibiti Umeme"; d: "Taasisi ya Kuhifadhi Utamaduni"; correct: "Taasisi ya Kuzuia na Kupambana na Rushwa"; cat: "UR"; diff: 2 }
        ListElement { q: "Raia wa Tanzania ana haki ya msingi ipi inayolindwa na Katiba?"; a: "Kupata kazi tu"; b: "Uhuru wa maoni, dini, na usawa mbele ya sheria"; c: "Kupata ardhi bure"; d: "Kutolipa kodi"; correct: "Uhuru wa maoni, dini, na usawa mbele ya sheria"; cat: "UR"; diff: 2 }
        ListElement { q: "Mkoa katika Jamhuri ya Tanzania unaongozwa na?"; a: "Meya"; b: "Mkurugenzi"; c: "Mkuu wa Mkoa"; d: "Gavana"; correct: "Mkuu wa Mkoa"; cat: "UR"; diff: 1 }
        ListElement { q: "Serikali ya Mtaa (LGA) inajumuisha nini?"; a: "Halmashauri za wilaya, mji na jiji"; b: "Bunge na mahakama"; c: "Wizara na idara"; d: "Polisi na jeshi"; correct: "Halmashauri za wilaya, mji na jiji"; cat: "UR"; diff: 2 }
        ListElement { q: "Mahakama ya juu kabisa nchini Tanzania inaitwa?"; a: "Mahakama Kuu"; b: "Mahakama ya Rufaa"; c: "Mahakama ya Hakimu Mkazi"; d: "Baraza la Mawaziri"; correct: "Mahakama ya Rufaa"; cat: "UR"; diff: 2 }
        ListElement { q: "Haki ya binadamu ni nini kwa mujibu wa sheria za kimataifa?"; a: "Haki anazopewa na serikali tu"; b: "Haki za msingi alizozaliwa nazo binadamu yeyote"; c: "Haki za watu wenye pesa"; d: "Haki za watu wazima tu"; correct: "Haki za msingi alizozaliwa nazo binadamu yeyote"; cat: "UR"; diff: 2 }
        ListElement { q: "Azimio la Haki za Binadamu la Umoja wa Mataifa lilitangazwa mwaka gani?"; a: "1945"; b: "1948"; c: "1955"; d: "1963"; correct: "1948"; cat: "UR"; diff: 2 }
        ListElement { q: "Mwenyekiti wa Baraza la Mawaziri Tanzania ni nani?"; a: "Waziri Mkuu"; b: "Spika"; c: "Rais"; d: "Jaji Mkuu"; correct: "Rais"; cat: "UR"; diff: 2 }
        ListElement { q: "Nchi ya Tanzania ina mfumo gani wa uchaguzi wa urais?"; a: "Wingi wa kura (First Past the Post)"; b: "Kura mbili (Two-round system)"; c: "Proportional representation"; d: "Kura ya bunge"; correct: "Wingi wa kura (First Past the Post)"; cat: "UR"; diff: 3 }
        ListElement { q: "Taasisi inayolinda haki za binadamu Tanzania inaitwa?"; a: "TAKUKURU"; b: "CHRAGG"; c: "NEC"; d: "TRA"; correct: "CHRAGG"; cat: "UR"; diff: 3 }
        ListElement { q: "Raia ana wajibu gani muhimu kwa nchi?"; a: "Kufuata sheria na kulipa kodi"; b: "Kupiga kura tu"; c: "Kwenda kanisani au msikitini"; d: "Kufanya kazi serikalini"; correct: "Kufuata sheria na kulipa kodi"; cat: "UR"; diff: 1 }
        ListElement { q: "Kodi ya mapato (income tax) nchini Tanzania inakusanywa na?"; a: "Benki Kuu"; b: "TRA (Tanzania Revenue Authority)"; c: "Hazina ya Taifa"; d: "Wizara ya Fedha"; correct: "TRA (Tanzania Revenue Authority)"; cat: "UR"; diff: 1 }
        ListElement { q: "Katiba ya Tanzania inasema ardhi yote nchini inamilikiwa na?"; a: "Serikali ya Tanzania"; b: "Raia wote kwa pamoja"; c: "Rais wa Tanzania"; d: "Halmashauri za wilaya"; correct: "Raia wote kwa pamoja"; cat: "UR"; diff: 2 }
        ListElement { q: "Chama tawala nchini Tanzania kwa miaka mingi kimekuwa?"; a: "CHADEMA"; b: "CUF"; c: "CCM"; d: "ACT-Wazalendo"; correct: "CCM"; cat: "UR"; diff: 1 }
        ListElement { q: "Mfumo wa vyama vingi vya siasa Tanzania ulianza rasmi mwaka gani?"; a: "1985"; b: "1990"; c: "1992"; d: "1995"; correct: "1992"; cat: "UR"; diff: 2 }
        ListElement { q: "Polisi wa Tanzania wako chini ya Wizara gani?"; a: "Wizara ya Ulinzi"; b: "Wizara ya Mambo ya Ndani"; c: "Wizara ya Sheria"; d: "Wizara ya Fedha"; correct: "Wizara ya Mambo ya Ndani"; cat: "UR"; diff: 2 }
        ListElement { q: "Nambari ya dharura ya Polisi Tanzania ni?"; a: "112"; b: "999"; c: "911"; d: "100"; correct: "112"; cat: "UR"; diff: 1 }
        ListElement { q: "Haki ya elimu ya msingi bure nchini Tanzania inalindwa na?"; a: "Sheria ya Elimu"; b: "Katiba ya Tanzania"; c: "Mwongozo wa CCM"; d: "Sheria ya Watoto"; correct: "Katiba ya Tanzania"; cat: "UR"; diff: 2 }
        ListElement { q: "Taasisi inayosimamia usalama wa chakula na dawa Tanzania ni?"; a: "TFDA"; b: "SUMATRA"; c: "EWURA"; d: "TANESCO"; correct: "TFDA"; cat: "UR"; diff: 2 }
        ListElement { q: "Kifupi cha TRA kinamaanisha nini?"; a: "Tanzania Roads Authority"; b: "Tanzania Revenue Authority"; c: "Tanzania Railway Authority"; d: "Tanzania Relief Authority"; correct: "Tanzania Revenue Authority"; cat: "UR"; diff: 1 }
        ListElement { q: "Mkurugenzi wa wilaya anashughulikia nini hasa?"; a: "Usalama wa jeshi"; b: "Maendeleo ya wilaya na utekelezaji wa sera"; c: "Uchaguzi tu"; d: "Kodi za mauzo"; correct: "Maendeleo ya wilaya na utekelezaji wa sera"; cat: "UR"; diff: 2 }
        ListElement { q: "Umoja wa Mataifa (UN) una makao makuu yake wapi?"; a: "Geneva, Uswisi"; b: "Brussels, Ubelgiji"; c: "New York, Marekani"; d: "London, Uingereza"; correct: "New York, Marekani"; cat: "UR"; diff: 1 }
        ListElement { q: "Shirika la kuhakikisha haki za watoto kimataifa linaitwa?"; a: "UNESCO"; b: "UNICEF"; c: "WHO"; d: "UNHCR"; correct: "UNICEF"; cat: "UR"; diff: 2 }
        ListElement { q: "Sheria ya kupinga ukatili wa kijinsia Tanzania ilipitishwa mwaka gani?"; a: "1998"; b: "2002"; c: "2010"; d: "2016"; correct: "1998"; cat: "UR"; diff: 3 }
        ListElement { q: "Nani ana mamlaka ya kutangaza hali ya hatari (State of Emergency) Tanzania?"; a: "Jeshi la ulinzi"; b: "Bunge"; c: "Rais"; d: "Mahakama ya Rufaa"; correct: "Rais"; cat: "UR"; diff: 2 }
        ListElement { q: "Muda wa kura za uchaguzi mkuu Tanzania kwa kawaida ni saa ngapi?"; a: "06:00 - 18:00"; b: "07:00 - 16:00"; c: "08:00 - 17:00"; d: "06:00 - 20:00"; correct: "07:00 - 16:00"; cat: "UR"; diff: 3 }
        ListElement { q: "Benki Kuu ya Tanzania inaitwa?"; a: "NMB"; b: "CRDB"; c: "Benki Kuu ya Tanzania (BOT)"; d: "NBC"; correct: "Benki Kuu ya Tanzania (BOT)"; cat: "UR"; diff: 1 }
        ListElement { q: "Sarafu rasmi ya Tanzania ni?"; a: "Dola la Tanzania"; b: "Shilingi ya Tanzania"; c: "Paundi la Tanzania"; d: "Faranga ya Tanzania"; correct: "Shilingi ya Tanzania"; cat: "UR"; diff: 1 }
        ListElement { q: "Haki ya kutokuwa na utumwa inalindwa na kifungu gani cha Katiba?"; a: "Ibara ya 13"; b: "Ibara ya 16"; c: "Ibara ya 23"; d: "Ibara ya 5"; correct: "Ibara ya 16"; cat: "UR"; diff: 3 }
        ListElement { q: "Taasisi inayosimamia umeme Tanzania inaitwa?"; a: "SUMATRA"; b: "EWURA"; c: "TANESCO"; d: "DAWASCO"; correct: "TANESCO"; cat: "UR"; diff: 1 }
        ListElement { q: "Taasisi inayosimamia maji Dar es Salaam inaitwa?"; a: "TANESCO"; b: "DAWASCO"; c: "EWURA"; d: "TRA"; correct: "DAWASCO"; cat: "UR"; diff: 2 }
        ListElement { q: "Wizara inayoshughulikia ardhi Tanzania inaitwa?"; a: "Wizara ya Mipango"; b: "Wizara ya Ardhi, Nyumba na Maendeleo ya Makazi"; c: "Wizara ya Kilimo"; d: "Wizara ya Ujenzi"; correct: "Wizara ya Ardhi, Nyumba na Maendeleo ya Makazi"; cat: "UR"; diff: 2 }
        ListElement { q: "Hati inayomthibitishu mtu kuwa raia wa Tanzania inaitwa?"; a: "Pasipoti"; b: "Cheti cha kuzaliwa"; c: "Kitambulisho cha Taifa (NIDA)"; d: "Leseni ya udereva"; correct: "Kitambulisho cha Taifa (NIDA)"; cat: "UR"; diff: 1 }
        ListElement { q: "Kura ya maoni ya katiba mpya Tanzania ilifanyika mwaka gani?"; a: "2010"; b: "2014"; c: "Haikufanyika bado"; d: "2018"; correct: "Haikufanyika bado"; cat: "UR"; diff: 3 }
        ListElement { q: "Umri wa chini wa kugombea urais Tanzania ni?"; a: "30"; b: "35"; c: "40"; d: "45"; correct: "40"; cat: "UR"; diff: 2 }
        ListElement { q: "Shirika la uzalendo linalowakilisha wafanyakazi Tanzania linaitwa?"; a: "CCM"; b: "TUCTA"; c: "COTU"; d: "TUC"; correct: "TUCTA"; cat: "UR"; diff: 3 }
        ListElement { q: "Watoto wa Tanzania wana haki ya elimu ya msingi bure kuanzia darasa?"; a: "La kwanza hadi la nne"; b: "La kwanza hadi la saba"; c: "La kwanza hadi la kumi"; d: "La tatu hadi la saba"; correct: "La kwanza hadi la saba"; cat: "UR"; diff: 2 }
        ListElement { q: "Tume ya Haki za Binadamu na Utawala Bora Tanzania inajulikana kwa kifupi gani?"; a: "TAKUKURU"; b: "CHRAGG"; c: "NEC"; d: "TFDA"; correct: "CHRAGG"; cat: "UR"; diff: 3 }
        ListElement { q: "Mfumo wa serikali ya Tanzania unaitwa?"; a: "Shirikisho (Federal)"; b: "Muungano (Union)"; c: "Kifalme (Monarchy)"; d: "Mkoa (Regional)"; correct: "Muungano (Union)"; cat: "UR"; diff: 2 }
        ListElement { q: "Katiba ya Zanzibar ni tofauti na Katiba ya Muungano — hii inamaanisha?"; a: "Zanzibar ni nchi huru"; b: "Zanzibar ina mambo yake ya ndani chini ya muungano"; c: "Tanzania ina katiba mbili zinazopingana"; d: "Zanzibar haihusiki na sheria za Tanzania Bara"; correct: "Zanzibar ina mambo yake ya ndani chini ya muungano"; cat: "UR"; diff: 3 }
        ListElement { q: "Ofisi ya Mkurugenzi wa Mashtaka (DPP) inafanya kazi gani?"; a: "Kulinda Rais"; b: "Kusimamia mahakama"; c: "Kuamua kufungua au kutofungua mashtaka ya jinai"; d: "Kukusanya kodi"; correct: "Kuamua kufungua au kutofungua mashtaka ya jinai"; cat: "UR"; diff: 3 }
        ListElement { q: "Sheria ya kupinga ubaguzi wa rangi Tanzania imewekwa katika?"; a: "Sheria ya Jinai"; b: "Katiba ya Tanzania Ibara ya 13"; c: "Sheria ya Polisi"; d: "Sheria ya Kazi"; correct: "Katiba ya Tanzania Ibara ya 13"; cat: "UR"; diff: 3 }
        ListElement { q: "Taasisi ya kutoa vibali vya biashara Tanzania inaitwa?"; a: "TRA"; b: "BRELA"; c: "BOT"; d: "SUMATRA"; correct: "BRELA"; cat: "UR"; diff: 2 }
        ListElement { q: "Mwaka gani Tanzania iliingia Umoja wa Afrika (AU)?"; a: "1963 (kama OAU)"; b: "2002 (kama AU)"; c: "1964"; d: "1975"; correct: "1963 (kama OAU)"; cat: "UR"; diff: 3 }
        ListElement { q: "Jukumu la Mkaguzi Mkuu wa Hesabu za Serikali (CAG) ni?"; a: "Kukusanya kodi"; b: "Kukagua matumizi ya fedha za umma"; c: "Kusimamia benki"; d: "Kulipa mishahara"; correct: "Kukagua matumizi ya fedha za umma"; cat: "UR"; diff: 2 }
        ListElement { q: "Sheria ya Mtoto Tanzania ilipitishwa mwaka gani?"; a: "1998"; b: "2005"; c: "2009"; d: "2012"; correct: "2009"; cat: "UR"; diff: 3 }
        ListElement { q: "Adhabu ya kukatazwa kisheria kwa watoto Tanzania ni?"; a: "Kupigwa viboko shuleni"; b: "Kufungwa gerezani"; c: "Adhabu zote za mwili"; d: "Kufanya kazi ya nguvu"; correct: "Adhabu zote za mwili"; cat: "UR"; diff: 3 }
        ListElement { q: "Kisheria Tanzania mtu ana haki ya kushikiliwa bila kushtakiwa kwa muda wa juu wa saa ngapi?"; a: "24"; b: "48"; c: "72"; d: "96"; correct: "48"; cat: "UR"; diff: 3 }
        ListElement { q: "Taasisi ya kusimamia ushindani wa biashara Tanzania inaitwa?"; a: "BRELA"; b: "FCC"; c: "TRA"; d: "BOT"; correct: "FCC"; cat: "UR"; diff: 3 }
        ListElement { q: "Nchi Tanzania ni mwanachama wa jumuiya gani za kikanda Afrika Mashariki?"; a: "EAC na SADC"; b: "ECOWAS na AU"; c: "COMESA pekee"; d: "EAC pekee"; correct: "EAC na SADC"; cat: "UR"; diff: 2 }
        ListElement { q: "Mtu anaweza kupoteza uraia wa Tanzania kwa njia gani?"; a: "Kukaa nje ya nchi muda mrefu"; b: "Kupata uraia wa nchi nyingine kwa hiari"; c: "Kutolipa kodi"; d: "Kutoshiriki uchaguzi"; correct: "Kupata uraia wa nchi nyingine kwa hiari"; cat: "UR"; diff: 3 }
        ListElement { q: "Wizara inayoshughulikia elimu ya juu Tanzania inaitwa?"; a: "Wizara ya Elimu"; b: "Wizara ya Sayansi na Teknolojia"; c: "Wizara ya Elimu, Sayansi na Teknolojia"; d: "NECTA"; correct: "Wizara ya Elimu, Sayansi na Teknolojia"; cat: "UR"; diff: 2 }
        ListElement { q: "Bodi ya Mikopo ya Wanafunzi wa Elimu ya Juu Tanzania inajulikana kwa kifupi gani?"; a: "HESLB"; b: "TCU"; c: "NECTA"; d: "VETA"; correct: "HESLB"; cat: "UR"; diff: 2 }
        ListElement { q: "Jukumu la Baraza la Taifa la Elimu ya Ufundi Tanzania (VETA) ni?"; a: "Kutoa mkopo"; b: "Kusimamia elimu ya ufundi stadi"; c: "Kukagua shule"; d: "Kutoa vyeti vya chuo kikuu"; correct: "Kusimamia elimu ya ufundi stadi"; cat: "UR"; diff: 2 }

        // ═══════════════════════════════════════════════════
        // MADA MPYA 3: MAZINGIRA & KILIMO (MK) — 60 maswali
        // ═══════════════════════════════════════════════════
        ListElement { q: "Msimu wa masika Tanzania Bara huanza lini kwa kawaida?"; a: "Januari - Februari"; b: "Machi - Mei"; c: "Juni - Agosti"; d: "Oktoba - Novemba"; correct: "Machi - Mei"; cat: "MK"; diff: 1 }
        ListElement { q: "Msimu wa vuli Tanzania huanza lini?"; a: "Machi - Mei"; b: "Juni - Agosti"; c: "Oktoba - Desemba"; d: "Januari - Machi"; correct: "Oktoba - Desemba"; cat: "MK"; diff: 2 }
        ListElement { q: "Ukame mrefu Tanzania mara nyingi unahusishwa na hali ya hewa inayoitwa?"; a: "La Niña"; b: "El Niño"; c: "Monsoon"; d: "Harmattan"; correct: "El Niño"; cat: "MK"; diff: 2 }
        ListElement { q: "Mmomonyoko wa udongo husababishwa hasa na?"; a: "Upepo tu"; b: "Mto tu"; c: "Mvua, upepo, na shughuli za binadamu"; d: "Jua kali"; correct: "Mvua, upepo, na shughuli za binadamu"; cat: "MK"; diff: 2 }
        ListElement { q: "Kilimo cha umwagiliaji kinamaanisha nini?"; a: "Kulima kwenye msitu"; b: "Kutumia mfumo wa maji ya bandia kumwagilia mashamba"; c: "Kulima wakati wa mvua tu"; d: "Kutumia mbolea ya asili"; correct: "Kutumia mfumo wa maji ya bandia kumwagilia mashamba"; cat: "MK"; diff: 1 }
        ListElement { q: "Gesi inayosababisha ongezeko la joto duniani (greenhouse gas) kuu ni?"; a: "Nitrogen"; b: "Oxygen"; c: "Carbon Dioxide (CO2)"; d: "Helium"; correct: "Carbon Dioxide (CO2)"; cat: "MK"; diff: 1 }
        ListElement { q: "Mkataba wa kimataifa wa kulinda mazingira uliopigiwa kura Paris unahusu nini?"; a: "Kulinda bahari"; b: "Kupunguza uzalishaji wa gesi chafu"; c: "Kupanda miti"; d: "Kulinda wanyama"; correct: "Kupunguza uzalishaji wa gesi chafu"; cat: "MK"; diff: 2 }
        ListElement { q: "Mbinu ya kilimo inayolinda udongo inayojumuisha kupanda miti kati ya mazao inaitwa?"; a: "Kilimo mseto (Agroforestry)"; b: "Kilimo cha matuta"; c: "Kilimo cha mikingamo"; d: "Kilimo cha mzunguko"; correct: "Kilimo mseto (Agroforestry)"; cat: "MK"; diff: 2 }
        ListElement { q: "Zao linalopandwa kurutubisha udongo kwa naitrojeni linaitwa?"; a: "Mazao ya nafaka"; b: "Mazao ya mikunde (legumes)"; c: "Mazao ya mizizi"; d: "Mazao ya matunda"; correct: "Mazao ya mikunde (legumes)"; cat: "MK"; diff: 2 }
        ListElement { q: "Mabadiliko ya tabianchi yanasababisha tatizo gani kubwa Tanzania?"; a: "Mafuriko na ukame zaidi"; b: "Baridi kali zaidi"; c: "Dhoruba za radi zaidi"; d: "Mvua nyingi zaidi tu"; correct: "Mafuriko na ukame zaidi"; cat: "MK"; diff: 1 }
        ListElement { q: "Mwelekeo wa barafu ya Kilimanjaro umekuwa ukipungua kwa sababu ya?"; a: "Upepo mkali"; b: "Ongezeko la joto duniani"; c: "Mvua nyingi"; d: "Volkano"; correct: "Ongezeko la joto duniani"; cat: "UT"; diff: 1 }
        ListElement { q: "Ufugaji wa nyuki unasaidia mazingira kwa njia gani?"; a: "Kupunguza wadudu"; b: "Uchavushaji wa maua na mazao"; c: "Kulinda maji"; d: "Kuongeza mvua"; correct: "Uchavushaji wa maua na mazao"; cat: "MK"; diff: 2 }
        ListElement { q: "Msitu wa Miombo unaofunika sehemu kubwa ya Tanzania ni muhimu kwa?"; a: "Kuzalisha dhahabu"; b: "Kuhifadhi maji, hewa na makazi ya wanyama"; c: "Kuzalisha nishati ya nyuklia"; d: "Kulima pamba"; correct: "Kuhifadhi maji, hewa na makazi ya wanyama"; cat: "MK"; diff: 2 }
        ListElement { q: "Mbolea ya asili inayotengenezwa kutoka kwa mabaki ya mimea na wanyama inaitwa?"; a: "Urea"; b: "Mboji (Compost)"; c: "DAP"; d: "CAN"; correct: "Mboji (Compost)"; cat: "MK"; diff: 1 }
        ListElement { q: "Kilimo cha mzunguko wa mazao (crop rotation) kinasaidia nini?"; a: "Kuongeza bei ya mazao"; b: "Kudumisha rutuba ya udongo na kupunguza wadudu"; c: "Kupunguza gharama za maji"; d: "Kuharakisha ukuaji wa mazao"; correct: "Kudumisha rutuba ya udongo na kupunguza wadudu"; cat: "MK"; diff: 2 }
        ListElement { q: "Nishati mbadala inayotumia nguvu za upepo inaitwa?"; a: "Solar energy"; b: "Wind energy (nishati ya upepo)"; c: "Hydropower"; d: "Geothermal"; correct: "Wind energy (nishati ya upepo)"; cat: "MK"; diff: 1 }
        ListElement { q: "Bwawa kubwa la umeme Tanzania linalotegemewa zaidi ni?"; a: "Bwawa la Nyumba ya Mungu"; b: "Bwawa la Mtera"; c: "Bwawa la Julius Nyerere (JNHPP)"; d: "Bwawa la Kidatu"; correct: "Bwawa la Julius Nyerere (JNHPP)"; cat: "MK"; diff: 2 }
        ListElement { q: "Sheria ya Misitu Tanzania inakataza nini hasa?"; a: "Kupanda miti"; b: "Ukataji wa miti holela bila ruhusa"; c: "Kilimo ndani ya msitu"; d: "Uwindaji wa wanyama"; correct: "Ukataji wa miti holela bila ruhusa"; cat: "MK"; diff: 2 }
        ListElement { q: "Mradi mkubwa wa umwagiliaji Tanzania katika Bonde la Kilimo la Kilombero unalima zao gani?"; a: "Mahindi"; b: "Mpunga (Mchele)"; c: "Pamba"; d: "Miwa"; correct: "Mpunga (Mchele)"; cat: "MK"; diff: 3 }
        ListElement { q: "Tatizo la 'soil salinization' (chumvi kwenye udongo) husababishwa hasa na?"; a: "Mvua nyingi"; b: "Umwagiliaji kupita kiasi bila mifereji mizuri"; c: "Baridi kali"; d: "Jua kali tu"; correct: "Umwagiliaji kupita kiasi bila mifereji mizuri"; cat: "MK"; diff: 3 }
        ListElement { q: "Programu ya REDD+ inayotekelezwa Tanzania inalenga nini?"; a: "Kupanda miti ya matunda"; b: "Kupunguza ukataji miti na utoaji wa hewa ukaa misituni"; c: "Kuongeza kilimo"; d: "Kuzuia mafuriko"; correct: "Kupunguza ukataji miti na utoaji wa hewa ukaa misituni"; cat: "MK"; diff: 3 }
        ListElement { q: "Mazao ya biashara yanayolindwa zaidi Tanzania kupitia bodi maalum ni?"; a: "Mahindi na mchele"; b: "Kahawa, chai, korosho, tumbaku, pamba"; c: "Ndizi na viazi"; d: "Nyanya na vitunguu"; correct: "Kahawa, chai, korosho, tumbaku, pamba"; cat: "MK"; diff: 2 }
        ListElement { q: "Teknolojia ya kilimo inayotumia data na kompyuta kuongoza uzalishaji inaitwa?"; a: "Kilimo mseto"; b: "Kilimo cha kisasa (Smart Agriculture)"; c: "Kilimo cha matuta"; d: "Kilimo cha kujikimu"; correct: "Kilimo cha kisasa (Smart Agriculture)"; cat: "MK"; diff: 3 }
        ListElement { q: "Mbegu bora (improved seeds) zinaongeza mavuno kwa wastani wa asilimia ngapi ikilinganishwa na mbegu za kawaida?"; a: "5-10%"; b: "10-20%"; c: "30-50%"; d: "80-100%"; correct: "30-50%"; cat: "MK"; diff: 3 }
        ListElement { q: "Mfumo wa kilimo unaolinda udongo dhidi ya mmomonyoko kwa kupanda mstari wa miti au nyasi pembeni mwa shamba unaitwa?"; a: "Contour farming"; b: "Strip cropping"; c: "Windbreak/Shelterbelt"; d: "Mulching"; correct: "Windbreak/Shelterbelt"; cat: "MK"; diff: 3 }
        ListElement { q: "Uvunaji wa maji ya mvua (rainwater harvesting) unasaidia nini hasa maeneo ya ukame?"; a: "Kuongeza mvua"; b: "Kuhifadhi maji kwa matumizi ya kilimo wakati wa ukame"; c: "Kupunguza joto"; d: "Kuondoa mafuriko"; correct: "Kuhifadhi maji kwa matumizi ya kilimo wakati wa ukame"; cat: "MK"; diff: 2 }
        ListElement { q: "Zao la miwa (sugarcane) Tanzania huzalishwa zaidi mkoa gani?"; a: "Morogoro"; b: "Kilosa na Morogoro (Kilombero Sugar)"; c: "Mwanza"; d: "Tanga"; correct: "Kilosa na Morogoro (Kilombero Sugar)"; cat: "MK"; diff: 2 }
        ListElement { q: "Hifadhi ya Biosphere ya Selous (Nyerere National Park) ni kubwa kiasi gani?"; a: "Kubwa kuliko nchi ya Switzerland"; b: "Ndogo kuliko Serengeti"; c: "Sawa na nchi ya Kenya"; d: "Kubwa kuliko nchi ya Germany"; correct: "Kubwa kuliko nchi ya Switzerland"; cat: "UT"; diff: 3 }
        ListElement { q: "Mbinu ya 'mulching' katika kilimo inamaanisha?"; a: "Kumwagilia kwa bomba"; b: "Kufunika udongo kwa nyasi au majani kukinga unyevunyevu"; c: "Kutumia mbolea ya kemikali"; d: "Kupanda mazao mseto"; correct: "Kufunika udongo kwa nyasi au majani kukinga unyevunyevu"; cat: "MK"; diff: 2 }
        ListElement { q: "Mbuguma (wetlands) zina umuhimu gani kwa mazingira?"; a: "Kutoa madini tu"; b: "Kuchuja maji, kuzuia mafuriko na makazi ya viumbe"; c: "Kupata nishati"; d: "Kulima mchele tu"; correct: "Kuchuja maji, kuzuia mafuriko na makazi ya viumbe"; cat: "MK"; diff: 2 }
        ListElement { q: "Tatizo la upotevu wa bioanuwai (biodiversity loss) Tanzania linahusiana hasa na?"; a: "Ukosefu wa maji"; b: "Ukataji miti na ujangili"; c: "Ukosefu wa mbolea"; d: "Ukame"; correct: "Ukataji miti na ujangili"; cat: "MK"; diff: 2 }
        ListElement { q: "Gazeti la kilimo linaloelimisha wakulima Tanzania linaloloitwa 'Mkulima Mbunifu' linatolewa na shirika gani?"; a: "FAO"; b: "Biovision Africa"; c: "Serikali ya Tanzania"; d: "TARI"; correct: "Biovision Africa"; cat: "MK"; diff: 3 }
        ListElement { q: "Zao la pareto (pyrethrum) linalotumiwa kutengeneza dawa za wadudu huzalishwa Tanzania hasa mkoa gani?"; a: "Arusha"; b: "Kilimanjaro"; c: "Mbeya na Iringa"; d: "Kagera"; correct: "Mbeya na Iringa"; cat: "MK"; diff: 3 }
        ListElement { q: "TARI ni taasisi inayofanya nini Tanzania?"; a: "Kusimamia maji"; b: "Utafiti wa kilimo"; c: "Usimamizi wa misitu"; d: "Uchimbaji wa madini"; correct: "Utafiti wa kilimo"; cat: "MK"; diff: 2 }
        ListElement { q: "Mbinu ya kilimo endelevu inayochanganya mifugo na mazao inaitwa?"; a: "Kilimo hai (Organic farming)"; b: "Kilimo jumuishi (Integrated farming)"; c: "Kilimo cha umwagiliaji"; d: "Monoculture"; correct: "Kilimo jumuishi (Integrated farming)"; cat: "MK"; diff: 2 }
        ListElement { q: "Tatizo gani linafanya uvuvi kupungua kwenye Ziwa Victoria?"; a: "Maji mengi sana"; b: "Uvuvi kupita kiasi na magugu ya maji (water hyacinth)"; c: "Baridi kali"; d: "Mawimbi makubwa"; correct: "Uvuvi kupita kiasi na magugu ya maji (water hyacinth)"; cat: "MK"; diff: 2 }
        ListElement { q: "Siku ya Mazingira Duniani huadhimishwa tarehe gani kila mwaka?"; a: "Aprili 22"; b: "Juni 5"; c: "Machi 22"; d: "Julai 11"; correct: "Juni 5"; cat: "MK"; diff: 2 }
        ListElement { q: "Siku ya Dunia ya Maji (World Water Day) huadhimishwa tarehe gani?"; a: "Machi 22"; b: "Juni 5"; c: "Aprili 22"; d: "Januari 15"; correct: "Machi 22"; cat: "MK"; diff: 2 }
        ListElement { q: "Nishati ya jua (solar energy) ina faida gani kuu Tanzania?"; a: "Ni nafuu kutengeneza"; b: "Haitoi gesi chafu na Tanzania ina jua nyingi"; c: "Inahitaji maji mengi"; d: "Inafanya kazi usiku tu"; correct: "Haitoi gesi chafu na Tanzania ina jua nyingi"; cat: "MK"; diff: 1 }
        ListElement { q: "Kutupa taka ovyo (littering) husababisha madhara gani kwa mazingira?"; a: "Kuongeza joto tu"; b: "Kuziba mifereji, kudhuru wanyama na kuchafua maji"; c: "Kupunguza mvua"; d: "Kuua miti"; correct: "Kuziba mifereji, kudhuru wanyama na kuchafua maji"; cat: "MK"; diff: 1 }
        ListElement { q: "Mfumo wa kilimo unaotumia maji kidogo sana (drip irrigation) unafaa hasa kwa?"; a: "Maeneo ya mvua nyingi"; b: "Maeneo ya ukame yenye maji machache"; c: "Kulima mpunga"; d: "Kilimo cha miti mikubwa"; correct: "Maeneo ya ukame yenye maji machache"; cat: "MK"; diff: 2 }
        ListElement { q: "Chanzo kikuu cha uchafuzi wa hewa mijini Tanzania ni?"; a: "Viwanda na magari"; b: "Kilimo"; c: "Uvuvi"; d: "Wanyama wa mfugo"; correct: "Viwanda na magari"; cat: "MK"; diff: 1 }
        ListElement { q: "Upandaji miti wa Serikali ya Tanzania (Greening Programme) unalenga kupanda miti mingapi ifikapo 2030?"; a: "Milioni 5"; b: "Bilioni 5"; c: "Milioni 500"; d: "Bilioni 1"; correct: "Bilioni 5"; cat: "MK"; diff: 3 }
        ListElement { q: "Kilimo hai (organic farming) kinatofautiana na kilimo cha kawaida kwa?"; a: "Hakitumii mbolea wala dawa za kemikali"; b: "Hulima usiku tu"; c: "Hutumia mbegu za kisasa pekee"; d: "Huhitaji ardhi kubwa"; correct: "Hakitumii mbolea wala dawa za kemikali"; cat: "MK"; diff: 2 }
        ListElement { q: "Tatizo la magugu baharini yanayoitwa 'water hyacinth' yanaathiri hasa?"; a: "Kilimo cha nchi kavu"; b: "Uvuvi na usafiri wa maji kwenye maziwa"; c: "Hali ya hewa"; d: "Uchimbaji madini"; correct: "Uvuvi na usafiri wa maji kwenye maziwa"; cat: "MK"; diff: 2 }
        ListElement { q: "Mto Pangani unatoka wapi?"; a: "Mlima Meru"; b: "Mlima Kilimanjaro na Meru"; c: "Ziwa Victoria"; d: "Bonde la Ngorongoro"; correct: "Mlima Kilimanjaro na Meru"; cat: "MK"; diff: 3 }
        ListElement { q: "Ardhi oevu (wetlands) inayopata hifadhi ya kimataifa (Ramsar) Tanzania ni?"; a: "Bonde la Kilombero"; b: "Mto Rufiji"; c: "Ziwa Natron"; d: "Msitu wa Jozani"; correct: "Bonde la Kilombero"; cat: "UT"; diff: 3 }
        ListElement { q: "Hewa ya oksijeni inayomfanya binadamu aishi nyingi zaidi inatoka wapi?"; a: "Bahari na msitu"; b: "Mchanga"; c: "Mawe ya volkano"; d: "Mvua"; correct: "Bahari na msitu"; cat: "MK"; diff: 1 }
        ListElement { q: "Nishati inayotokana na mkaa wa miti (biomass) ina tatizo gani Tanzania?"; a: "Ni ghali sana"; b: "Husababisha ukataji miti kupita kiasi"; c: "Haifanyi kazi vizuri"; d: "Haitumiki nyumbani"; correct: "Husababisha ukataji miti kupita kiasi"; cat: "MK"; diff: 2 }
        ListElement { q: "Aina ya udongo mwekundu unaofaa kwa kilimo cha chai na kahawa Tanzania unaitwa?"; a: "Udongo mfinyanzi (clay)"; b: "Udongo tifutifu (loam)"; c: "Udongo mwekundu wa miinuko (ferralsols)"; d: "Udongo wa mchanga (sandy)"; correct: "Udongo mwekundu wa miinuko (ferralsols)"; cat: "MK"; diff: 3 }
        ListElement { q: "Tahadhari ya awali (early warning system) kwa ukame Tanzania inashughulikiwa na?"; a: "TRA"; b: "Tanzania Meteorological Authority (TMA)"; c: "TANESCO"; d: "Wizara ya Maji"; correct: "Tanzania Meteorological Authority (TMA)"; cat: "MK"; diff: 2 }
        ListElement { q: "Maeneo ya hifadhi (conservation areas) ya Tanzania yanachukua asilimia ngapi ya ardhi yote?"; a: "Karibu 10%"; b: "Karibu 16%"; c: "Karibu 25%"; d: "Karibu 38%"; correct: "Karibu 38%"; cat: "UT"; diff: 3 }
        ListElement { q: "Utaratibu wa 'zero grazing' katika ufugaji wa ng'ombe unamaanisha?"; a: "Kutofuga ng'ombe"; b: "Kulisha ng'ombe zizizi badala ya kuwaacha wachunge"; c: "Kutumia dawa tu kulisha"; d: "Kufuga ng'ombe msituni"; correct: "Kulisha ng'ombe zizizi badala ya kuwaacha wachunge"; cat: "MK"; diff: 2 }
        ListElement { q: "Kisima cha maji kinachochimbwa kwa teknolojia ya kisasa bila kutumia nguvu za binadamu nyingi inaitwa?"; a: "Kisima cha bomba"; b: "Kisima cha mkono"; c: "Kisima cha hand pump"; d: "Borehole"; correct: "Borehole"; cat: "MK"; diff: 1 }
        ListElement { q: "Jangwa linaloenea karibu na Tanzania kaskazini-mashariki ni?"; a: "Sahara"; b: "Kalahari"; c: "Namib"; d: "Chalbi"; correct: "Chalbi"; cat: "MK"; diff: 3 }

        // ═══════════════════════════════════════════════════
        // MADA MPYA: MUZIKI WA TANZANIA (MUZ) — 40 maswali
        // ═══════════════════════════════════════════════════

        // BONGO FLAVA & WASANII WA KISASA
        ListElement { q: "Diamond Platnumz alizaliwa jina gani la kweli?"; a: "Nasibu Abdul Juma"; b: "Abdul Diamond Platnumz"; c: "Juma Diamond Naseeb"; d: "Naseeb Abdul Juma"; correct: "Nasebu Abdul Juma"; cat: "BUR"; diff: 2 }
        ListElement { q: "Msanii wa Bongo Flava anayejulikana kama 'Simba wa Bongo' ni?"; a: "Diamond Platnumz"; b: "Professor Jay"; c: "Mr. Blue"; d: "Juma Nature"; correct: "Mr. Blue"; cat: "BUR"; diff: 3 }
        ListElement { q: "Konde Gang ni lebo ya muziki inayomilikiwa na nani?"; a: "Diamond Platnumz"; b: "Harmonize"; c: "Rayvanny"; d: "Alikiba"; correct: "Harmonize"; cat: "BUR"; diff: 2 }
        ListElement { q: "Msanii wa kwanza wa Tanzania kupata platinum YouTube ni?"; a: "Rayvanny"; b: "Zuchu"; c: "Diamond Platnumz"; d: "Alikiba"; correct: "Diamond Platnumz"; cat: "BUR"; diff: 2 }
        ListElement { q: "Zuchu ni msanii anayeshirikiana na lebo gani?"; a: "Konde Gang"; b: "Kings Music"; c: "WCB Wasafi"; d: "Zoom Extra"; correct: "WCB Wasafi"; cat: "BUR"; diff: 1 }
        ListElement { q: "Msanii Marioo anajulikana zaidi kwa mtindo gani wa muziki?"; a: "Taarab"; b: "Bongo Flava/Afropop"; c: "Gospel"; d: "Dansi"; correct: "Bongo Flava/Afropop"; cat: "BUR"; diff: 2 }
        ListElement { q: "Jina la kweli la msanii Harmonize ni?"; a: "Rajab Abdul Kahali"; b: "Khadija Kopa"; c: "Juma Harmonize"; d: "Abdul Rajab"; correct: "Rajab Abdul Kahali"; cat: "BUR"; diff: 2 }
        ListElement { q: "Msanii wa kike aliyejulikana kama 'Queen of Bongo' ni?"; a: "Zuchu"; b: "Lady Jaydee"; c: "Nandy"; d: "Shilole"; correct: "Lady Jaydee"; cat: "BUR"; diff: 2 }
        ListElement { q: "Wimbo wa 'Sugua' uliofanya msanii gani mashuhuri zaidi?"; a: "Diamond Platnumz"; b: "Rayvanny"; c: "Zuchu"; d: "Harmonize"; correct: "Rayvanny"; cat: "BUR"; diff: 2 }
        ListElement { q: "Professor Jay anajulikana zaidi kwa aina gani ya muziki?"; a: "Taarab"; b: "Gospel"; c: "Bongo Flava/Hip hop"; d: "Dansi"; correct: "Bongo Flava/Hip hop"; cat: "BUR"; diff: 1 }

        // TAARAB & MUZIKI WA ASILI
        ListElement { q: "Taarab ina asili ya nchi gani kabla ya kufika Tanzania?"; a: "India na Arabia"; b: "Uingereza na Ufaransa"; c: "Afrika Kusini"; d: "Ethiopia"; correct: "India na Arabia"; cat: "BUR"; diff: 2 }
        ListElement { q: "Kina Bi Kidude alijulikana zaidi kwa muziki gani?"; a: "Bongo Flava"; b: "Taarab ya Kisanaa"; c: "Gospel"; d: "Dansi"; correct: "Taarab ya Kisanaa"; cat: "BUR"; diff: 2 }
        ListElement { q: "Kikundi cha Taarab kilichojulikana sana Zanzibar kinachocheza 'Taarab ya Kidart' kinaitwa?"; a: "TOT"; b: "Culture Musical Club"; c: "Egyptian Musical Club"; d: "Muungano Cultural Troupe"; correct: "Culture Musical Club"; cat: "BUR"; diff: 3 }
        ListElement { q: "Ala ya muziki inayotumika zaidi katika Taarab ni?"; a: "Gitaa"; b: "Kinanda (Keyboard/Accordion)"; c: "Ngoma"; d: "Filimbi"; correct: "Kinanda (Keyboard/Accordion)"; cat: "BUR"; diff: 2 }
        ListElement { q: "Nyimbo za Taarab mara nyingi zinaandikwa kwa lugha gani?"; a: "Kiingereza"; b: "Kiarabu na Kiswahili"; c: "Kifaransa"; d: "Kihindi"; correct: "Kiarabu na Kiswahili"; cat: "BUR"; diff: 1 }
        ListElement { q: "Hukwe Zawose alijulikana duniani kwa kucheza ala gani ya asili?"; a: "Zeze na Ilimba"; b: "Ngoma ya Bongo"; c: "Kinanda"; d: "Gitaa la umeme"; correct: "Zeze na Ilimba"; cat: "BUR"; diff: 2 }
        ListElement { q: "Muziki wa 'Chakacha' ni ngoma ya asili ya watu wa?"; a: "Wachagga"; b: "Wamasai"; c: "Waswahili wa pwani"; d: "Wasukuma"; correct: "Waswahili wa pwani"; cat: "BUR"; diff: 2 }
        ListElement { q: "Aina ya muziki wa dansi uliokuwa maarufu miaka ya 1960-80 Tanzania unaitwa?"; a: "Bongo Flava"; b: "Muziki wa Dansi (Tanzania Jazz)"; c: "Gospel"; d: "Hip hop"; correct: "Muziki wa Dansi (Tanzania Jazz)"; cat: "BUR"; diff: 2 }
        ListElement { q: "Kikundi cha muziki wa dansi kilichokuwa mashuhuri sana Tanzania miaka ya 70-80 ni?"; a: "WCB Wasafi"; b: "OTTU Jazz Band"; c: "Diamond Orchestra"; d: "Kings Music"; correct: "OTTU Jazz Band"; cat: "BUR"; diff: 3 }
        ListElement { q: "Remmy Ongala (Omari Ramadhan) alijulikana kimataifa kwa aina gani ya muziki?"; a: "Taarab"; b: "Soukous/Dansi ya Tanzania"; c: "Gospel"; d: "Bongo Flava"; correct: "Soukous/Dansi ya Tanzania"; cat: "BUR"; diff: 3 }

        // GOSPEL & INJILI
        ListElement { q: "Msanii wa kwanza wa Tanzania kushinda tuzo ya Kili Music Awards ni?"; a: "Diamond Platnumz"; b: "Rose Muhando"; c: "Professor Jay"; d: "Ali Kiba"; correct: "Diamond Platnumz"; cat: "BUR"; diff: 3 }
        ListElement { q: "Msanii maarufu wa muziki wa gospel Tanzania anayejulikana kama 'Mama Gospel' ni?"; a: "Rose Muhando"; b: "Zuchu"; c: "Nandy"; d: "Lady Jaydee"; correct: "Rose Muhando"; cat: "BUR"; diff: 1 }
        ListElement { q: "Msanii wa gospel Bahati Bukuku anajulikana zaidi kwa wimbo gani?"; a: "Mungu Baba"; b: "Yesu ni Bwana"; c: "Nikiwa Mbali"; d: "Sitolia"; correct: "Nikiwa Mbali"; cat: "BUR"; diff: 2 }
        ListElement { q: "Kikundi cha gospel kilichojulikana sana Tanzania miaka ya 2000 ni?"; a: "Sauti Sol"; b: "Muungano National Choir"; c: "WCB Wasafi"; d: "Kings Music"; correct: "Muungano National Choir"; cat: "BUR"; diff: 2 }
        ListElement { q: "Msanii wa gospel Judith Babirye anatoka nchi gani lakini maarufu Tanzania?"; a: "Kenya"; b: "Uganda"; c: "Rwanda"; d: "Burundi"; correct: "Uganda"; cat: "BUR"; diff: 2 }

        // HISTORIA YA MUZIKI WA TZ
        ListElement { q: "Kikundi cha kwanza cha muziki wa kisasa kuanzishwa Tanzania kilichoitwa 'Dar es Salaam Jazz Band' kilianzishwa lini?"; a: "Miaka ya 1940"; b: "Miaka ya 1960"; c: "Miaka ya 1980"; d: "Miaka ya 2000"; correct: "Miaka ya 1940"; cat: "BUR"; diff: 3 }
        ListElement { q: "TOT (Tanzania One Theatre) ilijulikana zaidi kwa aina gani ya sanaa?"; a: "Muziki wa dansi na maigizo"; b: "Bongo Flava"; c: "Taarab tu"; d: "Hip hop"; correct: "Muziki wa dansi na maigizo"; cat: "BUR"; diff: 2 }
        ListElement { q: "Msanii Mbaraka Mwinshehe alijulikana kwa aina gani ya muziki?"; a: "Taarab"; b: "Chakacha na Dansi"; c: "Gospel"; d: "Hip hop"; correct: "Chakacha na Dansi"; cat: "BUR"; diff: 3 }
        ListElement { q: "Tamasha kubwa la muziki Tanzania linalofanyika Dar es Salaam linaitwa?"; a: "Sauti za Busara"; b: "Fiesta"; c: "Karibu New Music Tanzania"; d: "Wasafi Festival"; correct: "Wasafi Festival"; cat: "BUR"; diff: 2 }
        ListElement { q: "Tamasha la 'Sauti za Busara' linafanyika kila mwaka wapi?"; a: "Dar es Salaam"; b: "Arusha"; c: "Zanzibar"; d: "Mwanza"; correct: "Zanzibar"; cat: "BUR"; diff: 2 }

        // WASANII WENGINE MAARUFU
        ListElement { q: "Msanii Alikiba anajulikana zaidi kwa aina gani ya muziki?"; a: "Gospel"; b: "Taarab"; c: "Bongo Flava/R&B"; d: "Dansi"; correct: "Bongo Flava/R&B"; cat: "BUR"; diff: 1 }
        ListElement { q: "Jina la kweli la msanii Nandy ni?"; a: "Faustina Charles"; b: "Nandi Charles"; c: "Faustina Minzi"; d: "Nancy Charles"; correct: "Faustina Charles"; cat: "BUR"; diff: 2 }
        ListElement { q: "Msanii Dully Sykes anajulikana kwa jina gani lingine?"; a: "King of Bongo"; b: "The Gentleman"; c: "Simba"; d: "Mfalme wa Dansi"; correct: "The Gentleman"; cat: "BUR"; diff: 2 }
        ListElement { q: "Msanii Mrisho Mpoto anajulikana kwa aina gani ya muziki?"; a: "Gospel"; b: "Taarab"; c: "Bongo Flava/Hip hop"; d: "Dansi"; correct: "Bongo Flava/Hip hop"; cat: "BUR"; diff: 2 }
        ListElement { q: "Kikundi cha muziki kilichojumuisha wasanii Juma Nature na Afande Sele kilikuwa?"; a: "P-Square TZ"; b: "X Plastaz"; c: "TMK"; d: "East African Bashment Crew"; correct: "X Plastaz"; cat: "BUR"; diff: 3 }
        ListElement { q: "Msanii Shilole anajulikana zaidi kwa?"; a: "Muziki wa taarab na nyimbo za mapenzi"; b: "Gospel"; c: "Dansi ya zamani"; d: "Hip hop"; correct: "Muziki wa taarab na nyimbo za mapenzi"; cat: "BUR"; diff: 2 }
        ListElement { q: "Wasanii wa Tanzania walioshinda tuzo ya AFRIMA (All Africa Music Awards) ni wengi — tuzo hizi hufanyika nchi gani?"; a: "Tanzania"; b: "Nigeria"; c: "Afrika Kusini"; d: "Kenya"; correct: "Nigeria"; cat: "BUR"; diff: 3 }
        ListElement { q: "Msanii wa kike anayejulikana kwa jina 'Lulu' katika muziki ni nani?"; a: "Zuchu"; b: "Nandy"; c: "Elizabeth Michael"; d: "Shilole"; correct: "Elizabeth Michael"; cat: "BUR"; diff: 2 }
        ListElement { q: "Ala ya 'Tinde' inayopigwa kwa mikono ni ala ya asili ya kabila gani Tanzania?"; a: "Wachagga"; b: "Wagogo"; c: "Wamasai"; d: "Wasukuma"; correct: "Wagogo"; cat: "BUR"; diff: 3 }
        ListElement { q: "Msanii Ommy Dimpoz anajulikana kwa ushirikiano wake maarufu na msanii gani wa kimataifa?"; a: "Davido"; b: "Wizkid"; c: "P-Square"; d: "Don Jazzy"; correct: "P-Square"; cat: "BUR"; diff: 3 }
        ListElement { q: "Neno 'Bongo Flava' linamaanisha nini hasa?"; a: "Muziki wa Tanzania wenye ladha ya hapa"; b: "Muziki wa dansi tu"; c: "Muziki wa gospel"; d: "Muziki wa watoto"; correct: "Muziki wa Tanzania wenye ladha ya hapa"; cat: "BUR"; diff: 1 }

        // ═══════════════════════════════════════════════════
        // BUR — MAIGIZO, VICHEKESHO, FILAMU MPYA (+30)
        // ═══════════════════════════════════════════════════

        // VICHEKESHO
        ListElement { q: "Jukwaa la vichekesho la 'Cheka Tu' linafanyika jijini gani Tanzania?"; a: "Arusha"; b: "Mwanza"; c: "Dar es Salaam"; d: "Dodoma"; correct: "Dar es Salaam"; cat: "BUR"; diff: 1 }
        ListElement { q: "Mchekeshaji Ebitoke anajulikana kwa nini hasa?"; a: "Kuimba vichekesho"; b: "Kuigiza wahusika wa kisiasa na kuchanganya lugha"; c: "Kucheza ngoma"; d: "Kuandika vitabu"; correct: "Kuigiza wahusika wa kisiasa na kuchanganya lugha"; cat: "BUR"; diff: 2 }
        ListElement { q: "Kikundi cha 'Vituko Show' kilifanya vichekesho vyake kupitia njia gani kuu?"; a: "Runinga ya ITV"; b: "YouTube na Runinga"; c: "Redio tu"; d: "Maonyesho ya uwanja tu"; correct: "YouTube na Runinga"; cat: "BUR"; diff: 2 }
        ListElement { q: "Mchekeshaji Bwakila anajulikana zaidi kwa?"; a: "Mchezo wa kuigiza kwenye runinga"; b: "Vichekesho vya stand-up na kuigiza sauti"; c: "Kuandika filamu"; d: "Kuimba nyimbo za vichekesho"; correct: "Vichekesho vya stand-up na kuigiza sauti"; cat: "BUR"; diff: 2 }
        ListElement { q: "Mchekeshaji Mwijaku anajulikana kwa jukwaa gani la vichekesho?"; a: "Cheka Tu"; b: "Laugh Industry"; c: "Comedy Festival TZ"; d: "Stand Up Dar"; correct: "Laugh Industry"; cat: "BUR"; diff: 3 }
        ListElement { q: "Kundi la vichekesho 'Ze Komedi' lilianzishwa na nani?"; a: "Mpoki"; b: "Joti na washirika"; c: "Ebitoke"; d: "Kitale"; correct: "Joti na washirika"; cat: "BUR"; diff: 3 }
        ListElement { q: "Mtangazaji na mchekeshaji wa runinga anayejulikana kwa 'Ngosha' ni maarufu kupitia runinga gani?"; a: "ITV"; b: "TBC 1"; c: "Clouds TV"; d: "Star TV"; correct: "Clouds TV"; cat: "BUR"; diff: 2 }
        ListElement { q: "Tamasha la vichekesho la 'Comedy Knights' Tanzania lilifanyika mara ngapi kwa mwaka kawaida?"; a: "Kila wiki"; b: "Kila mwezi"; c: "Mara mbili kwa mwaka"; d: "Kila siku"; correct: "Kila mwezi"; cat: "BUR"; diff: 3 }
        ListElement { q: "Mchekeshaji anayejulikana kama 'MC' wa harusi wengi Tanzania na vichekesho vya Clouds TV ni?"; a: "Bwakila"; b: "Coy Mzero"; c: "Mpoki"; d: "Mwijaku"; correct: "Coy Mzero"; cat: "BUR"; diff: 2 }
        ListElement { q: "Nani kati ya hawa ni mchekeshaji wa Tanzania anayejulikana kwa sauti ya pua na vichekesho vya kijamii?"; a: "Joti"; b: "Kitale"; c: "Mpoki"; d: "Ebitoke"; correct: "Mpoki"; cat: "BUR"; diff: 2 }

        // MAIGIZO YA RUNINGA
        ListElement { q: "Msururu maarufu wa maigizo ya Tanzania ulioonyeshwa ITV ulihusu familia inaitwa?"; a: "Familia"; b: "Tazama Jirani"; c: "Bongo"; d: "Mtaa Wangu"; correct: "Familia"; cat: "BUR"; diff: 2 }
        ListElement { q: "Mwigizaji Wema Sepetu anajulikana zaidi kwa?"; a: "Muziki wa gospel"; b: "Maigizo ya filamu na runinga za Tanzania"; c: "Vichekesho vya stand-up"; d: "Uandishi wa vitabu"; correct: "Maigizo ya filamu na runinga za Tanzania"; cat: "BUR"; diff: 1 }
        ListElement { q: "Mwigizaji Jacqueline Wolper anajulikana zaidi kwa?"; a: "Nyimbo za taarab"; b: "Maigizo ya filamu za Tanzania"; c: "Vichekesho"; d: "Uandishi wa habari"; correct: "Maigizo ya filamu za Tanzania"; cat: "BUR"; diff: 2 }
        ListElement { q: "Mwigizaji maarufu wa Tanzania Steven Kanumba alifariki mwaka gani?"; a: "2010"; b: "2012"; c: "2014"; d: "2015"; correct: "2012"; cat: "BUR"; diff: 2 }
        ListElement { q: "Tamasha la Filamu la Kimataifa la Zanzibar (ZIFF) hufanyika wapi?"; a: "Dar es Salaam"; b: "Arusha"; c: "Zanzibar"; d: "Mwanza"; correct: "Zanzibar"; cat: "BUR"; diff: 2 }
        ListElement { q: "Mwigizaji Irene Uwoya anajulikana zaidi kwa?"; a: "Nyimbo za Bongo Flava"; b: "Maigizo ya filamu na runinga"; c: "Vichekesho"; d: "Uandishi wa magazeti"; correct: "Maigizo ya filamu na runinga"; cat: "BUR"; diff: 1 }
        ListElement { q: "Kikundi cha 'Kaole Sanaa Group' kilijulikana kwa aina gani ya sanaa?"; a: "Muziki wa dansi"; b: "Maigizo ya runinga na ukumbi"; c: "Vichekesho tu"; d: "Ngoma za asili"; correct: "Maigizo ya runinga na ukumbi"; cat: "BUR"; diff: 2 }
        ListElement { q: "Runinga ya kwanza ya kibinafsi Tanzania iliyoanza kutangaza ni?"; a: "ITV"; b: "Clouds TV"; c: "Star TV"; d: "Channel Ten"; correct: "ITV"; cat: "BUR"; diff: 2 }
        ListElement { q: "Msururu wa maigizo ya Tanzania 'Ndoto za Elisha' ulihusu nini?"; a: "Maisha ya biashara"; b: "Mapenzi na ndoto za kijana maskini"; c: "Vita vya kikabila"; d: "Maisha ya polisi"; correct: "Mapenzi na ndoto za kijana maskini"; cat: "BUR"; diff: 2 }
        ListElement { q: "Mwigizaji wa Tanzania aliyepata umaarufu wa kimataifa kupitia filamu za Nigeria (Nollywood) ni?"; a: "Wema Sepetu"; b: "Elizabeth Michael Lulu"; c: "Jacqueline Wolper"; d: "Irene Uwoya"; correct: "Irene Uwoya"; cat: "BUR"; diff: 2 }

        // FILAMU ZA TANZANIA
        ListElement { q: "Tasnia ya filamu ya Tanzania inajulikana kwa jina gani maarufu?"; a: "Tanzwood"; b: "Bongwood"; c: "Swahiliwood"; d: "Dawood"; correct: "Swahiliwood"; cat: "BUR"; diff: 2 }
        ListElement { q: "Filamu ya Tanzania 'Siri ya Mtungi' ilihusu nini hasa?"; a: "Vita vya Kagera"; b: "Uchawi na mila za Tanzania"; c: "Mapenzi ya vijana"; d: "Biashara ya dawa za kulevya"; correct: "Uchawi na mila za Tanzania"; cat: "BUR"; diff: 2 }
        ListElement { q: "Tuzo ya AMVCA inayoshughulika na filamu na maigizo hufanyika nchi gani?"; a: "Ghana"; b: "Afrika Kusini"; c: "Nigeria"; d: "Kenya"; correct: "Nigeria"; cat: "BUR"; diff: 2 }
        ListElement { q: "Nollywood ni jina linalotumiwa kwa tasnia ya filamu ya nchi gani?"; a: "Ghana"; b: "Kenya"; c: "Nigeria"; d: "Afrika Kusini"; correct: "Nigeria"; cat: "BUR"; diff: 1 }
        ListElement { q: "Filamu ya Tanzania 'Dar ni Njema' ilihusu nini?"; a: "Safari za utalii"; b: "Maisha ya vijana wa Dar es Salaam na changamoto zao"; c: "Historia ya Tanzania"; d: "Vita dhidi ya ujangili"; correct: "Maisha ya vijana wa Dar es Salaam na changamoto zao"; cat: "BUR"; diff: 2 }
        ListElement { q: "Mkurugenzi maarufu wa filamu za Tanzania anayejulikana kwa filamu za mapenzi na vitendo ni?"; a: "Steven Kanumba"; b: "Francis Njau (Bob Njau)"; c: "John Mwangi"; d: "Ali Hassan"; correct: "Francis Njau (Bob Njau)"; cat: "BUR"; diff: 3 }
        ListElement { q: "Filamu za Tanzania mara nyingi zinaimbwa au zinaandikwa kwa lugha gani?"; a: "Kiingereza tu"; b: "Kiswahili hasa"; c: "Kiarabu"; d: "Kihindi"; correct: "Kiswahili hasa"; cat: "BUR"; diff: 1 }
        ListElement { q: "Mwigizaji wa Tanzania aliyecheza kwenye filamu ya kimataifa 'Vuta N'kuvute' alikuwa?"; a: "Wema Sepetu"; b: "Vanessa Myamba"; c: "Irene Uwoya"; d: "Jacqueline Wolper"; correct: "Vanessa Myamba"; cat: "BUR"; diff: 3 }
        ListElement { q: "Tamasha la filamu la ZIFF lilianzishwa mwaka gani?"; a: "1990"; b: "1998"; c: "2005"; d: "2010"; correct: "1998"; cat: "BUR"; diff: 3 }
        ListElement { q: "Filamu ya Tanzania inayohusu vita vya uhuru na mkoloni inayojulikana ni?"; a: "Siri ya Mtungi"; b: "Vuta N'kuvute"; c: "Dar ni Njema"; d: "Bongo"; correct: "Vuta N'kuvute"; cat: "BUR"; diff: 2 }
        ListElement { q: "Kitendawili: Ninaingia kila chumba bila kugonga hodi, lakini huwezi kuniona. Mimi ni nani?"; a: "Mwizi"; b: "Nuru"; c: "Baridi"; d: "Pumzi"; correct: "Nuru"; cat: "V"; diff: 2 }
        ListElement { q: "Kitendawili: Sehemu yangu ya chini iko juu na sehemu yangu ya juu iko chini. Mimi ni nani?"; a: "Mlima"; b: "Mti uliogeuziwa"; c: "Mguu"; d: "Nywele"; correct: "Mguu"; cat: "V"; diff: 3 }
        ListElement { q: "Ziwa Chala linalopatikana mpakani wa Tanzania na Kenya linajulikana kwa nini katika utalii?"; a: "Samaki wakubwa"; b: "Ziwa la volkano (crater lake) lenye maji ya buluu"; c: "Ndege adimu"; d: "Maporomoko ya maji"; correct: "Ziwa la volkano (crater lake) lenye maji ya buluu"; cat: "UT"; diff: 3 }
        ListElement { q: "Hifadhi ya wanyama ya Loliondo ipo karibu na hifadhi gani kubwa?"; a: "Ruaha"; b: "Serengeti"; c: "Mikumi"; d: "Nyerere"; correct: "Serengeti"; cat: "UT"; diff: 3 }
        ListElement { q: "Kama mfululizo ni 2, 6, 18, 54, nambari inayofuata ni?"; a: "108"; b: "144"; c: "162"; d: "180"; correct: "162"; cat: "LG"; diff: 2 }

        // --- MANTIKI ZAIDI (+21) ---
        ListElement { q: "Kama A ni ndugu wa B, na C ni mtoto wa B, A ni nini kwa C?"; a: "Baba/Mama"; b: "Shangazi/Mjomba"; c: "Babu/Bibi"; d: "Binamu"; correct: "Shangazi/Mjomba"; cat: "LG"; diff: 2 }
        ListElement { q: "Nambari ngapi zisizogawanyika kati ya 1 na 10?"; a: "3"; b: "4"; c: "5"; d: "6"; correct: "4"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama chupa na kikombe vina thamani ya 110, na chupa peke yake ni 100 zaidi ya kikombe, kikombe ni bei gani?"; a: "5"; b: "10"; c: "50"; d: "100"; correct: "5"; cat: "LG"; diff: 3 }
        ListElement { q: "Mfululizo: 1, 3, 7, 13, 21, ... nambari inayofuata ni?"; a: "29"; b: "31"; c: "33"; d: "35"; correct: "31"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama watu 100 wana umri wa wastani wa miaka 30, na mtu 1 aongezeke mwenye umri wa miaka 130, wastani mpya ni?"; a: "30"; b: "31"; c: "32"; d: "35"; correct: "31"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama saa inabonyeza mara 2 saa mbili, na mara 3 saa tatu, itabonyeza mara ngapi saa kumi na mbili?"; a: "12"; b: "11"; c: "10"; d: "78"; correct: "78"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama PAKA : MEOW, basi MBWA : ?"; a: "BASS"; b: "BARK"; c: "MOO"; d: "ROAR"; correct: "BARK"; cat: "LG"; diff: 1 }
        ListElement { q: "Mtu ana ndugu 3 wa kike na kaka 2. Dada yake ana ndugu wa kike wangapi?"; a: "2"; b: "3"; c: "4"; d: "5"; correct: "3"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama unaandika hesabu 1 hadi 100, tarakimu '9' itatokea mara ngapi?"; a: "10"; b: "19"; c: "20"; d: "21"; correct: "20"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama ndege anaweza kuruka km 10 kwa saa, atafika umbali gani kwa dakika 90?"; a: "9 km"; b: "12 km"; c: "15 km"; d: "18 km"; correct: "15 km"; cat: "LG"; diff: 2 }
        ListElement { q: "Mfululizo wa nambari: 2, 5, 10, 17, 26, 37, ... inayofuata ni?"; a: "48"; b: "49"; c: "50"; d: "51"; correct: "50"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama ukitenganisha neno BANANA kwa herufi tofauti, una herufi ngapi tofauti?"; a: "2"; b: "3"; c: "4"; d: "5"; correct: "3"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama bei ya bidhaa ipandapo kwa 10% kisha 10% tena, jumla imepanda kwa asilimia ngapi?"; a: "20%"; b: "21%"; c: "22%"; d: "25%"; correct: "21%"; cat: "LG"; diff: 3 }
        ListElement { q: "Masharti: Wote wanaoimba wanapenda muziki. Juma anapenda muziki. Je Juma anaimba?"; a: "Ndiyo"; b: "Hapana"; c: "Haiwezekani kujua"; d: "Labda"; correct: "Haiwezekani kujua"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama mraba mmoja una mstari wa 4 cm, miraba 4 inaunganishwa — mzingo wote ni cm ngapi?"; a: "32"; b: "40"; c: "48"; d: "64"; correct: "40"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama MWALIMU ana WANAFUNZI 30 na aliwagawanya nusu kwa nusu, kila kundi lina wangapi?"; a: "10"; b: "12"; c: "15"; d: "20"; correct: "15"; cat: "LG"; diff: 1 }
        ListElement { q: "Mfululizo: O, T, T, F, F, S, S, E, ... herufi inayofuata ni?"; a: "N"; b: "T"; c: "E"; d: "N"; correct: "N"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama 1 = 3, 2 = 3, 3 = 5, 4 = 4, 5 = 4, basi 6 = ?"; a: "3"; b: "4"; c: "5"; d: "6"; correct: "3"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama kanzu ina mikono 2, suruali ina miguu 2, soksi 2 na viatu 2, vitu ngapi jumla?"; a: "6"; b: "7"; c: "8"; d: "10"; correct: "8"; cat: "LG"; diff: 1 }
        ListElement { q: "Meza ina miguu 4. Kiti kina miguu 4. Chumba kina meza 1 na viti 6. Miguu yote ni mingapi?"; a: "28"; b: "32"; c: "36"; d: "40"; correct: "32"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama unachomeka 3 vipande vya mkaa pamoja, hutapata vipande 4 ukivunja. Kwa nini? Kwa sababu?"; a: "Unafanya 4"; b: "Unafanya 6"; c: "Swali ni udanganyifu — unavunja 3 kupata 6"; d: "Haiwezekani"; correct: "Swali ni udanganyifu — unavunja 3 kupata 6"; cat: "LG"; diff: 3 }


        ListElement { q: "Hifadhi ya Taifa ya Tarangire inajulikana zaidi kwa wanyama gani?"; a: "Sokwe"; b: "Tembo na Miti ya Baobab"; c: "Nyangumi"; d: "Flamingo"; correct: "Tembo na Miti ya Baobab"; cat: "UT"; diff: 1 }
        ListElement { q: "Ziwa Manyara linajulikana kwa nini katika utalii?"; a: "Simba wanaopanda miti"; b: "Sokwe wengi"; c: "Nyumbu wengi"; d: "Ndege wa bahari"; correct: "Simba wanaopanda miti"; cat: "UT"; diff: 2 }
        ListElement { q: "Hifadhi ya Taifa ya Kilimanjaro ilianzishwa mwaka gani?"; a: "1968"; b: "1973"; c: "1977"; d: "1985"; correct: "1973"; cat: "UT"; diff: 3 }
        ListElement { q: "Njia maarufu zaidi ya kupanda Mlima Kilimanjaro inaitwa?"; a: "Machame Route"; b: "Marangu Route"; c: "Lemosho Route"; d: "Rongai Route"; correct: "Marangu Route"; cat: "UT"; diff: 2 }
        ListElement { q: "Njia ya Kilimanjaro inayoitwa 'Whisky Route' ni ipi?"; a: "Marangu"; b: "Rongai"; c: "Machame"; d: "Umbwe"; correct: "Machame"; cat: "UT"; diff: 3 }
        ListElement { q: "Kilele cha juu zaidi cha Mlima Kilimanjaro kinaitwa?"; a: "Mawenzi"; b: "Shira"; c: "Uhuru Peak"; d: "Kibo"; correct: "Uhuru Peak"; cat: "UT"; diff: 1 }
        ListElement { q: "Mlima Kilimanjaro una vilele vikuu vingapi?"; a: "2"; b: "3"; c: "4"; d: "5"; correct: "3"; cat: "UT"; diff: 2 }
        ListElement { q: "Stone Town ya Zanzibar imeorodheshwa na UNESCO kama?"; a: "Hifadhi ya Taifa"; b: "Urithi wa Dunia (World Heritage Site)"; c: "Bustani ya Kimataifa"; d: "Mji wa Biashara"; correct: "Urithi wa Dunia (World Heritage Site)"; cat: "UT"; diff: 2 }
        ListElement { q: "Zanzibar inajulikana kwa jina lingine gani la utalii?"; a: "Kisiwa cha Amani"; b: "Kisiwa cha Viungo (Spice Island)"; c: "Kisiwa cha Dhahabu"; d: "Kisiwa cha Rangi"; correct: "Kisiwa cha Viungo (Spice Island)"; cat: "UT"; diff: 1 }
        ListElement { q: "Pwani maarufu ya utalii kaskazini mwa Zanzibar inaitwa?"; a: "Nungwi Beach"; b: "Bongoyo Beach"; c: "Kunduchi Beach"; d: "Msasani Beach"; correct: "Nungwi Beach"; cat: "UT"; diff: 2 }
        ListElement { q: "Hifadhi ya Taifa ya Nyerere (Selous) ni hifadhi ya aina gani ya kipekee?"; a: "Hifadhi ya bahari"; b: "Hifadhi kubwa zaidi ya wanyama Afrika"; c: "Hifadhi ya msitu tu"; d: "Hifadhi ya ndege"; correct: "Hifadhi kubwa zaidi ya wanyama Afrika"; cat: "UT"; diff: 2 }
        ListElement { q: "Bonde la Ngorongoro linajulikana kwa jina gani la kisayansi?"; a: "Caldera kubwa zaidi duniani iliyobaki"; b: "Volkano hai"; c: "Bonde la Ufa"; d: "Ziwa kame"; correct: "Caldera kubwa zaidi duniani iliyobaki"; cat: "UT"; diff: 3 }
        ListElement { q: "Mlima mrefu wa pili Afrika (Mount Kenya) uko karibu na Mlima Kilimanjaro — Kilimanjaro kiko nchi gani hasa?"; a: "Kenya"; b: "Tanzania"; c: "Uganda"; d: "Mpakani wa Tanzania na Kenya"; correct: "Tanzania"; cat: "UT"; diff: 2 }
        ListElement { q: "Wanyama wanaojulikana kama 'Big Five' Tanzania ni?"; a: "Simba, Tembo, Nyati, Kifaru, Chui"; b: "Simba, Tembo, Nyumbu, Pundamilia, Twiga"; c: "Simba, Kiboko, Swala, Nyati, Tembo"; d: "Simba, Chui, Duma, Fisi, Mbwa mwitu"; correct: "Simba, Tembo, Nyati, Kifaru, Chui"; cat: "UT"; diff: 1 }
        ListElement { q: "Hifadhi ya Taifa ya Arusha ina upekee gani?"; a: "Ina flamingo wengi"; b: "Ipo karibu na jiji la Arusha na ina Mlima Meru"; c: "Ina sokwe wengi"; d: "Ina tembo weupe"; correct: "Ipo karibu na jiji la Arusha na ina Mlima Meru"; cat: "UT"; diff: 2 }
        ListElement { q: "Mlima Meru uko mkoa gani Tanzania?"; a: "Kilimanjaro"; b: "Manyara"; c: "Arusha"; d: "Tanga"; correct: "Arusha"; cat: "UT"; diff: 2 }
        ListElement { q: "Ziwa la chumvi linaloitwa 'Ziwa la Flamingo' Tanzania ni?"; a: "Ziwa Manyara"; b: "Ziwa Natron"; c: "Ziwa Eyasi"; d: "Ziwa Rukwa"; correct: "Ziwa Natron"; cat: "UT"; diff: 2 }
        ListElement { q: "Flamingo wekundu wanaozaliana Tanzania wanapatikana zaidi wapi?"; a: "Ziwa Victoria"; b: "Ziwa Manyara"; c: "Ziwa Natron"; d: "Ziwa Tanganyika"; correct: "Ziwa Natron"; cat: "UT"; diff: 2 }
        ListElement { q: "Circuit ya utalii inayojumuisha Serengeti, Ngorongoro, Tarangire na Manyara inaitwa?"; a: "Southern Circuit"; b: "Northern Circuit"; c: "Western Circuit"; d: "Coastal Circuit"; correct: "Northern Circuit"; cat: "UT"; diff: 2 }
        ListElement { q: "Circuit ya utalii inayojumuisha Ruaha, Selous na Mikumi inaitwa?"; a: "Northern Circuit"; b: "Western Circuit"; c: "Southern Circuit"; d: "Eastern Circuit"; correct: "Southern Circuit"; cat: "UT"; diff: 2 }
        ListElement { q: "Hifadhi ya Taifa ya Katavi ipo mkoa gani na inajulikana kwa nini?"; a: "Kigoma — sokwe"; b: "Katavi — kiboko na mamba wengi"; c: "Rukwa — ndege"; d: "Tabora — simba"; correct: "Katavi — kiboko na mamba wengi"; cat: "UT"; diff: 2 }
        ListElement { q: "Kisiwa cha Mafia kinajulikana kwa utalii wa aina gani?"; a: "Utalii wa milima"; b: "Kupiga mbizi (diving) na whale sharks"; c: "Safari ya wanyama"; d: "Utalii wa historia"; correct: "Kupiga mbizi (diving) na whale sharks"; cat: "UT"; diff: 2 }
        ListElement { q: "Nyangumi wakubwa (Whale Sharks) Tanzania wanapatikana wapi kwa wingi?"; a: "Zanzibar"; b: "Dar es Salaam"; c: "Mafia Island"; d: "Pemba"; correct: "Mafia Island"; cat: "UT"; diff: 2 }
        ListElement { q: "Hifadhi ya Taifa ya Saadani ina upekee gani wa pekee Afrika Mashariki?"; a: "Ina volkano hai"; b: "Ni hifadhi ya pekee yenye wanyama na pwani ya bahari"; c: "Ina sokwe wengi"; d: "Ina ndege adimu zaidi"; correct: "Ni hifadhi ya pekee yenye wanyama na pwani ya bahari"; cat: "UT"; diff: 2 }
        ListElement { q: "Wapi Tanzania unaweza kuogelea na Sea Turtles (Kasa wa Bahari)?"; a: "Dar es Salaam"; b: "Mafia, Pemba na Zanzibar"; c: "Tanga tu"; d: "Mtwara tu"; correct: "Mafia, Pemba na Zanzibar"; cat: "UT"; diff: 2 }
        ListElement { q: "Hifadhi ya Msitu wa Amani inajulikana kwa nini?"; a: "Wanyama wakubwa"; b: "Ndege adimu na viumbe vya msitu wa milima"; c: "Maporomoko ya maji"; d: "Mapango ya historia"; correct: "Ndege adimu na viumbe vya msitu wa milima"; cat: "UT"; diff: 3 }
        ListElement { q: "Ushoroba wa wanyama unaounganisha Serengeti (Tanzania) na Masai Mara (Kenya) unaitwa?"; a: "Ngorongoro Corridor"; b: "Mara River Corridor"; c: "Serengeti-Mara Ecosystem"; d: "Tanzanian Wildlife Corridor"; correct: "Serengeti-Mara Ecosystem"; cat: "UT"; diff: 3 }
        ListElement { q: "Mto Mara unaopitiwa na nyumbu wakati wa Great Migration unatoka wapi?"; a: "Tanzania"; b: "Kenya na Tanzania"; c: "Uganda"; d: "Rwanda"; correct: "Kenya na Tanzania"; cat: "UT"; diff: 3 }
        ListElement { q: "Watu wa asili wanaoishi karibu na Ngorongoro na wanaovutia watalii ni?"; a: "Wahehe"; b: "Wamasai"; c: "Wasukuma"; d: "Wachagga"; correct: "Wamasai"; cat: "UT"; diff: 1 }
        ListElement { q: "Ngome ya Portugali inayovutia watalii Kilwa Kisiwani ilijengwa karne gani?"; a: "Karne ya 13"; b: "Karne ya 15-16"; c: "Karne ya 18"; d: "Karne ya 19"; correct: "Karne ya 15-16"; cat: "UT"; diff: 3 }
        ListElement { q: "Mapango ya Amboni yanayovutia watalii yanapatikana wapi?"; a: "Arusha"; b: "Tanga"; c: "Morogoro"; d: "Lindi"; correct: "Tanga"; cat: "UT"; diff: 2 }
        ListElement { q: "Maporomoko ya Kalambo yaliyo karibu na Ziwa Tanganyika ni maarufu kwa nini?"; a: "Ni makubwa zaidi Afrika"; b: "Ni marefu ya pili Afrika"; c: "Yana maji ya moto"; d: "Yanazalisha umeme"; correct: "Ni marefu ya pili Afrika"; cat: "UT"; diff: 3 }
        ListElement { q: "Ziwa Eyasi linapatikana karibu na eneo la utalii gani?"; a: "Serengeti"; b: "Ngorongoro na Makabila ya Hadzabe"; c: "Tarangire"; d: "Manyara"; correct: "Ngorongoro na Makabila ya Hadzabe"; cat: "UT"; diff: 3 }
        ListElement { q: "Watu wa kabila la Hadzabe Tanzania wanaishi vipi na wanafanya nini kinachowavutia watalii?"; a: "Wafugaji wa ng'ombe"; b: "Wakulima wa kahawa"; c: "Wawindaji na wakusanyaji chakula (hunter-gatherers)"; d: "Wavuvi wa ziwa"; correct: "Wawindaji na wakusanyaji chakula (hunter-gatherers)"; cat: "UT"; diff: 2 }
        ListElement { q: "Pwani ndefu ya utalii upande wa mashariki wa Tanzania kutoka Tanga hadi Mtwara inaitwa?"; a: "Swahili Coast"; b: "Tanzania Coast"; c: "Indian Ocean Coast"; d: "Msumbiji Coast"; correct: "Swahili Coast"; cat: "UT"; diff: 2 }
        ListElement { q: "Mji wa Bagamoyo unafaa kwa utalii wa aina gani?"; a: "Safari ya wanyama"; b: "Utalii wa historia ya utumwa na ukoloni"; c: "Utalii wa bahari"; d: "Utalii wa milima"; correct: "Utalii wa historia ya utumwa na ukoloni"; cat: "UT"; diff: 2 }
        ListElement { q: "Hifadhi ya Taifa ya Burigi-Chato ipo mkoa gani?"; a: "Kagera na Geita"; b: "Mara"; c: "Shinyanga"; d: "Simiyu"; correct: "Kagera na Geita"; cat: "UT"; diff: 3 }
        ListElement { q: "Ziwa Tanganyika ni maarufu kwa aina gani za samaki wa kipekee?"; a: "Sangara na dagaa tu"; b: "Samaki wa pekee wasiopatikana mahali pengine (endemic cichlids)"; c: "Nyangumi na pomboo"; d: "Kambale wakubwa"; correct: "Samaki wa pekee wasiopatikana mahali pengine (endemic cichlids)"; cat: "UT"; diff: 3 }
        ListElement { q: "Giza la miti la Msitu wa Kakamega linalofanana na msitu wa mvua unapatikana karibu na Tanzania wapi?"; a: "Kenya"; b: "Uganda"; c: "Rwanda"; d: "Burundi"; correct: "Kenya"; cat: "UT"; diff: 3 }
        ListElement { q: "Hifadhi ya Biosphere ya Ziwa Manyara inatambulika na shirika gani la kimataifa?"; a: "UNESCO"; b: "WWF"; c: "IUCN"; d: "UN Environment"; correct: "UNESCO"; cat: "UT"; diff: 3 }
        ListElement { q: "Ughairi (poaching) wa wanyama Tanzania unasababisha upotezaji mkubwa wa wanyama gani?"; a: "Simba na chui"; b: "Tembo na kifaru"; c: "Nyumbu na pundamilia"; d: "Twiga na nyati"; correct: "Tembo na kifaru"; cat: "UT"; diff: 1 }
        ListElement { q: "Mji wa Arusha unahudumia kama kituo cha utalii kwa sababu?"; a: "Una uwanja mkubwa wa ndege"; b: "Uko katikati ya vivutio vingi vya kaskazini Tanzania"; c: "Ina hoteli nyingi"; d: "Ina reli"; correct: "Uko katikati ya vivutio vingi vya kaskazini Tanzania"; cat: "UT"; diff: 1 }
        ListElement { q: "Bwawa la samaki maarufu la utalii Ziwa Victoria linaitwa?"; a: "Mwanza Gulf"; b: "Rubondo Island"; c: "Rusinga Island"; d: "Ukerewe"; correct: "Rubondo Island"; cat: "UT"; diff: 3 }
        ListElement { q: "Tanzania inapata mapato ya ziada kutoka utalii kwa njia gani kuu?"; a: "Park fees na watalii wa hoteli"; b: "Mauzo ya nyara za wanyama"; c: "Uuzaji wa ardhi"; d: "Ushuru wa ndege"; correct: "Park fees na watalii wa hoteli"; cat: "UT"; diff: 2 }
        ListElement { q: "Vivutio vya utalii vya Zanzibar ni vipi vikuu?"; a: "Wanyama wakubwa"; b: "Fukwe, viungo, historia ya Stone Town na pwani"; c: "Milima na maporomoko"; d: "Mazao ya kahawa"; correct: "Fukwe, viungo, historia ya Stone Town na pwani"; cat: "UT"; diff: 1 }
        ListElement { q: "Shughuli maarufu ya watalii inayofanyika Serengeti kila mwaka ni?"; a: "Kulima shamba"; b: "Kuona Great Migration ya nyumbu"; c: "Kupiga mbizi"; d: "Kupanda mlima"; correct: "Kuona Great Migration ya nyumbu"; cat: "UT"; diff: 1 }
        ListElement { q: "Watalii wengi kutoka nchi gani wanatembelea Tanzania zaidi?"; a: "China na India"; b: "Marekani, Uingereza na Ujerumani"; c: "Brazil na Mexico"; d: "Russia na Canada"; correct: "Marekani, Uingereza na Ujerumani"; cat: "UT"; diff: 2 }
        ListElement { q: "Chandarua cha kulala ambacho kinatumiwa sana kwenye safari za wanyama Tanzania kinaitwa?"; a: "Tent"; b: "Banda"; c: "Camp"; d: "Safari Lodge"; correct: "Tent"; cat: "UT"; diff: 1 }
        ListElement { q: "Jina la Kiingereza la 'Utalii wa wanyama' Tanzania linaitwa?"; a: "Wildlife Tourism"; b: "Safari"; c: "Bush Walk"; d: "Game Drive"; correct: "Safari"; cat: "UT"; diff: 1 }
        ListElement { q: "Hifadhi ya Taifa ya Ibanda-Kyerwa ipo mkoa gani?"; a: "Mara"; b: "Kagera"; c: "Kigoma"; d: "Shinyanga"; correct: "Kagera"; cat: "UT"; diff: 3 }
        ListElement { q: "Tembo wa Tanzania wanapatikana kwa wingi zaidi katika hifadhi gani?"; a: "Serengeti"; b: "Nyerere (Selous) na Ruaha"; c: "Gombe"; d: "Kilimanjaro"; correct: "Nyerere (Selous) na Ruaha"; cat: "UT"; diff: 2 }
        ListElement { q: "Mji wa Moshi unafaa kwa utalii kwa sababu gani?"; a: "Una pwani nzuri"; b: "Ni mlango wa kupanda Kilimanjaro"; c: "Una hifadhi ya wanyama"; d: "Una historia ya Waarabu"; correct: "Ni mlango wa kupanda Kilimanjaro"; cat: "UT"; diff: 1 }
        ListElement { q: "Msimu mzuri wa kutembelea Serengeti kwa Great Migration ni?"; a: "Januari - Machi"; b: "Julai - Oktoba"; c: "Aprili - Juni"; d: "Novemba - Desemba"; correct: "Julai - Oktoba"; cat: "UT"; diff: 2 }
        ListElement { q: "Dawa ya malaria inayopendekezwa kwa watalii wanaoingia Tanzania ni?"; a: "Panadol"; b: "Prophylaxis ya malaria (kama Malarone)"; c: "Aspirini"; d: "Vitamini C"; correct: "Prophylaxis ya malaria (kama Malarone)"; cat: "UT"; diff: 2 }
        ListElement { q: "Chanjo inayohitajika kisheria kuingia Tanzania kutoka nchi zenye homa ya manjano ni?"; a: "Malaria"; b: "Yellow Fever (Homa ya Manjano)"; c: "Typhoid"; d: "Hepatitis B"; correct: "Yellow Fever (Homa ya Manjano)"; cat: "UT"; diff: 2 }
        ListElement { q: "Uwanja wa ndege wa kimataifa wa Kilimanjaro uko karibu na mji gani?"; a: "Moshi"; b: "Arusha"; c: "Kati ya Moshi na Arusha"; d: "Tanga"; correct: "Kati ya Moshi na Arusha"; cat: "UT"; diff: 2 }
        ListElement { q: "Hoteli zinazojulikana kwa kuwa ndani ya hifadhi za wanyama Tanzania zinaitwa?"; a: "Moteli"; b: "Lodge au tented camps"; c: "Nyumba za kulala wageni"; d: "Hostel"; correct: "Lodge au tented camps"; cat: "UT"; diff: 1 }
        ListElement { q: "Msitu wa Udzungwa unajulikana kwa viumbe gani vya kipekee?"; a: "Sokwe wa kawaida"; b: "Kima (primate) wa kipekee — Udzungwa Red Colobus"; c: "Tembo weupe"; d: "Chui wa dhahabu"; correct: "Kima (primate) wa kipekee — Udzungwa Red Colobus"; cat: "UT"; diff: 3 }
        ListElement { q: "Shirika la ndege la Tanzania linaitwa nini?"; a: "Air Tanzania"; b: "Tanzania Airlines"; c: "Kilimanjaro Air"; d: "Swahili Airlines"; correct: "Air Tanzania"; cat: "UT"; diff: 1 }
        ListElement { q: "Watalii wanaopanda Kilimanjaro wana asilimia ngapi ya kufanikiwa kufika kilele?"; a: "Karibu 30%"; b: "Karibu 50%"; c: "Karibu 65%"; d: "Karibu 90%"; correct: "Karibu 65%"; cat: "UT"; diff: 3 }
        ListElement { q: "Vizuizi vya hali ya hewa kwenye Kilimanjaro vina mikanda (zones) mingapi?"; a: "3"; b: "4"; c: "5"; d: "6"; correct: "5"; cat: "UT"; diff: 3 }
        ListElement { q: "Hali ya hewa ya 'Arctic Zone' inaanza urefu gani Kilimanjaro?"; a: "Mita 3,000"; b: "Mita 4,000"; c: "Mita 5,000"; d: "Mita 5,500"; correct: "Mita 5,000"; cat: "UT"; diff: 3 }
        ListElement { q: "Vivutio vya utalii vya Kigoma ni vipi?"; a: "Hifadhi ya Gombe, Mahale na Ziwa Tanganyika"; b: "Mlima na wanyama wa nyanda"; c: "Pwani ya bahari"; d: "Mazao ya kahawa"; correct: "Hifadhi ya Gombe, Mahale na Ziwa Tanganyika"; cat: "UT"; diff: 2 }
        ListElement { q: "Mwanzishaji wa utafiti wa sokwe Tanzania, mwanamke maarufu aliyefanya kazi Gombe ni?"; a: "Dian Fossey"; b: "Jane Goodall"; c: "Birute Galdikas"; d: "Mary Leakey"; correct: "Jane Goodall"; cat: "UT"; diff: 2 }
        ListElement { q: "Kivutio kikuu cha utalii kwa watalii wanaokwenda Lindi na Mtwara ni?"; a: "Wanyama wa hifadhi"; b: "Milango ya asili ya Makonde na historia ya pwani"; c: "Pwani za dhahabu"; d: "Maporomoko ya maji"; correct: "Milango ya asili ya Makonde na historia ya pwani"; cat: "UT"; diff: 2 }
        ListElement { q: "Tanzania ina hifadhi za taifa ngapi rasmi?"; a: "12"; b: "17"; c: "22"; d: "28"; correct: "22"; cat: "UT"; diff: 3 }
        ListElement { q: "Mwaka ambao Tanzania ilianzisha rasmi utalii kama sekta muhimu ya uchumi ni?"; a: "Miaka ya 1970"; b: "Miaka ya 1980"; c: "Miaka ya 1990"; d: "Miaka ya 2000"; correct: "Miaka ya 1990"; cat: "UT"; diff: 3 }
        ListElement { q: "Nchi ya Tanzania inashika nafasi ya ngapi Afrika kwa mapato ya utalii?"; a: "Ya kwanza"; b: "Ya pili"; c: "Ya tatu"; d: "Ya nne"; correct: "Ya tatu"; cat: "UT"; diff: 3 }
        ListElement { q: "Muziki wa 'Taarab' wa Zanzibar unavutia watalii — unachezwa kawaida wapi?"; a: "Fukwe"; b: "Masikani ya Stone Town na harusi"; c: "Viwanja vya michezo"; d: "Shule"; correct: "Masikani ya Stone Town na harusi"; cat: "UT"; diff: 2 }
        ListElement { q: "Mji wa Zanzibar (Stone Town) ulianzishwa na watu wa kabila gani kama kituo cha biashara?"; a: "Wareno"; b: "Wafaransa"; c: "Waarabu wa Oman"; d: "Wahindi"; correct: "Waarabu wa Oman"; cat: "UT"; diff: 2 }
        ListElement { q: "Biashara ya karafuu (cloves) Zanzibar ilianzishwa na watawala gani?"; a: "Wareno"; b: "Waarabu wa Oman"; c: "Waingereza"; d: "Wajerumani"; correct: "Waarabu wa Oman"; cat: "UT"; diff: 3 }
        ListElement { q: "Vivutio vya utalii vya Morogoro ni vipi?"; a: "Bahari na mapango"; b: "Milima ya Uluguru, SUA na mazingira ya kijani"; c: "Wanyama wa savanna"; d: "Historia ya waarabu"; correct: "Milima ya Uluguru, SUA na mazingira ya kijani"; cat: "UT"; diff: 2 }
        ListElement { q: "Wanyama wa 'Little Five' Tanzania ni kinyume cha Big Five — mfano wake ni?"; a: "Simba mdogo, Tembo mdogo"; b: "Ant Lion, Elephant Shrew, Buffalo Weaver, Rhinoceros Beetle, Leopard Tortoise"; c: "Kobe, Kenge, Nyoka"; d: "Ndege wakubwa 5"; correct: "Ant Lion, Elephant Shrew, Buffalo Weaver, Rhinoceros Beetle, Leopard Tortoise"; cat: "UT"; diff: 3 }
        ListElement { q: "Maporomoko ya Materuni (Materuni Waterfalls) yanapatikana karibu na mji gani?"; a: "Arusha"; b: "Morogoro"; c: "Moshi"; d: "Tanga"; correct: "Moshi"; cat: "UT"; diff: 2 }
        ListElement { q: "Utalii wa utamaduni (Cultural Tourism) wa Tanzania unaojulikana zaidi uko wapi?"; a: "Dar es Salaam"; b: "Mto wa Mbu karibu na Manyara"; c: "Mwanza"; d: "Dodoma"; correct: "Mto wa Mbu karibu na Manyara"; cat: "UT"; diff: 2 }
        ListElement { q: "Hifadhi ya Taifa ya Mkomazi ipo mkoa gani na inajulikana kwa nini?"; a: "Kilimanjaro — kifaru mweusi"; b: "Tanga — tembo"; c: "Arusha — simba"; d: "Manyara — twiga"; correct: "Kilimanjaro — kifaru mweusi"; cat: "UT"; diff: 3 }
        ListElement { q: "Watalii wanaoingia Tanzania kwa kawaida hupitia uwanja gani mkubwa wa ndege?"; a: "Julius Nyerere International Airport (JNIA)"; b: "Kilimanjaro International Airport"; c: "Zanzibar Airport"; d: "Mwanza Airport"; correct: "Julius Nyerere International Airport (JNIA)"; cat: "UT"; diff: 1 }
        ListElement { q: "Kivutio maarufu cha utalii kilichopo karibu na Mwanza ni?"; a: "Rubondo Island National Park"; b: "Gombe Stream"; c: "Bukoba"; d: "Mara River"; correct: "Rubondo Island National Park"; cat: "UT"; diff: 2 }
        ListElement { q: "Milango maarufu ya sanaa ya Makonde inayovutia watalii inapatikana zaidi wapi Tanzania?"; a: "Zanzibar"; b: "Mwanza"; c: "Mtwara na Masasi"; d: "Arusha"; correct: "Mtwara na Masasi"; cat: "UT"; diff: 2 }

        // ══════════════════════════════════════════════════════════
        // MANTIKI / LOGIC (LG) — maswali 60 mapya
        // ══════════════════════════════════════════════════════════
        ListElement { q: "Kama A ni kubwa kuliko B, na C ni ndogo kuliko B, nani ndiye mkubwa zaidi?"; a: "B"; b: "C"; c: "A"; d: "Wote sawa"; correct: "A"; cat: "LG"; diff: 1 }
        ListElement { q: "Nambari inayofuata: 3, 6, 12, 24, ..."; a: "36"; b: "48"; c: "42"; d: "30"; correct: "48"; cat: "LG"; diff: 1 }
        ListElement { q: "Kama leo ni Jumanne, wiki 3 ijayo itakuwa siku gani?"; a: "Jumatatu"; b: "Jumanne"; c: "Jumatano"; d: "Alhamisi"; correct: "Jumanne"; cat: "LG"; diff: 2 }
        ListElement { q: "Katika mfululizo: 1, 4, 9, 16, 25, nambari inayofuata ni?"; a: "30"; b: "36"; c: "35"; d: "32"; correct: "36"; cat: "LG"; diff: 1 }
        ListElement { q: "Kama watu 5 wanaweza kumalizia kazi katika siku 6, watu 3 watamalizia kazi hiyo kwa siku ngapi?"; a: "8"; b: "9"; c: "10"; d: "12"; correct: "10"; cat: "LG"; diff: 3 }
        ListElement { q: "Herufi inayokosekana: A, C, F, J, O, ..."; a: "S"; b: "T"; c: "U"; d: "V"; correct: "U"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama MWALIMU = 7, na DAKTARI = 7, basi MWANAFUNZI = ?"; a: "9"; b: "10"; c: "11"; d: "12"; correct: "10"; cat: "LG"; diff: 2 }
        ListElement { q: "Saa 3:45 mshale mkubwa unaelekea upande gani?"; a: "Juu"; b: "Chini"; c: "Kushoto"; d: "Kulia"; correct: "Chini"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama unavyouza kwa bei ya kununulia, faida yako ni?"; a: "Sifuri"; b: "Nusu ya gharama"; c: "Mara mbili"; d: "Theluthi"; correct: "Sifuri"; cat: "LG"; diff: 1 }
        ListElement { q: "Nambari inayofuata: 2, 3, 5, 8, 13, 21, ..."; a: "29"; b: "32"; c: "34"; d: "36"; correct: "34"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama x + y = 10 na x - y = 4, basi x ni ngapi?"; a: "5"; b: "6"; c: "7"; d: "8"; correct: "7"; cat: "LG"; diff: 2 }
        ListElement { q: "Mtu anakimbia mzunguko wa uwanja wa mstatili wenye urefu 80m na upana 50m. Safari moja ni mita ngapi?"; a: "130m"; b: "200m"; c: "260m"; d: "300m"; correct: "260m"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama nusu ya idadi ni 24, robo ya idadi hiyo ni?"; a: "6"; b: "12"; c: "18"; d: "24"; correct: "12"; cat: "LG"; diff: 1 }
        ListElement { q: "Neno: ASUBUHI — herufi ngapi ni vokali?"; a: "2"; b: "3"; c: "4"; d: "5"; correct: "4"; cat: "LG"; diff: 2 }
        ListElement { q: "Mfululizo: 100, 90, 81, 73, 66, ... Nambari inayofuata ni?"; a: "59"; b: "60"; c: "61"; d: "62"; correct: "60"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama mnyororo una pete 5 na kila pete imeunganishwa na pete mbili, pete ya katikati imeunganishwa na pete ngapi?"; a: "1"; b: "2"; c: "3"; d: "4"; correct: "2"; cat: "LG"; diff: 2 }
        ListElement { q: "Nambari gani haijakamilika kwenye mfululizo: 2, 5, 10, 17, 26, __, 50?"; a: "35"; b: "36"; c: "37"; d: "38"; correct: "37"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama tunda moja la machungwa lina thamani ya shilingi 500, matunda 8 yana thamani gani?"; a: "3,500"; b: "4,000"; c: "4,500"; d: "5,000"; correct: "4,000"; cat: "LG"; diff: 1 }
        ListElement { q: "Upande wa kaskazini unaangalia mbele yako, upande wa mashariki uko wapi?"; a: "Nyuma yako"; b: "Mkono wako wa kulia"; c: "Mkono wako wa kushoto"; d: "Juu yako"; correct: "Mkono wako wa kulia"; cat: "LG"; diff: 1 }
        ListElement { q: "Kama unaandika namba zote kutoka 1 hadi 50, tarakimu '1' itaonekana mara ngapi?"; a: "10"; b: "14"; c: "15"; d: "16"; correct: "15"; cat: "LG"; diff: 3 }
        ListElement { q: "Kizazi cha babu ni kizazi cha ngapi kutoka kwako?"; a: "Cha kwanza"; b: "Cha pili"; c: "Cha tatu"; d: "Cha nne"; correct: "Cha tatu"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama darasa lina wanafunzi 30 na asilimia 40 ni wavulana, wasichana ni wangapi?"; a: "12"; b: "15"; c: "18"; d: "20"; correct: "18"; cat: "LG"; diff: 2 }
        ListElement { q: "Mfululizo wa piramidi: 1, 3, 6, 10, 15, ... Nambari inayofuata ni?"; a: "18"; b: "20"; c: "21"; d: "22"; correct: "21"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama neno 'LOGIC' linaandikwa nyuma, linaandikwaje?"; a: "CIGOL"; b: "LOGCI"; c: "COLOG"; d: "GILOC"; correct: "CIGOL"; cat: "LG"; diff: 1 }
        ListElement { q: "Kama Jana alikuwa ni Jumamosi, wiki ijayo siku ya leo itakuwa nini?"; a: "Jumapili"; b: "Jumatatu"; c: "Jumanne"; d: "Jumatano"; correct: "Jumapili"; cat: "LG"; diff: 2 }
        ListElement { q: "Gari linasafiri kwa kasi ya km 60 kwa saa. Litafika wapi baada ya dakika 30?"; a: "Km 20"; b: "Km 30"; c: "Km 45"; d: "Km 60"; correct: "Km 30"; cat: "LG"; diff: 1 }
        ListElement { q: "Kama bidhaa imepanda bei kwa 20% na kisha kushuka kwa 20%, bei ya mwisho ni?"; a: "Sawa na mwanzo"; b: "Chini ya mwanzo kwa 4%"; c: "Juu ya mwanzo kwa 4%"; d: "Chini ya mwanzo kwa 2%"; correct: "Chini ya mwanzo kwa 4%"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama una vizuri vilivyopangwa kwenye mstari: Nyekundu, Bluu, Kijani, Njano, Nyekundu, Bluu, Kijani... Rangi ya 11 ni?"; a: "Nyekundu"; b: "Bluu"; c: "Kijani"; d: "Njano"; correct: "Kijani"; cat: "LG"; diff: 2 }
        ListElement { q: "Tatizo: Watu 3 wana mikono 3. Watu 10 wana mikono mingapi?"; a: "10"; b: "20"; c: "30"; d: "15"; correct: "20"; cat: "LG"; diff: 1 }
        ListElement { q: "Nambari inayofuata: 1, 2, 4, 7, 11, 16, ..."; a: "20"; b: "21"; c: "22"; d: "23"; correct: "22"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama mzigo wa ndizi ni kilo 25, sehemu ya tano ya mzigo ni kilo ngapi?"; a: "4"; b: "5"; c: "6"; d: "7"; correct: "5"; cat: "LG"; diff: 1 }
        ListElement { q: "Mfululizo: Z, X, V, T, R, ... Herufi inayofuata ni?"; a: "P"; b: "Q"; c: "N"; d: "O"; correct: "P"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama gurudumu la baiskeli lina msumari ulioumia, msumari unapiga ardhini mara ngapi kwa zamu moja kamili?"; a: "Mara moja"; b: "Mara mbili"; c: "Mara tatu"; d: "Mara nne"; correct: "Mara moja"; cat: "LG"; diff: 1 }
        ListElement { q: "Kama mtu anakimbia mbio za mita 400 na anafanikiwa mara 3, jumla ni mita ngapi?"; a: "800"; b: "1000"; c: "1200"; d: "1600"; correct: "1200"; cat: "LG"; diff: 1 }
        ListElement { q: "Kama A=1, B=2, C=3, basi CAB inawakilisha nambari gani?"; a: "123"; b: "312"; c: "321"; d: "213"; correct: "312"; cat: "LG"; diff: 2 }
        ListElement { q: "Mti una matawi 4. Kila tawi lina matawi 4. Kila tawi dogo lina matawi 4. Jumla ya matawi yote ni?"; a: "16"; b: "64"; c: "84"; d: "20"; correct: "84"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama mstatili una urefu mara 3 ya upana wake, na mzingo ni cm 64, upana wake ni cm ngapi?"; a: "6"; b: "8"; c: "10"; d: "12"; correct: "8"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama una sarafu 7 za shilingi 50, sarafu 3 za shilingi 100, na noti 2 za shilingi 500, una shilingi ngapi?"; a: "1,150"; b: "1,350"; c: "1,650"; d: "2,150"; correct: "1,650"; cat: "LG"; diff: 2 }
        ListElement { q: "Somo la historia linaanza saa 2 asubuhi na hudumu saa 1 na nusu. Linaisha saa ngapi?"; a: "Saa 3 asubuhi"; b: "Saa 3:30 asubuhi"; c: "Saa 4 asubuhi"; d: "Saa 3:45 asubuhi"; correct: "Saa 3:30 asubuhi"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama SIKU = 4 na WIKI = 4 na MWAKA = 5, basi hesabu inayofuata ni nini?"; a: "DAKIKA = 6"; b: "DAKIKA = 7"; c: "DAKIKA = 5"; d: "DAKIKA = 4"; correct: "DAKIKA = 6"; cat: "LG"; diff: 3 }
        ListElement { q: "Mfululizo: 1, 8, 27, 64, ... Nambari inayofuata ni?"; a: "100"; b: "115"; c: "125"; d: "130"; correct: "125"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama wewe una umri wa miaka 15 na dada yako ana nusu ya umri wako, umri wako ukifikia miaka 30, dada atakuwa na miaka mingapi?"; a: "15"; b: "20"; c: "22"; d: "23"; correct: "22"; cat: "LG"; diff: 3 }
        ListElement { q: "Nambari ngapi zisizo za kawaida (odd) zipo kati ya 10 na 20?"; a: "4"; b: "5"; c: "6"; d: "7"; correct: "5"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama pembe tatu za pembetatu ni 60°, 70° na x°, thamani ya x ni?"; a: "40°"; b: "50°"; c: "60°"; d: "70°"; correct: "50°"; cat: "LG"; diff: 2 }
        ListElement { q: "Wafanyakazi 4 wanachimba shimo kwa masaa 8. Wafanyakazi 8 watachimba shimo sawa kwa masaa mangapi?"; a: "2"; b: "3"; c: "4"; d: "6"; correct: "4"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama MAMA ana dada mmoja, na dada wake ana mtoto mmoja, uhusiano wa mtoto huyo na MAMA ni?"; a: "Mtoto"; b: "Shangazi na mpwa"; c: "Shangazi na mpwa wa nje"; d: "Kaka na dada"; correct: "Shangazi na mpwa"; cat: "LG"; diff: 2 }
        ListElement { q: "Nambari ya ajabu (prime) kati ya 20 na 30 ni ipi?"; a: "21"; b: "23"; c: "25"; d: "27"; correct: "23"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama hesabu 5 × 5 = 25, basi 55 × 55 = ?"; a: "2525"; b: "3025"; c: "2550"; d: "3005"; correct: "3025"; cat: "LG"; diff: 3 }
        ListElement { q: "Picha 3 zinaweza kuchukua nafasi ya paka 4. Paka 8 zinaweza kuchukua nafasi ya picha ngapi?"; a: "4"; b: "5"; c: "6"; d: "7"; correct: "6"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama kila pembe ya mraba ni 90°, jumla ya pembe zote ni?"; a: "180°"; b: "270°"; c: "360°"; d: "450°"; correct: "360°"; cat: "LG"; diff: 1 }
        ListElement { q: "Mfululizo: 0.5, 1, 2, 4, 8, ... Nambari inayofuata ni?"; a: "12"; b: "14"; c: "16"; d: "18"; correct: "16"; cat: "LG"; diff: 1 }
        ListElement { q: "Kama kiganjani kuna pesa 500 na unatoa robo tatu, unabakisha kiasi gani?"; a: "100"; b: "125"; c: "150"; d: "175"; correct: "125"; cat: "LG"; diff: 2 }
        ListElement { q: "Nambari ngapi ni ndogo kuliko 100 zinazogawanyika na 7 na 3 zote mbili?"; a: "3"; b: "4"; c: "5"; d: "6"; correct: "4"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama msururu wa herufi ni AZBYCX, herufi inayofuata baada ya X ni?"; a: "DW"; b: "WD"; c: "DV"; d: "VD"; correct: "DW"; cat: "LG"; diff: 3 }
        ListElement { q: "Kama nyumba ina vyumba 4 na kila chumba kina kona 4, jumla ya kona za nyumba ni?"; a: "12"; b: "16"; c: "20"; d: "24"; correct: "16"; cat: "LG"; diff: 1 }
        ListElement { q: "Kama mtu anakula chakula kwa dakika 20 na kinywaji kwa dakika 5, atachukua muda gani kwa milo 3 ya chakula na vinywaji?"; a: "60 dakika"; b: "65 dakika"; c: "75 dakika"; d: "90 dakika"; correct: "75 dakika"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama bei ya kitu imepanda kutoka 800 hadi 1000, imepanda kwa asilimia ngapi?"; a: "15%"; b: "20%"; c: "25%"; d: "30%"; correct: "25%"; cat: "LG"; diff: 2 }
        ListElement { q: "Nambari inayofuata mfululizo: 1, 1, 2, 3, 5, 8, 13, ..."; a: "18"; b: "19"; c: "20"; d: "21"; correct: "21"; cat: "LG"; diff: 2 }
        ListElement { q: "Kama Juma ana ndugu 4 wa kiume, na kila mmoja ana dada 1, Juma ana dada wangapi?"; a: "1"; b: "2"; c: "4"; d: "5"; correct: "1"; cat: "LG"; diff: 3 }

        // ══════════════════════════════════════════════════════════
        // KUONGEZA MASWALI (+18 kwa kila cat inayohitaji)
        // ══════════════════════════════════════════════════════════

        // AFYA (+18)
        ListElement { q: "Shinikizo la damu la kawaida kwa mtu mwenye afya ni?"; a: "80/60 mmHg"; b: "120/80 mmHg"; c: "140/90 mmHg"; d: "160/100 mmHg"; correct: "120/80 mmHg"; cat: "A"; diff: 2 }
        ListElement { q: "Damu ya binadamu ina pH ya takriban ngapi?"; a: "6.0 - 6.5"; b: "7.35 - 7.45"; c: "8.0 - 8.5"; d: "5.5 - 6.0"; correct: "7.35 - 7.45"; cat: "A"; diff: 3 }
        ListElement { q: "Mfupa mrefu zaidi mwilini mwa binadamu ni?"; a: "Mgongo"; b: "Ubavu"; c: "Femur (paja)"; d: "Tibia (mguu wa chini)"; correct: "Femur (paja)"; cat: "A"; diff: 2 }
        ListElement { q: "Cholera husambazwa kwa njia gani?"; a: "Hewa"; b: "Mbu"; c: "Maji na chakula vilivyochafuliwa"; d: "Mgusano wa ngozi"; correct: "Maji na chakula vilivyochafuliwa"; cat: "A"; diff: 1 }
        ListElement { q: "Chanjo ya BCG inakinga dhidi ya ugonjwa gani?"; a: "Kipindupindu"; b: "Kifua kikuu (TB)"; c: "Surua"; d: "Polio"; correct: "Kifua kikuu (TB)"; cat: "A"; diff: 2 }
        ListElement { q: "Dawa ya kwanza ya antibiotiki iliyogunduliwa duniani ni?"; a: "Amoxicillin"; b: "Tetracycline"; c: "Penicillin"; d: "Streptomycin"; correct: "Penicillin"; cat: "A"; diff: 2 }
        ListElement { q: "Sehemu ya ubongo inayodhibiti kumbukumbu na hisia inaitwa?"; a: "Cerebellum"; b: "Hippocampus"; c: "Medulla"; d: "Cortex"; correct: "Hippocampus"; cat: "A"; diff: 3 }
        ListElement { q: "Ini (Liver) ina kazi ngapi kuu mwilini?"; a: "Moja"; b: "Mbili"; c: "Tatu"; d: "Zaidi ya 500"; correct: "Zaidi ya 500"; cat: "A"; diff: 3 }
        ListElement { q: "Kisukari cha aina ya 2 kinahusiana zaidi na?"; a: "Maambukizi ya virusi"; b: "Unene kupita kiasi na lishe mbaya"; c: "Urithi wa kinasaba tu"; d: "Mzigo wa kazi"; correct: "Unene kupita kiasi na lishe mbaya"; cat: "A"; diff: 2 }
        ListElement { q: "Matumizi ya sigara yanasababisha hasa saratani ya?"; a: "Saratani ya ngozi"; b: "Saratani ya mapafu"; c: "Saratani ya tumbo"; d: "Saratani ya damu"; correct: "Saratani ya mapafu"; cat: "A"; diff: 1 }
        ListElement { q: "Kinga ya mwili (immune system) inazalisha nini kupigana na maambukizi?"; a: "Hemoglobin"; b: "Antibodies"; c: "Platelets"; d: "Insulin"; correct: "Antibodies"; cat: "A"; diff: 2 }
        ListElement { q: "Usingizi wa kutosha kwa mtu mzima kwa siku ni masaa mangapi?"; a: "4-5"; b: "6-7"; c: "7-9"; d: "10-12"; correct: "7-9"; cat: "A"; diff: 1 }
        ListElement { q: "Mazoezi ya mwili yanasaidia kupunguza?"; a: "Kinga ya mwili"; b: "Msongo wa mawazo na magonjwa ya moyo"; c: "Nguvu za mwili"; d: "Uzito wa mifupa"; correct: "Msongo wa mawazo na magonjwa ya moyo"; cat: "A"; diff: 1 }
        ListElement { q: "Mgonjwa wa kisukari anapaswa kufuatilia nini mara kwa mara?"; a: "Shinikizo la damu tu"; b: "Kiwango cha sukari (glucose) mwilini"; c: "Uzito wa mwili tu"; d: "Joto la mwili"; correct: "Kiwango cha sukari (glucose) mwilini"; cat: "A"; diff: 2 }
        ListElement { q: "Nini tofauti kuu kati ya bakteria na virusi?"; a: "Bakteria ni wakubwa na wanaweza kutibiwa na antibiotiki"; b: "Virusi ni wakubwa"; c: "Bakteria husababisha magonjwa makubwa zaidi"; d: "Hakuna tofauti"; correct: "Bakteria ni wakubwa na wanaweza kutibiwa na antibiotiki"; cat: "A"; diff: 2 }
        ListElement { q: "Tumbo (stomach) lina asidi inayoitwa?"; a: "Asidi ya Citric"; b: "Asidi ya Hydrochloric (HCl)"; c: "Asidi ya Acetic"; d: "Asidi ya Sulfuric"; correct: "Asidi ya Hydrochloric (HCl)"; cat: "A"; diff: 3 }
        ListElement { q: "Kupumua kwa binadamu kunafanywa na viungo vipi?"; a: "Moyo na mishipa"; b: "Mapafu na diaphragm"; c: "Ini na figo"; d: "Ubongo na mishipa"; correct: "Mapafu na diaphragm"; cat: "A"; diff: 1 }
        ListElement { q: "Chanjo ya COVID-19 ilizalishwa kwa muda mfupi zaidi wa chanjo yoyote kwa historia — ilichukua muda gani?"; a: "Miezi 6"; b: "Mwaka 1"; c: "Miaka 2"; d: "Miaka 5"; correct: "Mwaka 1"; cat: "A"; diff: 3 }

        // SAYANSI (+18)
        ListElement { q: "Einstein aliunda nadharia gani maarufu?"; a: "Nadharia ya Mageuzi"; b: "Nadharia ya Mvuto"; c: "Nadharia ya Uhusiano (Relativity)"; d: "Nadharia ya Quantum"; correct: "Nadharia ya Uhusiano (Relativity)"; cat: "S"; diff: 2 }
        ListElement { q: "Gesi inayofanya ozoni angani kuwa na mwiba ni?"; a: "CO2"; b: "Methane"; c: "CFC (Chlorofluorocarbons)"; d: "Nitrogen"; correct: "CFC (Chlorofluorocarbons)"; cat: "S"; diff: 3 }
        ListElement { q: "Mwanga unaosafiri kwa kasi ya sekunde moja unakwenda umbali gani?"; a: "Km 30,000"; b: "Km 300,000"; c: "Km 3,000,000"; d: "Km 30,000,000"; correct: "Km 300,000"; cat: "S"; diff: 2 }
        ListElement { q: "Molekuli ya maji ina atomi ngapi?"; a: "2"; b: "3"; c: "4"; d: "5"; correct: "3"; cat: "S"; diff: 1 }
        ListElement { q: "Sayari inayozunguka Jua kwa muda mfupi zaidi ni?"; a: "Venus"; b: "Mars"; c: "Mercury"; d: "Earth"; correct: "Mercury"; cat: "S"; diff: 2 }
        ListElement { q: "DNA iko wapi kwenye seli?"; a: "Membrane ya seli"; b: "Cytoplasm"; c: "Nucleus (kiini)"; d: "Mitochondria"; correct: "Nucleus (kiini)"; cat: "S"; diff: 1 }
        ListElement { q: "Kipengele cha kemikali chenye alama 'Au' ni?"; a: "Fedha"; b: "Shaba"; c: "Dhahabu"; d: "Aluminium"; correct: "Dhahabu"; cat: "S"; diff: 1 }
        ListElement { q: "Nguvu ya mvuto kati ya vitu viwili inategemea nini?"; a: "Rangi ya vitu"; b: "Wingi (mass) na umbali wao"; c: "Joto la vitu"; d: "Rangi ya vitu"; correct: "Wingi (mass) na umbali wao"; cat: "S"; diff: 2 }
        ListElement { q: "Uundaji wa glukosi kutoka CO2 na maji kwa nishati ya jua unaitwa?"; a: "Upumuaji"; b: "Photosynthesis"; c: "Osmosis"; d: "Diffusion"; correct: "Photosynthesis"; cat: "S"; diff: 1 }
        ListElement { q: "Sauti ya ngurumo (thunder) ni matokeo ya nini?"; a: "Mawingu yanagongana"; b: "Hewa inayopanuka kwa haraka kutokana na radi"; c: "Mvua kubwa"; d: "Upepo mkali"; correct: "Hewa inayopanuka kwa haraka kutokana na radi"; cat: "S"; diff: 3 }
        ListElement { q: "Sayari ya Saturn inajulikana kwa nini?"; a: "Rangi yake ya nyekundu"; b: "Pete zake zinazozunguka"; c: "Ukubwa wake mdogo"; d: "Mwezi mmoja mkubwa"; correct: "Pete zake zinazozunguka"; cat: "S"; diff: 1 }
        ListElement { q: "Nguvu inayofanya sumaku kuvutia chuma inaitwa?"; a: "Nguvu ya uvutano"; b: "Nguvu ya umeme"; c: "Nguvu ya sumaku (magnetism)"; d: "Nguvu ya msuguano"; correct: "Nguvu ya sumaku (magnetism)"; cat: "S"; diff: 1 }
        ListElement { q: "Mwaka wa nuru (light year) ni kipimo cha nini?"; a: "Muda"; b: "Uzito"; c: "Umbali"; d: "Kasi"; correct: "Umbali"; cat: "S"; diff: 2 }
        ListElement { q: "Kupima joto la vitu hutumia kipimo gani cha msingi cha kisayansi?"; a: "Celsius"; b: "Fahrenheit"; c: "Kelvin"; d: "Newton"; correct: "Kelvin"; cat: "S"; diff: 3 }
        ListElement { q: "Ubongo wa binadamu una asilimia ngapi ya mwili lakini unatumia asilimia ngapi ya nishati?"; a: "2% - 20%"; b: "5% - 10%"; c: "10% - 30%"; d: "15% - 25%"; correct: "2% - 20%"; cat: "S"; diff: 3 }
        ListElement { q: "Nini maana ya 'ecosystem'?"; a: "Mfumo wa umeme"; b: "Mfumo wa viumbe na mazingira yao wanayoshirikiana"; c: "Aina ya mmea"; d: "Aina ya hewa"; correct: "Mfumo wa viumbe na mazingira yao wanayoshirikiana"; cat: "S"; diff: 2 }
        ListElement { q: "Viumbe vidogo visivyoonekana kwa jicho inaitwa?"; a: "Insects"; b: "Microorganisms"; c: "Fungi"; d: "Algae"; correct: "Microorganisms"; cat: "S"; diff: 1 }
        ListElement { q: "Kwa nini mbinguni ni rangi ya buluu mchana?"; a: "Mawingu ya buluu"; b: "Mwanga wa jua unaosambazwa na hewa hupitisha rangi buluu zaidi"; c: "Bahari inarudisha rangi buluu juu"; d: "Oksijeni ni ya rangi buluu"; correct: "Mwanga wa jua unaosambazwa na hewa hupitisha rangi buluu zaidi"; cat: "S"; diff: 3 }

        // HISTORIA (+18)
        ListElement { q: "Mji wa kale wa Rumi (Rome) ulikuwa mji mkuu wa dola gani?"; a: "Dola ya Ugiriki"; b: "Dola ya Roma"; c: "Dola ya Misri"; d: "Dola ya Ufaransa"; correct: "Dola ya Roma"; cat: "H"; diff: 1 }
        ListElement { q: "Majarida ya zamani ya Misri yaliyoandikwa kwenye mimea yaliitwa?"; a: "Papyrus"; b: "Parchment"; c: "Canvas"; d: "Velvet"; correct: "Papyrus"; cat: "H"; diff: 2 }
        ListElement { q: "Cleopatra alikuwa malkia wa nchi gani?"; a: "Ugiriki"; b: "Roma"; c: "Misri"; d: "Mesopotamia"; correct: "Misri"; cat: "H"; diff: 1 }
        ListElement { q: "Barabara ya Hariri (Silk Road) iliunganisha nchi gani kwa biashara?"; a: "Afrika na Amerika"; b: "China na Ulaya kupitia Asia ya Kati"; c: "India na Afrika"; d: "Arabia na Uingereza"; correct: "China na Ulaya kupitia Asia ya Kati"; cat: "H"; diff: 2 }
        ListElement { q: "Vita vya Kwanza vya Dunia viliisha mwaka gani?"; a: "1916"; b: "1917"; c: "1918"; d: "1919"; correct: "1918"; cat: "H"; diff: 1 }
        ListElement { q: "Bomba la atomu lililotupwa Hiroshima liliitwa?"; a: "Fat Man"; b: "Little Boy"; c: "Big Baby"; d: "Thunder"; correct: "Little Boy"; cat: "H"; diff: 3 }
        ListElement { q: "Mapinduzi ya Viwanda (Industrial Revolution) yalianza nchi gani?"; a: "Ufaransa"; b: "Ujerumani"; c: "Uingereza"; d: "Marekani"; correct: "Uingereza"; cat: "H"; diff: 2 }
        ListElement { q: "Mkataba wa Oslo uliotiwa sahihi mwaka 1993 ulihusiana na amani kati ya nchi zipi?"; a: "India na Pakistan"; b: "Israel na Palestine"; c: "Amerika na Urusi"; d: "Iraq na Kuwait"; correct: "Israel na Palestine"; cat: "H"; diff: 3 }
        ListElement { q: "Mwaka gani Apartheid ilimalizika Afrika Kusini?"; a: "1990"; b: "1991"; c: "1994"; d: "1996"; correct: "1994"; cat: "H"; diff: 2 }
        ListElement { q: "Mgeni wa kwanza wa Uropa aliyefika India kwa bahari ya Afrika alikuwa?"; a: "Christopher Columbus"; b: "Vasco da Gama"; c: "Ferdinand Magellan"; d: "Francis Drake"; correct: "Vasco da Gama"; cat: "H"; diff: 2 }
        ListElement { q: "Vita vya Maji Maji Tanzania vilipiganwa dhidi ya wakoloni wa nchi gani?"; a: "Waingereza"; b: "Wafaransa"; c: "Wajerumani"; d: "Wareno"; correct: "Wajerumani"; cat: "H"; diff: 1 }
        ListElement { q: "Kiongozi wa Uhuru wa India aliyetumia njia ya amani alikuwa?"; a: "Jawaharlal Nehru"; b: "Subhas Bose"; c: "Mahatma Gandhi"; d: "Indira Gandhi"; correct: "Mahatma Gandhi"; cat: "H"; diff: 1 }
        ListElement { q: "Msalaba Mwekundu (Red Cross) ulianzishwa na nani?"; a: "Florence Nightingale"; b: "Henry Dunant"; c: "Louis Pasteur"; d: "Albert Schweitzer"; correct: "Henry Dunant"; cat: "H"; diff: 3 }
        ListElement { q: "Mwaka gani Umoja wa Mataifa (UN) ulianzishwa?"; a: "1943"; b: "1944"; c: "1945"; d: "1946"; correct: "1945"; cat: "H"; diff: 2 }
        ListElement { q: "Nchi ya kwanza kuweka demokrasia ya kisasa ilikuwa?"; a: "Roma ya kale"; b: "Ugiriki wa kale (Athens)"; c: "Uingereza"; d: "Marekani"; correct: "Ugiriki wa kale (Athens)"; cat: "H"; diff: 2 }
        ListElement { q: "Sera ya ukoloni ya Ujerumani Tanzania (Tanganyika) iliisha mwaka gani?"; a: "1914"; b: "1916"; c: "1918"; d: "1920"; correct: "1918"; cat: "H"; diff: 2 }
        ListElement { q: "Mji wa Constantinople wa kale sasa unaitwa?"; a: "Ankara"; b: "Athens"; c: "Istanbul"; d: "Beirut"; correct: "Istanbul"; cat: "H"; diff: 2 }
        ListElement { q: "Vita vya Kagera viliisha mwaka gani baada ya Tanzania kumshinda Idi Amin?"; a: "1978"; b: "1979"; c: "1980"; d: "1981"; correct: "1979"; cat: "H"; diff: 2 }

        // MICHEZO (+18) — hadi 58 jumla
        ListElement { q: "Mchezo wa Badminton unachezwa kwa kutumia?"; a: "Mpira wa mviringo"; b: "Shuttlecock (manyoya)"; c: "Mpira wa kikapu"; d: "Mpira laini"; correct: "Shuttlecock (manyoya)"; cat: "SP"; diff: 1 }
        ListElement { q: "Klabu ya Liverpool inacheza uwanjani gani?"; a: "Old Trafford"; b: "Etihad Stadium"; c: "Anfield"; d: "Stamford Bridge"; correct: "Anfield"; cat: "SP"; diff: 1 }
        ListElement { q: "Mbio za 5000m na 10000m ni mbio za aina gani?"; a: "Sprint"; b: "Middle distance"; c: "Long distance"; d: "Marathon"; correct: "Long distance"; cat: "SP"; diff: 2 }
        ListElement { q: "Nchi gani imeshinda Kombe la Afrika (AFCON) mara nyingi zaidi?"; a: "Nigeria"; b: "Egypt"; c: "Ghana"; d: "Cameroon"; correct: "Egypt"; cat: "SP"; diff: 3 }
        ListElement { q: "Samba ya FIFA World Cup inapiganwa kila miaka 4 — ilianzishwa mwaka gani?"; a: "1924"; b: "1928"; c: "1930"; d: "1934"; correct: "1930"; cat: "SP"; diff: 2 }
        ListElement { q: "Mchezo wa formula 1 unashindana kwa nini?"; a: "Baiskeli"; b: "Magari ya mbio"; c: "Meli"; d: "Ndege"; correct: "Magari ya mbio"; cat: "SP"; diff: 1 }
        ListElement { q: "Rekodi ya dunia ya mbio za mita 100 inashikiliwa na nani?"; a: "Carl Lewis"; b: "Asafa Powell"; c: "Usain Bolt"; d: "Yohan Blake"; correct: "Usain Bolt"; cat: "SP"; diff: 1 }
        ListElement { q: "Mpira wa rugby wenye umbo la yai unaitwa?"; a: "Spherical ball"; b: "Oval ball"; c: "Round ball"; d: "Flat ball"; correct: "Oval ball"; cat: "SP"; diff: 2 }
        ListElement { q: "Mchezaji wa kwanza wa Afrika kushinda Ballon d'Or (Golden Ball) alikuwa?"; a: "Samuel Eto'o"; b: "Didier Drogba"; c: "George Weah"; d: "Michael Essien"; correct: "George Weah"; cat: "SP"; diff: 3 }
        ListElement { q: "Wimbledon ni mashindano ya mchezo gani?"; a: "Golf"; b: "Tenisi"; c: "Squash"; d: "Badminton"; correct: "Tenisi"; cat: "SP"; diff: 1 }
        ListElement { q: "Mchezo wa Boxing una raundi za dakika ngapi kila moja?"; a: "2 dakika"; b: "3 dakika"; c: "4 dakika"; d: "5 dakika"; correct: "3 dakika"; cat: "SP"; diff: 2 }
        ListElement { q: "Timu ya taifa ya Afrika Kusini ya rugby inajulikana kwa jina gani?"; a: "Springboks"; b: "All Blacks"; c: "Wallabies"; d: "Lions"; correct: "Springboks"; cat: "SP"; diff: 2 }
        ListElement { q: "Mchezo wa Sumo ni mchezo wa mapigano wa nchi gani?"; a: "China"; b: "Korea"; c: "Japan"; d: "Mongolia"; correct: "Japan"; cat: "SP"; diff: 1 }
        ListElement { q: "Michezo ya Paralympic inashughulika na watu wa aina gani?"; a: "Vijana tu"; b: "Wazee tu"; c: "Walemavu"; d: "Wanawake tu"; correct: "Walemavu"; cat: "SP"; diff: 1 }
        ListElement { q: "Nchi gani imeshinda medali nyingi zaidi katika historia ya Olimpiki?"; a: "China"; b: "Urusi"; c: "Marekani"; d: "Uingereza"; correct: "Marekani"; cat: "SP"; diff: 2 }
        ListElement { q: "Kombe la dunia la rugby (Rugby World Cup) hufanyika kila baada ya miaka mingapi?"; a: "2"; b: "3"; c: "4"; d: "5"; correct: "4"; cat: "SP"; diff: 2 }
        ListElement { q: "Mchezo wa cricket unaochezwa ndani ya masaa 20 upande mmoja unaitwa?"; a: "Test cricket"; b: "One Day International"; c: "T20"; d: "T10"; correct: "T20"; cat: "SP"; diff: 2 }
        ListElement { q: "Mchezaji maarufu wa basketball Michael Jordan alicheza kwa klabu gani?"; a: "LA Lakers"; b: "Chicago Bulls"; c: "Miami Heat"; d: "Boston Celtics"; correct: "Chicago Bulls"; cat: "SP"; diff: 2 }

        // TEKNOLOJIA (+18)
        ListElement { q: "Lugha ya programu Python ilitengenezwa na nani?"; a: "Dennis Ritchie"; b: "Guido van Rossum"; c: "James Gosling"; d: "Brendan Eich"; correct: "Guido van Rossum"; cat: "TK"; diff: 3 }
        ListElement { q: "GPS inafanya kazi kwa kutumia satelaiti ngapi angani?"; a: "12"; b: "18"; c: "24"; d: "30"; correct: "24"; cat: "TK"; diff: 3 }
        ListElement { q: "Kompyuta ya kwanza duniani ilitengenezwa miaka gani?"; a: "Miaka ya 1920"; b: "Miaka ya 1940"; c: "Miaka ya 1960"; d: "Miaka ya 1980"; correct: "Miaka ya 1940"; cat: "TK"; diff: 2 }
        ListElement { q: "App inayotumiwa zaidi duniani kwa piga simu za video ni?"; a: "Skype"; b: "Zoom"; c: "WhatsApp"; d: "FaceTime"; correct: "WhatsApp"; cat: "TK"; diff: 1 }
        ListElement { q: "Neno 'Algorithm' katika kompyuta linamaanisha?"; a: "Lugha ya kompyuta"; b: "Mfumo wa hatua za kutatua tatizo"; c: "Aina ya programu"; d: "Hifadhi ya data"; correct: "Mfumo wa hatua za kutatua tatizo"; cat: "TK"; diff: 2 }
        ListElement { q: "Simu ya kwanza ya kisasa (smartphone) yenye touchscreen ilitengenezwa na?"; a: "Samsung"; b: "Nokia"; c: "Apple (iPhone)"; d: "Motorola"; correct: "Apple (iPhone)"; cat: "TK"; diff: 2 }
        ListElement { q: "Bandwidth ya intaneti inapimwa kwa?"; a: "Megapixels"; b: "Megabytes per second (Mbps)"; c: "Megahertz"; d: "Megawatts"; correct: "Megabytes per second (Mbps)"; cat: "TK"; diff: 2 }
        ListElement { q: "Blockchain technology inatumika hasa kwa?"; a: "Kupiga picha"; b: "Kuhifadhi rekodi za muamala zinazolindwa"; c: "Kutuma barua pepe"; d: "Kufanya kazi za ofisi"; correct: "Kuhifadhi rekodi za muamala zinazolindwa"; cat: "TK"; diff: 3 }
        ListElement { q: "VPN inasaidia kufanya nini?"; a: "Kuongeza kasi ya intaneti"; b: "Kulinda faragha na kubadilisha eneo lako la mtandaoni"; c: "Kurekebisha virusi"; d: "Kuhifadhi picha"; correct: "Kulinda faragha na kubadilisha eneo lako la mtandaoni"; cat: "TK"; diff: 2 }
        ListElement { q: "App store ya Android inaitwa?"; a: "Apple Store"; b: "Microsoft Store"; c: "Google Play Store"; d: "Samsung Store"; correct: "Google Play Store"; cat: "TK"; diff: 1 }
        ListElement { q: "Kifupi cha URL kinamaanisha nini?"; a: "Universal Resource Locator"; b: "Uniform Resource Locator"; c: "United Resource Link"; d: "Universal Reference Link"; correct: "Uniform Resource Locator"; cat: "TK"; diff: 3 }
        ListElement { q: "Nani alianzisha kampuni ya Tesla?"; a: "Bill Gates"; b: "Jeff Bezos"; c: "Elon Musk"; d: "Mark Zuckerberg"; correct: "Elon Musk"; cat: "TK"; diff: 1 }
        ListElement { q: "USB-C inafanya nini tofauti na USB-A?"; a: "Ni ndogo na inaweza kupigwa upande wowote"; b: "Ni kubwa zaidi"; c: "Inafanya kazi polepole"; d: "Inafanya kazi na simu tu"; correct: "Ni ndogo na inaweza kupigwa upande wowote"; cat: "TK"; diff: 2 }
        ListElement { q: "Neno 'Open Source' katika programu linamaanisha?"; a: "Programu inayolipiwa"; b: "Msimbo wa programu unaoweza kuonekana na kubadilishwa na wote"; c: "Programu ya serikali"; d: "Programu ya wazi kwa watoto"; correct: "Msimbo wa programu unaoweza kuonekana na kubadilishwa na wote"; cat: "TK"; diff: 2 }
        ListElement { q: "Kamera ya simu inayopiga picha za nyuma ya simu inaitwa?"; a: "Front camera"; b: "Selfie camera"; c: "Rear camera"; d: "Wide camera"; correct: "Rear camera"; cat: "TK"; diff: 1 }
        ListElement { q: "RAM nyingi zaidi kwenye simu au kompyuta inasaidia?"; a: "Picha bora"; b: "Betri kudumu zaidi"; c: "Kufanya kazi nyingi kwa wakati mmoja (multitasking)"; d: "Uunganisho wa mtandao"; correct: "Kufanya kazi nyingi kwa wakati mmoja (multitasking)"; cat: "TK"; diff: 2 }
        ListElement { q: "Neno 'Streaming' linamaanisha nini katika teknolojia?"; a: "Kupakua faili kubwa"; b: "Kutazama au kusikiliza maudhui mtandaoni moja kwa moja"; c: "Kuhifadhi data"; d: "Kufuta data"; correct: "Kutazama au kusikiliza maudhui mtandaoni moja kwa moja"; cat: "TK"; diff: 1 }
        ListElement { q: "Kampuni ya Amazon ilianzishwa kufanya nini mwanzoni?"; a: "Kutengeneza programu"; b: "Kuuza vitabu mtandaoni"; c: "Kufanya vifaa vya umeme"; d: "Kutengeneza simu"; correct: "Kuuza vitabu mtandaoni"; cat: "TK"; diff: 2 }

        // HISABATI (+18)
        ListElement { q: "Pi (π) ni thamani gani takriban?"; a: "3.14"; b: "2.71"; c: "1.41"; d: "4.13"; correct: "3.14"; cat: "M"; diff: 1 }
        ListElement { q: "Eneo la duara lenye radius ya 7 cm ni? (π = 22/7)"; a: "22 cm²"; b: "44 cm²"; c: "154 cm²"; d: "308 cm²"; correct: "154 cm²"; cat: "M"; diff: 2 }
        ListElement { q: "√169 ni sawa na?"; a: "11"; b: "12"; c: "13"; d: "14"; correct: "13"; cat: "M"; diff: 2 }
        ListElement { q: "Kama bei inaongezeka kwa 50% na kisha kupungua kwa 50%, matokeo yake ni?"; a: "Sawa na mwanzo"; b: "Chini ya mwanzo kwa 25%"; c: "Juu ya mwanzo kwa 25%"; d: "Chini ya mwanzo kwa 50%"; correct: "Chini ya mwanzo kwa 25%"; cat: "M"; diff: 3 }
        ListElement { q: "Thamani ya 2³ + 3² ni?"; a: "13"; b: "17"; c: "19"; d: "21"; correct: "17"; cat: "M"; diff: 2 }
        ListElement { q: "Kama pembe mbili za pembetatu ni 45° na 65°, pembe ya tatu ni?"; a: "60°"; b: "70°"; c: "75°"; d: "80°"; correct: "70°"; cat: "M"; diff: 2 }
        ListElement { q: "Nambari hasi mara nambari hasi inatoa jibu?"; a: "Hasi"; b: "Chanya (positive)"; c: "Sifuri"; d: "Inategemea"; correct: "Chanya (positive)"; cat: "M"; diff: 2 }
        ListElement { q: "Mfululizo wa Fibonacci unaanza hivi: 0, 1, 1, 2, 3, 5, 8 — nambari ya 10 ni?"; a: "29"; b: "34"; c: "39"; d: "43"; correct: "34"; cat: "M"; diff: 3 }
        ListElement { q: "Kama duka linapata faida ya 30% kwenye bidhaa iliyonunuliwa kwa 7,000, bei ya kuuza ni?"; a: "9,000"; b: "9,100"; c: "9,500"; d: "10,000"; correct: "9,100"; cat: "M"; diff: 2 }
        ListElement { q: "Pembetatu yenye pembe zote 60° inaitwa?"; a: "Isosceles"; b: "Scalene"; c: "Right angle"; d: "Equilateral"; correct: "Equilateral"; cat: "M"; diff: 2 }
        ListElement { q: "Kama kiwango cha riba ni 5% kwa mwaka na umeweka 10,000 kwa miaka 2, riba rahisi ni?"; a: "500"; b: "1,000"; c: "1,500"; d: "2,000"; correct: "1,000"; cat: "M"; diff: 2 }
        ListElement { q: "Hesabu ya 15% ya 2,400 ni?"; a: "280"; b: "320"; c: "360"; d: "400"; correct: "360"; cat: "M"; diff: 1 }
        ListElement { q: "Kama mstatili una eneo la 48 cm² na urefu wa 8 cm, upana wake ni?"; a: "4 cm"; b: "5 cm"; c: "6 cm"; d: "7 cm"; correct: "6 cm"; cat: "M"; diff: 2 }
        ListElement { q: "Jumla ya pembe za nyota ya pointi 5 (pentagram) ni?"; a: "360°"; b: "540°"; c: "720°"; d: "900°"; correct: "180°"; cat: "M"; diff: 3 }
        ListElement { q: "Kama gari linasafiri km 120 kwa saa 2, litachukua muda gani kusafiri km 300?"; a: "3.5 saa"; b: "4 saa"; c: "4.5 saa"; d: "5 saa"; correct: "5 saa"; cat: "M"; diff: 2 }
        ListElement { q: "Nambari inayoitwa 'kamili' (perfect number) kwa sababu jumla ya vigawanyo vyake ni sawa nayo ni?"; a: "6"; b: "8"; c: "10"; d: "12"; correct: "6"; cat: "M"; diff: 3 }
        ListElement { q: "Kiwango cha wastani cha darasa la wanafunzi 5 wenye alama: 70, 85, 90, 60, 95 ni?"; a: "78"; b: "80"; c: "82"; d: "85"; correct: "80"; cat: "M"; diff: 2 }
        ListElement { q: "Kama n = 4, thamani ya n² + 2n + 1 ni?"; a: "21"; b: "24"; c: "25"; d: "28"; correct: "25"; cat: "M"; diff: 2 }

        // GEO (+18)
        ListElement { q: "Mji mkuu wa Kenya ni?"; a: "Mombasa"; b: "Kisumu"; c: "Nairobi"; d: "Nakuru"; correct: "Nairobi"; cat: "GEO"; diff: 1 }
        ListElement { q: "Mlima mrefu zaidi Afrika ni?"; a: "Mlima Kenya"; b: "Mlima Kilimanjaro"; c: "Mlima Cameroon"; d: "Mlima Atlas"; correct: "Mlima Kilimanjaro"; cat: "GEO"; diff: 1 }
        ListElement { q: "Jangwa kubwa zaidi duniani ni?"; a: "Kalahari"; b: "Gobi"; c: "Sahara"; d: "Arabian"; correct: "Sahara"; cat: "GEO"; diff: 1 }
        ListElement { q: "Mto mrefu zaidi duniani ni?"; a: "Amazon"; b: "Nile"; c: "Congo"; d: "Yangtze"; correct: "Nile"; cat: "GEO"; diff: 1 }
        ListElement { q: "Nchi ya Kenya inapakana na Tanzania upande gani?"; a: "Kaskazini"; b: "Kusini"; c: "Mashariki"; d: "Magharibi"; correct: "Kusini"; cat: "GEO"; diff: 1 }
        ListElement { q: "Bahari inayozunguka Tanzania upande wa mashariki ni?"; a: "Bahari ya Atlantiki"; b: "Bahari ya Hindi"; c: "Bahari ya Pasifiki"; d: "Bahari ya Kaskazini"; correct: "Bahari ya Hindi"; cat: "GEO"; diff: 1 }
        ListElement { q: "Nchi kubwa zaidi barani Afrika ni?"; a: "Sudan"; b: "Congo DRC"; c: "Algeria"; d: "Libya"; correct: "Algeria"; cat: "GEO"; diff: 2 }
        ListElement { q: "Ziwa la chumvi kubwa zaidi Afrika ni?"; a: "Ziwa Turkana"; b: "Ziwa Natron"; c: "Ziwa Manyara"; d: "Ziwa Assal"; correct: "Ziwa Assal"; cat: "GEO"; diff: 3 }
        ListElement { q: "Dar es Salaam inamaanisha nini kwa Kiarabu?"; a: "Bandari ya Amani"; b: "Mji wa Dhahabu"; c: "Nyumba ya Amani"; d: "Nchi ya Amani"; correct: "Bandari ya Amani"; cat: "GEO"; diff: 2 }
        ListElement { q: "Wilaya gani ya Tanzania ina mpaka mrefu zaidi na Msumbiji?"; a: "Mtwara"; b: "Songea"; c: "Tunduru"; d: "Lindi"; correct: "Tunduru"; cat: "GEO"; diff: 3 }
        ListElement { q: "Mji wa Arusha uko urefu wa mita ngapi juu ya usawa wa bahari?"; a: "800m"; b: "1,400m"; c: "2,000m"; d: "2,500m"; correct: "1,400m"; cat: "GEO"; diff: 3 }
        ListElement { q: "Ziwa Victoria ni ziwa la ngapi kwa ukubwa duniani?"; a: "La kwanza"; b: "La pili"; c: "La tatu"; d: "La nne"; correct: "La pili"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mkoa gani wa Tanzania hauna mpaka na nchi nyingine?"; a: "Kagera"; b: "Dodoma"; c: "Mara"; d: "Kigoma"; correct: "Dodoma"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mji wa Pemba (kaskazini mwa Mozambique) upo nchi gani?"; a: "Tanzania"; b: "Msumbiji"; c: "Malawi"; d: "Zambia"; correct: "Msumbiji"; cat: "GEO"; diff: 2 }
        ListElement { q: "Bonde la Ufa (Great Rift Valley) linapita Tanzania na kuathiri nini?"; a: "Hali ya hewa tu"; b: "Kuumba maziwa, mabonde na milima"; c: "Uzalishaji wa mazao"; d: "Mifumo ya maji ya bahari"; correct: "Kuumba maziwa, mabonde na milima"; cat: "GEO"; diff: 2 }
        ListElement { q: "Mkoa wa Shinyanga unajulikana kwa nini?"; a: "Uvuvi wa ziwa"; b: "Almasi na pamba"; c: "Utalii wa wanyama"; d: "Kahawa"; correct: "Almasi na pamba"; cat: "GEO"; diff: 1 }
        ListElement { q: "Kisiwa kikubwa zaidi Afrika ni?"; a: "Zanzibar"; b: "Madagascar"; c: "Comoros"; d: "Reunion"; correct: "Madagascar"; cat: "GEO"; diff: 1 }
        ListElement { q: "Nchi gani iko kaskazini kabisa barani Afrika?"; a: "Libya"; b: "Tunisia"; c: "Morocco"; d: "Egypt"; correct: "Tunisia"; cat: "GEO"; diff: 3 }

        // MAZINGIRA (+18)
        ListElement { q: "Tabaka la ozoni linalolinda Dunia lipo wapi angani?"; a: "Troposphere"; b: "Stratosphere"; c: "Mesosphere"; d: "Thermosphere"; correct: "Stratosphere"; cat: "MK"; diff: 3 }
        ListElement { q: "Mti mrefu zaidi duniani ni aina gani?"; a: "Oak"; b: "Sequoia (Redwood)"; c: "Eucalyptus"; d: "Pine"; correct: "Sequoia (Redwood)"; cat: "MK"; diff: 3 }
        ListElement { q: "Mwaka gani Mkataba wa Paris wa hali ya hewa ulisainiwa?"; a: "2010"; b: "2012"; c: "2015"; d: "2018"; correct: "2015"; cat: "MK"; diff: 2 }
        ListElement { q: "Nishati ya umeme inayotokana na mvuke wa ardhi (geothermal) inapatikana Tanzania wapi?"; a: "Kilimanjaro"; b: "Serengeti"; c: "Bonde la Ufa (Olkaria/Mbeya)"; d: "Zanzibar"; correct: "Bonde la Ufa (Olkaria/Mbeya)"; cat: "MK"; diff: 3 }
        ListElement { q: "Kusafisha hewa ndani ya nyumba kwa mimea ni kweli — mmea gani mzuri zaidi?"; a: "Nyasi"; b: "Aloe Vera na Peace Lily"; c: "Cactus"; d: "Rose"; correct: "Aloe Vera na Peace Lily"; cat: "MK"; diff: 3 }
        ListElement { q: "Methane (CH4) ni gesi ya greenhouse inayotoka wapi Tanzania?"; a: "Magari tu"; b: "Mifugo (ng'ombe) na maeneo ya mvua"; c: "Viwanda tu"; d: "Meli za bahari"; correct: "Mifugo (ng'ombe) na maeneo ya mvua"; cat: "MK"; diff: 3 }
        ListElement { q: "Mto Amazon (Brazil) unazalisha asilimia ngapi ya oksijeni ya dunia?"; a: "10%"; b: "15%"; c: "20%"; d: "30%"; correct: "20%"; cat: "MK"; diff: 3 }
        ListElement { q: "Mfumo wa kilimo endelevu unaochanganya samaki na mimea (fish + plants) unaitwa?"; a: "Hydroponics"; b: "Aquaponics"; c: "Aeroponics"; d: "Permaculture"; correct: "Aquaponics"; cat: "MK"; diff: 3 }
        ListElement { q: "Siku ya Dunia ya Miti (World Tree Day) huadhimishwa lini?"; a: "Machi 21"; b: "Juni 5"; c: "Aprili 22"; d: "Julai 28"; correct: "Machi 21"; cat: "MK"; diff: 3 }
        ListElement { q: "Mabadiliko ya tabianchi yanaweza kusababisha kupanda kwa usawa wa bahari — hii inaathiri nini Tanzania?"; a: "Milima tu"; b: "Visiwa vidogo na maeneo ya pwani"; c: "Jangwa"; d: "Msitu wa milima"; correct: "Visiwa vidogo na maeneo ya pwani"; cat: "MK"; diff: 2 }
        ListElement { q: "Kilimo cha 'permaculture' kinamaanisha nini?"; a: "Kilimo cha mazao makubwa"; b: "Mfumo wa kudumu wa kilimo unaoigwa kutoka asili"; c: "Kilimo cha kemikali nyingi"; d: "Kilimo cha muda mfupi"; correct: "Mfumo wa kudumu wa kilimo unaoigwa kutoka asili"; cat: "MK"; diff: 3 }
        ListElement { q: "Taka za plastiki zinachukua muda gani kuoza kabisa?"; a: "Miaka 10-20"; b: "Miaka 50-100"; c: "Miaka 400-1000"; d: "Kamwe haziozi"; correct: "Miaka 400-1000"; cat: "MK"; diff: 2 }
        ListElement { q: "Nguvu ya mawimbi ya bahari (wave energy) inaweza kutumika kuzalisha?"; a: "Chakula"; b: "Umeme"; c: "Mafuta"; d: "Maji safi"; correct: "Umeme"; cat: "MK"; diff: 2 }
        ListElement { q: "Nini maana ya 'carbon footprint' katika mazingira?"; a: "Alama ya mguu kwenye mchanga"; b: "Kiasi cha CO2 kinachozalishwa na shughuli za mtu au shirika"; c: "Aina ya mazao"; d: "Aina ya nishati"; correct: "Kiasi cha CO2 kinachozalishwa na shughuli za mtu au shirika"; cat: "MK"; diff: 2 }
        ListElement { q: "Upandaji wa miti wa 'The Great Green Wall' unalenga kupambana na tatizo gani Afrika?"; a: "Ukosefu wa maji ya kunywa"; b: "Kuzuia kuenea kwa Jangwa la Sahara"; c: "Kuzalisha chakula zaidi"; d: "Kulinda wanyama"; correct: "Kuzuia kuenea kwa Jangwa la Sahara"; cat: "MK"; diff: 2 }
        ListElement { q: "Biogas inayozalishwa kutoka taka za mifugo inaweza kutumika kwa nini?"; a: "Kupiga picha"; b: "Kupika na kutoa mwanga"; c: "Kutengeneza plastiki"; d: "Kumwagilia maji"; correct: "Kupika na kutoa mwanga"; cat: "MK"; diff: 1 }
        ListElement { q: "Mfumo wa hali ya hewa wa 'monsoon' una athari gani Tanzania?"; a: "Huleta baridi kali"; b: "Huleta mvua za masika na mwelekeo wa upepo wa bahari"; c: "Husababisha dhoruba za radi tu"; d: "Hauna athari Tanzania"; correct: "Huleta mvua za masika na mwelekeo wa upepo wa bahari"; cat: "MK"; diff: 2 }
        ListElement { q: "Hifadhi ya kibayolojia (biodiversity hotspot) kubwa zaidi Afrika Mashariki ipo wapi?"; a: "Serengeti"; b: "Msitu wa Albertine Rift"; c: "Bonde la Ngorongoro"; d: "Ziwa Tanganyika"; correct: "Msitu wa Albertine Rift"; cat: "MK"; diff: 3 }

    }

    // Hifadhi maswali yaliyoulizwa — data ni array ya maswali (q strings)
    Settings {
        id: askedQuestions
        property var data: []

        function add(q) {
            if (!data) data = [];
            var arr = data.slice();
            arr.push(q);
            data = arr;
        }

        function has(q) {
            if (!data) return false;
            return data.indexOf(q) !== -1;
        }

        // Futa historia yote — maswali yote yatakuwa mapya tena
        function restoreAndReset() {
            data = [];
        }

        Component.onDestruction: setValue("data", data);
    }

    function shuffleOptions(a, b, c, d) {
        var opts = [a, b, c, d];
        for (var i = opts.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var temp = opts[i];
            opts[i] = opts[j];
            opts[j] = temp;
        }
        return opts;
    }


    function startNewGame() {
        quizModel.clear();

        var totalCount = iqModel.count;
        var cats = selectedCategories.length === 0
            ? ["S","M","SP","TK","H","A","V","GEO","UR","MK","BUR","UT","LG"]
            : selectedCategories.slice();

        var shuffleArray = function(arr) {
            for (var x = arr.length - 1; x > 0; x--) {
                var y = Math.floor(Math.random() * (x + 1));
                var tmp = arr[x]; arr[x] = arr[y]; arr[y] = tmp;
            }
        };

        // --- Hatua 1: Kusanya pool ya kila mada (hayajaulizwa) ---
        var poolByCat = {};
        for (var ci = 0; ci < cats.length; ci++) {
            var cat = cats[ci];
            var pool = [];
            for (var i = 0; i < totalCount; i++) {
                var item = iqModel.get(i);
                var diffOk = (selectedDifficulty === 0) || (item.diff === selectedDifficulty);
                if (item.cat === cat && diffOk && !askedQuestions.has(item.q))
                    pool.push(i);
            }
            poolByCat[cat] = pool;
        }

        // --- Hatua 2: Kwa kila mada iliyokwisha (pool=0), futa historia YAKE tu ---
        //     Fanya kwa kumark maswali ya mada hiyo kama "safi" kwenye hesabu yetu
        //     (restoreAndReset inafuta historia yote — tunabadilisha approach)
        //     Angalia kama kuna mada yoyote iliyokwisha:
        var anyCatEmpty = false;
        for (var ce = 0; ce < cats.length; ce++) {
            if (poolByCat[cats[ce]].length === 0) { anyCatEmpty = true; break; }
        }
        if (anyCatEmpty) {
            // Futa historia yote — rahisi zaidi na salama
            // (kwa sababu hatuna per-cat history)
            askedQuestions.restoreAndReset();
            // Jaza upya pool zote
            for (var ci2 = 0; ci2 < cats.length; ci2++) {
                var cat2 = cats[ci2];
                var pool2 = [];
                for (var j = 0; j < totalCount; j++) {
                    var jItem = iqModel.get(j);
                    var jDiffOk = (selectedDifficulty === 0) || (jItem.diff === selectedDifficulty);
                    if (jItem.cat === cat2 && jDiffOk) pool2.push(j);
                }
                poolByCat[cat2] = pool2;
            }
        }

        // --- Hatua 3: Allocation ya usawa ---
        var target = 26;
        var numCats = cats.length;
        var base = Math.floor(target / numCats);
        var extra = target % numCats;

        var catsShuffled = cats.slice();
        shuffleArray(catsShuffled);

        // Panga allocation — kama mada ina maswali machache, allocation yake ni ndogo
        // Overflow (kutoka mada yenye maswali machache) inagawanywa kwa mada nyingine
        var allocation = {};
        for (var ai = 0; ai < catsShuffled.length; ai++) {
            allocation[catsShuffled[ai]] = base + (ai < extra ? 1 : 0);
        }

        // Rekebisha allocation: kama mada ina maswali machache kuliko allocation,
        // punguza allocation yake na ongeza overflow kwenye mada nyingine
        var overflow = 0;
        for (var oi = 0; oi < cats.length; oi++) {
            var oCat = cats[oi];
            if (poolByCat[oCat].length < allocation[oCat]) {
                overflow += allocation[oCat] - poolByCat[oCat].length;
                allocation[oCat] = poolByCat[oCat].length;
            }
        }
        // Gawanya overflow kwa mada zenye uwezo wa kupokea zaidi
        if (overflow > 0) {
            for (var oi2 = 0; oi2 < cats.length && overflow > 0; oi2++) {
                var oCat2 = cats[oi2];
                var canTake = poolByCat[oCat2].length - allocation[oCat2];
                if (canTake > 0) {
                    var give = Math.min(canTake, overflow);
                    allocation[oCat2] += give;
                    overflow -= give;
                }
            }
        }

        // --- Hatua 4: Chagua maswali kwa kila mada ---
        var selectedByCat = {};
        var usedIndexes = {};  // kuhakikisha hakuna index kurudiwa
        for (var si = 0; si < cats.length; si++) {
            var sCat = cats[si];
            var sPool = poolByCat[sCat].slice();
            shuffleArray(sPool);
            var taken = [];
            for (var ti = 0; ti < sPool.length && taken.length < allocation[sCat]; ti++) {
                var idx = sPool[ti];
                if (!usedIndexes[idx]) {
                    taken.push(idx);
                    usedIndexes[idx] = true;
                }
            }
            selectedByCat[sCat] = taken;
        }

        // --- Hatua 5: Interleave (round-robin) ---
        var finalIndexes = [];
        var catQueues = [];
        for (var qi = 0; qi < cats.length; qi++) {
            if (selectedByCat[cats[qi]].length > 0)
                catQueues.push(selectedByCat[cats[qi]].slice());
        }
        shuffleArray(catQueues);

        var going = true;
        while (going && finalIndexes.length < target) {
            going = false;
            for (var ri = 0; ri < catQueues.length; ri++) {
                if (catQueues[ri].length > 0 && finalIndexes.length < target) {
                    finalIndexes.push(catQueues[ri].shift());
                    going = true;
                }
            }
        }

        if (finalIndexes.length === 0) { viewState = "START"; return; }

        // --- Hatua 6: Weka kwenye quizModel (hakikisha hakuna swali kurudiwa) ---
        var addedQs = {};
        for (var m = 0; m < finalIndexes.length; m++) {
            var qItem = iqModel.get(finalIndexes[m]);
            if (!addedQs[qItem.q]) {
                quizModel.append(qItem);
                askedQuestions.add(qItem.q);
                addedQs[qItem.q] = true;
            }
        }

        // --- Hatua 7: Weka muda, reset variables, anza ---
        if      (selectedDifficulty === 1) timeInterval = 30;
        else if (selectedDifficulty === 3) timeInterval = 10;
        else                               timeInterval = 20;

        maxQuestions = quizModel.count;
        currentIdx = 0;
        totalScore = 0;
        timerValue = timeInterval;
        noOfPassedQuestion = 0;
        answerResult = "";
        selectedAnswer = "";
        questionsAttempted = maxQuestions;
        speedBonusTotal = 0;
        lastSpeedBonus = 0;
        skippedQuestions = 0;
        isNewHighscore = false;
        currentStreak = 0;
        maxStreak = 0;
        streakMultiplier = 1.0;
        earnedBadges = [];
        if (!isTimeAttack) {
            timeAttackScore = 0;
        }
        userAnswers.clear();

        viewState = "QUIZ";
        mainTimer.start();
        if (isTimeAttack) timeAttackTimer.start();
    }


    // Hii ndio model itakayotumika kwenye mchezo (Maswali 26 tu)
    ListModel { id: quizModel }

    // --- LOGIC ---
    Timer {
        id: mainTimer
        interval: 1000; repeat: true
        onTriggered: {
            if (timerValue > 0) {
                timerValue--;
            } else {
                mainTimer.stop();
                // Timeout: rekodi kama jibu la makosa bila chaguo
                var correctAns = quizModel.get(currentIdx).correct;
                userAnswers.append({
                    "q":          quizModel.get(currentIdx).q,
                    "correct":    correctAns,
                    "chosen":     "",
                    "wasCorrect": false
                });
                answerResult = "wrong";
                selectedAnswer = "";
                lastSpeedBonus = 0;
                feedbackTimer.start();
            }
        }
    }

    function processAnswer(selected) {
        if (answerResult !== "") return; // block double-tap during feedback
        mainTimer.stop();
        selectedAnswer = selected;
        var correctAns = quizModel.get(currentIdx).correct;
        var wasRight = (selected !== "" && selected === correctAns);
        if (wasRight) {
            // Streak logic
            currentStreak++;
            if (currentStreak > maxStreak) maxStreak = currentStreak;
            if      (currentStreak >= 6) streakMultiplier = 3.0;
            else if (currentStreak >= 4) streakMultiplier = 2.0;
            else if (currentStreak >= 2) streakMultiplier = 1.5;
            else                          streakMultiplier = 1.0;

            var base  = 10;
            var bonus = timerValue * 3;
            var streakBonus = Math.round((base + bonus) * (streakMultiplier - 1.0));
            totalScore += base + bonus + streakBonus;
            speedBonusTotal += bonus;
            lastSpeedBonus = bonus;
            ++app.noOfPassedQuestion;
            if (isTimeAttack) timeAttackScore++;
            answerResult = "correct";
        } else {
            currentStreak = 0;
            streakMultiplier = 1.0;
            lastSpeedBonus = 0;
            answerResult = "wrong";
        }
        // Hifadhi rekodi ya swali hili
        userAnswers.append({
            "q":          quizModel.get(currentIdx).q,
            "correct":    correctAns,
            "chosen":     selected,
            "wasCorrect": wasRight
        });
        feedbackTimer.start();
    }

    function advanceQuestion() {
        answerResult = "";
        selectedAnswer = "";
        if (isTimeAttack) {
            // Time Attack — endelea na swali jipya bila mwisho hadi muda uishe
            if (timeAttackRemaining > 0) {
                // Chagua swali jipya random kutoka quizModel
                if (quizModel.count > 1) {
                    var next = (currentIdx + 1 + Math.floor(Math.random() * (quizModel.count - 1))) % quizModel.count;
                    currentIdx = next;
                }
                timerValue = timeInterval;
                mainTimer.start();
            }
        } else if (currentIdx < quizModel.count - 1) {
            currentIdx++;
            timerValue = timeInterval;
            mainTimer.start();
        } else {
            questionsAttempted = quizModel.count;
            highscoreCheckTimer.start();
            viewState = "END";
            app.ad();
        }
    }

    Timer {
        id: highscoreCheckTimer
        interval: 200; repeat: false
        onTriggered: {
            var iq = calculateFinalIQ();
            if (iq > highscoreSettings.bestIQ) {
                highscoreSettings.bestIQ = iq;
                isNewHighscore = true;
            }
            // Hesabu badges
            var badges = [];
            var total = maxQuestions;
            var correct = noOfPassedQuestion;
            if (total > 0 && correct === total)
                badges.push({ icon: "\ud83c\udfc6", name: "Mkamilifu",  desc: "Maswali yote sahihi!" });
            if (maxStreak >= 5)
                badges.push({ icon: "\ud83d\udd25", name: "Mfalme wa Mfululizo",    desc: "Sahihi " + maxStreak + " mfululizo!" });
            if (iq >= 130)
                badges.push({ icon: "\ud83d\udcda", name: "Msomi",        desc: "IQ " + iq + " — Akili ya hali ya juu!" });
            if (speedBonusTotal >= 200)
                badges.push({ icon: "\u26a1",         name: "Mwepesi",   desc: "Ulijibu kwa kasi ya ajabu!" });
            if (isTimeAttack && timeAttackScore >= 15)
                badges.push({ icon: "\u23f1",         name: "Bingwa wa Muda", desc: "Maswali " + timeAttackScore + " kwa dakika 2!" });
            earnedBadges = badges;
        }
    }

    Timer {
        id: feedbackTimer
        interval: 1200; repeat: false
        onTriggered: advanceQuestion()
    }

    // Time Attack countdown (inaendesha parallel na mainTimer wakati wa TA)
    Timer {
        id: timeAttackTimer
        interval: 1000; repeat: true
        onTriggered: {
            if (timeAttackRemaining > 1) {
                timeAttackRemaining--;
            } else {
                timeAttackRemaining = 0;
                timeAttackTimer.stop();
                mainTimer.stop();
                feedbackTimer.stop();
                // Muda uliisha — nenda END
                questionsAttempted = userAnswers.count;
                skippedQuestions = 0;
                highscoreCheckTimer.start();
                viewState = "END";
                app.ad();
            }
        }
    }


    // ═══════════════════════════════════════════════════════════════
    // UI REDESIGN — Premium dark African sci-fi aesthetic
    // Colours: deep space bg, cyan accent, white text
    // ═══════════════════════════════════════════════════════════════

    readonly property color bg0:      "#020d0d"
    readonly property color bg1:      "#031515"
    readonly property color bg2:      "#061c1c"
    readonly property color card:     "#071e1e"
    readonly property color gold:     "#00e5ff"
    readonly property color goldDim:  "#005f6b"
    readonly property color goldGlow: "#80f0ff"
    readonly property color accent:   "#00b8d4"
    readonly property color danger:   "#ef4444"
    readonly property color success:  "#22c55e"
    readonly property color textPri:  "#ffffff"
    readonly property color textSec:  "#a0d8d8"
    readonly property color textDim:  "#2e7070"

    readonly property real  dp: Math.max(Screen.pixelDensity * 0.1588, 1.0)
    readonly property real  fs: Math.round(14 * dp)

    // ── Animated background ───────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: bg1 }
            GradientStop { position: 1.0; color: bg0 }
        }
    }

    // Geometric grid overlay
    Canvas {
        anchors.fill: parent
        opacity: 0.06
        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "#00e5ff";
            ctx.lineWidth = 0.5;
            var step = 40;
            for (var x = 0; x < width; x += step) {
                ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke();
            }
            for (var y = 0; y < height; y += step) {
                ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke();
            }
        }
    }

    // Top accent bar
    Rectangle {
        anchors.top: parent.top
        width: parent.width; height: Math.round(3 * dp)
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.3; color: gold }
            GradientStop { position: 0.7; color: goldGlow }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // ══════════════════════════════════════
    // VIEW: START
    // ══════════════════════════════════════
    Item {
        anchors.fill: parent
        opacity: viewState === "START" ? 1.0 : 0.0
        enabled: viewState === "START"
        Behavior on opacity { NumberAnimation { duration: 300 } }

        Flickable {
            anchors.fill: parent
            contentWidth: width
            contentHeight: startCol.implicitHeight + Math.round(40 * dp)
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: startCol
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.88
                spacing: 0

                Item { width: 1; height: Math.round(28 * dp) }

                // Logo ring
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.round(100 * dp); height: width
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            var cx = width/2, cy = height/2, r = width*0.44;
                            ctx.beginPath(); ctx.arc(cx,cy,r,0,2*Math.PI);
                            ctx.strokeStyle="#00e5ff"; ctx.lineWidth=2.5; ctx.stroke();
                            ctx.beginPath(); ctx.arc(cx,cy,r*0.78,0,2*Math.PI);
                            ctx.strokeStyle="rgba(0,229,255,0.3)"; ctx.lineWidth=1; ctx.stroke();
                            for(var i=0;i<12;i++){
                                var a=(i/12)*2*Math.PI-Math.PI/2;
                                ctx.beginPath();
                                ctx.moveTo(cx+Math.cos(a)*r*0.88,cy+Math.sin(a)*r*0.88);
                                ctx.lineTo(cx+Math.cos(a)*r,cy+Math.sin(a)*r);
                                ctx.strokeStyle=i%3===0?"#00e5ff":"rgba(232,160,32,0.4)";
                                ctx.lineWidth=i%3===0?2:1; ctx.stroke();
                            }
                        }
                    }
                    Text { anchors.centerIn:parent; text:"IQ"; font.pointSize:20; font.bold:true; color:gold }
                }

                Item { width:1; height: Math.round(14*dp) }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "ML IQ LAB"
                    font.pointSize: 17; font.bold: true
                    font.letterSpacing: Math.round(4*dp); color: textPri
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Pima uwezo wa akili yako sasa."
                    font.pointSize: 9
                    font.italic: true
                    color: textDim
                    font.letterSpacing: Math.round(0.5*dp)
                }

                Item { width:1; height: Math.round(6*dp) }

                // Highscore badge
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: highscoreRow.implicitWidth + Math.round(24*dp)
                    height: Math.round(30*dp)
                    radius: Math.round(15*dp)
                    color: highscoreSettings.bestIQ > 0 ? Qt.rgba(0,0.9,1,0.1) : "transparent"
                    border.color: highscoreSettings.bestIQ > 0 ? Qt.rgba(0,0.9,1,0.3) : "transparent"
                    border.width: 1
                    visible: highscoreSettings.bestIQ > 0
                    Row {
                        id: highscoreRow
                        anchors.centerIn: parent
                        spacing: Math.round(5*dp)
                        Text { text: "\u2605"; color: gold; font.pointSize: 9; anchors.verticalCenter: parent.verticalCenter }
                        Text {
                            text: "Rekodi: " + highscoreSettings.bestIQ + " IQ"
                            font.pointSize: 10; font.bold: true; color: gold
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Item { width:1; height: Math.round(20*dp) }

                // ── DIFFICULTY SELECTOR ───────────────────────────────
                Text {
                    text: "KIWANGO"
                    font.pointSize: 9; font.bold: true
                    font.letterSpacing: Math.round(2*dp); color: textDim
                }
                Item { width:1; height: Math.round(8*dp) }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Math.round(8*dp)
                    Repeater {
                        model: [
                            { label: "ZOTE",    val: 0, time: "20s" },
                            { label: "RAHISI",  val: 1, time: "30s" },
                            { label: "WASTANI", val: 2, time: "20s" },
                            { label: "NGUMU",   val: 3, time: "10s" }
                        ]
                        delegate: Rectangle {
                            width: Math.round(72*dp)
                            height: Math.round(48*dp)
                            radius: Math.round(10*dp)
                            color: selectedDifficulty === modelData.val ? Qt.rgba(0,0.9,1,0.18) : card
                            border.color: selectedDifficulty === modelData.val ? gold : Qt.rgba(0,0.9,1,0.12)
                            border.width: selectedDifficulty === modelData.val ? 2 : 1
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Column {
                                anchors.centerIn: parent; spacing: Math.round(2*dp)
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.label; font.pointSize: 8; font.bold: true
                                    color: selectedDifficulty === modelData.val ? gold : textSec
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.time; font.pointSize: 8
                                    color: selectedDifficulty === modelData.val ? goldGlow : textDim
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: selectedDifficulty = modelData.val
                            }
                        }
                    }
                }

                Item { width:1; height: Math.round(20*dp) }

                // ── CATEGORY SELECTOR ─────────────────────────────────
                Text {
                    text: "MADA"
                    font.pointSize: 9; font.bold: true
                    font.letterSpacing: Math.round(2*dp); color: textDim
                }
                Item { width:1; height: Math.round(8*dp) }

                ListView {
                    width: parent.width
                    height: Math.round(40*dp)
                    orientation: ListView.Horizontal
                    spacing: Math.round(8*dp)
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOff }
                    model: ListModel {
                        ListElement { label: "Sayansi";        icon: "\u2697";  cat: "S"   }
                        ListElement { label: "Hisabati";       icon: "\u2211";  cat: "M"   }
                        ListElement { label: "Michezo";        icon: "\u26bd";  cat: "SP"  }
                        ListElement { label: "Teknolojia";     icon: "\u2328";  cat: "TK"  }
                        ListElement { label: "Historia";       icon: "\ud83d\udcdc"; cat: "H"   }
                        ListElement { label: "Afya";           icon: "\u2665";  cat: "A"   }
                        ListElement { label: "Vitendawili";    icon: "\u2753";  cat: "V"   }
                        ListElement { label: "Mitaa & Maeneo"; icon: "\ud83d\uddfa"; cat: "GEO" }
                        ListElement { label: "Elimu ya Uraia"; icon: "\u2696";  cat: "UR"  }
                        ListElement { label: "Mazingira";      icon: "\ud83c\udf31"; cat: "MK"  }
                        ListElement { label: "Burudani";       icon: "\ud83c\udfb5"; cat: "BUR" }
                        ListElement { label: "Utalii wa TZ";   icon: "\ud83c\udf04"; cat: "UT"  }
                        ListElement { label: "Mantiki";        icon: "\ud83e\udde0"; cat: "LG"  }
                    }
                    delegate: Rectangle {
                        property bool isSelected: selectedCategories.indexOf(cat) !== -1
                        width: chipText.implicitWidth + Math.round(36*dp)
                        height: Math.round(34*dp)
                        radius: Math.round(17*dp)
                        color: isSelected ? Qt.rgba(0,0.9,1,0.18) : card
                        border.color: isSelected ? gold : Qt.rgba(0,0.9,1,0.12)
                        border.width: isSelected ? 2 : 1
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Row {
                            anchors.centerIn: parent
                            spacing: Math.round(4*dp)
                            Text {
                                text: icon
                                font.pointSize: 10
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                id: chipText
                                text: label
                                font.pointSize: 9
                                font.bold: isSelected
                                color: isSelected ? gold : textSec
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var arr = selectedCategories.slice();
                                var i = arr.indexOf(cat);
                                if (i === -1) arr.push(cat);
                                else arr.splice(i, 1);
                                selectedCategories = arr;
                            }
                        }
                    }
                }

                Item { width:1; height: Math.round(6*dp) }
                Text {
                    text: selectedCategories.length === 0 ? "Mada zote zimechaguliwa" : (selectedCategories.length + " mada zimechaguliwa")
                    font.pointSize: 9; color: textDim
                    font.italic: true
                }

                Item { width:1; height: Math.round(24*dp) }

                // Stats row
                Rectangle {
                    id: statsCard
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width; height: Math.round(60*dp)
                    color: card; radius: Math.round(14*dp)
                    Row {
                        anchors.centerIn: parent; spacing: 0
                        Repeater {
                            model: [
                                { val: getAvailableCount() + "",  lbl: "Maswali" },
                                { val: (selectedDifficulty === 1 ? "30s" : (selectedDifficulty === 3 ? "10s" : "20s")), lbl: "Kwa Swali" },
                                { val: "IQ",  lbl: "Matokeo" }
                            ]
                            delegate: Item {
                                width: Math.round(statsCard.width / 3); height: Math.round(60*dp)
                                Rectangle {
                                    anchors.right: parent.right
                                    width: 1; height: parent.height * 0.5
                                    color: textDim; visible: index < 2
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Column {
                                    anchors.centerIn: parent; spacing: 2
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.val; font.pointSize:12; font.bold:true; color:gold }
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.lbl; font.pointSize:9; font.letterSpacing:1; color:textDim }
                                }
                            }
                        }
                    }
                }

                Item { width:1; height: Math.round(20*dp) }

                // MODE SELECTOR — Normal / Time Attack
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Math.round(8*dp)
                    Repeater {
                        model: [
                            { label: "KAWAIDA",     icon: "\u2609", ta: false },
                            { label: "MASHAMBULIZI", icon: "\u23f1", ta: true  }
                        ]
                        delegate: Rectangle {
                            width: Math.round(140*dp); height: Math.round(44*dp)
                            radius: Math.round(12*dp)
                            color: isTimeAttack === modelData.ta ? Qt.rgba(0,0.9,1,0.18) : card
                            border.color: isTimeAttack === modelData.ta ? gold : Qt.rgba(0,0.9,1,0.12)
                            border.width: isTimeAttack === modelData.ta ? 2 : 1
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Row {
                                anchors.centerIn: parent; spacing: Math.round(6*dp)
                                Text { text: modelData.icon; font.pointSize: 13; anchors.verticalCenter: parent.verticalCenter }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter; spacing: 0
                                    Text {
                                        text: modelData.label; font.pointSize: 8; font.bold: true
                                        color: isTimeAttack === modelData.ta ? gold : textSec
                                    }
                                    Text {
                                        text: modelData.ta ? "Dakika 2" : "Maswali 26"
                                        font.pointSize: 7; color: textDim
                                    }
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: isTimeAttack = modelData.ta
                            }
                        }
                    }
                }

                Item { width:1; height: Math.round(10*dp) }

                // FONT SIZE toggle
                Text {
                    text: "UKUBWA WA MAANDISHI"
                    font.pointSize: 9; font.bold: true
                    font.letterSpacing: Math.round(2*dp); color: textDim
                }
                Item { width:1; height: Math.round(6*dp) }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Math.round(6*dp)
                    Repeater {
                        model: [
                            { label: "A",  hint: "Ndogo",   size: 0.85 },
                            { label: "A",  hint: "Kawaida", size: 1.0  },
                            { label: "A",  hint: "Kubwa",   size: 1.2  }
                        ]
                        delegate: Column {
                            spacing: Math.round(3*dp)
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: Math.round(52*dp); height: Math.round(36*dp)
                                radius: Math.round(8*dp)
                                color: Math.abs(fontScale - modelData.size) < 0.05 ? Qt.rgba(0,0.9,1,0.18) : card
                                border.color: Math.abs(fontScale - modelData.size) < 0.05 ? gold : Qt.rgba(0,0.9,1,0.12)
                                border.width: 1
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.pointSize: 7 + index * 2
                                    font.bold: true
                                    color: Math.abs(fontScale - modelData.size) < 0.05 ? gold : textSec
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: fontScale = modelData.size
                                }
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.hint
                                font.pointSize: 7
                                color: Math.abs(fontScale - modelData.size) < 0.05 ? gold : textDim
                            }
                        }
                    }
                }

                Item { width:1; height: Math.round(14*dp) }

                // ANZA button
                Rectangle {
                    id: startBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width; height: Math.round(54*dp)
                    radius: Math.round(14*dp)
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#007a8a" }
                        GradientStop { position: 1.0; color: isTimeAttack ? "#f0c040" : "#00e5ff" }
                    }
                    Behavior on gradient { }
                    Row {
                        anchors.centerIn: parent; spacing: Math.round(8*dp)
                        Text {
                            text: isTimeAttack ? "\u23f1" : "\u25b6"
                            font.pointSize: 12; color: "#020d0d"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: isTimeAttack ? "ANZA MASHAMBULIZI" : "ANZA JARIBIO"
                            font.pointSize: 11; font.bold: true
                            font.letterSpacing: Math.round(2*dp); color: "#020d0d"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed:  { startBtn.scale = 0.97; }
                        onReleased: {
                            startBtn.scale = 1.0;
                            if (isTimeAttack) {
                                timeAttackRemaining = timeAttackSeconds;
                                timeAttackScore = 0;
                            }
                            startCountdown();
                        }
                        onCanceled: { startBtn.scale = 1.0; }
                    }
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }

                Item { width:1; height: Math.round(10*dp) }

                // FUNGA button
                Rectangle {
                    id: closeBtn0
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width; height: Math.round(46*dp)
                    radius: Math.round(14*dp); color: "transparent"
                    border.color: danger; border.width: 1
                    Text { anchors.centerIn:parent; text:"FUNGA"; font.pointSize:10; font.bold:true; font.letterSpacing:2; color:danger }
                    MouseArea {
                        anchors.fill: parent
                        onPressed:  { closeBtn0.scale = 0.97; }
                        onReleased: { closeBtn0.scale = 1.0; app.close(); }
                        onCanceled: { closeBtn0.scale = 1.0; }
                    }
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }

                // ── MAGABE LAB branding ───────────────────────────────────
                Item {
                    width: parent.width
                    height: Math.round(40 * dp)

                    // Divider gradient line
                    Rectangle {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.round(80 * dp); height: 1
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.5; color: Qt.rgba(0,0.9,1,0.2) }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: Math.round(6 * dp)

                        Rectangle {
                            width: Math.round(3 * dp); height: Math.round(3 * dp)
                            radius: Math.round(2 * dp)
                            color: "#00e5ff"; opacity: 0.5
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        /*
                        Text {
                            text: "BY"
                            font.pointSize: 7
                            font.letterSpacing: Math.round(2 * dp)
                            color: Qt.rgba(0,0.9,1,0.3)
                            anchors.verticalCenter: parent.verticalCenter
                        } */

                        Text {
                            text: "MAGABE LAB"
                            font.pointSize: 8
                            font.bold: true
                            font.letterSpacing: Math.round(2.5 * dp)
                            color: Qt.rgba(0,0.9,1,0.7)
                            anchors.verticalCenter: parent.verticalCenter

                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.45; duration: 2000; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 1.0;  duration: 2000; easing.type: Easing.InOutSine }
                            }
                        }

                        Rectangle {
                            width: Math.round(3 * dp); height: Math.round(3 * dp)
                            radius: Math.round(2 * dp)
                            color: "#00e5ff"; opacity: 0.5
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Item { width:1; height: Math.round(8*dp) }
            }
        }
    }

    // ══════════════════════════════════════
    // VIEW: COUNTDOWN
    // ══════════════════════════════════════
    Item {
        anchors.fill: parent
        opacity: viewState === "COUNTDOWN" ? 1.0 : 0.0
        enabled: viewState === "COUNTDOWN"
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Column {
            anchors.centerIn: parent
            spacing: Math.round(10*dp)

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "JIANDAE"
                font.pointSize: 13; font.bold: true
                font.letterSpacing: Math.round(3*dp); color: textSec
            }

            // Namba kubwa inayobadilika
            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.round(130*dp); height: width

                Canvas {
                    id: cdCanvas
                    anchors.fill: parent
                    property real ratio: countdownValue / 3.0
                    onRatioChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0,0,width,height);
                        var cx=width/2, cy=height/2, r=width*0.44;
                        ctx.beginPath(); ctx.arc(cx,cy,r,0,2*Math.PI);
                        ctx.strokeStyle="#0a2424"; ctx.lineWidth=Math.round(8*dp); ctx.stroke();
                        ctx.beginPath();
                        ctx.arc(cx,cy,r,-Math.PI/2,-Math.PI/2+ratio*2*Math.PI);
                        ctx.strokeStyle="#00e5ff"; ctx.lineWidth=Math.round(8*dp);
                        ctx.lineCap="round"; ctx.stroke();
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: countdownValue > 0 ? countdownValue : ""
                    font.pointSize: 48; font.bold: true; color: gold
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: countdownValue === 3 ? "Tatu" : countdownValue === 2 ? "Mbili" : "Moja"
                font.pointSize: 14; color: textSec; font.letterSpacing: Math.round(2*dp)
            }
        }
    }

    // ══════════════════════════════════════
    // VIEW: QUIZ
    // ══════════════════════════════════════
    Item {
        anchors.fill: parent
        opacity: (viewState === "QUIZ" && quizModel.count > 0) ? 1.0 : 0.0
        enabled: viewState === "QUIZ"
        Behavior on opacity { NumberAnimation { duration: 250 } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.round(16 * dp)
            spacing: Math.round(12 * dp)

            // ── Header: progress + timer ──────────────────────────────
            Item {
                Layout.fillWidth: true
                height: Math.round(52 * dp)

                // Question counter badge
                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.round(90 * dp)
                    height: Math.round(32 * dp)
                    radius: Math.round(8 * dp)
                    color: card

                    Column {
                        anchors.centerIn: parent
                        spacing: 0
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Swali"
                            font.pointSize: 7
                            color: textDim
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: (currentIdx + 1) + " / " + quizModel.count
                            font.pointSize: 11
                            font.bold: true
                            color: gold
                        }
                    }
                }

                // Timer ring (circular) with pulse on low time
                Item {
                    id: timerItem
                    anchors.centerIn: parent
                    width: Math.round(52 * dp)
                    height: width

                    SequentialAnimation on scale {
                        id: timerPulseAnim
                        running: timerValue <= 5 && timerValue > 0 && viewState === "QUIZ"
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.12; duration: 300; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0;  duration: 300; easing.type: Easing.InOutSine }
                    }

                    Canvas {
                        id: timerCanvas
                        anchors.fill: parent
                        property real ratio: timerValue / timeInterval

                        onRatioChanged: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var cx = width / 2, cy = height / 2;
                            var r  = width * 0.42;

                            // Background ring
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                            ctx.strokeStyle = "#0a2424";
                            ctx.lineWidth = Math.round(4 * dp);
                            ctx.stroke();

                            // Progress arc
                            if (ratio > 0) {
                                ctx.beginPath();
                                ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + ratio * 2 * Math.PI);
                                ctx.strokeStyle = ratio < 0.2 ? "#ef4444" : ratio < 0.5 ? "#00bcd4" : "#00e5ff";
                                ctx.lineWidth = Math.round(4 * dp);
                                ctx.lineCap = "round";
                                ctx.stroke();
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: timerValue
                        font.pointSize: 11
                        font.bold: true
                        color: timerValue < 4 ? danger : timerValue < 8 ? "#00bcd4" : textPri
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }

                // Streak indicator — inaonyesha streak na multiplier
                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: Math.round(98*dp)
                    width: streakLabel.implicitWidth + Math.round(16*dp)
                    height: Math.round(28*dp)
                    radius: Math.round(14*dp)
                    visible: currentStreak >= 2
                    color: currentStreak >= 6 ? Qt.rgba(0.94,0.27,0.27,0.25)
                         : currentStreak >= 4 ? Qt.rgba(1,0.75,0,0.25)
                         : Qt.rgba(0.13,0.77,0.33,0.2)
                    border.color: currentStreak >= 6 ? danger
                                : currentStreak >= 4 ? "#f0c040"
                                : success
                    border.width: 1
                    Row {
                        anchors.centerIn: parent; spacing: Math.round(3*dp)
                        Text { text: "\ud83d\udd25"; font.pointSize: 9; anchors.verticalCenter: parent.verticalCenter }
                        Text {
                            id: streakLabel
                            text: currentStreak + "x" + (streakMultiplier > 1 ? " \u00d7" + streakMultiplier : "")
                            font.pointSize: 8; font.bold: true
                            color: currentStreak >= 6 ? danger : currentStreak >= 4 ? "#f0c040" : success
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    // Pulse animation ukiongeza streak
                    SequentialAnimation on scale {
                        id: streakPulse
                        running: false
                        NumberAnimation { to: 1.3; duration: 100; easing.type: Easing.OutBack }
                        NumberAnimation { to: 1.0; duration: 150 }
                    }
                    Connections {
                        target: app
                        function onCurrentStreakChanged() {
                            if (app.currentStreak >= 2) streakPulse.start();
                        }
                    }
                }

                // Score badge with jump animation
                Rectangle {
                    id: scoreBadge
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.round(90 * dp)
                    height: Math.round(32 * dp)
                    radius: Math.round(8 * dp)
                    color: card

                    SequentialAnimation {
                        id: scoreJumpAnim
                        NumberAnimation { target: scoreBadge; property: "scale"; to: 1.25; duration: 120; easing.type: Easing.OutBack }
                        NumberAnimation { target: scoreBadge; property: "scale"; to: 1.0;  duration: 180; easing.type: Easing.OutBounce }
                    }

                    Connections {
                        target: app
                        function onNoOfPassedQuestionChanged() {
                            scoreJumpAnim.start();
                        }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: Math.round(4 * dp)
                        Text { text: "\u2605"; color: gold; font.pointSize: 8; anchors.verticalCenter: parent.verticalCenter }
                        Text {
                            text: noOfPassedQuestion
                            font.pointSize: 12
                            font.bold: true
                            color: success
                        }
                    }
                }
            }

            // ── Progress / Time Attack bar ───────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: Math.round(6 * dp)
                radius: Math.round(3 * dp)
                color: "#0a2424"

                Rectangle {
                    id: progressFill
                    width: isTimeAttack
                        ? (timeAttackRemaining / timeAttackSeconds) * parent.width
                        : ((currentIdx + 1) / Math.max(quizModel.count, 1)) * parent.width
                    height: parent.height
                    radius: parent.radius
                    color: isTimeAttack
                        ? (timeAttackRemaining < 30 ? danger : timeAttackRemaining < 60 ? "#f0c040" : "#00e5ff")
                        : (answerResult === "correct" ? success : answerResult === "wrong" ? danger : "#007a8a")
                    Behavior on width { NumberAnimation { duration: isTimeAttack ? 980 : 400; easing.type: Easing.Linear } }
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                // TA score overlay
                Text {
                    anchors.centerIn: parent
                    visible: isTimeAttack
                    text: timeAttackRemaining + "s  |  " + timeAttackScore + " sahihi"
                    font.pointSize: 6; font.bold: true
                    color: timeAttackRemaining < 30 ? danger : gold
                }
            }

            // ── Question card ─────────────────────────────────────────
            Rectangle {
                id: questionCard
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.4
                radius: Math.round(16 * dp)
                color: card
                opacity: 1.0
                x: 0

                // Slide in animation when question changes
                SequentialAnimation {
                    id: slideInAnim
                    NumberAnimation { target: questionCard; property: "opacity"; to: 0; duration: 80 }
                    NumberAnimation { target: questionCard; property: "x"; to: Math.round(-20 * dp); duration: 0 }
                    NumberAnimation { target: questionCard; property: "opacity"; to: 1; duration: 0 }
                    NumberAnimation { target: questionCard; property: "x"; to: 0; duration: 220; easing.type: Easing.OutCubic }
                }

                Connections {
                    target: app
                    function onCurrentIdxChanged() {
                        if (app.viewState === "QUIZ") slideInAnim.start();
                    }
                }

                // Gold left accent bar
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: Math.round(14 * dp)
                    width: Math.round(3 * dp)
                    radius: Math.round(2 * dp)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: goldGlow }
                        GradientStop { position: 1.0; color: goldDim }
                    }
                }

                // Difficulty + Category badges (top right of question card)
                Row {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: Math.round(8*dp)
                    anchors.rightMargin: Math.round(10*dp)
                    spacing: Math.round(5*dp)

                    // Category badge
                    Rectangle {
                        height: Math.round(20*dp)
                        width: catBadgeText.implicitWidth + Math.round(10*dp)
                        radius: Math.round(10*dp)
                        color: Qt.rgba(0,0.9,1,0.10)
                        border.color: Qt.rgba(0,0.9,1,0.25); border.width: 1
                        Text {
                            id: catBadgeText
                            anchors.centerIn: parent
                            text: {
                                if (quizModel.count <= currentIdx) return "";
                                var c = quizModel.get(currentIdx).cat;
                                var m = {"S":"Sayansi","M":"Hisabati","SP":"Michezo","TK":"Teknolojia",
                                         "H":"Historia","A":"Afya","V":"Vitendawili","GEO":"Mitaa",
                                         "UR":"Uraia","MK":"Mazingira","BUR":"Burudani",
                                         "UT":"Utalii","LG":"Mantiki"};
                                return m[c] || c;
                            }
                            font.pointSize: 7; color: "#00e5ff"
                        }
                    }

                    // Difficulty dot
                    Rectangle {
                        height: Math.round(20*dp)
                        width: diffText.implicitWidth + Math.round(10*dp)
                        radius: Math.round(10*dp)
                        color: {
                            if (quizModel.count <= currentIdx) return "transparent";
                            var d = quizModel.get(currentIdx).diff;
                            return d === 1 ? Qt.rgba(0.13,0.77,0.33,0.2)
                                 : d === 3 ? Qt.rgba(0.94,0.27,0.27,0.2)
                                 : Qt.rgba(1,0.75,0,0.2);
                        }
                        border.color: {
                            if (quizModel.count <= currentIdx) return "transparent";
                            var d = quizModel.get(currentIdx).diff;
                            return d === 1 ? success : d === 3 ? danger : "#f0c040";
                        }
                        border.width: 1
                        Text {
                            id: diffText
                            anchors.centerIn: parent
                            text: {
                                if (quizModel.count <= currentIdx) return "";
                                var d = quizModel.get(currentIdx).diff;
                                return d === 1 ? "Rahisi" : d === 3 ? "Ngumu" : "Wastani";
                            }
                            font.pointSize: 7
                            color: {
                                if (quizModel.count <= currentIdx) return textDim;
                                var d = quizModel.get(currentIdx).diff;
                                return d === 1 ? success : d === 3 ? danger : "#f0c040";
                            }
                        }
                    }
                }

                Text {
                    anchors {
                        left: parent.left; right: parent.right
                        top: parent.top; bottom: parent.bottom
                        leftMargin: Math.round(22 * dp)
                        rightMargin: Math.round(16 * dp)
                        topMargin: Math.round(32 * dp)
                        bottomMargin: Math.round(10 * dp)
                    }
                    text: (quizModel.count > currentIdx) ? quizModel.get(currentIdx).q : ""
                    font.pointSize: Math.round(16 * fontScale)
                    font.bold: true
                    color: textPri
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    lineHeight: 1.4
                    lineHeightMode: Text.ProportionalHeight
                }
            }

            // ── Options ───────────────────────────────────────────────
            ColumnLayout {
                id: optionsLayout
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Math.round(9 * dp)

                Repeater {
                    id: optionRepeater
                    model: (quizModel.count > currentIdx)
                           ? shuffleOptions(quizModel.get(currentIdx).a,
                                            quizModel.get(currentIdx).b,
                                            quizModel.get(currentIdx).c,
                                            quizModel.get(currentIdx).d) : []

                    delegate: Rectangle {
                        id: optRect
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Math.round(12 * dp)
                        clip: true

                        // Safe accessor — huzuia TypeError kama quizModel ni tupu
                        readonly property string correctAnswer: (quizModel.count > currentIdx)
                            ? quizModel.get(currentIdx).correct : ""

                        // Feedback color logic
                        color: {
                            if (answerResult !== "") {
                                if (modelData === correctAnswer)
                                    return Qt.rgba(0.13, 0.77, 0.33, 0.25);
                                if (modelData === selectedAnswer)
                                    return Qt.rgba(0.94, 0.27, 0.27, 0.20);
                                return Qt.rgba(0.04, 0.12, 0.12, 0.5);
                            }
                            if (optMA.pressed)
                                return (modelData === correctAnswer
                                        ? Qt.rgba(0.13,0.77,0.33,0.25)
                                        : Qt.rgba(0.94,0.27,0.27,0.2));
                            return card;
                        }
                        border.color: {
                            if (answerResult !== "") {
                                if (modelData === correctAnswer) return success;
                                if (modelData === selectedAnswer) return danger;
                                return Qt.rgba(0, 0.9, 1, 0.06);
                            }
                            if (optMA.pressed)
                                return (modelData === correctAnswer ? success : danger);
                            return Qt.rgba(0, 0.9, 1, 0.15);
                        }
                        border.width: {
                            if (answerResult !== "") {
                                if (modelData === correctAnswer
                                        || modelData === selectedAnswer)
                                    return Math.round(1.5 * dp);
                            }
                            return optMA.pressed ? Math.round(1.5 * dp) : 1;
                        }

                        Behavior on color  { ColorAnimation { duration: 120 } }
                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        // ── SHAKE animation (wrong answer) ──────────────
                        SequentialAnimation {
                            id: shakeAnim
                            NumberAnimation { target: optRect; property: "x"; to:  Math.round(8*dp);  duration: 40 }
                            NumberAnimation { target: optRect; property: "x"; to: -Math.round(8*dp);  duration: 40 }
                            NumberAnimation { target: optRect; property: "x"; to:  Math.round(5*dp);  duration: 35 }
                            NumberAnimation { target: optRect; property: "x"; to: -Math.round(5*dp);  duration: 35 }
                            NumberAnimation { target: optRect; property: "x"; to:  Math.round(2*dp);  duration: 30 }
                            NumberAnimation { target: optRect; property: "x"; to:  0;                 duration: 30 }
                        }

                        // ── BOUNCE animation (correct answer) ───────────
                        SequentialAnimation {
                            id: bounceAnim
                            NumberAnimation { target: optRect; property: "scale"; to: 1.04; duration: 100; easing.type: Easing.OutCubic }
                            NumberAnimation { target: optRect; property: "scale"; to: 0.98; duration: 80  }
                            NumberAnimation { target: optRect; property: "scale"; to: 1.0;  duration: 100; easing.type: Easing.OutBounce }
                        }

                        // Trigger animations when answerResult changes
                        Connections {
                            target: app
                            function onAnswerResultChanged() {
                                if (app.answerResult === "wrong" && modelData === app.selectedAnswer) {
                                    shakeAnim.start();
                                } else if (app.answerResult === "correct"
                                           && quizModel.count > app.currentIdx
                                           && modelData === correctAnswer) {
                                    bounceAnim.start();
                                }
                            }
                        }

                        // ── Ripple overlay (flash on tap) ───────────────
                        Rectangle {
                            id: ripple
                            anchors.fill: parent
                            radius: parent.radius
                            color: "white"
                            opacity: 0
                            SequentialAnimation on opacity {
                                id: rippleAnim
                                running: false
                                NumberAnimation { to: 0.12; duration: 60 }
                                NumberAnimation { to: 0;    duration: 180 }
                            }
                        }

                        // ── Tick / X icon overlay (feedback) ───────────
                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: Math.round(14 * dp)
                            text: {
                                if (answerResult === "" ) return "";
                                if (modelData === correctAnswer) return "\u2713";
                                if (modelData === selectedAnswer) return "x";
                                return "";
                            }
                            font.pointSize: 14
                            font.bold: true
                            color: modelData === correctAnswer ? success : danger
                            opacity: answerResult !== "" ? 1 : 0
                            scale:  answerResult !== "" ? 1 : 0.3
                            Behavior on opacity { NumberAnimation { duration: 180 } }
                            Behavior on scale   { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: Math.round(14 * dp)
                            anchors.rightMargin: Math.round(40 * dp)
                            spacing: Math.round(12 * dp)

                            // Letter badge
                            Rectangle {
                                id: letterBadge
                                width: Math.round(34 * dp); height: width; radius: Math.round(6 * dp)
                                color: {
                                    if (answerResult !== "") {
                                        if (modelData === correctAnswer) return Qt.rgba(0.13,0.77,0.33,0.3);
                                        if (modelData === selectedAnswer) return Qt.rgba(0.94,0.27,0.27,0.3);
                                    }
                                    return Qt.rgba(0, 0.9, 1, 0.1);
                                }
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Text {
                                    anchors.centerIn: parent
                                    text: app.indexToLetter(index)
                                    font.pointSize: 13
                                    font.bold: true
                                    color: {
                                        if (answerResult !== "") {
                                            if (modelData === correctAnswer) return success;
                                            if (modelData === selectedAnswer) return danger;
                                        }
                                        return gold;
                                    }
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                            }

                            Text {
                                width: parent.width - Math.round(34 * dp) - Math.round(12 * dp)
                                text: app.cleanOption(modelData)
                                font.pointSize: Math.round(16 * fontScale)
                                color: {
                                    if (answerResult !== "") {
                                        if (modelData === correctAnswer) return success;
                                        if (modelData === selectedAnswer) return danger;
                                        return Qt.rgba(1,1,1,0.3);
                                    }
                                    return textPri;
                                }
                                Behavior on color { ColorAnimation { duration: 150 } }
                                wrapMode: Text.WordWrap
                                lineHeight: 1.3
                                lineHeightMode: Text.ProportionalHeight
                            }
                        }

                        MouseArea {
                            id: optMA
                            anchors.fill: parent
                            enabled: answerResult === ""
                            onPressed:  { optRect.scale = 0.97; rippleAnim.start(); }
                            onReleased: { optRect.scale = 1.0; processAnswer(modelData); }
                            onCanceled: { optRect.scale = 1.0; }
                        }
                        Behavior on scale { NumberAnimation { duration: 100 } }
                    }
                }

                // ── SPEED BONUS POPUP ─────────────────────────────────
                // Popup inayoruka juu inapojibu sahihi — inaonyesha bonus ya kasi
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 0   // haichukui nafasi — popup ni overlay
                    clip: false

                    Item {
                        id: speedPopup
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 0
                        width: speedPopupRow.implicitWidth + Math.round(20 * dp)
                        height: Math.round(32 * dp)
                        opacity: 0
                        visible: opacity > 0

                        // Acha ifanye kazi mara answerResult inabadilika kuwa "correct"
                        states: State {
                            name: "visible"
                            when: answerResult === "correct" && lastSpeedBonus > 0
                            PropertyChanges { target: speedPopup; opacity: 1.0; y: Math.round(-44 * dp) }
                        }

                        transitions: [
                            Transition {
                                from: ""; to: "visible"
                                NumberAnimation { target: speedPopup; property: "opacity"; from: 0; to: 1.0; duration: 150 }
                                NumberAnimation { target: speedPopup; property: "y"; from: 0; to: Math.round(-44 * dp); duration: 350; easing.type: Easing.OutCubic }
                            },
                            Transition {
                                from: "visible"; to: ""
                                NumberAnimation { target: speedPopup; property: "opacity"; from: 1.0; to: 0; duration: 300 }
                                NumberAnimation { target: speedPopup; property: "y"; from: Math.round(-44 * dp); to: Math.round(-64 * dp); duration: 300; easing.type: Easing.InCubic }
                            }
                        ]

                        Rectangle {
                            anchors.fill: parent
                            radius: Math.round(16 * dp)
                            color: Qt.rgba(0.0, 0.13, 0.13, 0.92)
                            border.color: gold
                            border.width: 1

                            // Glow effect
                            layer.enabled: true
                            layer.effect: Glow {
                                radius: 6
                                samples: 12
                                color: gold
                                spread: 0.1
                            }
                        }

                        Row {
                            id: speedPopupRow
                            anchors.centerIn: parent
                            spacing: Math.round(5 * dp)

                            Text {
                                text: "\u26A1"   // ⚡
                                font.pointSize: 12
                                color: gold
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "+" + lastSpeedBonus + " pointi"
                                font.pointSize: 12
                                font.bold: true
                                color: gold
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "KASI!"
                                font.pointSize: 9
                                font.bold: true
                                font.letterSpacing: Math.round(1.5 * dp)
                                color: goldGlow
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // ── KIMBIA ────────────────────────────────────
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.round(36 * dp)

                    Text {
                        anchors.centerIn: parent
                        text: "Funga jaribio  \u203a"
                        font.pointSize: 12
                        color: "red"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                mainTimer.stop();
                                feedbackTimer.stop();
                                answerResult = "";
                                selectedAnswer = "";
                                // Maswali yaliyokimbwa = yote ambayo hayakujibiwa kabisa
                                // (userAnswers ni maswali yaliyojibiwa AU yaliyoisha muda)
                                skippedQuestions = quizModel.count - userAnswers.count;
                                viewState = "END";
                                app.ad();
                            }
                        }
                    }
                }
            }
        }
    }

    // Hesabu maswali yanayopatikana kwa chaguzi la sasa (category + difficulty)
    function getAvailableCount() {
        var count = 0;
        for (var i = 0; i < iqModel.count; i++) {
            var item = iqModel.get(i);
            var diffOk = (selectedDifficulty === 0) || (item.diff === selectedDifficulty);
            var catOk  = (selectedCategories.length === 0) || (selectedCategories.indexOf(item.cat) !== -1);
            if (diffOk && catOk) count++;
        }
        return Math.min(26, count);
    }

    function calculateFinalIQ() {
        // Jumla ya maswali yote ya mchezo huu (ni denominator sahihi)
        var total = Math.max(maxQuestions, 1);

        // Accuracy: sahihi / maswali yote (si yaliyojibiwa tu)
        // Ukifunga mapema, maswali usiyojibu yanakuwa makosa kiotomatiki
        var accuracy = noOfPassedQuestion / total;

        // Base IQ: 70 (sifuri) hadi 135 (100% sahihi)
        var baseIQ = 70 + Math.round(accuracy * 65);

        // Speed bonus: inahesabiwa kwa maswali yaliyojibiwa tu (si yaliyokimbwa)
        var attempted = Math.max(userAnswers.count, 1);
        var maxSpeed = attempted * timeInterval * 3;
        var speedRatio = maxSpeed > 0 ? Math.min(speedBonusTotal / maxSpeed, 1.0) : 0;
        // Speed inaongeza hadi pointi 10 — tu kama accuracy ya jumla >= 40%
        var speedIQ = accuracy >= 0.4 ? Math.round(speedRatio * 10) : 0;

        // Penalty ya kukimbia: -1 IQ kwa kila swali lililokimbwa (si -2)
        // Na penalty isizidi nusu ya base IQ iliyopatikana
        var rawPenalty = skippedQuestions;
        var maxPenalty = Math.floor((baseIQ - 70) / 2);
        var skipPenalty = Math.min(rawPenalty, maxPenalty);

        return Math.max(70, Math.min(145, baseIQ + speedIQ - skipPenalty));
    }

    // ══════════════════════════════════════
    // VIEW: END (Results)
    // ══════════════════════════════════════
    Item {
        id: endView
        anchors.fill: parent
        // --- IQ FORMULA ILIYOBORESHWA ---
        // Accuracy (sahihi / jumla) ndiyo msingi mkuu wa IQ
        // Speed bonus inaongeza kidogo (max +10 pointi za IQ)
        // Penalty ya kukimbia: accuracy inashuka + IQ minus 2 kwa kila swali lililokimbwa
        // Mtu asiyejibu chochote → IQ 70 (kiwango cha chini)
        // Mtu anayejibu yote kwa kasi → IQ 145
        property int finalIQ: calculateFinalIQ()
        property real animatedRatio: 0.0
        opacity: viewState === "END" ? 1.0 : 0.0
        enabled: viewState === "END"
        Behavior on opacity { NumberAnimation { duration: 300 } }

        onOpacityChanged: {
            if (opacity > 0.9) {
                iqRatioAnim.start();
                if (finalIQ >= 110) confettiLaunchTimer.start();
            }
        }

        NumberAnimation {
            id: iqRatioAnim
            target: endView
            property: "animatedRatio"
            from: 0.0
            to: endView.finalIQ / 145.0
            duration: 1200
            easing.type: Easing.OutCubic
        }

        // Scrollable in case screen is short
        Flickable {
            anchors.fill: parent
            anchors.margins: Math.round(20 * dp)
            contentWidth: width
            contentHeight: resultsCol.implicitHeight + Math.round(40 * dp)
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: resultsCol
                width: parent.width
                spacing: Math.round(14 * dp)

                Item { width: 1; height: Math.round(10 * dp) }

                // "MATOKEO" heading
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "M A T O K E O"
                    font.pointSize: 14
                    font.bold: true
                    font.letterSpacing: Math.round(5 * dp)
                    color: textSec
                }

                // IQ score ring
                // finalIQ is a property on the END view Item (endView), accessible to all children
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.round(160 * dp)
                    height: width

                    Canvas {
                        id: iqRingCanvas
                        anchors.fill: parent
                        property real ratio: endView.animatedRatio

                        onRatioChanged: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var cx = width/2, cy = height/2, r = width*0.42;

                            // bg ring
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, 0, 2*Math.PI);
                            ctx.strokeStyle = "#0a2424";
                            ctx.lineWidth = Math.round(8 * dp);
                            ctx.stroke();

                            // score arc
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, -Math.PI/2, -Math.PI/2 + Math.min(ratio, 1.0)*2*Math.PI);
                            ctx.strokeStyle = "#00e5ff";
                            ctx.lineWidth = Math.round(8 * dp);
                            ctx.lineCap = "round";
                            ctx.stroke();

                            // inner glow ring
                            ctx.beginPath();
                            ctx.arc(cx, cy, r*0.80, 0, 2*Math.PI);
                            ctx.strokeStyle = "rgba(0,229,255,0.12)";
                            ctx.lineWidth = 1;
                            ctx.stroke();
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: Math.round(2 * dp)

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Alama za IQ"
                            font.pointSize: 10
                            color: textDim
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Math.round(endView.animatedRatio * 145)
                            font.pointSize: 24
                            font.bold: true
                            color: getGradeColor(endView.finalIQ)
                        }
                    }
                }

                // Grade letter badge
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Math.round(12*dp)

                    Rectangle {
                        width: Math.round(64*dp); height: Math.round(64*dp)
                        radius: Math.round(14*dp)
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: Qt.rgba(0,0.1,0.15,1) }
                            GradientStop { position: 1.0; color: Qt.rgba(0,0.15,0.2,1) }
                        }
                        border.color: getGradeColor(endView.finalIQ); border.width: 2
                        Column {
                            anchors.centerIn: parent; spacing: 0
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: getGrade(endView.finalIQ)
                                font.pointSize: 22; font.bold: true
                                color: getGradeColor(endView.finalIQ)
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Daraja"
                                font.pointSize: 7; color: textDim
                            }
                        }
                        opacity: endView.animatedRatio > 0.8 ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 400 } }
                        scale: endView.animatedRatio > 0.8 ? 1.0 : 0.5
                        Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
                    }

                    // Best category badge
                    Rectangle {
                        visible: getBestCat() !== ""
                        width: Math.round(130*dp); height: Math.round(64*dp)
                        radius: Math.round(14*dp)
                        color: Qt.rgba(0,0.12,0.12,1)
                        border.color: Qt.rgba(0,0.9,1,0.25); border.width: 1
                        Column {
                            anchors.centerIn: parent; spacing: Math.round(2*dp)
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Bora Zaidi"
                                font.pointSize: 7; color: textDim
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: getBestCat()
                                font.pointSize: 10; font.bold: true; color: "#00e5ff"
                                wrapMode: Text.WordWrap
                                width: Math.round(115*dp)
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                        opacity: endView.animatedRatio > 0.8 ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 500 } }
                    }
                }

                // NEW HIGHSCORE banner — inaonekana tu kama rekodi mpya
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: Math.round(44*dp)
                    radius: Math.round(14*dp)
                    visible: isNewHighscore
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#005500" }
                        GradientStop { position: 1.0; color: "#007700" }
                    }
                    border.color: success; border.width: 1
                    Row {
                        anchors.centerIn: parent; spacing: Math.round(8*dp)
                        Text { text: "\u2605"; color: "#ffff00"; font.pointSize: 13; anchors.verticalCenter: parent.verticalCenter }
                        Text {
                            text: "REKODI MPYA!"
                            font.pointSize: 12; font.bold: true
                            font.letterSpacing: Math.round(2*dp); color: "#ffff00"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text { text: "\u2605"; color: "#ffff00"; font.pointSize: 13; anchors.verticalCenter: parent.verticalCenter }
                    }
                }

                // Category badge
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: Math.round(56 * dp)
                    radius: Math.round(14 * dp)
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#001a1a" }
                        GradientStop { position: 1.0; color: "#002e2e" }
                    }
                    border.color: Qt.rgba(0.0,0.9,1.0,0.4)
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: getCategory(endView.finalIQ)
                        font.pointSize: 11
                        font.bold: true
                        font.letterSpacing: Math.round(2 * dp)
                        color: gold
                    }
                }

                // Stats cards row
                Row {
                    id: statsCardsRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    spacing: Math.round(10 * dp)

                    Repeater {
                        model: [
                            { icon: "\u2713", val: noOfPassedQuestion,                        lbl: "Sahihi" },
                            { icon: "x", val: userAnswers.count - noOfPassedQuestion,          lbl: "Makosa" }
                        ]
                        delegate: Rectangle {
                            width: (statsCardsRow.width - Math.round(10 * dp)) / 2
                            height: Math.round(72 * dp)
                            radius: Math.round(14 * dp)
                            color: card

                            Column {
                                anchors.centerIn: parent
                                spacing: Math.round(4 * dp)
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.icon + "  " + modelData.val
                                    font.pointSize: 18
                                    font.bold: true
                                    color: index === 0 ? success : danger
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.lbl
                                    font.pointSize: 10
                                    color: textDim
                                    font.letterSpacing: 1
                                }
                            }
                        }
                    }
                }

                // ── PENALTY CARD — inaonekana tu kama alikimbia ──────────
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: Math.round(64 * dp)
                    radius: Math.round(14 * dp)
                    visible: skippedQuestions > 0
                    color: Qt.rgba(0.94, 0.27, 0.27, 0.08)
                    border.color: Qt.rgba(0.94, 0.27, 0.27, 0.4)
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: Math.round(14 * dp)

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Math.round(3 * dp)
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: skippedQuestions
                                font.pointSize: 18
                                font.bold: true
                                color: danger
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Yaliyokimbiwa"
                                font.pointSize: 9
                                color: textDim
                                font.letterSpacing: 1
                            }
                        }

                        // Divider
                        Rectangle {
                            width: 1
                            height: Math.round(36 * dp)
                            color: Qt.rgba(0.94, 0.27, 0.27, 0.3)
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Math.round(3 * dp)
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "-" + (skippedQuestions * 2) + " IQ"
                                font.pointSize: 18
                                font.bold: true
                                color: danger
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Penati ya kukimbia"
                                font.pointSize: 9
                                color: textDim
                                font.letterSpacing: 1
                            }
                        }
                    }
                }

                Item { width: 1; height: Math.round(4 * dp) }

                // ── MAPITIO YA MASWALI (Maswali yaliyokosewa) ──────────
                Item {
                    width: parent.width
                    // Onyesha tu kama kuna makosa
                    height: wrongReviewCol.implicitHeight
                    visible: userAnswers.count > 0 && (userAnswers.count - noOfPassedQuestion) > 0

                    Column {
                        id: wrongReviewCol
                        width: parent.width
                        spacing: Math.round(8 * dp)

                        // Kichwa cha sehemu
                        Rectangle {
                            width: parent.width
                            height: Math.round(40 * dp)
                            radius: Math.round(10 * dp)
                            color: Qt.rgba(0.94, 0.27, 0.27, 0.12)
                            border.color: Qt.rgba(0.94, 0.27, 0.27, 0.35)
                            border.width: 1

                            Row {
                                anchors.centerIn: parent
                                spacing: Math.round(8 * dp)
                                Text {
                                    text: "\u26A0"
                                    font.pointSize: 11
                                    color: danger
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "MASWALI YALIYOKOSEWA  (" + (userAnswers.count - noOfPassedQuestion) + ")"
                                    font.pointSize: 10
                                    font.bold: true
                                    font.letterSpacing: Math.round(1 * dp)
                                    color: danger
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        // Orodha ya maswali yaliyokosewa
                        Repeater {
                            model: userAnswers
                            delegate: Item {
                                width: wrongReviewCol.width
                                height: model.wasCorrect ? 0 : wrongCard.implicitHeight + Math.round(2 * dp)
                                visible: !model.wasCorrect
                                clip: true

                                Rectangle {
                                    id: wrongCard
                                    width: parent.width
                                    implicitHeight: wrongCardCol.implicitHeight + Math.round(16 * dp)
                                    radius: Math.round(10 * dp)
                                    color: card
                                    border.color: Qt.rgba(0.94, 0.27, 0.27, 0.2)
                                    border.width: 1

                                    Column {
                                        id: wrongCardCol
                                        anchors {
                                            left: parent.left; right: parent.right
                                            top: parent.top
                                            margins: Math.round(12 * dp)
                                        }
                                        spacing: Math.round(7 * dp)

                                        // Swali
                                        Text {
                                            width: parent.width
                                            text: (index + 1) + ". " + model.q
                                            font.pointSize: 11
                                            font.bold: true
                                            color: textPri
                                            wrapMode: Text.WordWrap
                                            lineHeight: 1.35
                                            lineHeightMode: Text.ProportionalHeight
                                        }

                                        // Jibu sahihi
                                        Row {
                                            spacing: Math.round(6 * dp)
                                            Rectangle {
                                                width: Math.round(18 * dp); height: width
                                                radius: Math.round(4 * dp)
                                                color: Qt.rgba(0.13, 0.77, 0.33, 0.2)
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "\u2713"
                                                    font.pointSize: 8
                                                    font.bold: true
                                                    color: success
                                                }
                                            }
                                            Text {
                                                text: app.cleanOption(model.correct)
                                                font.pointSize: 10
                                                color: success
                                                wrapMode: Text.WordWrap
                                                width: wrongCardCol.width - Math.round(24 * dp)
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        // Jibu la mtumiaji (kama alitoa jibu)
                                        Row {
                                            spacing: Math.round(6 * dp)
                                            visible: model.chosen !== ""
                                            Rectangle {
                                                width: Math.round(18 * dp); height: width
                                                radius: Math.round(4 * dp)
                                                color: Qt.rgba(0.94, 0.27, 0.27, 0.2)
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "x"
                                                    font.pointSize: 8
                                                    font.bold: true
                                                    color: danger
                                                }
                                            }
                                            Text {
                                                text: app.cleanOption(model.chosen)
                                                font.pointSize: 10
                                                color: danger
                                                wrapMode: Text.WordWrap
                                                width: wrongCardCol.width - Math.round(24 * dp)
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        // Timeout label
                                        Text {
                                            visible: model.chosen === ""
                                            text: "\u23F0  Muda uliisha"
                                            font.pointSize: 10
                                            font.italic: true
                                            color: textDim
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Item { width: 1; height: Math.round(4 * dp) }

                // BADGES zilizopatikana
                Item {
                    width: parent.width
                    height: earnedBadges.length > 0 ? badgesCol.implicitHeight + Math.round(16*dp) : 0
                    visible: earnedBadges.length > 0
                    Behavior on height { NumberAnimation { duration: 300 } }

                    Column {
                        id: badgesCol
                        anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: Math.round(8*dp) }
                        spacing: Math.round(8*dp)

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "TUZO ZAKO"
                            font.pointSize: 9; font.bold: true
                            font.letterSpacing: Math.round(2*dp); color: textDim
                        }

                        Repeater {
                            model: earnedBadges
                            delegate: Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width
                                height: Math.round(54*dp)
                                radius: Math.round(12*dp)
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: "#001a0d" }
                                    GradientStop { position: 1.0; color: "#002a14" }
                                }
                                border.color: Qt.rgba(0.13,0.77,0.33,0.5); border.width: 1

                                Row {
                                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: Math.round(16*dp) }
                                    spacing: Math.round(12*dp)
                                    Text { text: modelData.icon; font.pointSize: 22; anchors.verticalCenter: parent.verticalCenter }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: Math.round(2*dp)
                                        Text { text: modelData.name; font.pointSize: 11; font.bold: true; color: "#4caf50" }
                                        Text { text: modelData.desc; font.pointSize: 9; color: textDim; wrapMode: Text.WordWrap; width: Math.round(200*dp) }
                                    }
                                }

                                // Entry animation
                                opacity: 0
                                scale: 0.8
                                Component.onCompleted: {
                                    opacity = 1; scale = 1.0;
                                }
                                Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                                Behavior on scale   { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
                            }
                        }
                    }
                }

                // JARIBU TENA — maswali mapya, mada ile ile
                Rectangle {
                    id: retryBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: Math.round(54 * dp)
                    radius: Math.round(14 * dp)
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#007a8a" }
                        GradientStop { position: 1.0; color: gold }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "JARIBU TENA"
                        font.pointSize: 11; font.bold: true
                        font.letterSpacing: Math.round(2 * dp)
                        color: "#020d0d"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed:  { retryBtn.scale = 0.97; }
                        onReleased: {
                            retryBtn.scale = 1.0;
                            transitionCurtain.action = "retry";
                            curtainAnim.start();
                        }
                        onCanceled: { retryBtn.scale = 1.0; }
                    }
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }

                // BADILISHA MADA — rudi START screen kubadilisha chaguzi
                Rectangle {
                    id: changeCatBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: Math.round(48 * dp)
                    radius: Math.round(14 * dp)
                    color: "transparent"
                    border.color: gold
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: Math.round(8 * dp)
                      /*
                        Text {
                            text: "\u2630"
                            font.pointSize: 11
                            color: gold
                            anchors.verticalCenter: parent.verticalCenter
                        } */
                        Text {
                            text: "BADILISHA MADA"
                            font.pointSize: 10; font.bold: true
                            font.letterSpacing: Math.round(1.5 * dp)
                            color: gold
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed:  { changeCatBtn.scale = 0.97; }
                        onReleased: {
                            changeCatBtn.scale = 1.0;
                            transitionCurtain.action = "start";
                            curtainAnim.start();
                        }
                        onCanceled: { changeCatBtn.scale = 1.0; }
                    }
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }

                // FUNGA button
                Rectangle {
                    id: closeBtn1
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: Math.round(48 * dp)
                    radius: Math.round(14 * dp)
                    color: "transparent"
                    border.color: danger
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "FUNGA"
                        font.pointSize: 10
                        font.bold: true
                        font.letterSpacing: 2
                        color: danger
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed:  { closeBtn1.scale = 0.97; }
                        onReleased: { closeBtn1.scale = 1.0; app.close(); }
                        onCanceled: { closeBtn1.scale = 1.0; }
                    }
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }

                Item { width: 1; height: Math.round(8 * dp) }
            }
        }
    }

    // ══════════════════════════════════════════════════════
    // VIEW: ONBOARDING — inaonyeshwa mara ya kwanza tu
    // ══════════════════════════════════════════════════════
    Item {
        id: onboardView
        anchors.fill: parent
        opacity: viewState === "ONBOARD" ? 1.0 : 0.0
        enabled: viewState === "ONBOARD"
        Behavior on opacity { NumberAnimation { duration: 350 } }

        // Background gradient overlay
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#020d0d" }
                GradientStop { position: 1.0; color: "#041a1a" }
            }
        }

        Flickable {
            anchors.fill: parent
            contentWidth: width
            contentHeight: onboardCol.implicitHeight + Math.round(60 * dp)
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: onboardCol
                width: parent.width
                spacing: 0

                // Header
                Item { width: 1; height: Math.round(52 * dp) }

                // Logo / Icon
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.round(90 * dp)
                    height: width
                    radius: width / 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#007a8a" }
                        GradientStop { position: 1.0; color: "#00e5ff" }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "IQ"
                        font.pointSize: 30
                        font.bold: true
                        color: "#020d0d"
                    }
                }

                Item { width: 1; height: Math.round(24 * dp) }

                // Title
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Karibu ML IQ Lab!"
                    font.pointSize: 20
                    font.bold: true
                    color: "#00e5ff"
                    font.letterSpacing: 1
                }

                Item { width: 1; height: Math.round(6 * dp) }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - Math.round(48 * dp)
                    text: "Pima akili yako na ujaribu maswali kutoka mada mbalimbali za Tanzania na dunia."
                    font.pointSize: 11
                    color: "#8ab8b8"
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Item { width: 1; height: Math.round(36 * dp) }

                // Steps
                Repeater {
                    model: [
                        { icon: "\u2460", title: "Chagua Mada",    desc: "Chagua mada unayopenda au cheza maswali yote mchanganyiko." },
                        { icon: "\u2461", title: "Jibu Haraka",    desc: "Kila swali lina muda maalum. Jibu haraka zaidi upate bonus ya kasi!" },
                        { icon: "\u2462", title: "Pata IQ Yako",   desc: "Matokeo yako yanakokotolewa kulingana na usahihi na kasi yako." },
                        { icon: "\u2463", title: "Vunja Rekodi",   desc: "Jaribu tena na tena uboreshe IQ yako ya juu zaidi." },
                    ]
                    delegate: Item {
                        width: onboardCol.width
                        height: stepRow.implicitHeight + Math.round(28 * dp)

                        Row {
                            id: stepRow
                            anchors {
                                left: parent.left; right: parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin: Math.round(28 * dp)
                                rightMargin: Math.round(28 * dp)
                            }
                            spacing: Math.round(16 * dp)

                            // Icon circle
                            Rectangle {
                                width: Math.round(44 * dp); height: width
                                radius: width / 2
                                color: Qt.rgba(0, 0.9, 1, 0.1)
                                border.color: Qt.rgba(0, 0.9, 1, 0.25)
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    font.pointSize: 18
                                    color: "#00e5ff"
                                }
                            }

                            Column {
                                spacing: Math.round(3 * dp)
                                width: parent.width - Math.round(44 * dp) - Math.round(16 * dp)
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: modelData.title
                                    font.pointSize: 12
                                    font.bold: true
                                    color: "#e0f7f7"
                                }
                                Text {
                                    text: modelData.desc
                                    font.pointSize: 10
                                    color: "#8ab8b8"
                                    wrapMode: Text.WordWrap
                                    width: parent.width
                                }
                            }
                        }

                        // Divider
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left; anchors.right: parent.right
                            anchors.leftMargin: Math.round(28 * dp)
                            anchors.rightMargin: Math.round(28 * dp)
                            height: 1
                            color: Qt.rgba(0, 0.9, 1, 0.07)
                            visible: index < 3
                        }
                    }
                }

                Item { width: 1; height: Math.round(36 * dp) }

                // CTA Button
                Rectangle {
                    id: onboardBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - Math.round(48 * dp)
                    height: Math.round(56 * dp)
                    radius: Math.round(16 * dp)
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#007a8a" }
                        GradientStop { position: 1.0; color: "#f0c040" }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "ANZA KUCHEZA  \u203a"
                        font.pointSize: 13
                        font.bold: true
                        font.letterSpacing: Math.round(2 * dp)
                        color: "#020d0d"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed:  { onboardBtn.scale = 0.97; }
                        onReleased: {
                            onboardBtn.scale = 1.0;
                            highscoreSettings.hasSeenOnboard = true;
                            viewState = "START";
                        }
                        onCanceled: { onboardBtn.scale = 1.0; }
                    }
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }

                Item { width: 1; height: Math.round(32 * dp) }
            }
        }
    }

    // ══════════════════════════════════════════════════════
    // TRANSITION OVERLAY: END → START (iliyoimarishwa)
    // ══════════════════════════════════════════════════════
    // Inatumia "curtain" ya kijani inayofunika screen kisha kuifungua upya
    Rectangle {
        id: transitionCurtain
        anchors.fill: parent
        color: "#020d0d"
        opacity: 0
        visible: opacity > 0
        z: 500
        property string action: "start"  // "start" = rudi START, "retry" = anza mchezo upya

        // Shimmer line inayopita katikati wakati wa transition
        Rectangle {
            id: shimmerLine
            width: parent.width
            height: Math.round(2 * dp)
            y: parent.height / 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.4; color: "#00e5ff" }
                GradientStop { position: 0.6; color: "#f0c040" }
                GradientStop { position: 1.0; color: "transparent" }
            }
            opacity: 0
        }

        SequentialAnimation {
            id: curtainAnim
            // Fade in (funika screen)
            NumberAnimation { target: transitionCurtain; property: "opacity"; from: 0; to: 1.0; duration: 280; easing.type: Easing.InCubic }
            // Shimmer line inapita
            ParallelAnimation {
                NumberAnimation { target: shimmerLine; property: "opacity"; from: 0; to: 1.0; duration: 120 }
                NumberAnimation { target: shimmerLine; property: "y"; from: 0; to: transitionCurtain.height; duration: 340; easing.type: Easing.InOutCubic }
            }
            // Tekeleza action iliyowekwa
            ScriptAction {
                script: {
                    shimmerLine.opacity = 0;
                    if (transitionCurtain.action === "retry") {
                        app.startCountdown();
                    } else {
                        viewState = "START";
                    }
                }
            }
            // Fade out
            NumberAnimation { target: transitionCurtain; property: "opacity"; from: 1.0; to: 0; duration: 380; easing.type: Easing.OutCubic }
        }
    }

    // ── CONFETTI — inaonekana END screen kama IQ >= 110 ──────────────────
    Timer {
        id: confettiLaunchTimer
        interval: 400
        repeat: false
        onTriggered: confettiCanvas.launch()
    }

    Canvas {
        id: confettiCanvas
        anchors.fill: parent
        z: 998
        opacity: 0
        visible: opacity > 0

        property var pieces: []

        function launch() {
            pieces = [];
            for (var i = 0; i < 80; i++) {
                pieces.push({
                    x:     Math.random() * width,
                    y:    -20 - Math.random() * 120,
                    vx:    (Math.random() - 0.5) * 5,
                    vy:    2 + Math.random() * 5,
                    r:     Math.random() * 7 + 3,
                    color: ["#00e5ff","#f0c040","#4caf50","#ef4444","#ffffff","#ff69b4"][Math.floor(Math.random()*6)],
                    rot:   Math.random() * 360,
                    vrot:  (Math.random() - 0.5) * 8
                });
            }
            opacity = 1;
            confettiTimer.start();
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            for (var i = 0; i < pieces.length; i++) {
                var p = pieces[i];
                ctx.save();
                ctx.translate(p.x, p.y);
                ctx.rotate(p.rot * Math.PI / 180);
                ctx.fillStyle = p.color;
                ctx.fillRect(-p.r / 2, -p.r * 0.3, p.r, p.r * 0.6);
                ctx.restore();
            }
        }

        Behavior on opacity { NumberAnimation { duration: 400 } }

        Timer {
            id: confettiTimer
            interval: 30
            repeat: true
            onTriggered: {
                var alive = false;
                for (var i = 0; i < confettiCanvas.pieces.length; i++) {
                    var p = confettiCanvas.pieces[i];
                    p.x   += p.vx;
                    p.y   += p.vy;
                    p.vy  += 0.12;
                    p.rot += p.vrot;
                    if (p.y < confettiCanvas.height + 20) alive = true;
                }
                if (!alive) {
                    confettiTimer.stop();
                    confettiCanvas.opacity = 0;
                    return;
                }
                confettiCanvas.requestPaint();
            }
        }
    }
    // ─────────────────────────────────────────────────────────────────────
}
