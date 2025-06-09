import QtQuick 2.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

Rectangle {
    id: app
    width: parent.width
    height: parent.height
    color: "transparent"

    property string selectedLanguage: "" // "en" or "sw"
    property int currentAttractionIndex: 0

     function close()
    {
        if(typeof n3ctaApp !== "undefined"){
            n3ctaApp.closeCustomPage();
            n3ctaApp.onUrlVisited("#showGoogleAd");
        }else if(typeof loader !== "undefined"){
            loader.closeCustomPage();
            loader.onUrlVisited("#showGoogleAd");
        }
    }

    ListModel {
        id: attractionModel
        ListElement {
            name_en: "Lake Victoria"; name_sw: "Ziwa Victoria"
            imageFile: "./victoria.jpg"
            desc_en: "Experience Lake Victoria, Mwanza: Africa's largest lake. Enjoy stunning sunsets over Bismarck Rock, island safaris, and vibrant local culture. A true Tanzanian gem!"
            desc_sw: "Furahia Ziwa Victoria, Mwanza: Ziwa kubwa Afrika. Tazama machweo mazuri juu ya Mwamba Bismarck, safari za visiwa, na utamaduni hai. Hazina halisi ya Tanzania!"
        }
ListElement {
            name_en: "Rubondo Island National Park"; name_sw: "Hifadhi ya Taifa ya Kisiwa cha Rubondo"
            imageFile: "./rubondo.jpg"
            desc_en: "An island sanctuary on Lake Victoria, home to elephats, chimpanzees, sitatunga, and a diverse birdlife, ideal for walking safaris."
            desc_sw: "Hifadhi ya kisiwa kwenye Ziwa Victoria, makazi ya tembo, sokwe, sitatunga, na ndege mbalimbali, inayofaa kwa safari za kutembea."
        }

        ListElement {
            name_en: "Serengeti National Park"; name_sw: "Hifadhi ya Taifa ya Serengeti"
            imageFile: "./serengeti.jpg"
            desc_en: "Vast plains, famous for the annual wildebeest migration, offering unparalleled safari experiences."
            desc_sw: "Nyanda pana, maarufu kwa uhamaji mkuu wa nyumbu kila mwaka, inayotoa uzoefu wa safari usio na kifani."
        }
        ListElement {
            name_en: "Mount Kilimanjaro"; name_sw: "Mlima Kilimanjaro"
            imageFile: "./kilimanjaro.jpg"
            desc_en: "Africa's highest peak and a dormant volcano. A challenging but rewarding climb for adventurers."
            desc_sw: "Mlima mrefu zaidi Afrika na volkano iliyolala. Changamoto lakini yenye thawabu kwa wapandaji wajasiri."
        }
        ListElement {
            name_en: "Ngorongoro Conservation Area"; name_sw: "Mamlaka ya Hifadhi ya Ngorongoro"
            imageFile: "./ngorongoro.jpg"
            desc_en: "Home to the Ngorongoro Crater, a large volcanic caldera teeming with diverse wildlife."
            desc_sw: "Makao ya Kreta ya Ngorongoro, kaldera kubwa ya volkano iliyojaa wanyamapori mbalimbali."
        }
        ListElement {
            name_en: "Zanzibar (Stone Town & Beaches)"; name_sw: "Zanzibar (Mji Mkongwe na Fukwe)"
            imageFile: "./zanzibar_st.jpg"
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
            name_en: "Lake Manyara National Park"; name_sw: "Hifadhi ya Taifa ya Ziwa Manyara"
            imageFile: "./manyara.jpg"
            desc_en: "Famous for its tree-climbing lions, flamingos, and stunning Rift Valley scenery."
            desc_sw: "Maarufu kwa simba wanaopanda miti, flamingo, na mandhari ya kuvutia ya Bonde la Ufa."
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
            name_en: "Mahale Mountains National Park"; name_sw: "Hifadhi ya Taifa ya Milima ya Mahale"
            imageFile: "./mahale.jpg"
            desc_en: "Home to chimpanzees on the shores of Lake Tanganyika, offering unique primate tracking experiences."
            desc_sw: "Makao ya sokwe pembezoni mwa Ziwa Tanganyika, inayotoa uzoefu wa kipekee wa kufuatilia nyani."
        }
        ListElement {
            name_en: "Gombe Stream National Park"; name_sw: "Hifadhi ya Taifa ya Gombe Stream"
            imageFile: "./gombe.jpg"
            desc_en: "The site of Jane Goodall's pioneering chimpanzee research, a small park with significant impact."
            desc_sw: "Eneo la utafiti waanzilishi wa sokwe wa Jane Goodall, hifadhi ndogo yenye thamani kubwa."
        }
        ListElement {
            name_en: "Mafia Island Marine Park"; name_sw: "Hifadhi ya Bahari ya Kisiwa cha Mafia"
            imageFile: "./mafia_island.jpg"
            desc_en: "Pristine coral reefs, a haven for divers and snorkelers, and a seasonal home for whale sharks."
            desc_sw: "Miamba ya matumbawe safi, kimbilio la wapiga mbizi, na makazi ya msimu ya papa nyangumi."
        }
        ListElement {
            name_en: "Pemba Island"; name_sw: "Kisiwa cha Pemba"
            imageFile: "./pemba.jpg"
            desc_en: "Part of the Zanzibar Archipelago, known as the 'Green Island' for its lush vegetation, cloves, and diving spots."
            desc_sw: "Sehemu ya Visiwa vya Zanzibar, inayojulikana kama 'Kisiwa cha Kijani' kwa uoto wake mwingi, karafuu, na maeneo ya kupiga mbizi."
        }
        ListElement {
            name_en: "Olduvai Gorge"; name_sw: "Bonde la Olduvai"
            imageFile: "./olduvai.jpg"
            desc_en: "A crucial paleoanthropological site holding evidence of early human evolution."
            desc_sw: "Eneo muhimu la paleoanthropolojia lenye ushahidi wa mageuzi ya awali ya binadamu."
        }
        ListElement {
            name_en: "Arusha National Park"; name_sw: "Hifadhi ya Taifa ya Arusha"
            imageFile: "./arusha_np.jpg"
            desc_en: "Offers diverse landscapes including Mount Meru, Momella Lakes, and Ngurdoto Crater."
            desc_sw: "Inatoa mandhari mbalimbali ikiwa ni pamoja na Mlima Meru, Maziwa ya Momella, na Kreta ya Ngurdoto."
        }
        ListElement {
            name_en: "Mikumi National Park"; name_sw: "Hifadhi ya Taifa ya Mikumi"
            imageFile: "./mikumi.jpg"
            desc_en: "An accessible park, forming part of the Selous ecosystem, with good wildlife viewing."
            desc_sw: "Hifadhi inayofikika kirahisi, sehemu ya mfumoikolojia wa Selous, yenye utazamaji mzuri wa wanyamapori."
        }
        ListElement {
            name_en: "Udzungwa Mountains National Park"; name_sw: "Hifadhi ya Taifa ya Milima ya Udzungwa"
            imageFile: "./udzungwa.jpg"
            desc_en: "A biodiverse montane forest, excellent for hiking and spotting endemic primate species."
            desc_sw: "Msitu wa milimani wenye bioanuwai nyingi, bora kwa matembezi na kuona aina za nyani za kipekee."
        }
        ListElement {
            name_en: "Katavi National Park"; name_sw: "Hifadhi ya Taifa ya Katavi"
            imageFile: "./katavi.jpg"
            desc_en: "A remote and wild park known for large concentrations of game during the dry season."
            desc_sw: "Hifadhi ya mbali na pori inayojulikana kwa mikusanyiko mikubwa ya wanyama wakati wa kiangazi."
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
            name_en: "Kolo Rock Paintings"; name_sw: "Michoro ya Miamba ya Kolo"
            imageFile: "./kolo_rock_paintings.jpg"
            desc_en: "Ancient rock art sites in Kondoa Irangi, offering insights into early human history and culture in Tanzania."
            desc_sw: "Maeneo ya kale ya sanaa ya miamba huko Kondoa Irangi, yakitoa ufafanuzi wa historia na utamaduni wa awali wa binadamu nchini Tanzania."
        }
        ListElement {
            name_en: "Bagamoyo"; name_sw: "Bagamoyo"
            imageFile: "./bagamoyo.jpg"
            desc_en: "A historic coastal town with a rich past as a former slave trade port, featuring colonial architecture and cultural sites."
            desc_sw: "Mji wa kihistoria wa pwani wenye historia tajiri kama bandari ya zamani ya biashara ya watumwa, yenye usanifu wa kikoloni na maeneo ya kitamaduni."
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
            name_en: "Lake Natron"; name_sw: "Ziwa Natron"
            imageFile: "./natron.jpg"
            desc_en: "A shallow, alkaline lake famous as a breeding ground for lesser flamingos, with dramatic landscapes."
            desc_sw: "Ziwa la chumvi lisilo na kina kirefu, maarufu kama eneo la kuzaliana flamingo wadogo, lenye mandhari ya kuvutia."
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

    onSelectedLanguageChanged: {
        if (selectedLanguage !== "") {
            viewComponentLoader.sourceComponent = attractionViewComponent;
        }
    }

    Loader {
        id: viewComponentLoader
        anchors.fill: parent
        sourceComponent: languageSelectionComponent
    }

    Component {
        id: languageSelectionComponent
        Item {
            anchors.fill: parent
            Rectangle { // Background
                anchors.fill: parent
                color: "transparent"
            }

            ColumnLayout {
                width: app.width
                spacing: 10

                Rectangle{
                    width: parent.width
                    height: header.height + flag.height
                    color: "white"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true

                    Text {
                        id: header
                        text: "<font color=\"green\">Utalii wa Tanzania</font> / <font color=\"blue\">Tanzania Tourism</font>"
                        anchors.top: parent.top
                        font.pointSize: Qt.platform.os === "android" ? 16 : 14
                        font.bold: true
                        font.underline: true
                        wrapMode: Text.WordWrap
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    AnimatedImage{
                        id: flag
                        source: "./tzflag.gif"
                        anchors.top: header.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                }


                Text {
                    text: "IDADI YA VIVUTIO VILIVYOORODHESHWA / NUMBER OF LISTED ATTRACTIONS:: <font color=\"white\">"+ attractionModel.count + "</font>"
                    font.pointSize: Qt.platform.os === "android" ? 12 : 10
                    Layout.alignment: Qt.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    textFormat: Text.RichText
                    font.bold: true
                    color: "#dadada"
                }


Image {
   source: "./TZmap.png"
   Layout.preferredWidth: app.width * 0.8
   Layout.alignment: Qt.AlignHCenter

}

Rectangle {
    width: app.width
    height: 1
    color: "#dadada"
}

                Text {
                    text: "Chagua Lugha / Select Language"
                    font.pointSize: Qt.platform.os === "android" ? 16 : 14
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                }

                Button {
                    text: "Kiswahili"
                    font.pointSize: Qt.platform.os === "android" ? 14 : 12
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 50
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        app.selectedLanguage = "sw";
                    }

                }

                Button {
                    text: "English"
                    font.pointSize: Qt.platform.os === "android" ? 14 : 12
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 50
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        app.selectedLanguage = "en";
                    }
                }
        

Rectangle {
    width: app.width
    height: 1
    color: "#dadada"
}

                Button {
                    text: "Funga / Close"
                    font.pointSize: Qt.platform.os === "android" ? 12 : 10
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 60
                   Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        app.close();
                    }
                }

Rectangle {
    width: app.width
    height: 1
    color: "#dadada"
}

Image {
   source: "./tz_royal_tour.jpg"
   Layout.preferredWidth: app.width * 0.86
   Layout.alignment: Qt.AlignHCenter
  
}




            }
        }
    }

    // Component for Attraction Display Screen
    Component {
        id: attractionViewComponent
        Item {
            id: attractionItem
            anchors.fill: parent
            focus: true // To receive key events

            // Background Image
            Image {
                id: attractionImage
                anchors.fill: parent
                source: app.currentAttractionImage()
                fillMode: Image.PreserveAspectFit
                smooth: true

                // Fallback color if image fails to load
                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    visible: attractionImage.status !== Image.Ready
                    Text {
                        anchors.centerIn: parent
                        text: "Image not found:\n" + app.currentAttractionImage()
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Overlay for Text (at the bottom of the image)
            Rectangle {
                id: textOverlay
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: attractionNameText.height + attractionDescriptionText.height + 20
                color: "transparent"

                Rectangle{
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.5
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        app.close();
                    }
                }

                ColumnLayout {
                    width: app.width
                    anchors.margins: 10 // Padding inside the overlay

                    // Attraction Name
                    Text {
                        id: attractionNameText
                        text: app.currentAttractionName()
                        font.pointSize: Qt.platform.os === "android" ? 16 : 14
                        font.bold: true
                        color: "white"
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // Attraction Description
                    Text {
                        id: attractionDescriptionText
                        text: app.currentAttractionDesc()
                        width: app.width
                        height: 80
                        font.pointSize: Qt.platform.os === "android" ? 12 : 10
                        color: "white"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.fillHeight: true // Allow text to take remaining space
                    }
                }
            }

            // Navigation Arrows (Visual cues, actual logic in Keys.onPressed)
            Text {
                text: "<"
                font.pixelSize: Qt.platform.os === "android"? 100 : 40
                font.bold: true
                color: "#b2ffffff"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 20
                MouseArea {
                    anchors.fill: parent
                    onClicked: navigatePrevious()
                }
            }

            Text {
                text: "::"
                font.pixelSize: Qt.platform.os === "android"? 100 : 40
                font.bold: true
                color: "#b2ffffff"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        viewComponentLoader.sourceComponent = languageSelectionComponent;
                        app.selectedLanguage = "";
                    }
                }
            }

            Text {
                text: ">"
                font.pixelSize: Qt.platform.os === "android"? 100 : 40
                font.bold: true
                color: "#b2ffffff"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 20
                MouseArea {
                    anchors.fill: parent
                    onClicked: navigateNext()
                }
            }


            // Handle Arrow Key Presses for Navigation
            Keys.onPressed: (event) => {
                                if (event.key === Qt.Key_Left) {
                                    navigatePrevious();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Right) {
                                    navigateNext();
                                    event.accepted = true;
                                }
                            }

            function navigatePrevious() {
                if (app.currentAttractionIndex > 0) {
                    app.currentAttractionIndex--;
                } else {
                    app.currentAttractionIndex = attractionModel.count - 1; // Wrap around
                }
            }

            function navigateNext() {
                if (app.currentAttractionIndex < attractionModel.count - 1) {
                    app.currentAttractionIndex++;
                } else {
                    app.currentAttractionIndex = 0; // Wrap around
                }
            }
        }
    }
}