import QtQuick 2.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0

Rectangle {
    id: app
    width: parent.width
    height: parent.height
    visible: true
    color: "#050a0c"


    // --- APP PROPERTIES ---
    property int currentIdx: 0
    property int totalScore: 0
    property int timeInterval: 20
    property int timerValue: timeInterval
    property string viewState: "START"
    property int maxQuestions: 26 // Tunataka maswali 26 tu kila mchezo
    property int noOfPassedQuestion: 0


    // --- IQ CATEGORY LOGIC ---
    function getCategory(iq) {
        if (iq >= 140) return "GWIJI";
        if (iq >= 120) return "UPEO WA JUU";
        if (iq >= 110) return "ZAIDI YA WASTANI";
        if (iq >= 90)  return "WASTANI";
        return "UNAHITAJI MAZOEZI";
    }


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


    function ad()
    {
        if(typeof n3ctaApp !== "undefined"){
            n3ctaApp.onUrlVisited("#showGoogleAd");
        }else if(typeof loader !== "undefined"){
            loader.onUrlVisited("#showGoogleAd");
        }
    }

    function indexToLetter(i){
        let letter;
        if(i === 0){
            letter = "A";
        } else if(i === 1){
            letter = "B";
        }else if(i === 2){
            letter = "C";
        }else if(i === 3){
            letter = "D";
        }
        return letter;
    }


function cleanOption(text) {
    if (!text) return "";
    // Inafuta mabano na yaliyomo ndani, kisha inafuta nafasi zilizoziada
    return text.replace(/\s*\(.*?\)\s*/g, "").trim();
}


    // --- QUESTION MODEL (Maswali 26) ---
    ListModel {
        id: iqModel

        //SAYANSI
        ListElement { q: "Ni gesi gani binadamu anahitaji ili kuishi?"; a: "Nitrogen"; b: "Oxygen"; c: "Carbon"; d: "Hydrogen"; correct: "Oxygen" }
        ListElement { q: "Sayari ya karibu zaidi na Jua inaitwa?"; a: "Dunia"; b: "Mercury"; c: "Mars"; d: "Venus"; correct: "Mercury" }
        ListElement { q: "Maji huganda (Freezing point) kwenye nyuzi ngapi Celsius?"; a: "100"; b: "0"; c: "50"; d: "-10"; correct: "0" }
        ListElement { q: "Sehemu ya seli inayohusika na nishati (Powerhouse) ni?"; a: "Nucleus"; b: "Mitochondria"; c: "Ribosome"; d: "Wall"; correct: "Mitochondria" }

        //LOGIC & MATH
        ListElement { q: "Robo ya 200 ikiongezewa 50 unapata?"; a: "100"; b: "150"; c: "75"; d: "250"; correct: "100" }
        ListElement { q: "Kama 1=5, 2=25, 3=125, basi 5=?"; a: "625"; b: "1"; c: "3125"; d: "500"; correct: "1" }
        ListElement { q: "Saa kumi na mbili za jioni ni saa ngapi katika mfumo wa saa 24?"; a: "12:00"; b: "18:00"; c: "00:00"; d: "20:00"; correct: "18:00" }
        ListElement { q: "Kati ya kilo 1 ya pamba na kilo 1 ya chuma, nini kizito zaidi?"; a: "Chuma"; b: "Pamba"; c: "Zinalingana"; d: "Inategemea"; correct: "Zinalingana" }
        ListElement { q: "Tafuta wastani wa namba hizi: 5, 10, 15, 20, 25"; a: "15"; b: "10"; c: "20"; d: "12"; correct: "15" }

        //MICHEZO (SPORTS)
        ListElement { q: "Mchezaji gani wa kwanza wa TZ kucheza Ligi Kuu ya Uingereza (EPL)?"; a: "Samatta"; b: "Msuva"; c: "Ulimwengu"; d: "Ngassa"; correct: "Samatta" }
        ListElement { q: "Timu ya Taifa ya Tanzania inaitwa?"; a: "Taifa Stars"; b: "The Cranes"; c: "Harambee Stars"; d: "Black Stars"; correct: "Taifa Stars" }
        ListElement { q: "Mwanariadha gani alishinda medali ya kwanza ya dhahabu ya Jumuiya ya Madola (1974)?"; a: "Filbert Bayi"; b: "Suleiman Nyambui"; c: "Alphonce Simbu"; d: "Gidamis Shahanga"; correct: "Filbert Bayi" }
        ListElement { q: "Klabu ya Simba SC ilianzishwa mwaka gani?"; a: "1936"; b: "1935"; c: "1940"; d: "1950"; correct: "1936" }

        //COMPUTER SCIENCE & TECHNOLOGY
        ListElement { q: "Katika lugha ya kompyuta, 'RAM' inamaanisha nini?"; a: "Read Access Memory"; b: "Random Access Memory"; c: "Real Access Memory"; d: "Run Access Memory"; correct: "Random Access Memory" }
        ListElement { q: "Ni kifaa kipi ni 'Brain' ya kompyuta?"; a: "Monitor"; b: "CPU"; c: "Hard Disk"; d: "Keyboard"; correct: "CPU" }
        ListElement { q: "Lugha gani inatumika kutengeneza Apps za QML?"; a: "Java"; b: "JavaScript"; c: "PHP"; d: "Swift"; correct: "JavaScript" }
        ListElement { q: "Kifupi cha 'WWW' ni nini?"; a: "World Wide Web"; b: "Word Wide Web"; c: "World Web Wide"; d: "Web Wide World"; correct: "World Wide Web" }
        ListElement { q: "Ni kampuni gani ilitengeneza mfumo wa Android?"; a: "Apple"; b: "Microsoft"; c: "Google"; d: "Nokia"; correct: "Google" }

        //HESABU & LOGIC
        ListElement { q: "Ni namba gani inafuata?\n2, 5, 11, 23, ..."; a: "35"; b: "47"; c: "46"; d: "50"; correct: "47" }
        ListElement { q: "Tafuta thamani ya 'x' kama:\n2x + 10 = 30"; a: "5"; b: "15"; c: "10"; d: "20"; correct: "10" }
        ListElement { q: "Kama 3 ni 9, na 4 ni 16, basi 6 ni nini?"; a: "36"; b: "24"; c: "12"; d: "30"; correct: "36" }
        ListElement { q: "Nusu ya robo ya 400 ni ngapi?"; a: "100"; b: "50"; c: "25"; d: "200"; correct: "50" }

        //KILIMO NA UVUVI
        ListElement { q: "Zao lipi ni 'Dhahabu ya Kijani' mkoani Kagera na Kilimanjaro?"; a: "Kahawa"; b: "Pamba"; c: "Karafuu"; d: "Chai"; correct: "Kahawa" }
        ListElement { q: "Ziwa lipi linaongoza kwa uzalishaji wa Sangara Tanzania?"; a: "Victoria"; b: "Tanganyika"; c: "Nyasa"; d: "Eyasi"; correct: "Victoria" }
        ListElement { q: "Bodi ya Korosho Tanzania (CBT) ina makao makuu mkoa gani?"; a: "Lindi"; b: "Mtwara"; c: "Pwani"; d: "Tanga"; correct: "Mtwara" }
        ListElement { q: "Zao kuu la biashara visiwani Pemba ni?"; a: "Karafuu"; b: "Tangawizi"; c: "Ulanga"; d: "Mdalasini"; correct: "Karafuu" }

        //MADINI (MINERALS)
        ListElement { q: "Madini ya kipekee yanayopatikana Tanzania pekee duniani ni?"; a: "Dhahabu"; b: "Tanzanite"; c: "Almasi"; d: "Shaba"; correct: "Tanzanite" }
        ListElement { q: "Mgodi wa Almasi wa Mwadui unapatikana mkoa gani?"; a: "Geita"; b: "Shinyanga"; c: "Mara"; d: "Mwanza"; correct: "Shinyanga" }
        ListElement { q: "Mji gani unajulikana kama kitovu cha biashara ya Dhahabu Tanzania?"; a: "Geita"; b: "Chunya"; c: "Mbeya"; d: "Kahama"; correct: "Geita" }

        //MAPISHI NA CHAKULA (FOOD)
        ListElement { q: "Chakula gani ni maarufu kwa watu wa Kilimanjaro (Ndizi na Nyama)?"; a: "Mtori"; b: "Makande"; c: "Kande"; d: "Kiti moto"; correct: "Mtori" }
        ListElement { q: "Kande ni mchanganyiko wa maharage na nini?"; a: "Mchele"; b: "Mahindi"; c: "Viazi"; d: "Mtama"; correct: "Mahindi" }
        ListElement { q: "Pilau ni chakula chenye asili ya wapi nchini?"; a: "Pwani/Zanzibar"; b: "Kanda ya Ziwa"; c: "Kusini"; d: "Kaskazini"; correct: "Pwani/Zanzibar" }

        //ELIMU NA JAMII
        ListElement { q: "Chuo Kikuu kikongwe zaidi nchini Tanzania ni?"; a: "UDSM"; b: "Mzumbe"; c: "SUA"; d: "UDOM"; correct: "UDSM" }
        ListElement { q: "Lugha ya Taifa ya Tanzania ni?"; a: "Kiingereza"; b: "Kiswahili"; c: "Kiarabu"; d: "Kinyamwezi"; correct: "Kiswahili" }

        //HESABU (LOGIC & MATH)
        ListElement { q: "Kama 5 + x = 12, basi x ni ngapi?"; a: "5"; b: "7"; c: "8"; d: "6"; correct: "7" }
        ListElement { q: "Namba inayofuata: 1, 4, 9, 16, ..."; a: "20"; b: "25"; c: "30"; d: "24"; correct: "25" }
        ListElement { q: "Pembe tatu (Triangle) ina jumla ya nyuzi (degrees) ngapi?"; a: "90"; b: "180"; c: "360"; d: "270"; correct: "180" }
        ListElement { q: "Tafuta wastani wa 10, 20, na 30:"; a: "15"; b: "20"; c: "25"; d: "10"; correct: "20" }
        ListElement { q: "Ni namba gani ni namba tasa (Prime number)?"; a: "4"; b: "9"; c: "7"; d: "10"; correct: "7" }

        //MICHEZO & BURUDANI
        ListElement { q: "Mshindi wa kwanza wa medali ya Olimpiki kwa Tanzania alikuwa nani?"; a: "Filbert Bayi"; b: "Suleiman Nyambui"; c: "Samson Ramadhani"; d: "Juma Ikangaa"; correct: "Suleiman Nyambui" }
        ListElement { q: "Klabu ya Yanga SC ilianzishwa mwaka gani?"; a: "1935"; b: "1938"; c: "1940"; d: "1932"; correct: "1935" }
        ListElement { q: "Uwanja wa Kaitaba unapatikana mkoa gani?"; a: "Mwanza"; b: "Kagera"; c: "Mara"; d: "Shinyanga"; correct: "Kagera" }
        ListElement { q: "Ni mwanamuziki gani wa Tanzania alishinda tuzo ya BET (Best International Act)?"; a: "Diamond Platnumz"; b: "Rayvanny"; c: "Alikiba"; d: "Harmonize"; correct: "Rayvanny" }
        ListElement { q: "Shirikisho la Mpira wa Miguu Tanzania linajulikana kwa kifupi kama?"; a: "TFF"; b: "FAT"; c: "BMT"; d: "DRFA"; correct: "TFF" }
        ListElement { q: "Mchezo wa asili wa 'Bao' unachezwa na watu wangapi kwa wakati mmoja?"; a: "3"; b: "2"; c: "4"; d: "1"; correct: "2" }

        //COMPUTER SCIENCE & ICT
        ListElement { q: "Kifupi cha USB ni nini?"; a: "Universal Serial Bus"; b: "United Serial Bus"; c: "User System Bus"; d: "Unit Serial Block"; correct: "Universal Serial Bus" }
        ListElement { q: "Ni nini kazi ya 'Antivirus' kwenye kompyuta?"; a: "Kuongeza kasi"; b: "Kulinda dhidi ya virusi"; c: "Kufuta picha"; d: "Kuhifadhi siri"; correct: "Kulinda dhidi ya virusi" }
        ListElement { q: "Sehemu ya nje ya kompyuta inayoweza kuguswa inaitwa?"; a: "Software"; b: "Hardware"; c: "Firmware"; d: "Malware"; correct: "Hardware" }
        ListElement { q: "Neno 'Email' kirefu chake ni nini?"; a: "Easy Mail"; b: "Electronic Mail"; c: "Electric Mail"; d: "Engine Mail"; correct: "Electronic Mail" }
        ListElement { q: "Ni kifaa kipi kinachotumika kutoa nakala ya karatasi kutoka kwenye kompyuta?"; a: "Scanner"; b: "Printer"; c: "Monitor"; d: "Mouse"; correct: "Printer" }
        ListElement { q: "Lugha ya 'Binary' inatumia namba gani?"; a: "1 na 2"; b: "0 na 1"; c: "1 hadi 10"; d: "0 hadi 9"; correct: "0 na 1" }
        ListElement { q: "Kifaa kinachounganisha kompyuta na internet kinaitwa?"; a: "Router"; b: "Keyboard"; c: "Speaker"; d: "CPU"; correct: "Router" }
        ListElement { q: "Ni zipi kati ya hizi ni 'Operating System'?"; a: "Google"; b: "Windows"; c: "Facebook"; d: "WhatsApp"; correct: "Windows" }

        //KILIMO & UVUVI
        ListElement { q: "Zao lipi la biashara ni maarufu mkoani Tabora?"; a: "Tumbaku"; b: "Chai"; c: "Karafuu"; d: "Sisal"; correct: "Tumbaku" }
        ListElement { q: "Wizara ya Kilimo nchini Tanzania ina makao makuu mji gani?"; a: "Dar es Salaam"; b: "Dodoma"; c: "Morogoro"; d: "Arusha"; correct: "Dodoma" }
        ListElement { q: "Chuo kikuu maarufu cha kilimo nchini Tanzania kinaitwa?"; a: "UDSM"; b: "SUA"; c: "SAUT"; d: "Mzumbe"; correct: "SUA" }
        ListElement { q: "Zao la mkonge (Sisal) huzalishwa kwa wingi mkoa gani?"; a: "Tanga"; b: "Mtwara"; c: "Lindi"; d: "Ruvuma"; correct: "Tanga" }
        ListElement { q: "Dagaa wa Kigoma wanapatikana katika ziwa gani?"; a: "Victoria"; b: "Tanganyika"; c: "Nyasa"; d: "Rukwa"; correct: "Tanganyika" }
        ListElement { q: "Ni mbinu gani ya kilimo inayozuia mmomonyoko wa udongo milimani?"; a: "Kilimo cha matuta"; b: "Kilimo cha mikingamo"; c: "Kilimo cha kuhamahama"; d: "Kilimo cha umwagiliaji"; correct: "Kilimo cha mikingamo" }

        //MADINI
        ListElement { q: "Madini ya makaa ya mawe yanapatikana kwa wingi mkoa gani?"; a: "Njombe"; b: "Ruvuma"; c: "Geita"; d: "Pwani"; correct: "Ruvuma" }
        ListElement { q: "Mji wa Mererani unajulikana kwa uchimbaji wa madini gani?"; a: "Dhahabu"; b: "Tanzanite"; c: "Chuma"; d: "Shaba"; correct: "Tanzanite" }
        ListElement { q: "Mgodi wa dhahabu wa Geita unaitwa?"; a: "GGML"; b: "Bulyanhulu"; c: "North Mara"; d: "Williamson"; correct: "GGML" }
        ListElement { q: "Tanzania ni nchi ya ngapi Afrika kwa uzalishaji wa Dhahabu?"; a: "Kwanza"; b: "Nne"; c: "Pili"; d: "Tano"; correct: "Nne" }
        ListElement { q: "Chuma kinapatikana katika eneo gani nchini?"; a: "Liganga"; b: "Mwadui"; c: "Kahama"; d: "Ngerengere"; correct: "Liganga" }

        //LOGIC & MATH
        ListElement { q: "Kama una dakika 60, na unatumia sekunde 30 kwa kila swali, utajibu maswali mangapi?"; a: "2"; b: "120"; c: "60"; d: "30"; correct: "120" }
        ListElement { q: "Tafuta thamani ya 'y':\n3y - 5 = 10"; a: "5"; b: "15"; c: "3"; d: "10"; correct: "5" }
        ListElement { q: "Jumla ya pembe za ndani za mraba (Square) ni ngapi?"; a: "180"; b: "360"; c: "90"; d: "270"; correct: "360" }

        //MAPISHI NA CHAKULA
        ListElement { q: "Chakula cha asili cha Wahaya kinachoitwa 'Senene' ni nini?"; a: "Samaki"; b: "Panzi"; c: "Kunde"; d: "Mimea"; correct: "Panzi" }
        ListElement { q: "Ugabigabi ni chakula cha asili cha mkoa gani?"; a: "Dodoma"; b: "Mara"; c: "Mtwara"; d: "Singida"; correct: "Singida" }
        ListElement { q: "Wali wa nazi ni maarufu sana katika maeneo yapi?"; a: "Pwani"; b: "Nyanda za juu"; c: "Kanda ya ziwa"; d: "Kati"; correct: "Pwani" }
        ListElement { q: "Kifupi cha neno 'Chai' katika Kiswahili cha zamani ilikuwa 'Mchai'. Jani la mchai linaitwa?"; a: "Mkandaa"; b: "Mchai"; c: "Mchai-chai"; d: "Mchai-bara"; correct: "Mchai-chai" }
        ListElement { q: "Kiungo gani hukupa pilau harufu nzuri?"; a: "Chumvi"; b: "Binzari"; c: "Sukari"; d: "Mafuta"; correct: "Binzari" }

        //HISTORIA & SIASA
        ListElement { q: "Bendera ya Tanganyika ilikuwa na rangi gani kabla ya Muungano?"; a: "Kijani, Nyeusi, Kijani"; b: "Kijani, Nyeusi, Njano"; c: "Bluu, Nyeusi, Kijani"; d: "Nyekundu, Nyeusi, Kijani"; correct: "Kijani, Nyeusi, Kijani" }
        ListElement { q: "Azimio la Arusha lilitangazwa mwaka gani?"; a: "1961"; b: "1967"; c: "1977"; d: "1964"; correct: "1967" }
        ListElement { q: "Chama cha TANU kilianzishwa tarehe 7 Julai mwaka gani?"; a: "1954"; b: "1961"; c: "1950"; d: "1945"; correct: "1954" }
        ListElement { q: "Makao makuu ya Umoja wa Afrika (AU) yapo nchi gani?"; a: "Tanzania"; b: "Ethiopia"; c: "Kenya"; d: "Misri"; correct: "Ethiopia" }
        ListElement { q: "Rais wa kwanza wa Zanzibar baada ya Mapinduzi alikuwa?"; a: "Abeid Karume"; b: "Idris Abdul Wakil"; c: "Salmin Amour"; d: "Ali Hassan Mwinyi"; correct: "Abeid Karume" }
        ListElement { q: "Nyerere alistaafu urais mwaka gani?"; a: "1980"; b: "1985"; c: "1990"; d: "1975"; correct: "1985" }

        //ELIMU & JIOGRAFIA
        ListElement { q: "Mlima wa pili kwa urefu nchini Tanzania unaitwa?"; a: "Meru"; b: "Oldonyo Lengai"; c: "Hanang"; d: "Rungwe"; correct: "Meru" }
        ListElement { q: "Ziwa la pili kwa kina kirefu duniani lililopo Tanzania ni?"; a: "Victoria"; b: "Tanganyika"; c: "Nyasa"; d: "Natron"; correct: "Tanganyika" }
        ListElement { q: "Mkoa wa Dar es Salaam una wilaya ngapi kwa sasa?"; a: "3"; b: "5"; c: "7"; d: "4"; correct: "5" }
        ListElement { q: "Mto mrefu kuliko yote nchini Tanzania ni?"; a: "Rufiji"; b: "Pangani"; c: "Ruvuma"; d: "Malagarasi"; correct: "Rufiji" }
        ListElement { q: "Hifadhi ya Saadani ina upekee gani?"; a: "Ina chui wengi"; b: "Imepakana na bahari"; c: "Ina milima"; d: "Ina baridi kali"; correct: "Imepakana na bahari" }

        //IQ & LOGIC (HESABU)
        ListElement { q: "Nusu ya nusu ya 100 ni ngapi?"; a: "50"; b: "25"; c: "12.5"; d: "75"; correct: "25" }
        ListElement { q: "Kuna miezi mingapi yenye siku 28?"; a: "1"; b: "12"; c: "0"; d: "6"; correct: "12" }
        ListElement { q: "Kama jana ilikuwa Jumatatu, kesho kutwa itakuwa siku gani?"; a: "Jumatano"; b: "Alhamisi"; c: "Ijumaa"; d: "Jumanne"; correct: "Alhamisi" }
        ListElement { q: "Umbo lenye pande 6 linaitwa?"; a: "Pentagon"; b: "Hexagon"; c: "Octagon"; d: "Square"; correct: "Hexagon" }
        ListElement { q: "Dazeni moja ni sawa na vitu vingapi?"; a: "10"; b: "12"; c: "24"; d: "6"; correct: "12" }

        // MZIKI WA TANZANIA
        ListElement { q: "Aina ya muziki wa asili nchini Tanzania unaotumia ala ya zeze na ilali unaitwa?"; a: "Bongo Fleva"; b: "Mchiriku"; c: "Taarab"; d: "Dansi"; correct: "Taarab" }
        ListElement { q: "Mwanamuziki gani anafahamika kama 'Mfalme wa Taarab' nchini Tanzania?"; a: "Mzee Yusuf"; b: "Diamond Platnumz"; c: "Alikiba"; d: "Moni Centrozone"; correct: "Mzee Yusuf" }
        ListElement { q: "Wimbo wa Taifa wa Tanzania unaitwa?"; a: "Tanzania Nakupenda"; b: "Mungu Ibariki Afrika"; c: "Tanzania Tanzania"; d: "Uzendo wa Taifa"; correct: "Mungu Ibariki Afrika" }
        ListElement { q: "Ni mwanamuziki gani aliyeasisi mtindo wa 'Zuku' nchini Tanzania?"; a: "Marijani Rajab"; b: "Bi Kidude"; c: "Hukwe Zawose"; d: "Remmy Ongala"; correct: "Bi Kidude" }
        ListElement { q: "Tuzo kubwa za muziki duniani ambazo wasanii wa TZ hupania kushinda nchini Marekani ni?"; a: "Grammy"; b: "Kili Awards"; c: "BET"; d: "MTV"; correct: "Grammy" }

        //LOGIC & MATH
        ListElement { q: "Ni namba gani inafuata?\n1, 2, 4, 7, 11, ..."; a: "15"; b: "16"; c: "14"; d: "18"; correct: "16" }
        ListElement { q: "Nusu ya 2 plus 2 ni ngapi?"; a: "2"; b: "3"; c: "4"; d: "1"; correct: "3" }

        // SERIKALI NA BUNGE
        ListElement { q: "Bunge la Jamhuri ya Muungano wa Tanzania linaongozwa na nani kwa sasa?"; a: "Spika"; b: "Waziri Mkuu"; c: "Rais"; d: "Jaji Mkuu"; correct: "Spika" }
        ListElement { q: "Kiongozi wa shughuli za Serikali Bungeni ni nani?"; a: "Rais"; b: "Waziri Mkuu"; c: "Spika"; d: "Mwanasheria Mkuu"; correct: "Waziri Mkuu" }
        ListElement { q: "Uchaguzi mkuu nchini Tanzania hufanyika kila baada ya miaka mingapi?"; a: "4"; b: "5"; c: "10"; d: "6"; correct: "5" }
        ListElement { q: "Mhimili wa Serikali unaohusika na kutafsiri sheria unaitwa?"; a: "Bunge"; b: "Mahakama"; c: "Baraza la Mawaziri"; d: "Tume ya Uchaguzi"; correct: "Mahakama" }

        ListElement { q: "Nani anayemteua Waziri Mkuu wa Tanzania?"; a: "Bunge"; b: "Rais"; c: "Spika"; d: "Wananchi"; correct: "Rais" }
        ListElement { q: "Jumla ya mikoa ya Tanzania Bara na Visiwani ni mingapi kwa sasa?"; a: "26"; b: "31"; c: "30"; d: "21"; correct: "31" }
        ListElement { q: "Kiti cha Spika wa Bunge la Tanzania kipo mji gani?"; a: "Dar es Salaam"; b: "Dodoma"; c: "Arusha"; d: "Zanzibar"; correct: "Dodoma" }

        // UTAMADUNI
        ListElement { q: "Lugha ipi inatambulika kama lugha ya Taifa na kiunganishi cha Watanzania?"; a: "Kiingereza"; b: "Kiswahili"; c: "Kiarabu"; d: "Kinyamwezi"; correct: "Kiswahili" }
        ListElement { q: "Mavazi ya asili ya kabila la Wamasai yanaitwa?"; a: "Kanzu"; b: "Shuka"; c: "Lubega"; d: "Suti"; correct: "Shuka" }
        ListElement { q: "Sikukuu ya 'Nane Nane' nchini Tanzania huadhimisha nini?"; a: "Wafanyakazi"; b: "Wakulima"; c: "Muungano"; d: "Mapinduzi"; correct: "Wakulima" }
        ListElement { q: "Ngoma ya asili ya kabila la Wasukuma inayohusisha nyoka inaitwa?"; a: "Bugobogobo"; b: "Bughu"; c: "Mdundiko"; d: "Sindimba"; correct: "Bugobogobo" }
        ListElement { q: "Chakula gani cha asili ni maarufu sana kwa kabila la Wachaga?"; a: "Ugali"; b: "Kande"; c: "Mtori/Machalari"; d: "Wali"; correct: "Mtori/Machalari" }
        ListElement { q: "Mwenge wa Uhuru uliwashwa kwa mara ya kwanza kilele cha Kilimanjaro mwaka gani?"; a: "1961"; b: "1964"; c: "1967"; d: "1977"; correct: "1961" }
        ListElement { q: "Sanamu ya Askari (Askari Monument) inapatikana katikati ya jiji gani?"; a: "Mwanza"; b: "Dodoma"; c: "Dar es Salaam"; d: "Tanga"; correct: "Dar es Salaam" }
        ListElement { q: "Zanzibar ni maarufu kwa mlango wa aina gani wa kitamaduni?"; a: "Mlango wa Chuma"; b: "Mlango wa Nakshi (Zanzibar Door)"; c: "Mlango wa Kioo"; d: "Mlango wa Plastiki"; correct: "Mlango wa Nakshi (Zanzibar Door)" }

        //LOGIC & MATH
        ListElement { q: "Kama utageuza neno 'KILIMANJARO', herufi ya tatu itakuwa?"; a: "A"; b: "R"; c: "O"; d: "J"; correct: "R" }
        ListElement { q: "Tanzania imepakana na nchi ngapi?"; a: "6"; b: "8"; c: "10"; d: "7"; correct: "8" }
        ListElement { q: "Rangi za bendera ya Tanzania ni ngapi?"; a: "3"; b: "4"; c: "5"; d: "2"; correct: "4" }
        ListElement { q: "Nchi ya Tanzania ipo upande gani wa bara la Afrika?"; a: "Magharibi"; b: "Kaskazini"; c: "Mashariki"; d: "Kati"; correct: "Mashariki" }

        //WANYAMAPORI
        ListElement { q: "Mnyama yupi anapatikana katika nembo ya Taifa ya Tanzania (Coat of Arms)?"; a: "Simba"; b: "Twiga"; c: "Chui"; d: "Tembo"; correct: "Twiga" }
        ListElement { q: "Ni mnyama yupi anajulikana kama 'Mfalme wa Mwitu'?"; a: "Tembo"; b: "Simba"; c: "Kifaru"; d: "Chui"; correct: "Simba" }
        ListElement { q: "Tanzania ina mnyama mrefu zaidi duniani, anaitwa?"; a: "Twiga"; b: "Swala"; c: "Nyumbu"; d: "Duma"; correct: "Twiga" }
        ListElement { q: "Ni mnyama yupi kati ya hawa anaunda kundi la 'Big Five' nchini Tanzania?"; a: "Pundamilia"; b: "Kifaru"; c: "Twiga"; d: "Mamba"; correct: "Kifaru" }
        ListElement { q: "Ziwa Victoria ni maarufu kwa aina gani ya samaki wa biashara?"; a: "Sangara"; b: "Paremisi"; c: "Mwatiko"; d: "Kibua"; correct: "Sangara" }

        //IQ & LOGIC (HESABU)
        ListElement { q: "Kama unayo mayai 3 na ukavunja 2, unayo mayai mangapi?"; a: "1"; b: "2"; c: "3"; d: "0"; correct: "3" }
        ListElement { q: "Namba gani inafuata: 10, 20, 40, 80, ..."; a: "100"; b: "160"; c: "120"; d: "140"; correct: "160" }
        ListElement { q: "Kama kaka ana miaka 6 na dada ana nusu ya umri wake, kaka akifikisha 10, dada ana miaka mingapi?"; a: "5"; b: "7"; c: "8"; d: "3"; correct: "7" }
        ListElement { q: "Ni namba gani kubwa zaidi: 0.5, 0.05, 0.55, 0.1?"; a: "0.5"; b: "0.55"; c: "0.1"; d: "0.05"; correct: "0.55" }
        ListElement { q: "Saa 1 ina sekunde ngapi?"; a: "60"; b: "3600"; c: "600"; d: "1200"; correct: "3600" }
        ListElement { q: "Tafuta namba inayokosekana: 1, 3, 5, ?, 9"; a: "6"; b: "7"; c: "8"; d: "4"; correct: "7" }

        //SAMAKI
        ListElement { q: "Samaki aina ya 'Dagaa wa Kigoma' wanapatikana katika ziwa gani?"; a: "Victoria"; b: "Tanganyika"; c: "Nyasa"; d: "Eyasi"; correct: "Tanganyika" }
        ListElement { q: "Ni mnyama yupi anaongoza kwa uhamiaji mkubwa wa kila mwaka (Great Migration) Serengeti?"; a: "Simba"; b: "Nyumbu"; c: "Swala"; d: "Tembo"; correct: "Nyumbu" }
        ListElement { q: "Mnyama yupi ni maarufu kwa kuwa na pembe moja au mbili na yupo hatarini kutoweka?"; a: "Kifaru"; b: "Kiboko"; c: "Ngiri"; d: "Punda"; correct: "Kifaru" }
        ListElement { q: "Samaki aina ya Perege (Tilapia) hupatikana kwa wingi katika mazingira gani?"; a: "Maji ya Bahari"; b: "Maji Baridi (Maziwa/Mito)"; c: "Maji ya Chumvi"; d: "Maji ya Mafuta"; correct: "Maji Baridi (Maziwa/Mito)" }
        ListElement { q: "Mnyama yupi anaishi majini na nchi kavu na anaonekana kwa wingi mto Rufiji?"; a: "Mamba"; b: "Nyati"; c: "Duma"; d: "Sungura"; correct: "Mamba" }

        //AFYA NA MIMEA

        ListElement { q: "Ni tunda gani linajulikana kwa kuwa na kiasi kikubwa cha Vitamin C?"; a: "Chungwa"; b: "Ndizi"; c: "Tikiti"; d: "Tufaha (Apple)"; correct: "Chungwa" }
        ListElement { q: "Mmea unahitaji gesi gani kutoka kwa binadamu ili kutengeneza chakula?"; a: "Oxygen"; b: "Carbon Dioxide"; c: "Nitrogen"; d: "Hydrogen"; correct: "Carbon Dioxide" }
        ListElement { q: "Ugonjwa wa Malaria husababishwa na vimelea vinavyoenezwa na?"; a: "Inzi"; b: "Mbu Jike (Anopheles)"; c: "Mbu Dume"; d: "Funza"; correct: "Mbu Jike (Anopheles)" }
        ListElement { q: "Sehemu ya mmea inayohusika na kufyonza maji na madini ardhini ni?"; a: "Matawi"; b: "Mizizi"; c: "Maua"; d: "Shina"; correct: "Mizizi" }
        ListElement { q: "Ni vitamin gani inayopatikana kwa urahisi kupitia mwanga wa Jua la asubuhi?"; a: "Vitamin A"; b: "Vitamin C"; c: "Vitamin D"; d: "Vitamin K"; correct: "Vitamin D" }

        ListElement { q: "Mmea wa ajabu unaopatikana Tanzania (Kondoa) na huishi miaka mingi sana ni?"; a: "Mbuyu"; b: "Mwembe"; c: "Mnanasi"; d: "Mparachichi"; correct: "Mbuyu" }
        ListElement { q: "Kiwango cha kawaida cha joto la mwili wa binadamu ni nyuzi joto (Celsius) ngapi?"; a: "30°C"; b: "37°C"; c: "40°C"; d: "25°C"; correct: "37°C" }
        ListElement { q: "Mchakato wa mimea kutengeneza chakula chake kwa kutumia mwanga wa jua unaitwa?"; a: "Respiration"; b: "Photosynthesis"; c: "Digestion"; d: "Evaporation"; correct: "Photosynthesis" }

        ListElement { q: "Ni kiungo gani ndani ya mwili wa binadamu kinahusika na kusafisha damu?"; a: "Moyo"; b: "Mapafu"; c: "Figo"; d: "Tumbo"; correct: "Figo" }
        ListElement { q: "Upungufu wa madini ya Chuma mwilini husababisha ugonjwa gani?"; a: "Anemia (Upungufu wa damu)"; b: "Kisukari"; c: "Pumu"; d: "Tezi dume"; correct: "Anemia (Upungufu wa damu)" }

        //LOGIC & MATH
        ListElement { q: "Kama namba 3 ni 18, na 5 ni 30, basi 10 ni nini?"; a: "60"; b: "50"; c: "100"; d: "80"; correct: "60" }
        ListElement { q: "Tafuta namba inayokosekana:\n100, 95, 85, 70, ?"; a: "50"; b: "60"; c: "55"; d: "45"; correct: "50" }
        ListElement { q: "Ni namba gani ikiidhinishwa na 0 jibu linakuwa 0?"; a: "Namba yoyote"; b: "100 pekee"; c: "Hakuna"; d: "1 pekee"; correct: "Namba yoyote" }
        ListElement { q: "Kama mti mmoja una matawi 5, na kila tawi lina ndege 5, kuna ndege wangapi jumla?"; a: "10"; b: "25"; c: "20"; d: "15"; correct: "25" }
        ListElement { q: "Mfululizo wa namba: 2, 4, 8, 16, ... Namba ya 6 itakuwa?"; a: "32"; b: "64"; c: "48"; d: "128"; correct: "64" }

        // --- LOGIC ZA KUTEGA (10 QUESTIONS)

        ListElement { q: "Kama unaniita, mimi huvunjika. Mimi ni nani?"; a: "Kioo"; b: "Ukuta"; c: "Ukimya"; d: "Siri"; correct: "Ukimya" }
        ListElement { q: "Baba yake Juma ana watoto wanne: Januari, Februari, na Machi. Wa nne anaitwa nani?"; a: "Aprili"; b: "Juma"; c: "Mei"; d: "Agosti"; correct: "Juma" }
        ListElement { q: "Ni nini kina kichwa na mguu, lakini hakina mwili?"; a: "Senti/Sarafu"; b: "Msumari"; c: "Kitanda"; d: "Mlima"; correct: "Kitanda" }
        ListElement { q: "Kuna nini katikati ya 'TANZANIA'?"; a: "Z"; b: "N"; c: "A"; d: "I"; correct: "Z" }
        ListElement { q: "Ninaruka bila mabawa na ninalia bila macho. Mimi ni nani?"; a: "Ndege"; b: "Wingu/Mvua"; c: "Upepo"; d: "Moshi"; correct: "Wingu/Mvua" }

        ListElement { q: "Mtu mmoja alikuwa nje kwenye mvua kubwa bila mwavuli wala kofia, lakini unywele wake hata mmoja haukulowa. Kwa nini?"; a: "Alikimbia sana"; b: "Alikuwa na kipara (hana nywele)"; c: "Mvua ilikuwa ndogo"; d: "Alivaa koti"; correct: "Alikuwa na kipara (hana nywele)" }
        ListElement { q: "Ni nini kinaingia majini lakini hakilowi?"; a: "Kivuli"; b: "Chumvi"; c: "Karatasi"; d: "Sifongo"; correct: "Kivuli" }
        ListElement { q: "Ni neno gani limeandikwa vibaya kwenye kamusi zote duniani?"; a: "Makosa"; b: "Vibaya"; c: "Uongo"; d: "Sahihisha"; correct: "Vibaya" }
        ListElement { q: "Ukienda kulala saa mbili usiku na ukategesha saa ya mshale kukuamsha saa tatu asubuhi, utakuwa umelala saa ngapi?"; a: "Saa 13"; b: "Saa 1"; c: "Saa 11"; d: "Saa 9"; correct: "Saa 1" }
        ListElement { q: "Kama mzungu mweusi akivaa koti la bluu na akaingia kwenye Bahari ya Shamu (Red Sea), anakuwa nani?"; a: "Mzungu mwekundu"; b: "Mlowezi"; c: "Mzungu mweusi aliyelowa"; d: "Mfu"; correct: "Mzungu mweusi aliyelowa" }

        // --- VITENDAWILI

        ListElement { q: "Kitendawili: Nyumba yangu haina mlango."; a: "Yai"; b: "Kaburi"; c: "Chumvi"; d: "Tango"; correct: "Yai" }
        ListElement { q: "Kitendawili: Askari wangu wote wamevaa kofia nyekundu."; a: "Vidole"; b: "Kiberiti"; c: "Askari kanzu"; d: "Meno"; correct: "Kiberiti" }
        ListElement { q: "Kitendawili: Kamba yangu ndefu lakini haifungi kuni."; a: "Nyoka"; b: "Barabara"; c: "Mshipi"; d: "Mto"; correct: "Barabara" }
        ListElement { q: "Kitendawili: Babu yangu hacheki mpaka achunwe ngozi."; a: "Mahindi"; b: "Ndizi"; c: "Chungwa"; d: "Kitunguu"; correct: "Mahindi" }
        ListElement { q: "Kitendawili: Mvua hapa, mvua kule, lakini katikati pakavu."; a: "Mwavuli"; b: "Nyumba"; c: "Mtu aliyevaa koti"; d: "Daraja"; correct: "Nyumba" }

// --- UKEREWE (3 QUESTIONS) ---
ListElement { q: "Kisiwa cha Ukerewe kinapatikana ndani ya ziwa gani?"; a: "Tanganyika"; b: "Nyasa"; c: "Victoria"; d: "Eyasi"; correct: "Victoria" }

ListElement { q: "Ukerewe ni wilaya inayopatikana katika mkoa gani nchini Tanzania?"; a: "Mwanza"; b: "Mara"; c: "Geita"; d: "Kagera"; correct: "Mwanza" }

// --- TEKNOLOJIA YA ANGA
ListElement { q: "Ni sayari gani inajulikana kama 'Sayari Nyekundu' (Red Planet)?"; a: "Jupiter"; b: "Venus"; c: "Mars"; d: "Saturn"; correct: "Mars" }

ListElement { q: "Chombo cha kwanza kilichompeleka binadamu mwezini (Apollo 11) kilikuwa cha nchi gani?"; a: "Urusi"; b: "Marekani"; c: "China"; d: "Uingereza"; correct: "Marekani" }

ListElement { q: "Ni nini jina la darubini kubwa zaidi na ya kisasa iliyorushwa angani hivi karibuni?"; a: "Hubble"; b: "Galileo"; c: "James Webb"; d: "Newton"; correct: "James Webb" }

ListElement { q: "Gesi gani inapatikana kwa wingi zaidi katika anga la Dunia (Atmosphere)?"; a: "Oxygen"; b: "Nitrogen"; c: "Carbon Dioxide"; d: "Argon"; correct: "Nitrogen" }

// --- ELIMU 
ListElement { q: "Kirefu cha neno NECTA ni nini kwa Kiswahili?"; a: "Baraza la Mitihani la Tanzania"; b: "Wizara ya Elimu"; c: "Bodi ya Mikopo"; d: "Tume ya Vyuo Vikuu"; correct: "Baraza la Mitihani la Tanzania" }
ListElement { q: "Katika mfumo wa NECTA, daraja 'A' kwenye mtihani wa kidato cha nne huanzia alama ngapi?"; a: "70"; b: "75"; c: "81"; d: "65"; correct: "75" }
ListElement { q: "Ni mwaka gani Tanzania ilianza rasmi mfumo wa elimu ya bila malipo kwa shule za msingi na sekondari?"; a: "2010"; b: "2015"; c: "2020"; d: "2005"; correct: "2015" }

ListElement { q: "Siku ya kwanza ya mzunguko wa hedhi huhesabiwa kuanzia lini?"; a: "Siku hedhi inapoisha"; b: "Siku ya kwanza kuona damu"; c: "Siku ya 14"; d: "Siku yoyote"; correct: "Siku ya kwanza kuona damu" }
ListElement { q: "Kirusi kinachosababisha UKIMWI kinaitwa?"; a: "Bacteria"; b: "VVU (HIV)"; c: "Plasmodium"; d: "Fungi"; correct: "VVU (HIV)" }
ListElement { q: "Ni ugonjwa upi wa zinaa unaweza kusababisha upofu kwa mtoto wakati wa kuzaliwa?"; a: "Kaswende"; b: "Kisonono (Gonorrhea)"; c: "Homa ya Ini"; d: "Teepee"; correct: "Kisonono (Gonorrhea)" }
ListElement { q: "Njia ya uhakika zaidi ya kuzuia mimba na magonjwa ya zinaa kwa wakati mmoja ni?"; a: "Vidonge"; b: "Kondomu"; c: "Sindano"; d: "Kalenda"; correct: "Kondomu" }
ListElement { q: "Kipindi ambacho yai la mwanamke linatoka tayari kurutubishwa huitwa?"; a: "Hedhi"; b: "Ovulation (Upevushaji)"; c: "Mimba"; d: "Kukoma hedhi"; correct: "Ovulation (Upevushaji)" }

ListElement { q: "Ugonjwa wa Kaswende husababishwa na nini?"; a: "Virusi"; b: "Bacteria"; c: "Uchafu"; d: "Minyoo"; correct: "Bacteria" }
ListElement { q: "Chanjo ya HPV hutolewa ili kuzuia saratani gani kwa wanawake?"; a: "Saratani ya matiti"; b: "Saratani ya mlango wa uzazi"; c: "Saratani ya ini"; d: "Saratani ya ngozi"; correct: "Saratani ya mlango wa uzazi" }
ListElement { q: "Mimba ya kawaida ya binadamu huchukua wastani wa wiki ngapi?"; a: "30"; b: "36"; c: "40"; d: "45"; correct: "40" }
ListElement { q: "Ni vimelea gani husababisha ugonjwa wa Trichomoniasis?"; a: "Virusi"; b: "Bacteria"; c: "Protozoa"; d: "Fungi"; correct: "Protozoa" }
ListElement { q: "Upasuaji mdogo kwa wanaume ili kuzuia uwezo wa kutoa mbegu za uzazi huitwa?"; a: "Vasectomy"; b: "Circumcision"; c: "Dialysis"; d: "Biopsy"; correct: "Vasectomy" }
ListElement { q: "Kifupi cha PID katika afya ya uzazi inamaanisha?"; a: "Pelvic Inflammatory Disease"; b: "Private Internal Disease"; c: "Period Internal Delay"; d: "Pain In Digestion"; correct: "Pelvic Inflammatory Disease" }
ListElement { q: "Je, mwanamke anaweza kupata mimba akishiriki tendo la ndoa mara moja pekee?"; a: "Hapana"; b: "Ndiyo"; c: "Inategemea umri"; d: "Haiwezekani"; correct: "Ndiyo" }
ListElement { q: "Ni ugonjwa gani wa zinaa unaoshambulia zaidi Ini?"; a: "Kisonono"; b: "Homa ya Ini B (Hepatitis B)"; c: "Kaswende"; d: "Vifundo"; correct: "Homa ya Ini B (Hepatitis B)" }
ListElement { q: "Mbegu za kiume hutengenezwa sehemu gani ya mwili?"; a: "Kibofu"; b: "Mapumbu (Testes)"; c: "Uume"; d: "Mifuko ya mkojo"; correct: "Mapumbu (Testes)" }
ListElement { q: "Kukoma kwa hedhi kabisa kwa mwanamke (Menopause) hutokea wastani wa umri gani?"; a: "20-30"; b: "45-55"; c: "30-40"; d: "60-70"; correct: "45-55" }
ListElement { q: "Ni ipi dalili ya kawaida ya Kisonono kwa wanaume?"; a: "Kutoa usaha kwenye uume"; b: "Kukohoa"; c: "Maumivu ya mgongo"; d: "Kupoteza nywele"; correct: "Kutoa usaha kwenye uume" }
ListElement { q: "Upungufu wa damu kwa mama mjamzito mara nyingi husababishwa na ukosefu wa?"; a: "Sukari"; b: "Madini ya Chuma"; c: "Chumvi"; d: "Mafuta"; correct: "Madini ya Chuma" }
ListElement { q: "Neno 'Uziwi' wa mtoto mchanga unaweza kusababishwa na maambukizi ya?"; a: "Rubella"; b: "Mafua"; c: "Kikohozi"; d: "Fangasi"; correct: "Rubella" }
ListElement { q: "Tendo la kuunganisha yai la kike na mbegu ya kiume huitwa?"; a: "Urutubishaji (Fertilization)"; b: "Upevushaji"; c: "Hedhi"; d: "Uzazi"; correct: "Urutubishaji (Fertilization)" }
ListElement { q: "Je, mtu anaweza kuwa na ugonjwa wa zinaa bila kuonyesha dalili zozote?"; a: "Hapana"; b: "Ndiyo"; c: "Ni nadra"; d: "Haiwezekani"; correct: "Ndiyo" }

ListElement { q: "Tendo la kutoa damu kila mwezi kwa wasichana huitwa?"; a: "Kuvunja ungo"; b: "Hedhi"; c: "Ovulation"; d: "Mimba"; correct: "Hedhi" }
ListElement { q: "Ni homoni ipi inawajibika kwa mabadiliko ya kiume wakati wa kubalehe?"; a: "Estrogen"; b: "Progesterone"; c: "Testosterone"; d: "Insulin"; correct: "Testosterone" }
ListElement { q: "Mabadiliko ya sauti kuwa nzito kwa wavulana ni ishara ya?"; a: "Kubalehe"; b: "Ugonjwa"; c: "Uchovu"; d: "Kukua kwa mapafu"; correct: "Kubalehe" }
ListElement { q: "Kukua kwa matiti na kuanza hedhi ni ishara za kubalehe kwa?"; a: "Wavulana"; b: "Wasichana"; c: "Wote wawili"; d: "Watoto wachanga"; correct: "Wasichana" }
ListElement { q: "Tezi inayodhibiti mwanzo wa mchakato wa kubalehe inaitwa?"; a: "Pituitary"; b: "Thyroid"; c: "Adrenal"; d: "Pancreas"; correct: "Pituitary" }

ListElement { q: "Ni homoni ipi kuu inayosababisha mabadiliko kwa wasichana?"; a: "Estrogen"; b: "Testosterone"; c: "Adrenaline"; d: "Thyroxine"; correct: "Estrogen" }
ListElement { q: "Kuota chunusi wakati wa kubalehe mara nyingi husababishwa na?"; a: "Mabadiliko ya homoni"; b: "Kutokunawa uso"; c: "Kula sukari"; d: "Baridi"; correct: "Mabadiliko ya homoni" }
ListElement { q: "Ndoto za usiku zinazopelekea kutoa mbegu za kiume (Wet dreams) ni jambo la?"; a: "Kawaida/Kutokua"; b: "Kawaida/Afya"; c: "Hatari"; d: "Ugonjwa"; correct: "Kawaida/Afya" }
ListElement { q: "Wastani wa umri wa kuanza kubalehe kwa wasichana ni?"; a: "5-7"; b: "10-14"; c: "18-21"; d: "25-30"; correct: "10-14" }
ListElement { q: "Kupanuka kwa mabega ni tabia ya mabadiliko ya kubalehe kwa?"; a: "Wavulana"; b: "Wasichana"; c: "Wazee"; d: "Hakuna"; correct: "Wavulana" }
ListElement { q: "Mabadiliko ya kihisia na kuanza kuvutiwa na jinsia tofauti huanza kipindi cha?"; a: "Utoto"; b: "Kubalehe"; c: "Uzee"; d: "Uzaliwa"; correct: "Kubalehe" }
ListElement { q: "Kukua kwa 'Adam's Apple' shingoni ni ishara kwa?"; a: "Wavulana"; b: "Wasichana"; c: "Wote"; d: "Wanyama"; correct: "Wavulana" }


ListElement { q: "Kirefu cha AI ni nini?"; a: "Art Intelligent"; b: "Artificial Intelligence"; c: "Automated Info"; d: "Advanced Intel"; correct: "Artificial Intelligence" }
ListElement { q: "Ni mfumo upi wa AI uliotengenezwa na kampuni ya OpenAI?"; a: "Siri"; b: "ChatGPT"; c: "Alexa"; d: "Bixby"; correct: "ChatGPT" }
ListElement { q: "Uwezo wa AI kujifunza kupitia data bila kupewa maelekezo ya kila hatua huitwa?"; a: "Machine Learning"; b: "Coding"; c: "Typing"; d: "Hardware"; correct: "Machine Learning" }


ListElement { q: "AI inayoweza kutengeneza picha au maandishi mapya huitwa?"; a: "Static AI"; b: "Generative AI"; c: "Old AI"; d: "Manual AI"; correct: "Generative AI" }
ListElement { q: "Robot maarufu mwenye uraia wa Saudi Arabia anaitwa?"; a: "Sophia"; b: "Alexa"; c: "Siri"; d: "Jarvis"; correct: "Sophia" }
ListElement { q: "Kampuni ya Google imetengeneza AI inayoitwa?"; a: "Gemini"; b: "ChatGPT"; c: "Claude"; d: "Llama"; correct: "Gemini" }
ListElement { q: "Ni kifaa gani kinatumia AI kutambua uso wa mtu (Face ID)?"; a: "Simu Janja"; b: "Pasi ya umeme"; c: "Redio"; d: "Saa ya ukutani"; correct: "Simu Janja" }
ListElement { q: "AI inayotumika kuendesha magari bila dereva inaitwa?"; a: "Manual Driving"; b: "Autonomous Driving"; c: "Remote Control"; d: "Flying AI"; correct: "Autonomous Driving" }
ListElement { q: "Turing Test inatumika kupima nini?"; a: "Uwezo wa AI kufikiri kama binadamu"; b: "Kasi ya intaneti"; c: "Ukubwa wa betri"; d: "Ubora wa kioo"; correct: "Uwezo wa AI kufikiri kama binadamu" }
ListElement { q: "Lugha ya kompyuta inayotumika zaidi kwenye AI ni?"; a: "Python"; b: "HTML"; c: "CSS"; d: "SQL"; correct: "Python" }
ListElement { q: "Kifaa kinachotumia AI nyumbani kutoa taarifa kwa sauti (mfano Alexa) huitwa?"; a: "Smart Speaker"; b: "Microphone"; c: "Radio"; d: "TV"; correct: "Smart Speaker" }
ListElement { q: "AI inaweza kupata 'Hallucinations'. Hii inamaanisha nini?"; a: "Inatoa majibu ya uongo kwa kujiamini"; b: "Inazima yenyewe"; c: "Inapata virusi"; d: "Inafanya kazi haraka"; correct: "Inatoa majibu ya uongo kwa kujiamini" }
ListElement { q: "Mwasisi wa AI anayefahamika kama baba wa AI ni?"; a: "Alan Turing"; b: "Bill Gates"; c: "Elon Musk"; d: "Steve Jobs"; correct: "Alan Turing" }
ListElement { q: "Deep Learning ni sehemu ya nini?"; a: "Machine Learning"; b: "Hardware"; c: "Agriculture"; d: "Physics"; correct: "Machine Learning" }
ListElement { q: "AI inatumia nini ili kufanya maamuzi haraka?"; a: "Algorithms"; b: "Maji"; c: "Upepo"; d: "Petroli"; correct: "Algorithms" }


ListElement { q: "Kitendawili: Nyumba yangu haina mlango."; a: "Yai"; b: "Chupa"; c: "Kaburi"; d: "Tango"; correct: "Yai" }
ListElement { q: "Kitendawili: Kila nikienda ananifuata."; a: "Kivuli"; b: "Mbwa"; c: "Rafiki"; d: "Upepo"; correct: "Kivuli" }
ListElement { q: "Kitendawili: Babu amebeba gitaa mgongoni."; a: "Kobe"; b: "Konokono"; c: "Mzee"; d: "Kiti"; correct: "Kobe" }
ListElement { q: "Kitendawili: Daima anatazama juu."; a: "Nyasi"; b: "Moshi"; c: "Mvua"; d: "Mbuyu"; correct: "Nyasi" }
ListElement { q: "Kitendawili: Ana meno mengi lakini hali chakula."; a: "Kitana"; b: "Simba"; c: "Msumeno"; d: "Paka"; correct: "Kitana" }

ListElement { q: "Kifupi cha teknolojia ya 'Wi-Fi' inamaanisha nini?"; a: "Wireless Fidelity"; b: "Wireless Fiber"; c: "Wire Filter"; d: "Wide Field"; correct: "Wireless Fidelity" }
ListElement { q: "Ni kampuni gani ilitengeneza mfumo wa uendeshaji wa Windows?"; a: "Apple"; b: "Microsoft"; c: "IBM"; d: "Google"; correct: "Microsoft" }
ListElement { q: "Sehemu ya siri ya mtandao ambayo haionekani kirahisi kwenye search engines huitwa?"; a: "Dark Web"; b: "Public Web"; c: "Safe Web"; d: "Open Web"; correct: "Dark Web" }
ListElement { q: "Kifaa kinachotumika kubadilisha nishati ya jua kuwa umeme huitwa?"; a: "Solar Panel"; b: "Generator"; c: "Battery"; d: "Inverter"; correct: "Solar Panel" }
ListElement { q: "Katika email, kirefu cha 'BCC' ni nini?"; a: "Blind Carbon Copy"; b: "Best Carbon Copy"; c: "Basic Clear Copy"; d: "Business Case Copy"; correct: "Blind Carbon Copy" }
ListElement { q: "Ni lugha gani ya programu (Coding) inayotumika zaidi kutengeneza kurasa za tovuti (Websites)?"; a: "HTML"; b: "C++"; c: "Swift"; d: "Kotlin"; correct: "HTML" }
ListElement { q: "Kifaa kinachounganisha kompyuta yako na mtandao wa intaneti huitwa?"; a: "Router"; b: "Scanner"; c: "Printer"; d: "Monitor"; correct: "Router" }
ListElement { q: "Teknolojia ya kuratibu maeneo kwa kutumia satelaiti inaitwa?"; a: "GPS"; b: "SMS"; c: "UPS"; d: "CCTV"; correct: "GPS" }
ListElement { q: "Namba ya utambulisho wa kipekee kwa kila simu (IMEI) ina tarakimu ngapi?"; a: "10"; b: "15"; c: "12"; d: "16"; correct: "15" }
ListElement { q: "Kitufe cha 'F5' kwenye keyboard ya kompyuta mara nyingi hutumika kwa kazi gani?"; a: "Kufuta"; b: "Ku-Refresh"; c: "Kuzima"; d: "Kuhifadhi"; correct: "Ku-Refresh" }
ListElement { q: "Ni nini kazi ya 'Firewall' kwenye kompyuta?"; a: "Kuzuia virusi na wadukuzi"; b: "Kupunguza joto"; c: "Kuongeza kasi"; d: "Kupiga picha"; correct: "Kuzuia virusi na wadukuzi" }
ListElement { q: "Teknolojia ya kuhifadhi data kwenye mtandao badala ya diski ya kompyuta huitwa?"; a: "Cloud Storage"; b: "Hard Drive"; c: "Flash Disk"; d: "RAM"; correct: "Cloud Storage" }
ListElement { q: "Ni nani anayefahamika kama mwanzilishi wa Facebook (Meta)?"; a: "Mark Zuckerberg"; b: "Bill Gates"; c: "Elon Musk"; d: "Jeff Bezos"; correct: "Mark Zuckerberg" }

ListElement { q: "Ni kiungo gani cha mwili kinachohusika na kusafisha damu?"; a: "Moyo"; b: "Figo"; c: "Mapafu"; d: "Tumbo"; correct: "Figo" }
ListElement { q: "Damu ya binadamu ina rangi nyekundu kwa sababu ya protini iitwayo?"; a: "Hemoglobin"; b: "Insulin"; c: "Keratin"; d: "Melanin"; correct: "Hemoglobin" }
ListElement { q: "Ni tunda gani lina vitamini C kwa wingi zaidi?"; a: "Chungwa"; b: "Ndizi"; c: "Tikiti"; d: "Tufaha (Apple)"; correct: "Chungwa" }
ListElement { q: "Binadamu ana jozi ngapi za kromozomu (Chromosomes)?"; a: "23"; b: "46"; c: "20"; d: "30"; correct: "23" }
ListElement { q: "Ni aina gani ya damu (Blood Group) inayoweza kutoa kwa makundi yote (Universal Donor)?"; a: "Group A"; b: "Group B"; c: "Group AB"; d: "Group O"; correct: "Group O" }
ListElement { q: "Mifupa ya binadamu mtu mzima imegawanyika katika vipande vingapi?"; a: "100"; b: "206"; c: "300"; d: "150"; correct: "206" }
ListElement { q: "Kiungo kikubwa zaidi cha nje cha mwili wa binadamu ni?"; a: "Ngozi"; b: "Mapafu"; c: "Ini"; d: "Miguu"; correct: "Ngozi" }
ListElement { q: "Viumbe hai wanaokula mimea pekee huitwa?"; a: "Herbivores"; b: "Carnivores"; c: "Omnivores"; d: "Parasites"; correct: "Herbivores" }
ListElement { q: "Ni vitamini gani inayopatikana kwa wingi kupitia mwanga wa jua la asubuhi?"; a: "Vitamini A"; b: "Vitamini C"; c: "Vitamini D"; d: "Vitamini K"; correct: "Vitamini D" }
ListElement { q: "Sehemu ya jicho inayohusika na kuingiza mwanga huitwa?"; a: "Pupil"; b: "Retina"; c: "Lens"; d: "Iris"; correct: "Pupil" }
ListElement { q: "Ni wadudu gani wanaosafirisha chavua (Pollination) kwa kiasi kikubwa duniani?"; a: "Nyuki"; b: "Mbu"; c: "Mende"; d: "Nzi"; correct: "Nyuki" }
ListElement { q: "Zoezi la mimea kutengeneza chakula chake kwa kutumia mwanga wa jua huitwa?"; a: "Photosynthesis"; b: "Respiration"; c: "Digestion"; d: "Osmosis"; correct: "Photosynthesis" }
ListElement { q: "Mapigo ya moyo ya binadamu mwenye afya kwa dakika ni wastani wa?"; a: "40-60"; b: "70-80"; c: "100-120"; d: "20-30"; correct: "70-80" }

ListElement { q: "Ni chombo gani kinatumika kupima kiasi cha mvua iliyonyesha?"; a: "Thermometer"; b: "Rain Gauge"; c: "Barometer"; d: "Anemometer"; correct: "Rain Gauge" }
ListElement { q: "Radi hutokea kwa sababu ya msuguano wa nini angani?"; a: "Mawingu"; b: "Ndege"; c: "Nyota"; d: "Mwezi"; correct: "Mawingu" }
ListElement { q: "Mvua inayonyesha baada ya maji ya bahari kupata joto na kupaisha mvuke huitwa?"; a: "Convectional Rain"; b: "Relief Rain"; c: "Cyclonic Rain"; d: "Acid Rain"; correct: "Convectional Rain" }
ListElement { q: "Ni gesi gani inatengeneza asilimia 21 ya hewa ya anga (Atmosphere)?"; a: "Nitrogen"; b: "Oxygen"; c: "Carbon Dioxide"; d: "Hydrogen"; correct: "Oxygen" }
ListElement { q: "Mstari wa kidhahania unaogawanya dunia katika ncha ya kaskazini na kusini ni?"; a: "Equator (Ikweta)"; b: "Longitude"; c: "Tropic of Cancer"; d: "Prime Meridian"; correct: "Equator (Ikweta)" }
ListElement { q: "Sauti ya kishindo inayosikika baada ya mwanga wa radi huitwa?"; a: "Umeme"; b: "Mngurumo"; c: "Upepo"; d: "Mwangwi"; correct: "Mngurumo" }
ListElement { q: "Zoezi la maji kugeuka kuwa mvuke kutokana na joto huitwa?"; a: "Evaporation"; b: "Condensation"; c: "Freezing"; d: "Melting"; correct: "Evaporation" }
ListElement { q: "Ni bahari gani iliyo kubwa zaidi duniani?"; a: "Hindi"; b: "Pasifiki (Pacific)"; c: "Atlantiki"; d: "Shamu"; correct: "Pasifiki (Pacific)" }
ListElement { q: "Safu ya milima mirefu zaidi duniani inaitwa?"; a: "Himalayas"; b: "Andes"; c: "Alps"; d: "Kilimanjaro"; correct: "Himalayas" }
ListElement { q: "Ni mkoa gani nchini Tanzania unaosifika kwa kuwa na mvua nyingi karibu mwaka mzima?"; a: "Dodoma"; b: "Njombe"; c: "Singida"; d: "Simiyu"; correct: "Njombe" }
ListElement { q: "Chombo kinachopima kasi ya upepo huitwa?"; a: "Anemometer"; b: "Hygrometer"; c: "Seismograph"; d: "Compass"; correct: "Anemometer" }
ListElement { q: "Vumbi na moshi vikichanganyika na ukungu angani huitwa?"; a: "Smog"; b: "Snow"; c: "Ice"; d: "Dew"; correct: "Smog" }
ListElement { q: "Maji ya chumvi duniani yanapatikana kwa kiasi gani?"; a: "50%"; b: "97%"; c: "10%"; d: "75%"; correct: "97%" }

ListElement { q: "Ni mbu yupi anayeeneza vimelea vya ugonjwa wa Malaria?"; a: "Anopheles Jike"; b: "Anopheles Dume"; c: "Culex"; d: "Aedes"; correct: "Anopheles Jike" }
ListElement { q: "Vimelea vinavyosababisha ugonjwa wa Malaria huitwa?"; a: "Plasmodium"; b: "Amoeba"; c: "Virusi"; d: "Bacteria"; correct: "Plasmodium" }
ListElement { q: "Ni njia ipi bora ya kuzuia mbu wa malaria wasikufikie ukiwa umelala?"; a: "Chandarua"; b: "Kipepeo"; c: "Kufunga mlango"; d: "Kupaka mafuta ya nazi"; correct: "Chandarua" }
ListElement { q: "Malaria inashambulia zaidi seli zipi mwilini?"; a: "Seli nyekundu za damu"; b: "Seli nyeupe"; c: "Seli za ubongo"; d: "Seli za mifupa"; correct: "Seli nyekundu za damu" }
ListElement { q: "Ni ipi dalili ya kawaida ya ugonjwa wa Malaria?"; a: "Homa na baridi"; b: "Kupoteza nywele"; c: "Kuumwa meno"; d: "Kuvimba miguu"; correct: "Homa na baridi" }
ListElement { q: "Dawa inayopendekezwa na Serikali ya TZ kwa matibabu ya kwanza ya Malaria kwa sasa ni?"; a: "AL (Mseto)"; b: "Quinine"; c: "Panadol"; d: "Asprin"; correct: "AL (Mseto)" }
ListElement { q: "Ni kundi lipi lililo hatarini zaidi kupata madhara makubwa ya Malaria?"; a: "Watoto chini ya miaka 5"; b: "Vijana"; c: "Wanaume"; d: "Wanariadha"; correct: "Watoto chini ya miaka 5" }
ListElement { q: "Mbu wa malaria hupenda kuzaliana sehemu gani?"; a: "Maji yaliyotuama"; b: "Kwenye mchanga"; c: "Ndani ya chupa"; d: "Juu ya miti"; correct: "Maji yaliyotuama" }
ListElement { q: "Kipimo cha haraka cha Malaria kinachotumika kwenye vituo vya afya huitwa?"; a: "mRDT"; b: "X-Ray"; c: "Ultrasound"; d: "MRI"; correct: "mRDT" }
ListElement { q: "Ni kiungo gani mwilini kinachoweza kuvimba kutokana na malaria kali?"; a: "Wengu (Spleen)"; b: "Moyo"; c: "Kidole"; d: "Sikio"; correct: "Wengu (Spleen)" }
ListElement { q: "Kufyeka nyasi na kufukia madimbwi ni njia ya?"; a: "Kuharibu mazalia ya mbu"; b: "Kupamba mji"; c: "Kupata mbolea"; d: "Kuongeza joto"; correct: "Kuharibu mazalia ya mbu" }
ListElement { q: "Siku ya Malaria Duniani huadhimishwa kila mwaka tarehe ngapi?"; a: "Aprili 25"; b: "Desemba 1"; c: "Machi 8"; d: "Januari 1"; correct: "Aprili 25" }
ListElement { q: "Ni mkoa upi Tanzania unaotajwa kuwa na maambukizi makubwa ya Malaria kutokana na hali ya hewa?"; a: "Kigoma/Geita"; b: "Dodoma"; c: "Arusha"; d: "Manyara"; correct: "Kigoma/Geita" }

ListElement { q: "Ni kundi gani la kabila nchini Tanzania linalojulikana kwa kuishi kwa kuwinda na kula mizizi?"; a: "Wamasai"; b: "Wahadzabe"; c: "Wachagga"; d: "Wanyamwezi"; correct: "Wahadzabe" }
ListElement { q: "Kabila la Wamakonde linasifika duniani kwa kipaji gani cha asili?"; a: "Ufugaji wa nyuki"; b: "Uchongaji wa vinyago"; c: "Kusuka mikeka"; d: "Ujenzi wa meli"; correct: "Uchongaji wa vinyago" }
ListElement { q: "Ngoma ya 'Sindimba' inatokea katika makabila ya mikoa gani ya Kusini?"; a: "Mtwara na Lindi"; b: "Mbeya na Iringa"; c: "Kigoma na Tabora"; d: "Mwanza na Mara"; correct: "Mtwara na Lindi" }
ListElement { q: "Kabila gani nchini Tanzania linaongoza kwa idadi kubwa ya watu?"; a: "Wasukuma"; b: "Waha"; c: "Wagogo"; d: "Wazaramo"; correct: "Wasukuma" }
ListElement { q: "Chakula cha asili cha Wachagga kinachotengenezwa kwa ndizi na maharage huitwa?"; a: "Ugali"; b: "Mtori"; c: "Kiburu"; d: "Wali"; correct: "Kiburu" }

ListElement { q: "Ni sayari gani iliyo kubwa zaidi katika mfumo wetu wa Jua?"; a: "Dunia"; b: "Saturn"; c: "Jupiter"; d: "Neptune"; correct: "Jupiter" }
ListElement { q: "Galaxy yetu tunamoishi inaitwa jina gani?"; a: "Andromeda"; b: "Milky Way (Njia ya Mtindi)"; c: "Sombrero"; d: "Black Eye"; correct: "Milky Way (Njia ya Mtindi)" }
ListElement { q: "Sayari ya Saturn inafahamika zaidi kwa kuwa na nini kinachoizunguka?"; a: "Maji"; b: "Pete (Rings)"; c: "Moto"; d: "Mwangaza wa kijani"; correct: "Pete (Rings)" }
ListElement { q: "Jua ni nini hasa katika sayansi ya anga?"; a: "Sayari"; b: "Nyota (Star)"; c: "Satelaiti"; d: "Jiwe"; correct: "Nyota (Star)" }
ListElement { q: "Ni sayari gani iliyo karibu zaidi na Jua?"; a: "Venus"; b: "Mars"; c: "Mercury"; d: "Dunia"; correct: "Mercury" }
ListElement { q: "Mwanga wa Jua huchukua takriban dakika ngapi kufika Duniani?"; a: "Sekunde 30"; b: "Dakika 8"; c: "Saa 1"; d: "Siku 2"; correct: "Dakika 8" }
ListElement { q: "Ni sayari gani inayofahamika kama 'Pacha wa Dunia' kwa sababu ya ukubwa wake?"; a: "Venus"; b: "Jupiter"; c: "Mars"; d: "Uranus"; correct: "Venus" }
ListElement { q: "Eneo lenye nguvu kubwa ya uvutano angani ambapo hata mwanga hauwezi kutoroka huitwa?"; a: "Galaxy"; b: "Black Hole"; c: "Asteroid"; d: "Comet"; correct: "Black Hole" }

ListElement { q: "Fuvu la binadamu wa kale (Zinjanthropus) liligunduliwa na kina Leakey katika bonde gani?"; a: "Ngorongoro"; b: "Olduvai Gorge"; c: "Bonde la Ufa"; d: "Kilimatinde"; correct: "Olduvai Gorge" }
ListElement { q: "Michoro ya mapangoni ya Kondoa Irangi inasadikiwa kuchorwa na nani?"; a: "Wajerumani"; b: "Watu wa kale (Bushmen)"; c: "Waarabu"; d: "Wamasai"; correct: "Watu wa kale (Bushmen)" }
ListElement { q: "Zama ambapo binadamu alianza kutumia mawe kutengeneza vifaa huitwa?"; a: "Zama za Mawe"; b: "Zama za Chuma"; c: "Zama za Viwanda"; d: "Zama za Giza"; correct: "Zama za Mawe" }
ListElement { q: "Mji wa kale wa Kilwa Kisiwani ulikuwa kitovu cha biashara katika pwani ya?"; a: "Bahari ya Hindi"; b: "Bahari ya Shamu"; c: "Ziwa Victoria"; d: "Bahari ya Mediteranea"; correct: "Bahari ya Hindi" }

ListElement { q: "Soko kuu la mwisho la watumwa katika Afrika Mashariki lilikuwa wapi?"; a: "Bagamoyo"; b: "Zanzibar"; c: "Tabora"; d: "Mombasa"; correct: "Zanzibar" }
ListElement { q: "Vita vya Kwanza vya Dunia (WWI) vilianza mwaka gani?"; a: "1914"; b: "1939"; c: "1884"; d: "1945"; correct: "1914" }
ListElement { q: "Ni nchi gani ilivamia Poland na kusababisha kuanza kwa Vita vya Pili vya Dunia?"; a: "Uingereza"; b: "Ujerumani"; c: "Urusi"; d: "Italia"; correct: "Ujerumani" }
ListElement { q: "Kiongozi wa kijeshi wa Ujerumani wakati wa Vita vya Pili vya Dunia alikuwa nani?"; a: "Adolf Hitler"; b: "Winston Churchill"; c: "Benito Mussolini"; d: "Joseph Stalin"; correct: "Adolf Hitler" }
ListElement { q: "Mkataba wa Versailles ulihitimisha vita gani?"; a: "Vita vya Kwanza vya Dunia"; b: "Vita vya Pili vya Dunia"; c: "Vita vya Kagera"; d: "Vita vya Maji Maji"; correct: "Vita vya Kwanza vya Dunia" }
ListElement { q: "Mji mkuu wa kitumwa ambapo watumwa walipewa jina la 'Bwagamoyo' (Bagamoyo) unamaanisha nini?"; a: "Pumzika moyo"; b: "Tupa moyo"; c: "Furahisha moyo"; d: "Fariji moyo"; correct: "Tupa moyo" }

ListElement { q: "Rais gani wa Tanzania alijulikana kama 'Mzee wa Ruksa'?"; a: "Nyerere"; b: "Mwinyi"; c: "Mkapa"; d: "Kikwete"; correct: "Mwinyi" }
ListElement { q: "Vita vya Kagera (1978-1979) vilikuwa kati ya Tanzania na nchi gani?"; a: "Kenya"; b: "Uganda"; c: "Rwanda"; d: "Malawi"; correct: "Uganda" }
ListElement { q: "Ni nani alikuwa Rais wa Uganda wakati wa Vita vya Kagera?"; a: "Milton Obote"; b: "Idi Amin Dada"; c: "Yoweri Museveni"; d: "Tito Okello"; correct: "Idi Amin Dada" }
ListElement { q: "Rais wa awamu ya nne wa Tanzania ni nani?"; a: "Ali Hassan Mwinyi"; b: "Jakaya Kikwete"; c: "Benjamin Mkapa"; d: "John Magufuli"; correct: "Jakaya Kikwete" }
ListElement { q: "Rais Samia Suluhu Hassan alizaliwa katika mkoa gani?"; a: "Zanzibar (Unguja)"; b: "Pwani"; c: "Dar es Salaam"; d: "Zanzibar (Pemba)"; correct: "Zanzibar (Unguja)" }
ListElement { q: "Wimbo maarufu wa kishujaa uliotumika wakati wa Vita vya Kagera unaitwa?"; a: "Tanzania Tanzania"; b: "Mwenge wa Uhuru"; c: "Mvua ya Radi"; d: "Kifochura"; correct: "Kifochura" }
ListElement { q: "Rais Benjamin Mkapa alipewa jina la utani la?"; a: "Mzee wa Mapinduzi"; b: "Mr. Clean"; c: "Bulldozer"; d: "Chuma"; correct: "Mr. Clean" }
ListElement { q: "Ni Rais yupi alifariki akiwa madarakani mwaka 2021?"; a: "Nyerere"; b: "Magufuli"; c: "Mkapa"; d: "Karume"; correct: "Magufuli" }

ListElement { q: "Alama ya kikemia ya dhahabu (Gold) ni ipi?"; a: "Ag"; b: "Fe"; c: "Au"; d: "Gd"; correct: "Au" }
ListElement { q: "Gesi inayotumika kuzima moto inaitwa?"; a: "Oxygen"; b: "Carbon Dioxide"; c: "Hydrogen"; d: "Nitrogen"; correct: "Carbon Dioxide" }

ListElement { q: "PH ya maji yaliyo safi (Pure Water) ni ngapi?"; a: "0"; b: "7"; c: "14"; d: "5"; correct: "7" }

ListElement { q: "Tendo la chuma kupata kutu linahitaji vitu gani viwili?"; a: "Maji na Mafuta"; b: "Maji na Hewa (Oxygen)"; c: "Moto na Hewa"; d: "Mchanga na Maji"; correct: "Maji na Hewa (Oxygen)" }

ListElement { q: "Kizio cha kupimia mkondo wa umeme (Current) ni?"; a: "Volt"; b: "Watt"; c: "Ampere"; d: "Ohm"; correct: "Ampere" }
ListElement { q: "Ncha mbili za sumaku zinazofanana (mfano North na North) zikikutana hufanya nini?"; a: "Huvutana"; b: "Hupingana (Repel)"; c: "Huzima"; d: "Hulipuka"; correct: "Hupingana (Repel)" }


ListElement { q: "Kifaa kinachotumika kubadili nishati ya mwendo kuwa umeme huitwa?"; a: "Motor"; b: "Dynamo/Generator"; c: "Battery"; d: "Switch"; correct: "Dynamo/Generator" }
ListElement { q: "Nyaya za umeme mara nyingi hufunikwa na raba au plastiki kwa sababu ni?"; a: "Kinyeleo (Insulator)"; b: "Kipitisho (Conductor)"; c: "Nzito"; d: "Laini"; correct: "Kinyeleo (Insulator)" }

ListElement { q: "Chombo cha usafiri wa majini kinachoweza kuzama na kutembea chini ya maji huitwa?"; a: "Meli"; b: "Nyambizi (Submarine)"; c: "Mtumbwi"; d: "Pantoni"; correct: "Nyambizi (Submarine)" }
ListElement { q: "Ni nani anasifika kwa kuvumbua ndege ya kwanza duniani?"; a: "Wright Brothers"; b: "Thomas Edison"; c: "Henry Ford"; d: "Nikola Tesla"; correct: "Wright Brothers" }
ListElement { q: "Treni ya mwendokasi inayotumia umeme nchini Tanzania inajulikana kama?"; a: "TAZARA"; b: "SGR"; c: "Mwendokasi"; d: "TRC"; correct: "SGR" }
ListElement { q: "Kifaa kinachotumika kuongoza meli au ndege kujua upande wa Kaskazini huitwa?"; a: "Thermometer"; b: "Compass"; c: "Barometer"; d: "Radar"; correct: "Compass" }
ListElement { q: "Usafiri wa anga unaotumia puto kubwa lenye hewa ya moto unaitwa?"; a: "Helikopta"; b: "Hot Air Balloon"; c: "Parachute"; d: "Drone"; correct: "Hot Air Balloon" }


ListElement { q: "Kitendawili: Askari wangu wote huvaa kofia nyekundu."; a: "Kiberiti"; b: "Meno"; c: "Askari"; d: "Mawingu"; correct: "Kiberiti" }
ListElement { q: "Kitendawili: Kamba yangu ndefu lakini haifungi kuni."; a: "Njia/Barabara"; b: "Nyoka"; c: "Maji"; d: "Upepo"; correct: "Njia/Barabara" }
ListElement { q: "Kitendawili: Huenda lakini harudi."; a: "Maji ya mto"; b: "Miguu"; c: "Gari"; d: "Muda"; correct: "Maji ya mto" }
ListElement { q: "Kitendawili: Nyumbani kwangu kumesitiriwa kwa kuta nyeupe lakini hakuingiliki."; a: "Yai"; b: "Chumba"; c: "Gereza"; d: "Chupa"; correct: "Yai" }
ListElement { q: "Kitendawili: Anatembea kwa miguu minne asubuhi, miwili mchana, na mitatu jioni."; a: "Binadamu"; b: "Kobe"; c: "Mzee"; d: "Mtoto"; correct: "Binadamu" }

// --- MAGABE LAB
ListElement { q: "Magabe Lab inatumika zaidi kutengeneza mifumo ya aina gani?"; a: "Apps na Programu za Kompyuta"; b: "Kilimo cha kisasa"; c: "Ujenzi wa barabara"; d: "Ufugaji wa nyuki"; correct: "Apps na Programu za Kompyuta" }

ListElement { q: "Ni lugha gani ya programu (Coding) inayotumiwa na Magabe Lab kutengeneza interface ya App hii?"; a: "Python"; b: "C++"; c: "QML (Qt Quick)"; d: "PHP"; correct: "QML (Qt Quick)" }

ListElement { q: "Kwenye Magabe Lab, 'Frontend' ya App inahusika na nini?"; a: "Muonekano unaoonekana na mtumiaji"; b: "Uhifadhi wa siri kwenye database"; c: "Kutengeneza vioo vya simu"; d: "Kupiga picha za satelaiti"; correct: "Muonekano unaoonekana na mtumiaji" }

ListElement { q: "Ni mfumo upi wa uendeshaji (OS) ambao App za Magabe Lab zinaweza kufanya kazi?"; a: "Android pekee"; b: "Windows pekee"; c: "Android, iOS, na Windows"; d: "Redio za mbao pekee"; correct: "Android, iOS, na Windows" }

ListElement { q: "Lengo kuu la Magabe Lab katika kuleta teknolojia nchini Tanzania ni?"; a: "Kutoa burudani na elimu kidijitali"; b: "Kuuza simu zilizotumika"; c: "Kufundisha udereva wa malori"; d: "Kutengeneza michezo ya kamari pekee"; correct: "Kutoa burudani na elimu kidijitali" }

ListElement { q: "Msanii gani wa Tanzania alikuwa wa kwanza kushinda tuzo ya BET (Viewer's Choice Best New International Act)?"; a: "Diamond Platnumz"; b: "Rayvanny"; c: "Harmonize"; d: "Ali Kiba"; correct: "Rayvanny" }

ListElement { q: "Kundi la vichekesho lililojizolea umaarufu mkubwa nchini Tanzania kuanzia miaka ya 2000 linaitwa?"; a: "Orijino Komedi"; b: "Vituko Show"; c: "Mizengwe"; d: "Ze Komedi"; correct: "Orijino Komedi" }

ListElement { q: "Marehemu Steven Kanumba alikuwa mwigizaji maarufu aliyejulikana pia kwa jina lipi la kisanii?"; a: "The Great"; b: "The King"; c: "Director"; d: "Chairman"; correct: "The Great" }

ListElement { q: "Msanii wa kike wa Bongo Flava anayeshikilia rekodi ya kutazamwa zaidi (Most Viewed) YouTube ni?"; a: "Nandy"; b: "Zuchu"; c: "Shilole"; d: "Maua Sama"; correct: "Zuchu" }

ListElement { q: "Mchekeshaji gani nchini Tanzania anajulikana kwa mtindo wake wa kuvaa kama mwanamke na kutumia jina la 'Mkude Simba'?"; a: "Joti"; b: "Kitale"; c: "Mpoki"; d: "Mwijaku"; correct: "Kitale" }

ListElement { q: "Filamu ya kwanza ya Kitanzania kuingia katika mashindano makubwa ya 'Oscars' nchini Marekani inaitwa?"; a: "Tug of War (Vuta N'kuvute)"; b: "Bulyanhulu"; c: "Siri ya Mtungi"; d: "Dar ni Njema"; correct: "Tug of War (Vuta N'kuvute)" }

ListElement { q: "Msanii wa muziki anayefahamika kama 'King of Bongo Flava' na mmiliki wa lebo ya Kings Music ni?"; a: "Ali Kiba"; b: "Marioo"; c: "Dully Sykes"; d: "Professor Jay"; correct: "Ali Kiba" }

ListElement { q: "Mwigizaji gani wa kike nchini Tanzania alishinda tuzo ya 'Best Actress' katika tamasha la AMVCA nchini Nigeria?"; a: "Wema Sepetu"; b: "Elizabeth Michael (Lulu)"; c: "Jacqueline Wolper"; d: "Irene Uwoya"; correct: "Elizabeth Michael (Lulu)" }

ListElement { q: "Msanii gani wa vichekesho anayesifika kwa uwezo wa kuigiza sauti za viongozi mbalimbali na watu maarufu?"; a: "Mpoki"; b: "Joti"; c: "Ebitoke"; d: "Bwakila"; correct: "Joti" }

ListElement { q: "Lebo ya muziki inayomilikiwa na Diamond Platnumz inaitwa?"; a: "WCB Wasafi"; b: "Konde Gang"; c: "Kings Music"; d: "Next Level"; correct: "WCB Wasafi" }

ListElement { q: "Marehemu ambae alikuwa mwigizaji nguli wa maigizo ya runinga na kiongozi wa kundi la Kaole Sanaa Group ni?"; a: "Mzee Small"; b: "Mzee Majuto"; c: "Sajuki"; d: "Steve Kanumba"; correct: "Mzee Majuto" }

ListElement { q: "Wimbo wa 'Number One' uliomtangaza Diamond Platnumz kimataifa alimshirikisha msanii gani kutoka Nigeria?"; a: "Davido"; b: "Wizkid"; c: "Burna Boy"; d: "P-Square"; correct: "Davido" }

ListElement { q: "Mchekeshaji Coy Mzero anajulikana zaidi kupitia jukwaa gani la vichekesho nchini?"; a: "Cheka Tu"; b: "Comedy Knights"; c: "Stand Up Tanzania"; d: "Funny Fellas"; correct: "Cheka Tu" }

// --- MAWASILIANO
ListElement { q: "Mamlaka inayosimamia mawasiliano ya simu, intaneti, na utangazaji nchini Tanzania inaitwa?"; a: "TRA"; b: "TCRA"; c: "TANESCO"; d: "NIDA"; correct: "TCRA" }

ListElement { q: "Namba ya utambulisho wa kipekee inayopatikana kwenye simu (IMEI) hutumika kwa kazi gani?"; a: "Kupiga simu"; b: "Kutambua na kufungia simu iliyoibwa"; c: "Kuongeza salio"; d: "Kupima kasi ya intaneti"; correct: "Kutambua na kufungia simu iliyoibwa" }

ListElement { q: "Ni mfumo upi unaotumiwa na TCRA kusajili laini za simu kwa kutumia alama za vidole?"; a: "Mfumo wa Biometriki"; b: "Mfumo wa Analogi"; c: "Mfumo wa Satelaiti"; d: "Mfumo wa Sensa"; correct: "Mfumo wa Biometriki" }

ListElement { q: "Kadi ndogo inayowekwa kwenye simu ili kukuunganisha na mtandao (SIM Card) kirefu chake ni nini?"; a: "Subscriber Identity Module"; b: "System Internal Memory"; c: "Signal Integrated Mode"; d: "Social Identity Media"; correct: "Subscriber Identity Module" }


ListElement { q: "Namba ya huduma kwa wateja kwa kampuni zote za simu Tanzania iliyosanifiwa na TCRA ni ipi?"; a: "100"; b: "911"; c: "112"; d: "101"; correct: "100" }

// --- SHULE NA HISTORIA 
ListElement { q: "Mwalimu Julius K. Nyerere alisoma elimu yake ya sekondari katika shule gani maarufu?"; a: "Tabora Boys"; b: "Pugu Secondary"; c: "Mzumbe"; d: "Kibaha"; correct: "Tabora Boys" }

ListElement { q: "Ni shule ipi kati ya hizi inajulikana kama shule ya kitaifa ya wavulana yenye vipaji maalum (Special Talents School)?"; a: "Ilboru"; b: "Msalato"; c: "Jangwani"; d: "Azania"; correct: "Ilboru" }

ListElement { q: "Shule gani ya wasichana ya serikali mkoani Dodoma inajulikana kwa ufaulu mzuri na ni ya kiwango cha kitaifa?"; a: "Msalato Girls"; b: "Kilakala"; c: "Loleza"; d: "Weruweru"; correct: "Msalato Girls" }

ListElement { q: "Shule ya sekondari ya Tabora Girls inasifika kwa kuwa shule ya kwanza ya serikali kwa ajili ya?"; a: "Wasichana wenye vipaji"; b: "Walimu wa kike"; c: "Viongozi wa dini"; d: "Kilimo"; correct: "Wasichana wenye vipaji" }

ListElement { q: "Shule ya sekondari Kibaha (Kibaha Boys) inapatikana katika mkoa gani?"; a: "Dar es Salaam"; b: "Pwani"; c: "Morogoro"; d: "Tanga"; correct: "Pwani" }

ListElement { q: "Shule ipi ya kiume mkoani Morogoro inasifika kwa nidhamu ya kijeshi na ufaulu mkubwa wa masomo ya sayansi?"; a: "Mzumbe Secondary"; b: "Iyunga"; c: "Kantare"; d: "Milambo"; correct: "Mzumbe Secondary" }

// --- KILIMO CHA ZABIBU DODOMA
ListElement { q: "Zao kuu la kibiashara linalosifika kulimwa mkoani Dodoma na kutumika kutengeneza mvinyo (Wine) ni?"; a: "Pamba"; b: "Zabibu"; c: "Karafuu"; d: "Mkonge"; correct: "Zabibu" }


ListElement { q: "Ni kata gani mkoani Dodoma inayojulikana zaidi kwa kuanzisha na kuendeleza kilimo cha zabibu?"; a: "Makutupora"; b: "Chamwino"; c: "Kizota"; d: "Msalato"; correct: "Makutupora" }

ListElement { q: "Kwa nini mkoa wa Dodoma unafaa zaidi kwa kilimo cha zabibu kuliko mikoa mingine ya Tanzania?"; a: "Udongo mweusi na baridi"; b: "Hali ya hewa kavu na jua la kutosha"; c: "Mvua nyingi mwaka mzima"; d: "Uwepo wa bahari"; correct: "Hali ya hewa kavu na jua la kutosha" }

ListElement { q: "Ni mwezi gani mara nyingi wakulima wa zabibu Dodoma hufanya mavuno ya kwanza ya mwaka?"; a: "Januari - Machi"; b: "Juni - Julai"; c: "Oktoba - Novemba"; d: "Septemba"; correct: "Januari - Machi" }

// --- TABORA BOYS 
ListElement { q: "Shule ya Tabora Boys ilianzishwa mwaka 1922 na Waingereza kwa lengo la kuwasomesha nani?"; a: "Watoto wa machifu"; b: "Wafanyakazi wa reli"; c: "Wakulima wa pamba"; d: "Askari wa vita"; correct: "Watoto wa machifu" }

ListElement { q: "Mwalimu Julius K. Nyerere alipokuwa mwanafunzi Tabora Boys (1937-1942), alikuwa kiongozi wa klabu gani?"; a: "Klabu ya Mdahalo (Debating Society)"; b: "Klabu ya Mpira"; c: "Klabu ya Skauti"; d: "Klabu ya Kilimo"; correct: "Klabu ya Mdahalo (Debating Society)" }

ListElement { q: "Jina la awali la shule ya Tabora Boys kabla ya kuitwa jina la sasa lilikuwa nani?"; a: "Pugu School"; b: "Government Central School, Tabora"; c: "Milambo Secondary"; d: "Royal Boys Academy"; correct: "Government Central School, Tabora" }

    }

    Settings{
        id: askedQuestions
        property var data

        function add(q){
            data.push(q);
        }

        function removeAll(){
            for (var n = 0; n < data.length; n++) {
                const q = data[n];
                for (var x = 0; x < iqModel.count; x++) {
                    if (iqModel.get(x).q === q) {
                        iqModel.remove(x);
                        break;
                    }
                }
            }
        }

        function configure(){
            if((data === null) || (data === undefined) || ((iqModel.count - data.length) < maxQuestions)){
                data = [];
            } else {
                removeAll();
            }
        }

        Component.onCompleted: configure();
        Component.onDestruction: setValue("data",data);
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
        // 1. Safisha quizModel ya mchezo uliopita
        quizModel.clear();

        // 2. Angalia kama iqModel ina maswali ya kutosha
        var count = iqModel.count;
        if (count < maxQuestions) {
            console.log("Benki haina maswali ya kutosha! Maswali yameisha.");

            // Kama maswali yameisha, rudi kwenye ukurasa mkuu au fanya reload
            if(typeof n3ctaApp !== "undefined"){
                n3ctaApp.closeCustomPage();
                n3ctaApp.onUrlVisited("#IQTest");
            } else if(typeof loader !== "undefined"){
                loader.closeCustomPage();
                loader.onUrlVisited("#IQTest");
            }
            return;
        }

        // 3. Complex Shuffle Logic: Gawanya index zilizopo sasa hivi
        var beginPart = [];
        var middlePart = [];
        var endPart = [];
        var segmentSize = Math.floor(count / 3);

        for (var i = 0; i < count; i++) {
            if (i < segmentSize) beginPart.push(i);
            else if (i < segmentSize * 2) middlePart.push(i);
            else endPart.push(i);
        }

        var shuffleArray = function(arr) {
            for (var j = arr.length - 1; j > 0; j--) {
                var k = Math.floor(Math.random() * (j + 1));
                var temp = arr[j];
                arr[j] = arr[k];
                arr[k] = temp;
            }
        };

        shuffleArray(beginPart);
        shuffleArray(middlePart);
        shuffleArray(endPart);

        // Changanya mpangilio wa makundi
        var segments = [beginPart, middlePart, endPart];
        shuffleArray(segments);

        var finalIndexes = [];
        for (var s = 0; s < segments.length; s++) {
            finalIndexes = finalIndexes.concat(segments[s]);
        }

        // 4. CHAGUA NA ONDOA (Remove Items from iqModel)
        // Tunachukua maswali 26 ya mwanzo kutoka kwenye list iliyovurugwa
        var limit = Math.min(maxQuestions, finalIndexes.length);

        /* Muhimu: Tunapofuta vitu kwenye ListModel, index zinahama.
               Ili kuwa salama, tunakusanya data kwanza, kisha tunafuta
               kwa kutumia kitambulisho cha kipekee au tunafuta kwa kurudi nyuma.
            */

        var tempStorage = [];
        for (var m = 0; m < limit; m++) {
            var targetIdx = finalIndexes[m];
            tempStorage.push(iqModel.get(targetIdx));
        }

        // Sasa hamishia kwenye quizModel na ufute kwenye iqModel
        for (var k = 0; k < tempStorage.length; k++) {
            quizModel.append(tempStorage[k]);

            // Tafuta upya index ya swali hili kwenye iqModel ili kulifuta
            // Hii inahakikisha hata kama index zilihama, tunafuta swali sahihi
            for (var n = 0; n < iqModel.count; n++) {
                const q = iqModel.get(n).q;
                if (q === tempStorage[k].q) {
                    iqModel.remove(n);
                    askedQuestions.add(q);
                    break;
                }
            }
        }

        // 5. Reset Variables
        currentIdx = 0;
        totalScore = 0;
        timerValue = timeInterval;
        noOfPassedQuestion = 0;

        // 6. Anza Mchezo
        viewState = "QUIZ";
        mainTimer.start();
    }


    // Hii ndio model itakayotumika kwenye mchezo (Maswali 26 tu)
    ListModel { id: quizModel }

    // --- LOGIC ---
    Timer {
        id: mainTimer
        interval: 1000; repeat: true
        onTriggered: {
            if (timerValue > 0) timerValue--;
            else processAnswer("");
        }
    }

    function processAnswer(selected) {
        if (selected === quizModel.get(currentIdx).correct) {
            totalScore += (timerValue * 3) + 10;
            ++app.noOfPassedQuestion;
        }
        if (currentIdx < quizModel.count - 1) {
            currentIdx++;
            timerValue = timeInterval;
        } else {
            mainTimer.stop();
            viewState = "END";
            app.ad();
        }
    }

    // --- UI DESIGN ---
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#001a1a" }
            GradientStop { position: 1.0; color: "#050a0c" }
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: 25

        // VIEW START
        ColumnLayout {
            visible: viewState === "START"
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "SAMIA IQ LAB"
                color: "#00ffff"
                font.pixelSize: 32
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Pima uwezo wa akili yako sasa."
                color: "#88ffffff"
                font.pixelSize: 16 * (Qt.platform.os === "android" ? 2.5 : 1)
                Layout.alignment: Qt.AlignHCenter
            }

            Button {
                text: "ANZA JARIBIO"
                Layout.preferredWidth: app.width * 0.8
                Layout.preferredHeight: 55
                onClicked: {
                    startNewGame();
                }
                background: Rectangle {
                    color: "#00ffff"
                    radius: 10
                }
                contentItem: Text {
                    text: parent.text
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                text: "FUNGA"
                Layout.preferredWidth: app.width * 0.8
                Layout.preferredHeight: 50
                Layout.alignment: Qt.AlignHCenter
                background: Rectangle {
                    color: "red"
                    radius: 10
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    app.close();
                }
            }
        }


        // --- QUIZ VIEW ---
        ColumnLayout {
            visible: viewState === "QUIZ" && quizModel.count > 0
            anchors.fill: parent
            spacing: 5

            // Circular Timer Placeholder (Progress Bar)
            Rectangle {
                Layout.fillWidth: true
                height: 10
                radius: 5
                color: "#111"
                Rectangle {
                    width: (timerValue / timeInterval) * parent.width
                    height: parent.height
                    radius: 5
                    color: timerValue < 4 ? "red" : "#00ffff"
                    Behavior on width { NumberAnimation { duration: 500 } }
                }
            }

            Text {
                text: "Swali " + (currentIdx + 1) + " kati ya " + quizModel.count
                color: "#00ffff"
                font.pixelSize: 14 * (Qt.platform.os === "android" ? 3 : 1)
            }

            Text {
                text: (quizModel.count > currentIdx) ? quizModel.get(currentIdx).q : ""
                color: "white"
                font.pixelSize: 24 * (Qt.platform.os === "android" ? 2.2 : 1)
                font.bold: true
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.preferredHeight: 120
            }

            // Options list
            ColumnLayout {
                Layout.fillWidth: true; spacing: 14
                Repeater {
                    model: (quizModel.count > currentIdx) ? shuffleOptions(quizModel.get(currentIdx).a, quizModel.get(currentIdx).b, quizModel.get(currentIdx).c, quizModel.get(currentIdx).d) : []
                    delegate: Button {
                        text: "<font color=\"cyan\"> (" + app.indexToLetter(index) + ")</font> " + app.cleanOption(modelData)
                        Layout.fillWidth: true
                        Layout.preferredHeight: (Qt.platform.os === "android" ? 69 : 60)
                        onClicked: processAnswer(modelData)
                        background: Rectangle {
                            color: parent.pressed ? ((modelData === quizModel.get(currentIdx).correct) ? "green" : "red") : "#121a1d"
                            border.color: "#22ffffff"
                            radius: 12
                        }
                        contentItem: Text {
                            text: parent.text;
                            color: "white"
                            font.pixelSize: 18 * (Qt.platform.os === "android" ? 3 : 1)
                            horizontalAlignment: Text.AlignLeft
                            anchors.leftMargin: 20
                            verticalAlignment: Text.AlignVCenter
                            textFormat: Text.RichText
                        }
                    }
                }
            }

            Button {
                text: "KIMBIA"
                Layout.preferredWidth: app.width * 0.8
                Layout.preferredHeight: 50
                Layout.alignment: Qt.AlignHCenter
                background: Rectangle {
                    color: "red"
                    radius: 10
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    mainTimer.stop();
                    viewState = "END";
                    app.ad();
                }
            }
        }

        // VIEW END
        ColumnLayout {
            visible: viewState === "END"
            anchors.centerIn: parent
            spacing: 18

            Text {
                text: "MATOKEO"
                color: "#88ffffff"
                font.pixelSize: 48 * 2
                font.bold: true
                font.underline: true
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                id: finalScoreDisplay
                // Logic: 70 ndio kianzio.
                // Mtu akipata yote 26, anapata 70 nyingine (Jumla 140).
                // Plus bonus ndogo ya kasi (totalScore / 500)
                property int finalIQ: 70 + Math.round((noOfPassedQuestion / 26) * 70) + Math.min(5, Math.floor(totalScore / 500))
                text: "Alama ya IQ: " + finalIQ
                color: "#00ffff"
                font.pixelSize: 48
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }


            Rectangle {
                Layout.preferredWidth: app.width * 0.92
                Layout.preferredHeight: 70
                Layout.alignment: Qt.AlignHCenter
                color: "#121a1d"
                radius: 10
                border.color: "#3300ffff"
                Text {
                    anchors.centerIn: parent
                    text: getCategory(finalScoreDisplay.finalIQ)
                    color: "white"
                    font.bold: true
                    font.pixelSize: 18 * (Qt.platform.os === "android" ? 2.2 : 1)
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Text {
                text: "Umepata maswali  " + app.noOfPassedQuestion + " kati ya " + app.maxQuestions
                color: "white"
                font.pointSize: 16
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Button {
                text: "JARIBU TENA"
                Layout.preferredWidth: app.width * 0.8
                Layout.preferredHeight: 80
                Layout.alignment: Qt.AlignHCenter
                background: Rectangle {
                    color: "blue"
                    radius: 10
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
font.pointSize: 24
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    app.startNewGame();
                }
            }

/*
            Button {
                text: "SHARE KWA WHATSAPP"
                Layout.preferredWidth: app.width * 0.8
                Layout.preferredHeight: 60
                Layout.alignment: Qt.AlignHCenter

                background: Rectangle {
                    color: "#25D366"
                    radius: 10
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    let msg = "Nimepata IQ ya " + finalScoreDisplay.finalIQ + " (" + getCategory(finalScoreDisplay.finalIQ) + ") kwenye Samia IQ Lab!";
                    Qt.openUrlExternally("whatsapp://send?text=" + encodeURIComponent(msg));
                }
            } */

            // Text { text: "Developer: Edwin Magabe Ngosso"; color: "#44ffffff"; Layout.alignment: Qt.AlignHCenter }

            Button {
                text: "FUNGA"
                Layout.preferredWidth: app.width * 0.8
                Layout.preferredHeight: 60
                Layout.alignment: Qt.AlignHCenter
                background: Rectangle {
                    color: "red"
                    radius: 10
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    app.close();
                }
            }
        }
    }
}
