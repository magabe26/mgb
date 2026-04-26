import QtQuick 2.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtMultimedia 5.14
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0

Rectangle {
    id: app
    width: parent.width
    height: parent.height
    color: "transparent"

    property string selectedLanguage: "" // "en" or "sw"
    property int currentAttractionIndex: 0
    property int appMode: 2
    property string searchText: ""
    property string activeFilter: "All"          // category filter — always English key
    property var recentlyViewed: []              // recently viewed indices
    property bool safariTvVisible: false         // retro TV overlay
    property bool wakeLockTipShown: false        // screen-on tip shown once
    property bool articleViewVisible: false      // Tanzania article overlay
    property string articleLang: ""             // language for article view
    property real articleFontScale: articleFontSettings.scale  // persisted via QSettings
    property string safariChannelStreamURL: ""
    property int safariChannelMode: 1

    Settings {
        id: langSettings
        property string lang: "sw"
    }

    Settings {
        id: safariChannelModeSettings
        category: "safariChannelMode"
        property int cachedMode: 1
    }

    Settings {
        id: articleCacheSettings
        category: "articleCache"
        property string htmlSw: ""
        property string htmlEn: ""
    }

    Settings {
        id: articleFontSettings
        category: "articleFont"
        property real scale: 1.0
    }

    // ── fetch & cache Tanzania article HTML ──────────────────────────────
    function fetchArticle(lang) {
        var url = lang === "sw"
                ? "https://raw.githubusercontent.com/magabe26/mgb/refs/heads/master/tztourism/images/tz-sw.html"
                : "https://raw.githubusercontent.com/magabe26/mgb/refs/heads/master/tztourism/images/tz-en.html";

        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.timeout = 12000;

        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;
            if (xhr.status === 200) {
                var html = xhr.responseText;
                if (html.trim() !== "") {
                    if (lang === "sw") {
                        articleCacheSettings.htmlSw = html;
                    } else {
                        articleCacheSettings.htmlEn = html;
                    }
                    articleCacheSettings.sync();
                    // refresh display if this lang is currently showing
                    if (app.articleViewVisible && app.articleLang === lang) {
                        articleWebView.showContent(lang);
                    }
                }
            }
        };

        xhr.ontimeout = function() { /* silently use cache */ };
        xhr.onerror  = function() { /* silently use cache */ };

        xhr.send();
    }

    // ── fetch safari channel mode from remote config ─────────────────────────────────────
    function fetchSafariChannelMode() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://raw.githubusercontent.com/magabe26/mgb/refs/heads/master/safari-channel-mode.config", true);
        xhr.timeout = 8000;

        app.safariChannelMode = safariChannelModeSettings.cachedMode;

        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;

            if (xhr.status === 200) {
                var raw = xhr.responseText.trim();
                var parsed = parseInt(raw, 10);
                app.safariChannelMode = parsed;
                safariChannelModeSettings.cachedMode = parsed;
                safariChannelModeSettings.sync();
            } else {
                app.safariChannelMode = safariChannelModeSettings.cachedMode;
            }
        };

        xhr.ontimeout = function() {
            app.safariChannelMode = safariChannelModeSettings.cachedMode;
        };

        xhr.onerror = function() {
            app.safariChannelMode = safariChannelModeSettings.cachedMode;
        };

        xhr.send();
    }

    Component.onCompleted: {
        fetchSafariChannelMode();
        fetchArticle("sw");
        fetchArticle("en");
    }

    function animateBackToFrontPage(){
        app.selectedLanguage = langSettings.lang;
        viewComponentLoader.switchTo(languageSelectionComponent, app.width / 2, app.height / 2);
        app.selectedLanguage = "";
        app.ad();
    }

    // ── Android back button ────────────────────────────────────────────
    Keys.onBackPressed: {
        if (contextMenu.visible) {
            contextMenu.close();
            event.accepted = true;
        } else if (modeSelectionDialog.visible) {
            modeSelectionDialog.close();
            event.accepted = true;
        } else if (app.articleViewVisible) {
            app.articleViewVisible = false;
            app.articleLang = "";
            event.accepted = true;
        } else if (safariTvOverlay.tvFullScreen) {
            safariTvOverlay.tvFullScreen = false;
            fsLayer.videoRotation = 0;
            event.accepted = true;
        } else if (app.selectedLanguage !== "") {
            app.searchText = "";
            viewComponentLoader.switchTo(languageSelectionComponent, app.width / 2, app.height / 2);
            app.selectedLanguage = "";
            event.accepted = true;
        } else {
            event.accepted = false;
        }
    }

    function addRecentlyViewed(idx) {
        var thumbW  = Qt.platform.os === "android" ? 90 : 72;
        var spacing = 8;
        var padding = 20; // left + right margin
        var maxCount = Math.max(1, Math.floor((app.width - padding) / (thumbW + spacing)));

        var arr = app.recentlyViewed.slice();
        var pos = arr.indexOf(idx);
        if (pos !== -1) arr.splice(pos, 1);
        arr.unshift(idx);
        if (arr.length > maxCount) arr = arr.slice(0, maxCount);
        app.recentlyViewed = arr;
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


    ListModel {
        id: attractionModel

        ListElement {
            name_en: "Mount Kilimanjaro"; name_sw: "Mlima Kilimanjaro"
            imageFile: "./kilimanjaro.jpg"
            desc_en: "Africa's highest peak and a dormant volcano. A challenging but rewarding climb for adventurers."
            desc_sw: "Mlima mrefu zaidi Afrika na volkano iliyolala. Changamoto lakini yenye thawabu kwa wapandaji wajasiri."
        }

        ListElement {
            name_en: "Mikumi National Park"; name_sw: "Hifadhi ya Taifa ya Mikumi"
            imageFile: "./mikumi.jpg"
            desc_en: "Escape the city! It's an easy drive: dar mpaka moro and beyond. See giraffes, lions, elephants, zebras, and wildebeest. The wild awaits!"
            desc_sw: "Toroka jiji! Ni safari rahisi: dar mpaka moro na kuendelea. Tazama twiga, simba, tembo, punda milia, na nyumbu. Pori linakusubiri!"
        }


        ListElement {
            name_en: "Ngorongoro Conservation Area"; name_sw: "Mamlaka ya Hifadhi ya Ngorongoro"
            imageFile: "./ngorongoro.jpg"
            desc_en: "Home to the Ngorongoro Crater, a large volcanic caldera teeming with diverse wildlife."
            desc_sw: "Makao ya Kreta ya Ngorongoro, kaldera kubwa ya volkano iliyojaa wanyamapori mbalimbali."
        }

        ListElement {
            name_en: "Kitulo National Park"; name_sw: "Hifadhi ya Taifa ya Kitulo"
            imageFile: "./kitulo.jpg"
            desc_en: "Known as the 'Garden of God', this unique montane grassland is famous for its spectacular seasonal wildflower displays."
            desc_sw: "Inajulikana kama 'Bustani ya Mungu', nyanda hii ya kipekee ya milimani ni maarufu kwa maonyesho yake mazuri ya maua ya porini ya msimu."
        }

        ListElement {
            name_en: "Serengeti National Park"; name_sw: "Hifadhi ya Taifa ya Serengeti"
            imageFile: "./serengeti.jpg"
            desc_en: "Vast plains, famous for the annual wildebeest migration, offering unparalleled safari experiences."
            desc_sw: "Nyanda pana, maarufu kwa uhamaji mkuu wa nyumbu kila mwaka, inayotoa uzoefu wa safari usio na kifani."
        }

        ListElement {
            name_en: "Zanzibar (Stone Town & Beaches)"; name_sw: "Zanzibar (Mji Mkongwe na Fukwe)"
            imageFile: "./zanzibar_st2.jpg"
            desc_en: "Historic Stone Town, spice farms, and pristine beaches make Zanzibar a unique cultural and relaxation hub."
            desc_sw: "Mji Mkongwe wa kihistoria, mashamba ya viungo, na fukwe safi hufanya Zanzibar kuwa kitovu cha kipekee cha utamaduni na mapumziko."
        }


        ListElement {
            name_en: "Tarangire National Park"; name_sw: "Hifadhi ya Taifa ya Tarangire"
            imageFile: "./tarangire.jpg"
            desc_en: "Known for its large elephant herds, iconic baobab trees, and diverse birdlife."
            desc_sw: "Inajulikana kwa makundi makubwa ya tembo, miti ya mibuyu ya kipekee, na aina mbalimbali za ndege."
        }


        ListElement {
            name_en: "Bodaboda & Bajaji Transport, Tanzania"
            name_sw: "Usafiri wa Bodaboda na Bajaji, Tanzania"
            imageFile: "./bodaboda_bajaji.jpg"
            desc_en: "The most iconic and efficient way to navigate Tanzanian streets. Experience the city like a local with Bajaji for a breezy ride or Bodaboda to beat the traffic."
            desc_sw: "Njia maarufu na bora ya kuzunguka mitaa ya Tanzania. Ishi kama mzawa kwa kutumia Bajaji kufurahia upepo mwanana au Bodaboda kuwahi unakokwenda bila kukwama kwenye foleni."
        }

        ListElement {
            name_en: "Lake Victoria"; name_sw: "Ziwa Victoria"
            imageFile: "./victoria.jpg"
            desc_en: "Experience Lake Victoria, Mwanza: Africa's largest lake. Enjoy stunning sunsets over Bismarck Rock, island safaris, and vibrant local culture. A true Tanzanian gem!"
            desc_sw: "Furahia Ziwa Victoria, Mwanza: Ziwa kubwa Afrika. Tazama machweo mazuri juu ya Mwamba Bismarck, safari za visiwa, na utamaduni hai. Hazina halisi ya Tanzania!"
        }

        ListElement {
            name_en: "Lake Manyara National Park"; name_sw: "Hifadhi ya Taifa ya Ziwa Manyara"
            imageFile: "./manyara.jpg"
            desc_en: "Famous for its tree-climbing lions, flamingos, and stunning Rift Valley scenery."
            desc_sw: "Maarufu kwa simba wanaopanda miti, flamingo, na mandhari ya kuvutia ya Bonde la Ufa."
        }

        ListElement {
            name_en: "Rubondo Island National Park"; name_sw: "Hifadhi ya Taifa ya Kisiwa cha Rubondo"
            imageFile: "./rubondo.jpg"
            desc_en: "An island sanctuary on Lake Victoria, home to elephants, chimpanzees, sitatunga, and a diverse birdlife, ideal for walking safaris."
            desc_sw: "Hifadhi ya kisiwa kwenye Ziwa Victoria, makazi ya tembo, sokwe, sitatunga, na ndege mbalimbali, inayofaa kwa safari za kutembea."
        }


        ListElement {
            name_en: "Nyerere National Park"; name_sw: "Hifadhi ya Taifa ya Nyerere"
            imageFile: "./nyerere.jpg"
            desc_en: "One of Africa's largest game reserves, offering boat safaris and encounters with wild dogs."
            desc_sw: "Moja ya hifadhi kubwa za wanyama Afrika, inayotoa safari za boti na kukutana na mbwa mwitu."
        }

        ListElement {
            name_en: "Ruaha National Park"; name_sw: "Hifadhi ya Taifa ya Ruaha"
            imageFile: "./ruaha.jpg"
            desc_en: "Tanzania's largest national park, a remote wilderness with rugged landscapes and abundant wildlife."
            desc_sw: "Hifadhi kubwa zaidi ya taifa Tanzania, pori la mbali lenye mandhari na wanyamapori wengi."
        }

        ListElement {
            name_en: "Kizimkazi Dolphin Safari"; name_sw: "Utalii wa Pomboo Kizimkazi"
            imageFile: "./kizimkazi-d.jpeg"
            desc_en: "Dive into the blue waters of Kizimkazi, Zanzibar. Experience the thrill of swimming with wild dolphins in their natural habitat and visit historical mosques."
            desc_sw: "Zama kwenye maji ya bluu ya Kizimkazi, Zanzibar. Shuhudia msisimko wa kuogelea na pomboo katika mazingira yao ya asili na utembelee misikiti ya kihistoria."
        }

        ListElement {
            name_en: "Katavi National Park"; name_sw: "Hifadhi ya Taifa ya Katavi"
            imageFile: "./katavi.jpg"
            desc_en: "A remote and wild park known for large concentrations of game during the dry season."
            desc_sw: "Hifadhi ya mbali na pori inayojulikana kwa mikusanyiko mikubwa ya wanyama wakati wa kiangazi."
        }

        ListElement {
            name_en: "Rubya Forest, Ukerewe"; name_sw: "Msitu wa Rubya, Ukerewe"
            imageFile: "./rubya.jpeg"
            desc_en: "Discover the hidden tranquility of Ukerewe Island. Explore the lush Rubya Forest and enjoy the serene beaches of Africa's largest inland island."
            desc_sw: "Gundua utulivu wa siri wa Kisiwa cha Ukerewe. Pekua Msitu mnene wa Rubya na ufurahie fukwe tulivu za kisiwa kikubwa zaidi cha ndani nchini Afrika."
        }
        ListElement {
            name_en: "Olduvai Gorge"; name_sw: "Bonde la Olduvai"
            imageFile: "./olduvai.jpg"
            desc_en: "A crucial paleoanthropological site holding evidence of early human evolution."
            desc_sw: "Eneo muhimu la paleoanthropolojia lenye ushahidi wa mageuzi ya awali ya binadamu."
        }

        ListElement {
            name_en: "Kigoma Town & Lake Tanganyika"; name_sw: "Mji wa Kigoma & Ziwa Tanganyika"
            imageFile: "./kigoma.jpg"
            desc_en: "A historic port town on Lake Tanganyika, offering boat trips, fishing, and a glimpse into local life by the world's second deepest lake."
            desc_sw: "Mji wa bandari wa kihistoria kwenye Ziwa Tanganyika, unaotoa safari za boti, uvuvi, na fursa ya kuona maisha ya wenyeji karibu na ziwa la pili kwa kina duniani."
        }

        ListElement {
            name_en: "Saadani National Park"; name_sw: "Hifadhi ya Taifa ya Saadani"
            imageFile: "./saadani.jpg"
            desc_en: "Tanzania's only coastal national park, where the bush meets the beach, offering unique land and boat safaris."
            desc_sw: "Hifadhi ya pekee ya taifa ya pwani Tanzania, ambapo msitu hukutana na fukwe, ikitoa safari za kipekee za ardhini na majini."
        }

        ListElement {
            name_en: "Mafia Island Marine Park"; name_sw: "Hifadhi ya Bahari ya Kisiwa cha Mafia"
            imageFile: "./mafia_island.jpg"
            desc_en: "Pristine coral reefs, a haven for divers and snorkelers, and a seasonal home for whale sharks."
            desc_sw: "Miamba ya matumbawe safi, kimbilio la wapiga mbizi, na makazi ya msimu ya papa nyangumi."
        }

        ListElement {
            name_en: "Amboni Caves"; name_sw: "Mapango ya Amboni"
            imageFile: "./amboni_caves.jpg"
            desc_en: "A vast limestone cave system near Tanga, significant culturally and historically, with impressive formations."
            desc_sw: "Mfumo mkubwa wa mapango ya chokaa karibu na Tanga, muhimu kiutamaduni na kihistoria, na maumbo ya kuvutia."
        }


        ListElement {
            name_en: "Selous Game Reserve (part of Nyerere NP)"; name_sw: "Hifadhi ya Wanyama ya Selous"
            imageFile: "./selous.jpg"
            desc_en: "One of Africa's largest protected areas (now largely Nyerere NP), known for its vastness, wildness, and diverse wildlife."
            desc_sw: "Moja ya maeneo makubwa zaidi yaliyohifadhiwa barani Afrika (sasa sehemu kubwa ni Hifadhi ya Taifa ya Nyerere), inayojulikana kwa ukubwa wake, pori, na wanyamapori mbalimbali."
        }

        ListElement {
            name_en: "Mkomazi National Park"; name_sw: "Hifadhi ya Taifa ya Mkomazi"
            imageFile: "./mkomazi.jpg"
            desc_en: "A semi-arid park bordering Tsavo in Kenya, crucial for black rhino and wild dog conservation, offering a rugged safari experience."
            desc_sw: "Hifadhi ya nusu-jangwa inayopakana na Tsavo nchini Kenya, muhimu kwa uhifadhi wa faru weusi na mbwa mwitu, ikitoa uzoefu mgumu wa safari."
        }


        ListElement {
            name_en: "Kaporogwe Falls, Mbeya"
            name_sw: "Maporomoko ya Kaporogwe, Mbeya"
            imageFile: "./kaporogwe_falls.jpeg"
            desc_en: "One of Mbeya's most beautiful waterfalls, hidden behind a massive basalt rock curtain with a natural cave behind the falling water."
            desc_sw: "Moja ya maporomoko mazuri zaidi Mbeya, yakiwa yamefichwa nyuma ya ukuta wa mwamba na pango la asili lililopo ndani ya maji yanayoporomoka."
        }



        ListElement {
            name_en: "Kalambo Falls, Rukwa"; name_sw: "Maporomoko ya Kalambo, Rukwa"
            imageFile: "./kalambo.jpeg"
            desc_en: "Visit Africa's second-highest single-drop waterfall on the border of Tanzania and Zambia. A breathtaking 221-meter plunge into the depths of the gorge!"
            desc_sw: "Tembelea maporomoko ya pili kwa urefu barani Afrika yaliyo mpakani mwa Tanzania na Zambia. Shuhudia maji yakiporomoka mita 221 kuelekea chini ya korongo!"
        }

        ListElement {
            name_en: "Materuni Falls, Moshi"; name_sw: "Maporomoko ya Materuni, Moshi"
            imageFile: "./Materuni.jpg"
            desc_en: "Hidden at the foot of Mt. Kilimanjaro, Materuni is a lush paradise. Enjoy a scenic hike through coffee plantations followed by a refreshing dip in the cool waters."
            desc_sw: "Yakiwa yamejificha chini ya mlima Kilimanjaro, Materuni ni paradiso ya kijani. Furahia safari ya miguu kupitia mashamba ya kahawa na kuogelea kwenye maji baridi."
        }


        ListElement {
            name_en: "Sanje Falls, Udzungwa"; name_sw: "Maporomoko ya Sanje, Udzungwa"
            imageFile: "./sanje.jpg"
            desc_en: "Located in the Udzungwa Mountains National Park, Sanje Falls drops 170 meters through a misty rainforest. Home to rare primates and stunning biodiversity."
            desc_sw: "Yapo ndani ya Hifadhi ya Taifa ya Udzungwa, maporomoko ya Sanje yanashuka mita 170 katikati ya msitu wa mvua wenye kima adimu na viumbe wa kipekee."
        }


        ListElement {
            name_en: "Marangu Falls, Kilimanjaro"; name_sw: "Maporomoko ya Marangu, Kilimanjaro"
            imageFile: "./marangu.jpeg"
            desc_en: "Experience the beauty of the Ndoro and Monjo falls in Marangu. Learn about the rich Chagga culture and enjoy the serene atmosphere of these hidden gems."
            desc_sw: "Shuhudia uzuri wa maporomoko ya Ndoro na Monjo kule Marangu. Jifunze utamaduni tajiri wa Wachagga na ufurahie utulivu wa hazina hizi zilizojificha."
        }

        ListElement {
            name_en: "Choma Waterfalls, Morogoro"; name_sw: "Maporomoko ya Choma, Morogoro"
            imageFile: "./choma_falls.jpg"
            desc_en: "Located in the Uluguru Mountains, these falls offer a refreshing hike and a chance to experience the local Luguru culture."
            desc_sw: "Yatapatikana katika milima ya Uluguru, maporomoko haya yanatoa fursa ya kupanda milima na kujifunza utamaduni wa Waluguru."
        }


        ListElement {
            name_en: "Tururu Waterfalls, Babati"
            name_sw: "Maporomoko ya Tururu, Babati"
            imageFile: "./tururu_waterfalls.jpeg"
            desc_en: "Discover the hidden paradise of Babati! Tururu Waterfall offers a refreshing escape surrounded by lush vegetation and rocky landscapes. Perfect for hikers and nature lovers looking for a serene experience away from the crowds."
            desc_sw: "Gundua paradiso iliyofichika kule Babati! Maporomoko ya Tururu yanatoa nafasi ya kipekee ya kupumzika huku ukiwa umezungukwa na uoto wa asili na mandhari ya kuvutia ya miamba. Ni mahali pazuri kwa wapenzi wa matembezi ya miguu na asili."
        }

        ListElement {
            name_en: "Udzungwa Mountains National Park"; name_sw: "Hifadhi ya Taifa ya Milima ya Udzungwa"
            imageFile: "./udzungwa.jpg"
            desc_en: "A biodiverse montane forest, excellent for hiking and spotting endemic primate species."
            desc_sw: "Msitu wa milimani wenye bioanuwai nyingi, bora kwa matembezi na kuona aina za nyani za kipekee."
        }

        ListElement {
            name_en: "Mount Meru"; name_sw: "Mlima Meru"
            imageFile: "./meru.jpg"
            desc_en: "An active stratovolcano and Tanzania's second highest peak, located in Arusha National Park."
            desc_sw: "Volkano hai ya tabaka na mlima wa pili kwa urefu Tanzania, uliopo katika Hifadhi ya Taifa ya Arusha."
        }

        ListElement {
            name_en: "Usambara Mountains"; name_sw: "Milima ya Usambara"
            imageFile: "./usambara.jpg"
            desc_en: "Lush, cool mountains offering rich biodiversity, scenic views, and excellent hiking opportunities."
            desc_sw: "Milima yenye uoto mwingi na hali ya hewa ya baridi, inayotoa bioanuwai tele, mandhari nzuri, na fursa bora za matembezi."
        }

        ListElement {
            name_en: "Mahale Mountains National Park"; name_sw: "Hifadhi ya Taifa ya Milima ya Mahale"
            imageFile: "./mahale.jpg"
            desc_en: "Home to chimpanzees on the shores of Lake Tanganyika, offering unique primate tracking experiences."
            desc_sw: "Makao ya sokwe pembezoni mwa Ziwa Tanganyika, inayotoa uzoefu wa kipekee wa kufuatilia nyani."
        }

        ListElement {
            name_en: "Isimila Stone Age Site, Iringa"; name_sw: "Eneo la Zama za Mawe la Isimila, Iringa"
            imageFile: "./isimila.jpg"
            desc_en: "Features towering sandstone pillars and ancient stone tools from thousands of years ago."
            desc_sw: "Ina nguzo ndefu za mchanga na zana za mawe za kale za maelfu ya miaka iliyopita."
        }

        ListElement {
            name_en: "Lake Duluti, Arusha"; name_sw: "Ziwa Duluti, Arusha"
            imageFile: "./duluti.jpeg"
            desc_en: "A peaceful volcanic crater lake near Arusha, ideal for canoeing."
            desc_sw: "Ziwa tulivu la volkano karibu na Arusha, linafaa kwa kuendesha mitumbwi."
        }

        ListElement {
            name_en: "Lake Eyasi, Arusha"; name_sw: "Ziwa Eyasi, Arusha"
            imageFile: "./eyasi.jpeg"
            desc_en: "Home to the Hadzabe tribe, one of the last hunter-gatherer groups in Africa."
            desc_sw: "Makazi ya kabila la Wahadzabe, wawindaji na waokota matunda wa mwisho Afrika."
        }

        ListElement {
            name_en: "Ibanda-Kyerwa National Park"; name_sw: "Hifadhi ya Taifa ya Ibanda-Kyerwa"
            imageFile: "./ibanda.jpeg"
            desc_en: "Scenic park in Kagera region featuring rolling hills and acacia woodlands."
            desc_sw: "Hifadhi nzuri mkoani Kagera yenye vilima na misitu ya miiba."
        }

        ListElement {
            name_en: "Rumanyika-Karagwe National Park"; name_sw: "Hifadhi ya Taifa ya Rumanyika-Karagwe"
            imageFile: "./rumanyika.jpeg"
            desc_en: "A haven for wild animals and birds in the northwest of Tanzania."
            desc_sw: "Makazi ya wanyamapori na ndege kaskazini-magharibi mwa Tanzania."
        }

        ListElement {
            name_en: "Bird Watching, Serengeti";
            name_sw: "Kushuhudia Ndege, Serengeti"
            imageFile: "./serengeti_birds.jpg"
            desc_en: "Serengeti is home to over 500 bird species, making it a paradise for bird lovers and photographers."
            desc_sw: "Serengeti ina aina zaidi ya 500 za ndege, na kuifanya kuwa pepo kwa wapenzi wa ndege na wapiga picha."
        }


        ListElement {
            name_en: "Pemba Island";
            name_sw: "Kisiwa cha Pemba"
            imageFile: "./Pemba-Island-2.jpg"
            desc_en: "Part of the Zanzibar Archipelago, known as the 'Green Island' for its lush vegetation, cloves, and diving spots."
            desc_sw: "Sehemu ya Visiwa vya Zanzibar, inayojulikana kama 'Kisiwa cha Kijani' kwa uoto wake mwingi, karafuu, na maeneo ya kupiga mbizi."
        }

        ListElement {
            name_en: "Mafia Island Marine Park, Pwani"
            name_sw: "Hifadhi ya Bahari ya Mafia, Pwani"
            imageFile: "./mafia_marine_park.jpg"
            desc_en: "A paradise for divers and snorkelers, famous for its whale shark sightings and pristine coral reefs in the Indian Ocean."
            desc_sw: "Pepo kwa wapiga mbizi, inasifika kwa kuonekana kwa papa msumeno (whale sharks) na matumbawe asilia ndani ya Bahari ya Hindi."
        }

        ListElement {
            name_en: "Saane Island National Park, Mwanza"
            name_sw: "Hifadhi ya Taifa ya Kisiwa cha Saane, Mwanza"
            imageFile: "./saane_island.jpeg"
            desc_en: "The smallest national park in Tanzania, located on a rocky island in Lake Victoria. It's a perfect spot for walking safaris and bird watching near the city."
            desc_sw: "Hifadhi ya taifa ndogo kuliko zote Tanzania, inayopatikana kwenye kisiwa cha mawe ndani ya Ziwa Victoria. Ni eneo zuri kwa utalii wa kutembea na kuona ndege karibu na mjini."
        }

        ListElement {
            name_en: "Mangrove Forests, Kilwa";
            name_sw: "Misitu ya Mikoko, Kilwa"
            imageFile: "./kilwa_mangroves.jpg"
            desc_en: "Explore the dense mangrove ecosystems along the Indian Ocean, crucial for marine life and coastal protection."
            desc_sw: "Gundua mfumo wa ikolojia wa mikoko kando ya Bahari ya Hindi, ambayo ni muhimu kwa viumbe wa baharini na ulinzi wa pwani."
        }

        ListElement {
            name_en: "Longuza Forest Plantation, Tanga"; name_sw: "Shamba la Miti Longuza, Tanga"
            imageFile: "./longuza_forest.jpeg"
            desc_en: "A lush, green escape in Tanga known for its massive teak trees, botanical diversity, and serene environment for nature walks."
            desc_sw: "Pepo ya kijani mkoani Tanga inayojulikana kwa miti mikubwa ya msaji (Teak), aina nyingi za mimea, na mazingira tulivu kwa matembezi."
        }

        ListElement {
            name_en: "Kigosi National Park"; name_sw: "Hifadhi ya Taifa ya Kigosi"
            imageFile: "./kigosi.jpg"
            desc_en: "A vast wetland ecosystem protecting rare water birds and sitatunga antelopes."
            desc_sw: "Mfumo mkubwa wa ardhi oevu unaolinda ndege wa majini na swala wa sitatunga."
        }

        ListElement {
            name_en: "Burigi-Chato National Park"; name_sw: "Hifadhi ya Taifa ya Burigi-Chato"
            imageFile: "./burigi.jpeg"
            desc_en: "One of Tanzania's newest parks featuring Lake Burigi and diverse wildlife."
            desc_sw: "Moja ya hifadhi mpya zaidi ikiwa na Ziwa Burigi na wanyamapori wa aina mbalimbali."
        }

        ListElement {
            name_en: "Mbozi Meteorite, Mbeya"; name_sw: "Kimondo cha Mbozi, Mbeya"
            imageFile: "./mbozi_meteorite.jpeg"
            desc_en: "One of the world's largest meteorites, a massive iron block from space."
            desc_sw: "Moja ya vimondo vikubwa zaidi duniani, kipande kikubwa cha chuma kutoka angani."
        }

        ListElement {
            name_en: "Kiwira River & God's Bridge"; name_sw: "Mto Kiwira na Daraja la Mungu"
            imageFile: "./gods_bridge.jpeg"
            desc_en: "A natural stone bridge formed by the Kiwira River in Rungwe district."
            desc_sw: "Daraja la asili la jiwe lililotokana na Mto Kiwira katika wilaya ya Rungwe."
        }


        ListElement {
            name_en: "Shamiani Island, Pemba";
            name_sw: "Kisiwa cha Shamiani, Pemba"
            imageFile: "./shamiani_island.jpg"
            desc_en: "A hidden gem in Pemba, Shamiani is famous for its white sandy beaches and the rare green sea turtles that nest along its shores."
            desc_sw: "Tunzo iliyofichwa kule Pemba, Shamiani ni maarufu kwa fukwe za mchanga mweupe na kobe wa kijani adimu wanaotaga kando ya pwani yake."
        }

        ListElement {
            name_en: "Amani Museum, Zanzibar";
            name_sw: "Makumbusho ya Amani, Zanzibar"
            imageFile: "./amani_museum.jpg"
            desc_en: "A historic site in Stone Town dedicated to showcasing the peace and heritage of the Zanzibar islands."
            desc_sw: "Eneo la kihistoria ndani ya Mji Mkongwe linalojitolea kuonyesha amani na urithi wa visiwa vya Zanzibar."
        }

        ListElement {
            name_en: "National Museum, Dar es Salaam"; name_sw: "Makumbusho ya Taifa, Dar es Salaam"
            imageFile: "./national_museum_dar.jpeg"
            desc_en: "The heart of Tanzania's heritage, featuring the famous Zinjanthropus skull, traditional crafts, and the history of the struggle for independence."
            desc_sw: "Kiini cha urithi wa Tanzania, kikiwa na fuvu maarufu la Zinjanthropus, kazi za mikono za asili, na historia ya harakati za uhuru."
        }

        ListElement {
            name_en: "Museum of Natural History, Zanzibar"; name_sw: "Makumbusho ya Viumbe, Zanzibar"
            imageFile: "./zanzibar_nature_museum.jpg"
            desc_en: "A fascinating collection showcasing the diverse fauna and flora of the Zanzibar Archipelago, from marine life to indigenous bird species."
            desc_sw: "Mkusanyiko wa kuvutia unaoonyesha wanyama na mimea mbalimbali wa visiwa vya Zanzibar, kuanzia viumbe wa baharini hadi ndege wa asili."
        }



        ListElement {
            name_en: "Lake Natron"; name_sw: "Ziwa Natron"
            imageFile: "./natron.jpg"
            desc_en: "A shallow, alkaline lake famous as a breeding ground for lesser flamingos, with dramatic landscapes."
            desc_sw: "Ziwa la chumvi lisilo na kina kirefu, maarufu kama eneo la kuzaliana flamingo wadogo, lenye mandhari ya kuvutia."
        }


        ListElement {
            name_en: "Bagamoyo";
            name_sw: "Bagamoyo"
            imageFile: "./bagamoyo.jpg"
            desc_en: "A historic coastal town with a rich past as a former slave trade port, featuring colonial architecture and cultural sites."
            desc_sw: "Mji wa kihistoria wa pwani wenye historia tajiri kama bandari ya zamani ya biashara ya watumwa, yenye usanifu wa kikoloni na maeneo ya kitamaduni."
        }

        ListElement {
            name_en: "Kilwa Kisiwani Ruins, Lindi"; name_sw: "Magofu ya Kilwa Kisiwani, Lindi"
            imageFile: "./kilwa_ruins.jpg"
            desc_en: "A UNESCO World Heritage site featuring the Great Mosque and the Palace of Husuni Kubwa."
            desc_sw: "Eneo la Urithi wa Dunia la UNESCO lenye Msikiti Mkuu na Jumba la kifalme la Husuni Kubwa."
        }


        ListElement {
            name_en: "Kuumbi Cave, Unguja";
            name_sw: "Pango la Kuumbi, Unguja"
            imageFile: "./kuumbi_cave.jpeg"
            desc_en: "A significant archaeological site in Zanzibar, this ancient limestone cave holds secrets of early human life dating back over 20,000 years."
            desc_sw: "Eneo muhimu la kiakiolojia nchini Zanzibar, pango hili la kale la chokaa lina siri za maisha ya binadamu wa kale tangu miaka 20,000 iliyopita."
        }



        ListElement {
            name_en: "George Lilanga Art, Dar es Salaam"; name_sw: "Sanaa ya George Lilanga, Dar es Salaam"
            imageFile: "./lilanga_art.jpg"
            desc_en: "Celebrate the world-renowned 'Shetani' paintings and sculptures of George Lilanga, whose whimsical Makonde style influenced modern global art."
            desc_sw: "Sherehekea michoro na vinyago vya 'Shetani' vya George Lilanga, ambaye mtindo wake wa Kimakonde uliathiri sanaa ya kisasa duniani."
        }

        ListElement {
            name_en: "Kondoa Rock Art Sites"; name_sw: "Michoro ya Mapangoni, Kondoa"
            imageFile: "./kondoa.jpg"
            desc_en: "Explore the UNESCO World Heritage site in Dodoma. Marvel at ancient rock paintings in Kondoa that tell stories of thousands of years of human history."
            desc_sw: "Gundua urithi wa dunia wa UNESCO mkoani Dodoma. Shuhudia michoro ya kale ya mapangoni Kondoa inayoelezea maelfu ya miaka ya historia ya mwanadamu."
        }


        ListElement {
            name_en: "Kolo Rock Paintings"; name_sw: "Michoro ya Miamba ya Kolo"
            imageFile: "./kolo_rock_paintings.jpg"
            desc_en: "Ancient rock art sites in Kondoa Irangi, offering insights into early human history and culture in Tanzania."
            desc_sw: "Maeneo ya kale ya sanaa ya miamba huko Kondoa Irangi, yakitoa ufafanuzi wa historia na utamaduni wa awali wa binadamu nchini Tanzania."
        }



        ListElement {
            name_en: "The German Boma, Bagamoyo";
            name_sw: "Boma la Mjerumani, Bagamoyo"
            imageFile: "./bagamoyo_boma.jpg"
            desc_en: "Built in 1895, this historic administrative building served as the headquarters for German East Africa, overlooking the Indian Ocean."
            desc_sw: "Lilijengwa mwaka 1895, jengo hili la kihistoria lilikuwa makao makuu ya utawala wa Kijerumani Afrika Mashariki, likitazama Bahari ya Hindi."
        }

        ListElement {
            name_en: "Vikindu Nature Forest Reserve"; name_sw: "Hifadhi ya Mazingira Asilia Vikindu"
            imageFile: "./vikindu_forest.jpeg"
            desc_en: "A vital sanctuary for biodiversity, Vikindu protects rare indigenous trees and provides a peaceful habitat for forest-dwelling birds and monkeys."
            desc_sw: "Hifadhi muhimu kwa viumbe hai, Vikindu inalinda miti ya asili adimu na kutoa makazi tulivu kwa ndege wa msituni na kima."
        }

        ListElement {
            name_en: "Arusha National Park"; name_sw: "Hifadhi ya Taifa ya Arusha"
            imageFile: "./arusha_np.jpg"
            desc_en: "Offers diverse landscapes including Mount Meru, Momella Lakes, and Ngurdoto Crater."
            desc_sw: "Inatoa mandhari mbalimbali ikiwa ni pamoja na Mlima Meru, Maziwa ya Momella, na Kreta ya Ngurdoto."
        }

        ListElement {
            name_en: "Kawetile View Point, Mbeya"; name_sw: "Eneo la Utazamaji la Kawetile, Mbeya"
            imageFile: "./kawetile_view.jpeg"
            desc_en: "Perched high in the Southern Highlands, Kawetile offers a breathtaking panoramic view of Mbeya city and the rolling green hills that define the region."
            desc_sw: "Likiwa juu kabisa katika nyanda za juu kusini, Kawetile inatoa mandhari ya kipekee ya mji wa Mbeya na vilima vya kijani vinavyopamba mkoa huo."
        }


        ListElement {
            name_en: "Lukwika-Lumesule Reserve, Nanyumbu"; name_sw: "Pori la Akiba Lukwika-Lumesule, Nanyumbu"
            imageFile: "./Lukwika-Lumesule.jpg"
            desc_en: "A wild frontier in Mtwara featuring Miombo woodlands, the Ruvuma River, and historic caves used by refugees during the Mozambican War. Home to hippos, crocodiles, and antelopes."
            desc_sw: "Pori la ajabu mkoani Mtwara lenye misitu ya Miombo, Mto Ruvuma, na mapango ya kihistoria yaliyotumiwa na wakimbizi wa Msumbiji. Kuna viboko, mamba, na swala."
        }

        ListElement {
            name_en: "The Art of Henna (Piko)";
            name_sw: "Sanaa ya Piko (Henna)"
            imageFile: "./pico-henna.jpg"
            desc_en: "A beautiful Swahili tradition where intricate floral and geometric patterns are painted on hands and feet using natural henna, often for weddings and festivals."
            desc_sw: "Utamaduni maridadi wa Kiswahili ambapo michoro ya maua na nakshi huchorwa mikononi na miguuni kwa kutumia piko asilia, mara nyingi wakati wa harusi na sherehe."
        }

        ListElement {
            name_en: "The Culture of Kanga, Zanzibar"; name_sw: "Utamaduni wa Kanga, Zanzibar"
            imageFile: "./zanzibar_kanga.jpg"
            desc_en: "More than just a garment, the Kanga is a symbol of Swahili identity. In Zanzibar, these colorful fabrics are famous for their 'Majina' (proverbs) printed at the bottom, used to communicate subtle messages within the community."
            desc_sw: "Zaidi ya vazi, Kanga ni alama ya utambulisho wa Mswahili. Kule Zanzibar, vitambaa hivi vya rangi hupambwa na 'Majina' (methali) chini yake, ambavyo hutumika kufikisha ujumbe mahususi katika jamii."
        }

        ListElement {
            name_en: "Maasai & Kanga Fashion, Iringa"; name_sw: "Ushonaji na Ubunifu, Iringa"
            imageFile: "./iringa_fashion_crafts.jpeg"
            desc_en: "Iringa has become a hub for creative fusion, where artisans blend traditional Maasai 'Shukas' and Kanga fabrics to sew modern outfits and stylish handbags. This craftsmanship preserves heritage while empowering local women."
            desc_sw: "Mkoa wa Iringa umekuwa kitovu cha ubunifu, ambapo mafundi huunganisha Mashuka ya Kimasai na vitambaa vya Kanga kushona mavazi ya kisasa na mikoba ya kijanja. Ufundi huu unalinda urithi wetu na kuziinua akina mama."
        }

        ListElement {
            name_en: "Matema Beach, Lake Nyasa"; name_sw: "Ufukwe wa Matema, Ziwa Nyasa"
            imageFile: "./matema.jpeg"
            desc_en: "Relax at Matema Beach in Mbeya, where the clear waters of Lake Nyasa meet the majestic Livingstone Mountains. Perfect for swimming and mountain hiking!"
            desc_sw: "Pumzika kwenye ufukwe wa Matema, Mbeya, ambapo maji safi ya Ziwa Nyasa hukutana na Milima ya Livingstone. Ni mahali safi kwa kuogelea na kupanda milima!"
        }

        ListElement {
            name_en: "Deep Sea Fishing, Zanzibar & Mafia"; name_sw: "Utalii wa Kuvua Samaki, Zanzibar na Mafia"
            imageFile: "./fishing_tanzania.png"
            desc_en: "Experience the thrill of big-game fishing in the turquoise waters of the Indian Ocean. Catch giant Marlin, Tuna, and Kingfish while enjoying the vibrant coastal culture and warm Tanzanian hospitality."
            desc_sw: "Jionee msisimko wa kuvua samaki wakubwa katika maji ya rangi ya kimalavidavi ya Bahari ya Hindi. Nasa samaki kama Sululu (Marlin), Jodari, na Nguru huku ukifurahia utamaduni wa pwani na ukarimu wa Kitanzania."
        }


        ListElement {
            name_en: "The Taste of Tanzania: Dagaa"; name_sw: "Ladha ya Nyumbani: Dagaa"
            imageFile: "./dagaa_wa_tanzania.jpeg"
            desc_en: "A beloved Tanzanian delicacy! Whether from Lake Victoria or the Indian Ocean, these small, nutrient-rich fish are often sautéed with onions, tomatoes, and spices, served best with hot Ugali and traditional greens."
            desc_sw: "Mlo pendwa wa Kitanzania! Iwe ni dagaa wa Ziwa Victoria au wa Bahari ya Hindi, samaki hawa wadogo wenye virutubisho vingi hupikwa kwa nyanya na viungo, na huliwa vyema zaidi na Ugali wa moto na mboga za majani."
        }


        ListElement {
            name_en: "Hot Air Balloon Safari, Serengeti"; name_sw: "Utalii wa Puto, Serengeti"
            imageFile: "./serengeti_balloon.jpeg"
            desc_en: "Experience a breathtaking bird's-eye view of the Serengeti plains at sunrise, floating above the Great Migration."
            desc_sw: "Shuhudia mandhari ya nyanda za Serengeti kutokea juu wakati wa macheo, ukielea juu ya msafara wa nyumbu."
        }


        ListElement {
            name_en: "St. Joseph's Cathedral, Dar es Salaam";
            name_sw: "Kanisa la Mtakatifu Yosefu, Dar es Salaam"
            imageFile: "./st_joseph_cathedral.jpg"
            desc_en: "A stunning Roman Catholic cathedral built by Germans between 1897 and 1902. It is famous for its Gothic architecture and beautiful stained-glass windows."
            desc_sw: "Kanisa kuu la Katoliki lililojengwa na Wajerumani kati ya mwaka 1897 na 1902. Ni maarufu kwa usanifu wa kigothiki na madirisha ya vioo vya rangi ya kuvutia."
        }

        ListElement {
            name_en: "Christ Church Anglican Cathedral, Zanzibar";
            name_sw: "Kanisa la Anglikana la Christ Church, Zanzibar"
            imageFile: "./zanzibar_anglican_cathedral.jpg"
            desc_en: "Built on the site of the former slave market in Stone Town, this cathedral stands as a symbol of the end of slavery in East Africa."
            desc_sw: "Limejengwa katika eneo lililokuwa soko la watumwa Mji Mkongwe, kanisa hili linasimama kama alama ya mwisho wa utumwa katika Afrika Mashariki."
        }

        ListElement {
            name_en: "Livingstone House, Kwihara"; name_sw: "Nyumba ya Livingstone, Kwihara"
            imageFile: "./livingstones-tabora.jpg"
            desc_en: "Step back in time in Tabora at the Kwihara Museum. Visit the historic home of David Livingstone and learn about Central Africa's ancient trade routes."
            desc_sw: "Rudi nyuma kitalii mjini Tabora kwenye makumbusho ya Kwihara. Tembelea nyumba ya kihistoria ya David Livingstone na ujifunze kuhusu njia za kale za biashara."
        }

        ListElement {
            name_en: "Nyerere Museum, Butiama"; name_sw: "Makumbusho ya Nyerere, Butiama"
            imageFile: "./nyerere.jpeg"
            desc_en: "Visit the home of Tanzania's founder, Mwalimu Julius K. Nyerere in Butiama. A journey of history, leadership, and the humble roots of a great statesman."
            desc_sw: "Tembelea nyumbani kwa muasisi wa Tanzania, Mwalimu Julius K. Nyerere kule Butiama. Safari ya kihistoria, uongozi, na asili ya kiongozi mkuu wa Taifa."
        }


        ListElement {
            name_en: "Mayunga Statue"
            name_sw: "Sanamu ya Mayunga"
            imageFile: "./mayunga.jpeg"
            desc_en: "The Mayunga Statue, a memorial to the Tanzania-Uganda War (Kagera War) contributors, located in Uhuru Stadium (formerly Uhuru Stadium, now often called Mayunga Stadium) in the center of Bukoba town."
            desc_sw: "Sanamu ya Mayunga Kama Kumbukumbu ya Uhuru Iliyopo Katikati ya Mji wa Bukoba Katika Kiwanja cha Uhuru."
        }




    }

    function currentAttractionImage()
    {
        let attraction = attractionModel.get(currentAttractionIndex);
        return attraction.imageFile;
    }

    function currentAttractionName()
    {
        let attraction = attractionModel.get(currentAttractionIndex);
        return selectedLanguage === "en" ? attraction.name_en : attraction.name_sw;
    }

    function currentAttractionDesc()
    {
        let attraction = attractionModel.get(currentAttractionIndex);
        return selectedLanguage === "en" ? attraction.desc_en : attraction.desc_sw;
    }

    property real lastTapX: 0
    property real lastTapY: 0
    property bool gameVisible: false
    property string gameLang: ""

    onSelectedLanguageChanged: {
        if (selectedLanguage !== "") {
            if(app.appMode === 1){
                viewComponentLoader.switchTo(attractionViewComponent1, app.lastTapX, app.lastTapY);
            } else if(app.appMode === 2){
                viewComponentLoader.switchTo(attractionViewComponent2, app.lastTapX, app.lastTapY);
            }
        }
    }

    // ── View transition container ──────────────────────────────────────
    Item {
        id: viewTransitionRoot
        anchors.fill: parent

        Loader {
            id: viewComponentLoader
            anchors.fill: parent
            sourceComponent: languageSelectionComponent

            function switchTo(component, tapX, tapY) {
                rippleTransition.start(component, tapX, tapY);
            }
        }

        // ── Ripple overlay ─────────────────────────────────────────────
        Item {
            id: rippleOverlay
            anchors.fill: parent
            visible: false
            z: 50

            Rectangle {
                id: rippleCircle
                property real cx: 0
                property real cy: 0
                property real maxR: 0
                property color rippleColor: "#cc000088"

                x: cx - width  / 2
                y: cy - height / 2
                width:  rippleCircle.maxR * 2 * rippleScale.xScale
                height: rippleCircle.maxR * 2 * rippleScale.xScale
                radius: width / 2
                color: rippleCircle.rippleColor
                transform: Scale {
                    id: rippleScale
                    xScale: 0
                    yScale: 0
                    origin.x: rippleCircle.width  / 2
                    origin.y: rippleCircle.height / 2
                }
            }
        }

        QtObject {
            id: rippleTransition
            property var pendingComponent: null

            function start(component, tapX, tapY) {
                pendingComponent = component;

                // Set ripple origin to tap point (default to center)
                var tx = (tapX !== undefined && tapX > 0) ? tapX : app.width  / 2;
                var ty = (tapY !== undefined && tapY > 0) ? tapY : app.height / 2;

                // Max radius = diagonal from tap to farthest corner
                var corners = [
                            Math.sqrt(tx*tx + ty*ty),
                            Math.sqrt((app.width-tx)*(app.width-tx) + ty*ty),
                            Math.sqrt(tx*tx + (app.height-ty)*(app.height-ty)),
                            Math.sqrt((app.width-tx)*(app.width-tx) + (app.height-ty)*(app.height-ty))
                        ];
                var maxR = Math.max(corners[0], corners[1], corners[2], corners[3]) + 10;

                rippleCircle.cx   = tx;
                rippleCircle.cy   = ty;
                rippleCircle.maxR = maxR;
                rippleCircle.rippleColor = app.selectedLanguage === "sw" ? "#cc006600" : "#cc000088";
                rippleScale.xScale = 0;
                rippleScale.yScale = 0;
                rippleOverlay.visible = true;

                rippleExpandAnim.start();
            }

            function finish() {
                rippleCollapseAnim.start();
            }
        }

        // Expand: ripple grows to fill screen
        SequentialAnimation {
            id: rippleExpandAnim
            NumberAnimation {
                target: rippleScale; properties: "xScale,yScale"
                from: 0; to: 1
                duration: 380
                easing.type: Easing.OutCubic
            }
            ScriptAction {
                script: {
                    viewComponentLoader.sourceComponent = rippleTransition.pendingComponent;
                    rippleTransition.finish();
                }
            }
        }

        // Collapse: ripple shrinks to reveal new view
        SequentialAnimation {
            id: rippleCollapseAnim
            NumberAnimation {
                target: rippleScale; properties: "xScale,yScale"
                from: 1; to: 0
                duration: 320
                easing.type: Easing.InCubic
            }
            ScriptAction {
                script: { rippleOverlay.visible = false; }
            }
        }
    }

    // ── Fancy Layout Selection Overlay ────────────────────────────────────
    Item {
        id: modeSelectionDialog
        anchors.fill: parent
        visible: false
        z: 100

        property string lag: ""
        property color btnColor: "green"
        property bool isRandom: false

        // Dimmed backdrop
        Rectangle {
            anchors.fill: parent
            color: "#cc000000"
            MouseArea { anchors.fill: parent } // block clicks behind
        }

        // Panel — slides up from bottom
        Rectangle {
            id: modePanel
            anchors.horizontalCenter: parent.horizontalCenter
            width: app.width * 0.92
            height: modePanelCol.height + 32
            radius: 16
            color: "#001413"
            border.color: "cyan"
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter

            // Entrance animation
            transform: Translate { id: panelSlide; y: 60 }
            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            Behavior on transform { } // handled manually

            Column {
                id: modePanelCol
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 32
                spacing: 14

                // Title
                Text {
                    id: dialogTitle
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: ""
                    color: "cyan"
                    font.pointSize: Qt.platform.os === "android" ? 15 : 13
                    font.bold: true
                }

                // Cyan divider
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.4
                    height: 2
                    radius: 1
                    color: "cyan"
                    opacity: 0.5
                }

                // ── Mode 1 Card: Default (hidden in random mode) ──────
                Rectangle {
                    id: mode1Card
                    width: parent.width
                    height: modeSelectionDialog.isRandom ? 0 : (Qt.platform.os === "android" ? 90 : 72)
                    visible: !modeSelectionDialog.isRandom
                    radius: 12
                    color: "#0d2a28"
                    border.color: modeSelectionDialog.btnColor
                    border.width: 2
                    clip: true

                    property bool pressed: false
                    scale: pressed ? 0.97 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        spacing: 14

                        Rectangle {
                            width: Qt.platform.os === "android" ? 52 : 42
                            height: width
                            radius: 10
                            color: modeSelectionDialog.btnColor
                            anchors.verticalCenter: parent.verticalCenter
                            Text { anchors.centerIn: parent; text: "🖼"; font.pointSize: Qt.platform.os === "android" ? 20 : 16 }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3
                            Text {
                                text: modeSelectionDialog.lag === "sw" ? "Kawaida" : "Default"
                                font.pointSize: Qt.platform.os === "android" ? 14 : 12
                                font.bold: true; color: "white"
                            }
                            Text {
                                text: modeSelectionDialog.lag === "sw"
                                      ? "Picha moja kwa wakati mmoja"
                                      : "One image at a time · swipe to navigate"
                                font.pointSize: Qt.platform.os === "android" ? 11 : 9; color: "#aaaaaa"
                            }
                        }
                    }

                    Text {
                        anchors.right: parent.right; anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: "›"; font.pointSize: Qt.platform.os === "android" ? 22 : 18
                        font.bold: true; color: modeSelectionDialog.btnColor
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed:  mode1Card.pressed = true
                        onReleased: mode1Card.pressed = false
                        onCanceled: mode1Card.pressed = false
                        onClicked: {
                            app.lastTapX = mouse.x + mode1Card.x;
                            app.lastTapY = mouse.y + mode1Card.y;
                            modeSelectionDialog.setMode1();
                        }
                    }
                }

                // ── Mode 2 Card: List (hidden in random mode) ──────────
                Rectangle {
                    id: mode2Card
                    width: parent.width
                    height: modeSelectionDialog.isRandom ? 0 : (Qt.platform.os === "android" ? 90 : 72)
                    visible: !modeSelectionDialog.isRandom
                    radius: 12
                    color: "#0d2a28"
                    border.color: modeSelectionDialog.btnColor
                    border.width: 2
                    clip: true

                    property bool pressed: false
                    scale: pressed ? 0.97 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        spacing: 14

                        Rectangle {
                            width: Qt.platform.os === "android" ? 52 : 42
                            height: width
                            radius: 10
                            color: modeSelectionDialog.btnColor
                            anchors.verticalCenter: parent.verticalCenter
                            Text { anchors.centerIn: parent; text: "📋"; font.pointSize: Qt.platform.os === "android" ? 20 : 16 }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3
                            Text {
                                text: modeSelectionDialog.lag === "sw" ? "Orodha" : "List"
                                font.pointSize: Qt.platform.os === "android" ? 14 : 12
                                font.bold: true; color: "white"
                            }
                            Text {
                                text: modeSelectionDialog.lag === "sw"
                                      ? "Vivutio vyote kwenye orodha"
                                      : "Browse all attractions in a scrollable list"
                                font.pointSize: Qt.platform.os === "android" ? 11 : 9; color: "#aaaaaa"
                            }
                        }
                    }

                    Text {
                        anchors.right: parent.right; anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: "›"; font.pointSize: Qt.platform.os === "android" ? 22 : 18
                        font.bold: true; color: modeSelectionDialog.btnColor
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed:  mode2Card.pressed = true
                        onReleased: mode2Card.pressed = false
                        onCanceled: mode2Card.pressed = false
                        onClicked: {
                            app.lastTapX = mouse.x + mode2Card.x;
                            app.lastTapY = mouse.y + mode2Card.y;
                            modeSelectionDialog.setMode2();
                        }
                    }
                }

                // ── Random: Swahili card (shown only in random mode) ───
                Rectangle {
                    id: randomSwCard
                    width: parent.width
                    height: modeSelectionDialog.isRandom ? (Qt.platform.os === "android" ? 90 : 72) : 0
                    visible: modeSelectionDialog.isRandom
                    radius: 12
                    color: "#0d2a28"
                    border.color: "green"
                    border.width: 2
                    clip: true

                    property bool pressed: false
                    scale: pressed ? 0.97 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        spacing: 14

                        Rectangle {
                            width: Qt.platform.os === "android" ? 52 : 42
                            height: width; radius: 10; color: "green"
                            anchors.verticalCenter: parent.verticalCenter
                            Text { anchors.centerIn: parent; text: "🇹🇿"; font.pointSize: Qt.platform.os === "android" ? 20 : 16 }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3
                            Text { text: "Kiswahili"; font.pointSize: Qt.platform.os === "android" ? 14 : 12; font.bold: true; color: "white" }
                            Text { text: "Nishangaze kwa Kiswahili"; font.pointSize: Qt.platform.os === "android" ? 11 : 9; color: "#aaaaaa" }
                        }
                    }

                    Text {
                        anchors.right: parent.right; anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: "›"; font.pointSize: Qt.platform.os === "android" ? 22 : 18
                        font.bold: true; color: "green"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed:  randomSwCard.pressed = true
                        onReleased: randomSwCard.pressed = false
                        onCanceled: randomSwCard.pressed = false
                        onClicked: {
                            modeSelectionDialog.close();
                            app.appMode = 1;
                            app.selectedLanguage = "sw";
                        }
                    }
                }

                // ── Random: English card (shown only in random mode) ───
                Rectangle {
                    id: randomEnCard
                    width: parent.width
                    height: modeSelectionDialog.isRandom ? (Qt.platform.os === "android" ? 90 : 72) : 0
                    visible: modeSelectionDialog.isRandom
                    radius: 12
                    color: "#0d2a28"
                    border.color: "blue"
                    border.width: 2
                    clip: true

                    property bool pressed: false
                    scale: pressed ? 0.97 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        spacing: 14

                        Rectangle {
                            width: Qt.platform.os === "android" ? 52 : 42
                            height: width; radius: 10; color: "blue"
                            anchors.verticalCenter: parent.verticalCenter
                            Text { anchors.centerIn: parent; text: "🌐"; font.pointSize: Qt.platform.os === "android" ? 20 : 16 }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3
                            Text { text: "English"; font.pointSize: Qt.platform.os === "android" ? 14 : 12; font.bold: true; color: "white" }
                            Text { text: "Surprise me in English"; font.pointSize: Qt.platform.os === "android" ? 11 : 9; color: "#aaaaaa" }
                        }
                    }

                    Text {
                        anchors.right: parent.right; anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: "›"; font.pointSize: Qt.platform.os === "android" ? 22 : 18
                        font.bold: true; color: "blue"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed:  randomEnCard.pressed = true
                        onReleased: randomEnCard.pressed = false
                        onCanceled: randomEnCard.pressed = false
                        onClicked: {
                            modeSelectionDialog.close();
                            app.appMode = 1;
                            app.selectedLanguage = "en";
                        }
                    }
                }

                // ── Close button ───────────────────────────────────────
                Rectangle {
                    id: modeCloseBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.5
                    height: Qt.platform.os === "android" ? 48 : 36
                    radius: height / 2
                    color: "#cc2200"

                    property bool pressed: false
                    scale: pressed ? 0.96 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: modeSelectionDialog.lag === "sw" ? "Funga" : "Close"
                        font.pointSize: Qt.platform.os === "android" ? 13 : 11
                        font.bold: true
                        color: "white"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed:  modeCloseBtn.pressed = true
                        onReleased: modeCloseBtn.pressed = false
                        onCanceled: modeCloseBtn.pressed = false
                        onClicked:  modeSelectionDialog.close()
                    }
                }

                // bottom spacer
                Item { width: 1; height: 4 }
            }
        }

        function doOpen(lag, btnColor) {
            modeSelectionDialog.lag = lag;
            modeSelectionDialog.btnColor = btnColor;
            modeSelectionDialog.isRandom = false;
            dialogTitle.text = lag === "sw" ? "Chagua mpangilio" : "Select a layout";
            modeSelectionDialog.visible = true;
            modePanel.opacity = 1;
            panelSlideAnim.start();
        }

        function doOpenRandom() {
            modeSelectionDialog.isRandom = true;
            dialogTitle.text = "🎲 Nishangaze!  ·  Surprise me!";
            modeSelectionDialog.visible = true;
            modePanel.opacity = 1;
            panelSlideAnim.start();
        }

        function close() {
            modePanel.opacity = 0;
            modeSelectionDialog.visible = false;
        }

        NumberAnimation {
            id: panelSlideAnim
            target: panelSlide
            property: "y"
            from: 60; to: 0
            duration: 280
            easing.type: Easing.OutCubic
        }

        function setMode1() {
            app.appMode = 1;
            close();
            app.selectedLanguage = modeSelectionDialog.lag;
        }

        function setMode2() {
            app.appMode = 2;
            close();
            app.selectedLanguage = modeSelectionDialog.lag;
        }
    }



    Item {
        id: contextMenu

        property string detailName: ""
        property string detailDesc: ""
        property string detailImage: ""
        property string detailLang: ""
        property int    detailIndex: -1   // current attraction index for swipe nav

        visible: false
        anchors.fill: parent
        z: 200

        // Dimmed backdrop
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            id: detailBackdrop
            opacity: 0.0
            Behavior on opacity { NumberAnimation { duration: 300 } }
        }

        // Full image background
        Image {
            id: detailBgImage
            anchors.fill: parent
            source: contextMenu.detailImage
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: 0.0
            Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
        }

        // Bottom gradient
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height * 0.55
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: "#cc001413" }
                GradientStop { position: 1.0; color: "#f0000000" }
            }
            opacity: detailBgImage.opacity
        }

        // ── Swipe gesture area ─────────────────────────────────────────
        MouseArea {
            anchors.fill: parent
            property real startX: 0
            onPressed:  startX = mouse.x
            onReleased: {
                var delta = mouse.x - startX;
                if (Math.abs(delta) > app.width * 0.25) {
                    if (delta < 0) contextMenu.navigateNext();
                    else           contextMenu.navigatePrev();
                }
            }
        }

        // ── Swipe hint arrows ──────────────────────────────────────────
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: "‹"
            font.pointSize: Qt.platform.os === "android" ? 36 : 28
            color: "#55ffffff"
            font.bold: true
            opacity: detailBgImage.opacity
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: "›"
            font.pointSize: Qt.platform.os === "android" ? 36 : 28
            color: "#55ffffff"
            font.bold: true
            opacity: detailBgImage.opacity
        }

        // ── Detail text ────────────────────────────────────────────────
        Column {
            id: detailTextCol
            anchors.bottom: detailBtnRow.top
            anchors.bottomMargin: 16
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 10
            opacity: 0.0
            transform: Translate { id: detailTextSlide; y: 40 }
            Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

            // Index counter
            Text {
                text: contextMenu.detailIndex >= 0
                      ? (contextMenu.detailIndex + 1) + " / " + attractionModel.count
                      : ""
                font.pointSize: Qt.platform.os === "android" ? 11 : 9
                color: "cyan"
                font.bold: true
            }

            Text {
                width: parent.width
                text: contextMenu.detailName
                font.pointSize: Qt.platform.os === "android" ? 20 : 16
                font.bold: true
                color: "white"
                wrapMode: Text.WordWrap
            }

            Rectangle { width: 50; height: 3; radius: 2; color: contextMenu.detailLang === "sw" ? "green" : "cyan" }

            Flickable {
                width: parent.width
                height: Math.min(detailDescText.implicitHeight, app.height * 0.25)
                contentHeight: detailDescText.implicitHeight
                clip: true
                Text {
                    id: detailDescText
                    width: parent.width
                    text: contextMenu.detailDesc
                    font.pointSize: Qt.platform.os === "android" ? 13 : 11
                    color: "#e0e0e0"
                    wrapMode: Text.WordWrap
                }
            }
        }

        // ── Button row ─────────────────────────────────────────────────
        Row {
            id: detailBtnRow
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12
            opacity: detailTextCol.opacity

            Rectangle {
                id: detailHomeBtn
                width: app.width * 0.28
                height: Qt.platform.os === "android" ? 52 : 40
                radius: height / 2
                property color frozenColor: app.selectedLanguage === "sw" ? "green" : "blue"
                color: frozenColor
                property bool pressed: false
                scale: pressed ? 0.95 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
                Text { anchors.centerIn: parent; text: "⌂"; font.pointSize: Qt.platform.os === "android" ? 18 : 14; color: "white" }
                MouseArea {
                    anchors.fill: parent
                    onPressed:  detailHomeBtn.pressed = true
                    onReleased: detailHomeBtn.pressed = false
                    onCanceled: detailHomeBtn.pressed = false
                    onClicked: {
                        detailHomeBtn.frozenColor = app.selectedLanguage === "sw" ? "green" : "blue";
                        contextMenu.close();
                        viewComponentLoader.switchTo(languageSelectionComponent, app.width / 2, app.height / 2);
                        app.selectedLanguage = "";
                    }
                }
            }

            Rectangle {
                id: detailPrevBtn
                width: app.width * 0.18
                height: Qt.platform.os === "android" ? 52 : 40
                radius: height / 2
                color: "#1a2a2a"
                border.color: "#44ffffff"; border.width: 1
                property bool pressed: false
                scale: pressed ? 0.95 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
                Text { anchors.centerIn: parent; text: "‹"; font.pointSize: Qt.platform.os === "android" ? 20 : 16; font.bold: true; color: "white" }
                MouseArea {
                    anchors.fill: parent
                    onPressed:  detailPrevBtn.pressed = true
                    onReleased: detailPrevBtn.pressed = false
                    onCanceled: detailPrevBtn.pressed = false
                    onClicked:  contextMenu.navigatePrev()
                }
            }

            Rectangle {
                id: detailNextBtn
                width: app.width * 0.18
                height: Qt.platform.os === "android" ? 52 : 40
                radius: height / 2
                color: "#1a2a2a"
                border.color: "#44ffffff"; border.width: 1
                property bool pressed: false
                scale: pressed ? 0.95 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
                Text { anchors.centerIn: parent; text: "›"; font.pointSize: Qt.platform.os === "android" ? 20 : 16; font.bold: true; color: "white" }
                MouseArea {
                    anchors.fill: parent
                    onPressed:  detailNextBtn.pressed = true
                    onReleased: detailNextBtn.pressed = false
                    onCanceled: detailNextBtn.pressed = false
                    onClicked:  contextMenu.navigateNext()
                }
            }

            Rectangle {
                id: detailCloseBtn
                width: app.width * 0.28
                height: Qt.platform.os === "android" ? 52 : 40
                radius: height / 2
                color: "#cc2200"
                property bool pressed: false
                scale: pressed ? 0.95 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
                Text { anchors.centerIn: parent; text: "x" ; font.pointSize: Qt.platform.os === "android" ? 12 : 9; font.bold: true; color: "white" }
                MouseArea {
                    anchors.fill: parent
                    onPressed:  detailCloseBtn.pressed = true
                    onReleased: detailCloseBtn.pressed = false
                    onCanceled: detailCloseBtn.pressed = false
                    onClicked:  contextMenu.close()
                }
            }
        }

        function loadAttraction(idx) {
            var a = attractionModel.get(idx);
            if (!a) return;
            contextMenu.detailIndex = idx;
            contextMenu.detailName  = contextMenu.detailLang === "en" ? a.name_en : a.name_sw;
            contextMenu.detailDesc  = contextMenu.detailLang === "en" ? a.desc_en : a.desc_sw;
            contextMenu.detailImage = a.imageFile;
            app.addRecentlyViewed(idx);
        }

        function navigateNext() {
            var next = (contextMenu.detailIndex + 1) % attractionModel.count;
            loadAttraction(next);
        }

        function navigatePrev() {
            var prev = contextMenu.detailIndex > 0 ? contextMenu.detailIndex - 1 : attractionModel.count - 1;
            loadAttraction(prev);
        }

        function doOpen(lag, name, desc, imagePath, idx) {
            contextMenu.detailLang  = lag;
            contextMenu.detailName  = name;
            contextMenu.detailDesc  = desc;
            contextMenu.detailImage = imagePath;
            contextMenu.detailIndex = (idx !== undefined) ? idx : -1;
            detailHomeBtn.frozenColor = lag === "sw" ? "green" : "blue";
            contextMenu.visible     = true;
            detailBackdrop.opacity  = 1.0;
            detailBgImage.opacity   = 1.0;
            detailTextCol.opacity   = 1.0;
            detailTextSlideAnim.start();
        }

        function close() {
            detailBackdrop.opacity = 0.0;
            detailBgImage.opacity  = 0.0;
            detailTextCol.opacity  = 0.0;
            contextMenu.visible    = false;
        }

        NumberAnimation {
            id: detailTextSlideAnim
            target: detailTextSlide
            property: "y"
            from: 40; to: 0
            duration: 380
            easing.type: Easing.OutCubic
        }
    }




    // ════════════════════════════════════════════════════════════════════
    // AD SYSTEM — each ad is a plain Component (no custom properties)
    // Lang is tracked separately in adsLang array, same index as adsPool.
    //
    // To add a client ad:
    //   1. Add a Component { id: adClientX ... } below
    //   2. Add it to adsPool list
    //   3. Add its lang ("en","sw","both") at the same index in adsLang
    // ════════════════════════════════════════════════════════════════════

    property var adsPool: [ adOwnerEN, adOwnerSW ]
    property var adsLang: [ "en",      "sw"      ]
    // ↑ add client components and their langs here, same order

    property int adRandomSeed: Math.floor(Math.random() * 9999)

    // ── Ad rotation timer — changes seed every 3 minutes ──────────
    Timer {
        interval: 180000
        repeat: true
        running: true
        onTriggered: {
            app.adRandomSeed = Math.floor(Math.random() * 9999);
        }
    }

    function pickAd(language) {
        var pool = [];
        for (var i = 0; i < adsPool.length; i++) {
            var l = adsLang[i] !== undefined ? adsLang[i] : "both";
            if (l === language || l === "both") pool.push(i);
        }
        if (pool.length === 0) return -1;
        return pool[app.adRandomSeed % pool.length];
    }

    // ── YOUR EN AD ────────────────────────────────────────────────────
    Component {
        id: adOwnerEN
        Rectangle {
            width: parent ? parent.width : 0
            height: _enCol.height + 20
            color: "#ffffff"; radius: 8
            border.color: "#dadce0"; border.width: 1; clip: true

            Rectangle {
                anchors.top: parent.top; anchors.left: parent.left
                anchors.topMargin: 8; anchors.leftMargin: 10
                width: _enBadge.implicitWidth + 8; height: _enBadge.implicitHeight + 4
                radius: 3; color: "#f0f0f0"; border.color: "#bbbbbb"; border.width: 1
                Text { id: _enBadge; anchors.centerIn: parent; text: "Ad"
                    font.pointSize: Qt.platform.os === "android" ? 9 : 7; color: "#555555" }
            }
            Column {
                id: _enCol
                anchors.top: parent.top; anchors.topMargin: 30
                anchors.left: parent.left; anchors.right: parent.right
                anchors.leftMargin: 10; anchors.rightMargin: 10
                spacing: 6
                Text { width: parent.width; wrapMode: Text.WordWrap; font.bold: true; color: "#1a0dab"
                    font.pointSize: Qt.platform.os === "android" ? 13 : 11
                    text: "📢 Advertise on Tanzania Tourism App!" }
                Text { text: "tztourism.app › advertise"
                    font.pointSize: Qt.platform.os === "android" ? 10 : 8; color: "#006621" }
                Text { width: parent.width; wrapMode: Text.WordWrap; color: "#333333"
                    font.pointSize: Qt.platform.os === "android" ? 11 : 9
                    text: "Reach thousands of tourists daily! List your Hotel, Hostel, Rental House e.t.c and get noticed by visitors from around the world." }
                Rectangle {
                    height: _enPrice.implicitHeight+8; width: _enPrice.implicitWidth+16
                    radius: 4; color: "#e8f5e9"; border.color: "#4caf50"; border.width: 1
                    Text { id: _enPrice; anchors.centerIn: parent; font.bold: true; color: "#2e7d32"
                        font.pointSize: Qt.platform.os === "android" ? 11 : 9
                        text: "💰 From TZS 50,000/= per month" }
                }
                Row {
                    spacing: 8
                    Rectangle {
                        id: _enCall; radius: 4; color: "#1a73e8"
                        height: _enCallTxt.implicitHeight+10; width: _enCallTxt.implicitWidth+20
                        property bool pressed: false; scale: pressed ? 0.96:1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        Text { id: _enCallTxt; anchors.centerIn: parent; font.bold: true; color: "white"
                            font.pointSize: Qt.platform.os === "android" ? 12:10; text: "📞  0789 081 122" }
                        MouseArea { anchors.fill: parent
                            onPressed: _enCall.pressed=true; onReleased: _enCall.pressed=false; onCanceled: _enCall.pressed=false
                            onClicked: Qt.openUrlExternally("tel:+255789081122") }
                    }
                    Rectangle {
                        id: _enWa; radius: 4; color: "#25D366"
                        height: _enWaTxt.implicitHeight+10; width: _enWaTxt.implicitWidth+20
                        property bool pressed: false; scale: pressed ? 0.96:1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        Text { id: _enWaTxt; anchors.centerIn: parent; font.bold: true; color: "white"
                            font.pointSize: Qt.platform.os === "android" ? 12:10; text: "💬 WhatsApp" }
                        MouseArea { anchors.fill: parent
                            onPressed: _enWa.pressed=true; onReleased: _enWa.pressed=false; onCanceled: _enWa.pressed=false
                            onClicked: Qt.openUrlExternally("https://wa.me/255789081122?text=Hello%2C%20I%20want%20to%20advertise") }
                    }
                    Rectangle {
                        id: _enBook; radius: 4; color: "#f8f9fa"; border.color: "#dadce0"; border.width: 1
                        height: _enBookTxt.implicitHeight+10; width: _enBookTxt.implicitWidth+20
                        property bool pressed: false; scale: pressed ? 0.96:1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        Text { id: _enBookTxt; anchors.centerIn: parent; font.bold: true; color: "#1a73e8"
                            font.pointSize: Qt.platform.os === "android" ? 12:10; text: "Book →" }
                        MouseArea { anchors.fill: parent
                            onPressed: _enBook.pressed=true; onReleased: _enBook.pressed=false; onCanceled: _enBook.pressed=false
                            onClicked: app.showToastMessage("Call or WhatsApp 0789 081 122 to book your slot!") }
                    }
                }
                Item { width: 1; height: 4 }
            }
        }
    }

    // ── YOUR SW AD ────────────────────────────────────────────────────
    Component {
        id: adOwnerSW
        Rectangle {
            width: parent ? parent.width : 0
            height: _swCol.height + 20
            color: "#ffffff"; radius: 8
            border.color: "#dadce0"; border.width: 1; clip: true

            Rectangle {
                anchors.top: parent.top; anchors.left: parent.left
                anchors.topMargin: 8; anchors.leftMargin: 10
                width: _swBadge.implicitWidth + 8; height: _swBadge.implicitHeight + 4
                radius: 3; color: "#f0f0f0"; border.color: "#bbbbbb"; border.width: 1
                Text { id: _swBadge; anchors.centerIn: parent; text: "Tangazo"
                    font.pointSize: Qt.platform.os === "android" ? 9 : 7; color: "#555555" }
            }
            Column {
                id: _swCol
                anchors.top: parent.top; anchors.topMargin: 30
                anchors.left: parent.left; anchors.right: parent.right
                anchors.leftMargin: 10; anchors.rightMargin: 10
                spacing: 6
                Text { width: parent.width; wrapMode: Text.WordWrap; font.bold: true; color: "#1a0dab"
                    font.pointSize: Qt.platform.os === "android" ? 13 : 11
                    text: "📢 Tangaza kwenye Aplikesheni ya Utalii wa Tanzania!" }
                Text { text: "tztourism.app › matangazo"
                    font.pointSize: Qt.platform.os === "android" ? 10 : 8; color: "#006621" }
                Text { width: parent.width; wrapMode: Text.WordWrap; color: "#333333"
                    font.pointSize: Qt.platform.os === "android" ? 11 : 9
                    text: "Fikia maelfu ya watalii kila siku! Tangaza Bidhaa, Hoteli, Hostel, Nyumba ya Kupanga n.k na uonekane na wageni kutoka duniani kote." }
                Rectangle {
                    height: _swPrice.implicitHeight+8; width: _swPrice.implicitWidth+16
                    radius: 4; color: "#e8f5e9"; border.color: "#4caf50"; border.width: 1
                    Text { id: _swPrice; anchors.centerIn: parent; font.bold: true; color: "#2e7d32"
                        font.pointSize: Qt.platform.os === "android" ? 11 : 9
                        text: "💰 Kuanzia TZS 50,000/= kwa mwezi" }
                }
                Row {
                    spacing: 8
                    Rectangle {
                        id: _swCall; radius: 4; color: "#1a73e8"
                        height: _swCallTxt.implicitHeight+10; width: _swCallTxt.implicitWidth+20
                        property bool pressed: false; scale: pressed ? 0.96:1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        Text { id: _swCallTxt; anchors.centerIn: parent; font.bold: true; color: "white"
                            font.pointSize: Qt.platform.os === "android" ? 12:10; text: "📞  0789 081 122" }
                        MouseArea { anchors.fill: parent
                            onPressed: _swCall.pressed=true; onReleased: _swCall.pressed=false; onCanceled: _swCall.pressed=false
                            onClicked: Qt.openUrlExternally("tel:+255789081122") }
                    }
                    Rectangle {
                        id: _swWa; radius: 4; color: "#25D366"
                        height: _swWaTxt.implicitHeight+10; width: _swWaTxt.implicitWidth+20
                        property bool pressed: false; scale: pressed ? 0.96:1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        Text { id: _swWaTxt; anchors.centerIn: parent; font.bold: true; color: "white"
                            font.pointSize: Qt.platform.os === "android" ? 12:10; text: "💬 WhatsApp" }
                        MouseArea { anchors.fill: parent
                            onPressed: _swWa.pressed=true; onReleased: _swWa.pressed=false; onCanceled: _swWa.pressed=false
                            onClicked: Qt.openUrlExternally("https://wa.me/255789081122?text=Habari%2C%20nataka%20kutangaza") }
                    }
                    Rectangle {
                        id: _swBook; radius: 4; color: "#f8f9fa"; border.color: "#dadce0"; border.width: 1
                        height: _swBookTxt.implicitHeight+10; width: _swBookTxt.implicitWidth+20
                        property bool pressed: false; scale: pressed ? 0.96:1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        Text { id: _swBookTxt; anchors.centerIn: parent; font.bold: true; color: "#1a73e8"
                            font.pointSize: Qt.platform.os === "android" ? 12:10; text: "Nafasi →" }
                        MouseArea { anchors.fill: parent
                            onPressed: _swBook.pressed=true; onReleased: _swBook.pressed=false; onCanceled: _swBook.pressed=false
                            onClicked: app.showToastMessage("Piga simu au WhatsApp 0789 081 122 kuhifadhi nafasi yako!") }
                    }
                }
                Item { width: 1; height: 4 }
            }
        }
    }

    // ── CLIENT ADS ────────────────────────────────────────────────────
    // Step 1: Add your Component here with a unique id
    // Step 2: Add the id to adsPool and its lang to adsLang (same index)
    //
    // Component {
    //     id: adClient1
    //     Rectangle {
    //         width: parent ? parent.width : 0
    //         height: ...
    //         // completely custom layout — no restrictions!
    //     }
    // }




    Component {
        id: languageSelectionComponent

        Item {
            anchors.fill: parent

            // ── Scrollable content ─────────────────────────────────────
            Flickable {
                anchors.fill: parent
                contentWidth: width
                contentHeight: pageCol.height
                clip: true

                Column {
                    id: pageCol
                    width: app.width
                    spacing: 0

                    // ══ HERO SECTION ══════════════════════════════════════
                    Item {
                        width: app.width
                        height: app.height * 0.42

                        // ══ Language toggle button ══════════════════════════════════════
                        Item {
                            id: langToggleRoot
                            z: tzflag.z + 1
                            width: Qt.platform.os === "android" ? app.width * 0.44 : app.width * 0.38
                            height: Qt.platform.os === "android" ? 54 : 46
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: Qt.platform.os === "android" ? 10 : 8
                            anchors.rightMargin: Qt.platform.os === "android" ? 10 : 8

                            property bool isSw: langSettings.lang === "sw"
                            property color activeColor: isSw ? "#1a8a3a" : "#1a4fa8"
                            property color glowColor:   isSw ? "#6600cc44" : "#660055ff"

                            // Outer glow ring
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width + 6
                                height: parent.height + 6
                                radius: height / 2
                                color: "transparent"
                                border.color: langToggleRoot.glowColor
                                border.width: 3
                                Behavior on border.color { ColorAnimation { duration: 350 } }

                                layer.enabled: true
                                layer.effect: DropShadow {
                                    transparentBorder: true
                                    horizontalOffset: 0
                                    verticalOffset: 0
                                    radius: 12
                                    samples: 25
                                    color: langToggleRoot.glowColor
                                    Behavior on color { ColorAnimation { duration: 350 } }
                                }
                            }

                            // Main pill body
                            Rectangle {
                                id: toggleBackground
                                anchors.fill: parent
                                radius: height / 2
                                color: langToggleRoot.activeColor
                                Behavior on color { ColorAnimation { duration: 300 } }

                                layer.enabled: true
                                layer.effect: DropShadow {
                                    transparentBorder: true
                                    horizontalOffset: 0
                                    verticalOffset: 3
                                    radius: 10
                                    samples: 21
                                    color: "#55000000"
                                }

                                // Left label: SW
                                Text {
                                    width: parent.width / 2
                                    height: parent.height
                                    anchors.left: parent.left
                                    text: "🇹🇿 SW"
                                    font.bold: true
                                    font.pixelSize: Qt.platform.os === "android" ? 20 : 11
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: "white"
                                    opacity: langToggleRoot.isSw ? 0.35 : 1.0
                                    Behavior on opacity { NumberAnimation { duration: 200 } }
                                    z: 1
                                }

                                // Right label: EN
                                Text {
                                    width: parent.width / 2
                                    height: parent.height
                                    anchors.right: parent.right
                                    text: "🌍 EN"
                                    font.bold: true
                                    font.pixelSize: Qt.platform.os === "android" ? 20 : 11
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: "white"
                                    opacity: langToggleRoot.isSw ? 1.0 : 0.35
                                    Behavior on opacity { NumberAnimation { duration: 200 } }
                                    z: 1
                                }

                                // Sliding knob
                                Rectangle {
                                    id: knob
                                    width: (parent.width / 2) - 6
                                    height: parent.height - 8
                                    x: langToggleRoot.isSw ? 3 : (parent.width / 2) + 3
                                    y: 4
                                    radius: height / 2
                                    color: "white"
                                    opacity: 0.92
                                    z: 2

                                    Behavior on x {
                                        NumberAnimation {
                                            duration: 260
                                            easing.type: Easing.OutBack
                                            easing.overshoot: 1.2
                                        }
                                    }

                                    layer.enabled: true
                                    layer.effect: DropShadow {
                                        radius: 6
                                        samples: 13
                                        color: "#30000000"
                                    }

                                    // Active language label inside knob
                                    Text {
                                        anchors.centerIn: parent
                                        text: langToggleRoot.isSw ? "SW" : "EN"
                                        font.bold: true
                                        font.pixelSize: Qt.platform.os === "android" ? 20 : 11
                                        color: langToggleRoot.activeColor
                                        Behavior on color { ColorAnimation { duration: 300 } }
                                    }
                                }

                                // Press scale animation
                                Behavior on scale { NumberAnimation { duration: 100 } }

                                MouseArea {
                                    anchors.fill: parent
                                    onPressed:  toggleBackground.scale = 0.95
                                    onReleased: {
                                        toggleBackground.scale = 1.0;
                                        langSettings.lang = langToggleRoot.isSw ? "en" : "sw";
                                        langSettings.sync();
                                    }
                                    onCanceled: toggleBackground.scale = 1.0
                                }
                            }
                        }
                        // ══ / Language toggle button ══════════════════════════════════════


                        // Hero background image
                        AnimatedImage {
                            id:tzflag
                            anchors.fill: parent
                            source: "./tzflag.gif"
                            fillMode: Image.PreserveAspectCrop
                        }

                        // Dark gradient over hero — app cyan palette, top-to-bottom
                        Rectangle {
                            anchors.fill: parent
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#99000000" }
                                GradientStop { position: 0.45; color: "#33001a19" }
                                GradientStop { position: 0.75; color: "#aa001a19" }
                                GradientStop { position: 1.0; color: "#f0001413" }
                            }
                        }

                        // ══ HERO BOTTOM ROW: Big 5| HeroText ════════
                        Item {
                            id: heroBottomRow
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottomMargin: Qt.platform.os === "android" ? 14 : 10
                            anchors.leftMargin: Qt.platform.os === "android" ? 10 : 8
                            anchors.rightMargin: Qt.platform.os === "android" ? 10 : 8
                            height: heroTextArea.height

                            // ── 1. Big5 photo — kushoto ───────────────────────
                            Item {
                                id: big5PhotoCol
                                anchors.left: parent.left
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 16
                                width: parent.width * 0.28
                                height: parent.height * 1.7

                                NumberAnimation on opacity {
                                    running: true; from: 0; to: 1
                                    duration: 700; easing.type: Easing.OutQuad
                                }

                                // Glowing frame behind the photo
                                Rectangle {
                                    anchors.centerIn: big5Photo
                                    width: big5Photo.width + (Qt.platform.os === "android" ? 6 : 4)
                                    height: big5Photo.height + (Qt.platform.os === "android" ? 6 : 4)
                                    radius: Qt.platform.os === "android" ? 12 : 9
                                    color: "transparent"
                                    border.color: "#ff02c6db"
                                    border.width: Qt.platform.os === "android" ? 2 : 1.5
                                    layer.enabled: true
                                    layer.effect: DropShadow {
                                        transparentBorder: true
                                        horizontalOffset: 0; verticalOffset: 0
                                        radius: 14; samples: 29; color: "#cc02c6db"
                                    }
                                }

                                Image {
                                    id: big5Photo
                                    source: "./big5.jpg"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width * 0.92
                                    height: parent.height * 0.88
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    layer.enabled: true
                                    layer.effect: DropShadow {
                                        transparentBorder: true
                                        horizontalOffset: 2; verticalOffset: 4
                                        radius: 10; samples: 21; color: "#88000000"
                                    }

                                    property real yOff: 20
                                    anchors.bottomMargin: -yOff
                                    NumberAnimation on yOff {
                                        running: true; from: 20; to: 0
                                        duration: 750; easing.type: Easing.OutCubic
                                    }
                                }

                                // name badge
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 4
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: big5NameText.implicitWidth + (Qt.platform.os === "android" ? 20 : 16)
                                    height: big5NameText.implicitHeight + (Qt.platform.os === "android" ? 9 : 7)
                                    radius: height / 2
                                    color: "#dd001413"
                                    border.color: "#aa02c6db"
                                    border.width: 1
                                    layer.enabled: true
                                    layer.effect: DropShadow {
                                        transparentBorder: true
                                        horizontalOffset: 0; verticalOffset: 2
                                        radius: 8; samples: 17; color: "#99000000"
                                    }

                                    Text {
                                        id: big5NameText
                                        anchors.centerIn: parent
                                        text: langSettings.lang === "sw" ? "Wakubwa Watano" : "Big Five"
                                        font.pixelSize: Qt.platform.os === "android" ? 16 : 11
                                        font.bold: true
                                        font.letterSpacing: 0.5
                                        color: langSettings.lang === "sw" ? "green" : "blue"
                                    }
                                }

                                // ── Animated 5 cyan stars ──────────────────────
                                Item {
                                    id: big5StarsItem
                                    anchors.top: parent.top
                                    anchors.topMargin: Qt.platform.os === "android" ? -18 : -14
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width
                                    height: Qt.platform.os === "android" ? 28 : 22

                                    // pulse scale animator
                                    property real pulseScale: 1.0
                                    SequentialAnimation on pulseScale {
                                        loops: Animation.Infinite
                                        NumberAnimation { from: 1.0; to: 1.25; duration: 700; easing.type: Easing.InOutSine; }
                                        NumberAnimation { from: 1.25; to: 1.0; duration: 700; easing.type: Easing.InOutSine; }
                                    }

                                    // per-star twinkle opacity array driven by a timer
                                    property var starOpacities: [1.0, 1.0, 1.0, 1.0, 1.0]
                                    property int twinkleIdx: 0

                                    Timer {
                                        interval: 280
                                        running: true
                                        repeat: true
                                        onTriggered: {
                                            var arr = big5StarsItem.starOpacities.slice();
                                            // restore previous
                                            for (var i = 0; i < arr.length; i++) arr[i] = 1.0;
                                            // dim current star
                                            arr[big5StarsItem.twinkleIdx] = 0.25;
                                            big5StarsItem.starOpacities = arr;
                                            big5StarsItem.twinkleIdx = (big5StarsItem.twinkleIdx + 1) % 5;
                                            big5StarsCanvas.requestPaint();
                                        }
                                    }

                                    Canvas {
                                        id: big5StarsCanvas
                                        anchors.fill: parent
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.clearRect(0, 0, width, height);

                                            var n       = 5;
                                            var starR   = (Qt.platform.os === "android" ? 7 : 5.5) * big5StarsItem.pulseScale;
                                            var innerR  = starR * 0.42;
                                            var spacing = (Qt.platform.os === "android" ? 20 : 16) * big5StarsItem.pulseScale;
                                            var totalW  = (n - 1) * spacing;
                                            var cx0     = (width - totalW) / 2;
                                            var cy      = height / 2;

                                            for (var s = 0; s < n; s++) {
                                                var cx = cx0 + s * spacing;
                                                var op = big5StarsItem.starOpacities[s];

                                                // glow
                                                ctx.save();
                                                ctx.globalAlpha = op * 0.45;
                                                var grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, starR * 1.6);
                                                grad.addColorStop(0, "#ff00e5ff");
                                                grad.addColorStop(1, "transparent");
                                                ctx.fillStyle = grad;
                                                ctx.beginPath();
                                                ctx.arc(cx, cy, starR * 1.6, 0, Math.PI * 2);
                                                ctx.fill();
                                                ctx.restore();

                                                // star shape
                                                ctx.save();
                                                ctx.globalAlpha = op;
                                                ctx.fillStyle   = "cyan";
                                                ctx.shadowColor = "cyan";
                                                ctx.shadowBlur  = Qt.platform.os === "android" ? 8 : 6;
                                                ctx.beginPath();
                                                var pts = 5;
                                                for (var p = 0; p < pts * 2; p++) {
                                                    var angle = (p * Math.PI / pts) - Math.PI / 2;
                                                    var r     = (p % 2 === 0) ? starR : innerR;
                                                    var px    = cx + r * Math.cos(angle);
                                                    var py    = cy + r * Math.sin(angle);
                                                    if (p === 0) ctx.moveTo(px, py);
                                                    else         ctx.lineTo(px, py);
                                                }
                                                ctx.closePath();
                                                ctx.fill();
                                                ctx.restore();
                                            }
                                        }

                                        // repaint whenever pulse changes
                                        Connections {
                                            target: big5StarsItem
                                            function onPulseScaleChanged() { big5StarsCanvas.requestPaint(); }
                                        }

                                        Component.onCompleted: { requestPaint(); }
                                    }
                                }
                                // ── end stars ─────────────────────────────────
                            }

                            // ── 3. Signal stream connector ────────────────────
                            Item {
                                id: arrowItem
                                anchors.left: big5PhotoCol.right
                                anchors.verticalCenter: parent.verticalCenter
                                width: Qt.platform.os === "android" ? 22 : 16
                                height:  parent.height * 0.8

                                NumberAnimation on opacity {
                                    running: true; from: 0; to: 1
                                    duration: 500; easing.type: Easing.OutQuad
                                }

                                // 5 traveling dash particles staggered vertically
                                Repeater {
                                    model: 5
                                    delegate: Item {
                                        id: dashDelegate
                                        property int idx: index
                                        property real sz: Qt.platform.os === "android" ? 3 : 2
                                        property real dashH: Qt.platform.os === "android" ? 10 : 7
                                        property real travelW: arrowItem.width - sz

                                        // each particle starts at a different vertical slice
                                        x: 0
                                        y: arrowItem.height * (index / 5.0)
                                        width: arrowItem.width
                                        height: arrowItem.height / 5.0

                                        // Dash rectangle
                                        Rectangle {
                                            id: dashRect
                                            y: (parent.height - dashDelegate.dashH) / 2
                                            width: dashDelegate.sz
                                            height: dashDelegate.dashH
                                            radius: dashDelegate.sz / 2
                                            color: "#02c6db"
                                            layer.enabled: true
                                            layer.effect: DropShadow {
                                                transparentBorder: true
                                                horizontalOffset: 0; verticalOffset: 0
                                                radius: 8; samples: 17; color: "#cc02c6db"
                                            }

                                            SequentialAnimation on x {
                                                loops: Animation.Infinite
                                                running: true
                                                PauseAnimation { duration: dashDelegate.idx * 260 }
                                                NumberAnimation { to: dashDelegate.travelW; duration: 0 }
                                                ParallelAnimation {
                                                    NumberAnimation { target: dashRect; property: "x"; from: 0; to: dashDelegate.travelW; duration: 700; easing.type: Easing.InCubic }
                                                    SequentialAnimation {
                                                        NumberAnimation { target: dashRect; property: "opacity"; from: 0; to: 1; duration: 120 }
                                                        PauseAnimation { duration: 420 }
                                                        NumberAnimation { target: dashRect; property: "opacity"; from: 1; to: 0; duration: 160 }
                                                    }
                                                }
                                                PauseAnimation { duration: (5 - dashDelegate.idx - 1) * 260 }
                                            }
                                        }
                                    }
                                }
                            }

                            // ── 4. heroTextArea — kulia ───────────────────────
                            Item {
                                id: heroTextArea
                                anchors.left: arrowItem.right
                                anchors.leftMargin: 4
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 16
                                height: heroTextCol.implicitHeight + 4

                                // slideOffset: resting y (via anchors.bottom) minus top-of-photo y
                                // top of photo y = heroBottomRow.height - raisPhotoCol.height - raisPhotoCol.bottomMargin
                                property real photoTopY: parent.height - big5PhotoCol.height - 6
                                property real restingY:  parent.height - height - (Qt.platform.os === "android" ? 12 : 8)
                                property real slideOffset: photoTopY - restingY

                                transform: Translate { y: heroTextArea.slideOffset }

                                ParallelAnimation {
                                    id: heroEntranceAnim
                                    running: false
                                    NumberAnimation {
                                        target: heroTextArea; property: "slideOffset"
                                        from: heroTextArea.slideOffset; to: 0
                                        duration: 720; easing.type: Easing.OutCubic
                                    }
                                    NumberAnimation {
                                        target: heroTextArea; property: "opacity"
                                        from: 0; to: 1; duration: 500; easing.type: Easing.OutQuad
                                    }
                                }
                                Component.onCompleted: { heroEntranceAnim.running = true; }

                                // Backdrop
                                Rectangle {
                                    id: heroBackdrop
                                    anchors.fill: parent
                                    anchors.leftMargin: -10
                                    anchors.rightMargin: -10
                                    anchors.topMargin: -14
                                    anchors.bottomMargin: -10
                                    radius: 18
                                    color: "#bb001e1c"
                                    border.color: "#441fb8ba"
                                    border.width: 1
                                    layer.enabled: true
                                    layer.effect: DropShadow {
                                        transparentBorder: true
                                        horizontalOffset: 0; verticalOffset: 4
                                        radius: 24; samples: 49; color: "#cc000e0d"
                                    }
                                }

                                // Top shimmer edge on backdrop
                                Rectangle {
                                    anchors.left: heroBackdrop.left
                                    anchors.right: heroBackdrop.right
                                    anchors.top: heroBackdrop.top
                                    height: 1
                                    radius: 1
                                    opacity: 0.35
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "transparent" }
                                        GradientStop { position: 0.35; color: "#02c6db" }
                                        GradientStop { position: 0.65; color: "#1fb8ba" }
                                        GradientStop { position: 1.0; color: "transparent" }
                                    }
                                }

                                // Left accent stripe
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.leftMargin: -10
                                    anchors.top: parent.top
                                    anchors.topMargin: -14
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: -10
                                    width: Qt.platform.os === "android" ? 5 : 4; radius: 3
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "#001fb8ba" }
                                        GradientStop { position: 0.2; color: "#cc02c6db" }
                                        GradientStop { position: 0.55; color: "#ff02c6db" }
                                        GradientStop { position: 0.8; color: "#cc1fb8ba" }
                                        GradientStop { position: 1.0; color: "#001fb8ba" }
                                    }
                                    layer.enabled: true
                                    layer.effect: DropShadow {
                                        transparentBorder: true
                                        horizontalOffset: 4; verticalOffset: 0
                                        radius: 10; samples: 21; color: "#dd02c6db"
                                    }
                                }

                                Column {
                                    id: heroTextCol
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    spacing: Qt.platform.os === "android" ? 6 : 5

                                    // Eyebrow pill badge
                                    Item {
                                        anchors.left: parent.left
                                        width: eyebrowRow.implicitWidth + (Qt.platform.os === "android" ? 16 : 12)
                                        height: eyebrowRow.implicitHeight + (Qt.platform.os === "android" ? 8 : 6)

                                        NumberAnimation on opacity {
                                            id: eyebrowFadeAnim; running: false
                                            from: 0; to: 1; duration: 450; easing.type: Easing.OutQuad
                                        }
                                        Component.onCompleted: { eyebrowDelayTimer.start(); }
                                        Timer {
                                            id: eyebrowDelayTimer
                                            interval: 300; repeat: false
                                            onTriggered: { eyebrowFadeAnim.running = true; }
                                        }

                                        Rectangle {
                                            anchors.fill: parent; radius: height / 2
                                            color: "#2202c6db"; border.color: "#8802c6db"; border.width: 1
                                        }

                                        Row {
                                            id: eyebrowRow
                                            anchors.centerIn: parent
                                            spacing: Qt.platform.os === "android" ? 6 : 4

                                            // sunray dot
                                            Item {
                                                width: Qt.platform.os === "android" ? 18 : 14
                                                height: Qt.platform.os === "android" ? 18 : 14
                                                anchors.verticalCenter: parent.verticalCenter

                                                Rectangle {
                                                    id: pingRing1; anchors.centerIn: parent
                                                    width: 6; height: 6; radius: 3
                                                    color: "transparent"; border.color: "#02c6db"; border.width: 1.5; opacity: 0
                                                    SequentialAnimation {
                                                        loops: Animation.Infinite; running: true
                                                        PauseAnimation { duration: 1800 }
                                                        ParallelAnimation {
                                                            NumberAnimation { target: pingRing1; property: "width";   from: 6; to: 18; duration: 700; easing.type: Easing.OutCubic }
                                                            NumberAnimation { target: pingRing1; property: "height";  from: 6; to: 18; duration: 700; easing.type: Easing.OutCubic }
                                                            NumberAnimation { target: pingRing1; property: "opacity"; from: 0.8; to: 0; duration: 700; easing.type: Easing.OutCubic }
                                                        }
                                                        ScriptAction { script: { pingRing1.width = 6; pingRing1.height = 6; } }
                                                    }
                                                }
                                                Rectangle {
                                                    id: pingRing2; anchors.centerIn: parent
                                                    width: 6; height: 6; radius: 3
                                                    color: "transparent"; border.color: "#1fb8ba"; border.width: 1; opacity: 0
                                                    SequentialAnimation {
                                                        loops: Animation.Infinite; running: true
                                                        PauseAnimation { duration: 2100 }
                                                        ParallelAnimation {
                                                            NumberAnimation { target: pingRing2; property: "width";   from: 6; to: 14; duration: 650; easing.type: Easing.OutCubic }
                                                            NumberAnimation { target: pingRing2; property: "height";  from: 6; to: 14; duration: 650; easing.type: Easing.OutCubic }
                                                            NumberAnimation { target: pingRing2; property: "opacity"; from: 0.5; to: 0; duration: 650; easing.type: Easing.OutCubic }
                                                        }
                                                        ScriptAction { script: { pingRing2.width = 6; pingRing2.height = 6; } }
                                                    }
                                                }
                                                Rectangle {
                                                    anchors.centerIn: parent; width: 6; height: 6; radius: 3
                                                    color: "#02c6db"
                                                    layer.enabled: true
                                                    layer.effect: DropShadow { transparentBorder: true; radius: 5; samples: 11; color: "#dd02c6db" }
                                                }
                                            }

                                            Text {
                                                id: eyebrowBadge
                                                text: langSettings.lang === "sw" ? "KARIBU TANZANIA" : "DISCOVER TANZANIA"
                                                font.pixelSize: Qt.platform.os === "android" ? 18 : 16
                                                font.bold: true; font.letterSpacing: 2.0
                                                color: "#02c6db"
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }


                                    // sub-quote — ndani ya heroTextArea
                                    Text {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        text: langSettings.lang === "sw"
                                              ? "Nchi yenye vivutio visivyo na mfano"
                                              : "A land of unmatched wonders"
                                        font.pixelSize: Qt.platform.os === "android" ? 21 : 14
                                        color: langSettings.lang === "sw" ? "green" : "blue"
                                        font.italic: true
                                        wrapMode: Text.WordWrap
                                        font.letterSpacing: 0.4
                                        layer.enabled: true
                                        layer.effect: DropShadow {
                                            transparentBorder: true
                                            horizontalOffset: 0; verticalOffset: 1
                                            radius: 5; samples: 11; color: langSettings.lang === "sw" ? "green" : "blue"
                                        }
                                    }

                                    // Main title
                                    Item {
                                        width: parent.width
                                        height: heroTitle.implicitHeight
                                        clip: true

                                        Text {
                                            id: heroTitle
                                            width: parent.width; x: -20; opacity: 0
                                            text: langSettings.lang === "sw" ? "Utalii wa Tanzania" : "Tanzania Tourism"
                                            font.pixelSize: Qt.platform.os === "android" ? 32 : 23
                                            font.bold: true; font.letterSpacing: -0.3
                                            color: "#f0ffffff"; wrapMode: Text.WordWrap
                                            layer.enabled: true
                                            layer.effect: DropShadow {
                                                transparentBorder: true
                                                horizontalOffset: 0; verticalOffset: 2
                                                radius: 16; samples: 33; color: "#dd02c6db"
                                            }
                                            ParallelAnimation {
                                                id: titleSlideAnim; running: false
                                                NumberAnimation { target: heroTitle; property: "x";       from: -20; to: 0; duration: 550; easing.type: Easing.OutCubic }
                                                NumberAnimation { target: heroTitle; property: "opacity"; from: 0;   to: 1; duration: 480; easing.type: Easing.OutQuad }
                                            }
                                            Component.onCompleted: { titleDelayTimer.start(); }
                                            Timer {
                                                id: titleDelayTimer; interval: 450; repeat: false
                                                onTriggered: { titleSlideAnim.running = true; }
                                            }
                                        }
                                    }

                                    // Subtitle
                                    Text {
                                        id: heroSubtitle
                                        anchors.left: parent.left; anchors.right: parent.right
                                        text: langSettings.lang === "sw"
                                              ? "Mbuga · Fukwe · Milima · Utamaduni"
                                              : "Wildlife · Beaches · Mountains · Culture"
                                        font.pixelSize: Qt.platform.os === "android" ? 20 : 14
                                        color: "#e602c6db"; wrapMode: Text.WordWrap; font.letterSpacing: 0.8
                                        layer.enabled: true
                                        layer.effect: DropShadow {
                                            transparentBorder: true
                                            horizontalOffset: 0; verticalOffset: 1
                                            radius: 6; samples: 13; color: "#99000000"
                                        }
                                        NumberAnimation on opacity {
                                            id: subtitleFadeAnim; running: false
                                            from: 0; to: 1; duration: 500; easing.type: Easing.OutQuad
                                        }
                                        Component.onCompleted: { subtitleDelayTimer.start(); }
                                        Timer {
                                            id: subtitleDelayTimer; interval: 620; repeat: false
                                            onTriggered: { subtitleFadeAnim.running = true; }
                                        }
                                    }

                                    // Accent bar
                                    Item {
                                        width: parent.width
                                        height: Qt.platform.os === "android" ? 5 : 4

                                        Rectangle {
                                            id: accentBar; height: parent.height; radius: height / 2; width: 0
                                            gradient: Gradient {
                                                GradientStop { position: 0.0; color: "#1fb8ba" }
                                                GradientStop { position: 0.4; color: "#02c6db" }
                                                GradientStop { position: 0.75; color: "#44d9f5" }
                                                GradientStop { position: 1.0; color: "#8802c6db" }
                                            }
                                            layer.enabled: true
                                            layer.effect: DropShadow { transparentBorder: true; radius: 9; samples: 19; color: "#cc02c6db" }
                                        }
                                        NumberAnimation on width {
                                            id: accentBarAnim; running: false
                                            target: accentBar; property: "width"
                                            from: 0; to: heroTextArea.width
                                            duration: 750; easing.type: Easing.OutCubic
                                        }
                                        SequentialAnimation {
                                            id: accentBarPulse; running: false; loops: Animation.Infinite
                                            NumberAnimation { target: accentBar; property: "opacity"; to: 0.5; duration: 1600; easing.type: Easing.InOutSine }
                                            NumberAnimation { target: accentBar; property: "opacity"; to: 1.0; duration: 1600; easing.type: Easing.InOutSine }
                                        }
                                        Component.onCompleted: {
                                            accentBarAnim.running = true;
                                            accentBarPulseTimer.start();
                                        }
                                        Timer {
                                            id: accentBarPulseTimer; interval: 800; repeat: false
                                            onTriggered: { accentBarPulse.running = true; }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ══ STATS BAR ══════════════════════════════════════════
                    Rectangle {
                        width: app.width
                        height: Qt.platform.os === "android" ? 56 : 42
                        color: "#001413"

                        Row {
                            anchors.centerIn: parent
                            spacing: 0

                            // Attractions count — animated roll
                            Column {
                                width: app.width * 0.5
                                spacing: 2
                                Text {
                                    id: rollingCountText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    property int displayCount: 0
                                    text: displayCount + "+"
                                    font.pointSize: Qt.platform.os === "android" ? 16 : 13
                                    font.bold: true
                                    color: "cyan"

                                    NumberAnimation on displayCount {
                                        id: countRollAnim
                                        from: 0
                                        to: attractionModel.count
                                        duration: 1400
                                        easing.type: Easing.OutCubic
                                        running: false
                                    }
                                    Timer {
                                        interval: 400; repeat: false; running: true
                                        onTriggered: countRollAnim.running = true;
                                    }
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: langSettings.lang === "sw"
                                          ? "Vivutio"
                                          : "Attractions"
                                    font.pointSize: Qt.platform.os === "android" ? 10 : 8
                                    color: "#aaaaaa"
                                }
                            }

                            // Divider
                            Rectangle {
                                width: 1
                                height: Qt.platform.os === "android" ? 36 : 28
                                color: "#33ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Tagline
                            Column {
                                width: app.width * 0.5
                                spacing: 2
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "🏔 🦁 🌊"
                                    font.pointSize: Qt.platform.os === "android" ? 14 : 11
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: langSettings.lang === "sw"
                                          ? "Mbuga · Utamaduni · Pwani"
                                          : "Parks · Culture · Coast"
                                    font.pointSize: Qt.platform.os === "android" ? 10 : 8
                                    color: "#aaaaaa"
                                }
                            }

                        }
                    }


                    // ══ DID YOU KNOW ═══════════════════════════════════════
                    Rectangle {
                        id: dykSection
                        width: app.width
                        height: dykCol.implicitHeight + (Qt.platform.os === "android" ? 32 : 24)
                        color: "#0a1a19"

                        function refreshDailyContent() {
                            var d = new Date();
                            dykIndex = d.getDate() % 100;
                        }

                        property var facts_sw: [
                            "Tanzania ina milima mirefu zaidi barani Afrika — Kilimanjaro, mita 5,895.",
                            "Serengeti ina uhamiaji mkubwa zaidi wa wanyama duniani — nyumbu milioni 1.5.",
                            "Zanzibar ilikuwa nchi huru hadi 1964 ilipounganishwa na Tanganyika.",
                            "Tanzania ina hifadhi za taifa 22 zinazofunika zaidi ya asilimia 38 ya nchi.",
                            "Ziwa Victoria ni ziwa kubwa zaidi barani Afrika.",
                            "Tanzania ni nchi pekee duniani yenye almasi za Tanzanite — jiwe la thamani la bluu.",
                            "Ngorongoro ni kaldera kubwa zaidi duniani inayokaliwa na wanyama.",
                            "Tanzania ina pwani ya kilomita 1,424 ya Bahari Hindi.",
                            "Dodoma ni mji mkuu wa Tanzania tangu 1974.",
                            "Kiswahili ni lugha ya kwanza ya Afrika kusomwa kwa herufi za Kiarabu.",
                            "Tanzania ina spishi zaidi ya ndege 1,100 — zaidi ya Ulaya yote.",
                            "Mto Rufiji ni mto mrefu zaidi Tanzania, ukipita katika Selous.",
                            "Selous Game Reserve ni hifadhi kubwa zaidi Afrika — kilomita 54,600.",
                            "Tanzania ilikuwa koloni la Ujerumani hadi 1919, kisha Uingereza.",
                            "Julius Nyerere alikuwa rais wa kwanza wa Tanzania na baba wa taifa.",
                            "Mikumi National Park ni hifadhi ya karibu zaidi na Dar es Salaam.",
                            "Tanzania ina makundi ya kikabila zaidi ya 120.",
                            "Kisiwa cha Pemba kinajulikana kwa kilimo bora zaidi cha karafuu duniani.",
                            "Ziwa Tanganyika ni ziwa refu zaidi duniani — kilomita 673.",
                            "Tanzania ina volcano inayofanya kazi — Ol Doinyo Lengai huko Arusha.",
                            "Dar es Salaam ni mji mkubwa zaidi Tanzania na bandari kuu.",
                            "Tarangire ina idadi kubwa zaidi ya tembo barani Afrika.",
                            "Ziwa Mara linajulikana kwa idadi kubwa ya mamba na viboko.",
                            "Stone Town ya Zanzibar ni Urithi wa Dunia wa UNESCO.",
                            "Tanzania ilivuka uhuru mwaka 1961 kwa amani bila vita.",
                            "Kilimanjaro ina maeneo matatu ya hali ya hewa — kitropiki, alpine, na barafu.",
                            "Tanzania inasifika kwa uzalishaji kwa kahawa nzuri duniani.",
                            "Tanzania ina misitu ya mvua ya Udzungwa yenye spishi adimu.",
                            "Gombe ni hifadhi ndogo zaidi Tanzania lakini maarufu kwa sokwe.",
                            "Jane Goodall alifanya utafiti wake wa sokwe Gombe mwaka 1960.",
                            "Ziwa Manyara linajulikana kwa simba wanaopanda miti.",
                            "Tanzania ina magofu ya Kilwa — mji wa kale wa biashara wa Swahili.",
                            "Pwani ya Mafia ina bahari ya kusafisha inayofaa kwa kupiga mbizi.",
                            "Bagamoyo ulikuwa mji mkuu wa Afrika Mashariki wakati wa ukoloni.",
                            "Tanzania ina maporomoko ya Kalambo — ya pili kwa urefu Afrika.",
                            "Ruaha National Park ina idadi kubwa ya simba kuliko mahali popote.",
                            "Tanzania inachangia zaidi ya asilimia 99 ya Tanzanite duniani.",
                            "Nyerere alianzisha sera ya Ujamaa na kujitegemea mwaka 1967.",
                            "Tanzania haina vita ya wenyewe kwa wenyewe tangu uhuru.",
                            "Ziwa Natron ni ziwa la chumvi linalounda makazi ya flamingo.",
                            "Tanzania ina spishi zaidi ya mimea 10,000.",
                            "Mji wa Arusha unaitwa 'Mji wa Kimataifa' kwa mikutano mingi.",
                            "Kilimanjaro inaweza kupandwa bila vifaa maalum vya milima.",
                            "Tanzania inauzwa kwa utalii zaidi ya dola bilioni 2 kila mwaka.",
                            "Vijiji vya Maasai vimehifadhi utamaduni wao kwa miaka mingi.",
                            "Spishi za samaki zaidi ya 350 zinapatikana katika Ziwa Victoria.",
                            "Tanzania ina bahari ya Mnazi Bay yenye matumbawe ya ajabu.",
                            "Kondoa Rock Art ni moja ya michoro ya zamani zaidi duniani.",
                            "Tanzania inapiganisha haki za mazingira kupitia sheria kali.",
                            "Mji wa Mwanza unaitwa 'Mji wa Pili' — bandari ya Ziwa Victoria.",
                            "Hifadhi ya Katavi ni moja ya mbali zaidi na tulivu Tanzania.",
                            "Tanzania ina maeneo ya UNESCO matano rasmi.",
                            "Biashara ya dhahabu ni sekta kubwa ya uchumi Tanzania.",
                            "Spishi za wanyama watambaao zaidi ya 150 zinaishi Tanzania.",
                            "Tanzania ina barabara kuu ya TANZAM inayounganisha Zambia.",
                            "Kilwa Kisiwani ilikuwa mji mkubwa wa biashara karne ya 14.",
                            "Tanzania ina migodi ya dhahabu ya Geita — kubwa zaidi Afrika.",
                            "Pwani ya Tanzania ina Tembo wa Bahari — dugong adimu.",
                            "Nyerere alitafsiri Shakespeare kwa Kiswahili.",
                            "Tanzania ina makaburi ya dinosaur — Tendaguru huko Lindi.",
                            "Ziwa Eyasi ni makazi ya Hadza — watu wa mwisho wanaokusanya chakula.",
                            "Tanzania inazalisha kahawa bora — Kilimanjaro na Mbeya.",
                            "Spishi za vipepeo zaidi ya 800 zinapatikana Tanzania.",
                            "Tanzania ina msitu wa Mahale — makazi ya sokwe wa kawaida.",
                            "Mvua ya masika Tanzania huanza Machi hadi Mei.",
                            "Tanzania inaunganisha nchi 8 za jirani.",
                            "Tanga ni mji wa pili wa zamani zaidi Tanzania.",
                            "Tanzania ina mito minne mikubwa — Rufiji, Ruvuma, Pangani, Wami.",
                            "Nyumbu wanaozaliwa Serengeti ni zaidi ya 8,000 kila siku wakati wa kuzaa.",
                            "Tanzania inatoa mafunzo ya uhifadhi wa wanyama kwa nchi nyingi.",
                            "Hifadhi ya Burigi-Chato ni mpya zaidi Tanzania — 2019.",
                            "Tanzania ina matunda ya baobab yenye vitamini C mara 6 ya machungwa.",
                            "Pwani ya Ushongo inajulikana kwa ufuo mzuri wa samaki.",
                            "Tanzania ina makaburi ya Laetoli — nyayo za binadamu wa zamani 3.7M.",
                            "Kilimanjaro inapoteza theluji yake — imepungua asilimia 85 tangu 1912.",
                            "Tanzania ina spishi 4 za fisi — wenye madoadoa, wenye mstari, ardhi, na usiku.",
                            "Bonde la Ufa linapita Tanzania kutoka kaskazini hadi kusini.",
                            "Tanzania ina siku ya uhuru — Desemba 9, 1961.",
                            "Ziwa Tanganyika lina kina cha mita 1,470 — pili kwa kina duniani.",
                            "Tanzania ina Chama cha Mapinduzi — CCM — kilichotawala tangu uhuru.",
                            "Mji wa Morogoro unajulikana kwa milima ya Uluguru.",
                            "Tanzania inazalisha chai ya ubora wa juu — Iringa na Mbeya.",
                            "Spishi za nyoka zaidi ya 130 zinapatikana Tanzania.",
                            "Tanzania ina Ukanda wa Pwani wenye misitu ya mikoko.",
                            "Kigoma ni lango la Ziwa Tanganyika na makazi ya sokwe.",
                            "Tanzania ina Shule ya Msingi ya kwanza Afrika Mashariki — Moshi 1893.",
                            "Mto Nile unachipua kutoka Ziwa Victoria nchini Tanzania.",
                            "Tanzania ina uhusiano mzuri na nchi zote jirani bila migogoro.",
                            "Kilimanjaro National Park ina msitu wa mvua, savanna, na alpine.",
                            "Tanzania ina spishi za kondoo wa mlimani — klipspringer.",
                            "Mji wa Lindi una historia ndefu ya biashara ya pembe za ndovu.",
                            "Tanzania ina makaburi ya Isimila — zana za mawe za miaka 60,000.",
                            "Ziwa Victoria linazalisha tani 500,000 za samaki kila mwaka.",
                            "Tanzania inashiriki kwenye East African Community tangu 2000.",
                            "Wanyama watano wakubwa — simba, tembo, nyati, chui, kifaru — wote wako Tanzania.",
                            "Tanzania ina barabara ya reli inayounganisha pwani na nchi jirani.",
                            "Nyumba za Swahili za Stone Town zina milango ya mbao iliyochongwa.",
                            "Tanzania ina vivutio vya asili na utamaduni ambavyo havipo mahali pengine."
                        ]

                        property var facts_en: [
                            "Tanzania has Africa's highest peak — Mount Kilimanjaro at 5,895m.",
                            "The Serengeti hosts the world's largest animal migration — 1.5 million wildebeest.",
                            "Zanzibar was an independent state until unifying with Tanganyika in 1964.",
                            "Tanzania has 22 national parks covering over 38% of its land area.",
                            "Lake Victoria is the largest lake in Africa.",
                            "Tanzania is the only source of Tanzanite — a rare blue gemstone.",
                            "Ngorongoro is the world's largest intact volcanic caldera inhabited by wildlife.",
                            "Tanzania has 1,424 km of Indian Ocean coastline.",
                            "Dodoma became Tanzania's official capital city in 1974.",
                            "Swahili was the first African language written in Arabic script.",
                            "Tanzania is home to over 1,100 bird species — more than all of Europe.",
                            "The Rufiji River is Tanzania's longest river, flowing through Selous.",
                            "Selous Game Reserve is Africa's largest protected area at 54,600 km².",
                            "Tanzania was a German colony until 1919, then British until independence.",
                            "Julius Nyerere was Tanzania's founding father and first president.",
                            "Mikumi National Park is the closest national park to Dar es Salaam.",
                            "Tanzania is home to over 120 distinct ethnic groups.",
                            "Pemba Island is considered the world's finest clove-growing region.",
                            "Lake Tanganyika is the world's longest freshwater lake at 673 km.",
                            "Tanzania has an active volcano — Ol Doinyo Lengai near Arusha.",
                            "Dar es Salaam is Tanzania's largest city and main commercial port.",
                            "Tarangire National Park has the highest elephant density in Africa.",
                            "The Mara River is famous for its massive crocodile and hippo populations.",
                            "Stone Town in Zanzibar is a UNESCO World Heritage Site.",
                            "Tanzania gained independence peacefully in 1961 without armed conflict.",
                            "Kilimanjaro has three distinct climate zones — tropical, alpine, and arctic.",
                            "Tanzania produces some of Africa's finest specialty coffee.",
                            "The Udzungwa Mountains Forest contains rare endemic species found nowhere else.",
                            "Gombe is Tanzania's smallest national park but famous for chimpanzees.",
                            "Jane Goodall began her groundbreaking chimpanzee research at Gombe in 1960.",
                            "Lake Manyara is famous for its tree-climbing lions.",
                            "Tanzania has the ruins of Kilwa — a major ancient Swahili trading city.",
                            "Mafia Island's marine park is one of Africa's premier dive destinations.",
                            "Bagamoyo was the capital of German East Africa during colonial times.",
                            "Kalambo Falls is Africa's second-highest waterfall, on the Zambia border.",
                            "Ruaha National Park has the largest lion population of any African park.",
                            "Tanzania supplies over 99% of the world's Tanzanite gemstone.",
                            "Nyerere introduced the Ujamaa socialist policy in the Arusha Declaration of 1967.",
                            "Tanzania has maintained peace and stability since independence in 1961.",
                            "Lake Natron is a highly alkaline soda lake that forms flamingo breeding habitat.",
                            "Tanzania is home to over 10,000 plant species.",
                            "Arusha city is known as the 'Geneva of Africa' for its international conferences.",
                            "Kilimanjaro can be climbed without technical mountaineering equipment.",
                            "Tanzania earns over $2 billion annually from tourism.",
                            "Maasai villages have preserved their traditional culture for centuries.",
                            "Lake Victoria contains over 350 species of fish, many found nowhere else.",
                            "Tanzania's Mnazi Bay has some of East Africa's most pristine coral reefs.",
                            "The Kondoa Rock Art paintings are among the oldest in the world.",
                            "Tanzania enforces some of Africa's toughest wildlife poaching laws.",
                            "Mwanza is Tanzania's second city and a major port on Lake Victoria.",
                            "Katavi National Park is one of Tanzania's most remote and unspoiled parks.",
                            "Tanzania has five official UNESCO World Heritage Sites.",
                            "Gold mining is a major sector of Tanzania's economy.",
                            "Tanzania is home to over 150 species of reptiles.",
                            "The TANZAM Highway connects Tanzania to landlocked Zambia.",
                            "Kilwa Kisiwani was one of the wealthiest trading cities in the 14th century.",
                            "The Geita Gold Mine is one of the largest gold mines in Africa.",
                            "Tanzania's coastline is home to the rare dugong sea mammal.",
                            "Nyerere translated Shakespeare's Julius Caesar into Swahili.",
                            "Tanzania has one of the world's richest dinosaur fossil sites at Tendaguru.",
                            "Lake Eyasi is home to the Hadza — one of the last hunter-gatherer peoples.",
                            "Tanzania produces high-quality coffee from Kilimanjaro and Mbeya regions.",
                            "Over 800 butterfly species have been recorded in Tanzania.",
                            "Mahale Mountains is home to one of Africa's largest chimpanzee communities.",
                            "Tanzania's long rains season runs from March to May each year.",
                            "Tanzania shares borders with eight different countries.",
                            "Tanga is one of Tanzania's oldest cities with a rich colonial history.",
                            "Tanzania's four major rivers are Rufiji, Ruvuma, Pangani, and Wami.",
                            "Over 8,000 wildebeest calves are born daily during the Serengeti calving season.",
                            "Tanzania provides wildlife conservation training programs for many African nations.",
                            "Burigi-Chato is Tanzania's newest national park, established in 2019.",
                            "Baobab fruit has six times more Vitamin C than oranges.",
                            "Tanzania's Ushongo Beach is renowned for its exceptional sport fishing.",
                            "The Laetoli footprints in Tanzania are 3.7 million years old — made by early humans.",
                            "Kilimanjaro has lost 85% of its ice cap since 1912 due to climate change.",
                            "Tanzania has four species of hyena — spotted, striped, brown, and aardwolf.",
                            "The Great Rift Valley runs through Tanzania from north to south.",
                            "Tanzania's independence day is December 9, 1961.",
                            "Lake Tanganyika reaches a depth of 1,470m — the world's second deepest lake.",
                            "Tanzania has been governed by the CCM party continuously since independence.",
                            "Morogoro city is known for the spectacular Uluguru Mountain range.",
                            "Tanzania produces premium tea in the Iringa and Mbeya highland regions.",
                            "Over 130 snake species have been recorded in Tanzania.",
                            "Tanzania's coastline has extensive mangrove forests protecting the shore.",
                            "Kigoma is the gateway to Lake Tanganyika and nearby chimpanzee habitats.",
                            "The source of the Nile River flows from Lake Victoria in Tanzania.",
                            "Tanzania maintains peaceful diplomatic relations with all its neighbors.",
                            "Kilimanjaro National Park contains rainforest, savanna, alpine, and arctic zones.",
                            "Klipspringer antelopes are found in Tanzania's rocky highland areas.",
                            "Lindi town has a long history as an ivory and trade hub.",
                            "Isimila Stone Age Site near Iringa has tools over 60,000 years old.",
                            "Lake Victoria produces over 500,000 tonnes of fish annually.",
                            "Tanzania has been a member of the East African Community since 2000.",
                            "All of the Big Five — lion, elephant, buffalo, leopard, rhino — live in Tanzania.",
                            "Tanzania's railway network connects the coast to neighboring landlocked countries.",
                            "Zanzibar's Stone Town doors are famous for their intricate hand-carved woodwork.",
                            "Tanzania offers natural and cultural attractions found nowhere else on Earth."
                        ]

                        property int dykIndex: (new Date()).getDate() % 100

                        // Left cyan accent bar
                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            width: 4
                            height: parent.height - (Qt.platform.os === "android" ? 20 : 14)
                            radius: 2
                            color: "#00ccaa"
                        }

                        Column {
                            id: dykCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 30
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Qt.platform.os === "android" ? 5 : 4

                            Row {
                                spacing: 8
                                anchors.left: parent.left
                                anchors.right: parent.right

                                Text {
                                    text: langSettings.lang === "sw" ? "💡 Je, wajua?" : "💡 Did you know?"
                                    font.pointSize: Qt.platform.os === "android" ? 10 : 8
                                    font.bold: true
                                    color: langSettings.lang === "sw" ? "green" : "blue"
                                }

                                Text {
                                    text: {
                                        var d = new Date();
                                        var months_sw = ["Januari","Februari","Machi","Aprili","Mei","Juni","Julai","Agosti","Septemba","Oktoba","Novemba","Desemba"];
                                        var months_en = ["January","February","March","April","May","June","July","August","September","October","November","December"];
                                        var months = langSettings.lang === "sw" ? months_sw : months_en;
                                        return d.getDate() + " " + months[d.getMonth()] + " " + d.getFullYear();
                                    }
                                    font.pointSize: Qt.platform.os === "android" ? 9 : 7
                                    color: "#888888"
                                    font.italic: true
                                    anchors.verticalCenter: undefined
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Text {
                                width: parent.width
                                text: langSettings.lang === "sw"
                                      ? parent.parent.facts_sw[parent.parent.dykIndex]
                                      : parent.parent.facts_en[parent.parent.dykIndex]
                                font.pointSize: Qt.platform.os === "android" ? 11 : 9
                                color: "#cccccc"
                                wrapMode: Text.WordWrap
                                font.italic: true
                            }
                        }
                    }

                    // ══ SPECIAL DATED DID YOU KNOW — multi-date calendar ══
                    Rectangle {
                        id: specialDykSection
                        width: app.width
                        color: "#0d0a00"
                        clip: true

                        // ── Calendar of special Tanzania dates ──────────────
                        // Each entry: { m: month(0-based), d: day, icon, color, accent,
                        //   label_sw, label_en, title_sw, title_en, body_sw, body_en }
                        property var calendarEntries: [
                            {
                                m: 0, d: 1,
                                icon: "🎆", color: "#1a3a6a", accent: "#4488ff",
                                label_sw: "Mwaka Mpya",
                                label_en: "New Year's Day",
                                title_sw: "Januari 1 — Mwaka Mpya Tanzania",
                                title_en: "January 1 — Tanzania New Year",
                                body_sw: "Tanzania inaadhimisha mwaka mpya kwa shangwe kubwa. Dar es Salaam, Zanzibar na miji mingi hujaa muziki, milio ya fataki, na watu wanaosherehekea pamoja.",
                                body_en: "Tanzania welcomes the new year with vibrant celebrations. Dar es Salaam, Zanzibar and many cities fill with music, fireworks, and people celebrating together."
                            },
                            {
                                m: 0, d: 12,
                                icon: "✊", color: "#4a0a0a", accent: "#cc3300",
                                label_sw: "Siku ya Mapinduzi ya Zanzibar",
                                label_en: "Zanzibar Revolution Day",
                                title_sw: "12 Januari 1964 — Mapinduzi ya Zanzibar",
                                title_en: "January 12, 1964 — Zanzibar Revolution",
                                body_sw: "Tarehe hii Wazanzibari waliipindua utawala wa Kisultani wa Kiarabu. Seyyid Jamshid bin Abdullah, Sultan wa Zanzibar, alikimbia nchi. Mapinduzi haya yalifungua njia ya muungano wa Zanzibar na Tanganyika kuunda Tanzania.",
                                body_en: "On this day Zanzibaris overthrew the Arab Sultanate. Sultan Jamshid bin Abdullah fled the island. This revolution opened the path to Zanzibar uniting with Tanganyika to form Tanzania."
                            },
                            {
                                m: 1, d: 5,
                                icon: "📜", color: "#1a2a0a", accent: "#66aa00",
                                label_sw: "Tamko la Arusha",
                                label_en: "Arusha Declaration",
                                title_sw: "5 Februari 1967 — Tamko la Arusha",
                                title_en: "February 5, 1967 — The Arusha Declaration",
                                body_sw: "Mwalimu Julius Nyerere alitangaza Tamko la Arusha — dira ya Ujamaa na Kujitegemea. Sera hii ilisisitiza usawa, elimu kwa wote, na ardhi kuwa mali ya umma. Iliathiri mataifa mengi ya Afrika.",
                                body_en: "Mwalimu Julius Nyerere announced the Arusha Declaration — the vision of Ujamaa and self-reliance. This policy emphasized equality, universal education, and land as public property. It influenced many African nations."
                            },
                            {
                                m: 2, d: 25,
                                icon: "🕯️", color: "#1a1400", accent: "#c8a400",
                                label_sw: "Siku ya Ukumbusho wa Utumwa",
                                label_en: "Slavery Remembrance Day",
                                title_sw: "25 Machi — Siku ya Kimataifa ya Ukumbusho wa Waathirika wa Utumwa",
                                title_en: "March 25 — International Day of Remembrance of Slavery Victims",
                                body_sw: "Umoja wa Mataifa unaiadhimisha siku hii kukumbuka waathirika wa biashara ya watumwa ya Atlantiki. Zanzibar ilikuwa kituo kikuu cha utumwa Afrika Mashariki — watu 50,000 waliuzwa hapo kila mwaka. Mnamo 1873 soko hilo la mwisho duniani lilifungwa. Magofu ya Bagamoyo na kanisa la Zanzibar lililojengwa juu ya soko la watumwa yanasimulia historia hii nzito.",
                                body_en: "The UN observes this day to honour victims of the transatlantic slave trade. Zanzibar was East Africa's main slave hub — 50,000 people were sold there annually. In 1873 the world's last slave market was closed. The ruins of Bagamoyo and Zanzibar's cathedral built over the slave market still tell this weighty history."
                            },
                            {
                                m: 3, d: 7,
                                icon: "🕊️", color: "#1a0a0a", accent: "#aa2200",
                                label_sw: "Siku ya Karume",
                                label_en: "Karume Day",
                                title_sw: "7 Aprili 1972 — Siku ya Karume",
                                title_en: "April 7, 1972 — Karume Day",
                                body_sw: "Sheikh Abeid Amani Karume, rais wa kwanza wa Zanzibar na makamu wa kwanza wa Tanzania, aliuawa tarehe hii mwaka 1972. Alikuwa kiongozi mkuu wa mapinduzi ya 1964 na alichangia sana maendeleo ya elimu na afya Zanzibar.",
                                body_en: "Sheikh Abeid Amani Karume, first president of Zanzibar and first Vice President of Tanzania, was assassinated on this day in 1972. He was the key leader of the 1964 revolution and greatly advanced education and healthcare in Zanzibar."
                            },
                            {
                                m: 3, d: 26,
                                icon: "🤝", color: "#0a1a0a", accent: "#00aa44",
                                label_sw: "Siku ya Muungano",
                                label_en: "Union Day",
                                title_sw: "26 Aprili 1964 — Muungano wa Tanzania",
                                title_en: "April 26, 1964 — Tanzania Union Day",
                                body_sw: "Siku hii Tanganyika na Zanzibar ziliungana kuunda Jamhuri ya Muungano wa Tanzania. Mwalimu Julius Nyerere akawa rais wa kwanza na Abeid Karume makamu wake. Muungano huu unaendelea hadi leo — nguvu ya amani na umoja.",
                                body_en: "On this day Tanganyika and Zanzibar united to form the United Republic of Tanzania. Mwalimu Julius Nyerere became first president and Abeid Karume his deputy. This union continues today — a beacon of peace and unity."
                            },
                            {
                                m: 4, d: 1,
                                icon: "⚒️", color: "#0a0a1a", accent: "#4444cc",
                                label_sw: "Siku ya Wafanyakazi",
                                label_en: "Workers' Day",
                                title_sw: "1 Mei — Siku ya Wafanyakazi Duniani",
                                title_en: "May 1 — International Workers' Day",
                                body_sw: "Tanzania inaadhimisha siku hii kwa mikutano ya vyama vya wafanyakazi, hotuba za viongozi, na maandamano. Wafanyakazi wa sekta zote — kilimo, ujenzi, elimu, na afya — wanashukurishwa mchango wao wa kujenga taifa.",
                                body_en: "Tanzania marks this day with trade union rallies, leader speeches, and marches. Workers from all sectors — agriculture, construction, education, and health — are honoured for their contribution to building the nation."
                            },
                            {
                                m: 5, d: 7,
                                icon: "⛰️", color: "#0a1a1a", accent: "#00ccaa",
                                label_sw: "Kilimanjaro — Sherehe ya Kwanza Kupanda",
                                label_en: "Kilimanjaro — First Summit Anniversary",
                                title_sw: "7 Juni 1889 — Hans Meyer Apanda Kilimanjaro",
                                title_en: "June 7, 1889 — Hans Meyer Summits Kilimanjaro",
                                body_sw: "Tarehe hii mwaka 1889, Hans Meyer wa Ujerumani na Ludwig Purtscheller walikuwa wazungu wa kwanza kuwahi kupanda kilele cha Uhuru Peak cha Mlima Kilimanjaro — mita 5,895. Leo wapandaji zaidi ya 50,000 hujaribu kila mwaka.",
                                body_en: "On this date in 1889, Hans Meyer of Germany and Ludwig Purtscheller became the first Europeans to summit Kilimanjaro's Uhuru Peak at 5,895m. Today over 50,000 climbers attempt the mountain every year."
                            },
                            {
                                m: 6, d: 7,
                                icon: "🌾", color: "#1a1500", accent: "#bbaa00",
                                label_sw: "Saba Saba — Siku ya Wakulima",
                                label_en: "Saba Saba — Peasants' Day",
                                title_sw: "7 Julai — Saba Saba",
                                title_en: "July 7 — Saba Saba Day",
                                body_sw: "Saba Saba (saba-saba = 7-7) inaadhimisha kuanzishwa kwa TANU mwaka 1954 — chama kilichopigana kwa uhuru wa Tanganyika. Leo inajulikana zaidi kama Siku ya Wakulima na Maonesho ya Kimataifa ya Biashara Dar es Salaam.",
                                body_en: "Saba Saba (seven-seven = 7-7) commemorates the founding of TANU in 1954 — the party that fought for Tanganyika's independence. Today it is better known as Peasants' Day and the Dar es Salaam International Trade Fair."
                            },
                            {
                                m: 7, d: 8,
                                icon: "🚜", color: "#0a1500", accent: "#55cc00",
                                label_sw: "Nane Nane — Siku ya Wakulima",
                                label_en: "Nane Nane — Farmers' Day",
                                title_sw: "8 Agosti — Nane Nane",
                                title_en: "August 8 — Nane Nane Farmers' Day",
                                body_sw: "Nane Nane (8-8) ni siku ya kusherehekea wakulima wa Tanzania. Zaidi ya asilimia 65 ya Watanzania wanategemea kilimo. Maonesho ya kilimo hufanyika kote nchini, yakionyesha mazao, teknolojia za kisasa, na mifugo.",
                                body_en: "Nane Nane (8-8) celebrates Tanzania's farmers. Over 65% of Tanzanians depend on agriculture. Agricultural shows are held nationwide, showcasing crops, modern technology, and livestock."
                            },
                            {
                                m: 7, d: 25,
                                icon: "⚔️", color: "#1a0a0a", accent: "#cc6600",
                                label_sw: "Vita Fupi Zaidi — Anglo-Zanzibar 1896",
                                label_en: "Shortest War in History — 1896",
                                title_sw: "27 Agosti 1896 — Vita vya Anglo-Zanzibar",
                                title_en: "August 27, 1896 — Anglo-Zanzibar War",
                                body_sw: "Vita vya Anglo-Zanzibar vilidumu dakika 38 tu — vita vifupi zaidi katika historia ya dunia. Meli za Uingereza zilipiga makombora ikulu ya Zanzibar baada ya Sultan mpya Khalid bin Barghash kukataa kushuka madarakani. Sultan alikimbilia ubalozi wa Ujerumani.",
                                body_en: "The Anglo-Zanzibar War lasted just 38 minutes — the shortest war in recorded history. British warships shelled Zanzibar's palace after new Sultan Khalid bin Barghash refused to stand down. The sultan fled to the German consulate."
                            },
                            {
                                m: 9, d: 14,
                                icon: "🌟", color: "#1a1200", accent: "#ddaa00",
                                label_sw: "Siku ya Nyerere",
                                label_en: "Nyerere Day",
                                title_sw: "14 Oktoba 1999 — Siku ya Nyerere",
                                title_en: "October 14, 1999 — Nyerere Day",
                                body_sw: "Mwalimu Julius Kambarage Nyerere alifariki tarehe hii mwaka 1999 akiwa na umri wa miaka 77. Baba wa Taifa, mwalimu, mwanadiplomasia, na mwandishi — alitafsiri Shakespeare kwa Kiswahili. Amezikwa huko Butiama, mji wake wa asili, na Makumbusho ya Nyerere inabaki kumbukumbu yake.",
                                body_en: "Mwalimu Julius Kambarage Nyerere passed away on this date in 1999 aged 77. Father of the Nation, teacher, diplomat, and writer — he translated Shakespeare into Swahili. He is buried in Butiama, his home village, and the Nyerere Museum preserves his legacy."
                            },
                            {
                                m: 11, d: 9,
                                icon: "🇹🇿", color: "#001a00", accent: "#00cc55",
                                label_sw: "Siku ya Uhuru wa Tanzania",
                                label_en: "Tanzania Independence Day",
                                title_sw: "9 Desemba 1961 — Uhuru wa Tanganyika",
                                title_en: "December 9, 1961 — Tanganyika Independence",
                                body_sw: "Tarehe hii Tanganyika ilipata uhuru wake kwa amani kutoka kwa Uingereza. Nyerere akawa Waziri Mkuu. Ni mwanzo wa safari ya Tanzania kuwa taifa huru. Siku hii inadhimishwa kila mwaka kwa maandamano, hotuba, na taa ya Uhuru iliyopasuliwa juu ya Kilimanjaro.",
                                body_en: "On this day Tanganyika peacefully gained independence from Britain. Nyerere became Prime Minister. It marks the beginning of Tanzania's journey as a free nation. The day is marked annually with parades, speeches, and the Uhuru Torch carried to Kilimanjaro's summit."
                            },
                            {
                                m: 11, d: 10,
                                icon: "🏝️", color: "#001a1a", accent: "#00aacc",
                                label_sw: "Uhuru wa Zanzibar",
                                label_en: "Zanzibar Independence",
                                title_sw: "10 Desemba 1963 — Zanzibar Yapata Uhuru",
                                title_en: "December 10, 1963 — Zanzibar Gains Independence",
                                body_sw: "Zanzibar ilipata uhuru wake kutoka kwa Uingereza chini ya miezi miwili kabla ya mapinduzi ya Januari 1964. Sultani Jamshid bin Abdullah alibaki madarakani kwa muda mfupi. Uhuru huu ulianzisha kipande kipya cha historia ya visiwa hivi vya Bahari ya Hindi.",
                                body_en: "Zanzibar gained independence from Britain less than two months before the January 1964 revolution. Sultan Jamshid bin Abdullah briefly held power. This independence began a new chapter in the history of these Indian Ocean islands."
                            }
                        ]

                        // ── Find today's matching entry ─────────────────────
                        property var todayEntry: {
                            var d = new Date();
                            var m = d.getMonth();
                            var day = d.getDate();
                            for (var i = 0; i < calendarEntries.length; i++) {
                                if (calendarEntries[i].m === m && calendarEntries[i].d === day) {
                                    return calendarEntries[i];
                                }
                            }
                            return null;
                        }

                        visible: todayEntry !== null
                        height: visible ? (specialDykInner.implicitHeight + (Qt.platform.os === "android" ? 36 : 28)) : 0

                        // Coloured left accent bar — uses entry's accent colour
                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            width: 4
                            height: parent.height - (Qt.platform.os === "android" ? 20 : 14)
                            radius: 2
                            color: specialDykSection.todayEntry ? specialDykSection.todayEntry.accent : "#c8a400"
                        }

                        Column {
                            id: specialDykInner
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 30
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Qt.platform.os === "android" ? 6 : 5

                            // Header row: icon + label
                            Row {
                                width: parent.width
                                spacing: 6

                                Text {
                                    text: specialDykSection.todayEntry ? specialDykSection.todayEntry.icon : "📅"
                                    font.pointSize: Qt.platform.os === "android" ? 13 : 11
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: {
                                        if (!specialDykSection.todayEntry) { return ""; }
                                        var prefix = langSettings.lang === "sw" ? "Je, wajua? • " : "Did you know? • ";
                                        return prefix + (langSettings.lang === "sw"
                                                         ? specialDykSection.todayEntry.label_sw
                                                         : specialDykSection.todayEntry.label_en);
                                    }
                                    font.pointSize: Qt.platform.os === "android" ? 10 : 8
                                    font.bold: true
                                    color: specialDykSection.todayEntry ? specialDykSection.todayEntry.accent : "#c8a400"
                                    anchors.verticalCenter: parent.verticalCenter
                                    wrapMode: Text.WordWrap
                                    width: parent.width - 30
                                }
                            }

                            // Title
                            Text {
                                width: parent.width
                                text: {
                                    if (!specialDykSection.todayEntry) { return ""; }
                                    return langSettings.lang === "sw"
                                            ? specialDykSection.todayEntry.title_sw
                                            : specialDykSection.todayEntry.title_en;
                                }
                                font.pointSize: Qt.platform.os === "android" ? 12 : 10
                                font.bold: true
                                color: "#f0e0b0"
                                wrapMode: Text.WordWrap
                            }

                            // Body text
                            Text {
                                width: parent.width
                                text: {
                                    if (!specialDykSection.todayEntry) { return ""; }
                                    return langSettings.lang === "sw"
                                            ? specialDykSection.todayEntry.body_sw
                                            : specialDykSection.todayEntry.body_en;
                                }
                                font.pointSize: Qt.platform.os === "android" ? 11 : 9
                                color: "#cccccc"
                                wrapMode: Text.WordWrap
                                font.italic: true
                            }
                        }
                    }

                    // ══ MAP SECTION ════════════════════════════════════════
                    Rectangle {
                        width: app.width
                        height: mapImg.implicitHeight + 24
                        color: "#001413"

                        Text {
                            id: mapLabel
                            anchors.top: parent.top
                            anchors.topMargin: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: langSettings.lang === "sw" ? "Ramani ya Tanzania" : "Map of Tanzania"
                            font.pointSize: Qt.platform.os === "android" ? 11 : 9
                            color: "cyan"
                            font.bold: true
                        }

                        Image {
                            id: mapImg
                            source: "./TZmap.png"
                            width: app.width * 0.8
                            fillMode: Image.PreserveAspectFit
                            anchors.top: mapLabel.bottom
                            anchors.topMargin: 6
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    //Spacing Rect
                    Rectangle{
                        color:"#001413"
                        width: parent.width
                        height: 16
                    }

                    // ══ TANZANIA ARTICLE — PIRATE SCROLL BUTTON ══════════
                    Rectangle {
                        id: articleBtnSection
                        width: app.width
                        height: Qt.platform.os === "android" ? 178 : 144
                        color: "#001413"
                        clip: true

                        // ── scroll rod top ────────────────────────────────
                        Rectangle {
                            id: scrollRodTop
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: app.width * 0.82
                            height: Qt.platform.os === "android" ? 14 : 11
                            radius: height / 2
                            color: langSettings.lang === "sw" ? "#001a14" : "#00141a"
                            border.color: langSettings.lang === "sw" ? "#1a6050" : "#1a5060"
                            border.width: 1

                            // rod sheen
                            Rectangle {
                                anchors.top: parent.top
                                anchors.topMargin: 2
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width * 0.7
                                height: 2
                                radius: 1
                                color: langSettings.lang === "sw" ? "#00cc99" : "blue"
                                opacity: 0.55
                            }

                            // end knobs
                            Rectangle {
                                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: -3
                                width: parent.height + 4; height: parent.height + 4; radius: (parent.height + 4) / 2
                                color: langSettings.lang === "sw" ? "#1a6050" : "#1a5060"
                                border.color: langSettings.lang === "sw" ? "#00aa77" : "blue"; border.width: 1
                            }
                            Rectangle {
                                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                anchors.rightMargin: -3
                                width: parent.height + 4; height: parent.height + 4; radius: (parent.height + 4) / 2
                                color: langSettings.lang === "sw" ? "#1a6050" : "#1a5060"
                                border.color: langSettings.lang === "sw" ? "#00aa77" : "blue"; border.width: 1
                            }
                        }

                        // ── scroll rod bottom ─────────────────────────────
                        Rectangle {
                            id: scrollRodBot
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: app.width * 0.82
                            height: Qt.platform.os === "android" ? 14 : 11
                            radius: height / 2
                            color: langSettings.lang === "sw" ? "#001a14" : "#00141a"
                            border.color: langSettings.lang === "sw" ? "#1a6050" : "#1a5060"
                            border.width: 1

                            Rectangle {
                                anchors.top: parent.top; anchors.topMargin: 2
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width * 0.7; height: 2; radius: 1
                                color: langSettings.lang === "sw" ? "#00cc99" : "blue"; opacity: 0.55
                            }
                            Rectangle {
                                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: -3
                                width: parent.height + 4; height: parent.height + 4; radius: (parent.height + 4) / 2
                                color: langSettings.lang === "sw" ? "#1a6050" : "#1a5060"; border.color: langSettings.lang === "sw" ? "#00aa77" : "blue"; border.width: 1
                            }
                            Rectangle {
                                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                anchors.rightMargin: -3
                                width: parent.height + 4; height: parent.height + 4; radius: (parent.height + 4) / 2
                                color: langSettings.lang === "sw" ? "#1a6050" : "#1a5060"; border.color: langSettings.lang === "sw" ? "#00aa77" : "blue"; border.width: 1
                            }
                        }

                        // ── parchment body between rods ───────────────────
                        Rectangle {
                            id: parchmentBody
                            anchors.top: scrollRodTop.bottom
                            anchors.bottom: scrollRodBot.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: app.width * 0.82
                            color: langSettings.lang === "sw" ? "#001a14" : "#00141a"
                            border.color: langSettings.lang === "sw" ? "#0a5040" : "#0a4050"
                            border.width: 1

                            // inner parchment glow
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 2
                                color: "transparent"
                                border.color: langSettings.lang === "sw" ? "#5000cc99" : "#5000003a"
                                border.width: 1
                            }

                            // ── compass rose decoration ───────────────────
                            Canvas {
                                id: compassCanvas
                                width: Qt.platform.os === "android" ? 28 : 22
                                height: width
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.margins: 6
                                opacity: 0.28

                                property real spinAngle: 0
                                NumberAnimation on spinAngle {
                                    from: 0; to: 360
                                    duration: 18000
                                    loops: Animation.Infinite
                                    running: true
                                }
                                onSpinAngleChanged: { requestPaint(); }

                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    var cx = width / 2; var cy = height / 2;
                                    var r  = width * 0.42;
                                    ctx.save();
                                    ctx.translate(cx, cy);
                                    ctx.rotate(spinAngle * Math.PI / 180);
                                    ctx.translate(-cx, -cy);
                                    // 8 points
                                    var pts = 8;
                                    for (var i = 0; i < pts; i++) {
                                        var a = (i / pts) * Math.PI * 2;
                                        var isMain = (i % 2 === 0);
                                        var tipR = isMain ? r : r * 0.62;
                                        ctx.beginPath();
                                        ctx.moveTo(cx, cy);
                                        ctx.lineTo(
                                                    cx + tipR * Math.sin(a - 0.18),
                                                    cy - tipR * Math.cos(a - 0.18)
                                                    );
                                        ctx.lineTo(
                                                    cx + tipR * Math.sin(a),
                                                    cy - tipR * Math.cos(a)
                                                    );
                                        ctx.lineTo(
                                                    cx + tipR * Math.sin(a + 0.18),
                                                    cy - tipR * Math.cos(a + 0.18)
                                                    );
                                        ctx.closePath();
                                        ctx.fillStyle = isMain ? (langSettings.lang === "sw" ? "#00ddaa" : "blue") : (langSettings.lang === "sw" ? "#1a6050" : "#1a5060");
                                        ctx.fill();
                                    }
                                    ctx.restore();
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, width * 0.1, 0, Math.PI * 2);
                                    ctx.fillStyle = (langSettings.lang === "sw" ? "#00aa77" : "blue");
                                    ctx.fill();
                                }
                                Component.onCompleted: { requestPaint(); }
                            }

                            // ── wave / rope separator line ────────────────
                            Canvas {
                                id: waveSepCanvas
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width - 16
                                height: 10
                                property real wavePhase: 0
                                NumberAnimation on wavePhase {
                                    from: 0; to: Math.PI * 2
                                    duration: 2400; loops: Animation.Infinite; running: true
                                }
                                onWavePhaseChanged: { requestPaint(); }
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    ctx.strokeStyle = (langSettings.lang === "sw" ? "#1a6050" : "#1a5060");
                                    ctx.lineWidth = 1.5;
                                    ctx.beginPath();
                                    for (var x = 0; x <= width; x += 2) {
                                        var y = height / 2 + Math.sin((x / width) * Math.PI * 6 + wavePhase) * 2.5;
                                        if (x === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                                    }
                                    ctx.stroke();
                                }
                                Component.onCompleted: { requestPaint(); }
                            }

                            // ── seal / stamp icon ─────────────────────────
                            Rectangle {
                                id: sealCircle
                                anchors.left: parent.left
                                anchors.bottom: parent.bottom
                                anchors.margins: 6
                                width: Qt.platform.os === "android" ? 30 : 24
                                height: width; radius: width / 2
                                color: "transparent"
                                border.color: langSettings.lang === "sw" ? "#00aa77" : "blue"; border.width: 2
                                opacity: 0.55

                                property real pulse: 1.0
                                SequentialAnimation on pulse {
                                    loops: Animation.Infinite; running: true
                                    NumberAnimation { to: 1.15; duration: 900; easing.type: Easing.SineCurve }
                                    NumberAnimation { to: 1.0;  duration: 900; easing.type: Easing.SineCurve }
                                }
                                scale: pulse

                                Text {
                                    anchors.centerIn: parent
                                    text: "🏛️"
                                    font.pointSize: Qt.platform.os === "android" ? 10 : 8
                                }
                            }

                            // ── Main content column ───────────────────────
                            Column {
                                id: scrollContentCol
                                anchors.top: waveSepCanvas.bottom
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.topMargin: 4
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                anchors.bottomMargin: 6
                                spacing: 0

                                // ── animated title Text with shimmer ─────
                                Item {
                                    width: parent.width
                                    height: Qt.platform.os === "android" ? 38 : 30
                                    clip: true

                                    // shimmer overlay
                                    Rectangle {
                                        id: shimmerRect
                                        width: parent.width * 0.35
                                        height: parent.height
                                        color: "transparent"
                                        opacity: 0.0

                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: "transparent" }
                                            GradientStop { position: 0.5; color: langSettings.lang === "sw" ? "#3300ffcc" : "#330000ff" }
                                            GradientStop { position: 1.0; color: "transparent" }
                                        }

                                        SequentialAnimation on x {
                                            loops: Animation.Infinite; running: true
                                            NumberAnimation {
                                                from: -shimmerRect.width
                                                to: parchmentBody.width
                                                duration: 2800
                                                easing.type: Easing.InOutSine
                                            }
                                            PauseAnimation { duration: 1800 }
                                        }
                                        SequentialAnimation on opacity {
                                            loops: Animation.Infinite; running: true
                                            PauseAnimation { duration: 400 }
                                            NumberAnimation { to: 1.0; duration: 300 }
                                            NumberAnimation { to: 0.0; duration: 300; easing.type: Easing.OutQuad }
                                            PauseAnimation { duration: 2600 }
                                        }
                                    }

                                    Text {
                                        id: scrollTitleText
                                        anchors.centerIn: parent
                                        text: langSettings.lang === "sw"
                                              ? "* Jifunze Zaidi Kuhusu Tanzania *"
                                              : "* Know More About Tanzania *"
                                        font.pointSize: Qt.platform.os === "android" ? 11 : 9
                                        font.bold: true
                                        color: langSettings.lang === "sw" ? "#00ffbb" : "blue"
                                        font.letterSpacing: 0.8

                                        property real glow: 0.0
                                        SequentialAnimation on glow {
                                            loops: Animation.Infinite; running: true
                                            NumberAnimation { to: 1.0; duration: 1200; easing.type: Easing.SineCurve }
                                            NumberAnimation { to: 0.0; duration: 1200; easing.type: Easing.SineCurve }
                                        }
                                        opacity: 0.75 + scrollTitleText.glow * 0.25
                                    }
                                }

                                // ── subtitle / flavour text ───────────────
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: langSettings.lang === "sw"
                                          ? "— Makala kamili · Historia · Utamaduni —"
                                          : "— Full article · History · Culture —"
                                    font.pointSize: Qt.platform.os === "android" ? 8 : 6
                                    color: langSettings.lang === "sw" ? "#4a9a80" : "blue"
                                    font.italic: true
                                }

                                // ── spacer ────────────────────────────────
                                Item { width: 1; height: Qt.platform.os === "android" ? 6 : 4 }

                                // ── CTA button ────────────────────────────
                                Rectangle {
                                    id: scrollCta
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: Math.min(parent.width - 12, Qt.platform.os === "android" ? 260 : 210)
                                    height: Qt.platform.os === "android" ? 44 : 36
                                    radius: Qt.platform.os === "android" ? 8 : 6
                                    clip: true
                                    color: scrollCtaMA.pressed ? (langSettings.lang === "sw" ? "#001a12" : "#00101a") : (langSettings.lang === "sw" ? "#000d09" : "#000d11")
                                    border.color: langSettings.lang === "sw" ? "#007a55" : "blue"
                                    border.width: Qt.platform.os === "android" ? 2 : 1

                                    Behavior on color { ColorAnimation { duration: 100 } }

                                    property real sc: 1.0
                                    scale: sc
                                    Behavior on sc { NumberAnimation { duration: 110; easing.type: Easing.OutBack } }

                                    // idle breathe
                                    SequentialAnimation on sc {
                                        id: ctaBreathe
                                        loops: Animation.Infinite; running: true
                                        NumberAnimation { to: 1.03; duration: 900; easing.type: Easing.SineCurve }
                                        NumberAnimation { to: 1.0;  duration: 900; easing.type: Easing.SineCurve }
                                    }

                                    // corner ornament top-left
                                    Text {
                                        anchors.top: parent.top; anchors.left: parent.left
                                        anchors.margins: 3
                                        text: "*"; font.pointSize: Qt.platform.os === "android" ? 7 : 5
                                        color: langSettings.lang === "sw" ? "#00aa77" : "blue"; opacity: 0.7
                                    }
                                    // corner ornament top-right
                                    Text {
                                        anchors.top: parent.top; anchors.right: parent.right
                                        anchors.margins: 3
                                        text: "*"; font.pointSize: Qt.platform.os === "android" ? 7 : 5
                                        color: langSettings.lang === "sw" ? "#00aa77" : "blue"; opacity: 0.7
                                    }

                                    // gold inner border highlight
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        color: "transparent"
                                        border.color: langSettings.lang === "sw" ? "#3000aa77" : "#3000003a"
                                        border.width: 1
                                        radius: parent.radius - 2
                                    }

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: Qt.platform.os === "android" ? 7 : 5

                                        Text {
                                            text: "📜"
                                            font.pointSize: Qt.platform.os === "android" ? 14 : 11
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            text: langSettings.lang === "sw"
                                                  ? "Soma Makala"
                                                  : "Read Article"
                                            font.bold: true
                                            font.pointSize: Qt.platform.os === "android" ? 13 : 10
                                            color: langSettings.lang === "sw" ? "#00ffbb" : "blue"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            id: ctaArrow
                                            text: "▶"
                                            font.pointSize: Qt.platform.os === "android" ? 9 : 7
                                            color: langSettings.lang === "sw" ? "#00aa77" : "blue"
                                            anchors.verticalCenter: parent.verticalCenter

                                            property real arrowX: 0
                                            SequentialAnimation on arrowX {
                                                loops: Animation.Infinite; running: true
                                                NumberAnimation { to: 4;  duration: 500; easing.type: Easing.InOutSine }
                                                NumberAnimation { to: 0;  duration: 500; easing.type: Easing.InOutSine }
                                            }
                                            transform: Translate { x: ctaArrow.arrowX }
                                        }
                                    }

                                    MouseArea {
                                        id: scrollCtaMA
                                        anchors.fill: parent
                                        onPressed: {
                                            ctaBreathe.running = false;
                                            scrollCta.sc = 0.93;
                                        }
                                        onReleased: {
                                            scrollCta.sc = 1.0;
                                            ctaBreathe.running = true;
                                            app.articleLang = langSettings.lang;
                                            app.articleViewVisible = true;
                                        }
                                        onCanceled: {
                                            scrollCta.sc = 1.0;
                                            ctaBreathe.running = true;
                                        }
                                    }
                                }
                            }
                        } // end parchmentBody
                    } // end articleBtnSection

                    //Spacing Rect
                    Rectangle{
                        color:"#001413"
                        width: parent.width
                        height: 16
                    }

                    // ══ WANYAMA COMIC STRIP — Scene A & B ════════════════
                    Rectangle {
                        id: comicStrip
                        width: app.width
                        color: "#000d08"
                        // Fixed height: image half-width + dialogue panel
                        height: comicHeader.height + comicSceneArea.height + 8

                        // ── state: which scene is showing ──────────────────
                        property int activeScene: 0   // 0 = A, 1 = B
                        property bool autoRunning: false
                        property int bubbleDelay: 8200  // ms kati ya bubble na nyingine
                        // ── bubble font sizes ──────────────────────
                        property int fsBubbleEmoji:  Qt.platform.os === "android" ? 11 : 9   // emoji ya mnyama
                        property int fsBubbleName:   Qt.platform.os === "android" ? 8  : 6   // jina la mnyama
                        property int fsBubbleAction: Qt.platform.os === "android" ? 12 : 10  // maandishi ya ()
                        property int fsBubbleMsg:    Qt.platform.os === "android" ? 12 : 9   // ujumbe mkuu

                        function startComicSequence() {
                            if (comicStrip.autoRunning) return;
                            comicStrip.autoRunning = true;
                            comicStrip.activeScene = 0;
                            // Reset both panels: A visible at 0, B hidden off-screen right
                            sceneAPanel.x = 0;
                            sceneAPanel.opacity = 1;
                            sceneBPanel.x = comicStrip.width;
                            sceneBPanel.opacity = 0;
                            sceneAPanel.resetAndPlay();
                            conclusionRect.opacity = 0;
                            sceneATimer.interval = 11 * comicStrip.bubbleDelay + 1000;
                            sceneATimer.start();
                        }

                        Component.onCompleted: {
                            Qt.callLater(function() { comicStrip.startComicSequence(); });
                        }

                        // After scene A finishes → transition to B
                        Timer {
                            id: sceneATimer
                            interval: 86000
                            repeat: false
                            onTriggered: {
                                transitionAnim.start();
                            }
                        }

                        // After scene B finishes → show conclusion, then restart
                        Timer {
                            id: sceneBTimer
                            interval: 61000
                            repeat: false
                            onTriggered: {
                                conclusionRect.opacity = 0;
                                conclusionFadeIn.start();
                                restartTimer.start();
                            }
                        }

                        Timer {
                            id: restartTimer
                            interval: 10000
                            repeat: false
                            onTriggered: {
                                conclusionRect.opacity = 0;
                                comicStrip.autoRunning = false;
                                comicStrip.startComicSequence();
                            }
                        }

                        // Slide transition: A slides left out, B slides in from right
                        SequentialAnimation {
                            id: transitionAnim
                            PauseAnimation { duration: 8000 } // pause kabla ya kubadilisha
                            // slide scene A out to the left
                            ParallelAnimation {
                                NumberAnimation { target: sceneAPanel; property: "x"; to: -comicStrip.width; duration: 420; easing.type: Easing.InCubic }
                                NumberAnimation { target: sceneAPanel; property: "opacity"; to: 0; duration: 420 }
                            }
                            ScriptAction { script: {
                                    comicStrip.activeScene = 1;
                                    sceneBPanel.x = comicStrip.width;
                                    sceneBPanel.opacity = 0;
                                    sceneBPanel.resetAndPlay();
                                    sceneTransitionLabel.opacity = 1;
                                } }
                            // slide scene B in from right
                            ParallelAnimation {
                                NumberAnimation { target: sceneBPanel; property: "x"; to: 0; duration: 420; easing.type: Easing.OutCubic }
                                NumberAnimation { target: sceneBPanel; property: "opacity"; to: 1; duration: 420 }
                                NumberAnimation { target: sceneTransitionLabel; property: "opacity"; to: 0; duration: 600 }
                            }
                            ScriptAction { script: {
                                    sceneAPanel.x = 0;
                                    sceneAPanel.opacity = 1;
                                    sceneBTimer.interval = 12 * comicStrip.bubbleDelay + 1000;
                                    sceneBTimer.start();
                                } }
                        }

                        // ── header ─────────────────────────────────────────
                        Rectangle {
                            id: comicHeader
                            width: parent.width
                            height: comicHeaderCol.height + 14
                            color: "#000d08"
                            anchors.top: parent.top

                            Column {
                                id: comicHeaderCol
                                anchors.top: parent.top; anchors.topMargin: 8
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 4

                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 8
                                    Text { text: "🦒🐘🦁🦓🐒🦦"; font.pointSize: Qt.platform.os === "android" ? 13 : 10 }
                                    Text {
                                        text: langSettings.lang === "sw" ? "Wanyama wa Tanzania" : "Tanzania Wildlife Comics"
                                        font.pointSize: Qt.platform.os === "android" ? 15 : 12
                                        font.bold: true; color: langSettings.lang === "sw" ? "green" : "blue"
                                        SequentialAnimation on opacity {
                                            loops: Animation.Infinite; running: true
                                            NumberAnimation { from: 1.0; to: 0.55; duration: 1400; easing.type: Easing.InOutSine }
                                            NumberAnimation { from: 0.55; to: 1.0; duration: 1400; easing.type: Easing.InOutSine }
                                        }
                                    }
                                    Text { text: "🦒🐘🦁🦓🐒🦦"; font.pointSize: Qt.platform.os === "android" ? 13 : 10 }
                                }

                                // scene indicator dots
                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 10
                                    Repeater {
                                        model: 2
                                        Rectangle {
                                            width: comicStrip.activeScene === index ? 22 : 8
                                            height: 8; radius: 4
                                            color: comicStrip.activeScene === index ? "#00ff88" : "#224433"
                                            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                                            Behavior on color { ColorAnimation { duration: 300 } }
                                        }
                                    }
                                }
                            }
                        }

                        // scene transition flash label
                        Text {
                            id: sceneTransitionLabel
                            anchors.centerIn: comicSceneArea
                            z: 20; opacity: 0
                            text: langSettings.lang === "sw" ? "Tukio B\n⇒" : "Scene B\n⇒"
                            font.pointSize: Qt.platform.os === "android" ? 22 : 18
                            font.bold: true; color: "#44ccff"
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // ── main scene area (clips both panels) ────────────
                        Item {
                            id: comicSceneArea
                            anchors.top: comicHeader.bottom
                            anchors.left: parent.left; anchors.right: parent.right
                            // height = image (square-ish) + dialogue strip
                            height: sceneAPanel.height
                            clip: true

                            // ══ SCENE A PANEL ═══════════════════════════════
                            Item {
                                id: sceneAPanel
                                width: comicStrip.width
                                height: sceneAContent.height
                                x: 0

                                property int playTick: 0
                                function resetAndPlay() {
                                    playTick = (playTick + 1) % 9999;
                                }

                                Column {
                                    id: sceneAContent
                                    width: parent.width
                                    spacing: 0

                                    // scene label
                                    Rectangle {
                                        width: parent.width; height: sceneLabelARow.height + 12
                                        color: "#003333"
                                        border.color: "cyan"; border.width: 1
                                        Row {
                                            id: sceneLabelARow
                                            anchors.left: parent.left; anchors.leftMargin: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            spacing: 8
                                            Text { text: "🎬"; font.pointSize: Qt.platform.os === "android" ? 14 : 11; anchors.verticalCenter: parent.verticalCenter }
                                            Text {
                                                text: langSettings.lang === "sw" ? "Tukio A — \"Operesheni: Bendera Juu!\"" : "Scene A — \"Operation: Flag Up!\""
                                                font.pointSize: Qt.platform.os === "android" ? 12 : 9; font.bold: true; color: langSettings.lang === "sw" ? "green" : "blue"
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }

                                    // stage direction
                                    Rectangle {
                                        width: parent.width; height: stageDirA.height + 14
                                        color: "#003333"
                                        border.color: "cyan"; border.width: 1
                                        Row {
                                            anchors.left: parent.left; anchors.leftMargin: 8
                                            anchors.top: parent.top; anchors.topMargin: 7
                                            anchors.right: parent.right; anchors.rightMargin: 8
                                            spacing: 5
                                            Text { text: "🎬"; font.pointSize: Qt.platform.os === "android" ? 11 : 8 }
                                            Text {
                                                id: stageDirA; width: parent.width - 28
                                                wrapMode: Text.WordWrap; font.italic: true
                                                font.pointSize: Qt.platform.os === "android" ? 10 : 8
                                                color: "#1fb8ba"
                                                text: langSettings.lang === "sw"
                                                      ? "Mvua inaanza kunyesha. Twiga anashika bendera ya Tanzania juu ya ngazi, nyani anashika ramani kichwa chini, simba amevaa kofia anasimama juu ya tembo, na vikaragosi wanajificha chini ya hema ndogo iliyofurika maji."
                                                      : "Rain begins. Giraffe holds the Tanzania flag atop a ladder, the monkey holds a map upside down, a lion in a hat stands on the elephant, and the meerkats hide under a tiny flooded tent."
                                            }
                                        }
                                    }

                                    // ── image LEFT + dialogue RIGHT ──────────
                                    Row {
                                        width: parent.width
                                        spacing: 0

                                        // scene A image
                                        Rectangle {
                                            width: parent.width * 0.48
                                            height: scImgA.height
                                            color: "transparent"; clip: true
                                            Image {
                                                id: scImgA
                                                source: "./wanyama-tz-3.png"
                                                width: parent.width
                                                height: implicitHeight > 0 ? width * implicitHeight / implicitWidth : width
                                                fillMode: Image.PreserveAspectFit; smooth: true
                                            }

                                        }


                                        Rectangle {
                                            width: parent.width * 0.52
                                            height: scImgA.height
                                            color: "#00100a"
                                            clip: true

                                            Item {
                                                id: dlgListA
                                                anchors.fill: parent

                                                Column {
                                                    anchors.top: parent.top
                                                    anchors.left: parent.left
                                                    anchors.right: parent.right
                                                    spacing: 4

                                                    Item {
                                                        id: ab0Root
                                                        width: parent.width
                                                        z: 1
                                                        height: opacity > 0 ? ab0ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: -20
                                                        Connections {
                                                            target: sceneAPanel
                                                            function onPlayTickChanged() { ab0Root.opacity = 0; ab0Root.height = 0; ab0Root.y = -20; ab0T.restart(); }
                                                        }
                                                        Timer { id: ab0T; interval: 0 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { ab0OpA.start(); ab0YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: ab0OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: ab0YA;   running: false; from: -20; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: ab0ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: ab0ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#fff8ec"
                                                                border.color: "#00cc77"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: ab0ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🐘"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "TEMBO" : "ELEPHANT"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#22ddaa" : "#00aaff"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "(akitikisa kwa hasira)" : "(shaking furiously)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: ab0Col
                                                                    width: ab0ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Simba! Wewe ni mzito sana! Miguu yangu inaingia ardhini!" : "Simba! You are too heavy! My feet are sinking!"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: ab2Root
                                                        width: parent.width
                                                        z: 3
                                                        height: opacity > 0 ? ab2ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: -20
                                                        Connections {
                                                            target: sceneAPanel
                                                            function onPlayTickChanged() { ab2Root.opacity = 0; ab2Root.height = 0; ab2Root.y = -20; ab2T.restart(); }
                                                        }
                                                        Timer { id: ab2T; interval: 2 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { ab0Root.opacity = 0; ab0Root.height = 0; ab2OpA.start(); ab2YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: ab2OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: ab2YA;   running: false; from: -20; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: ab2ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: ab2ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#fff8ec"
                                                                border.color: "#00cc77"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: ab2ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🐘"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "TEMBO" : "ELEPHANT"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#22ddaa" : "#00aaff"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    id: ab2Col
                                                                    width: ab2ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Kamanda wangu mguu! Toka juu yangu au nitakupeleka ziwani!" : "My commander's foot! Get off me or I'm sending you to the lake!"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: ab4Root
                                                        width: parent.width
                                                        z: 5
                                                        height: opacity > 0 ? ab4ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: -20
                                                        Connections {
                                                            target: sceneAPanel
                                                            function onPlayTickChanged() { ab4Root.opacity = 0; ab4Root.height = 0; ab4Root.y = -20; ab4T.restart(); }
                                                        }
                                                        Timer { id: ab4T; interval: 4 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { ab2Root.opacity = 0; ab2Root.height = 0; ab4OpA.start(); ab4YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: ab4OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: ab4YA;   running: false; from: -20; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: ab4ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: ab4ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#f8eeff"
                                                                border.color: "#aa44cc"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: ab4ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🐒"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "NYANI" : "MONKEY"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#cc66ff" : "#8822cc"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "(akiangalia ramani kichwa chini)" : "(reading map upside down)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: ab4Col
                                                                    width: ab4ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Kaskazini... au... ngoja... labda ramani iko chini chini?" : "North... or... wait... maybe the map is upside down?"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: ab6Root
                                                        width: parent.width
                                                        z: 7
                                                        height: opacity > 0 ? ab6ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: -20
                                                        Connections {
                                                            target: sceneAPanel
                                                            function onPlayTickChanged() { ab6Root.opacity = 0; ab6Root.height = 0; ab6Root.y = -20; ab6T.restart(); }
                                                        }
                                                        Timer { id: ab6T; interval: 6 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { ab4Root.opacity = 0; ab4Root.height = 0; ab6OpA.start(); ab6YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: ab6OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: ab6YA;   running: false; from: -20; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: ab6ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: ab6ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#f8eeff"
                                                                border.color: "#aa44cc"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: ab6ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🐒"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "NYANI" : "MONKEY"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#cc66ff" : "#8822cc"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    id: ab6Col
                                                                    width: ab6ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Sawa sawa! Kaskazini ni... ule mwelekeo ambapo mvua inakuja!" : "Okay okay! North is... where the rain is coming from!"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: ab8Root
                                                        width: parent.width
                                                        z: 9
                                                        height: opacity > 0 ? ab8ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: -20
                                                        Connections {
                                                            target: sceneAPanel
                                                            function onPlayTickChanged() { ab8Root.opacity = 0; ab8Root.height = 0; ab8Root.y = -20; ab8T.restart(); }
                                                        }
                                                        Timer { id: ab8T; interval: 8 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { ab6Root.opacity = 0; ab6Root.height = 0; ab8OpA.start(); ab8YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: ab8OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: ab8YA;   running: false; from: -20; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: ab8ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: ab8ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#eafaf5"
                                                                border.color: "#449988"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: ab8ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🦓"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "PUNDAMILIA" : "ZEBRA"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#55bbaa" : "#2288aa"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "(akisimama pembeni)" : "(standing aside)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: ab8Col
                                                                    width: ab8ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Weka bendera tu, usitufanye tuko kwenye muvi!" : "Just put the flag up; stop making it a movie!"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: ab10Root
                                                        width: parent.width
                                                        z: 11
                                                        height: opacity > 0 ? ab10ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: -20
                                                        Connections {
                                                            target: sceneAPanel
                                                            function onPlayTickChanged() { ab10Root.opacity = 0; ab10Root.height = 0; ab10Root.y = -20; ab10T.restart(); }
                                                        }
                                                        Timer { id: ab10T; interval: 10 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { ab8Root.opacity = 0; ab8Root.height = 0; ab10OpA.start(); ab10YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: ab10OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: ab10YA;   running: false; from: -20; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: ab10ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: ab10ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#fffde8"
                                                                border.color: "#ffaa00"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: ab10ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🦁"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "SIMBA" : "LION"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#ffcc00" : "#ff7700"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "😂 (akiwa anacheka)" : "😂 (while laughing)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: ab10Col
                                                                    width: ab10ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Nyie vikaragosi, acheni kuvuluga  operesheni kwa miziki yenu!" : "You meerkats, stop disrupting the operation with your music!"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                }

                                                Column {
                                                    anchors.top: parent.verticalCenter
                                                    anchors.left: parent.left
                                                    anchors.right: parent.right
                                                    spacing: 4

                                                    Item {
                                                        id: ab1Root
                                                        width: parent.width
                                                        z: 13
                                                        height: opacity > 0 ? ab1ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: 22
                                                        Connections {
                                                            target: sceneAPanel
                                                            function onPlayTickChanged() { ab1Root.opacity = 0; ab1Root.height = 0; ab1Root.y = 22; ab1T.restart(); }
                                                        }
                                                        Timer { id: ab1T; interval: 1 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { ab1OpA.start(); ab1YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: ab1OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: ab1YA;   running: false; from: 22; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: ab1ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: ab1ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#fffde8"
                                                                border.color: "#ffaa00"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: ab1ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🦁"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "SIMBA" : "LION"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#ffcc00" : "#ff7700"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "(akiangalia ramani kwa kiburi)" : "(studying the map proudly)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: ab1Col
                                                                    width: ab1ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Kimya, hii ni operesheni nyeti. Mimi ni kamanda. Kamanda hawashuki." : "Silence — sensitive operation. I am the commander. Commanders don't get down."
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: ab3Root
                                                        width: parent.width
                                                        z: 15
                                                        height: opacity > 0 ? ab3ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: 22
                                                        Connections {
                                                            target: sceneAPanel
                                                            function onPlayTickChanged() { ab3Root.opacity = 0; ab3Root.height = 0; ab3Root.y = 22; ab3T.restart(); }
                                                        }
                                                        Timer { id: ab3T; interval: 3 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { ab1Root.opacity = 0; ab1Root.height = 0; ab3OpA.start(); ab3YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: ab3OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: ab3YA;   running: false; from: 22; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: ab3ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: ab3ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#fff4e8"
                                                                border.color: "#ff6600"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: ab3ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🦒"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "TWIGA" : "GIRAFFE"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#ffaa33" : "#ff4400"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "(juu ya ngazi, akitetemeka)" : "(atop the ladder, trembling)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: ab3Col
                                                                    width: ab3ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "N-nyani! Bendera inaenda upande gani?!" : "M-monkey! Which direction does the flag go?!"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: ab5Root
                                                        width: parent.width
                                                        z: 17
                                                        height: opacity > 0 ? ab5ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: 22
                                                        Connections {
                                                            target: sceneAPanel
                                                            function onPlayTickChanged() { ab5Root.opacity = 0; ab5Root.height = 0; ab5Root.y = 22; ab5T.restart(); }
                                                        }
                                                        Timer { id: ab5T; interval: 5 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { ab3Root.opacity = 0; ab3Root.height = 0; ab5OpA.start(); ab5YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: ab5OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: ab5YA;   running: false; from: 22; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: ab5ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: ab5ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#fff4e8"
                                                                border.color: "#ff6600"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: ab5ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🦒"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "TWIGA" : "GIRAFFE"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#ffaa33" : "#ff4400"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    id: ab5Col
                                                                    width: ab5ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "NYANI!" : "MONKEY!"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: ab7Root
                                                        width: parent.width
                                                        z: 20
                                                        height: opacity > 0 ? ab7ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: 22
                                                        Connections {
                                                            target: sceneAPanel
                                                            function onPlayTickChanged() { ab7Root.opacity = 0; ab7Root.height = 0; ab7Root.y = 22; ab7T.restart(); }
                                                        }
                                                        Timer { id: ab7T; interval: 7 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { ab5Root.opacity = 0; ab5Root.height = 0; ab7OpA.start(); ab7YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: ab7OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: ab7YA;   running: false; from: 22; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: ab7ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: ab7ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#fff4e8"
                                                                border.color: "#ff6600"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: ab7ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🦒"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "TWIGA" : "GIRAFFE"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#ffaa33" : "#ff4400"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    id: ab7Col
                                                                    width: ab7ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Mvua inakuja KILA UPANDE!" : "Rain is coming from EVERY DIRECTION!"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: ab9Root
                                                        width: parent.width
                                                        z: 22
                                                        height: opacity > 0 ? ab9ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: 22
                                                        Connections {
                                                            target: sceneAPanel
                                                            function onPlayTickChanged() { ab9Root.opacity = 0; ab9Root.height = 0; ab9Root.y = 22; ab9T.restart(); }
                                                        }
                                                        Timer { id: ab9T; interval: 9 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { ab7Root.opacity = 0; ab7Root.height = 0; ab9OpA.start(); ab9YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: ab9OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: ab9YA;   running: false; from: 22; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: ab9ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: ab9ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#fff0f0"
                                                                border.color: "#cc2244"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: ab9ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🦦"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "VIKARAGOSI" : "MEERKATS"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#ff4466" : "#cc0033"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "(wakiwa wanaimba ndani ya hema)" : "(singing inside the tent)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: ab9Col
                                                                    width: ab9ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Twiga panda juu ya ngazi, weka bendera , chezea juu kwa juu! 🎵" : "Giraffe, climb up there, plant the flag, and dance on top! 🎵"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: ab11Root
                                                        width: parent.width
                                                        z: 24
                                                        height: opacity > 0 ? ab11ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: 22
                                                        Connections {
                                                            target: sceneAPanel
                                                            function onPlayTickChanged() { ab11Root.opacity = 0; ab11Root.height = 0; ab11Root.y = 22; ab11T.restart(); }
                                                        }
                                                        Timer { id: ab11T; interval: 11 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { ab9Root.opacity = 0; ab9Root.height = 0; ab11OpA.start(); ab11YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: ab11OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: ab11YA;   running: false; from: 22; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: ab11ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: ab11ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#fff0f0"
                                                                border.color: "#cc2244"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: ab11ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🦦"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "VIKARAGOSI" : "MEERKATS"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#ff4466" : "#cc0033"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "😂 (wakiwa wanacheka)" : "😂 (while laughing)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: ab11Col
                                                                    width: ab11ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "OPERESHENI?! TWIGA, CHEZEA JUU KWA JUU, JUU YA NGAZI!😂 " : "OPERATION?! GIRAFFE, DANCE ON TOP, ON TOP OF THE LADDER!😂"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                }

                                            }
                                        }
                                    }
                                }
                            } // end sceneAPanel

                            // ══ SCENE B PANEL ═══════════════════════════════
                            Item {
                                id: sceneBPanel
                                width: comicStrip.width
                                height: sceneAPanel.height
                                x: comicStrip.width

                                property int playTick: 0
                                function resetAndPlay() {
                                    playTick = (playTick + 1) % 9999;
                                }

                                Column {
                                    id: sceneBContent
                                    width: parent.width
                                    spacing: 0

                                    // scene label
                                    Rectangle {
                                        width: parent.width; height: sceneLabelBRow.height + 12
                                        color: "#003333"
                                        border.color: "cyan"; border.width: 1
                                        Row {
                                            id: sceneLabelBRow
                                            anchors.left: parent.left; anchors.leftMargin: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 8
                                            Text { text: "🎬"; font.pointSize: Qt.platform.os === "android" ? 14 : 11; anchors.verticalCenter: parent.verticalCenter }
                                            Text {
                                                text: langSettings.lang === "sw" ? "Tukio B — \"Wageni Wanafika!\"" : "Scene B — \"The Visitors Arrive!\""
                                                font.pointSize: Qt.platform.os === "android" ? 12 : 9; font.bold: true; color: langSettings.lang === "sw" ? "green" : "blue"
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }

                                    // stage direction
                                    Rectangle {
                                        width: parent.width; height: stageDirB.height + 14
                                        color: "#003333"
                                        border.color: "cyan"; border.width: 1
                                        Row {
                                            anchors.left: parent.left; anchors.leftMargin: 8
                                            anchors.top: parent.top; anchors.topMargin: 7
                                            anchors.right: parent.right; anchors.rightMargin: 8
                                            spacing: 5
                                            Text { text: "🎬"; font.pointSize: Qt.platform.os === "android" ? 11 : 8 }
                                            Text {
                                                id: stageDirB; width: parent.width - 28
                                                wrapMode: Text.WordWrap; font.italic: true
                                                font.pointSize: Qt.platform.os === "android" ? 10 : 8
                                                color: "#1fb8ba"
                                                text: langSettings.lang === "sw"
                                                      ? "Mvua imekwisha. Wapigapicha wanafika — watalii na watoto wa shule. Simba analala chini ya hema, tembo anasimama kwa heshima, twiga anajifanya hajui ngazi ilipotoka, na vikaragosi wanakaa juu ya mti wapole."
                                                      : "Rain has stopped. Photographers arrive — tourists and schoolchildren. The lion sleeps under the tent, the elephant stands tall, the giraffe pretends to know nothing about the ladder, and the meerkats sit calmly in the tree."
                                            }
                                        }
                                    }

                                    // ── image LEFT + dialogue RIGHT ──────────
                                    Row {
                                        width: parent.width
                                        spacing: 0

                                        // scene B image
                                        Rectangle {
                                            width: parent.width * 0.48
                                            height: scImgB.height
                                            color: "transparent"; clip: true
                                            Image {
                                                id: scImgB
                                                source: "./wanyama-tz-3-b.png"
                                                width: parent.width
                                                height: implicitHeight > 0 ? width * implicitHeight / implicitWidth : width
                                                fillMode: Image.PreserveAspectFit; smooth: true
                                            }

                                        }


                                        Rectangle {
                                            width: parent.width * 0.52
                                            height: scImgB.height
                                            color: "#00100a"
                                            clip: true

                                            Item {
                                                id: dlgListB
                                                anchors.fill: parent

                                                Column {
                                                    anchors.top: parent.top
                                                    anchors.left: parent.left
                                                    anchors.right: parent.right
                                                    spacing: 4

                                                    Item {
                                                        id: bb0Root
                                                        width: parent.width
                                                        z: 1
                                                        height: opacity > 0 ? bb0ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: -20
                                                        Connections {
                                                            target: sceneBPanel
                                                            function onPlayTickChanged() { bb0Root.opacity = 0; bb0Root.height = 0; bb0Root.y = -20; bb0T.restart(); }
                                                        }
                                                        Timer { id: bb0T; interval: 0 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { bb0OpA.start(); bb0YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: bb0OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: bb0YA;   running: false; from: -20; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: bb0ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: bb0ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#e8f4ff"
                                                                border.color: "#0077cc"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: bb0ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "📷"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "MPIGAPICHA #1" : "PHOTOGRAPHER #1"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: "#0077cc"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "(akipiga picha kwa furaha)" : "(snapping photos excitedly)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: bb0Col
                                                                    width: bb0ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Jamani! Tazama simba analala NDANI YA HEMA! Yeye ni mzuri sana!" : "OH MY GOD! Look at the lion sleeping INSIDE A TENT! How adorable!"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: bb2Root
                                                        width: parent.width
                                                        z: 3
                                                        height: opacity > 0 ? bb2ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: -20
                                                        Connections {
                                                            target: sceneBPanel
                                                            function onPlayTickChanged() { bb2Root.opacity = 0; bb2Root.height = 0; bb2Root.y = -20; bb2T.restart(); }
                                                        }
                                                        Timer { id: bb2T; interval: 2 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { bb0Root.opacity = 0; bb0Root.height = 0; bb2OpA.start(); bb2YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: bb2OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: bb2YA;   running: false; from: -20; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: bb2ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: bb2ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#e8f4ff"
                                                                border.color: "#0077cc"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: bb2ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "📷"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "MPIGAPICHA #2" : "PHOTOGRAPHER #2"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: "#0077cc"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    id: bb2Col
                                                                    width: bb2ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Na twiga yule — anaangalia nini?" : "And that giraffe — what is it looking at?"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: bb4Root
                                                        width: parent.width
                                                        z: 5
                                                        height: opacity > 0 ? bb4ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: -20
                                                        Connections {
                                                            target: sceneBPanel
                                                            function onPlayTickChanged() { bb4Root.opacity = 0; bb4Root.height = 0; bb4Root.y = -20; bb4T.restart(); }
                                                        }
                                                        Timer { id: bb4T; interval: 4 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { bb2Root.opacity = 0; bb2Root.height = 0; bb4OpA.start(); bb4YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: bb4OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: bb4YA;   running: false; from: -20; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: bb4ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: bb4ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#e0f0ff"
                                                                border.color: "#3399cc"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: bb4ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "👦"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "MTOTO WA SHULE" : "SCHOOLCHILD"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: "#3399cc"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "(akionyesha nyuma ya mti)" : "(pointing behind the tree)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: bb4Col
                                                                    width: bb4ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Dada, ile ngazi inatoka wapi?" : "Sister, where did that ladder come from?"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: bb6Root
                                                        width: parent.width
                                                        z: 7
                                                        height: opacity > 0 ? bb6ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: -20
                                                        Connections {
                                                            target: sceneBPanel
                                                            function onPlayTickChanged() { bb6Root.opacity = 0; bb6Root.height = 0; bb6Root.y = -20; bb6T.restart(); }
                                                        }
                                                        Timer { id: bb6T; interval: 6 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { bb4Root.opacity = 0; bb4Root.height = 0; bb6OpA.start(); bb6YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: bb6OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: bb6YA;   running: false; from: -20; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: bb6ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: bb6ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#e0f0ff"
                                                                border.color: "#3399cc"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: bb6ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "👦"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "MTOTO WA SHULE" : "SCHOOLCHILD"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: "#3399cc"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    id: bb6Col
                                                                    width: bb6ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Nina miaka saba tu—" : "I'm only seven years old—"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: bb8Root
                                                        width: parent.width
                                                        z: 9
                                                        height: opacity > 0 ? bb8ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: -20
                                                        Connections {
                                                            target: sceneBPanel
                                                            function onPlayTickChanged() { bb8Root.opacity = 0; bb8Root.height = 0; bb8Root.y = -20; bb8T.restart(); }
                                                        }
                                                        Timer { id: bb8T; interval: 8 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { bb6Root.opacity = 0; bb6Root.height = 0; bb8OpA.start(); bb8YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: bb8OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: bb8YA;   running: false; from: -20; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: bb8ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: bb8ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#fff8ec"
                                                                border.color: "#00cc77"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: bb8ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🐘"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "TEMBO" : "ELEPHANT"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#22ddaa" : "#00aaff"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "(kwa upole kwa watalii)" : "(gently addressing the tourists)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: bb8Col
                                                                    width: bb8ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Karibuni Tanzania. Kila kitu hapa ni... cha kawaida kabisa." : "Welcome to Tanzania. Everything here is... completely normal."
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: bb10Root
                                                        width: parent.width
                                                        z: 11
                                                        height: opacity > 0 ? bb10ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: -20
                                                        Connections {
                                                            target: sceneBPanel
                                                            function onPlayTickChanged() { bb10Root.opacity = 0; bb10Root.height = 0; bb10Root.y = -20; bb10T.restart(); }
                                                        }
                                                        Timer { id: bb10T; interval: 10 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { bb8Root.opacity = 0; bb8Root.height = 0; bb10OpA.start(); bb10YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: bb10OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: bb10YA;   running: false; from: -20; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: bb10ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: bb10ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#fff8ec"
                                                                border.color: "#00cc77"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: bb10ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🐘"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "TEMBO" : "ELEPHANT"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#22ddaa" : "#00aaff"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "(kwa lile jicho moja la nyuma, kwa Simba)" : "(one eye back, to Simba)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: bb10Col
                                                                    width: bb10ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "...Simba, amka. Wageni wako." : "...Simba, wake up. You have visitors."
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: bb12Root
                                                        width: parent.width
                                                        z: 13
                                                        height: opacity > 0 ? bb12ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: -20
                                                        Connections {
                                                            target: sceneBPanel
                                                            function onPlayTickChanged() { bb12Root.opacity = 0; bb12Root.height = 0; bb12Root.y = -20; bb12T.restart(); }
                                                        }
                                                        Timer { id: bb12T; interval: 12 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { bb10Root.opacity = 0; bb10Root.height = 0; bb12OpA.start(); bb12YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: bb12OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: bb12YA;   running: false; from: -20; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: bb12ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: bb12ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#fff8ec"
                                                                border.color: "#00cc77"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: bb12ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🐘"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "TEMBO" : "ELEPHANT"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#22ddaa" : "#00aaff"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    id: bb12Col
                                                                    width: bb12ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "😑" : "😑"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                }

                                                Column {
                                                    anchors.top: parent.verticalCenter
                                                    anchors.left: parent.left
                                                    anchors.right: parent.right
                                                    spacing: 4

                                                    Item {
                                                        id: bb1Root
                                                        width: parent.width
                                                        z: 15
                                                        height: opacity > 0 ? bb1ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: 22
                                                        Connections {
                                                            target: sceneBPanel
                                                            function onPlayTickChanged() { bb1Root.opacity = 0; bb1Root.height = 0; bb1Root.y = 22; bb1T.restart(); }
                                                        }
                                                        Timer { id: bb1T; interval: 1 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { bb1OpA.start(); bb1YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: bb1OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: bb1YA;   running: false; from: 22; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: bb1ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: bb1ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#fffde8"
                                                                border.color: "#ffaa00"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: bb1ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🦁"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "SIMBA" : "LION"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#ffcc00" : "#ff7700"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "(akifungua jicho moja)" : "(opening one eye)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: bb1Col
                                                                    width: bb1ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "...mzuri. Ndiyo. Hiyo ndiyo neno sahihi." : "...adorable. Yes. That is exactly the right word."
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: bb3Root
                                                        width: parent.width
                                                        z: 17
                                                        height: opacity > 0 ? bb3ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: 22
                                                        Connections {
                                                            target: sceneBPanel
                                                            function onPlayTickChanged() { bb3Root.opacity = 0; bb3Root.height = 0; bb3Root.y = 22; bb3T.restart(); }
                                                        }
                                                        Timer { id: bb3T; interval: 3 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { bb1Root.opacity = 0; bb1Root.height = 0; bb3OpA.start(); bb3YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: bb3OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: bb3YA;   running: false; from: 22; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: bb3ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: bb3ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#fff4e8"
                                                                border.color: "#ff6600"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: bb3ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🦒"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "TWIGA" : "GIRAFFE"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#ffaa33" : "#ff4400"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "(akiangalia mbinguni kwa utulivu)" : "(gazing at the sky peacefully)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: bb3Col
                                                                    width: bb3ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Nyota. Ni hobby yangu." : "Stars. It's my hobby."
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: bb5Root
                                                        width: parent.width
                                                        z: 20
                                                        height: opacity > 0 ? bb5ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: 22
                                                        Connections {
                                                            target: sceneBPanel
                                                            function onPlayTickChanged() { bb5Root.opacity = 0; bb5Root.height = 0; bb5Root.y = 22; bb5T.restart(); }
                                                        }
                                                        Timer { id: bb5T; interval: 5 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { bb3Root.opacity = 0; bb3Root.height = 0; bb5OpA.start(); bb5YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: bb5OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: bb5YA;   running: false; from: 22; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: bb5ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: bb5ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#f8eeff"
                                                                border.color: "#aa44cc"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: bb5ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🦦"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "KIKARAGOSI" : "MEERKAT"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#cc66ff" : "#8822cc"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "(haraka sana)" : "(very quickly)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: bb5Col
                                                                    width: bb5ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Ngazi? Gani ngazi? Mimi naona mti tu. Wewe unaona ngazi? Labda unahitaji miwani." : "Ladder? What ladder? I only see a tree. You see a ladder? Maybe you need glasses."
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: bb7Root
                                                        width: parent.width
                                                        z: 22
                                                        height: opacity > 0 ? bb7ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: 22
                                                        Connections {
                                                            target: sceneBPanel
                                                            function onPlayTickChanged() { bb7Root.opacity = 0; bb7Root.height = 0; bb7Root.y = 22; bb7T.restart(); }
                                                        }
                                                        Timer { id: bb7T; interval: 7 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { bb5Root.opacity = 0; bb5Root.height = 0; bb7OpA.start(); bb7YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: bb7OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: bb7YA;   running: false; from: 22; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: bb7ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: bb7ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#f8eeff"
                                                                border.color: "#aa44cc"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: bb7ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🦦"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "KIKARAGOSI" : "MEERKAT"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#cc66ff" : "#8822cc"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    id: bb7Col
                                                                    width: bb7ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Miwani ndogo basi." : "Small glasses then."
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: bb9Root
                                                        width: parent.width
                                                        z: 24
                                                        height: opacity > 0 ? bb9ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: 22
                                                        Connections {
                                                            target: sceneBPanel
                                                            function onPlayTickChanged() { bb9Root.opacity = 0; bb9Root.height = 0; bb9Root.y = 22; bb9T.restart(); }
                                                        }
                                                        Timer { id: bb9T; interval: 9 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { bb7Root.opacity = 0; bb7Root.height = 0; bb9OpA.start(); bb9YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: bb9OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: bb9YA;   running: false; from: 22; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: bb9ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: bb9ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#e8f4ff"
                                                                border.color: "#0077cc"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: bb9ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "📷"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "MPIGAPICHA #3" : "PHOTOGRAPHER #3"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: "#0077cc"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    id: bb9Col
                                                                    width: bb9ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Hii ni nzuri sana! Naomba picha pamoja!" : "This is so beautiful! Can we take a photo together!"
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Item {
                                                        id: bb11Root
                                                        width: parent.width
                                                        z: 26
                                                        height: opacity > 0 ? bb11ColWrap.height + 2 : 0
                                                        opacity: 0
                                                        y: 22
                                                        Connections {
                                                            target: sceneBPanel
                                                            function onPlayTickChanged() { bb11Root.opacity = 0; bb11Root.height = 0; bb11Root.y = 22; bb11T.restart(); }
                                                        }
                                                        Timer { id: bb11T; interval: 11 * comicStrip.bubbleDelay + 200; repeat: false
                                                            onTriggered: { bb9Root.opacity = 0; bb9Root.height = 0; bb11OpA.start(); bb11YA.start(); }
                                                        }
                                                        NumberAnimation on opacity { id: bb11OpA; running: false; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
                                                        NumberAnimation on y      { id: bb11YA;   running: false; from: 22; to: 0;  duration: 320; easing.type: Easing.OutCubic }
                                                        Item {
                                                            id: bb11ColWrap
                                                            anchors.left: parent.left; anchors.leftMargin: 4
                                                            width: parent.width - 8
                                                            height: bb11ColInner.height + 14
                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: 12
                                                                color: "#fffde8"
                                                                border.color: "#ffaa00"; border.width: 1.5
                                                            }
                                                            Column {
                                                                id: bb11ColInner
                                                                anchors.top: parent.top; anchors.topMargin: 7
                                                                anchors.left: parent.left; anchors.right: parent.right
                                                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                                                spacing: 2
                                                                Row {
                                                                    spacing: 4
                                                                    Text { text: "🦁"; font.pointSize: comicStrip.fsBubbleEmoji }
                                                                    Text {
                                                                        text: langSettings.lang === "sw" ? "SIMBA" : "LION"
                                                                        font.bold: true
                                                                        font.pointSize: comicStrip.fsBubbleName
                                                                        color: langSettings.lang === "sw" ? "#ffcc00" : "#ff7700"
                                                                        anchors.verticalCenter: parent.verticalCenter
                                                                    }
                                                                }
                                                                Text {
                                                                    width: parent.width
                                                                    text: langSettings.lang === "sw" ? "(bila kusogea hata kidogo)" : "(without moving at all)"
                                                                    font.italic: true
                                                                    font.pointSize: comicStrip.fsBubbleAction
                                                                    color: "#888888"; wrapMode: Text.WordWrap
                                                                }
                                                                Text {
                                                                    id: bb11Col
                                                                    width: bb11ColWrap.width - 20
                                                                    text: langSettings.lang === "sw" ? "Mimi ni Kivutio. Siongei na wageni." : "I am an exhibit. I don't speak to visitors."
                                                                    font.pointSize: comicStrip.fsBubbleMsg
                                                                    font.bold: false
                                                                    color: "#111111"; wrapMode: Text.WordWrap
                                                                }
                                                            }
                                                        }
                                                    }

                                                }

                                            }
                                        }
                                    }
                                }
                            } // end sceneBPanel

                        } // end comicSceneArea

                        // ── conclusion + credits (fades in after scene B) ──
                        Rectangle {
                            id: conclusionRect
                            opacity: 0
                            anchors.bottom: comicSceneArea.bottom
                            anchors.left: parent.left; anchors.right: parent.right
                            height: conclusionCol.height + 28
                            radius: 0
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 0.25; color: "#ee000d08" }
                                GradientStop { position: 1.0; color: "#ff000d08" }
                            }
                            NumberAnimation on opacity { id: conclusionFadeIn; running: false; from: 0; to: 1; duration: 900; easing.type: Easing.OutCubic }

                            Column {
                                id: conclusionCol
                                anchors.bottom: parent.bottom; anchors.bottomMargin: 14
                                anchors.left: parent.left; anchors.right: parent.right
                                anchors.leftMargin: 14; anchors.rightMargin: 14
                                spacing: 8

                                // ── tagline ─────────────────────────────────
                                Text {
                                    id: conclusionText
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap; font.bold: true
                                    font.pointSize: Qt.platform.os === "android" ? 14 : 12
                                    color: langSettings.lang === "sw" ? "#00ff88" : "#44ddff"
                                    text: langSettings.lang === "sw"
                                          ? "🌍 \"Tanzania: Hata wanyama wana drama zao!\" 🦒🐘🦁"
                                          : "🌍 \"Tanzania: Even the animals have their own drama!\" 🦒🐘🦁"
                                }

                                // ── divider ─────────────────────────────────
                                Rectangle {
                                    width: parent.width * 0.6
                                    height: 1
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: "#224433"
                                }

                                // ── credits ─────────────────────────────────
                                Column {
                                    width: parent.width
                                    spacing: 3

                                    Text {
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                        text: langSettings.lang === "sw" ? "✍️ Imeandikwa na" : "✍️ Written by"
                                        font.pointSize: Qt.platform.os === "android" ? 12 : 10
                                        color: "#556655"
                                    }

                                    Rectangle{
                                        width: emImg.width + emText.width + emText.anchors.leftMargin
                                        height: emImg.height
                                        color: "transparent"
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        Image {
                                            id:emImg
                                            height: 80
                                            width: height
                                            anchors.top: parent.top
                                            anchors.left: parent.left
                                            anchors.verticalCenter: parent.verticalCenter
                                            source: "./EM.jpg"
                                            fillMode: Image.PreserveAspectFit
                                        }

                                        Text {
                                            id: emText
                                            anchors.left: emImg.right
                                            anchors.leftMargin: 4
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: "Edwin Magabe Ngosso"
                                            font.pointSize: Qt.platform.os === "android" ? 14 : 12
                                            font.bold: true
                                            color: "#88cc99"
                                        }
                                    }

                                }
                            }
                        }

                    } // end comicStrip


                    // ══ ATTRACTION OF THE DAY ══════════════════════════════
                    Rectangle {
                        id: aotdSection
                        width: app.width
                        height: aotdInner.height + 24
                        color: "#0a1a19"

                        // Compute today's attraction index from date — changes daily
                        property int todayIdx: {
                            var d = new Date();
                            var dayOfYear = Math.floor((d - new Date(d.getFullYear(), 0, 0)) / 86400000);
                            return dayOfYear % attractionModel.count;
                        }
                        property var todayAttraction: attractionModel.get(todayIdx)

                        function refreshDailyContent() {
                            var d = new Date();
                            var dayOfYear = Math.floor((d - new Date(d.getFullYear(), 0, 0)) / 86400000);
                            todayIdx = dayOfYear % attractionModel.count;
                            todayAttraction = attractionModel.get(todayIdx);
                        }

                        Column {
                            id: aotdInner
                            anchors.top: parent.top
                            anchors.topMargin: 12
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10

                            // Title row
                            Row {
                                spacing: 8
                                anchors.horizontalCenter: parent.horizontalCenter
                                Text {
                                    text: "🌟"
                                    font.pointSize: Qt.platform.os === "android" ? 16 : 13
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: langSettings.lang === "sw"
                                          ? "Kivutio cha Leo"
                                          : "Attraction of the Day"
                                    font.pointSize: Qt.platform.os === "android" ? 15 : 13
                                    font.bold: true
                                    color: "cyan"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "🌟"
                                    font.pointSize: Qt.platform.os === "android" ? 16 : 13
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            // Card
                            Rectangle {
                                width: parent.width
                                height: aotdImg.height + aotdTextCol.height + 16
                                radius: 12
                                color: "#1a2a2a"
                                border.color: "cyan"
                                border.width: 1
                                clip: true

                                property bool pressed: false
                                scale: pressed ? 0.98 : 1.0
                                Behavior on scale { NumberAnimation { duration: 120 } }

                                // Image
                                Image {
                                    id: aotdImg
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: width * 0.52
                                    source: aotdSection.todayAttraction ? aotdSection.todayAttraction.imageFile : ""
                                    fillMode: Image.PreserveAspectCrop
                                }

                                // Gradient over image bottom
                                Rectangle {
                                    anchors.bottom: aotdImg.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: aotdImg.height * 0.4
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "transparent" }
                                        GradientStop { position: 1.0; color: "#1a2a2a" }
                                    }
                                }

                                Column {
                                    id: aotdTextCol
                                    anchors.top: aotdImg.bottom
                                    anchors.topMargin: 8
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 4

                                    Text {
                                        width: parent.width
                                        text: aotdSection.todayAttraction
                                              ? (langSettings.lang === "sw"
                                                 ? aotdSection.todayAttraction.name_sw
                                                 : aotdSection.todayAttraction.name_en)
                                              : ""
                                        font.pointSize: Qt.platform.os === "android" ? 14 : 12
                                        font.bold: true
                                        color: "cyan"
                                        wrapMode: Text.WordWrap
                                    }

                                    Text {
                                        width: parent.width
                                        text: aotdSection.todayAttraction
                                              ? (langSettings.lang === "sw"
                                                 ? aotdSection.todayAttraction.desc_sw
                                                 : aotdSection.todayAttraction.desc_en)
                                              : ""
                                        font.pointSize: Qt.platform.os === "android" ? 11 : 9
                                        color: "#cccccc"
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 3
                                        elide: Text.ElideRight
                                    }

                                    // Explore button
                                    Rectangle {
                                        id: aotdBtn
                                        anchors.right: parent.right
                                        width: aotdBtnTxt.implicitWidth + 24
                                        height: Qt.platform.os === "android" ? 40 : 32
                                        radius: height / 2
                                        color: langSettings.lang === "sw" ? "green" : "blue"
                                        property bool pressed: false
                                        scale: pressed ? 0.95 : 1.0
                                        Behavior on scale { NumberAnimation { duration: 100 } }

                                        Text {
                                            id: aotdBtnTxt
                                            anchors.centerIn: parent
                                            text: langSettings.lang === "sw" ? "Chunguza →" : "Explore →"
                                            font.pointSize: Qt.platform.os === "android" ? 12 : 10
                                            font.bold: true
                                            color: "white"
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            onPressed:  aotdBtn.pressed = true
                                            onReleased: aotdBtn.pressed = false
                                            onCanceled: aotdBtn.pressed = false
                                            onClicked: {
                                                app.currentAttractionIndex = aotdSection.todayIdx;
                                                app.appMode = 1;
                                                // lang already set by pageCol
                                            }
                                        }
                                    }

                                    Item { width: 1; height: 4 }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onPressed:  parent.pressed = true
                                    onReleased: parent.pressed = false
                                    onCanceled: parent.pressed = false
                                    onClicked: {
                                        var a = aotdSection.todayAttraction;
                                        if (a) {
                                            contextMenu.doOpen(
                                                        langSettings.lang,
                                                        langSettings.lang === "sw" ? a.name_sw : a.name_en,
                                                        langSettings.lang === "sw" ? a.desc_sw : a.desc_en,
                                                        a.imageFile,
                                                        aotdSection.todayIdx
                                                        );
                                        }
                                    }
                                }
                            }

                            // ── Countdown row ──────────────────────────────
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 6

                                Text {
                                    text: "⏱"
                                    font.pointSize: Qt.platform.os === "android" ? 10 : 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    opacity: 0.6
                                }
                                Text {
                                    id: aotdCountdownLabel
                                    text: langSettings.lang === "sw"
                                          ? "Inabadilika baada ya"
                                          : "Changes in"
                                    font.pointSize: Qt.platform.os === "android" ? 10 : 8
                                    color: "#888888"
                                    font.italic: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    id: aotdCountdownText
                                    text: "00:00:00"
                                    font.pointSize: Qt.platform.os === "android" ? 10 : 8
                                    font.bold: true
                                    color: Qt.rgba(0, 1, 1, 0.7)
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            // Countdown timer
                            Timer {
                                id: aotdCountdownTimer
                                interval: 1000
                                repeat: true
                                running: true
                                onTriggered: {
                                    var now = new Date();
                                    var midnight = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 0, 0, 0);
                                    var secs = Math.floor((midnight - now) / 1000);
                                    var h = Math.floor(secs / 3600);
                                    var m = Math.floor((secs % 3600) / 60);
                                    var s = secs % 60;
                                    aotdCountdownText.text =
                                            (h < 10 ? "0" + h : h) + ":" +
                                            (m < 10 ? "0" + m : m) + ":" +
                                            (s < 10 ? "0" + s : s);

                                    // Saa imefika usiku wa manane — badilisha maudhui bila kufungua app
                                    if (h === 0 && m === 0 && s === 0) {
                                        aotdSection.refreshDailyContent();
                                        dykSection.refreshDailyContent();
                                    }
                                }
                                Component.onCompleted: { aotdCountdownTimer.triggered(); }
                            }
                        }
                    }

                    // ══ CHOOSE LANGUAGE SECTION ════════════════════════════
                    Rectangle {
                        width: app.width
                        height: langCol.height + 32
                        color: "#0d1f1e"

                        Column {
                            id: langCol
                            anchors.centerIn: parent
                            width: app.width
                            spacing: 12

                            // ══ TAGLINE CARD ═══════════════════════════════════════
                            Rectangle {
                                width: app.width
                                height: taglineText.implicitHeight + 28
                                color: "#0d1f1e"

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 4
                                    height: parent.height - 20
                                    radius: 2
                                    color: "cyan"
                                }

                                Text {
                                    id: taglineText
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: 30
                                    anchors.rightMargin: 16
                                    text: langSettings.lang === "sw" ? "Kusafiri ni elimu. Tembelea hifadhi za Tanzania, jifunze thamani ya mazingira ya Tanzania, na uwe balozi wa uzuri wa Tanzania." : "Travel is a form of learning. Explore Tanzania's national parks, discover the value of our environment, and become an ambassador for the beauty of Tanzania."
                                    font.pointSize: Qt.platform.os === "android" ? 12 : 10
                                    color: "#cccccc"
                                    wrapMode: Text.WordWrap
                                    font.italic: true
                                }
                            }

                            // Swahili button
                            Rectangle {
                                id: swBtn
                                visible: langSettings.lang === "sw"
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: app.width * 0.82
                                height: Qt.platform.os === "android" ? 62 : 48
                                radius: 10
                                color: "green"
                                property bool pressed: false
                                scale: pressed ? 0.96 : 1.0
                                Behavior on scale { NumberAnimation { duration: 100 } }

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    Text { text: "🇹🇿"; font.pointSize: Qt.platform.os === "android" ? 18 : 14 }
                                    Text {
                                        text: "Furahia upekee wa Tanzania"
                                        font.pointSize: Qt.platform.os === "android" ? 13 : 11
                                        font.bold: true
                                        color: "white"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onPressed:  swBtn.pressed = true
                                    onReleased: swBtn.pressed = false
                                    onCanceled: swBtn.pressed = false
                                    onClicked:  modeSelectionDialog.doOpen("sw", "green")
                                }
                            }

                            // English button
                            Rectangle {
                                id: enBtn
                                visible: langSettings.lang === "en"
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: app.width * 0.82
                                height: Qt.platform.os === "android" ? 62 : 48
                                radius: 10
                                color: "blue"
                                property bool pressed: false
                                scale: pressed ? 0.96 : 1.0
                                Behavior on scale { NumberAnimation { duration: 100 } }

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    Text { text: "🌐"; font.pointSize: Qt.platform.os === "android" ? 18 : 14 }
                                    Text {
                                        text: "Experience the uniqueness of Tanzania"
                                        font.pointSize: Qt.platform.os === "android" ? 13 : 11
                                        font.bold: true
                                        color: "white"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onPressed:  enBtn.pressed = true
                                    onReleased: enBtn.pressed = false
                                    onCanceled: enBtn.pressed = false
                                    onClicked:  modeSelectionDialog.doOpen("en", "blue")
                                }
                            }

                            // 🎮 Game button — opens language dialog
                            Rectangle {
                                id: gameBtn
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: app.width * 0.82
                                height: Qt.platform.os === "android" ? 62 : 48
                                radius: 10
                                color: "#0d2a28"
                                border.color: "cyan"; border.width: 1
                                property bool pressed: false
                                scale: pressed ? 0.96 : 1.0
                                Behavior on scale { NumberAnimation { duration: 100 } }
                                Row {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left; anchors.leftMargin: 16
                                    spacing: 14
                                    Rectangle {
                                        width: Qt.platform.os === "android" ? 52 : 42; height: width
                                        radius: 10; color: "cyan"
                                        anchors.verticalCenter: parent.verticalCenter
                                        Text { anchors.centerIn: parent; text: "🎮"; font.pointSize: Qt.platform.os === "android" ? 20 : 16 }
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                        Text { text:  langSettings.lang === "sw" ? "Mchezo wa Utalii" : "Tourism Memory Game"; font.pointSize: Qt.platform.os === "android" ? 13 : 11; font.bold: true; color: "white" }
                                    }
                                }
                                Text {
                                    anchors.right: parent.right; anchors.rightMargin: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "›"; font.pointSize: Qt.platform.os === "android" ? 22 : 18
                                    font.bold: true; color: "cyan"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onPressed:  gameBtn.pressed = true
                                    onReleased: {
                                        gameLangSwCard.pressed = false;
                                        app.gameLang = langSettings.lang;
                                        app.gameVisible = true;
                                    }
                                    onCanceled: gameBtn.pressed = false
                                }
                            }

                            // 🎲 Surprise me button
                            /*
                            Rectangle {
                                id: randomBtn
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: app.width * 0.82
                                height: Qt.platform.os === "android" ? 62 : 48
                                radius: 10
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#1a6060" }
                                    GradientStop { position: 1.0; color: "#001413" }
                                }
                                border.color: "cyan"
                                border.width: 1
                                property bool pressed: false
                                scale: pressed ? 0.96 : 1.0
                                Behavior on scale { NumberAnimation { duration: 100 } }

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    Text { text: "🎲"; font.pointSize: Qt.platform.os === "android" ? 18 : 14 }
                                    Text {
                                        text: langSettings.lang === "sw" ? "Nishangaze!" : "Surprise me!"
                                        font.pointSize: Qt.platform.os === "android" ? 13 : 11
                                        font.bold: true
                                        color: "cyan"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onPressed:  randomBtn.pressed = true
                                    onReleased: randomBtn.pressed = false
                                    onCanceled: randomBtn.pressed = false
                                    onClicked: {
                                        app.currentAttractionIndex = Math.floor(Math.random() * attractionModel.count);
                                        app.appMode = 1;
                                        app.lastTapX = mouse.x + randomBtn.x;
                                        app.lastTapY = mouse.y + randomBtn.y;
                                        modeSelectionDialog.doOpenRandom();
                                    }
                                }
                            } */
                        }
                    }

                    // ══ SAFARI CHANNEL INFO ════════════════════════════════

                    Rectangle {
                        visible: (app.safariChannelMode === 1) || (app.safariChannelMode === 2)
                        width: app.width
                        height: safariCol.height + 24
                        color: "#001413"

                        Column {
                            id: safariCol
                            anchors.top: parent.top
                            anchors.topMargin: 12
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 8

                            // TV icon + label
                            Row {
                                spacing: 8
                                Text { text: "📺"; font.pointSize: Qt.platform.os === "android" ? 14 : 11 }
                                Text {
                                    text: "Tanzania Safari Channel"
                                    font.pointSize: Qt.platform.os === "android" ? 13 : 11
                                    font.bold: true
                                    color: "cyan"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Text {
                                id:tscDesc
                                width: parent.width
                                text: langSettings.lang === "sw" ? "Tanzania imebarikiwa kuwa na vivutio vingi vya utalii ambavyo ni vigumu kuvitaja vyote hapa. Ili kuvifahamu na kuvishuhudia kwa undani zaidi, tunakushauri kufuatilia Tanzania Safari Channel inayopatikana kupitia DStv (292), Azam TV (401), Zuku (27), StarTimes Antenna (331), StarTimes Dish (542), Zmux (46) na Continental (7). Huu ni mlango wako wa kidijitali wa kutembelea mbuga za wanyama, fukwe, na urithi wa kitamaduni wa nchi yetu ukiwa nyumbani kwako." : "Tanzania is home to an overwhelming number of tourist attractions that cannot be fully listed here. For a more immersive experience, we highly recommend watching the Tanzania Safari Channel, available on DStv (292), Azam TV (401), Zuku (27), StarTimes Antenna (331), StarTimes Dish (542), Zmux (46) and Continental (7)."
                                font.pointSize: Qt.platform.os === "android" ? 12 : 10
                                color: "#cccccc"
                                wrapMode: Text.WordWrap
                            }

                            // ── Watch Live button ─────────────────────────────
                            Rectangle {
                                id: watchLiveBtn
                                visible: (app.safariChannelMode === 1)
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width
                                height: Qt.platform.os === "android" ? 66 : 52
                                radius: 14
                                property bool pressed: false
                                scale: pressed ? 0.96 : 1.0
                                Behavior on scale { NumberAnimation { duration: 110 } }

                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: watchLiveBtn.pressed ? "#1a6060" : "#0d3a38" }
                                    GradientStop { position: 1.0; color: watchLiveBtn.pressed ? "#0d3a38" : "#001413" }
                                }
                                border.color: "cyan"
                                border.width: 2

                                // Pulsing cyan glow
                                SequentialAnimation on border.width {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 3; duration: 900; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: 1; duration: 900; easing.type: Easing.InOutSine }
                                }

                                Row {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    spacing: 14

                                    // TV icon box
                                    Rectangle {
                                        width: Qt.platform.os === "android" ? 46 : 38
                                        height: width
                                        radius: 8
                                        color: "#1a6060"
                                        anchors.verticalCenter: parent.verticalCenter
                                        Text {
                                            anchors.centerIn: parent
                                            text: "📺"
                                            font.pointSize: Qt.platform.os === "android" ? 18 : 14
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2
                                        Text {
                                            text: langSettings.lang === "sw" ? "Tazama Tanzania Safari Channel" : "Watch Tanzania Safari Channel"
                                            font.pointSize: Qt.platform.os === "android" ? 12 : 10
                                            font.bold: true
                                            color: "cyan"
                                        }
                                    }
                                }

                                // Live badge
                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: liveBadgeTxt.implicitWidth + 14
                                    height: Qt.platform.os === "android" ? 26 : 20
                                    radius: height / 2
                                    color: "#cc0000"

                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.3; duration: 700 }
                                        NumberAnimation { to: 1.0; duration: 700 }
                                    }

                                    Text {
                                        id: liveBadgeTxt
                                        anchors.centerIn: parent
                                        text: langSettings.lang === "sw" ? "● MOJA KWA MOJA" : "● LIVE"
                                        font.pointSize: Qt.platform.os === "android" ? 9 : 7
                                        font.bold: true
                                        color: "white"
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onPressed:  watchLiveBtn.pressed = true
                                    onReleased: {
                                        watchLiveBtn.pressed = false;
                                        app.safariTvVisible = true;
                                        safariPlayer.source = app.safariChannelStreamURL;
                                    }
                                    onCanceled: watchLiveBtn.pressed = false
                                }
                            }
                        }
                    }



                    // ══ FOOTER ═════════════════════════════════════════════
                    Rectangle {
                        width: app.width
                        height: Qt.platform.os === "android" ? 70 : 54
                        color: "#000d0c"

                        Rectangle {
                            id: closeBtn
                            anchors.centerIn: parent
                            width: app.width * 0.4
                            height: Qt.platform.os === "android" ? 46 : 34
                            radius: height / 2
                            color: "#cc2200"
                            property bool pressed: false
                            scale: pressed ? 0.96 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text: langSettings.lang === "sw" ? "Funga" : "Close"
                                font.pointSize: Qt.platform.os === "android" ? 12 : 10
                                font.bold: true
                                color: "white"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onPressed:  closeBtn.pressed = true
                                onReleased: closeBtn.pressed = false
                                onCanceled: closeBtn.pressed = false
                                onClicked:  app.close()
                            }
                        }
                    }

                    // ══ MAGABE LAB BRANDING — MUSIC BEAT LETTERS ══════════
                    Item {
                        id: mgbBrand
                        width: app.width
                        height: Qt.platform.os === "android" ? 58 : 46

                        // Background
                        Rectangle {
                            anchors.fill: parent
                            color: "#000d0c"
                        }

                        // Top separator line
                        Rectangle {
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 100; height: 1
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 0.5; color: Qt.rgba(0,1,1,0.3) }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                        }

                        // Beat index — cycles through letters like a music beat
                        property int beatIdx: 0
                        property var letters: ["M","A","G","A","B","E"," ","L","A","B"]
                        // beat amplitudes per letter — simulate drum/bass pattern
                        property var beatAmp: [1.0, 0.4, 0.7, 0.3, 1.0, 0.5, 0.0, 0.9, 0.4, 1.0]
                        property int activeLetter: -1

                        // Beat timer — sequential, 90ms per step ≈ lively groove
                        Timer {
                            id: beatTimer
                            interval: 90
                            repeat: true
                            running: true
                            onTriggered: {
                                mgbBrand.activeLetter = mgbBrand.beatIdx;
                                mgbBrand.beatIdx = (mgbBrand.beatIdx + 1) % mgbBrand.letters.length;
                            }
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: Qt.platform.os === "android" ? 2 : 1

                            // Left accent dash
                            Rectangle {
                                width: Qt.platform.os === "android" ? 14 : 10
                                height: 1; radius: 1
                                color: Qt.rgba(0, 1, 1, 0.25)
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Letter: M
                            Item {
                                id: ltr0
                                property bool active: mgbBrand.activeLetter === 0
                                property real amp: mgbBrand.beatAmp[0]
                                width: ltrTxt0.implicitWidth + (Qt.platform.os === "android" ? 3 : 2)
                                height: Qt.platform.os === "android" ? 38 : 28
                                anchors.verticalCenter: parent.verticalCenter
                                property real lift: active ? -(amp * (Qt.platform.os === "android" ? 9 : 7)) : 0
                                Behavior on lift { NumberAnimation { duration: 60; easing.type: Easing.OutBack } }
                                Text {
                                    id: ltrTxt0
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: ltr0.lift
                                    text: "M"
                                    font.pointSize: Qt.platform.os === "android" ? 9 : 7
                                    font.bold: true
                                    font.letterSpacing: 1
                                    color: ltr0.active ? Qt.rgba(0, 1, 0.9, 1.0) : Qt.rgba(0, 0.75, 0.65, 0.65)
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                    scale: ltr0.active ? (1.0 + ltr0.amp * 0.35) : 1.0
                                    Behavior on scale { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                }
                                // Beat bar below letter
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 2
                                    height: ltr0.active ? (ltr0.amp * (Qt.platform.os === "android" ? 5 : 4) + 1) : 1
                                    radius: 1
                                    color: ltr0.active ? "cyan" : Qt.rgba(0,1,1,0.2)
                                    Behavior on height { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                }
                            }

                            // Letter: A (1)
                            Item {
                                id: ltr1
                                property bool active: mgbBrand.activeLetter === 1
                                property real amp: mgbBrand.beatAmp[1]
                                width: ltrTxt1.implicitWidth + (Qt.platform.os === "android" ? 3 : 2)
                                height: Qt.platform.os === "android" ? 38 : 28
                                anchors.verticalCenter: parent.verticalCenter
                                property real lift: active ? -(amp * (Qt.platform.os === "android" ? 9 : 7)) : 0
                                Behavior on lift { NumberAnimation { duration: 60; easing.type: Easing.OutBack } }
                                Text {
                                    id: ltrTxt1
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: ltr1.lift
                                    text: "A"
                                    font.pointSize: Qt.platform.os === "android" ? 9 : 7
                                    font.bold: true
                                    font.letterSpacing: 1
                                    color: ltr1.active ? Qt.rgba(0, 1, 0.9, 1.0) : Qt.rgba(0, 0.75, 0.65, 0.65)
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                    scale: ltr1.active ? (1.0 + ltr1.amp * 0.35) : 1.0
                                    Behavior on scale { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                }
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 2
                                    height: ltr1.active ? (ltr1.amp * (Qt.platform.os === "android" ? 5 : 4) + 1) : 1
                                    radius: 1
                                    color: ltr1.active ? "cyan" : Qt.rgba(0,1,1,0.2)
                                    Behavior on height { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                }
                            }

                            // Letter: G
                            Item {
                                id: ltr2
                                property bool active: mgbBrand.activeLetter === 2
                                property real amp: mgbBrand.beatAmp[2]
                                width: ltrTxt2.implicitWidth + (Qt.platform.os === "android" ? 3 : 2)
                                height: Qt.platform.os === "android" ? 38 : 28
                                anchors.verticalCenter: parent.verticalCenter
                                property real lift: active ? -(amp * (Qt.platform.os === "android" ? 9 : 7)) : 0
                                Behavior on lift { NumberAnimation { duration: 60; easing.type: Easing.OutBack } }
                                Text {
                                    id: ltrTxt2
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: ltr2.lift
                                    text: "G"
                                    font.pointSize: Qt.platform.os === "android" ? 9 : 7
                                    font.bold: true
                                    font.letterSpacing: 1
                                    color: ltr2.active ? Qt.rgba(0, 1, 0.9, 1.0) : Qt.rgba(0, 0.75, 0.65, 0.65)
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                    scale: ltr2.active ? (1.0 + ltr2.amp * 0.35) : 1.0
                                    Behavior on scale { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                }
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 2
                                    height: ltr2.active ? (ltr2.amp * (Qt.platform.os === "android" ? 5 : 4) + 1) : 1
                                    radius: 1
                                    color: ltr2.active ? "cyan" : Qt.rgba(0,1,1,0.2)
                                    Behavior on height { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                }
                            }

                            // Letter: A (2)
                            Item {
                                id: ltr3
                                property bool active: mgbBrand.activeLetter === 3
                                property real amp: mgbBrand.beatAmp[3]
                                width: ltrTxt3.implicitWidth + (Qt.platform.os === "android" ? 3 : 2)
                                height: Qt.platform.os === "android" ? 38 : 28
                                anchors.verticalCenter: parent.verticalCenter
                                property real lift: active ? -(amp * (Qt.platform.os === "android" ? 9 : 7)) : 0
                                Behavior on lift { NumberAnimation { duration: 60; easing.type: Easing.OutBack } }
                                Text {
                                    id: ltrTxt3
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: ltr3.lift
                                    text: "A"
                                    font.pointSize: Qt.platform.os === "android" ? 9 : 7
                                    font.bold: true
                                    font.letterSpacing: 1
                                    color: ltr3.active ? Qt.rgba(0, 1, 0.9, 1.0) : Qt.rgba(0, 0.75, 0.65, 0.65)
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                    scale: ltr3.active ? (1.0 + ltr3.amp * 0.35) : 1.0
                                    Behavior on scale { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                }
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 2
                                    height: ltr3.active ? (ltr3.amp * (Qt.platform.os === "android" ? 5 : 4) + 1) : 1
                                    radius: 1
                                    color: ltr3.active ? "cyan" : Qt.rgba(0,1,1,0.2)
                                    Behavior on height { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                }
                            }

                            // Letter: B
                            Item {
                                id: ltr4
                                property bool active: mgbBrand.activeLetter === 4
                                property real amp: mgbBrand.beatAmp[4]
                                width: ltrTxt4.implicitWidth + (Qt.platform.os === "android" ? 3 : 2)
                                height: Qt.platform.os === "android" ? 38 : 28
                                anchors.verticalCenter: parent.verticalCenter
                                property real lift: active ? -(amp * (Qt.platform.os === "android" ? 9 : 7)) : 0
                                Behavior on lift { NumberAnimation { duration: 60; easing.type: Easing.OutBack } }
                                Text {
                                    id: ltrTxt4
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: ltr4.lift
                                    text: "B"
                                    font.pointSize: Qt.platform.os === "android" ? 9 : 7
                                    font.bold: true
                                    font.letterSpacing: 1
                                    color: ltr4.active ? Qt.rgba(0, 1, 0.9, 1.0) : Qt.rgba(0, 0.75, 0.65, 0.65)
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                    scale: ltr4.active ? (1.0 + ltr4.amp * 0.35) : 1.0
                                    Behavior on scale { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                }
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 2
                                    height: ltr4.active ? (ltr4.amp * (Qt.platform.os === "android" ? 5 : 4) + 1) : 1
                                    radius: 1
                                    color: ltr4.active ? "cyan" : Qt.rgba(0,1,1,0.2)
                                    Behavior on height { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                }
                            }

                            // Letter: E
                            Item {
                                id: ltr5
                                property bool active: mgbBrand.activeLetter === 5
                                property real amp: mgbBrand.beatAmp[5]
                                width: ltrTxt5.implicitWidth + (Qt.platform.os === "android" ? 3 : 2)
                                height: Qt.platform.os === "android" ? 38 : 28
                                anchors.verticalCenter: parent.verticalCenter
                                property real lift: active ? -(amp * (Qt.platform.os === "android" ? 9 : 7)) : 0
                                Behavior on lift { NumberAnimation { duration: 60; easing.type: Easing.OutBack } }
                                Text {
                                    id: ltrTxt5
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: ltr5.lift
                                    text: "E"
                                    font.pointSize: Qt.platform.os === "android" ? 9 : 7
                                    font.bold: true
                                    font.letterSpacing: 1
                                    color: ltr5.active ? Qt.rgba(0, 1, 0.9, 1.0) : Qt.rgba(0, 0.75, 0.65, 0.65)
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                    scale: ltr5.active ? (1.0 + ltr5.amp * 0.35) : 1.0
                                    Behavior on scale { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                }
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 2
                                    height: ltr5.active ? (ltr5.amp * (Qt.platform.os === "android" ? 5 : 4) + 1) : 1
                                    radius: 1
                                    color: ltr5.active ? "cyan" : Qt.rgba(0,1,1,0.2)
                                    Behavior on height { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                }
                            }

                            // Spacer between MAGABE and LAB
                            Item {
                                width: Qt.platform.os === "android" ? 8 : 6
                                height: 1
                            }

                            // Letter: L
                            Item {
                                id: ltr7
                                property bool active: mgbBrand.activeLetter === 7
                                property real amp: mgbBrand.beatAmp[7]
                                width: ltrTxt7.implicitWidth + (Qt.platform.os === "android" ? 3 : 2)
                                height: Qt.platform.os === "android" ? 38 : 28
                                anchors.verticalCenter: parent.verticalCenter
                                property real lift: active ? -(amp * (Qt.platform.os === "android" ? 9 : 7)) : 0
                                Behavior on lift { NumberAnimation { duration: 60; easing.type: Easing.OutBack } }
                                Text {
                                    id: ltrTxt7
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: ltr7.lift
                                    text: "L"
                                    font.pointSize: Qt.platform.os === "android" ? 9 : 7
                                    font.bold: true
                                    font.letterSpacing: 1
                                    color: ltr7.active ? Qt.rgba(0, 1, 0.9, 1.0) : Qt.rgba(0, 0.75, 0.65, 0.65)
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                    scale: ltr7.active ? (1.0 + ltr7.amp * 0.35) : 1.0
                                    Behavior on scale { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                }
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 2
                                    height: ltr7.active ? (ltr7.amp * (Qt.platform.os === "android" ? 5 : 4) + 1) : 1
                                    radius: 1
                                    color: ltr7.active ? "cyan" : Qt.rgba(0,1,1,0.2)
                                    Behavior on height { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                }
                            }

                            // Letter: A (3)
                            Item {
                                id: ltr8
                                property bool active: mgbBrand.activeLetter === 8
                                property real amp: mgbBrand.beatAmp[8]
                                width: ltrTxt8.implicitWidth + (Qt.platform.os === "android" ? 3 : 2)
                                height: Qt.platform.os === "android" ? 38 : 28
                                anchors.verticalCenter: parent.verticalCenter
                                property real lift: active ? -(amp * (Qt.platform.os === "android" ? 9 : 7)) : 0
                                Behavior on lift { NumberAnimation { duration: 60; easing.type: Easing.OutBack } }
                                Text {
                                    id: ltrTxt8
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: ltr8.lift
                                    text: "A"
                                    font.pointSize: Qt.platform.os === "android" ? 9 : 7
                                    font.bold: true
                                    font.letterSpacing: 1
                                    color: ltr8.active ? Qt.rgba(0, 1, 0.9, 1.0) : Qt.rgba(0, 0.75, 0.65, 0.65)
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                    scale: ltr8.active ? (1.0 + ltr8.amp * 0.35) : 1.0
                                    Behavior on scale { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                }
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 2
                                    height: ltr8.active ? (ltr8.amp * (Qt.platform.os === "android" ? 5 : 4) + 1) : 1
                                    radius: 1
                                    color: ltr8.active ? "cyan" : Qt.rgba(0,1,1,0.2)
                                    Behavior on height { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                }
                            }

                            // Letter: B (2)
                            Item {
                                id: ltr9
                                property bool active: mgbBrand.activeLetter === 9
                                property real amp: mgbBrand.beatAmp[9]
                                width: ltrTxt9.implicitWidth + (Qt.platform.os === "android" ? 3 : 2)
                                height: Qt.platform.os === "android" ? 38 : 28
                                anchors.verticalCenter: parent.verticalCenter
                                property real lift: active ? -(amp * (Qt.platform.os === "android" ? 9 : 7)) : 0
                                Behavior on lift { NumberAnimation { duration: 60; easing.type: Easing.OutBack } }
                                Text {
                                    id: ltrTxt9
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: ltr9.lift
                                    text: "B"
                                    font.pointSize: Qt.platform.os === "android" ? 9 : 7
                                    font.bold: true
                                    font.letterSpacing: 1
                                    color: ltr9.active ? Qt.rgba(0, 1, 0.9, 1.0) : Qt.rgba(0, 0.75, 0.65, 0.65)
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                    scale: ltr9.active ? (1.0 + ltr9.amp * 0.35) : 1.0
                                    Behavior on scale { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                }
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 2
                                    height: ltr9.active ? (ltr9.amp * (Qt.platform.os === "android" ? 5 : 4) + 1) : 1
                                    radius: 1
                                    color: ltr9.active ? "cyan" : Qt.rgba(0,1,1,0.2)
                                    Behavior on height { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                }
                            }

                            // Right accent dash
                            Rectangle {
                                width: Qt.platform.os === "android" ? 14 : 10
                                height: 1; radius: 1
                                color: Qt.rgba(0, 1, 1, 0.25)
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                } // end Column
            } // end Flickable
        }
    }

    // Attraction View Component 1
    Component {
        id: attractionViewComponent1
        Item {
            id: attractionItem
            anchors.fill: parent
            focus: true

            // ── Crossfade: two images swapping opacity ─────────────────
            property int shownIndex: app.currentAttractionIndex

            Image {
                id: attractionImageA
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: app.currentAttractionImage()
                opacity: 1

                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    visible: attractionImageA.status !== Image.Ready
                    Text {
                        anchors.centerIn: parent
                        text: langSettings.lang === "sw" ? "Picha haipatikani" : "Image not found"
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
            }

            // ── Full-screen swipe handler ─────────────────────────────
            MouseArea {
                id: swipeArea
                anchors.fill: parent
                z: 10
                property real startX: 0
                property bool isDrag: false

                onPressed:  { startX = mouse.x; isDrag = false; }
                onPositionChanged: { if (Math.abs(mouse.x - startX) > 15) isDrag = true; }
                onReleased: {
                    if (isDrag) {
                        var delta = mouse.x - startX;
                        if (Math.abs(delta) > app.width * 0.18) {
                            if (delta < 0) navigateNext();
                            else           navigatePrevious();
                        }
                    }
                }
            }

            // ── Top gradient overlay (title + desc) ───────────────────
            Rectangle {
                id: topOverlay
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: overlayCol.height + 20
                color: "transparent"
                z: 11

                Rectangle {
                    anchors.fill: parent
                    color: "#dd000000"
                }

                Column {
                    id: overlayCol
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 4

                    // Counter badge
                    Rectangle {
                        width: counterText.implicitWidth + 16
                        height: counterText.implicitHeight + 6
                        radius: 4
                        color: langSettings.lang === "sw" ? "#bb006600" : "#bb000088"
                        border.color: "cyan"
                        border.width: 1

                        Text {
                            id: counterText
                            anchors.centerIn: parent
                            text: (app.currentAttractionIndex + 1) + " / " + attractionModel.count
                            color: "cyan"
                            font.pointSize: Qt.platform.os === "android" ? 11 : 9
                            font.bold: true
                        }
                    }

                    Text {
                        id: attractionNameText
                        width: parent.width
                        text: app.currentAttractionName()
                        font.pointSize: Qt.platform.os === "android" ? 16 : 14
                        font.bold: true
                        color: "white"
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        id: attractionDescriptionText
                        width: parent.width
                        text: app.currentAttractionDesc()
                        font.pointSize: Qt.platform.os === "android" ? 12 : 10
                        color: "#e0e0e0"
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // ── Progress bar ──────────────────────────────────────────
            Rectangle {
                id: progressBar
                anchors.bottom: navBar.top
                anchors.left: parent.left
                height: 3
                color: langSettings.lang === "sw" ? "green" : "blue"
                width: attractionModel.count > 0
                       ? parent.width * (app.currentAttractionIndex + 1) / attractionModel.count
                       : 0
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
            }

            // ── Search bar ────────────────────────────────────────────
            Rectangle {
                id: cardSearchBg
                anchors.bottom: progressBar.top
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.6
                height: cardSearchField.implicitHeight + 10
                color: "#cc001413"
                z: 20
                radius: 6
                border.color: "cyan"
                border.width: 1

                TextField {
                    id: cardSearchField
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: cardClearBtn.left
                    anchors.leftMargin: 8
                    anchors.rightMargin: 4
                    placeholderText: langSettings.lang === "sw" ? "Tafuta..." : "Search..."
                    font.pointSize: Qt.platform.os === "android" ? 12 : 10
                    color: "white"
                    placeholderTextColor: "#888888"
                    background: Rectangle { color: "transparent" }
                    onTextChanged: {
                        var s = text.toLowerCase();
                        if (s === "") return;
                        for (var i = 0; i < attractionModel.count; i++) {
                            var item = attractionModel.get(i);
                            var n = app.selectedLanguage === "en" ? item.name_en : item.name_sw;
                            var d = app.selectedLanguage === "en" ? item.desc_en : item.desc_sw;
                            if (n.toLowerCase().indexOf(s) !== -1 || d.toLowerCase().indexOf(s) !== -1) {
                                app.currentAttractionIndex = i;
                                break;
                            }
                        }
                    }
                }

                Text {
                    id: cardClearBtn
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: "X"
                    color: cardSearchField.text.length > 0 ? "cyan" : "#444444"
                    font.pixelSize: 14
                    font.bold: true
                    MouseArea {
                        anchors.fill: parent
                        onClicked: { cardSearchField.text = ""; }
                    }
                }
            }

            // ── Navigation bar ────────────────────────────────────────
            Rectangle {
                id: navBar
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: Qt.platform.os === "android" ? 80 : 52
                color: "#e6001413"
                border.color: "#33ffffff"
                border.width: 0
                z: 20

                // Prev button
                Rectangle {
                    id: prevBtn
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    width: Qt.platform.os === "android" ? 90 : 64
                    height: Qt.platform.os === "android" ? 52 : 36
                    radius: height / 2
                    color: "#55ffffff"
                    border.color: "#88ffffff"
                    border.width: 1

                    property bool pressed: false
                    scale: pressed ? 0.93 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: langSettings.lang === "sw" ? "‹ Nyuma" : "‹ Prev"
                        color: "white"
                        font.pointSize: Qt.platform.os === "android" ? 13 : 10
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed:  prevBtn.pressed = true
                        onReleased: prevBtn.pressed = false
                        onCanceled: prevBtn.pressed = false
                        onClicked:  navigatePrevious()
                    }
                }

                // Home / back button (centre)
                Rectangle {
                    id: homeBtn
                    anchors.centerIn: parent
                    width: Qt.platform.os === "android" ? 90 : 64
                    height: Qt.platform.os === "android" ? 52 : 36
                    radius: height / 2
                    color: langSettings.lang === "sw" ? "#88006600" : "#880000aa"
                    border.color: "cyan"
                    border.width: 1

                    property bool pressed: false
                    scale: pressed ? 0.93 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: "⌂"
                        color: "cyan"
                        font.pointSize: Qt.platform.os === "android" ? 18 : 14
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed:  homeBtn.pressed = true
                        onReleased: homeBtn.pressed = false
                        onCanceled: homeBtn.pressed = false
                        onClicked: {
                            viewComponentLoader.switchTo(languageSelectionComponent, app.width / 2, app.height / 2);
                            app.selectedLanguage = "";
                        }
                    }
                }

                // Next button
                Rectangle {
                    id: nextBtn
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    width: Qt.platform.os === "android" ? 90 : 64
                    height: Qt.platform.os === "android" ? 52 : 36
                    radius: height / 2
                    color: "#55ffffff"
                    border.color: "#88ffffff"
                    border.width: 1

                    property bool pressed: false
                    scale: pressed ? 0.93 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: langSettings.lang === "sw" ? "Mbele ›" : "Next ›"
                        color: "white"
                        font.pointSize: Qt.platform.os === "android" ? 13 : 10
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed:  nextBtn.pressed = true
                        onReleased: nextBtn.pressed = false
                        onCanceled: nextBtn.pressed = false
                        onClicked:  navigateNext()
                    }
                }
            }

            // ── Keyboard navigation ───────────────────────────────────
            Keys.onPressed: (event) => {
                                if (event.key === Qt.Key_Left)  { navigatePrevious(); event.accepted = true; }
                                else if (event.key === Qt.Key_Right) { navigateNext(); event.accepted = true; }
                            }

            function navigatePrevious() {
                app.currentAttractionIndex = app.currentAttractionIndex > 0
                        ? app.currentAttractionIndex - 1
                        : attractionModel.count - 1;
            }

            function navigateNext() {
                app.currentAttractionIndex = app.currentAttractionIndex < attractionModel.count - 1
                        ? app.currentAttractionIndex + 1
                        : 0;
            }
        }
    }


    // Attraction View Component 2
    Component {
        id: attractionViewComponent2

        Rectangle {
            anchors.fill: parent
            color: "#050f0e"

            ListView {
                id: attractionList
                anchors.fill: parent
                anchors.margins: 2
                model: attractionModel
                clip: true
                spacing: 0

                // ── SCROLLABLE HEADER ─────────────────────────────────────
                header: Item {
                    width: parent.width
                    height: headerCol.height

                    Column {
                        id: headerCol
                        width: parent.width

                        // ── Title + flag block ─────────────────────────────
                        Rectangle {
                            width: parent.width
                            height: listTitle.height + listFlag.height + 12
                            color: "white"

                            Text {
                                id: listTitle
                                anchors.top: parent.top
                                anchors.topMargin: 4
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: app.selectedLanguage === "sw"
                                      ? "<font color=\"green\">Utalii wa Tanzania</font>"
                                      : "<font color=\"blue\">Tanzania Tourism</font>"
                                font.pointSize: Qt.platform.os === "android" ? 16 : 14
                                font.bold: true
                                textFormat: Text.RichText
                            }

                            AnimatedImage {
                                id: listFlag
                                source: "./tzflag.gif"
                                anchors.top: listTitle.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        // ── Search bar ─────────────────────────────────────
                        Rectangle {
                            width: parent.width
                            height: searchBarBg.height + 12
                            color: "#050f0e"

                            Rectangle {
                                id: searchBarBg
                                anchors.centerIn: parent
                                width: parent.width * 0.92
                                height: searchField.implicitHeight + 10
                                color: "#1a2a2a"
                                radius: 6
                                border.color: "cyan"
                                border.width: 1

                                TextField {
                                    id: searchField
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.right: clearBtn.left
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 4
                                    placeholderText: app.selectedLanguage === "sw" ? "Tafuta..." : "Search..."
                                    font.pointSize: Qt.platform.os === "android" ? 13 : 11
                                    color: "white"
                                    placeholderTextColor: "#888888"
                                    background: Rectangle { color: "transparent" }
                                    onTextChanged: app.searchText = text.toLowerCase()
                                }

                                Text {
                                    id: clearBtn
                                    anchors.right: parent.right
                                    anchors.rightMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "X"
                                    color: searchField.text.length > 0 ? "cyan" : "#555555"
                                    font.pixelSize: 16
                                    font.bold: true
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: { searchField.text = ""; app.searchText = ""; }
                                    }
                                }
                            }
                        }

                        // ── Category filter chips ──────────────────────────
                        Rectangle {
                            width: parent.width
                            height: filterRow.height + 12
                            color: "#050f0e"

                            Flickable {
                                anchors.centerIn: parent
                                width: parent.width
                                height: filterRow.height
                                contentWidth: filterRow.width + 24
                                clip: true

                                Row {
                                    id: filterRow
                                    x: 12
                                    spacing: 8

                                    Repeater {
                                        model: [
                                            { key: "All",       label_en: "All",       label_sw: "Zote",       icon: "🌍" },
                                            { key: "Parks",     label_en: "Parks",     label_sw: "Hifadhi",    icon: "🦁" },
                                            { key: "Coast",     label_en: "Coast",     label_sw: "Pwani",      icon: "🌊" },
                                            { key: "Mountains", label_en: "Mountains", label_sw: "Milima",     icon: "🏔" },
                                            { key: "Falls",     label_en: "Falls",     label_sw: "Maporomoko", icon: "💧" },
                                            { key: "Culture",   label_en: "Culture",   label_sw: "Utamaduni",  icon: "🏛" },
                                            { key: "Food",      label_en: "Food",      label_sw: "Chakula",    icon: "🍽" }
                                        ]

                                        Rectangle {
                                            height: Qt.platform.os === "android" ? 36 : 28
                                            width: chipRow.width + 18
                                            radius: height / 2
                                            color: app.activeFilter === modelData.key ? (app.selectedLanguage === "sw" ? "green" : "blue") : "#1a2a2a"
                                            border.color: app.activeFilter === modelData.key ? "transparent" : "#33ffffff"
                                            border.width: 1

                                            Row {
                                                id: chipRow
                                                anchors.centerIn: parent
                                                spacing: 4
                                                Text {
                                                    text: modelData.icon
                                                    font.pointSize: Qt.platform.os === "android" ? 12 : 10
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                                Text {
                                                    text: app.selectedLanguage === "sw" ? modelData.label_sw : modelData.label_en
                                                    font.pointSize: Qt.platform.os === "android" ? 11 : 9
                                                    font.bold: app.activeFilter === modelData.key
                                                    color: "white"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: app.activeFilter = modelData.key
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // ── Recently viewed row ────────────────────────────
                        Rectangle {
                            width: parent.width
                            height: app.recentlyViewed.length > 0 ? recentCol.height + 12 : 0
                            color: "#050f0e"
                            visible: app.recentlyViewed.length > 0
                            clip: true

                            Column {
                                id: recentCol
                                anchors.top: parent.top
                                anchors.topMargin: 6
                                width: parent.width
                                spacing: 4

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: app.selectedLanguage === "sw" ? "🕐 Uliyoona Hivi Karibuni" : "🕐 Recently Viewed"
                                    font.pointSize: Qt.platform.os === "android" ? 11 : 9
                                    font.bold: true
                                    color: "cyan"
                                }

                                Row {
                                    id: recentRow
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    height: Qt.platform.os === "android" ? 64 : 50
                                    spacing: 8

                                    Repeater {
                                        model: app.recentlyViewed

                                        Rectangle {
                                            width: Qt.platform.os === "android" ? 90 : 72
                                            height: Qt.platform.os === "android" ? 64 : 50
                                            radius: 8
                                            color: "#1a2a2a"
                                            border.color: "#33ffffff"
                                            border.width: 1
                                            clip: true

                                            property var attraction: attractionModel.get(modelData)

                                            Image {
                                                anchors.fill: parent
                                                source: attraction ? attraction.imageFile : ""
                                                fillMode: Image.PreserveAspectCrop
                                                opacity: 0.6
                                            }

                                            Text {
                                                anchors.bottom: parent.bottom
                                                anchors.bottomMargin: 3
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                anchors.leftMargin: 3
                                                anchors.rightMargin: 3
                                                text: attraction ? (app.selectedLanguage === "en" ? attraction.name_en : attraction.name_sw) : ""
                                                font.pointSize: Qt.platform.os === "android" ? 8 : 6
                                                color: "white"
                                                wrapMode: Text.WordWrap
                                                maximumLineCount: 2
                                                elide: Text.ElideRight
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    var a = attractionModel.get(modelData);
                                                    if (a) {
                                                        contextMenu.doOpen(
                                                                    app.selectedLanguage,
                                                                    app.selectedLanguage === "en" ? a.name_en : a.name_sw,
                                                                    app.selectedLanguage === "en" ? a.desc_en : a.desc_sw,
                                                                    a.imageFile,
                                                                    modelData
                                                                    );
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // ── Count text ─────────────────────────────────────
                        Rectangle {
                            width: parent.width
                            height: countText.height + 8
                            color: "#050f0e"

                            Text {
                                id: countText
                                anchors.centerIn: parent
                                font.pointSize: Qt.platform.os === "android" ? 12 : 10
                                font.bold: true
                                color: foundCount > 0 ? "#006600" : "red"

                                property int foundCount: {
                                    var c = 0;
                                    var s = app.searchText;
                                    var af = app.activeFilter;
                                    for (var i = 0; i < attractionModel.count; i++) {
                                        var item = attractionModel.get(i);
                                        var n = app.selectedLanguage === "en" ? item.name_en : item.name_sw;
                                        var d = app.selectedLanguage === "en" ? item.desc_en : item.desc_sw;
                                        var nameL = item.name_en.toLowerCase();
                                        var descL = item.desc_en.toLowerCase();

                                        var textMatch = s === "" || n.toLowerCase().indexOf(s) !== -1 || d.toLowerCase().indexOf(s) !== -1;

                                        var filterMatch = true;
                                        if (af !== "All") {
                                            if      (af === "Parks")     filterMatch = nameL.indexOf("park") !== -1 || nameL.indexOf("reserve") !== -1 || nameL.indexOf("conservation") !== -1;
                                            else if (af === "Coast")     filterMatch = nameL.indexOf("beach") !== -1 || nameL.indexOf("island") !== -1 || nameL.indexOf("marine") !== -1 || nameL.indexOf("zanzibar") !== -1 || descL.indexOf("ocean") !== -1 || descL.indexOf("coast") !== -1;
                                            else if (af === "Mountains") filterMatch = nameL.indexOf("mountain") !== -1 || nameL.indexOf("mount") !== -1 || nameL.indexOf("kilimanjaro") !== -1 || nameL.indexOf("peak") !== -1 || nameL.indexOf("view point") !== -1;
                                            else if (af === "Falls")     filterMatch = nameL.indexOf("falls") !== -1 || nameL.indexOf("waterfall") !== -1;
                                            else if (af === "Culture")   filterMatch = nameL.indexOf("museum") !== -1 || nameL.indexOf("cathedral") !== -1 || nameL.indexOf("art") !== -1 || nameL.indexOf("culture") !== -1 || nameL.indexOf("rock") !== -1 || nameL.indexOf("boma") !== -1 || nameL.indexOf("ruins") !== -1 || nameL.indexOf("cave") !== -1 || nameL.indexOf("house") !== -1 || nameL.indexOf("kanga") !== -1;
                                            else if (af === "Food")      filterMatch = descL.indexOf("food") !== -1 || descL.indexOf("fish") !== -1 || descL.indexOf("cuisine") !== -1 || nameL.indexOf("taste") !== -1 || nameL.indexOf("dagaa") !== -1;
                                        }

                                        if (textMatch && filterMatch) c++;
                                    }
                                    return c;
                                }

                                text: app.selectedLanguage === "sw"
                                      ? (app.searchText === "" && app.activeFilter === "All" ? "Vivutio: " + foundCount : "Vimepatikana: " + foundCount)
                                      : (app.searchText === "" && app.activeFilter === "All" ? "Attractions: " + foundCount : "Found: " + foundCount)
                            }
                        }
                    }
                } // end header

                // ── DELEGATE (Card Style with Animations) ─────────────────
                delegate: Item {
                    id: delegateWrapper
                    width: parent.width
                    property bool matchesSearch: {
                        var s = app.searchText;
                        var n = app.selectedLanguage === "en" ? name_en : name_sw;
                        var d = app.selectedLanguage === "en" ? desc_en : desc_sw;
                        var textMatch = s === "" || n.toLowerCase().indexOf(s) !== -1 || d.toLowerCase().indexOf(s) !== -1;

                        // Category filter
                        var af = app.activeFilter;
                        var filterMatch = true;
                        if (af !== "All") {
                            var nameL = name_en.toLowerCase();
                            var descL = desc_en.toLowerCase();
                            if      (af === "Parks")     filterMatch = nameL.indexOf("park") !== -1 || nameL.indexOf("reserve") !== -1 || nameL.indexOf("conservation") !== -1;
                            else if (af === "Coast")     filterMatch = nameL.indexOf("beach") !== -1 || nameL.indexOf("island") !== -1 || nameL.indexOf("marine") !== -1 || nameL.indexOf("zanzibar") !== -1 || descL.indexOf("ocean") !== -1 || descL.indexOf("coast") !== -1;
                            else if (af === "Mountains") filterMatch = nameL.indexOf("mountain") !== -1 || nameL.indexOf("mount") !== -1 || nameL.indexOf("kilimanjaro") !== -1 || nameL.indexOf("peak") !== -1 || nameL.indexOf("view point") !== -1;
                            else if (af === "Falls")     filterMatch = nameL.indexOf("falls") !== -1 || nameL.indexOf("waterfall") !== -1;
                            else if (af === "Culture")   filterMatch = nameL.indexOf("museum") !== -1 || nameL.indexOf("cathedral") !== -1 || nameL.indexOf("art") !== -1 || nameL.indexOf("culture") !== -1 || nameL.indexOf("rock") !== -1 || nameL.indexOf("boma") !== -1 || nameL.indexOf("ruins") !== -1 || nameL.indexOf("cave") !== -1 || nameL.indexOf("house") !== -1 || nameL.indexOf("kanga") !== -1;
                            else if (af === "Food")      filterMatch = descL.indexOf("food") !== -1 || descL.indexOf("fish") !== -1 || descL.indexOf("cuisine") !== -1 || nameL.indexOf("taste") !== -1 || nameL.indexOf("dagaa") !== -1;
                        }
                        return textMatch && filterMatch;
                    }
                    height: matchesSearch ? (card.height + 12
                                             + (visibleRank === 1 ? (adLoader.visible && adLoader.item ? adLoader.item.height + 8 : 0) : 0)) : 0
                    visible: matchesSearch
                    clip: true

                    property string attrName: app.selectedLanguage === "en" ? name_en : name_sw
                    property string attrDesc: app.selectedLanguage === "en" ? desc_en : desc_sw
                    property string attrPath: imageFile

                    // Compute how many visible items come before this one
                    property int visibleRank: {
                        var s = app.searchText;
                        var af = app.activeFilter;
                        var c = 0;
                        for (var i = 0; i < index; i++) {
                            var item = attractionModel.get(i);
                            var n = app.selectedLanguage === "en" ? item.name_en : item.name_sw;
                            var d = app.selectedLanguage === "en" ? item.desc_en : item.desc_sw;
                            var nL = item.name_en.toLowerCase();
                            var dL = item.desc_en.toLowerCase();
                            var tm = s === "" || n.toLowerCase().indexOf(s) !== -1 || d.toLowerCase().indexOf(s) !== -1;
                            var fm = true;
                            if (af !== "All") {
                                if      (af === "Parks")     fm = nL.indexOf("park") !== -1 || nL.indexOf("reserve") !== -1 || nL.indexOf("conservation") !== -1;
                                else if (af === "Coast")     fm = nL.indexOf("beach") !== -1 || nL.indexOf("island") !== -1 || nL.indexOf("marine") !== -1 || nL.indexOf("zanzibar") !== -1 || dL.indexOf("ocean") !== -1 || dL.indexOf("coast") !== -1;
                                else if (af === "Mountains") fm = nL.indexOf("mountain") !== -1 || nL.indexOf("mount") !== -1 || nL.indexOf("kilimanjaro") !== -1 || nL.indexOf("peak") !== -1 || nL.indexOf("view point") !== -1;
                                else if (af === "Falls")     fm = nL.indexOf("falls") !== -1 || nL.indexOf("waterfall") !== -1;
                                else if (af === "Culture")   fm = nL.indexOf("museum") !== -1 || nL.indexOf("cathedral") !== -1 || nL.indexOf("art") !== -1 || nL.indexOf("culture") !== -1 || nL.indexOf("rock") !== -1 || nL.indexOf("boma") !== -1 || nL.indexOf("ruins") !== -1 || nL.indexOf("cave") !== -1 || nL.indexOf("house") !== -1 || nL.indexOf("kanga") !== -1;
                                else if (af === "Food")      fm = dL.indexOf("food") !== -1 || dL.indexOf("fish") !== -1 || dL.indexOf("cuisine") !== -1 || nL.indexOf("taste") !== -1 || nL.indexOf("dagaa") !== -1;
                            }
                            if (tm && fm) c++;
                        }
                        return c;
                    }

                    // ── Slide-in + fade-in entrance animation ──────────────
                    transform: Translate { id: slideTranslate; x: -40 }

                    Component.onCompleted: {
                        slideAnim.start();
                    }

                    SequentialAnimation {
                        id: slideAnim
                        PauseAnimation { duration: Math.min(index * 40, 600) }
                        ParallelAnimation {
                            NumberAnimation {
                                target: delegateWrapper
                                property: "opacity"
                                from: 0; to: 1
                                duration: 320
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: slideTranslate
                                property: "x"
                                from: -40; to: 0
                                duration: 320
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    // ── Card body ──────────────────────────────────────────
                    Rectangle {
                        id: card
                        width: parent.width - 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 6

                        // Auto-size to content
                        height: cardNumberBadge.height + 8 + cardImgWrapper.height + 8 + divider.height + 8 + cardTextCol.height + 16

                        radius: 10
                        clip: true

                        // Card background: dark teal gradient using existing palette
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#1a2a2a" }
                            GradientStop { position: 1.0; color: "#001413" }
                        }

                        // Cyan border (existing accent color)
                        border.color: "cyan"
                        border.width: 1

                        // Subtle drop-shadow layer
                        layer.enabled: true

                        // ── Press / hover scale animation ─────────────────
                        property bool pressed: false
                        scale: pressed ? 0.97 : 1.0
                        Behavior on scale {
                            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed:  card.pressed = true
                            onReleased: card.pressed = false
                            onCanceled: card.pressed = false
                            onClicked: {
                                app.addRecentlyViewed(index);
                                contextMenu.doOpen(
                                            app.selectedLanguage,
                                            delegateWrapper.attrName,
                                            delegateWrapper.attrDesc,
                                            delegateWrapper.attrPath,
                                            index
                                            );
                            }
                        }

                        // ── Number badge (top-left corner) ─────────────────
                        Rectangle {
                            id: cardNumberBadge
                            anchors.top: parent.top
                            anchors.topMargin: 8
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            width: badgeText.implicitWidth + 14
                            height: badgeText.implicitHeight + 6
                            radius: 4
                            color: app.selectedLanguage === "sw" ? "green" : "blue"

                            Text {
                                id: badgeText
                                anchors.centerIn: parent
                                text: "#" + (index + 1)
                                font.pointSize: Qt.platform.os === "android" ? 11 : 9
                                font.bold: true
                                color: "white"
                            }
                        }

                        // ── Attraction image ───────────────────────────────
                        Item {
                            id: cardImgWrapper
                            anchors.top: cardNumberBadge.bottom
                            anchors.topMargin: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width - 16
                            height: width * 0.56

                            // Skeleton shimmer (shown while image loads)
                            Rectangle {
                                id: skeleton
                                anchors.fill: parent
                                radius: 6
                                color: "#1a2a2a"
                                visible: cardImg.status !== Image.Ready

                                // Shimmer sweep
                                Rectangle {
                                    id: shimmer
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: parent.width * 0.35
                                    x: -width
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "transparent" }
                                        GradientStop { position: 0.5; color: "#18ffffff" }
                                        GradientStop { position: 1.0; color: "transparent" }
                                    }

                                    NumberAnimation on x {
                                        from: -shimmer.width
                                        to: skeleton.width
                                        duration: 1200
                                        loops: Animation.Infinite
                                        easing.type: Easing.InOutSine
                                        running: skeleton.visible
                                    }
                                }

                                // Skeleton content lines
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    opacity: 0.3

                                    Rectangle { width: 60; height: 60; radius: 30; color: "#44ffffff"; anchors.horizontalCenter: parent.horizontalCenter }
                                    Rectangle { width: 80; height: 8; radius: 4; color: "#44ffffff"; anchors.horizontalCenter: parent.horizontalCenter }
                                    Rectangle { width: 55; height: 6; radius: 3; color: "#44ffffff"; anchors.horizontalCenter: parent.horizontalCenter }
                                }
                            }

                            Image {
                                id: cardImg
                                anchors.fill: parent
                                source: delegateWrapper.attrPath
                                fillMode: Image.PreserveAspectCrop
                                layer.enabled: true
                                opacity: cardImg.status === Image.Ready ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    radius: 6
                                }
                            }
                        }

                        // ── Thin cyan divider line ─────────────────────────
                        Rectangle {
                            id: divider
                            anchors.top: cardImgWrapper.bottom
                            anchors.topMargin: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width - 20
                            height: 1
                            color: "cyan"
                            opacity: 0.4
                        }

                        // ── Text column (title + description) ─────────────
                        Column {
                            id: cardTextCol
                            anchors.top: divider.bottom
                            anchors.topMargin: 8
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 6

                            Text {
                                id: cardTitle
                                width: parent.width
                                text: delegateWrapper.attrName
                                font.pointSize: Qt.platform.os === "android" ? 14 : 12
                                font.bold: true
                                color: "cyan"
                                wrapMode: Text.WordWrap
                                textFormat: Text.PlainText
                            }

                            Text {
                                id: cardDesc
                                width: parent.width
                                text: delegateWrapper.attrDesc
                                font.pointSize: Qt.platform.os === "android" ? 12 : 10
                                color: "#e0e0e0"
                                wrapMode: Text.WordWrap
                                textFormat: Text.PlainText
                            }

                            // Spacer at the bottom of the column
                            Item { width: 1; height: 4 }
                        }
                    } // end card Rectangle

                    // ── Ad Loader ──────────────────────────────────────────
                    Loader {
                        id: adLoader
                        property int adIdx: delegateWrapper.visibleRank === 1
                                            ? app.pickAd(app.selectedLanguage) : -1
                        visible: adIdx >= 0
                        width: parent.width - 12
                        height: visible && item ? item.height : 0
                        anchors.top: card.bottom
                        anchors.topMargin: visible ? 8 : 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        sourceComponent: adIdx >= 0 ? app.adsPool[adIdx] : null
                    }

                } // end delegateWrapper Item



            } // end ListView

            // ── Floating Back Button (always visible) ──────────────────
            Rectangle {
                id: floatingBackBtn
                z: 20
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.bottomMargin: 16
                anchors.rightMargin: 16
                width: floatingBtnText.implicitWidth + 16
                height: Qt.platform.os === "android" ? 36 : 26
                radius: height / 2
                property color frozenColor: app.selectedLanguage === "sw" ? "green" : "blue"
                color: frozenColor
                opacity: 0.85

                Text {
                    id: floatingBtnText
                    anchors.centerIn: parent
                    text: app.selectedLanguage === "sw" ? "← Rudi" : "← Back"
                    color: "white"
                    font.pointSize: Qt.platform.os === "android" ? 10 : 8
                    font.bold: true
                }

                // Press scale animation
                property bool pressed: false
                scale: pressed ? 0.93 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed:  floatingBackBtn.pressed = true
                    onReleased: floatingBackBtn.pressed = false
                    onCanceled: floatingBackBtn.pressed = false
                    onClicked: {
                        floatingBackBtn.frozenColor = app.selectedLanguage === "sw" ? "green" : "blue";
                        app.searchText = "";
                        viewComponentLoader.switchTo(languageSelectionComponent, app.width / 2, app.height / 2);
                        app.selectedLanguage = "";
                    }
                }
            }

        } // end outer Rectangle
    } // end Component attractionViewComponent2


    // ════════════════════════════════════════════════════════════════════
    // ── Game Language Selection Dialog (same style as modeSelectionDialog) ──
    Item {
        id: gameLangDialog
        anchors.fill: parent
        visible: false
        z: 400

        property real tapX: 0
        property real tapY: 0

        function doOpen(tx, ty) {
            gameLangDialog.tapX = (tx !== undefined && tx > 0) ? tx : app.width / 2;
            gameLangDialog.tapY = (ty !== undefined && ty > 0) ? ty : app.height / 2;
            gameLangDialog.visible = true;
            gameLangPanel.opacity = 1;
            gameLangSlideAnim.start();
        }

        function close() {
            gameLangPanel.opacity = 0;
            gameLangDialog.visible = false;
        }

        // Dimmed backdrop
        Rectangle {
            anchors.fill: parent; color: "#cc000000"
            MouseArea { anchors.fill: parent }
        }

        // Panel — same style as modePanel
        Rectangle {
            id: gameLangPanel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: app.width * 0.92
            height: gameLangCol.height + 32
            radius: 16
            color: "#001413"
            border.color: "cyan"; border.width: 1
            transform: Translate { id: gameLangSlide; y: 60 }
            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            NumberAnimation { id: gameLangSlideAnim; target: gameLangSlide; property: "y"; from: 60; to: 0; duration: 280; easing.type: Easing.OutCubic }

            Column {
                id: gameLangCol
                anchors.top: parent.top; anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 32; spacing: 14

                // Title
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🎮 Mchezo wa Utalii"
                    color: "cyan"
                    font.pointSize: Qt.platform.os === "android" ? 15 : 13
                    font.bold: true
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Tourism Memory Game"
                    color: "#aaaaaa"
                    font.pointSize: Qt.platform.os === "android" ? 11 : 9
                }

                // Cyan divider
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.4; height: 2; radius: 1; color: "cyan"; opacity: 0.5
                }

                // Kiswahili card
                Rectangle {
                    id: gameLangSwCard
                    width: parent.width
                    height: Qt.platform.os === "android" ? 90 : 72
                    radius: 12; color: "#0d2a28"; border.color: "green"; border.width: 2; clip: true
                    property bool pressed: false; scale: pressed ? 0.97 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    Row {
                        anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 16; spacing: 14
                        Rectangle { width: Qt.platform.os === "android" ? 52 : 42; height: width; radius: 10; color: "green"; anchors.verticalCenter: parent.verticalCenter
                            Text { anchors.centerIn: parent; text: "🇹🇿"; font.pointSize: Qt.platform.os === "android" ? 20 : 16 }
                        }
                        Column { anchors.verticalCenter: parent.verticalCenter; spacing: 3
                            Text { text: "Kiswahili"; font.pointSize: Qt.platform.os === "android" ? 14 : 12; font.bold: true; color: "white" }
                            Text { text: "Cheza kwa Kiswahili"; font.pointSize: Qt.platform.os === "android" ? 11 : 9; color: "#aaaaaa" }
                        }
                    }
                    Text { anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter; text: "›"; font.pointSize: Qt.platform.os === "android" ? 22 : 18; font.bold: true; color: "green" }
                    MouseArea {
                        anchors.fill: parent
                        onPressed:  gameLangSwCard.pressed = true
                        onReleased: {
                            gameLangSwCard.pressed = false;
                            app.gameLang = "sw";
                            gameLangDialog.close();
                            app.gameVisible = true;
                        }
                        onCanceled: gameLangSwCard.pressed = false
                    }
                }

                // English card
                Rectangle {
                    id: gameLangEnCard
                    width: parent.width
                    height: Qt.platform.os === "android" ? 90 : 72
                    radius: 12; color: "#0d2a28"; border.color: "blue"; border.width: 2; clip: true
                    property bool pressed: false; scale: pressed ? 0.97 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    Row {
                        anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 16; spacing: 14
                        Rectangle { width: Qt.platform.os === "android" ? 52 : 42; height: width; radius: 10; color: "blue"; anchors.verticalCenter: parent.verticalCenter
                            Text { anchors.centerIn: parent; text: "🌐"; font.pointSize: Qt.platform.os === "android" ? 20 : 16 }
                        }
                        Column { anchors.verticalCenter: parent.verticalCenter; spacing: 3
                            Text { text: "English"; font.pointSize: Qt.platform.os === "android" ? 14 : 12; font.bold: true; color: "white" }
                            Text { text: "Play in English"; font.pointSize: Qt.platform.os === "android" ? 11 : 9; color: "#aaaaaa" }
                        }
                    }
                    Text { anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter; text: "›"; font.pointSize: Qt.platform.os === "android" ? 22 : 18; font.bold: true; color: "blue" }
                    MouseArea {
                        anchors.fill: parent
                        onPressed:  gameLangEnCard.pressed = true
                        onReleased: {
                            gameLangEnCard.pressed = false;
                            app.gameLang = "en";
                            gameLangDialog.close();
                            app.gameVisible = true;
                        }
                        onCanceled: gameLangEnCard.pressed = false
                    }
                }

                // Close button — same style as modeCloseBtn
                Rectangle {
                    id: gameLangCloseBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.5
                    height: Qt.platform.os === "android" ? 48 : 36
                    radius: height / 2; color: "#cc2200"
                    property bool pressed: false; scale: pressed ? 0.96 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    Text { anchors.centerIn: parent; text: "Funga / Close"; font.pointSize: Qt.platform.os === "android" ? 13 : 11; font.bold: true; color: "white" }
                    MouseArea {
                        anchors.fill: parent
                        onPressed:  gameLangCloseBtn.pressed = true
                        onReleased: { gameLangCloseBtn.pressed = false; gameLangDialog.close(); }
                        onCanceled: gameLangCloseBtn.pressed = false
                    }
                }

                Item { width: 1; height: 4 }
            }
        }
    }

    // MEMORY CARD GAME OVERLAY
    // ════════════════════════════════════════════════════════════════════
    Item {
        id: gameOverlay
        anchors.fill: parent
        visible: app.gameVisible
        z: 300

        Rectangle { anchors.fill: parent; color: "#001413" }

        // ── Full bank of all attractions ────────────────────────
        property var allPairs: [
            {id: 0, name_en:"Zanzibar", name_sw:"Zanzibar", img:"./zanzibar_st2.jpg"},
            {id: 1, name_en:"Kizimkazi Dolphins", name_sw:"Pomboo Kizimkazi", img:"./kizimkazi-d.jpeg"},
            {id: 2, name_en:"Lake Victoria", name_sw:"Ziwa Victoria", img:"./victoria.jpg"},
            {id: 3, name_en:"Mt. Kilimanjaro", name_sw:"Mlima Kilimanjaro", img:"./kilimanjaro.jpg"},
            {id: 4, name_en:"Mikumi NP", name_sw:"Hifadhi ya Mikumi", img:"./mikumi.jpg"},
            {id: 5, name_en:"Serengeti NP", name_sw:"Hifadhi ya Serengeti", img:"./serengeti.jpg"},
            {id: 6, name_en:"Ngorongoro", name_sw:"Hifadhi ya Ngorongoro", img:"./ngorongoro.jpg"},
            {id: 7, name_en:"Tarangire NP", name_sw:"Hifadhi ya Tarangire", img:"./tarangire.jpg"},
            {id: 8, name_en:"Lake Manyara NP", name_sw:"Ziwa Manyara", img:"./manyara.jpg"},
            {id: 9, name_en:"Rubondo Island NP", name_sw:"Kisiwa cha Rubondo", img:"./rubondo.jpg"},
            {id:10, name_en:"Nyerere NP", name_sw:"Hifadhi ya Nyerere", img:"./nyerere.jpg"},
            {id:11, name_en:"Ruaha NP", name_sw:"Hifadhi ya Ruaha", img:"./ruaha.jpg"},
            {id:12, name_en:"Mafia Island", name_sw:"Kisiwa cha Mafia", img:"./mafia_island.jpg"},
            {id:13, name_en:"Katavi NP", name_sw:"Hifadhi ya Katavi", img:"./katavi.jpg"},
            {id:14, name_en:"Olduvai Gorge", name_sw:"Bonde la Olduvai", img:"./olduvai.jpg"},
            {id:15, name_en:"Lake Tanganyika", name_sw:"Ziwa Tanganyika", img:"./kigoma.jpg"},
            {id:16, name_en:"Saadani NP", name_sw:"Hifadhi ya Saadani", img:"./saadani.jpg"},
            {id:17, name_en:"Amboni Caves", name_sw:"Mapango ya Amboni", img:"./amboni_caves.jpg"},
            {id:18, name_en:"Kitulo NP", name_sw:"Hifadhi ya Kitulo", img:"./kitulo.jpg"},
            {id:19, name_en:"Selous Reserve", name_sw:"Hifadhi ya Selous", img:"./selous.jpg"},
            {id:20, name_en:"Mkomazi NP", name_sw:"Hifadhi ya Mkomazi", img:"./mkomazi.jpg"},
            {id:21, name_en:"Kaporogwe Falls", name_sw:"Maporomoko Kaporogwe", img:"./kaporogwe_falls.jpeg"},
            {id:22, name_en:"Kalambo Falls", name_sw:"Maporomoko Kalambo", img:"./kalambo.jpeg"},
            {id:23, name_en:"Materuni Falls", name_sw:"Maporomoko Materuni", img:"./Materuni.jpg"},
            {id:24, name_en:"Sanje Falls", name_sw:"Maporomoko ya Sanje", img:"./sanje.jpg"},
            {id:25, name_en:"Udzungwa Mts NP", name_sw:"Milima ya Udzungwa", img:"./udzungwa.jpg"},
            {id:26, name_en:"Mt. Meru", name_sw:"Mlima Meru", img:"./meru.jpg"},
            {id:27, name_en:"Usambara Mts", name_sw:"Milima ya Usambara", img:"./usambara.jpg"},
            {id:28, name_en:"Mahale Mts NP", name_sw:"Milima ya Mahale", img:"./mahale.jpg"},
            {id:29, name_en:"Isimila Stone Age", name_sw:"Eneo la Isimila", img:"./isimila.jpg"},
            {id:30, name_en:"Lake Duluti", name_sw:"Ziwa Duluti", img:"./duluti.jpeg"},
            {id:31, name_en:"Lake Eyasi", name_sw:"Ziwa Eyasi", img:"./eyasi.jpeg"},
            {id:32, name_en:"Pemba Island", name_sw:"Kisiwa cha Pemba", img:"./Pemba-Island-2.jpg"},
            {id:33, name_en:"Lake Natron", name_sw:"Ziwa Natron", img:"./natron.jpg"},
            {id:34, name_en:"Bagamoyo", name_sw:"Bagamoyo", img:"./bagamoyo.jpg"},
            {id:35, name_en:"Kilwa Kisiwani", name_sw:"Magofu ya Kilwa", img:"./kilwa_ruins.jpg"},
            {id:36, name_en:"Kondoa Rock Art", name_sw:"Michoro ya Kondoa", img:"./kondoa.jpg"},
            {id:37, name_en:"Balloon Safari", name_sw:"Utalii wa Puto", img:"./serengeti_balloon.jpeg"},
            {id:38, name_en:"Matema Beach", name_sw:"Ufukwe wa Matema", img:"./matema.jpeg"},
            {id:39, name_en:"Nyerere Museum", name_sw:"Makumbusho ya Nyerere", img:"./nyerere.jpeg"}
        ]
        // ── Active 8 pairs for current round (selected randomly) ────
        property var pairs:    []
        property var shuffled: []
        property var flipped:  []
        property var matched:  []
        property int  firstPick:  -1
        property int  secondPick: -1
        property bool busy:       false
        property int  moves:      0
        property bool gameWon:    false
        property bool showInstr:  true
        property real score:      0
        property bool showMatchAnim: false
        property bool showMissAnim:  false

        function shuffleArr(arr) {
            var a = arr.slice();
            for (var i = a.length - 1; i > 0; i--) {
                var j = Math.floor(Math.random() * (i + 1));
                var tmp = a[i]; a[i] = a[j]; a[j] = tmp;
            }
            return a;
        }

        // Pick 8 random unique pairs from allPairs bank, then shuffle 16 cards
        function initGame() {
            // Step 1: pick 8 random indices from bank
            var bankIdx = [];
            for (var i = 0; i < allPairs.length; i++) { bankIdx.push(i); }
            bankIdx = shuffleArr(bankIdx);
            var chosen = [];
            for (var k = 0; k < 8; k++) {
                var p = allPairs[bankIdx[k]];
                chosen.push({id: k, name_en: p.name_en, name_sw: p.name_sw, img: p.img});
            }
            pairs = chosen;

            // Step 2: create 16 card indices (each pair appears twice)
            var idx = [];
            for (var j = 0; j < pairs.length * 2; j++) { idx.push(j); }
            shuffled  = shuffleArr(idx);
            flipped   = []; matched = [];
            firstPick  = -1; secondPick = -1;
            busy = false; moves = 0; gameWon = false; score = 0;
        }
        function cardFlipped(pos) {
            if (busy) return;
            if (flipped.indexOf(pos) !== -1) return;
            var pid = pairs[Math.floor(shuffled[pos] / 2)].id;
            if (matched.indexOf(pid) !== -1) return;
            var f = flipped.slice(); f.push(pos); flipped = f;
            if (firstPick === -1) {
                firstPick = pos;
            } else {
                secondPick = pos; moves = moves + 1; busy = true; matchTimer.start();
            }
        }
        function checkMatch() {
            var idA = pairs[Math.floor(shuffled[firstPick]  / 2)].id;
            var idB = pairs[Math.floor(shuffled[secondPick] / 2)].id;
            if (idA === idB) {
                score = Math.round((score + 12.5) * 10) / 10;
                showMatchAnim = true;
                matchAnimTimer.start();
                var m = matched.slice(); m.push(idA); matched = m;
                if (matched.length === pairs.length) {
                    gameWon = true;
                    app.ad();
                }
            } else {
                score = score - 3;
                showMissAnim = true;
                missAnimTimer.start();
                var f2 = flipped.slice();
                f2.splice(f2.indexOf(firstPick),  1);
                f2.splice(f2.indexOf(secondPick), 1);
                flipped = f2;
            }
            firstPick = -1; secondPick = -1; busy = false;
        }

        Timer { id: matchTimer;     interval: 900; repeat: false; onTriggered: gameOverlay.checkMatch() }
        Timer { id: matchAnimTimer; interval: 700; repeat: false; onTriggered: gameOverlay.showMatchAnim = false }
        Timer { id: missAnimTimer;  interval: 700; repeat: false; onTriggered: gameOverlay.showMissAnim  = false }
        Component.onCompleted: gameOverlay.initGame()
        onVisibleChanged: { if (visible) { gameOverlay.initGame(); gameOverlay.showInstr = true; } }

        // Header
        Rectangle {
            id: gameHeader
            anchors.top: parent.top; width: parent.width
            height: Qt.platform.os === "android" ? 56 : 44
            color: "#000d0c"
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: (app.gameLang === "sw" ? "green" : "blue"); opacity: 0.4 }
            Rectangle {
                id: gameBackBtn
                anchors.left: parent.left; anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: backBtnTxt.implicitWidth + 24
                height: Qt.platform.os === "android" ? 36 : 28; radius: height / 2
                color: gameBackMA.pressed
                       ? (app.gameLang === "sw" ? "#0a3a0a" : "#0a0a3a")
                       : (app.gameLang === "sw" ? "#003a00" : "#00003a")
                border.color: app.gameLang === "sw" ? "green" : "blue"; border.width: 1
                Behavior on color { ColorAnimation { duration: 100 } }
                Text {
                    id: backBtnTxt
                    anchors.centerIn: parent
                    text: app.gameLang === "sw" ? "<- Rudi" : "<- Back"
                    font.pointSize: Qt.platform.os === "android" ? 12 : 10
                    font.bold: true
                    color: app.gameLang === "sw" ? "green" : "blue"
                }
                MouseArea {
                    id: gameBackMA; anchors.fill: parent
                    onClicked: {
                        app.gameVisible = false;
                        app.selectedLanguage = app.gameLang; //for ripple color to be correct
                        viewComponentLoader.switchTo(languageSelectionComponent, gameBackBtn.x + gameBackBtn.width / 2, gameHeader.y + gameHeader.height / 2);
                        app.ad();
                        app.selectedLanguage = "";
                    }
                }
            }
            Text {
                anchors.centerIn: parent
                text: app.gameLang === "sw" ? "Mchezo wa Utalii" : "Tourism Memory Game"
                font.pointSize: Qt.platform.os === "android" ? 14 : 11; font.bold: true; color: "white"
            }
        }

        // Stats bar
        Rectangle {
            id: gameStats
            anchors.top: gameHeader.bottom; width: parent.width
            height: Qt.platform.os === "android" ? 40 : 32; color: "#000f0e"
            Row {
                anchors.centerIn: parent; spacing: Qt.platform.os === "android" ? 16 : 12
                Row { spacing: 4
                    Text { text: "\uD83C\uDFAF"; font.pointSize: Qt.platform.os === "android" ? 9 : 7; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: (app.gameLang === "sw" ? "Hatua: " : "Moves: ") + gameOverlay.moves; font.pointSize: Qt.platform.os === "android" ? 9 : 7; color: "white"; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                }
                Rectangle { width: 1; height: Qt.platform.os === "android" ? 20 : 16; color: "#33ffffff"; anchors.verticalCenter: parent.verticalCenter }
                Row { spacing: 4
                    Text { text: "\u2705"; font.pointSize: Qt.platform.os === "android" ? 9 : 7; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: gameOverlay.matched.length + "/" + gameOverlay.pairs.length; font.pointSize: Qt.platform.os === "android" ? 9 : 7; color: app.gameLang === "sw" ? "green" : "blue"; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                }
                Rectangle { width: 1; height: Qt.platform.os === "android" ? 20 : 16; color: "#33ffffff"; anchors.verticalCenter: parent.verticalCenter }
                Row { spacing: 4
                    Text { text: "\u2B50"; font.pointSize: Qt.platform.os === "android" ? 9 : 7; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: (app.gameLang === "sw" ? "Pointi: " : "Score: ") + Math.round(gameOverlay.score) + "/100"
                        font.pointSize: Qt.platform.os === "android" ? 9 : 7; font.bold: true; anchors.verticalCenter: parent.verticalCenter
                        color: gameOverlay.score >= 0 ? "#00ff88" : "#ff6666"
                    }
                }
            }
        }

        // ── Match / Miss floating indicators ──────────────────────────
        Item {
            anchors.fill: parent
            z: 10
            // +12.5 green flash
            Rectangle {
                anchors.centerIn: parent
                width: matchPopTxt.implicitWidth + Math.round(24)
                height: Math.round(Qt.platform.os === "android" ? 44 : 34)
                radius: height / 2
                color: "#cc003300"
                border.color: "#00ff88"; border.width: 2
                visible: gameOverlay.showMatchAnim
                opacity: gameOverlay.showMatchAnim ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                anchors.verticalCenterOffset: gameOverlay.showMatchAnim ? -Math.round(40) : 0
                Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                Text {
                    id: matchPopTxt
                    anchors.centerIn: parent
                    text: "+12.5 \uD83C\uDF89"
                    font.pointSize: Qt.platform.os === "android" ? 14 : 11
                    font.bold: true; color: "#00ff88"
                }
            }
            // -5 red flash
            Rectangle {
                anchors.centerIn: parent
                width: missPopTxt.implicitWidth + Math.round(24)
                height: Math.round(Qt.platform.os === "android" ? 44 : 34)
                radius: height / 2
                color: "#cc330000"
                border.color: "#ff4444"; border.width: 2
                visible: gameOverlay.showMissAnim
                opacity: gameOverlay.showMissAnim ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                anchors.verticalCenterOffset: gameOverlay.showMissAnim ? Math.round(40) : 0
                Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                Text {
                    id: missPopTxt
                    anchors.centerIn: parent
                    text: "-3 \uD83D\uDE15"
                    font.pointSize: Qt.platform.os === "android" ? 14 : 11
                    font.bold: true; color: "#ff4444"
                }
            }
        }

        // Card grid 4x4
        Grid {
            id: cardGrid
            anchors.top: gameStats.bottom; anchors.topMargin: Qt.platform.os === "android" ? 10 : 7
            anchors.bottom: parent.bottom; anchors.bottomMargin: Qt.platform.os === "android" ? 12 : 8
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - (Qt.platform.os === "android" ? 20 : 14)
            columns: 4; spacing: Qt.platform.os === "android" ? 8 : 5

            Repeater {
                model: 16
                delegate: Item {
                    id: cardItem
                    width:  (cardGrid.width  - 3 * cardGrid.spacing) / 4
                    height: (cardGrid.height - 3 * cardGrid.spacing) / 4
                    property int  pairId:   gameOverlay.shuffled.length > index ? gameOverlay.pairs[Math.floor(gameOverlay.shuffled[index] / 2)].id : -1
                    property var  pairData: gameOverlay.shuffled.length > index ? gameOverlay.pairs[Math.floor(gameOverlay.shuffled[index] / 2)] : null
                    property bool isFlipped: gameOverlay.flipped.indexOf(index) !== -1
                    property bool isMatched: pairId >= 0 && gameOverlay.matched.indexOf(pairId) !== -1
                    property bool faceUp:    isFlipped || isMatched
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    // Bounce when matched
                    SequentialAnimation on scale {
                        running: cardItem.isMatched && gameOverlay.showMatchAnim
                        NumberAnimation { to: 1.12; duration: 120; easing.type: Easing.OutQuad }
                        NumberAnimation { to: 1.0;  duration: 120; easing.type: Easing.InQuad  }
                    }

                    // Back face
                    Rectangle {
                        width: parent.width * 0.93
                        height: parent.height * 0.9
                        radius: Qt.platform.os === "android" ? 8 : 5
                        color: "#0d2a28"; border.color: (app.gameLang === "sw" ? "green" : "blue"); border.width: 1
                        visible: !cardItem.faceUp; layer.enabled: true
                        Column { anchors.centerIn: parent; spacing: 2
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "🇹🇿"; font.pointSize: Qt.platform.os === "android" ? 16 : 12 }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: app.gameLang === "sw" ? "Utalii" : "Tourism"; font.pointSize: Qt.platform.os === "android" ? 9 : 7; font.bold: true; color: (app.gameLang === "sw" ? "green" : "blue"); font.letterSpacing: 2 }
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom;
                            anchors.left: parent.left;
                            anchors.right: parent.right;
                            height: 2;
                            radius: 5;
                            color: (app.gameLang === "sw" ? "green" : "blue");
                            opacity: 0.5
                        }
                        MouseArea {
                            anchors.fill: parent
                            onPressed:  cardItem.scale = 0.92
                            onReleased: { cardItem.scale = 1.0; if (!gameOverlay.gameWon) gameOverlay.cardFlipped(index); }
                            onCanceled: cardItem.scale = 1.0
                        }
                    }

                    // Front face
                    Rectangle {
                        width: parent.width * 0.93
                        height: parent.height * 0.9
                        radius: Qt.platform.os === "android" ? 8 : 5
                        color: cardItem.isMatched ? "#0a2a14" : "#0d1f1e"
                        border.color: cardItem.isMatched ? "#00ff88" : "cyan"
                        border.width: cardItem.isMatched ? 2 : 1
                        visible: cardItem.faceUp;
                        layer.enabled: true
                        clip: true

                        Column {
                            width: parent.width * 0.93
                            height: parent.height * 0.9
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 0
                            Image {
                                width: parent.width
                                height: parent.height * 0.60
                                fillMode: Image.PreserveAspectCrop;
                                smooth: true
                                source: cardItem.pairData ? cardItem.pairData.img : ""
                                opacity: cardItem.faceUp ? 1.0 : 0.0
                                Behavior on opacity { NumberAnimation { duration: 200 } }
                            }
                            Text {
                                width: parent.width
                                height: parent.height * 0.40
                                text: cardItem.pairData ? (app.gameLang === "sw" ? cardItem.pairData.name_sw : cardItem.pairData.name_en) : ""
                                font.pointSize: Qt.platform.os === "android" ? 7 : 5.5
                                font.bold: true; color: cardItem.isMatched ? "#00ff88" : "white"
                                wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                maximumLineCount: 2; elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            anchors.fill: parent; radius: parent.radius; color: "transparent"; border.color: "#00ff88"; border.width: 1
                            visible: cardItem.isMatched
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite; running: cardItem.isMatched
                                NumberAnimation { to: 0.1; duration: 900; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 0.7; duration: 900; easing.type: Easing.InOutSine }
                            }
                        }
                    }
                }
            }
        }

        // Instructions overlay
        Rectangle {
            anchors.fill: parent; color: Qt.rgba(0, 0.06, 0.06, 0.92)
            visible: gameOverlay.showInstr
            Column {
                anchors.centerIn: parent; width: parent.width - (Qt.platform.os === "android" ? 48 : 36); spacing: Qt.platform.os === "android" ? 14 : 10
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: app.gameLang === "sw" ? "Mchezo wa Kumbukumbu ya Utalii" : "Tourism Memory Game"
                    font.pointSize: Qt.platform.os === "android" ? 16 : 13; font.bold: true; color: (app.gameLang === "sw" ? "green" : "blue")
                    horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; width: parent.width
                }
                Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: parent.width * 0.7; height: 2; radius: 1; color: (app.gameLang === "sw" ? "green" : "blue"); opacity: 0.5 }
                Repeater {
                    model: app.gameLang === "sw"
                           ? ["1  Gusa card kuigeua", "2  Gusa nyingine kupata pair", "3  Zikifanana — zinabaki wazi \u2705, unapata pointi", "4  Hazifanani — zinarudi nyuma, unapoteza pointi", "5  Pata pairs 8 kushinda! \uD83C\uDFC6"]
                           : ["1  Tap a card to flip it", "2  Tap another to find a pair", "3  Match found — stays open \u2705, you gain points", "4  No match — cards flip back, you loose points", "5  Match all 8 pairs to win! \uD83C\uDFC6"]
                    delegate: Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData; font.pointSize: Qt.platform.os === "android" ? 12 : 10; color: "#cccccc"
                        wrapMode: Text.WordWrap; width: parent.width; horizontalAlignment: Text.AlignHCenter
                    }
                }
                Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: parent.width * 0.7; height: 1; radius: 1; color: (app.gameLang === "sw" ? "green" : "blue"); opacity: 0.3 }
                Rectangle {
                    id: instrStartBtn; anchors.horizontalCenter: parent.horizontalCenter
                    width: instrStartRow.implicitWidth + (Qt.platform.os === "android" ? 40 : 30)
                    height: Qt.platform.os === "android" ? 50 : 38; radius: height / 2
                    color: instrMA.pressed ? "#1a6060" : "#0d3a38"; border.color: (app.gameLang === "sw" ? "green" : "blue"); border.width: 2
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    Row { id: instrStartRow; anchors.centerIn: parent; spacing: 8
                        Text { text: "\uD83C\uDFAE"; font.pointSize: Qt.platform.os === "android" ? 16 : 13; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: app.gameLang === "sw" ? "Anza Mchezo" : "Start Game"; font.pointSize: Qt.platform.os === "android" ? 14 : 11; font.bold: true; color: (app.gameLang === "sw" ? "green" : "blue"); anchors.verticalCenter: parent.verticalCenter }
                    }
                    MouseArea { id: instrMA; anchors.fill: parent
                        onPressed:  instrStartBtn.scale = 0.95
                        onReleased: { instrStartBtn.scale = 1.0; gameOverlay.showInstr = false; }
                        onCanceled: instrStartBtn.scale = 1.0
                    }
                }
            }
        }

        // Win overlay
        Rectangle {
            anchors.fill: parent; color: Qt.rgba(0, 0.04, 0.04, 0.92)
            visible: gameOverlay.gameWon
            opacity: gameOverlay.gameWon ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 400 } }
            Column {
                anchors.centerIn: parent; spacing: Qt.platform.os === "android" ? 16 : 12
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter; text: "\uD83C\uDF89"
                    font.pointSize: Qt.platform.os === "android" ? 44 : 34
                    SequentialAnimation on scale {
                        loops: Animation.Infinite; running: gameOverlay.gameWon
                        NumberAnimation { to: 1.18; duration: 600; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0;  duration: 600; easing.type: Easing.InOutSine }
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: app.gameLang === "sw" ? "Hongera! Umeshinda!" : "Congratulations!"
                    font.pointSize: Qt.platform.os === "android" ? 22 : 18; font.bold: true; color: (app.gameLang === "sw" ? "green" : "blue")
                }
                // Stats summary
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: winStatsRow.implicitWidth + (Qt.platform.os === "android" ? 56 : 44)
                    height: Qt.platform.os === "android" ? 64 : 52
                    radius: 14; color: "#0d2a28"
                    border.color: app.gameLang === "sw" ? "green" : "blue"; border.width: 1
                    Row {
                        id: winStatsRow
                        anchors.centerIn: parent; spacing: Qt.platform.os === "android" ? 28 : 22
                        Column { spacing: 2
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "\uD83C\uDFAF"; font.pointSize: Qt.platform.os === "android" ? 14 : 11 }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: gameOverlay.moves
                                font.pointSize: Qt.platform.os === "android" ? 13 : 10; font.bold: true; color: "white"
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: app.gameLang === "sw" ? "Hatua" : "Moves"
                                font.pointSize: Qt.platform.os === "android" ? 9 : 7; color: "#aaaaaa"
                            }
                        }
                        Rectangle { width: 1; height: Qt.platform.os === "android" ? 36 : 28; color: "#33ffffff"; anchors.verticalCenter: parent.verticalCenter }
                        Column { spacing: 2
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "\u2B50"; font.pointSize: Qt.platform.os === "android" ? 14 : 11 }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Math.round(gameOverlay.score) + "/100"
                                font.pointSize: Qt.platform.os === "android" ? 13 : 10; font.bold: true
                                color: gameOverlay.score >= 80 ? "#00ff88" : gameOverlay.score >= 50 ? "#f5c400" : gameOverlay.score >= 0 ? "white" : "#ff6666"
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: app.gameLang === "sw" ? "Pointi" : "Score"
                                font.pointSize: Qt.platform.os === "android" ? 9 : 7; color: "#aaaaaa"
                            }
                        }
                        Rectangle { width: 1; height: Qt.platform.os === "android" ? 36 : 28; color: "#33ffffff"; anchors.verticalCenter: parent.verticalCenter }
                        Column { spacing: 2
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "\uD83C\uDFC6"; font.pointSize: Qt.platform.os === "android" ? 14 : 11 }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: gameOverlay.score >= 100 ? (app.gameLang === "sw" ? "Bora!" : "Perfect!")
                                                               : gameOverlay.score >= 75  ? (app.gameLang === "sw" ? "Safi!" : "Great!")
                                                                                          : gameOverlay.score >= 50  ? (app.gameLang === "sw" ? "Vizuri" : "Good")
                                                                                                                     : gameOverlay.score >= 0   ? (app.gameLang === "sw" ? "Jaribu" : "Try+")
                                                                                                                                                :                            (app.gameLang === "sw" ? "Rudia" : "Retry")
                                font.pointSize: Qt.platform.os === "android" ? 13 : 10; font.bold: true
                                color: gameOverlay.score >= 75 ? "#00ff88" : gameOverlay.score >= 50 ? "#f5c400" : gameOverlay.score >= 0 ? "white" : "#ff6666"
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: app.gameLang === "sw" ? "Daraja" : "Grade"
                                font.pointSize: Qt.platform.os === "android" ? 9 : 7; color: "#aaaaaa"
                            }
                        }
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: gameOverlay.moves <= 12 ? (app.gameLang === "sw" ? "\u2B50 Bingwa wa Utalii!" : "\u2B50 Tourism Expert!")
                                                  : gameOverlay.moves <= 18 ? (app.gameLang === "sw" ? "\uD83D\uDC4D Vizuri sana!" : "\uD83D\uDC4D Well done!")
                                                                            : (app.gameLang === "sw" ? "\uD83D\uDE0A Jaribu tena!" : "\uD83D\uDE0A Try again!")
                    font.pointSize: Qt.platform.os === "android" ? 14 : 11; font.bold: true; color: "#00ff88"
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter; spacing: Qt.platform.os === "android" ? 14 : 10
                    Rectangle {
                        id: winRestartBtn
                        width: winRestartRow.implicitWidth + (Qt.platform.os === "android" ? 32 : 24)
                        height: Qt.platform.os === "android" ? 48 : 38; radius: height / 2
                        color: winRestartMA.pressed ? "#1a6060" : "#0d3a38"; border.color: (app.gameLang === "sw" ? "green" : "blue"); border.width: 2
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        Row { id: winRestartRow; anchors.centerIn: parent; spacing: 6
                            Text { text: "\uD83D\uDD04"; font.pointSize: Qt.platform.os === "android" ? 14 : 11; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: app.gameLang === "sw" ? "Cheza Tena" : "Play Again"; font.pointSize: Qt.platform.os === "android" ? 13 : 10; font.bold: true; color: (app.gameLang === "sw" ? "green" : "blue"); anchors.verticalCenter: parent.verticalCenter }
                        }
                        MouseArea { id: winRestartMA; anchors.fill: parent
                            onPressed:  winRestartBtn.scale = 0.95
                            onReleased: { winRestartBtn.scale = 1.0; gameOverlay.initGame(); }
                            onCanceled: winRestartBtn.scale = 1.0
                        }
                    }
                    Rectangle {
                        id: winBackBtn
                        width: winBackRow.implicitWidth + (Qt.platform.os === "android" ? 32 : 24)
                        height: Qt.platform.os === "android" ? 48 : 38; radius: height / 2
                        color: winBackMA.pressed ? "#2a0a0a" : "#1a0808"; border.color: "#cc4444"; border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        Row { id: winBackRow; anchors.centerIn: parent; spacing: 6
                            Text { text: "\uD83C\uDF0D"; font.pointSize: Qt.platform.os === "android" ? 14 : 11; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: app.gameLang === "sw" ? "Rudi Utalii" : "Back to App"; font.pointSize: Qt.platform.os === "android" ? 13 : 10; font.bold: true; color: "#ff8888"; anchors.verticalCenter: parent.verticalCenter }
                        }
                        MouseArea { id: winBackMA; anchors.fill: parent
                            onPressed:  winBackBtn.scale = 0.95
                            onReleased: {
                                winBackBtn.scale = 1.0;
                                app.gameVisible = false;
                                app.animateBackToFrontPage();
                            }
                            onCanceled: winBackBtn.scale = 1.0
                        }
                    }
                }
            }
        }
    }


    // ════════════════════════════════════════════════════════════════
    // TANZANIA ARTICLE OVERLAY — bilingual HTML article viewer
    // Improvements: slide-in animation, reading progress bar,
    // font-size controls, swipe-down to close, end-of-article
    // footer, enhanced back button.
    // ════════════════════════════════════════════════════════════════
    Rectangle {
        id: articleOverlay
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height
        color: "#001413"

        // ── [1] SLIDE-IN ANIMATION ─────────────────────────────────
        // Slides up from bottom when opened, slides back down when closed.
        property real slideY: app.articleViewVisible ? 0 : parent.height
        y: slideY
        Behavior on slideY { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

        visible: slideY < parent.height   // keep visible during slide-out
        opacity: app.articleViewVisible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 260 } }
        z: 180

        // ── Header bar ─────────────────────────────────────────────
        Rectangle {
            id: articleHeader
            width: parent.width
            height: Qt.platform.os === "android" ? 72 : 52
            color: "#001e1b"
            z: 10

            // Bottom border line
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 2
                color: app.articleLang === "sw" ? "#1eb53a" : "#00a3dd"
                Behavior on color { ColorAnimation { duration: 300 } }
            }

            // Flag + title column
            Row {
                id: articleHeaderLeft
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Qt.platform.os === "android" ? 12 : 10
                anchors.right: articleFontRow.left
                anchors.rightMargin: 6
                spacing: 8
                clip: true

                Text {
                    text: app.articleLang === "sw" ? "🇹🇿" : "🌍"
                    font.pointSize: Qt.platform.os === "android" ? 20 : 16
                    anchors.verticalCenter: parent.verticalCenter
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1
                    Text {
                        text: app.articleLang === "sw"
                              ? "Tanzania — Nchi Yetu Tukufu"
                              : "Tanzania — A Nation of Wonders"
                        font.bold: true
                        font.pointSize: Qt.platform.os === "android" ? 14 : 10
                        color: app.articleLang === "sw" ? "#1eb53a" : "#00c8ff"
                        Behavior on color { ColorAnimation { duration: 300 } }
                        elide: Text.ElideRight
                    }
                    Text {
                        text: app.articleLang === "sw"
                              ? "Makala · Habari za Tanzania"
                              : "Article · Tanzania Knowledge"
                        font.pointSize: Qt.platform.os === "android" ? 9 : 7
                        color: "#666666"
                    }
                }
            }

            // ── [2] FONT SIZE CONTROLS A− / A+ ─────────────────────
            Row {
                id: articleFontRow
                anchors.right: articleBackBtn.left
                anchors.rightMargin: Qt.platform.os === "android" ? 8 : 6
                anchors.verticalCenter: parent.verticalCenter
                spacing: Qt.platform.os === "android" ? 5 : 4

                Repeater {
                    model: ListModel {
                        ListElement { lbl: "A−"; delta: -0.15 }
                        ListElement { lbl: "A+"; delta: 0.15 }
                    }
                    delegate: Rectangle {
                        width: Qt.platform.os === "android" ? 52 : 34
                        height: Qt.platform.os === "android" ? 44 : 28
                        radius: Qt.platform.os === "android" ? 10 : 7
                        color: fontBtnMA.pressed ? "#0d3d22" : "#0a2218"
                        border.color: app.articleLang === "sw" ? "#1eb53a" : "#00a3dd"
                        border.width: 1.5
                        Behavior on color { ColorAnimation { duration: 100 } }

                        property real sc: 1.0
                        scale: sc
                        Behavior on sc { NumberAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: lbl
                            font.pixelSize: Qt.platform.os === "android" ? 17 : 11
                            font.bold: true
                            color: app.articleLang === "sw" ? "#1eb53a" : "#00c8ff"
                        }
                        MouseArea {
                            id: fontBtnMA
                            anchors.fill: parent
                            onPressed:  { parent.sc = 0.88; }
                            onReleased: {
                                parent.sc = 1.0;
                                var next = app.articleFontScale + delta;
                                app.articleFontScale = Math.max(0.7, Math.min(1.6, next));
                                articleFontSettings.scale = app.articleFontScale;
                                articleFontSettings.sync();
                            }
                            onCanceled: { parent.sc = 1.0; }
                        }
                    }
                }
            }

            // ── [IMPROVED] BACK BUTTON ─────────────────────────────
            // Larger tap target, chevron icon, gradient-feel border glow,
            // ripple scale + color press feedback.
            Rectangle {
                id: articleBackBtn
                anchors.right: parent.right
                anchors.rightMargin: Qt.platform.os === "android" ? 12 : 10
                anchors.verticalCenter: parent.verticalCenter
                width: Qt.platform.os === "android" ? 100 : 72
                height: Qt.platform.os === "android" ? 50 : 36
                radius: Qt.platform.os === "android" ? 25 : 18

                // Two-tone press feedback
                color: articleBackMA.pressed
                       ? (app.articleLang === "sw" ? "#163d22" : "#0e2248")
                       : (app.articleLang === "sw" ? "#0a2218" : "#0a1830")
                Behavior on color { ColorAnimation { duration: 100 } }

                border.color: articleBackMA.pressed
                              ? (app.articleLang === "sw" ? "#28e84a" : "#33d6ff")
                              : (app.articleLang === "sw" ? "#1eb53a" : "#00a3dd")
                border.width: 1.8
                Behavior on border.color { ColorAnimation { duration: 100 } }

                // Glow effect
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 0; verticalOffset: 0
                    radius: 10; samples: 21
                    color: app.articleLang === "sw" ? "#441eb53a" : "#4400a3dd"
                }

                property real sc: 1.0
                scale: sc
                Behavior on sc { NumberAnimation { duration: 110; easing.type: Easing.OutBack } }

                Row {
                    anchors.centerIn: parent
                    spacing: Qt.platform.os === "android" ? 5 : 4

                    // Chevron «
                    Text {
                        text: "‹"
                        font.pixelSize: Qt.platform.os === "android" ? 34 : 22
                        font.bold: true
                        color: app.articleLang === "sw" ? "#1eb53a" : "#00c8ff"
                        anchors.verticalCenter: parent.verticalCenter
                        // nudge vertically for optical alignment
                        anchors.topMargin: Qt.platform.os === "android" ? -2 : -1
                    }
                    Text {
                        text: app.articleLang === "sw" ? "Rudi" : "Back"
                        font.pixelSize: Qt.platform.os === "android" ? 18 : 12
                        font.bold: true
                        color: app.articleLang === "sw" ? "#1eb53a" : "#00c8ff"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: articleBackMA
                    anchors.fill: parent
                    onPressed:  { articleBackBtn.sc = 0.90; }
                    onReleased: {
                        articleBackBtn.sc = 1.0;
                        app.articleViewVisible = false;
                        app.articleLang = langSettings.lang;
                        articleWebView.scrollToTop();
                        app.animateBackToFrontPage();
                    }
                    onCanceled: { articleBackBtn.sc = 1.0; }
                }
            }
        }

        // ── [1] READING PROGRESS BAR ───────────────────────────────
        // Thin bar below header tracking how far the user has scrolled.
        Rectangle {
            id: readingProgressBar
            anchors.top: articleHeader.bottom
            anchors.left: parent.left
            height: 3
            z: 9

            property real progress: articleFlickable.contentHeight > articleFlickable.height
                                    ? Math.min(1.0, articleFlickable.contentY /
                                               (articleFlickable.contentHeight - articleFlickable.height))
                                    : 0.0

            width: articleOverlay.width * progress
            Behavior on width { NumberAnimation { duration: 80 } }

            color: app.articleLang === "sw" ? "#1eb53a" : "#00c8ff"
            Behavior on color { ColorAnimation { duration: 300 } }

            // Glowing right-edge dot
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 7; height: 7; radius: 3.5
                color: parent.color
                visible: readingProgressBar.width > 10
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 0; verticalOffset: 0
                    radius: 6; samples: 13
                    color: app.articleLang === "sw" ? "#881eb53a" : "#8800c8ff"
                }
            }
        }

        // ── Article content: scrollable HTML via Text RichText ─────
        Flickable {
            id: articleFlickable
            anchors.top: readingProgressBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            contentWidth: width
            contentHeight: articleWebView.implicitHeight + articleEndFooter.height + 24
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            // scroll-to-top helper
            function scrollToTop() {
                contentY = 0;
            }

            // Reset scroll when article changes
            Connections {
                target: app
                function onArticleLangChanged() {
                    articleFlickable.contentY = 0;
                }
            }

            // ── [3] SWIPE-DOWN TO CLOSE ────────────────────────────
            // Fast downward flick while at top of content → close overlay.
            onFlickStarted: {
                if (verticalVelocity > 900 && contentY <= 0) {
                    cancelFlick();
                    app.articleViewVisible = false;
                    app.articleLang = langSettings.lang;
                    articleWebView.scrollToTop();
                    app.animateBackToFrontPage();
                }
            }

            Text {
                id: articleWebView
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                color: "#e0f7f4"
                text: ""
                // ── [2] FONT SCALE applied here ────────────────────
                font.pixelSize: (Qt.platform.os === "android" ? 14 : 10) * app.articleFontScale
                Behavior on font.pixelSize { NumberAnimation { duration: 150 } }
                x: Qt.platform.os === "android" ? 12 : 8
                y: Qt.platform.os === "android" ? 10 : 6
                width: articleFlickable.width - (Qt.platform.os === "android" ? 24 : 16)

                function scrollToTop() {
                    articleScrollTopBtn.sc = 1.0;
                    articleFlickable.contentY = 0;
                }

                // Show content from QSettings cache; trigger background fetch if cache empty
                function showContent(lang) {
                    var cached = lang === "sw"
                            ? articleCacheSettings.htmlSw
                            : articleCacheSettings.htmlEn;

                    if (cached !== undefined && cached.trim() !== "") {
                        articleWebView.text = cached;
                    } else {
                        // no cache yet — show loading indicator, fetch in background
                        articleWebView.text = lang === "sw"
                                ? "<p style='color:#00e5cc;font-family:sans-serif;padding:24px;font-size:15px;'>⏳ Inapakia makala...</p>"
                                : "<p style='color:#00c8ff;font-family:sans-serif;padding:24px;font-size:15px;'>⏳ Loading article...</p>";
                        app.fetchArticle(lang);
                    }
                }

                // Trigger showContent when overlay opens or lang changes
                Connections {
                    target: app
                    function onArticleViewVisibleChanged() {
                        if (app.articleViewVisible && app.articleLang !== "") {
                            articleWebView.showContent(app.articleLang);
                        }
                    }
                    function onArticleLangChanged() {
                        if (app.articleViewVisible && app.articleLang !== "") {
                            articleWebView.showContent(app.articleLang);
                        }
                    }
                }
            }

            // ── [4] END-OF-ARTICLE FOOTER ──────────────────────────
            // Appears below article content when near the bottom.
            Item {
                id: articleEndFooter
                width: articleFlickable.width
                height: Qt.platform.os === "android" ? 64 : 52
                y: articleWebView.implicitHeight + 12

                // Divider line
                Rectangle {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.6
                    height: 1
                    color: app.articleLang === "sw" ? "#2a5a38" : "#1a3a55"
                }

                Text {
                    anchors.centerIn: parent
                    text: app.articleLang === "sw"
                          ? "*  Mwisho wa makala  *"
                          : "*  End of article  *"
                    font.pixelSize: Qt.platform.os === "android" ? 14 : 12
                    font.italic: true
                    color: app.articleLang === "sw" ? "#2a6e40" : "#1a5577"
                    Behavior on color { ColorAnimation { duration: 300 } }

                    opacity: {
                        var threshold = articleFlickable.contentHeight - articleFlickable.height - 60;
                        return articleFlickable.contentY >= threshold ? 1.0 : 0.0;
                    }
                    Behavior on opacity { NumberAnimation { duration: 350 } }
                }
            }
        }

        // ── Scroll-to-top FAB ──────────────────────────────────────
        Rectangle {
            id: articleScrollTopBtn
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: Qt.platform.os === "android" ? 22 : 18
            anchors.rightMargin: Qt.platform.os === "android" ? 16 : 12
            width: Qt.platform.os === "android" ? 48 : 40
            height: width; radius: width / 2
            color: scrollTopMA.pressed
                   ? (app.articleLang === "sw" ? "#0a3d1e" : "#0a2040")
                   : "#001e1b"
            border.color: app.articleLang === "sw" ? "#1eb53a" : "#00a3dd"
            border.width: 2
            visible: articleFlickable.contentY > 100
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 220 } }

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0; verticalOffset: 3
                radius: 14; samples: 29
                color: app.articleLang === "sw" ? "#661eb53a" : "#6600a3dd"
            }

            property real sc: 1.0
            scale: sc
            Behavior on sc { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

            Text {
                anchors.centerIn: parent
                text: "▲"
                font.pointSize: Qt.platform.os === "android" ? 14 : 11
                color: app.articleLang === "sw" ? "#1eb53a" : "#00c8ff"
            }

            MouseArea {
                id: scrollTopMA
                anchors.fill: parent
                onPressed:  { articleScrollTopBtn.sc = 0.86; }
                onReleased: {
                    articleScrollTopBtn.sc = 1.0;
                    articleFlickable.contentY = 0;
                }
                onCanceled: { articleScrollTopBtn.sc = 1.0; }
            }
        }
    }
    // ════════════════════════════════════════════════════════════════

    // ════════════════════════════════════════════════════════════════
    // RETRO 60s TV OVERLAY — Tanzania Safari Channel Live Player
    // Theme: #001413 bg · cyan accent · #0d3a38 cabinet · #1a6060 highlights
    // ════════════════════════════════════════════════════════════════
    Rectangle {
        id: safariTvOverlay
        anchors.fill: parent
        color: "#001413"
        visible: app.safariTvVisible
        opacity: app.safariTvVisible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 280 } }
        z: 200

        property bool tvFullScreen: false
        property real tvVolume: 1.0
        property bool streamError: false
        property string streamErrorMsg: ""
        property real tvBrightness: 1.0   // 1.0 = full, 0.2 = very dim
        property bool pipMode: false       // picture-in-picture

        onTvVolumeChanged: {
            safariPlayer.volume = tvVolume;
            volIconCanvas.requestPaint();
            fsVolIconCanvas.requestPaint();
        }

        onTvFullScreenChanged: {
            if (tvFullScreen) {
                fsLayer.videoRotation = Qt.platform.os === "android" ? 90 : 0;
                fsLayer.fsUiVisible = true;
                channelInfoCard.show();
                gestureHintsCard.showIfFirst();
            } else {
                fsLayer.videoRotation = 0;
            }
        }

        // ── Show screen-on tip once when TV opens ─────────────────
        onVisibleChanged: {
            if (visible && !app.wakeLockTipShown) {
                wakeLockTipDialog.open();
                app.wakeLockTipShown = true;
            }
        }

        // ── Screen-on tip dialog (shown once) ─────────────────────
        Rectangle {
            id: wakeLockTipDialog
            anchors.centerIn: parent
            width: Math.min(app.width * 0.85, Qt.platform.os === "android" ? 340 : 280)
            height: wakeLockTipCol.implicitHeight + (Qt.platform.os === "android" ? 40 : 30)
            radius: Qt.platform.os === "android" ? 18 : 14
            color: "#001f1d"
            border.color: "cyan"
            border.width: 2
            visible: false
            z: 300

            function open()  { wakeLockTipDialog.visible = true; }
            function close() { wakeLockTipDialog.visible = false; }

            // dim background
            Rectangle {
                anchors.fill: parent
                anchors.margins: -app.width
                color: Qt.rgba(0, 0, 0, 0.55)
                z: -1
                MouseArea { anchors.fill: parent; onClicked: {} }
            }

            Column {
                id: wakeLockTipCol
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Qt.platform.os === "android" ? 20 : 15
                width: parent.width - (Qt.platform.os === "android" ? 32 : 24)
                spacing: Qt.platform.os === "android" ? 12 : 9

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: langSettings.lang === "sw" ? "📺  Kidokezo" : "📺  Tip"
                    font.pointSize: Qt.platform.os === "android" ? 14 : 11
                    font.bold: true
                    color: "cyan"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    visible: langSettings.lang === "sw"
                    text: "Ili skrini isizimike wakati wa kutazama, nenda:\nMipangilio → Onyesho → Muda wa Kuzima Skrini\nna uchague Kamwe au muda mrefu zaidi."
                    font.pointSize: Qt.platform.os === "android" ? 11 : 9
                    color: "#cceeec"
                    lineHeight: 1.35
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    visible: langSettings.lang === "en"
                    text: "To keep the screen on during playback, go to:\nSettings → Display → Screen Timeout\nand set it to Never or the longest duration."
                    font.pointSize: Qt.platform.os === "android" ? 11 : 9
                    color: "#cceeec"
                    lineHeight: 1.35
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Qt.platform.os === "android" ? 120 : 96
                    height: Qt.platform.os === "android" ? 44 : 36
                    radius: height / 2
                    color: wakeLockOkMA.pressed ? "#1a6060" : "#0d3a38"
                    border.color: "cyan"; border.width: 2
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: langSettings.lang === "sw" ? "Sawa" : "OK"
                        font.pointSize: Qt.platform.os === "android" ? 12 : 10
                        font.bold: true
                        color: "cyan"
                    }
                    MouseArea {
                        id: wakeLockOkMA
                        anchors.fill: parent
                        onPressed:  parent.scale = 0.93
                        onReleased: { parent.scale = 1.0; wakeLockTipDialog.close(); }
                        onCanceled: parent.scale = 1.0
                    }
                }

                Item { width: 1; height: Qt.platform.os === "android" ? 4 : 2 }
            }
        }

        // ── Prevent clicks to reach the elements below
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        // ── Scanline canvas overlay (retro CRT effect) ─────────────
        Canvas {
            id: scanlineCanvas
            anchors.fill: parent
            z: 10
            opacity: 0.10

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = "#000000";
                ctx.lineWidth = 1;
                for (var y = 0; y < height; y += 3) {
                    ctx.beginPath();
                    ctx.moveTo(0, y);
                    ctx.lineTo(width, y);
                    ctx.stroke();
                }
            }
            Component.onCompleted: { requestPaint(); }
        }

        // ── Background gradient — matches app dark teal ────────────
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#001a18" }
                GradientStop { position: 0.5; color: "#001413" }
                GradientStop { position: 1.0; color: "#000d0c" }
            }
        }

        // ── Subtle teal texture lines ──────────────────────────────
        Column {
            anchors.fill: parent
            spacing: Qt.platform.os === "android" ? 22 : 18
            Repeater {
                model: 30
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Qt.rgba(0, 1, 0.8, 0.03 + (index % 3) * 0.02)
                }
            }
        }

        // ── Main TV cabinet ────────────────────────────────────────
        Column {
            anchors.fill: parent
            anchors.margins: Qt.platform.os === "android" ? 10 : 8
            spacing: 0
            visible: !safariTvOverlay.tvFullScreen

            // ── TOP antenna bar ────────────────────────────────────
            Item {
                width: parent.width
                height: Qt.platform.os === "android" ? 48 : 38

                // Left antenna
                Rectangle {
                    id: antennaLeft
                    width: 4; radius: 2
                    height: Qt.platform.os === "android" ? 44 : 34
                    color: "#1a6060"
                    anchors.bottom: parent.bottom
                    x: parent.width * 0.28

                    SequentialAnimation on rotation {
                        loops: Animation.Infinite
                        NumberAnimation { to: -6; duration: 3000; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0;  duration: 3000; easing.type: Easing.InOutSine }
                    }

                    Rectangle { width: 8; height: 8; radius: 4; color: "cyan"; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top }
                }

                // Right antenna
                Rectangle {
                    width: 4; radius: 2
                    height: Qt.platform.os === "android" ? 44 : 34
                    color: "#1a6060"
                    anchors.bottom: parent.bottom
                    x: parent.width * 0.68

                    SequentialAnimation on rotation {
                        loops: Animation.Infinite
                        NumberAnimation { to: 6;  duration: 3500; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0;  duration: 3500; easing.type: Easing.InOutSine }
                    }

                    Rectangle { width: 8; height: 8; radius: 4; color: "cyan"; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top }
                }

                // Antenna base bar
                Rectangle {
                    width: parent.width * 0.5; height: 6; radius: 3
                    color: "#0d3a38"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                }
            }

            // ── TV BODY ────────────────────────────────────────────
            Rectangle {
                id: tvBody
                width: parent.width
                height: parent.height - (Qt.platform.os === "android" ? 48 : 38)
                radius: Qt.platform.os === "android" ? 22 : 18
                color: "#0d2a28"

                border.color: "#1a6060"
                border.width: Qt.platform.os === "android" ? 6 : 5

                // Inner depth line
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 3
                    radius: parent.radius - 3
                    color: "transparent"
                    border.color: "#0a1f1e"
                    border.width: 2
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: Qt.platform.os === "android" ? 14 : 10
                    spacing: Qt.platform.os === "android" ? 10 : 8

                    // ── SCREEN AREA ────────────────────────────────
                    Rectangle {
                        id: tvScreen
                        width: parent.width
                        height: parent.height
                                - (Qt.platform.os === "android" ? 120 : 96)
                                - controlsRow.height
                        radius: Qt.platform.os === "android" ? 14 : 10

                        // Screen surround (dark bezel)
                        color: "#050f0e"
                        border.color: "#0d3a38"
                        border.width: Qt.platform.os === "android" ? 5 : 4

                        // CRT corner vignette
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Qt.rgba(0,0,0,0.4) }
                                GradientStop { position: 0.3; color: "transparent" }
                                GradientStop { position: 0.7; color: "transparent" }
                                GradientStop { position: 1.0; color: Qt.rgba(0,0,0,0.4) }
                            }
                            z: 5
                        }

                        // Channel label overlay — kisasa na gradient
                        Rectangle {
                            anchors.top: parent.top
                            anchors.topMargin: 8
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            width: chLabelRow.implicitWidth + 20
                            height: Qt.platform.os === "android" ? 30 : 24
                            radius: height / 2
                            z: 6
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Qt.rgba(0, 0.25, 0.22, 0.92) }
                                GradientStop { position: 1.0; color: Qt.rgba(0, 0.12, 0.10, 0.85) }
                            }
                            border.color: Qt.rgba(0, 1, 1, 0.5); border.width: 1

                            Row {
                                id: chLabelRow
                                anchors.centerIn: parent
                                spacing: 6

                                // Glow dot
                                Item {
                                    width: Qt.platform.os === "android" ? 12 : 10
                                    height: width
                                    anchors.verticalCenter: parent.verticalCenter
                                    // Outer glow
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width * 1.8; height: width; radius: width / 2
                                        color: "#ff2222"; opacity: 0.25
                                        SequentialAnimation on opacity {
                                            loops: Animation.Infinite
                                            NumberAnimation { to: 0.05; duration: 600 }
                                            NumberAnimation { to: 0.30; duration: 600 }
                                        }
                                    }
                                    // Inner dot
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width; height: width; radius: width / 2
                                        color: "#ff3333"
                                        SequentialAnimation on opacity {
                                            loops: Animation.Infinite
                                            NumberAnimation { to: 0.3; duration: 600 }
                                            NumberAnimation { to: 1.0; duration: 600 }
                                        }
                                    }
                                }
                                Text {
                                    text: langSettings.lang === "sw" ? "🇹🇿 MOJA KWA MOJA  ·  Tanzania Safari Channel" : "🇹🇿 LIVE  ·  Tanzania Safari Channel"
                                    font.pointSize: Qt.platform.os === "android" ? 9 : 7
                                    font.bold: true
                                    color: "cyan"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // ── Stream quality dots ──────────────
                                Row {
                                    spacing: Qt.platform.os === "android" ? 3 : 2
                                    anchors.verticalCenter: parent.verticalCenter

                                    Repeater {
                                        model: 3
                                        Rectangle {
                                            width: Qt.platform.os === "android" ? 5 : 4
                                            height: width; radius: width / 2
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: {
                                                var q = safariPlayer.streamQuality;
                                                if (safariPlayer.playbackState !== MediaPlayer.PlayingState)
                                                    return "#333333";
                                                if (q === 2) return "#44ff44";       // Good — tutti e tre verdi
                                                if (q === 1) return index < 2 ? "#ffaa00" : "#333333"; // Fair — due gialli
                                                return index < 1 ? "#ff4444" : "#333333"; // Poor — uno rosso
                                            }
                                            Behavior on color { ColorAnimation { duration: 400 } }
                                        }
                                    }
                                }
                            }
                        }

                        // ── MediaPlayer (stream engine) ────────────────────
                        MediaPlayer {
                            id: safariPlayer
                            autoPlay: false

                            // 0 = Poor, 1 = Fair, 2 = Good
                            property int streamQuality: 0
                            property real _lastBuffer: 0.0

                            onStatusChanged: {
                                if (status === MediaPlayer.InvalidMedia) {
                                    safariTvOverlay.streamError = true;
                                    safariTvOverlay.streamErrorMsg = "invalid";
                                } else if (status === MediaPlayer.NoMedia) {
                                    safariTvOverlay.streamError = true;
                                    safariTvOverlay.streamErrorMsg = "nomedia";
                                } else if (status === MediaPlayer.Loaded || status === MediaPlayer.Buffered) {
                                    safariTvOverlay.streamError = false;
                                    safariTvOverlay.streamErrorMsg = "";
                                }
                            }
                            onErrorChanged: {
                                if (error !== MediaPlayer.NoError) {
                                    safariTvOverlay.streamError = true;
                                    safariTvOverlay.streamErrorMsg = "network";
                                }
                            }
                            onPlaybackStateChanged: {
                                if (playbackState === MediaPlayer.PlayingState) {
                                    safariTvOverlay.streamError = false;
                                    safariTvOverlay.streamErrorMsg = "";
                                }
                            }
                        }

                        // ── Stream quality timer ───────────────────────────
                        Timer {
                            id: qualityTimer
                            interval: 3000
                            repeat: true
                            running: safariPlayer.playbackState === MediaPlayer.PlayingState
                            onTriggered: {
                                var buf = safariPlayer.bufferProgress;
                                var delta = buf - safariPlayer._lastBuffer;
                                safariPlayer._lastBuffer = buf;
                                if (buf >= 0.8) {
                                    safariPlayer.streamQuality = 2;
                                } else if (buf >= 0.4 || delta > 0.05) {
                                    safariPlayer.streamQuality = 1;
                                } else {
                                    safariPlayer.streamQuality = 0;
                                }
                            }
                        }

                        // ── Video rendered by single videoOut in safariTvOverlay ──

                        // ── "No signal" shown when not playing ─────────────
                        Rectangle {
                            id: noSignalScreen
                            anchors.fill: parent
                            anchors.margins: parent.border.width
                            radius: parent.radius - parent.border.width
                            color: "#001413"
                            z: 10
                            visible: safariPlayer.playbackState !== MediaPlayer.PlayingState
                                     && safariPlayer.playbackState !== MediaPlayer.PausedState

                            // Buffering spinner — fancy Canvas arcs
                            Item {
                                anchors.centerIn: parent
                                width: Qt.platform.os === "android" ? 64 : 50
                                height: width
                                visible: safariPlayer.status === MediaPlayer.Loading
                                         || safariPlayer.status === MediaPlayer.Buffering
                                         || safariPlayer.status === MediaPlayer.Stalled
                                // Outer arc
                                Canvas {
                                    anchors.fill: parent
                                    property real angle: 0
                                    NumberAnimation on angle {
                                        loops: Animation.Infinite; from: 0; to: Math.PI * 2
                                        duration: 900; running: parent.visible
                                    }
                                    onAngleChanged: { requestPaint(); }
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.clearRect(0, 0, width, height);
                                        ctx.strokeStyle = "cyan";
                                        ctx.lineWidth = width * 0.08;
                                        ctx.lineCap = "round";
                                        ctx.globalAlpha = 1.0;
                                        ctx.beginPath();
                                        ctx.arc(width/2, height/2, width * 0.44, angle, angle + Math.PI * 1.2);
                                        ctx.stroke();
                                    }
                                    Component.onCompleted: { requestPaint(); }
                                }
                                // Middle arc
                                Canvas {
                                    anchors.fill: parent
                                    property real angle: 0
                                    NumberAnimation on angle {
                                        loops: Animation.Infinite; from: Math.PI * 2; to: 0
                                        duration: 700; running: parent.visible
                                    }
                                    onAngleChanged: { requestPaint(); }
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.clearRect(0, 0, width, height);
                                        ctx.strokeStyle = "#00ffff";
                                        ctx.lineWidth = width * 0.07;
                                        ctx.lineCap = "round";
                                        ctx.globalAlpha = 0.6;
                                        ctx.beginPath();
                                        ctx.arc(width/2, height/2, width * 0.31, angle, angle + Math.PI * 0.9);
                                        ctx.stroke();
                                    }
                                    Component.onCompleted: { requestPaint(); }
                                }
                                // Inner dot pulse
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width * 0.18; height: width; radius: width / 2
                                    color: "cyan"
                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite; running: parent.parent.visible
                                        NumberAnimation { to: 0.2; duration: 400 }
                                        NumberAnimation { to: 1.0; duration: 400 }
                                    }
                                    SequentialAnimation on scale {
                                        loops: Animation.Infinite; running: parent.parent.visible
                                        NumberAnimation { to: 0.6; duration: 400 }
                                        NumberAnimation { to: 1.0; duration: 400 }
                                    }
                                }
                            }

                            // ── ERROR STATE ────────────────────────────────
                            Column {
                                anchors.centerIn: parent
                                spacing: Qt.platform.os === "android" ? 12 : 9
                                visible: safariTvOverlay.streamError
                                         && safariPlayer.playbackState !== MediaPlayer.PlayingState
                                         && safariPlayer.playbackState !== MediaPlayer.PausedState

                                // Error icon — animated
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "⚠"
                                    font.pointSize: Qt.platform.os === "android" ? 32 : 26
                                    color: "#ffaa00"
                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.4; duration: 800 }
                                        NumberAnimation { to: 1.0; duration: 800 }
                                    }
                                }

                                // SW message
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: tvScreen.width * 0.82
                                    wrapMode: Text.WordWrap
                                    horizontalAlignment: Text.AlignHCenter
                                    visible: langSettings.lang === "sw"
                                    text: safariTvOverlay.streamErrorMsg === "network"
                                          ? "Hitilafu ya mtandao.\nThibitisha muunganiko wako wa intaneti."
                                          : "Stream haipatikani kwa sasa."
                                    font.pointSize: Qt.platform.os === "android" ? 11 : 9
                                    font.bold: true
                                    color: "#ffaa00"
                                }

                                // EN message
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: tvScreen.width * 0.82
                                    wrapMode: Text.WordWrap
                                    horizontalAlignment: Text.AlignHCenter
                                    visible: langSettings.lang === "en"
                                    text: safariTvOverlay.streamErrorMsg === "network"
                                          ? "Network error.\nCheck your internet connection."
                                          : "Stream unavailable at the moment."
                                    font.pointSize: Qt.platform.os === "android" ? 11 : 9
                                    font.bold: true
                                    color: "#ffaa00"
                                }

                                // Divider
                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: Qt.platform.os === "android" ? 160 : 120
                                    height: 1; color: "#ffaa00"; opacity: 0.4
                                }

                                // Retry button
                                Rectangle {
                                    id: retryBtn
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: retryRow.implicitWidth + (Qt.platform.os === "android" ? 36 : 28)
                                    height: Qt.platform.os === "android" ? 46 : 36
                                    radius: height / 2
                                    color: retryMA.pressed ? "#3a2200" : "#1a0e00"
                                    border.color: retryMA.pressed ? "#ffcc00" : "#ffaa00"
                                    border.width: retryMA.pressed ? 3 : 2
                                    opacity: retryMA.pressed ? 0.7 : 1.0
                                    Behavior on color        { ColorAnimation  { duration: 80 } }
                                    Behavior on border.color { ColorAnimation  { duration: 80 } }
                                    Behavior on border.width { NumberAnimation { duration: 80 } }
                                    Behavior on opacity      { NumberAnimation { duration: 80 } }

                                    // Inner glow on press
                                    Rectangle {
                                        anchors.fill: parent; radius: parent.radius
                                        color: Qt.rgba(1, 0.7, 0, 0.22)
                                        opacity: retryMA.pressed ? 1.0 : 0.0
                                        Behavior on opacity { NumberAnimation { duration: 80 } }
                                    }

                                    Row {
                                        id: retryRow
                                        anchors.centerIn: parent
                                        spacing: Qt.platform.os === "android" ? 8 : 6
                                        // Canvas-drawn retry icon
                                        Item {
                                            id: retryArrow
                                            width: Qt.platform.os === "android" ? 22 : 18
                                            height: width
                                            anchors.verticalCenter: parent.verticalCenter
                                            RotationAnimation on rotation {
                                                id: retrySpinAnim
                                                from: 0; to: -360
                                                duration: 450
                                                running: false
                                                easing.type: Easing.OutCubic
                                            }
                                            Canvas {
                                                anchors.fill: parent
                                                onPaint: {
                                                    var ctx = getContext("2d");
                                                    ctx.clearRect(0, 0, width, height);
                                                    var cx = width/2; var cy = height/2;
                                                    var r = width * 0.36;
                                                    ctx.strokeStyle = "#ffaa00";
                                                    ctx.lineWidth = width * 0.13;
                                                    ctx.lineCap = "round";
                                                    // Arc ~270°
                                                    ctx.beginPath();
                                                    ctx.arc(cx, cy, r, -Math.PI * 0.65, Math.PI * 0.85);
                                                    ctx.stroke();
                                                    // Arrowhead at end
                                                    ctx.fillStyle = "#ffaa00";
                                                    var ax = cx + r * Math.cos(Math.PI * 0.85);
                                                    var ay = cy + r * Math.sin(Math.PI * 0.85);
                                                    ctx.beginPath();
                                                    ctx.moveTo(ax - width*0.12, ay - height*0.04);
                                                    ctx.lineTo(ax + width*0.06, ay + height*0.15);
                                                    ctx.lineTo(ax + width*0.13, ay - height*0.12);
                                                    ctx.closePath(); ctx.fill();
                                                }
                                                Component.onCompleted: { requestPaint(); }
                                            }
                                        }
                                        Text {
                                            text: langSettings.lang === "sw" ? "Jaribu tena" : "Retry"
                                            font.pointSize: Qt.platform.os === "android" ? 12 : 10
                                            font.bold: true; color: "#ffaa00"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                    MouseArea {
                                        id: retryMA
                                        anchors.fill: parent
                                        onReleased: {
                                            retrySpinAnim.restart();
                                            safariTvOverlay.streamError = false;
                                            safariTvOverlay.streamErrorMsg = "";
                                            safariPlayer.stop();
                                            safariPlayer.source = "";
                                            safariPlayer.source = app.safariChannelStreamURL;
                                            safariPlayer.play();
                                        }
                                    }
                                }
                            }

                            // ── IDLE STATE (no error, not loading) ─────────
                            Column {
                                anchors.centerIn: parent
                                spacing: Qt.platform.os === "android" ? 10 : 8
                                visible: !safariTvOverlay.streamError
                                         && safariPlayer.status !== MediaPlayer.Loading
                                         && safariPlayer.status !== MediaPlayer.Buffering
                                         && safariPlayer.status !== MediaPlayer.Stalled

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "📡"
                                    font.pointSize: Qt.platform.os === "android" ? 30 : 24
                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.4; duration: 1200 }
                                        NumberAnimation { to: 1.0; duration: 1200 }
                                    }
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Tanzania Safari Channel"
                                    font.pointSize: Qt.platform.os === "android" ? 13 : 10
                                    font.bold: true; color: "cyan"
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: langSettings.lang === "sw"
                                          ? "Bonyeza ▶ kuanza kutazama"
                                          : "Press ▶ to start watching"
                                    font.pointSize: Qt.platform.os === "android" ? 10 : 8
                                    color: "#aaaaaa"; font.italic: true
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: tvScreen.width * 0.78
                                    wrapMode: Text.WordWrap
                                    horizontalAlignment: Text.AlignHCenter
                                    text: langSettings.lang === "sw"
                                          ? "Gonga mara mbili skrini kwenda Fullscreen"
                                          : "Double-tap screen to go Fullscreen"
                                    font.pointSize: Qt.platform.os === "android" ? 9 : 7
                                    color: "#1a6060"; font.italic: true
                                }
                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: Qt.platform.os === "android" ? 180 : 140
                                    height: 2; color: "cyan"; opacity: 0.35
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: tvScreen.width * 0.78
                                    wrapMode: Text.WordWrap
                                    horizontalAlignment: Text.AlignHCenter
                                    text: "DStv 292  ·  Azam TV 401\nZuku 27  ·  StarTimes 331\nZmux 46  ·  Continental 7"
                                    font.pointSize: Qt.platform.os === "android" ? 10 : 8
                                    color: "#aaaaaa"; font.italic: true
                                }
                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: Qt.platform.os === "android" ? 180 : 140
                                    height: 2; color: "cyan"; opacity: 0.35
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "MagabeLab TV v3.2"
                                    font.pointSize: Qt.platform.os === "android" ? 10 : 8
                                    color: "#1a6060";
                                    font.italic: true
                                }

                            }
                        }

                        // Scanline overlay on screen
                        Canvas {
                            anchors.fill: parent
                            anchors.margins: parent.border.width
                            z: 8
                            opacity: 0.10

                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);
                                ctx.strokeStyle = "#000000";
                                ctx.lineWidth = 1;
                                for (var y = 0; y < height; y += 2) {
                                    ctx.beginPath();
                                    ctx.moveTo(0, y);
                                    ctx.lineTo(width, y);
                                    ctx.stroke();
                                }
                            }
                            Component.onCompleted: { requestPaint(); }
                        }

                        // ── Gestures: double-tap → fullscreen, swipe Y → volume, swipe X → brightness ──
                        MouseArea {
                            anchors.fill: parent
                            z: 9
                            property real startX: 0
                            property real startY: 0
                            property real startVol: 1.0
                            property real startBright: 1.0
                            property bool isDragging: false
                            property bool isHorizontal: false

                            onPressed: {
                                startX = mouse.x;
                                startY = mouse.y;
                                startVol = safariTvOverlay.tvVolume;
                                startBright = safariTvOverlay.tvBrightness;
                                isDragging = false;
                                isHorizontal = false;
                            }
                            onPositionChanged: {
                                var dx = mouse.x - startX;
                                var dy = mouse.y - startY;
                                if (!isDragging && (Math.abs(dx) > 8 || Math.abs(dy) > 8)) {
                                    isDragging = true;
                                    isHorizontal = Math.abs(dx) > Math.abs(dy);
                                }
                                if (isDragging) {
                                    if (isHorizontal) {
                                        var db = dx / (tvScreen.width * 0.8);
                                        safariTvOverlay.tvBrightness = Math.max(0.1, Math.min(1.0, startBright + db));
                                        brightOverlay.show();
                                    } else {
                                        var dv = (startY - mouse.y) / (tvScreen.height * 0.8);
                                        safariTvOverlay.tvVolume = Math.max(0.0, Math.min(1.0, startVol + dv));
                                        volOverlay.show();
                                    }
                                }
                            }
                            onDoubleClicked: {
                                if (!isDragging) {
                                    safariTvOverlay.tvFullScreen = true;
                                }
                            }
                        }
                    }

                    // ── CONTROLS ROW ───────────────────────────────────────
                    Item {
                        id: controlsRow
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        height: Qt.platform.os === "android" ? 72 : 58
                        property int btnSize: Qt.platform.os === "android" ? 48 : 38
                        property int smallSize: Qt.platform.os === "android" ? 40 : 32
                        property int playSize: Qt.platform.os === "android" ? 64 : 52
                        property int sideGap: Qt.platform.os === "android" ? 7 : 5

                        // ── STOP — left of centre group ────────────
                        Rectangle {
                            id: stopBtn
                            anchors.right: parent.horizontalCenter
                            anchors.rightMargin: (controlsRow.smallSize + controlsRow.playSize / 2) + controlsRow.sideGap * 2 + (Qt.platform.os === "android" ? 10 : 8)
                            anchors.verticalCenter: parent.verticalCenter
                            width: controlsRow.btnSize; height: width; radius: width / 2
                            color: stopMA.pressed ? "#1a0a0a" : "#0d0505"
                            border.color: "#cc4444"; border.width: stopMA.pressed ? 3 : 2
                            Behavior on color { ColorAnimation { duration: 100 } }
                            Behavior on border.width { NumberAnimation { duration: 100 } }
                            Behavior on scale { NumberAnimation { duration: 100 } }
                            Rectangle {
                                anchors.fill: parent; radius: parent.radius
                                color: Qt.rgba(0.8, 0.1, 0.1, 0.25)
                                opacity: stopMA.pressed ? 1.0 : 0.0
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }
                            Canvas {
                                anchors.fill: parent
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    var s = width * 0.34;
                                    ctx.fillStyle = "#cc4444";
                                    ctx.fillRect(width/2 - s/2, height/2 - s/2, s, s);
                                }
                                Component.onCompleted: { requestPaint(); }
                            }
                            MouseArea {
                                id: stopMA; anchors.fill: parent
                                onPressed:  stopBtn.scale = 0.9
                                onReleased: { stopBtn.scale = 1.0; safariPlayer.stop(); }
                                onCanceled: stopBtn.scale = 1.0
                            }
                        }

                        // ── VOLUME — right of centre group ─────
                        Rectangle {
                            id: volBtn
                            anchors.left: parent.horizontalCenter
                            anchors.leftMargin: (controlsRow.smallSize + controlsRow.playSize / 2) + controlsRow.sideGap * 2 + (Qt.platform.os === "android" ? 10 : 8)
                            anchors.verticalCenter: parent.verticalCenter
                            width: controlsRow.btnSize; height: width; radius: width / 2
                            color: volMA.pressed ? "#1a6060" : "#0d3a38"
                            border.color: "cyan"; border.width: 2
                            Behavior on color { ColorAnimation { duration: 100 } }
                            Behavior on scale { NumberAnimation { duration: 100 } }
                            Canvas {
                                id: volIconCanvas
                                anchors.fill: parent
                                property bool muted: safariPlayer.muted
                                onMutedChanged: { requestPaint(); }
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    var cx = width * 0.38; var cy = height / 2;
                                    var bh = height * 0.38; var bw = width * 0.22;
                                    ctx.save();
                                    ctx.translate(width/2, cy); ctx.scale(0.75, 0.75); ctx.translate(-width/2, -cy);
                                    ctx.fillStyle = "cyan";
                                    ctx.beginPath();
                                    ctx.moveTo(cx - bw, cy - bh * 0.5);
                                    ctx.lineTo(cx, cy - bh * 0.5);
                                    ctx.lineTo(cx + bw * 0.7, cy - bh);
                                    ctx.lineTo(cx + bw * 0.7, cy + bh);
                                    ctx.lineTo(cx, cy + bh * 0.5);
                                    ctx.lineTo(cx - bw, cy + bh * 0.5);
                                    ctx.closePath(); ctx.fill();
                                    if (!muted) {
                                        ctx.lineWidth = width * 0.08;
                                        ctx.lineCap = "round";
                                        ctx.strokeStyle = "cyan";
                                        ctx.beginPath();
                                        ctx.arc(cx + bw * 0.7, cy, width * 0.16, -Math.PI * 0.5, Math.PI * 0.5);
                                        ctx.stroke();
                                        ctx.beginPath();
                                        ctx.arc(cx + bw * 0.7, cy, width * 0.28, -Math.PI * 0.5, Math.PI * 0.5);
                                        ctx.stroke();
                                    } else {
                                        ctx.lineWidth = width * 0.10;
                                        ctx.lineCap = "round";
                                        ctx.strokeStyle = "#cc4444";
                                        ctx.beginPath();
                                        ctx.moveTo(cx + bw * 1.1, cy - height * 0.22);
                                        ctx.lineTo(cx + bw * 1.8, cy + height * 0.22);
                                        ctx.stroke();
                                        ctx.beginPath();
                                        ctx.moveTo(cx + bw * 1.8, cy - height * 0.22);
                                        ctx.lineTo(cx + bw * 1.1, cy + height * 0.22);
                                        ctx.stroke();
                                    }
                                    ctx.restore();
                                }
                                Component.onCompleted: { requestPaint(); }
                            }
                            MouseArea {
                                id: volMA; anchors.fill: parent
                                onPressed:  volBtn.scale = 0.9
                                onReleased: {
                                    volBtn.scale = 1.0;
                                    safariPlayer.muted = !safariPlayer.muted;
                                    volIconCanvas.requestPaint();
                                }
                                onCanceled: volBtn.scale = 1.0
                            }
                        }

                        // ── CENTRE GROUP: Rewind + Play + Forward ──
                        Row {
                            anchors.centerIn: parent
                            spacing: Qt.platform.os === "android" ? 10 : 8

                            // REWIND
                            Rectangle {
                                id: rwBtn
                                width: controlsRow.smallSize; height: width; radius: width / 2
                                anchors.verticalCenter: parent.verticalCenter
                                color: rwMA.pressed ? "#1a6060" : "#0d3a38"
                                border.color: "cyan"; border.width: 2
                                Behavior on color { ColorAnimation { duration: 100 } }
                                Behavior on scale { NumberAnimation { duration: 100 } }
                                Canvas {
                                    anchors.fill: parent
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.clearRect(0, 0, width, height);
                                        ctx.fillStyle = "cyan";
                                        var cx = width / 2; var cy = height / 2;
                                        ctx.save();
                                        ctx.translate(cx, cy); ctx.scale(0.75, 0.75); ctx.translate(-cx, -cy);
                                        var tw = width * 0.26; var th = height * 0.44;
                                        var bw = width * 0.07; var gap = width * 0.04;
                                        ctx.save();
                                        ctx.translate(width, 0);
                                        ctx.scale(-1, 1);
                                        ctx.beginPath();
                                        ctx.moveTo(cx - tw - gap/2, cy - th/2);
                                        ctx.lineTo(cx - gap/2, cy);
                                        ctx.lineTo(cx - tw - gap/2, cy + th/2);
                                        ctx.closePath(); ctx.fill();
                                        ctx.beginPath();
                                        ctx.moveTo(cx + gap/2, cy - th/2);
                                        ctx.lineTo(cx + tw + gap/2, cy);
                                        ctx.lineTo(cx + gap/2, cy + th/2);
                                        ctx.closePath(); ctx.fill();
                                        ctx.fillRect(cx + tw + gap/2 + gap, cy - th/2, bw, th);
                                        ctx.restore();
                                        ctx.restore();
                                    }
                                    Component.onCompleted: { requestPaint(); }
                                }
                                MouseArea {
                                    id: rwMA; anchors.fill: parent
                                    onPressed:  rwBtn.scale = 0.9
                                    onReleased: { rwBtn.scale = 1.0; showToastMessage("Rewind — Live stream haiwezi kurudi nyuma"); }
                                    onCanceled: rwBtn.scale = 1.0
                                }
                            }

                            // PLAY / PAUSE — kubwa
                            Item {
                                width: controlsRow.playSize; height: width
                                anchors.verticalCenter: parent.verticalCenter
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width + (Qt.platform.os === "android" ? 16 : 12)
                                    height: width; radius: width / 2
                                    color: "transparent"
                                    border.color: "cyan"; border.width: Qt.platform.os === "android" ? 3 : 2
                                    opacity: playMA.pressed ? 0.7 : 0.0
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                }
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width + (Qt.platform.os === "android" ? 30 : 24)
                                    height: width; radius: width / 2
                                    color: "transparent"
                                    border.color: "cyan"; border.width: Qt.platform.os === "android" ? 2 : 1
                                    opacity: playMA.pressed ? 0.25 : 0.0
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                }
                                Rectangle {
                                    id: playBtn
                                    anchors.centerIn: parent
                                    width: parent.width; height: width; radius: width / 2
                                    color: playMA.pressed ? "#1a6060" : "#0d3a38"
                                    border.color: "cyan"; border.width: 3
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                    Behavior on scale { NumberAnimation { duration: 100 } }
                                    Canvas {
                                        id: playIconCanvas
                                        anchors.fill: parent
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.clearRect(0, 0, width, height);
                                            ctx.fillStyle = "cyan";
                                            var cx = width / 2; var cy = height / 2;
                                            var playing = safariPlayer.playbackState === MediaPlayer.PlayingState;
                                            if (playing) {
                                                var bw = width * 0.12; var bh = height * 0.42; var gap = width * 0.10;
                                                ctx.fillRect(cx - gap/2 - bw, cy - bh/2, bw, bh);
                                                ctx.fillRect(cx + gap/2, cy - bh/2, bw, bh);
                                            } else {
                                                var tw = width * 0.38; var th = height * 0.44;
                                                ctx.beginPath();
                                                ctx.moveTo(cx - tw/2 + width*0.03, cy - th/2);
                                                ctx.lineTo(cx + tw/2 + width*0.03, cy);
                                                ctx.lineTo(cx - tw/2 + width*0.03, cy + th/2);
                                                ctx.closePath(); ctx.fill();
                                            }
                                        }
                                        Component.onCompleted: { requestPaint(); }
                                        Connections {
                                            target: safariPlayer
                                            onPlaybackStateChanged: { playIconCanvas.requestPaint(); }
                                        }
                                    }
                                    MouseArea {
                                        id: playMA; anchors.fill: parent
                                        onPressed:  playBtn.scale = 0.9
                                        onReleased: {
                                            playBtn.scale = 1.0;
                                            if (safariPlayer.playbackState === MediaPlayer.PlayingState) {
                                                safariPlayer.pause();
                                            } else {
                                                safariPlayer.play();
                                            }
                                            playIconCanvas.requestPaint();
                                        }
                                        onCanceled: playBtn.scale = 1.0
                                    }
                                }
                            }

                            // FORWARD
                            Rectangle {
                                id: ffBtn
                                width: controlsRow.smallSize; height: width; radius: width / 2
                                anchors.verticalCenter: parent.verticalCenter
                                color: ffMA.pressed ? "#1a6060" : "#0d3a38"
                                border.color: "cyan"; border.width: 2
                                Behavior on color { ColorAnimation { duration: 100 } }
                                Behavior on scale { NumberAnimation { duration: 100 } }
                                Canvas {
                                    anchors.fill: parent
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.clearRect(0, 0, width, height);
                                        ctx.fillStyle = "cyan";
                                        var cx = width / 2; var cy = height / 2;
                                        ctx.save();
                                        ctx.translate(cx, cy); ctx.scale(0.75, 0.75); ctx.translate(-cx, -cy);
                                        var tw = width * 0.26; var th = height * 0.44;
                                        var bw = width * 0.07;
                                        ctx.beginPath();
                                        ctx.moveTo(cx - tw - bw * 0.5 - tw * 0.1, cy - th/2);
                                        ctx.lineTo(cx - bw * 0.5 - tw * 0.1, cy);
                                        ctx.lineTo(cx - tw - bw * 0.5 - tw * 0.1, cy + th/2);
                                        ctx.closePath(); ctx.fill();
                                        ctx.beginPath();
                                        ctx.moveTo(cx - bw * 0.5 + tw * 0.1, cy - th/2);
                                        ctx.lineTo(cx + tw * 0.9 - bw * 0.5, cy);
                                        ctx.lineTo(cx - bw * 0.5 + tw * 0.1, cy + th/2);
                                        ctx.closePath(); ctx.fill();
                                        ctx.fillRect(cx + tw * 0.9 - bw * 0.5 + tw * 0.1, cy - th/2, bw, th);
                                        ctx.restore();
                                    }
                                    Component.onCompleted: { requestPaint(); }
                                }
                                MouseArea {
                                    id: ffMA; anchors.fill: parent
                                    onPressed:  ffBtn.scale = 0.9
                                    onReleased: { ffBtn.scale = 1.0; showToastMessage(langSettings.lang === "sw" ? "Haraka mbele — Stream inaendelea moja kwa moja" : "Fast-forward — Live stream only"); }
                                    onCanceled: ffBtn.scale = 1.0
                                }
                            }
                        }

                    } // end controlsRow

                    // ── BOTTOM PANEL: knobs + brand ────────────────────────
                    Item {
                        width: parent.width
                        height: Qt.platform.os === "android" ? 72 : 58

                        // Knob 1 — left
                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: Qt.platform.os === "android" ? 18 : 14
                            anchors.verticalCenter: parent.verticalCenter
                            width: Qt.platform.os === "android" ? 32 : 25; height: width; radius: width / 2
                            color: "#0a1f1e"; border.color: "#1a6060"; border.width: 2
                            Rectangle { width: 4; height: parent.height * 0.4; radius: 2; color: "cyan"; anchors.centerIn: parent; rotation: 45 }
                        }

                        // Channel dial — right
                        Rectangle {
                            anchors.right: parent.right
                            anchors.rightMargin: Qt.platform.os === "android" ? 18 : 14
                            anchors.verticalCenter: parent.verticalCenter
                            width: Qt.platform.os === "android" ? 38 : 30; height: width; radius: width / 2
                            color: "#001413"; border.color: "cyan"; border.width: 2
                            RotationAnimation on rotation {
                                loops: Animation.Infinite; from: 0; to: 360
                                duration: 8000
                                running: app.safariTvVisible
                            }
                            Rectangle { width: 3; height: parent.height * 0.38; radius: 2; color: "cyan"; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top; anchors.topMargin: 3 }
                        }

                        // Knob 2 — right of center
                        Rectangle {
                            anchors.right: parent.right
                            anchors.rightMargin: Qt.platform.os === "android" ? 68 : 54
                            anchors.verticalCenter: parent.verticalCenter
                            width: Qt.platform.os === "android" ? 32 : 25; height: width; radius: width / 2
                            color: "#0a1f1e"; border.color: "#1a6060"; border.width: 2
                            Rectangle { width: 4; height: parent.height * 0.4; radius: 2; color: "cyan"; anchors.centerIn: parent; rotation: -30 }
                        }

                        // Brand — centred
                        Rectangle {
                            anchors.centerIn: parent
                            width: brandCol.implicitWidth + (Qt.platform.os === "android" ? 28 : 20)
                            height: brandCol.implicitHeight + (Qt.platform.os === "android" ? 14 : 10)
                            radius: Qt.platform.os === "android" ? 12 : 9
                            color: "#001413"
                            border.color: Qt.rgba(0, 1, 1, 0.3); border.width: 1

                            Column {
                                id: brandCol
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: langSettings.lang === "sw" ? "Utalii wa Tanzania" : "Tanzania Tourism"
                                    font.pointSize: Qt.platform.os === "android" ? 11 : 9
                                    font.bold: true
                                    color: "cyan"
                                    font.letterSpacing: 2
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Brightness dim overlay ─────────────────────────────────
        // Covers video only — black overlay with opacity = 1 - brightness
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 1.0 - safariTvOverlay.tvBrightness
            z: 501
            visible: safariTvOverlay.tvBrightness < 0.99
            Behavior on opacity { NumberAnimation { duration: 80 } }
        }

        // ── Brightness indicator (left side) ──────────────────────
        Rectangle {
            id: brightOverlay
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Qt.platform.os === "android" ? 28 : 23
            width: Qt.platform.os === "android" ? 56 : 44
            height: Qt.platform.os === "android" ? 200 : 160
            radius: width / 2
            color: Qt.rgba(0, 0.08, 0.07, 0.88)
            border.color: Qt.rgba(1, 0.93, 0, 0.35); border.width: 1
            z: 550
            opacity: 0.0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            function show() {
                opacity = 1.0;
                brightHideTimer.restart();
            }
            Timer {
                id: brightHideTimer
                interval: 1800
                onTriggered: { brightOverlay.opacity = 0.0; }
            }

            // Sun icon — top
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Qt.platform.os === "android" ? 12 : 9
                text: "☀"
                font.pointSize: Qt.platform.os === "android" ? 14 : 11
                color: "#ffee00"
            }

            // Track background
            Rectangle {
                id: brightTrackBg
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: Qt.platform.os === "android" ? 46 : 36
                anchors.bottomMargin: Qt.platform.os === "android" ? 38 : 30
                width: Qt.platform.os === "android" ? 10 : 8
                radius: width / 2
                color: Qt.rgba(0.6, 0.6, 0, 0.3)
            }

            // Fill
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: brightTrackBg.bottom
                width: brightTrackBg.width
                height: brightTrackBg.height * safariTvOverlay.tvBrightness
                radius: width / 2
                color: "#ffee00"
                Behavior on height { NumberAnimation { duration: 80 } }
            }

            // Percentage — bottom
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Qt.platform.os === "android" ? 10 : 8
                text: Math.round(safariTvOverlay.tvBrightness * 100) + "%"
                font.pointSize: Qt.platform.os === "android" ? 11 : 9
                font.bold: true; color: "#ffee00"
            }

            // Click anywhere on pill to set brightness
            MouseArea {
                anchors.fill: brightTrackBg
                anchors.margins: -10
                onPressed: {
                    var level = 1.0 - (mouseY / brightTrackBg.height);
                    safariTvOverlay.tvBrightness = Math.max(0.1, Math.min(1.0, level));
                    brightOverlay.show();
                }
                onPositionChanged: {
                    var level = 1.0 - (mouseY / brightTrackBg.height);
                    safariTvOverlay.tvBrightness = Math.max(0.1, Math.min(1.0, level));
                }
            }
        }

        // ── Fullscreen brightness indicator — moved inside fsInner ──

        // ── PiP (Picture-in-Picture) floating window ───────────────
        Rectangle {
            id: pipWindow
            width: Qt.platform.os === "android" ? 160 : 130
            height: Qt.platform.os === "android" ? 100 : 80
            x: safariTvOverlay.width  - width  - (Qt.platform.os === "android" ? 12 : 8)
            y: safariTvOverlay.height - height - (Qt.platform.os === "android" ? 12 : 8)
            radius: Qt.platform.os === "android" ? 10 : 8
            color: "#001413"
            border.color: "cyan"; border.width: 2
            z: 700
            visible: safariTvOverlay.pipMode && !safariTvOverlay.tvFullScreen
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 250 } }

            // PiP video mirror via ShaderEffectSource
            ShaderEffectSource {
                anchors.fill: parent
                anchors.margins: 2
                sourceItem: videoOut
                hideSource: false
                clip: true
            }

            // PiP drag handler
            MouseArea {
                anchors.fill: parent
                drag.target: pipWindow
                drag.minimumX: 0
                drag.maximumX: safariTvOverlay.width  - pipWindow.width
                drag.minimumY: 0
                drag.maximumY: safariTvOverlay.height - pipWindow.height
            }

            // PiP close button
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: -6; anchors.rightMargin: -6
                width: Qt.platform.os === "android" ? 22 : 18; height: width; radius: width / 2
                color: "#0d0505"; border.color: "#cc4444"; border.width: 1.5
                z: 10
                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        ctx.strokeStyle = "#ff6666";
                        ctx.lineWidth = width * 0.14; ctx.lineCap = "round";
                        var cx = width/2; var cy = height/2;
                        var d = cx * 0.5;
                        ctx.beginPath(); ctx.moveTo(cx-d, cy-d); ctx.lineTo(cx+d, cy+d); ctx.stroke();
                        ctx.beginPath(); ctx.moveTo(cx+d, cy-d); ctx.lineTo(cx-d, cy+d); ctx.stroke();
                    }
                    Component.onCompleted: { requestPaint(); }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: { safariTvOverlay.pipMode = false; }
                }
            }
        }

        // ── PiP toggle button (shown on normal TV mode) ────────────
        Rectangle {
            id: pipBtn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: Qt.platform.os === "android" ? 14 : 10
            anchors.leftMargin: Qt.platform.os === "android" ? 14 : 10
            width: Qt.platform.os === "android" ? 42 : 34; height: width; radius: width / 2
            color: pipBtnMA.pressed ? "#0d3a38" : "#001413"
            border.color: safariTvOverlay.pipMode ? "cyan" : "#1a6060"; border.width: 2
            visible: !safariTvOverlay.tvFullScreen
            z: 20
            Behavior on color { ColorAnimation { duration: 100 } }
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.strokeStyle = safariTvOverlay.pipMode ? "cyan" : "#1a8080";
                    ctx.lineWidth = width * 0.09; ctx.lineJoin = "round";
                    var m = width * 0.22;
                    // Outer screen
                    ctx.strokeRect(m, m, width - m*2, height - m*2);
                    // Inner small screen (bottom-right)
                    var sw = width * 0.30; var sh = height * 0.22;
                    ctx.fillStyle = safariTvOverlay.pipMode ? "cyan" : "#1a8080";
                    ctx.fillRect(width - m - sw - width*0.04, height - m - sh - height*0.04, sw, sh);
                }
                Component.onCompleted: { requestPaint(); }
                Connections {
                    target: safariTvOverlay
                    onPipModeChanged: { parent.requestPaint(); }
                }
            }
            MouseArea {
                id: pipBtnMA
                anchors.fill: parent
                onClicked: { safariTvOverlay.pipMode = !safariTvOverlay.pipMode; }
            }
        }

        // ── Volume indicator overlay ───────────────────────────────
        Rectangle {
            id: volOverlay
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Qt.platform.os === "android" ? 28 : 23
            width: Qt.platform.os === "android" ? 56 : 44
            height: Qt.platform.os === "android" ? 200 : 160
            radius: width / 2
            color: Qt.rgba(0, 0.08, 0.07, 0.88)
            border.color: Qt.rgba(0, 1, 1, 0.35); border.width: 1
            z: 550
            opacity: 0.0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            function show() {
                opacity = 1.0;
                hideTimer.restart();
            }

            Timer {
                id: hideTimer
                interval: 1800
                onTriggered: { volOverlay.opacity = 0.0; }
            }

            // Icon — top
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Qt.platform.os === "android" ? 12 : 9
                text: "🔊"
                font.pointSize: Qt.platform.os === "android" ? 14 : 11
            }

            // Track background
            Rectangle {
                id: volTrackBg
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: Qt.platform.os === "android" ? 46 : 36
                anchors.bottomMargin: Qt.platform.os === "android" ? 38 : 30
                width: Qt.platform.os === "android" ? 10 : 8
                radius: width / 2
                color: Qt.rgba(0, 0.3, 0.3, 0.5)
            }

            // Fill level
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: volTrackBg.bottom
                width: volTrackBg.width
                height: volTrackBg.height * safariTvOverlay.tvVolume
                radius: width / 2
                color: "cyan"
                Behavior on height { NumberAnimation { duration: 80 } }
            }

            // Percentage — bottom
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Qt.platform.os === "android" ? 10 : 8
                text: Math.round(safariTvOverlay.tvVolume * 100) + "%"
                font.pointSize: Qt.platform.os === "android" ? 11 : 9
                font.bold: true
                color: "cyan"
            }

            // Click anywhere on pill to set volume
            MouseArea {
                anchors.fill: volTrackBg
                anchors.margins: -10
                onPressed: {
                    var level = 1.0 - (mouseY / volTrackBg.height);
                    safariTvOverlay.tvVolume = Math.max(0.0, Math.min(1.0, level));
                    volOverlay.show();
                }
                onPositionChanged: {
                    var level = 1.0 - (mouseY / volTrackBg.height);
                    safariTvOverlay.tvVolume = Math.max(0.0, Math.min(1.0, level));
                }
            }
        }

        // ── Fullscreen volume overlay — moved inside fsInner ──────

        // ── Black fullscreen background (z:499, below videoOut z:500) ──
        Rectangle {
            anchors.fill: parent
            color: "black"
            visible: safariTvOverlay.tvFullScreen
            z: 499
        }

        // ── SINGLE VideoOutput ─────────────────────────────────────
        // Normal mode : sits inside tvScreen bezel (z:0)
        // Fullscreen  : fills overlay (z:500), above black bg (z:499)
        //               but below fsLayer UI (z:600)
        VideoOutput {
            id: videoOut
            source: safariPlayer
            fillMode: VideoOutput.PreserveAspectFit
            visible: safariPlayer.playbackState === MediaPlayer.PlayingState
                     || safariPlayer.playbackState === MediaPlayer.PausedState
            z: safariTvOverlay.tvFullScreen ? 500 : 0

            // Actual position read from tvScreen at runtime via mapToItem
            property real normalX: 0
            property real normalY: 0
            property real normalW: 100
            property real normalH: 100

            function updateNormalGeometry() {
                var bw = tvScreen.border.width;
                var pt = tvScreen.mapToItem(safariTvOverlay, bw, bw);
                normalX = pt.x;
                normalY = pt.y;
                normalW = tvScreen.width  - bw * 2;
                normalH = tvScreen.height - bw * 2;
            }

            Component.onCompleted: { Qt.callLater(updateNormalGeometry); }

            Connections {
                target: tvScreen
                onWidthChanged:  { videoOut.updateNormalGeometry(); }
                onHeightChanged: { videoOut.updateNormalGeometry(); }
            }

            Connections {
                target: safariTvOverlay
                onVisibleChanged: {
                    if (safariTvOverlay.visible) {
                        Qt.callLater(videoOut.updateNormalGeometry);
                    }
                }
            }

            property bool isLandscape: safariTvOverlay.tvFullScreen && (fsLayer.videoRotation % 180 !== 0)

            x:      safariTvOverlay.tvFullScreen ? (isLandscape ? (safariTvOverlay.width  - safariTvOverlay.height) / 2 : 0) : normalX
            y:      safariTvOverlay.tvFullScreen ? (isLandscape ? (safariTvOverlay.height - safariTvOverlay.width)  / 2 : 0) : normalY
            width:  safariTvOverlay.tvFullScreen ? (isLandscape ? safariTvOverlay.height : safariTvOverlay.width)  : normalW
            height: safariTvOverlay.tvFullScreen ? (isLandscape ? safariTvOverlay.width  : safariTvOverlay.height) : normalH

            Behavior on x      { NumberAnimation { duration: 450; easing.type: Easing.InOutCubic } }
            Behavior on y      { NumberAnimation { duration: 450; easing.type: Easing.InOutCubic } }
            Behavior on width  { NumberAnimation { duration: 450; easing.type: Easing.InOutCubic } }
            Behavior on height { NumberAnimation { duration: 450; easing.type: Easing.InOutCubic } }

            rotation: safariTvOverlay.tvFullScreen ? fsLayer.videoRotation : 0
            Behavior on rotation {
                RotationAnimation { duration: 300; direction: RotationAnimation.Clockwise }
            }
        }

        // ── FULLSCREEN OVERLAY ─────────────────────────────────────
        // fsInner rotates controls + badge + no-signal as one unit.
        // A Loader creates a VideoOutput only while fullscreen is active
        // so it never coexists with the normal videoOut — no GPU duplication.
        Item {
            id: fsLayer
            anchors.fill: parent
            visible: safariTvOverlay.tvFullScreen
            z: 600

            property int videoRotation: 0
            property bool fsUiVisible: true

            Item {
                id: fsInner
                anchors.centerIn: parent
                width:  (fsLayer.videoRotation % 180 === 0) ? parent.width  : parent.height
                height: (fsLayer.videoRotation % 180 === 0) ? parent.height : parent.width

                rotation: fsLayer.videoRotation
                Behavior on rotation {
                    RotationAnimation { duration: 300; direction: RotationAnimation.Clockwise }
                }

                // ── "No signal" when not playing (fullscreen) ─────
                Rectangle {
                    anchors.fill: parent
                    color: "#001413"
                    z: 1
                    visible: safariPlayer.playbackState !== MediaPlayer.PlayingState
                             && safariPlayer.playbackState !== MediaPlayer.PausedState
                }

                // ── ERROR STATE (at fsInner level, z:10) ──────────
                Column {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -(Qt.platform.os === "android" ? 40 : 30)
                    spacing: Qt.platform.os === "android" ? 14 : 10
                    z: 10
                    visible: safariTvOverlay.streamError
                             && safariPlayer.playbackState !== MediaPlayer.PlayingState
                             && safariPlayer.playbackState !== MediaPlayer.PausedState

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "⚠"
                        font.pointSize: Qt.platform.os === "android" ? 42 : 34
                        color: "#ffaa00"
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.4; duration: 800 }
                            NumberAnimation { to: 1.0; duration: 800 }
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: fsInner.width * 0.75
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        visible: langSettings.lang === "sw"
                        text: safariTvOverlay.streamErrorMsg === "network"
                              ? "Hitilafu ya mtandao.\nThibitisha muunganiko wako."
                              : "Stream haipatikani kwa sasa."
                        font.pointSize: Qt.platform.os === "android" ? 13 : 10
                        font.bold: true; color: "#ffaa00"
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: fsInner.width * 0.75
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        visible: langSettings.lang === "en"
                        text: safariTvOverlay.streamErrorMsg === "network"
                              ? "Network error. Check your connection."
                              : "Stream unavailable at the moment."
                        font.pointSize: Qt.platform.os === "android" ? 13 : 10
                        font.bold: true; color: "#ffaa00"
                    }
                }

                // ── IDLE STATE (at fsInner level, z:10) ───────────
                Text {
                    anchors.centerIn: parent
                    text: "📡"
                    font.pointSize: Qt.platform.os === "android" ? 40 : 32
                    z: 10
                    visible: !safariTvOverlay.streamError
                             && safariPlayer.playbackState !== MediaPlayer.PlayingState
                             && safariPlayer.playbackState !== MediaPlayer.PausedState
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.4; duration: 1200 }
                        NumberAnimation { to: 1.0; duration: 1200 }
                    }
                }

                // ── Retry button — at fsInner level, above gesture MouseArea ──
                Rectangle {
                    id: fsRetryBtn
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: Qt.platform.os === "android" ? 60 : 46
                    width: fsRetryRow.implicitWidth + (Qt.platform.os === "android" ? 40 : 30)
                    height: Qt.platform.os === "android" ? 52 : 40
                    radius: height / 2
                    z: 10
                    visible: safariTvOverlay.streamError
                             && safariPlayer.playbackState !== MediaPlayer.PlayingState
                             && safariPlayer.playbackState !== MediaPlayer.PausedState
                    color: fsRetryMA.pressed ? "#3a2200" : "#1a0e00"
                    border.color: fsRetryMA.pressed ? "#ffcc00" : "#ffaa00"
                    border.width: fsRetryMA.pressed ? 3 : 2
                    opacity: fsRetryMA.pressed ? 0.7 : 1.0
                    Behavior on color        { ColorAnimation  { duration: 80 } }
                    Behavior on border.color { ColorAnimation  { duration: 80 } }
                    Behavior on border.width { NumberAnimation { duration: 80 } }
                    Behavior on opacity      { NumberAnimation { duration: 80 } }
                    Rectangle {
                        anchors.fill: parent; radius: parent.radius
                        color: Qt.rgba(1, 0.7, 0, 0.22)
                        opacity: fsRetryMA.pressed ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 80 } }
                    }
                    Row {
                        id: fsRetryRow
                        anchors.centerIn: parent
                        spacing: Qt.platform.os === "android" ? 8 : 6
                        Item {
                            id: fsRetryArrow
                            width: Qt.platform.os === "android" ? 26 : 20
                            height: width
                            anchors.verticalCenter: parent.verticalCenter
                            RotationAnimation on rotation {
                                id: fsRetrySpinAnim
                                from: 0; to: -360
                                duration: 450; running: false
                                easing.type: Easing.OutCubic
                            }
                            Canvas {
                                anchors.fill: parent
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    var cx = width/2; var cy = height/2;
                                    var r = width * 0.36;
                                    ctx.strokeStyle = "#ffaa00";
                                    ctx.lineWidth = width * 0.13;
                                    ctx.lineCap = "round";
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, r, -Math.PI * 0.65, Math.PI * 0.85);
                                    ctx.stroke();
                                    ctx.fillStyle = "#ffaa00";
                                    var ax = cx + r * Math.cos(Math.PI * 0.85);
                                    var ay = cy + r * Math.sin(Math.PI * 0.85);
                                    ctx.beginPath();
                                    ctx.moveTo(ax - width*0.12, ay - height*0.04);
                                    ctx.lineTo(ax + width*0.06, ay + height*0.15);
                                    ctx.lineTo(ax + width*0.13, ay - height*0.12);
                                    ctx.closePath(); ctx.fill();
                                }
                                Component.onCompleted: { requestPaint(); }
                            }
                        }
                        Text {
                            text: langSettings.lang === "sw" ? "Jaribu tena" : "Retry"
                            font.pointSize: Qt.platform.os === "android" ? 14 : 11
                            font.bold: true; color: "#ffaa00"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        id: fsRetryMA
                        anchors.fill: parent
                        onReleased: {
                            fsRetrySpinAnim.restart();
                            safariTvOverlay.streamError = false;
                            safariTvOverlay.streamErrorMsg = "";
                            safariPlayer.stop();
                            safariPlayer.source = "";
                            safariPlayer.source = app.safariChannelStreamURL;
                            safariPlayer.play();
                        }
                    }
                }

                // ── Gestures: tap → toggle UI, double-tap → exit, swipe Y → volume, swipe X → brightness ──
                MouseArea {
                    anchors.fill: parent
                    z: 2
                    propagateComposedEvents: true
                    property real startX: 0
                    property real startY: 0
                    property real startVol: 1.0
                    property real startBright: 1.0
                    property bool isDragging: false
                    property bool isHorizontal: false

                    onPressed: {
                        startX = mouse.x;
                        startY = mouse.y;
                        startVol = safariTvOverlay.tvVolume;
                        startBright = safariTvOverlay.tvBrightness;
                        isDragging = false;
                        isHorizontal = false;
                    }
                    onPositionChanged: {
                        var dx = mouse.x - startX;
                        var dy = mouse.y - startY;
                        if (!isDragging && (Math.abs(dx) > 8 || Math.abs(dy) > 8)) {
                            isDragging = true;
                            isHorizontal = Math.abs(dx) > Math.abs(dy);
                        }
                        if (isDragging) {
                            if (isHorizontal) {
                                var db = dx / (fsInner.width * 0.8);
                                safariTvOverlay.tvBrightness = Math.max(0.1, Math.min(1.0, startBright + db));
                                fsBrightOverlay.show();
                            } else {
                                var dv = (startY - mouse.y) / (fsInner.height * 0.8);
                                safariTvOverlay.tvVolume = Math.max(0.0, Math.min(1.0, startVol + dv));
                                fsVolOverlay.show();
                            }
                        }
                    }
                    onClicked: {
                        if (!isDragging) {
                            fsLayer.fsUiVisible = !fsLayer.fsUiVisible;
                        }
                    }
                    onDoubleClicked: {
                        if (!isDragging) {
                            safariTvOverlay.tvFullScreen = false;
                            fsLayer.videoRotation = 0;
                        }
                    }
                }

                // ── Auto-hide timer ────────────────────────────────
                Timer {
                    id: fsAutoHideTimer
                    interval: 4000
                    running: safariTvOverlay.tvFullScreen
                             && safariPlayer.playbackState === MediaPlayer.PlayingState
                             && fsLayer.fsUiVisible
                    onTriggered: { fsLayer.fsUiVisible = false; }
                }

                // ── LIVE badge (top-left) ──────────────────────────
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: Qt.platform.os === "android" ? 14 : 10
                    anchors.leftMargin: Qt.platform.os === "android" ? 14 : 10
                    width: fsBadgeRow.implicitWidth + 20
                    height: Qt.platform.os === "android" ? 30 : 24
                    radius: height / 2
                    z: 10
                    visible: fsLayer.fsUiVisible
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(0, 0.25, 0.22, 0.92) }
                        GradientStop { position: 1.0; color: Qt.rgba(0, 0.12, 0.10, 0.85) }
                    }
                    border.color: Qt.rgba(0, 1, 1, 0.5); border.width: 1
                    Row {
                        id: fsBadgeRow
                        anchors.centerIn: parent
                        spacing: 6
                        Item {
                            width: Qt.platform.os === "android" ? 12 : 10
                            height: width
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width * 1.8; height: width; radius: width / 2
                                color: "#ff2222"; opacity: 0.25
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.05; duration: 600 }
                                    NumberAnimation { to: 0.30; duration: 600 }
                                }
                            }
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width; height: width; radius: width / 2
                                color: "#ff3333"
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.3; duration: 600 }
                                    NumberAnimation { to: 1.0; duration: 600 }
                                }
                            }
                        }
                        Text {
                            text: langSettings.lang === "sw" ? "🇹🇿 MOJA KWA MOJA  ·  Tanzania Safari Channel" : "🇹🇿 LIVE  ·  Tanzania Safari Channel"
                            font.pointSize: Qt.platform.os === "android" ? 9 : 7
                            font.bold: true; color: "cyan"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // ── Stream quality dots ──────────────
                        Row {
                            spacing: Qt.platform.os === "android" ? 3 : 2
                            anchors.verticalCenter: parent.verticalCenter

                            Repeater {
                                model: 3
                                Rectangle {
                                    width: Qt.platform.os === "android" ? 5 : 4
                                    height: width; radius: width / 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: {
                                        var q = safariPlayer.streamQuality;
                                        if (safariPlayer.playbackState !== MediaPlayer.PlayingState)
                                            return "#333333";
                                        if (q === 2) return "#44ff44";
                                        if (q === 1) return index < 2 ? "#ffaa00" : "#333333";
                                        return index < 1 ? "#ff4444" : "#333333";
                                    }
                                    Behavior on color { ColorAnimation { duration: 400 } }
                                }
                            }
                        }
                    }
                }

                // ── Channel info card — anchored centre ───────────────
                Rectangle {
                    id: channelInfoCard
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: channelInfoCard.opacity > 0 ? 0 : -(Qt.platform.os === "android" ? 40 : 30)
                    width: channelInfoCol.implicitWidth + (Qt.platform.os === "android" ? 56 : 42)
                    height: channelInfoCol.implicitHeight + (Qt.platform.os === "android" ? 28 : 20)
                    radius: Qt.platform.os === "android" ? 22 : 16
                    color: Qt.rgba(0, 0.08, 0.07, 0.94)
                    border.color: Qt.rgba(0, 1, 1, 0.55); border.width: 2
                    z: 20
                    opacity: 0.0
                    scale: opacity > 0 ? 1.0 : 0.85
                    Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                    Behavior on scale  { NumberAnimation { duration: 400; easing.type: Easing.OutBack  } }
                    Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

                    // Subtle inner glow line
                    Rectangle {
                        anchors.fill: parent; radius: parent.radius
                        color: "transparent"
                        border.color: Qt.rgba(0, 1, 1, 0.12); border.width: 6
                    }

                    function show() {
                        clockTimer.running = true;
                        channelInfoCard.updateClock();
                        opacity = 1.0;
                        channelHideTimer.restart();
                    }

                    function updateClock() {
                        var d = new Date();
                        var h = d.getHours();
                        var m = d.getMinutes();
                        var ampm = h >= 12 ? "PM" : "AM";
                        h = h % 12;
                        if (h === 0) h = 12;
                        clockText.text = h + ":" + (m < 10 ? "0" + m : m) + " " + ampm;
                    }

                    Timer {
                        id: channelHideTimer
                        interval: 4500
                        onTriggered: {
                            channelInfoCard.opacity = 0.0;
                            clockTimer.running = false;
                        }
                    }
                    Timer {
                        id: clockTimer
                        interval: 1000; repeat: true; running: false
                        onTriggered: { channelInfoCard.updateClock(); }
                    }

                    Column {
                        id: channelInfoCol
                        anchors.centerIn: parent
                        spacing: Qt.platform.os === "android" ? 7 : 5

                        // Flag + channel name row
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: Qt.platform.os === "android" ? 10 : 8
                            Text {
                                text: "🇹🇿"
                                font.pointSize: Qt.platform.os === "android" ? 22 : 17
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "Tanzania Safari Channel"
                                font.pointSize: Qt.platform.os === "android" ? 17 : 13
                                font.bold: true; color: "cyan"; font.letterSpacing: 0.8
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Divider
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: channelInfoCol.implicitWidth * 0.85
                            height: 1; color: Qt.rgba(0, 1, 1, 0.25)
                        }

                        // LIVE dot + clock row
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: Qt.platform.os === "android" ? 16 : 12

                            Row {
                                spacing: 6
                                anchors.verticalCenter: parent.verticalCenter
                                Rectangle {
                                    width: Qt.platform.os === "android" ? 10 : 8
                                    height: width; radius: width / 2; color: "#ff3333"
                                    anchors.verticalCenter: parent.verticalCenter
                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.2; duration: 600 }
                                        NumberAnimation { to: 1.0; duration: 600 }
                                    }
                                }
                                Text {
                                    text: langSettings.lang === "sw" ? "MOJA KWA MOJA" : "LIVE"
                                    font.pointSize: Qt.platform.os === "android" ? 11 : 9
                                    font.bold: true; color: "#ff5555"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            // Vertical separator
                            Rectangle {
                                width: 1
                                height: Qt.platform.os === "android" ? 18 : 14
                                color: Qt.rgba(0, 1, 1, 0.3)
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Clock
                            Text {
                                id: clockText
                                text: "0:00 AM"
                                font.pointSize: Qt.platform.os === "android" ? 11 : 9
                                font.bold: true; color: "cyan"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Divider
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: channelInfoCol.implicitWidth * 0.85
                            height: 1; color: Qt.rgba(0, 1, 1, 0.25)
                        }

                        // Channel numbers — row 1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "DStv 292  ·  Azam TV 401  ·  Zuku 27"
                            font.pointSize: Qt.platform.os === "android" ? 10 : 8
                            color: "#aaaaaa"; font.italic: true
                        }
                        // Channel numbers — row 2
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "StarTimes 331  ·  Zmux 46  ·  Continental 7"
                            font.pointSize: Qt.platform.os === "android" ? 10 : 8
                            color: "#aaaaaa"; font.italic: true
                        }
                    }
                }

                // ── Gesture hints overlay (shown once on fullscreen entry) ──
                Rectangle {
                    id: gestureHintsCard
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: gestureHintsCard.opacity > 0 ? 0 : (Qt.platform.os === "android" ? 40 : 30)
                    width: parent.width * 0.82
                    height: gestureHintsCol.implicitHeight + (Qt.platform.os === "android" ? 36 : 26)
                    radius: Qt.platform.os === "android" ? 20 : 15
                    color: Qt.rgba(0, 0.06, 0.05, 0.90)
                    border.color: Qt.rgba(0, 1, 1, 0.28); border.width: 1
                    z: 19
                    opacity: 0.0
                    scale: opacity > 0 ? 1.0 : 0.88
                    Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                    Behavior on scale  { NumberAnimation { duration: 400; easing.type: Easing.OutBack  } }
                    Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

                    property bool shownOnce: false

                    function showIfFirst() {
                        if (!gestureHintsCard.shownOnce) {
                            gestureHintsCard.shownOnce = true;
                            // Subiri channel info card iishe kwanza (4500ms) kisha onyesha
                            gestureDelayTimer.restart();
                        }
                    }

                    Timer {
                        id: gestureDelayTimer
                        interval: 4800
                        onTriggered: {
                            gestureHintsCard.opacity = 1.0;
                        }
                    }

                    Timer {
                        id: gestureHideTimer
                        interval: 4500
                        onTriggered: { gestureHintsCard.opacity = 0.0; }
                    }

                    // Gonga card kuifunga mapema
                    MouseArea {
                        anchors.fill: parent
                        enabled: gestureHintsCard.opacity > 0
                        onClicked: {
                            gestureHideTimer.stop();
                            gestureHintsCard.opacity = 0.0;
                        }
                    }

                    Column {
                        id: gestureHintsCol
                        anchors.centerIn: parent
                        width: parent.width - (Qt.platform.os === "android" ? 32 : 24)
                        spacing: Qt.platform.os === "android" ? 10 : 7

                        // Title
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: langSettings.lang === "sw" ? "Ishara za kugusa" : "Gestures"
                            font.pointSize: Qt.platform.os === "android" ? 10 : 8
                            font.bold: true; color: Qt.rgba(0, 1, 1, 0.75)
                            font.letterSpacing: 0.5
                        }

                        // Divider
                        Rectangle {
                            width: parent.width; height: 1
                            color: Qt.rgba(0, 1, 1, 0.18)
                        }

                        // Hint rows
                        Repeater {
                            model: [
                                { icon: "👆",   sw: "Gonga moja — ficha/onyesha vidhibiti",  en: "Tap — hide / show controls"      },
                                { icon: "👆👆", sw: "Gonga mara mbili — toka fullscreen",    en: "Double-tap — exit fullscreen"    },
                                { icon: "↕",    sw: "Swipe juu/chini — sauti",               en: "Swipe up / down — volume"        },
                                { icon: "↔",    sw: "Swipe kushoto/kulia — mwangaza",         en: "Swipe left / right — brightness" }
                            ]
                            Row {
                                width: gestureHintsCol.width
                                spacing: Qt.platform.os === "android" ? 14 : 10
                                Text {
                                    text: modelData.icon
                                    font.pointSize: Qt.platform.os === "android" ? 18 : 14
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: Qt.platform.os === "android" ? 34 : 26
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: langSettings.lang === "sw" ? modelData.sw : modelData.en
                                    font.pointSize: Qt.platform.os === "android" ? 11 : 8
                                    color: "#dddddd"
                                    width: gestureHintsCol.width - (Qt.platform.os === "android" ? 48 : 36)
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }

                        // Divider
                        Rectangle {
                            width: parent.width; height: 1
                            color: Qt.rgba(0, 1, 1, 0.12)
                        }

                        // Tap to close hint
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: langSettings.lang === "sw" ? "Gonga hapa kufunga" : "Tap to close"
                            font.pointSize: Qt.platform.os === "android" ? 9 : 7
                            color: Qt.rgba(0, 1, 1, 0.40)
                            font.italic: true
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.4; duration: 900 }
                                NumberAnimation { to: 1.0; duration: 900 }
                            }
                        }
                    }
                }

                // ── Fullscreen brightness indicator (left, rotates with fsInner) ──
                Rectangle {
                    id: fsBrightOverlay
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Qt.platform.os === "android" ? 16 : 12
                    width: Qt.platform.os === "android" ? 56 : 44
                    height: Qt.platform.os === "android" ? 200 : 160
                    radius: width / 2
                    color: Qt.rgba(0, 0.08, 0.07, 0.88)
                    border.color: Qt.rgba(1, 0.93, 0, 0.35); border.width: 1
                    z: 30
                    opacity: 0.0
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    function show() {
                        opacity = 1.0;
                        fsBrightHideTimer.restart();
                    }
                    Timer {
                        id: fsBrightHideTimer
                        interval: 1800
                        onTriggered: { fsBrightOverlay.opacity = 0.0; }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: Qt.platform.os === "android" ? 12 : 9
                        text: "☀"
                        font.pointSize: Qt.platform.os === "android" ? 14 : 11
                        color: "#ffee00"
                    }
                    Rectangle {
                        id: fsBrightTrackBg
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: Qt.platform.os === "android" ? 46 : 36
                        anchors.bottomMargin: Qt.platform.os === "android" ? 38 : 30
                        width: Qt.platform.os === "android" ? 10 : 8
                        radius: width / 2
                        color: Qt.rgba(0.6, 0.6, 0, 0.3)
                    }
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: fsBrightTrackBg.bottom
                        width: fsBrightTrackBg.width
                        height: fsBrightTrackBg.height * safariTvOverlay.tvBrightness
                        radius: width / 2
                        color: "#ffee00"
                        Behavior on height { NumberAnimation { duration: 80 } }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Qt.platform.os === "android" ? 10 : 8
                        text: Math.round(safariTvOverlay.tvBrightness * 100) + "%"
                        font.pointSize: Qt.platform.os === "android" ? 11 : 9
                        font.bold: true; color: "#ffee00"
                    }

                    // Click/drag to set brightness
                    MouseArea {
                        anchors.fill: fsBrightTrackBg
                        anchors.margins: -10
                        onPressed: {
                            var level = 1.0 - (mouseY / fsBrightTrackBg.height);
                            safariTvOverlay.tvBrightness = Math.max(0.1, Math.min(1.0, level));
                            fsBrightOverlay.show();
                        }
                        onPositionChanged: {
                            var level = 1.0 - (mouseY / fsBrightTrackBg.height);
                            safariTvOverlay.tvBrightness = Math.max(0.1, Math.min(1.0, level));
                        }
                    }
                }

                // ── Fullscreen volume indicator (right, rotates with fsInner) ──
                Rectangle {
                    id: fsVolOverlay
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: Qt.platform.os === "android" ? 16 : 12
                    width: Qt.platform.os === "android" ? 56 : 44
                    height: Qt.platform.os === "android" ? 200 : 160
                    radius: width / 2
                    color: Qt.rgba(0, 0.08, 0.07, 0.88)
                    border.color: Qt.rgba(0, 1, 1, 0.35); border.width: 1
                    z: 30
                    opacity: 0.0
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    function show() {
                        opacity = 1.0;
                        fsHideTimer.restart();
                    }
                    Timer {
                        id: fsHideTimer
                        interval: 1800
                        onTriggered: { fsVolOverlay.opacity = 0.0; }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: Qt.platform.os === "android" ? 12 : 9
                        text: "🔊"
                        font.pointSize: Qt.platform.os === "android" ? 14 : 11
                    }
                    Rectangle {
                        id: fsVolTrackBg
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: Qt.platform.os === "android" ? 46 : 36
                        anchors.bottomMargin: Qt.platform.os === "android" ? 38 : 30
                        width: Qt.platform.os === "android" ? 10 : 8
                        radius: width / 2
                        color: Qt.rgba(0, 0.3, 0.3, 0.5)
                    }
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: fsVolTrackBg.bottom
                        width: fsVolTrackBg.width
                        height: fsVolTrackBg.height * safariTvOverlay.tvVolume
                        radius: width / 2
                        color: "cyan"
                        Behavior on height { NumberAnimation { duration: 80 } }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Qt.platform.os === "android" ? 10 : 8
                        text: Math.round(safariTvOverlay.tvVolume * 100) + "%"
                        font.pointSize: Qt.platform.os === "android" ? 11 : 9
                        font.bold: true
                        color: "cyan"
                    }

                    // Click/drag to set volume
                    MouseArea {
                        anchors.fill: fsVolTrackBg
                        anchors.margins: -10
                        onPressed: {
                            var level = 1.0 - (mouseY / fsVolTrackBg.height);
                            safariTvOverlay.tvVolume = Math.max(0.0, Math.min(1.0, level));
                            fsVolOverlay.show();
                        }
                        onPositionChanged: {
                            var level = 1.0 - (mouseY / fsVolTrackBg.height);
                            safariTvOverlay.tvVolume = Math.max(0.0, Math.min(1.0, level));
                        }
                    }
                }

                // ── Close button (top-right) ───────────────────────
                Rectangle {
                    id: fsCloseBtn
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: Qt.platform.os === "android" ? 14 : 10
                    anchors.rightMargin: Qt.platform.os === "android" ? 14 : 10
                    width: Qt.platform.os === "android" ? 42 : 34; height: width; radius: width / 2
                    color: fsCloseMA.pressed ? "#1a0a0a" : "#0d0505"
                    border.color: "#cc4444"; border.width: 2
                    z: 10
                    visible: fsLayer.fsUiVisible
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            ctx.strokeStyle = "#ff6666";
                            ctx.lineWidth = width * 0.13;
                            ctx.lineCap = "round";
                            // Draw X using circle radius points at 45° angles
                            var cx = width / 2; var cy = height / 2;
                            var r  = width * 0.28;
                            var d  = r * 0.707; // cos(45°) = sin(45°) = √2/2
                            ctx.beginPath();
                            ctx.moveTo(cx - d, cy - d);
                            ctx.lineTo(cx + d, cy + d);
                            ctx.stroke();
                            ctx.beginPath();
                            ctx.moveTo(cx + d, cy - d);
                            ctx.lineTo(cx - d, cy + d);
                            ctx.stroke();
                        }
                        Component.onCompleted: { requestPaint(); }
                    }
                    MouseArea {
                        id: fsCloseMA
                        anchors.fill: parent
                        onPressed:  fsCloseBtn.scale = 0.9
                        onReleased: {
                            fsCloseBtn.scale = 1.0;
                            safariTvOverlay.tvFullScreen = false;
                            fsLayer.videoRotation = 0;
                            safariPlayer.stop();
                            safariPlayer.source = "";
                            app.safariTvVisible = false;
                            app.selectedLanguage = langSettings.lang;
                            viewComponentLoader.switchTo(languageSelectionComponent, app.width / 2, app.height / 2);
                            app.selectedLanguage = "";
                            app.ad();
                        }
                        onCanceled: fsCloseBtn.scale = 1.0
                    }
                }

                // ── Floating bottom controls bar ───────────────────
                Rectangle {
                    id: fsControlsBar
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottomMargin: Qt.platform.os === "android" ? 18 : 12
                    anchors.leftMargin:   Qt.platform.os === "android" ? 14 : 10
                    anchors.rightMargin:  Qt.platform.os === "android" ? 14 : 10
                    height: Qt.platform.os === "android" ? 72 : 58
                    radius: height / 2
                    color: Qt.rgba(0, 0.08, 0.07, 0.88)
                    border.color: "#1a6060"; border.width: 2
                    z: 10
                    visible: fsLayer.fsUiVisible
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Item {
                        anchors.fill: parent
                        property int sz: Qt.platform.os === "android" ? 46 : 36
                        property int sp: Qt.platform.os === "android" ? 20 : 15

                        // ── Centre group: Stop + Play + Volume ────────────
                        Row {
                            anchors.centerIn: parent
                            spacing: parent.sp
                            property int sz: parent.sz
                            property int sp: parent.sp

                            // STOP
                            Rectangle {
                                id: fsStopBtn
                                width: parent.sz; height: parent.sz; radius: parent.sz / 2
                                anchors.verticalCenter: parent.verticalCenter
                                color: fsStopMA.pressed ? "#1a0a0a" : "#0d0505"
                                border.color: "#cc4444"; border.width: 2
                                Behavior on color { ColorAnimation { duration: 100 } }
                                Behavior on scale { NumberAnimation { duration: 100 } }
                                Canvas {
                                    anchors.fill: parent
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.clearRect(0, 0, width, height);
                                        var s = width * 0.34;
                                        ctx.fillStyle = "#cc4444";
                                        ctx.fillRect(width/2 - s/2, height/2 - s/2, s, s);
                                    }
                                    Component.onCompleted: { requestPaint(); }
                                }
                                MouseArea {
                                    id: fsStopMA; anchors.fill: parent
                                    onPressed:  fsStopBtn.scale = 0.9
                                    onReleased: { fsStopBtn.scale = 1.0; safariPlayer.stop(); }
                                    onCanceled: fsStopBtn.scale = 1.0
                                }
                            }

                            // PLAY / PAUSE
                            Item {
                                width: parent.sz * 1.3; height: parent.sz * 1.3
                                // Glow rings
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width + (Qt.platform.os === "android" ? 16 : 12)
                                    height: width; radius: width / 2
                                    color: "transparent"
                                    border.color: "cyan"; border.width: Qt.platform.os === "android" ? 3 : 2
                                    opacity: fsPlayMA.pressed ? 0.7 : 0.0
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                }
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width + (Qt.platform.os === "android" ? 30 : 24)
                                    height: width; radius: width / 2
                                    color: "transparent"
                                    border.color: "cyan"; border.width: Qt.platform.os === "android" ? 2 : 1
                                    opacity: fsPlayMA.pressed ? 0.25 : 0.0
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                }
                                Rectangle {
                                    id: fsPlayBtn
                                    anchors.centerIn: parent
                                    width: parent.width; height: parent.height
                                    radius: width / 2
                                    color: fsPlayMA.pressed ? "#1a6060" : "#0d3a38"
                                    border.color: "cyan"; border.width: 3
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                    Behavior on scale { NumberAnimation { duration: 100 } }
                                    Canvas {
                                        id: fsPlayIconCanvas
                                        anchors.fill: parent
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.clearRect(0, 0, width, height);
                                            ctx.fillStyle = "cyan";
                                            var cx = width / 2; var cy = height / 2;
                                            var playing = safariPlayer.playbackState === MediaPlayer.PlayingState;
                                            if (playing) {
                                                var bw = width * 0.12; var bh = height * 0.42; var gap = width * 0.10;
                                                ctx.fillRect(cx - gap/2 - bw, cy - bh/2, bw, bh);
                                                ctx.fillRect(cx + gap/2,       cy - bh/2, bw, bh);
                                            } else {
                                                var tw = width * 0.38; var th = height * 0.44;
                                                ctx.beginPath();
                                                ctx.moveTo(cx - tw/2 + width*0.03, cy - th/2);
                                                ctx.lineTo(cx + tw/2 + width*0.03, cy);
                                                ctx.lineTo(cx - tw/2 + width*0.03, cy + th/2);
                                                ctx.closePath(); ctx.fill();
                                            }
                                        }
                                        Component.onCompleted: { requestPaint(); }
                                        Connections {
                                            target: safariPlayer
                                            onPlaybackStateChanged: { fsPlayIconCanvas.requestPaint(); }
                                        }
                                    }
                                    MouseArea {
                                        id: fsPlayMA; anchors.fill: parent
                                        onPressed:  fsPlayBtn.scale = 0.9
                                        onReleased: {
                                            fsPlayBtn.scale = 1.0;
                                            if (safariPlayer.playbackState === MediaPlayer.PlayingState) {
                                                safariPlayer.pause();
                                            } else {
                                                safariPlayer.play();
                                            }
                                        }
                                        onCanceled: fsPlayBtn.scale = 1.0
                                    }
                                }
                            }

                            // VOLUME
                            Rectangle {
                                id: fsVolBtn
                                width: parent.sz; height: parent.sz; radius: parent.sz / 2
                                anchors.verticalCenter: parent.verticalCenter
                                color: fsVolMA.pressed ? "#1a6060" : "#0d3a38"
                                border.color: "cyan"; border.width: 2
                                Behavior on color { ColorAnimation { duration: 100 } }
                                Behavior on scale { NumberAnimation { duration: 100 } }
                                Canvas {
                                    id: fsVolIconCanvas
                                    anchors.fill: parent
                                    property bool muted: safariPlayer.muted
                                    onMutedChanged: { requestPaint(); }
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.clearRect(0, 0, width, height);
                                        var cx = width * 0.38; var cy = height / 2;
                                        var bh = height * 0.38; var bw = width * 0.22;
                                        ctx.save();
                                        ctx.translate(width/2, cy); ctx.scale(0.75, 0.75); ctx.translate(-width/2, -cy);
                                        ctx.fillStyle = "cyan";
                                        ctx.beginPath();
                                        ctx.moveTo(cx - bw, cy - bh * 0.5);
                                        ctx.lineTo(cx, cy - bh * 0.5);
                                        ctx.lineTo(cx + bw * 0.7, cy - bh);
                                        ctx.lineTo(cx + bw * 0.7, cy + bh);
                                        ctx.lineTo(cx, cy + bh * 0.5);
                                        ctx.lineTo(cx - bw, cy + bh * 0.5);
                                        ctx.closePath(); ctx.fill();
                                        if (!muted) {
                                            ctx.lineWidth = width * 0.08;
                                            ctx.lineCap = "round";
                                            ctx.strokeStyle = "cyan";
                                            ctx.beginPath();
                                            ctx.arc(cx + bw * 0.7, cy, width * 0.16, -Math.PI * 0.5, Math.PI * 0.5);
                                            ctx.stroke();
                                            ctx.beginPath();
                                            ctx.arc(cx + bw * 0.7, cy, width * 0.28, -Math.PI * 0.5, Math.PI * 0.5);
                                            ctx.stroke();
                                        } else {
                                            ctx.lineWidth = width * 0.10;
                                            ctx.lineCap = "round";
                                            ctx.strokeStyle = "#cc4444";
                                            ctx.beginPath();
                                            ctx.moveTo(cx + bw * 1.1, cy - height * 0.22);
                                            ctx.lineTo(cx + bw * 1.8, cy + height * 0.22);
                                            ctx.stroke();
                                            ctx.beginPath();
                                            ctx.moveTo(cx + bw * 1.8, cy - height * 0.22);
                                            ctx.lineTo(cx + bw * 1.1, cy + height * 0.22);
                                            ctx.stroke();
                                        }
                                        ctx.restore();
                                    }
                                    Component.onCompleted: { requestPaint(); }
                                }
                                MouseArea {
                                    id: fsVolMA; anchors.fill: parent
                                    onPressed:  fsVolBtn.scale = 0.9
                                    onReleased: {
                                        fsVolBtn.scale = 1.0;
                                        safariPlayer.muted = !safariPlayer.muted;
                                        fsVolIconCanvas.requestPaint();
                                    }
                                    onCanceled: fsVolBtn.scale = 1.0
                                }
                            }

                        } // end centre Row

                        // ── ROTATE — anchored to right ─────────────────────
                        Rectangle {
                            id: fsRotBtn
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: Qt.platform.os === "android" ? 14 : 10
                            width: parent.sz; height: parent.sz; radius: parent.sz / 2
                            color: fsRotMA.pressed ? "#1a6060" : "#0d3a38"
                            border.color: "cyan"; border.width: 2
                            Behavior on color { ColorAnimation { duration: 100 } }
                            Behavior on scale { NumberAnimation { duration: 100 } }
                            Canvas {
                                anchors.fill: parent
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    var cx = width / 2; var cy = height / 2;
                                    ctx.save();
                                    ctx.translate(cx, cy); ctx.scale(0.75, 0.75); ctx.translate(-cx, -cy);
                                    ctx.strokeStyle = "cyan";
                                    ctx.lineWidth = width * 0.10;
                                    ctx.lineCap = "round";
                                    var r = width * 0.32;
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, r, -Math.PI * 0.75, Math.PI * 0.75);
                                    ctx.stroke();
                                    ctx.fillStyle = "cyan";
                                    var ax = cx + r * Math.cos(Math.PI * 0.75);
                                    var ay = cy + r * Math.sin(Math.PI * 0.75);
                                    ctx.beginPath();
                                    ctx.moveTo(ax - width * 0.12, ay - height * 0.03);
                                    ctx.lineTo(ax + width * 0.05, ay + height * 0.14);
                                    ctx.lineTo(ax + width * 0.12, ay - height * 0.12);
                                    ctx.closePath(); ctx.fill();
                                    ctx.restore();
                                }
                                Component.onCompleted: { requestPaint(); }
                            }
                            MouseArea {
                                id: fsRotMA; anchors.fill: parent
                                onPressed:  fsRotBtn.scale = 0.9
                                onReleased: {
                                    fsRotBtn.scale = 1.0;
                                    fsLayer.videoRotation = (fsLayer.videoRotation + 90) % 360;
                                }
                                onCanceled: fsRotBtn.scale = 1.0
                            }
                        }

                    } // end controls Item
                }
            } // end fsInner
        }
        // ── END FULLSCREEN VIDEO LAYER ─────────────────────────────

        // ── Close button (normal TV mode only) ─────────────────────
        Rectangle {
            id: tvCloseBtn
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Qt.platform.os === "android" ? 14 : 10
            anchors.rightMargin: Qt.platform.os === "android" ? 14 : 10
            width: Qt.platform.os === "android" ? 42 : 34; height: width; radius: width / 2
            color: tvCloseMA.pressed ? "#1a0a0a" : "#0d0505"
            border.color: "#cc4444"; border.width: 2
            visible: !safariTvOverlay.tvFullScreen
            z: 20
            Behavior on color { ColorAnimation { duration: 100 } }
            Behavior on scale { NumberAnimation { duration: 100 } }

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.strokeStyle = "#ff6666";
                    ctx.lineWidth = width * 0.13;
                    ctx.lineCap = "round";
                    var cx = width / 2; var cy = height / 2;
                    var r  = width * 0.28;
                    var d  = r * 0.707;
                    ctx.beginPath();
                    ctx.moveTo(cx - d, cy - d);
                    ctx.lineTo(cx + d, cy + d);
                    ctx.stroke();
                    ctx.beginPath();
                    ctx.moveTo(cx + d, cy - d);
                    ctx.lineTo(cx - d, cy + d);
                    ctx.stroke();
                }
                Component.onCompleted: { requestPaint(); }
            }
            MouseArea {
                id: tvCloseMA
                anchors.fill: parent
                onPressed:  tvCloseBtn.scale = 0.9
                onReleased: {
                    tvCloseBtn.scale = 1.0;
                    safariPlayer.stop();
                    safariPlayer.source = "";
                    app.safariTvVisible = false;
                    app.selectedLanguage = langSettings.lang;
                    viewComponentLoader.switchTo(languageSelectionComponent, app.width / 2, app.height / 2);
                    app.selectedLanguage = "";
                    app.ad();
                }
                onCanceled: tvCloseBtn.scale = 1.0
            }
        }
    }
    // ════════════════════════════════════════════════════════════════

} // end root Rectangle
