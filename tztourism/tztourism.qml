import QtQuick 2.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

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



    // ── Android back button ────────────────────────────────────────────
    Keys.onBackPressed: {
        if (contextMenu.visible) {
            contextMenu.close();
            event.accepted = true;
        } else if (modeSelectionDialog.visible) {
            modeSelectionDialog.close();
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
            name_en: "Zanzibar (Stone Town & Beaches)"; name_sw: "Zanzibar (Mji Mkongwe na Fukwe)"
            imageFile: "./zanzibar_st2.jpg"
            desc_en: "Historic Stone Town, spice farms, and pristine beaches make Zanzibar a unique cultural and relaxation hub."
            desc_sw: "Mji Mkongwe wa kihistoria, mashamba ya viungo, na fukwe safi hufanya Zanzibar kuwa kitovu cha kipekee cha utamaduni na mapumziko."
        }

        ListElement {
            name_en: "Kizimkazi Dolphin Safari"; name_sw: "Utalii wa Pomboo Kizimkazi"
            imageFile: "./kizimkazi-d.jpeg"
            desc_en: "Dive into the blue waters of Kizimkazi, Zanzibar. Experience the thrill of swimming with wild dolphins in their natural habitat and visit historical mosques."
            desc_sw: "Zama kwenye maji ya bluu ya Kizimkazi, Zanzibar. Shuhudia msisimko wa kuogelea na pomboo katika mazingira yao ya asili na utembelee misikiti ya kihistoria."
        }


ListElement {
    name_en: "The Art of Henna (Piko), Zanzibar"; 
    name_sw: "Sanaa ya Piko (Henna), Zanzibar"
    image_file: "./zanzibar_henna.png"
    desc_en: "A beautiful Swahili tradition where intricate floral and geometric patterns are painted on hands and feet using natural henna, often for weddings and festivals."
    desc_sw: "Utamaduni maridadi wa Kiswahili ambapo michoro ya maua na nakshi huchorwa mikononi na miguuni kwa kutumia piko asilia, mara nyingi wakati wa harusi na sherehe."
}

        ListElement {
            name_en: "Lake Victoria"; name_sw: "Ziwa Victoria"
            imageFile: "./victoria.jpg"
            desc_en: "Experience Lake Victoria, Mwanza: Africa's largest lake. Enjoy stunning sunsets over Bismarck Rock, island safaris, and vibrant local culture. A true Tanzanian gem!"
            desc_sw: "Furahia Ziwa Victoria, Mwanza: Ziwa kubwa Afrika. Tazama machweo mazuri juu ya Mwamba Bismarck, safari za visiwa, na utamaduni hai. Hazina halisi ya Tanzania!"
        }

        ListElement {
            name_en: "Rubya Forest, Ukerewe"; name_sw: "Msitu wa Rubya, Ukerewe"
            imageFile: "./rubya.jpeg"
            desc_en: "Discover the hidden tranquility of Ukerewe Island. Explore the lush Rubya Forest and enjoy the serene beaches of Africa's largest inland island."
            desc_sw: "Gundua utulivu wa siri wa Kisiwa cha Ukerewe. Pekua Msitu mnene wa Rubya na ufurahie fukwe tulivu za kisiwa kikubwa zaidi cha ndani nchini Afrika."
        }

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
            name_en: "Serengeti National Park"; name_sw: "Hifadhi ya Taifa ya Serengeti"
            imageFile: "./serengeti.jpg"
            desc_en: "Vast plains, famous for the annual wildebeest migration, offering unparalleled safari experiences."
            desc_sw: "Nyanda pana, maarufu kwa uhamaji mkuu wa nyumbu kila mwaka, inayotoa uzoefu wa safari usio na kifani."
        }

        ListElement {
            name_en: "Ngorongoro Conservation Area"; name_sw: "Mamlaka ya Hifadhi ya Ngorongoro"
            imageFile: "./ngorongoro.jpg"
            desc_en: "Home to the Ngorongoro Crater, a large volcanic caldera teeming with diverse wildlife."
            desc_sw: "Makao ya Kreta ya Ngorongoro, kaldera kubwa ya volkano iliyojaa wanyamapori mbalimbali."
        }

        ListElement {
            name_en: "Tarangire National Park"; name_sw: "Hifadhi ya Taifa ya Tarangire"
            imageFile: "./tarangire.jpg"
            desc_en: "Known for its large elephant herds, iconic baobab trees, and diverse birdlife."
            desc_sw: "Inajulikana kwa makundi makubwa ya tembo, miti ya mibuyu ya kipekee, na aina mbalimbali za ndege."
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
            name_en: "Mafia Island Marine Park"; name_sw: "Hifadhi ya Bahari ya Kisiwa cha Mafia"
            imageFile: "./mafia_island.jpg"
            desc_en: "Pristine coral reefs, a haven for divers and snorkelers, and a seasonal home for whale sharks."
            desc_sw: "Miamba ya matumbawe safi, kimbilio la wapiga mbizi, na makazi ya msimu ya papa nyangumi."
        }

        ListElement {
            name_en: "Katavi National Park"; name_sw: "Hifadhi ya Taifa ya Katavi"
            imageFile: "./katavi.jpg"
            desc_en: "A remote and wild park known for large concentrations of game during the dry season."
            desc_sw: "Hifadhi ya mbali na pori inayojulikana kwa mikusanyiko mikubwa ya wanyama wakati wa kiangazi."
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
            name_en: "Amboni Caves"; name_sw: "Mapango ya Amboni"
            imageFile: "./amboni_caves.jpg"
            desc_en: "A vast limestone cave system near Tanga, significant culturally and historically, with impressive formations."
            desc_sw: "Mfumo mkubwa wa mapango ya chokaa karibu na Tanga, muhimu kiutamaduni na kihistoria, na maumbo ya kuvutia."
        }

        ListElement {
            name_en: "Kitulo National Park"; name_sw: "Hifadhi ya Taifa ya Kitulo"
            imageFile: "./kitulo.jpg"
            desc_en: "Known as the 'Garden of God', this unique montane grassland is famous for its spectacular seasonal wildflower displays."
            desc_sw: "Inajulikana kama 'Bustani ya Mungu', nyanda hii ya kipekee ya milimani ni maarufu kwa maonyesho yake mazuri ya maua ya porini ya msimu."
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
            opacity: 0
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
                        text: modeSelectionDialog.lag === "sw" ? "X  Funga" : "X  Close"
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
                Text { anchors.centerIn: parent; text: contextMenu.detailLang === "sw" ? "x Funga" : "x Close"; font.pointSize: Qt.platform.os === "android" ? 12 : 9; font.bold: true; color: "white" }
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

                        // Hero background image
                        AnimatedImage {
                            anchors.fill: parent
                            source: "./tzflag.gif"
                            fillMode: Image.PreserveAspectCrop
                        }

                        // Dark gradient over hero
                        Rectangle {
                            anchors.fill: parent
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#88000000" }
                                GradientStop { position: 0.6; color: "#44000000" }
                                GradientStop { position: 1.0; color: "#dd001413" }
                            }
                        }

                        // Hero text
                        Column {
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 20
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            spacing: 6

                            Text {
                                text: "🌍 Tanzania Tourism"
                                font.pointSize: Qt.platform.os === "android" ? 22 : 18
                                font.bold: true
                                color: "white"
                            }

                            Text {
                                text: "Utalii wa Tanzania"
                                font.pointSize: Qt.platform.os === "android" ? 15 : 12
                                color: "cyan"
                                font.bold: true
                            }

                            // Cyan underline accent
                            Rectangle {
                                width: 60
                                height: 3
                                radius: 2
                                color: "cyan"
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

                            // Attractions count
                            Column {
                                width: app.width * 0.5
                                spacing: 2
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: attractionModel.count + "+"
                                    font.pointSize: Qt.platform.os === "android" ? 16 : 13
                                    font.bold: true
                                    color: "cyan"
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Vivutio · Attractions"
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
                                    text: "Parks · Culture · Coast"
                                    font.pointSize: Qt.platform.os === "android" ? 10 : 8
                                    color: "#aaaaaa"
                                }
                            }
                        }
                    }

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
                            text: "Kusafiri ni elimu. Tembelea hifadhi za Tanzania, jifunze thamani ya mazingira ya Tanzania, na uwe balozi wa uzuri wa Tanzania.\n\nTravel is a form of learning. Explore Tanzania's national parks, discover the value of our environment, and become an ambassador for the beauty of Tanzania."
                            font.pointSize: Qt.platform.os === "android" ? 12 : 10
                            color: "#cccccc"
                            wrapMode: Text.WordWrap
                            font.italic: true
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
                            text: "Ramani ya Tanzania  ·  Map of Tanzania"
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

                    // ══ WILDLIFE IMAGES SIDE BY SIDE ══════════════════════
                    Rectangle {
                        width: app.width
                        height: imgRow.height
                        color: "#001413"

                        Row {
                            id: imgRow
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 6

                            Image {
                                source: "./wanyama-tz-3.png"
                                width: (app.width - 18) / 2
                                height: implicitHeight > 0 ? width * implicitHeight / implicitWidth : width
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            Image {
                                source: "./wanyama-tz-3-b.png"
                                width: (app.width - 18) / 2
                                height: implicitHeight > 0 ? width * implicitHeight / implicitWidth : width
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }
                        }
                    }

                    // ══ ATTRACTION OF THE DAY ══════════════════════════════
                    Rectangle {
                        id: aotdSection
                        property string lag:""
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

                        Component.onCompleted: {
                            if(app.selectedLanguage === ""){
                                aotdSection.lag = (Math.random() < 0.5) ? "sw" : "en";
                            } else {
                                aotdSection.lag = app.selectedLanguage;
                            }
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
                                    text: aotdSection.lag === "sw"
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
                                              ? (aotdSection.lag === "sw"
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
                                              ? (aotdSection.lag === "sw"
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
                                        color: aotdSection.lag === "sw" ? "green" : "blue"
                                        property bool pressed: false
                                        scale: pressed ? 0.95 : 1.0
                                        Behavior on scale { NumberAnimation { duration: 100 } }

                                        Text {
                                            id: aotdBtnTxt
                                            anchors.centerIn: parent
                                            text: aotdSection.lag === "sw" ? "Chunguza →" : "Explore →"
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
                                                aotdSection.lag = aotdSection.lag || "en";
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
                                                        aotdSection.lag || "en",
                                                        aotdSection.lag === "sw" ? a.name_sw : a.name_en,
                                                        aotdSection.lag === "sw" ? a.desc_sw : a.desc_en,
                                                        a.imageFile,
                                                        aotdSection.todayIdx
                                                        );
                                        }
                                    }
                                }
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

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Chagua lugha yako · Choose your language"
                                font.pointSize: Qt.platform.os === "android" ? 12 : 10
                                color: "#888888"
                            }

                            // Swahili button
                            Rectangle {
                                id: swBtn
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
                                        Text { text: "Mchezo wa Utalii"; font.pointSize: Qt.platform.os === "android" ? 13 : 11; font.bold: true; color: "white" }
                                        Text { text: "Tourism Memory Game"; font.pointSize: Qt.platform.os === "android" ? 11 : 9; color: "#aaaaaa" }
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
                                    onReleased: { gameBtn.pressed = false; gameLangDialog.doOpen(mouse.x + gameBtn.x, mouse.y + gameBtn.y); }
                                    onCanceled: gameBtn.pressed = false
                                }
                            }

                            // 🎲 Surprise me button
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
                                        text: "Nishangaze!  ·  Surprise me!"
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
                            }
                        }
                    }

                    // ══ SAFARI CHANNEL INFO ════════════════════════════════
                    Rectangle {
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
                                width: parent.width
                                text: "Tanzania imebarikiwa kuwa na vivutio vingi vya utalii ambavyo ni vigumu kuvitaja vyote hapa. Ili kuvifahamu na kuvishuhudia kwa undani zaidi, tunakushauri kufuatilia Tanzania Safari Channel inayopatikana kupitia DStv (292), Azam TV (401), Zuku (27), StarTimes Antenna (331), StarTimes Dish (542), Zmux (46) na Continental (7). Huu ni mlango wako wa kidijitali wa kutembelea mbuga za wanyama, fukwe, na urithi wa kitamaduni wa nchi yetu ukiwa nyumbani kwako.\n\nTanzania is home to an overwhelming number of tourist attractions that cannot be fully listed here. For a more immersive experience, we highly recommend watching the Tanzania Safari Channel, available on DStv (292), Azam TV (401), Zuku (27), StarTimes Antenna (331), StarTimes Dish (542), Zmux (46) and Continental (7)."
                                font.pointSize: Qt.platform.os === "android" ? 12 : 10
                                color: "#cccccc"
                                wrapMode: Text.WordWrap

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        /*
                                        if(typeof n3ctaApp !== "undefined"){
                                            n3ctaApp.pasteToClipboard("8647491");
                                            n3ctaApp.showToastMessage("Namba ya changisha imenakiliwa.");
                                        }else if(typeof loader !== "undefined"){
                                            loader.pasteToClipboard("8647491");
                                            loader.showToastMessage("Changisha number copied.");
                                        } */
                                    }
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
                                text: "X  Funga / Close"
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
                        text: "Image not found"
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
                        color: app.selectedLanguage === "sw" ? "#bb006600" : "#bb000088"
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
                color: app.selectedLanguage === "sw" ? "green" : "blue"
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
                    placeholderText: app.selectedLanguage === "sw" ? "Tafuta..." : "Search..."
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
                        text: "‹ Prev"
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
                    property color frozenColor: app.selectedLanguage === "sw" ? "#88006600" : "#880000aa"
                    color: frozenColor
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
                            homeBtn.frozenColor = app.selectedLanguage === "sw" ? "#88006600" : "#880000aa";
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
                        text: "Next ›"
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
                    opacity: 0
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
            opacity: 0
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
                    Text { anchors.centerIn: parent; text: "X  Funga / Close"; font.pointSize: Qt.platform.os === "android" ? 13 : 11; font.bold: true; color: "white" }
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
                                app.selectedLanguage = app.gameLang; //for ripple color to be correct
                                viewComponentLoader.switchTo(languageSelectionComponent, app.width / 2, app.height / 2);
                            }
                            onCanceled: winBackBtn.scale = 1.0
                        }
                    }
                }
            }
        }
    }

} // end root Rectangle
