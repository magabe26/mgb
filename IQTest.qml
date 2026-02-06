import QtQuick 2.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Rectangle {
    id: app
    width: parent.width
    height: parent.height
    visible: true
    color: "#050a0c"

    // --- APP PROPERTIES ---
    property int currentIdx: 0
    property int totalScore: 0
    property int timerValue: 15
    property string viewState: "START"
    property int maxQuestions: 26 // Tunataka maswali 26 tu kila mchezo
    property int noOfPassedQuestion: 0

    // --- IQ CATEGORY LOGIC ---
    function getCategory(iq) {
        if (iq >= 140) return "GENIUS (Gwiji)";
        if (iq >= 120) return "SUPERIOR (Upeo wa Juu)";
        if (iq >= 110) return "ABOVE AVERAGE (Zaidi ya Wastani)";
        if (iq >= 90)  return "AVERAGE (Wastani)";
        return "LOW (Unahitaji Mazoezi)";
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
            // n3ctaApp.showToastMessage("Tafadhali subiri.");
        }else if(typeof loader !== "undefined"){
            loader.onUrlVisited("#showGoogleAd");
            // loader.showToastMessage("Please wait.");
        }
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

    // --- LOGIC YA KUCHANGANYA MASWALI ---
    function startNewGame() {
        // 1. Safisha quizModel ya mchezo uliopita
        quizModel.clear();

        // 2. Angalia kama iqModel ina maswali ya kutosha
        if (iqModel.count === 0) {
            console.log("Benki ya maswali imeisha!");

            // Unaweza kuweka logic ya ku-reload maswali hapa kama ukitaka
            if(typeof n3ctaApp !== "undefined"){
                n3ctaApp.closeCustomPage();
                n3ctaApp.onUrlVisited("#IQTest");
            }else if(typeof loader !== "undefined"){
                loader.closeCustomPage();
                loader.onUrlVisited("#IQTest");
            }
            return;
        }

        // 3. Piga Shuffle kwenye iqModel nzima kwanza (Optional lakini salama zaidi)
        // Au chagua maswali ya mwanzo baada ya kuchanganya index
        var limit = Math.min(maxQuestions, iqModel.count);

        for (var i = 0; i < limit; i++) {
            // Tunachagua swali la random kutoka kwenye iqModel
            var randomIndex = Math.floor(Math.random() * iqModel.count);

            // Tunachukua data ya swali hilo
            var selectedQuestion = iqModel.get(randomIndex);

            // Tunaliweka kwenye model ya mchezo wa sasa
            quizModel.append(selectedQuestion);

            // MUHIMU: Tunafuta swali hili kwenye benki kuu (iqModel)
            // ili lisitokee tena mchezo ujao
            iqModel.remove(randomIndex);
        }

        // 4. Reset Variables za mchezo
        currentIdx = 0;
        totalScore = 0;
        timerValue = 15;
        noOfPassedQuestion = 0;

        // 5. Anza Mchezo
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
            timerValue = 15;
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
            spacing: 25

            // Circular Timer Placeholder (Progress Bar)
            Rectangle {
                Layout.fillWidth: true
                height: 10
                radius: 5
                color: "#111"
                Rectangle {
                    width: (timerValue / 15/*must be equal to initial set timerValue*/) * parent.width
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
                Layout.preferredHeight: 120 * 0.8
            }

            // Options list
            ColumnLayout {
                Layout.fillWidth: true; spacing: 12
                Repeater {
                    model: (quizModel.count > currentIdx) ? shuffleOptions(quizModel.get(currentIdx).a, quizModel.get(currentIdx).b, quizModel.get(currentIdx).c, quizModel.get(currentIdx).d) : []
                    delegate: Button {
                        text: modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
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
                        }
                    }
                }
            }
        }

        // VIEW END
        ColumnLayout {
            visible: viewState === "END"
            anchors.centerIn: parent
            spacing: 15

            Text {
                text: "MATOKEO YA JARIBIO"
                color: "#88ffffff"
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                id: finalScoreDisplay
                // Logic: 70 ndio kianzio.
                // Mtu akipata yote 26, anapata 70 nyingine (Jumla 140).
                // Plus bonus ndogo ya kasi (totalScore / 500)
                property int finalIQ: 70 + Math.round((noOfPassedQuestion / 26) * 70) + Math.min(5, Math.floor(totalScore / 500))
                text: "IQ SCORE: " + finalIQ
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
                    font.pixelSize: 18 * (Qt.platform.os === "android" ? 2 : 1)
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Text {
                text: "Umepata maswali  " + app.noOfPassedQuestion + " kati ya " + app.maxQuestions
                color: "white"
                font.pointSize: 12
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Button {
                text: "SHARE KWA WHATSAPP"
                Layout.preferredWidth: app.width * 0.8
                Layout.preferredHeight: 50
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
            }

            // Text { text: "Developer: Edwin Magabe Ngosso"; color: "#44ffffff"; Layout.alignment: Qt.AlignHCenter }

            Button {
                text: "JARIBU TENA"
                Layout.preferredWidth: app.width * 0.8
                Layout.preferredHeight: 50
                Layout.alignment: Qt.AlignHCenter
                background: Rectangle {
                    color: "blue"
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
                    app.startNewGame();
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
    }
}
