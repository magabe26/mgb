import QtQuick 2.14
import QtQuick.Controls 2.14
import Qt.labs.settings 1.0

Rectangle {
    id: app
    width:  parent ? parent.width  : 360
    height: parent ? parent.height : 720

    // ── App integration ───────────────────────────────────────────────────────
    function cleanParent(t) { return t ? t.replace(/\s*\(.*?\)\s*/g,"").trim() : ""; }
    function isPrimaryResultsApp()   { return (typeof n3ctaApp !== "undefined"); }
    function isSecondaryResultsApp() { return (typeof loader  !== "undefined"); }
    function isInsideApp() {
        var t=cleanParent(String(parent.parent.parent.parent));
        if(isPrimaryResultsApp()) return t==="QQuickRootItem";
        var i=t.indexOf("_"); return i!==-1&&t.substr(0,i)==="SwipeView";
    }
    function isQMLDialogApp() { return cleanParent(String(parent.parent.parent))==="QQuickRectangle"; }
    function closeIfInsideApp() {
        if(!isInsideApp()) return;
        if(isPrimaryResultsApp()){ n3ctaApp.closeCustomPage(); }
        else if(isSecondaryResultsApp()){
            loader.isMenuWindowVisible=true; loader.isMainResultsWindowVisible=true;
            loader.isFooterVisible=true;
            if(typeof loader.mode!=="undefined") loader.mode=2;
            loader.closeCustomPage();
        }
    }
    function closeIfQMLDialogApp() {
        if(!isQMLDialogApp()) return;
        if(isPrimaryResultsApp()){ n3ctaApp.closeQMLDialog(); }
        else if(isSecondaryResultsApp()){ nectaMainResultsPageDownloaderHtmlToXmlConveterAndSaver.closeQMLDialog(); }
    }
    function cmd(url) {
        if(isPrimaryResultsApp()){ n3ctaApp.onUrlVisited(url); }
        else if(isSecondaryResultsApp()){
            if(isQMLDialogApp()){ n3ctaQmlConnectionsPipe.onUrlVisited(url); }
            else if(isInsideApp()){ loader.onUrlVisited(url); }
        }
    }
    function ad() { cmd("#showGoogleAd"); }
    function close() { closeIfInsideApp(); closeIfQMLDialogApp(); ad(); }

    // ── Scale ─────────────────────────────────────────────────────────────────
    property real sw: width
    property real sh: height
    property real sc: sw / 360.0
    function dp(val) { return val * sc; }

    // ── Palette — IQTest deep-space cyan theme ───────────────────────────────
    readonly property color bgDark:    "#020d0d"
    readonly property color bgCard:    "#071e1e"
    readonly property color bgInput:   "#061c1c"
    readonly property color accent:    "#00e5ff"
    readonly property color accentGrn: "#22c55e"
    readonly property color accentYlw: "#00e5ff"
    readonly property color accentRed: "#ef4444"
    readonly property color borderCol: "#0d3a3a"
    readonly property color textMain:  "#ffffff"
    readonly property color textDim:   "#a0d8d8"
    readonly property color hintColor: "#00b8d4"
    // IQTest extra
    readonly property color goldGlow:  "#80f0ff"
    readonly property color goldDim:   "#005f6b"
    readonly property color textSec:   "#a0d8d8"
    color: bgDark

    // ── IQTest background: gradient + cyan grid overlay ───────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#031515" }
            GradientStop { position: 1.0; color: "#020d0d" }
        }
    }
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
    // Top accent bar — horizontal cyan gradient
    Rectangle {
        anchors.top: parent.top
        width: parent.width; height: dp(3); z: 100
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.3; color: "#00e5ff" }
            GradientStop { position: 0.7; color: "#80f0ff" }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // ── Persistent settings ───────────────────────────────────────────────────
    Settings {
        id: gameSettings
        category: "NenoGame"
        property string playedWordsJson: "[]"
    }


    // ── Word banks ────────────────────────────────────────────────────────────
    property var bank4: [
        {w:"BABA",sw:"Mzazi wa kiume",en:"Father"},
        {w:"MAMA",sw:"Mzazi wa kike",en:"Mother"},
        {w:"DADA",sw:"Ndugu wa kike",en:"Sister"},
        {w:"KAKA",sw:"Ndugu wa kiume",en:"Brother"},
        {w:"MAJI",sw:"Kinywaji cha asili, kinapatikana mtoni",en:"Water"},
        {w:"MOTO",sw:"Kinyume cha baridi",en:"Hot / Fire"},
        {w:"PAKA",sw:"Mnyama wa nyumbani anayepiga meow",en:"Cat"},
        {w:"JINO",sw:"Unatumia hiki kuuma chakula",en:"Tooth"},
        {w:"JIWE",sw:"Kitu kigumu kutoka ardhini",en:"Stone"},
        {w:"ROHO",sw:"Nafsi ya mtu isiyoonekana",en:"Soul / Spirit"},
        {w:"MOYO",sw:"Kiungo kinachopiga mapigo mwilini",en:"Heart"},
        {w:"EMBE",sw:"Tunda tamu la manjano au kijani",en:"Mango"},
        {w:"SUMU",sw:"Kitu kinachoweza kuua ukila",en:"Poison"},
        {w:"ZIWA",sw:"Maji mengi yaliyozingirwa na ardhi",en:"Lake"},
        {w:"GOTI",sw:"Kiungo kati ya mguu na paja",en:"Knee"},
        {w:"SOMA",sw:"Kitendo cha kusoma vitabu",en:"To read"},
        {w:"IMBA",sw:"Kutoa sauti za muziki kwa mdomo",en:"To sing"},
        {w:"KULA",sw:"Kutumia chakula mdomoni",en:"To eat"},
        {w:"LALA",sw:"Kupumzika usiku",en:"To sleep"},
        {w:"SEMA",sw:"Kutoa maneno kwa mdomo",en:"To speak"},
        {w:"PATA",sw:"Kupokea au kukuta kitu",en:"To get"},
        {w:"FUPI",sw:"Kinyume cha refu",en:"Short"},
        {w:"REFU",sw:"Kinyume cha fupi",en:"Tall / Long"},
        {w:"SAFI",sw:"Kinyume cha chafu",en:"Clean"},
        {w:"POLE",sw:"Neno la faraja",en:"Sorry / Gentle"},
        {w:"HURU",sw:"Bila minyororo",en:"Free"},
        {w:"GIZA",sw:"Kutokuwa na mwanga",en:"Darkness"},
        {w:"MVUA",sw:"Maji yanayonyesha kutoka angani",en:"Rain"},
        {w:"DAMU",sw:"Kiowevu chekundu mwilini",en:"Blood"},
        {w:"TAMU",sw:"Ladha nzuri ya chakula",en:"Sweet"},
        {w:"DUKA",sw:"Mahali pa kuuzia bidhaa",en:"Shop"},
        {w:"PESA",sw:"Fedha unayotumia kununua",en:"Money"},
        {w:"SIKU",sw:"Muda wa masaa ishirini na nne",en:"Day"},
        {w:"GARI",sw:"Chombo cha usafiri barabarani",en:"Car"},
        {w:"DAWA",sw:"Unakunywa hii ukiwa mgonjwa",en:"Medicine"},
        {w:"AFYA",sw:"Hali nzuri ya mwili na akili",en:"Health"},
        {w:"MENO",sw:"Wingi wa jino",en:"Teeth"},
        {w:"BABU",sw:"Baba wa baba au mama yako",en:"Grandfather"},
        {w:"BIBI",sw:"Mama wa baba au mama yako",en:"Grandmother"},
        {w:"MZEE",sw:"Mtu mwenye umri mkubwa",en:"Elder"},
        {w:"MUME",sw:"Mwanaume katika ndoa",en:"Husband"},
        {w:"KILA",sw:"Kila mmoja bila kubakisha",en:"Every"},
        {w:"MOJA",sw:"Nambari ya kwanza",en:"One"},
        {w:"TATU",sw:"Nambari baada ya mbili",en:"Three"},
        {w:"TANO",sw:"Nambari baada ya nne",en:"Five"},
        {w:"SABA",sw:"Nambari baada ya sita",en:"Seven"},
        {w:"NANE",sw:"Nambari baada ya saba",en:"Eight"},
        {w:"TISA",sw:"Nambari kabla ya kumi",en:"Nine"},
        {w:"KUMI",sw:"Vidole vyote vya mikono miwili",en:"Ten"},
        {w:"JOTO",sw:"Kinyume cha baridi",en:"Heat"},
        {w:"MBWA",sw:"Mnyama wa nyumbani, rafiki wa mtu",en:"Dog"},
        {w:"KUKU",sw:"Ndege wa nyumbani anayetaga mayai",en:"Chicken"},
        {w:"PAPA",sw:"Samaki mkubwa hatari baharini",en:"Shark"},
        {w:"PETE",sw:"Pambo unalovalika kidoleni",en:"Ring"},
        {w:"NGUO",sw:"Mavazi unayovaa mwilini",en:"Clothes"},
        {w:"HAKI",sw:"Kile unachostahili kupewa",en:"Right / Justice"},
        {w:"SALA",sw:"Mazungumzo na Mungu",en:"Prayer"},
        {w:"DINI",sw:"Imani ya Mungu",en:"Religion"},
        {w:"TOBA",sw:"Kuomba msamaha kwa makosa",en:"Repentance"},
        {w:"BORA",sw:"Nzuri zaidi; kinyume cha duni",en:"Best"},
        {w:"SAWA",sw:"Kitu kinachofanana",en:"Equal / Okay"},
        {w:"ZURI",sw:"Chenye kupendeza",en:"Beautiful"},
        {w:"KALI",sw:"Chenye ncha kali",en:"Sharp / Fierce"},
        {w:"GUMU",sw:"Kinyume cha laini",en:"Hard"},
        {w:"PANA",sw:"Kinyume cha nyembamba",en:"Wide"},
        {w:"NENE",sw:"Chenye unene",en:"Fat / Thick"},
        {w:"WAZO",sw:"Kitu kinachokuja akilini",en:"Idea"},
        {w:"SIMU",sw:"Kifaa cha kupigia watu mbali",en:"Phone"},
        {w:"SASA",sw:"Wakati huu huu",en:"Now"},
        {w:"JANA",sw:"Siku iliyopita",en:"Yesterday"},
        {w:"HEWA",sw:"Unaipumua kila wakati lakini hauwezi kuiona",en:"Air"},
        {w:"PIGO",sw:"Moyo wako unafanya hiki kila sekunde bila kukoma",en:"Beat/Strike"},
        {w:"HOFU",sw:"Hisia inayokufanya ukimbie bila kuulizwa",en:"Fear"},
        {w:"WIVU",sw:"Unatesa mtu kwa sababu ya mafanikio ya mwingine",en:"Jealousy"},
        {w:"BURE",sw:"Hakuna bei lakini wakati mwingine haina maana",en:"Free/Worthless"},
        {w:"HAMU",sw:"Nguvu ya ndani inayokuvuta kuelekea kitu",en:"Eagerness/Longing"},
        {w:"NDOA",sw:"Mkataba mmoja lakini watu wawili wanausaini",en:"Marriage"},
        {w:"AIBU",sw:"Uso unabadilika rangi bila hiari yako",en:"Shame"},
        {w:"NURU",sw:"Giza linakimbia punde tu unapofika",en:"Light"},
        {w:"SIRI",sw:"Ukijua wewe peke yako — usimwambie hata rafiki yako wa karibu",en:"Secret"},
        {w:"KERO",sw:"Inakusumbua akilini hata unapolala",en:"Worry/Grievance"},
        {w:"INDA",sw:"Chuki iliyofichwa moyoni — inakula polepole",en:"Hidden grudge"},
        {w:"TELE",sw:"Nyingi sana hadi haziwezi kuhesabiwa",en:"Plenty/Abundant"},
        {w:"KOSA",sw:"Unafanya bila kukusudia lakini inaumiza wengine",en:"Mistake"},
        {w:"HAJA",sw:"Bila hiki maisha yanakuwa magumu sana",en:"Need/Necessity"},
        {w:"KAZI",sw:"Unafanya hii kupata chakula na kujikimu",en:"Work/Job"},
        {w:"BOVU",sw:"Kilikuwa kizuri lakini sasa hakifai tena",en:"Rotten/Spoiled"},
        {w:"OMBI",sw:"Unasujudu au unapiga magoti ukitoa hili",en:"Prayer/Request"},
        {w:"RIBA",sw:"Unalipa ziada ya ulichokopa — benki inafurahi",en:"Interest"},
        {w:"ADHA",sw:"Maumivu makubwa yanayodumu muda mrefu",en:"Suffering/Torment"},
        {w:"BAKI",sw:"Kilichobaki baada ya kila kitu kingine kutumika",en:"Remainder"},
        {w:"JADI",sw:"Mila inayopita kizazi hadi kizazi bila ya kuandikwa",en:"Tradition/Heritage"},
        {w:"USIA",sw:"Maneno ya mtu anayefariki — ni muhimu kusikia",en:"Last will"},
        {w:"ZAKA",sw:"Unailipa kama ibada si kama ushuru",en:"Zakat/Tithe"},
        {w:"YOWE",sw:"Sauti ya maumivu au mshangao inayotoka bila kukusudia",en:"Cry/Shriek"},
        {w:"POVU",sw:"Inajaa na kutoweka haraka kama maisha ya starehe",en:"Foam/Froth"},
        {w:"TAWI",sw:"Inategemea shina lakini inaweza kukua peke yake",en:"Branch"},
        {w:"JIVU",sw:"Kilichobaki baada ya kitu kuchomwa kabisa",en:"Ash"},
        {w:"NAZI",sw:"Gumu nje lakini tamu na yenye maji ndani",en:"Coconut"},
        {w:"LOZI",sw:"Ndogo lakini thamani yake ni kubwa sana",en:"Almond"},
        {w:"KETE",sw:"Pambo la sikioni — damu ikitoka ulijua ni kubwa",en:"Earring"},
        {w:"NGAO",sw:"Inakuzuia risasi au mshtuko lakini haikushambulia",en:"Shield"},
        {w:"ZIZI",sw:"Nyumba ya wanyama — wao hawalali hotelini",en:"Animal pen"},
        {w:"FUKO",sw:"Anachimba ardhi kutafuta chakula — haoni vizuri mchana",en:"Mole"},
        {w:"TOTO",sw:"Mdogo kabisa — bado hajui lolote kuhusu dunia",en:"Baby/Infant"},
        {w:"KOPO",sw:"Chombo cha chuma kilichofungwa — unakishangilia ukifungua",en:"Tin can"},
        {w:"JIPU",sw:"Uvimbe wenye siri ndani unauma ukiguswa kidogo tu",en:"Abscess/Boil"},
        {w:"BOGA",sw:"Mboga ya mviringo unayokata haikuumia wala kulia",en:"Pumpkin/Gourd"},
        {w:"PORI",sw:"Mahali binadamu hawaiishi wanyama wanamiliki kila kitu",en:"Wilderness"},
        {w:"TUTA",sw:"Kilima kidogo cha ardhi si mlima wala bonde kabisa",en:"Mound"},
        {w:"MELE",sw:"Kelele nyingi amani inakimbia bila kuagana",en:"Noise/Uproar"},
        {w:"GOGO",sw:"Shina la mti lililowekwa chini bado lina nguvu ndani",en:"Log/Trunk"},
        {w:"LELE",sw:"Wimbo wa kulaza mtoto upole wake ni wa kipekee duniani",en:"Lullaby"},
        {w:"BUSU",sw:"Onyesho la upendo kwa midomo hakuna bei yake",en:"Kiss"},
        {w:"KIMO",sw:"Urefu wa mtu au kitu kipimo cha wima tu",en:"Height/Stature"},
        {w:"DOLI",sw:"Mfano wa binadamu wa kucheza nawo watoto wanaipenda",en:"Doll"},
        {w:"KOFI",sw:"Mkono wazi ukigonga kwa nguvu sauti yake inasikika mbali",en:"Slap/Clap"},
        {w:"BWIA",sw:"Kukaa bila kufanya kazi wakati unaendelea kupita bila kujali",en:"Idling"},
        {w:"SHAO",sw:"Nusu au upande mmoja wa kitu hukamilishi peke yake",en:"Half/One side"},
        {w:"NUKA",sw:"Kutoa harufu mbaya au kuchukiza — pua inafungika haraka",en:"To smell bad/stink"},
        {w:"KADI",sw:"Karatasi ndogo ya utambulisho au ya mchezo wa kawaida",en:"Card/ID card"},
        {w:"GOLI",sw:"Mpira unaoingia nyavuni — furaha ya wachezaji wote pamoja",en:"Goal in sports"},
        {w:"HEPA",sw:"Kukimbia hatari haraka akili inafanya kazi kuliko miguu yako",en:"To escape/dodge"},
        {w:"INUA",sw:"Kuinua kitu juu kwa nguvu au kuinua hali ya mtu dhaifu",en:"To lift up"},
        {w:"AMKA",sw:"Kuacha usingizi macho yanafunguka duniani tena kila asubuhi yake",en:"To wake up"},
        {w:"LIPA",sw:"Kutoa pesa kwa bidhaa uliyonunua deni linakwisha baada ya kulipa",en:"To pay"}
        ,
        {w:"NCHA",sw:"Mwisho wa kitu — au mwanzo wa hatari inayokaribia",en:"Tip/Edge/Point"},
        {w:"RAHA",sw:"Hali ya furaha na utulivu — wengi wanaitafuta maisha yote",en:"Peace/Comfort"},
        {w:"BUDI",sw:"Huna budi — haina maana ya chaguo hapa kabisa",en:"No choice/Must"},
        {w:"NDIO",sw:"Neno moja linaweza kufungua mlango au kufunga kabisa",en:"Yes"},
        {w:"KOBE",sw:"Polepole ni mbio zake — lakini anafika mwishowe",en:"Tortoise"},
        {w:"FUPA",sw:"Muundo wa ndani wa mwili unaobeba uzito wote",en:"Bone"},
        {w:"JIBU",sw:"Swali linasubiri hili — wakati mwingine halikuja",en:"Answer"},
        {w:"NENO",sw:"Kipande kimoja cha lugha — hata moja linaweza kuumiza",en:"Word"},
        {w:"RUDI",sw:"Kurudi mahali ulikokuwa — safari imekwisha vizuri",en:"To return"},
        {w:"OMBA",sw:"Unasujudu ukitoa hili — au unaomba serikali msaada",en:"To pray/request"},
        {w:"BEGA",sw:"Unabeba mizigo hapa — na wasiwasi wa maisha pia",en:"Shoulder"},
        {w:"FOMU",sw:"Karatasi ya kujaza taarifa zako rasmi kabla ya kupata kitu",en:"Form/Application"},
        {w:"JELA",sw:"Mahali ambapo uhuru ni ndoto tu kwa wanaokaa ndani",en:"Prison/Jail"},
        {w:"BEBA",sw:"Kubeba mzigo — mgongoni au moyoni — wote una mzigo wake",en:"To carry/bear"},
        {w:"KATA",sw:"Kugawanya kitu kwa kisu — au kuacha kabisa jambo fulani",en:"To cut/quit"},
        {w:"LIMA",sw:"Kufanya kazi shambani — chakula kinatoka hapa peke yake",en:"To farm/cultivate"},
        {w:"VUKA",sw:"Kupita upande wa pili — wa mto au barabara ndefu",en:"To cross/traverse"},
        {w:"AMUA",sw:"Kufanya uamuzi mgumu — wakati mwingine huna muda mrefu",en:"To decide"},
        {w:"GUSA",sw:"Kugusa kwa kidole — kinachoweza kubadilisha kila kitu",en:"To touch"},
        {w:"HISI",sw:"Kutambua kitu kwa hisia — bila kuona au kusikia",en:"To feel/sense"},
        {w:"KANA",sw:"Kukana ukweli — wakati mwingine ni uoga wa kukubali",en:"To deny/negate"},
        {w:"LEWA",sw:"Kupoteza akili — si lazima kwa pombe tu maishani",en:"To get drunk/intoxicated"},
        {w:"ENDA",sw:"Kwenda — lakini safari yenyewe ndiyo thamani ya kweli",en:"To go"},
        {w:"KUJA",sw:"Kuja — kuwasili mahali fulani — mwisho wa safari ndefu",en:"To come/arrive"},
        {w:"WEKA",sw:"Kuweka mahali — lakini sehemu unayoiweka ni muhimu sana",en:"To put/place/keep"},
        {w:"TUPA",sw:"Unatoa mbali — lakini baadhi ya vitu vinarudi kwako",en:"To throw/discard"},
        {w:"UMIA",sw:"Kupata maumivu — ya mwili au ya moyoni inaumiza zaidi",en:"To get hurt/suffer"},
        {w:"PIGA",sw:"Moyo wako unafanya hiki kila sekunde bila malipo yoyote",en:"To beat/hit"},
        {w:"MCHE",sw:"Mche mdogo wa mmea — unaanza kukua hatua moja kwa moja",en:"Seedling/Sprout"}
        ,
        {w:"FIGO",sw:"Viungo viwili vya ndani vinavyosafisha damu yako",en:"Kidneys"},
        {w:"VITU",sw:"Wingi wa kitu — vitu vingi vya aina mbalimbali",en:"Things/Objects"},
        {w:"WEMA",sw:"Tabia ya kufanya mema — bila kuomba malipo yoyote",en:"Goodness/Virtue/Kindness"},
        {w:"YOTE",sw:"Jumla ya vitu vyote — bila kubakisha hata kimoja",en:"All/Everything"},
        {w:"ZANA",sw:"Vyombo vya kufanyia kazi — bila yake kazi ni ngumu",en:"Tools/Equipment/Instruments"},
        {w:"MALI",sw:"Vitu vya thamani au utajiri wa aina yoyote maishani",en:"Property/Wealth/Assets"},
        {w:"CHAI",sw:"Kinywaji cha joto cha majani — unakusaidia kuamka asubuhi",en:""},
        {w:"ASHA",sw:"Chakula cha usiku — mlo wa mwisho wa siku yako",en:"Dinner/Evening meal"}
        ,
        {w:"FISI",sw:"Kicheko chake kitisha usiku — anakula hata mifupa yote",en:"Hyena"},
        {w:"KIMA",sw:"Nyani mdogo mwenye mkia mrefu — anapenda ndizi zaidi",en:"Vervet monkey"},
        {w:"BATA",sw:"Ndege anayeogelea — anapiga quack ana miguu ya wavu",en:"Duck"},
        {w:"KASA",sw:"Mnyama wa baharini mwenye gamba gumu — polepole ni nguvu",en:"Sea turtle"},
        {w:"POPO",sw:"Anaruka usiku — analala kichwa chini mchana tena",en:"Bat"},
        {w:"FARU",sw:"Mnyama mzito wa pembe — hatarini kutoweka duniani mwetu",en:"Rhinoceros"}
        ,
        {w:"TASA",sw:"Chombo cha gorofa cha kupimia au kukusanyia",en:"Flat basin/Tray"},
        {w:"LESO",sw:"Kitambaa kidogo cha kujifunika kichwa au uso",en:"Head scarf/Kerchief"},
        {w:"KABA",sw:"Nguo ndefu ya wanawake inayofunika kila kitu",en:"Long dress/Abaya"},
        {w:"TAWA",sw:"Chombo cha kupikia chapati au mkate wa kawaida",en:"Griddle/Flat pan"},
        {w:"DUMU",sw:"Chombo cha kuhifadhi maji — la chuma au plastiki",en:"Water container/Drum"},
        {w:"PIPA",sw:"Chombo kikubwa cha kuhifadhi maji au mafuta",en:"Barrel/Large drum"},
        {w:"NDOO",sw:"Chombo cha kubeba maji — unabeba kwa mkono",en:"Bucket/Pail"},
        {w:"KISU",sw:"Kina makali — unakata nacho bila kuulizwa sababu",en:"Knife"},
        {w:"RADI",sw:"Sauti kubwa angani wakati wa mvua — inatisha sana",en:"Thunder"},
        {w:"TOPE",sw:"Ardhi na maji vikichanganyika — miguu inashikwa",en:"Mud"},
        {w:"GOME",sw:"Nguo ya nje ya mti — inailinda ndani yake yote",en:"Tree bark"},
        {w:"JANI",sw:"Kinachomea kwenye tawi — kinaanguka wakati wa baridi",en:"Leaf"},
        {w:"PERA",sw:"Tamu kidogo na chungu kidogo — rangi yake ya kijani",en:"Guava"},
        {w:"KIFO",sw:"Mwisho wa maisha ya kimwili — unakuja bila ruhusa",en:"Death"},
        {w:"ANGA",sw:"Upande wa juu wa dunia — nyota zinaishi hapa",en:"Sky/Atmosphere"},
        {w:"FICA",sw:"Kufika — kuwasili mahali ulipokusudia baada ya safari",en:"To arrive"}
        ,
        {w:"TABU",sw:"Hali ngumu inayokusumbua — lakini inakufundisha pia",en:""},
        {w:"FIWA",sw:"Kupoteza mtu wa kupendwa bila kuwa tayari kabisa",en:"Bereaved"},
        {w:"MFUO",sw:"Mkondo mdogo wa maji — wa asili unaotiririka mlimani",en:"Stream/Brook"},
        {w:"BOMA",sw:"Uzio wa miti au mwanzi — unalinda nyumba na wanyama",en:"Enclosure/Homestead"},
        {w:"DARI",sw:"Sakafu ya juu ya jengo — au balcony ya kuangalia nje",en:"Upper floor/Balcony"},
        {w:"CHOO",sw:"Mahali pa kujisaidia — muhimu sana kwa afya ya wote",en:"Toilet/Latrine"},
        {w:"WALI",sw:"Chakula cha mchele kilichopikwa — kikuu Tanzania",en:""},
        {w:"SUPU",sw:"Chakula cha majimaji cha moto — kinakupoza baridi",en:"Soup/Broth"},
        {w:"DENI",sw:"Pesa uliyokopa — lazima uirudishe au wasiwasi unakuwa",en:"Debt"},
        {w:"KODI",sw:"Pesa unayolipa kwa serikali au mmiliki wa nyumba",en:"Tax/Rent"},
        {w:"NOTI",sw:"Karatasi ya pesa — au maelezo mafupi ya muhimu sana",en:"Banknote/Note"},
        {w:"BASI",sw:"Sawa — inatosha — au gari kubwa la abiria ya kawaida",en:"Enough/Bus"},
        {w:"HATA",sw:"Hata hivyo — hata yeye — hata mimi — ni neno linaloongeza",en:"Even/Despite"},
        {w:"BILA",sw:"Kukosa kitu — bila pesa bila furaha bila tumaini lolote",en:"Without"},
        {w:"KAMA",sw:"Kufanana na kitu au hali — au sharti la masharti yote",en:"Like/If/As"},
        {w:"BADO",sw:"Bado haijafika — bado inaendelea — wakati haujafika",en:"Still/Not yet"},
        {w:"SANA",sw:"Kwa kiasi kikubwa sana — inaongeza nguvu ya neno",en:"Very/Extremely"},
        {w:"NINI",sw:"Swali linaloitaka kitu — jibu lake linaweza kubadilisha kila kitu",en:"What"},
        {w:"WAPI",sw:"Swali la mahali — jibu lake ni mwelekeo wa safari",en:"Where"},
        {w:"LINI",sw:"Swali la wakati — jibu lake linaweza kusaidia kupanga",en:"When"},
        {w:"NANI",sw:"Swali la mtu — jibu lake linaweza kufungua au kufunga njia",en:"Who"}
        ,
        {w:"TADU",sw:"Mdudu mrefu wa kuamsha hofu — anakwea kwa haraka sana",en:"Centipede/Millipede"},
        {w:"UMRI",sw:"Idadi ya miaka ya maisha yako — inavyoongezeka kila siku",en:"Age"},
        {w:"RUKA",sw:"Kuruka juu — au kupita hatua fulani haraka bila kusimama",en:"To jump/skip"},
        {w:"ANZA",sw:"Kuanza kitu kipya — hatua ya kwanza ndiyo ngumu zaidi",en:"To begin/start"},
        {w:"TENA",sw:"Mara nyingine — kurudia kitu kilichofanyika kabla yake",en:"Again/Once more"},
        {w:"NAAM",sw:"Ndiyo kwa lugha ya Kiarabu — pia inatumika Kiswahili",en:"Yes/Indeed"}
        ,
        {w:"MBIO",sw:"Mwendo wa haraka wa miguu — au mapigo ya moyo wa haraka",en:"Running/Speed"},
        {w:"ZIDI",sw:"Kuwa zaidi ya kiasi — kupita mipaka iliyowekwa kabla",en:"To exceed"},
        {w:"NCHI",sw:"Eneo la ardhi lenye mipaka — linalotawaliwa na serikali",en:"Country"},
        {w:"MIJI",sw:"Wingi wa mji — miji ya Tanzania ni mingi na maarufu",en:"Cities/Towns"},
        {w:"TATA",sw:"Suala gumu la kushangaza akili — halijiwezi kirahisi",en:"Complicated/Tangled"},
        {w:"KURA",sw:"Unaweza kuibadilisha historia ya nchi — kwa karatasi moja",en:"Vote"},
        {w:"AMRI",sw:"Agizo kutoka kwa mwenye mamlaka — lazima litekelezwe",en:"Order/Command"},
        {w:"RAIS",sw:"Kiongozi mkuu wa nchi — anachaguliwa na wananchi wake",en:"President"},
        {w:"MEYA",sw:"Kiongozi wa mji — anasimamia mambo ya mji wake mzima",en:"Mayor"},
        {w:"JAJI",sw:"Mtu anayeamua hukumu — ana nguvu ya mwisho mahakamani",en:"Judge"},
        {w:"KESI",sw:"Jambo linalosikilizwa mahakamani — mara nyingi ni ndefu",en:"Legal case"},
        {w:"PIMA",sw:"Kupima uzito au urefu au kiasi cha kitu fulani",en:"To measure"},
        {w:"OSHA",sw:"Kunawa au kuosha kitu kwa maji na sabuni — usafi kwanza",en:"To wash"},
        {w:"WAZA",sw:"Kufikiri kwa undani — kuzalisha mawazo mapya ya ajabu",en:"To think"}
    ]

    property var bank5: [
        {w:"AMANI",sw:"Hali ya utulivu bila vita",en:"Peace"},
        {w:"ARDHI",sw:"Udongo tunaoishi juu yake",en:"Land / Soil"},
        {w:"ASALI",sw:"Kinywaji kitamu cha nyuki",en:"Honey"},
        {w:"BARUA",sw:"Ujumbe ulioandikwa kwenye karatasi",en:"Letter / Mail"},
        {w:"BONDE",sw:"Eneo la chini kati ya milima",en:"Valley"},
        {w:"CHAMA",sw:"Kundi la watu wenye lengo moja",en:"Party / Group"},
        {w:"CHINI",sw:"Kinyume cha juu",en:"Below / Down"},
        {w:"CHUMA",sw:"Madini ya nguvu",en:"Iron / Metal"},
        {w:"DAIMA",sw:"Wakati wote bila kusimama",en:"Always"},
        {w:"DUNIA",sw:"Sayari tunayoishi",en:"World"},
        {w:"ELIMU",sw:"Maarifa unayopata shuleni",en:"Education"},
        {w:"FAIDA",sw:"Kile unachopata zaidi ya gharama",en:"Benefit / Profit"},
        {w:"FEDHA",sw:"Pesa au madini ya fedha",en:"Money / Silver"},
        {w:"FURSA",sw:"Wakati mzuri wa kufanya kitu",en:"Opportunity"},
        {w:"GHALI",sw:"Bei kubwa; kinyume cha rahisi",en:"Expensive"},
        {w:"IMANI",sw:"Kuamini kwa nguvu",en:"Faith / Belief"},
        {w:"JAMBO",sw:"Salamu ya Kiswahili",en:"Greetings"},
        {w:"JICHO",sw:"Kiungo cha kuona",en:"Eye"},
        {w:"KANGA",sw:"Kitambaa cha rangi cha mwanamke",en:"Kanga cloth"},
        {w:"KARNE",sw:"Miaka mia moja",en:"Century"},
        {w:"KASHA",sw:"Sanduku au kisanduku",en:"Box / Chest"},
        {w:"KESHO",sw:"Siku inayokuja baada ya leo",en:"Tomorrow"},
        {w:"KIATU",sw:"Unachovalika mguuni",en:"Shoe"},
        {w:"KIAZI",sw:"Mboga ya ardhini",en:"Potato"},
        {w:"KIFAA",sw:"Chombo cha kufanyia kazi",en:"Tool"},
        {w:"KIKAO",sw:"Mkutano rasmi",en:"Meeting"},
        {w:"KIMYA",sw:"Kutokuwa na sauti",en:"Silence"},
        {w:"KITUO",sw:"Mahali pa kati; stesheni",en:"Station / Centre"},
        {w:"KOFIA",sw:"Unachovalika kichwani",en:"Hat / Cap"},
        {w:"KWELI",sw:"Kinyume cha uongo",en:"Truth"},
        {w:"LAANA",sw:"Maneno mabaya ya kudhuru mtu",en:"Curse"},
        {w:"LANGO",sw:"Mlango mkubwa wa kuingia",en:"Gate"},
        {w:"LUGHA",sw:"Njia ya mawasiliano kwa maneno",en:"Language"},
        {w:"MACHO",sw:"Wingi wa jicho",en:"Eyes"},
        {w:"MANGA",sw:"Kiungo cha kupikia chenye harufu kali",en:"Ginger"},
        {w:"MBALI",sw:"Umbali mkubwa; si karibu",en:"Far away"},
        {w:"MBEGU",sw:"Kile unachopanda ardhini kukua mmea",en:"Seed"},
        {w:"MGENI",sw:"Mtu anayekuja kutembelea",en:"Guest / Stranger"},
        {w:"MKONO",sw:"Sehemu ya mwili kutoka bega hadi vidole",en:"Hand / Arm"},
        {w:"MSITU",sw:"Eneo kubwa la miti mingi",en:"Forest"},
        {w:"MTOTO",sw:"Binadamu mdogo",en:"Child"},
        {w:"MUNGU",sw:"Muumba wa ulimwengu",en:"God"},
        {w:"NAFSI",sw:"Roho au utu wa mtu",en:"Soul / Self"},
        {w:"NDEGE",sw:"Kiumbe chenye mabawa",en:"Bird / Airplane"},
        {w:"NDOTO",sw:"Mawazo yanayokuja usingizini",en:"Dream"},
        {w:"NGOMA",sw:"Chombo cha muziki kinachopigwa",en:"Drum"},
        {w:"NGUVU",sw:"Uwezo wa kimwili",en:"Strength"},
        {w:"NYOTA",sw:"Mwanga mdogo unaong'aa usiku",en:"Star"},
        {w:"PANGO",sw:"Tundu kubwa kwenye mwamba",en:"Cave"},
        {w:"PENDO",sw:"Hisia ya upendo",en:"Love / Affection"},
        {w:"PICHA",sw:"Mfano wa kitu uliochorwa",en:"Photo / Picture"},
        {w:"PUMZI",sw:"Hewa unayovuta puani",en:"Breath"},
        {w:"RANGI",sw:"Kama nyekundu, bluu, au kijani",en:"Colour"},
        {w:"SHULE",sw:"Mahali pa kujifunza",en:"School"},
        {w:"SIASA",sw:"Mambo ya utawala wa nchi",en:"Politics"},
        {w:"SIMBA",sw:"Mnyama mkubwa, mfalme wa wanyama",en:"Lion"},
        {w:"TAABU",sw:"Hali ngumu au tatizo",en:"Trouble"},
        {w:"TABIA",sw:"Jinsi mtu anavyoishi na kutenda",en:"Character"},
        {w:"TAIFA",sw:"Nchi na watu wake",en:"Nation"},
        {w:"TUNDA",sw:"Mazao ya mmea yanayoliwa",en:"Fruit"},
        {w:"UKUTA",sw:"Kizuizi cha matofali",en:"Wall"},
        {w:"UMOJA",sw:"Hali ya kuwa pamoja kwa nia moja",en:"Unity"},
        {w:"UZURI",sw:"Hali ya kupendeza",en:"Beauty"},
        {w:"VUMBI",sw:"Chembe ndogo za ardhi zinazopeperuka",en:"Dust"},
        {w:"WINGU",sw:"Mawingu yanayotanda angani",en:"Cloud"},
        {w:"WIMBO",sw:"Nyimbo za muziki",en:"Song"},
        {w:"AKILI",sw:"Uwezo wa kufikiria",en:"Intelligence"},
        {w:"BINTI",sw:"Mtoto wa kike",en:"Daughter"},
        {w:"JIONI",sw:"Wakati wa jua kutua",en:"Evening"},
        {w:"LENGO",sw:"Kusudi au shabaha",en:"Goal"},
        {w:"MBAYA",sw:"Kinyume cha nzuri",en:"Bad"},
        {w:"MBELE",sw:"Upande wa mbele",en:"In front"},
        {w:"MLIMA",sw:"Kilima kikubwa cha ardhi",en:"Mountain"},
        {w:"MZAZI",sw:"Baba au mama",en:"Parent"},
        {w:"NDANI",sw:"Kinyume cha nje",en:"Inside"},
        {w:"SHIDA",sw:"Tatizo au ugumu",en:"Problem"},
        {w:"TEMBO",sw:"Mnyama mkubwa mwenye mkonga",en:"Elephant"},
        {w:"USIKU",sw:"Wakati wa giza",en:"Night"},
        {w:"UHURU",sw:"Hali ya kuwa huru",en:"Freedom"},
        {w:"NYOKA",sw:"Mnyama mrefu asiye na miguu",en:"Snake"},
        {w:"NYUMA",sw:"Kinyume cha mbele",en:"Behind"},
        {w:"MWILI",sw:"Nyumba ya roho yako — utaicha siku moja",en:"Body"},
        {w:"UPOLE",sw:"Nguvu ya aina nyingine — watu wenye nguvu wanaweza",en:"Gentleness"},
        {w:"MBINU",sw:"Njia ya siri ya kufanikisha lengo bila kupigana",en:"Tactic/Strategy"},
        {w:"UJUZI",sw:"Uliujenga kwa miaka na makosa mengi si siku moja",en:"Skill/Knowledge"},
        {w:"BONGO",sw:"Kiongozi wa mwili wote — hata wakati unaolala kinafanya kazi",en:"Brain"},
        {w:"KISIO",sw:"Unafikiri jibu kabla ya kuthibitisha — wakati mwingine unakosea",en:"Guess/Hunch"},
        {w:"KINGA",sw:"Inakuzuia maradhi — ngao ya ndani ya mwili wako",en:"Protection/Immunity"},
        {w:"MAWIO",sw:"Wakati jua linapoanza safari yake asubuhi",en:"Sunrise/Dawn"},
        {w:"FUNZO",sw:"Kinabaki nawe maisha yote — hata ukisahau mwalimu",en:"Lesson/Teaching"},
        {w:"NGOZI",sw:"Nguo yako ya asili — hata ukifua haifiki",en:"Skin"},
        {w:"AJALI",sw:"Hakuna anayepanga — lakini inaweza kubadilisha maisha yote",en:"Accident"},
        {w:"ADABU",sw:"Haitoi pesa lakini inafungua milango mingi",en:"Good manners/Etiquette"},
        {w:"FICHA",sw:"Kila mtu ana kitu anachofanya hiki moyoni mwake",en:"To hide/conceal"},
        {w:"IMARA",sw:"Hata dhoruba kali haiwezi kukiangusha",en:"Strong/Firm/Stable"},
        {w:"PEKEE",sw:"Hakuna mwingine kama wewe ulimwenguni",en:"Unique/Alone/Only"},
        {w:"ARUSI",sw:"Siku moja tu lakini kumbukumbu inadumu maisha yote",en:"Wedding ceremony"},
        {w:"BIDII",sw:"Unaiweka hata ukijua matokeo hayatakuwa ya haraka",en:"Effort/Diligence"},
        {w:"TAMAA",sw:"Inakuvuta mbele lakini wakati mwingine inakuangamiza",en:"Desire/Greed"},
        {w:"FAHMU",sw:"Kuelewa kwa undani si kujua tu bali kushika maana yake",en:"Understanding"},
        {w:"GANZI",sw:"Hali ya mwili kutohisi moyo pia unaweza kupata hali hii",en:"Numbness"},
        {w:"HAIBA",sw:"Mvuto wa kipekee unaoanza ukimwona tu bila maneno yoyote",en:"Charm/Charisma"},
        {w:"HEKMA",sw:"Busara ya hali ya juu ni kipawa cha nadra sana duniani",en:"Wisdom"},
        {w:"HONGO",sw:"Unatoa pesa kwa siri ili kitu kisiende sawa kwa wote",en:"Bribe"},
        {w:"JINSI",sw:"Namna au njia ya kufanya kitu kila mtu ana yake mwenyewe",en:"Manner/Way"},
        {w:"RUNDO",sw:"Vitu vingi vilivyokusanywa kila kimoja kina historia yake",en:"Heap/Pile"},
        {w:"CHORA",sw:"Kutoa mchoro kwa kalamu au penseli kabla ya rangi",en:"To draw/sketch"},
        {w:"ANGUA",sw:"Kuangusha kitu chini bila kukusudia wala kupanga",en:"To knock down/topple"},
        {w:"FUATA",sw:"Kufuata mtu au njia — mara nyingi bila kuulizwa",en:"To follow"},
        {w:"GEUKA",sw:"Kubadilisha mwelekeo ghafla — mara nyingi kwa mshangao",en:"To turn/change direction"},
        {w:"CHOKA",sw:"Kupata uchovu baada ya kutoa nguvu zako zote",en:"To get tired/exhausted"},
        {w:"FANYA",sw:"Kutenda kitendo — kufanya kitu kizuri au kibaya",en:"To do/make/act"},
        {w:"GONGA",sw:"Kugonga mlango kabla ya kuingia — adabu inasema hivyo",en:"To knock/hit"},
        {w:"OGOPA",sw:"Kuogopa kitu au mtu hata ukijua labda hakupo kweli kweli",en:"To fear"},
        {w:"PAMBA",sw:"Mmea mweupe laini unaotumika kutengeneza nguo na vitanda",en:"Cotton"},
        {w:"UPONA",sw:"Kupona ugonjwa na kurudi nguvu — mwili unashukuri baada ya taabu",en:"Recovery/Healing"},
        {w:"VUMIA",sw:"Kuvumilia maumivu au hali ngumu bila kulalamika kamwe",en:"To endure/bear pain"},
        {w:"PAKUA",sw:"Kupakua mzigo kutoka gari — au kupakua faili kwenye simu yako",en:"To unload/download"}
        ,
        {w:"SOGEA",sw:"Kusogea karibu — hatua moja inatosha wakati mwingine",en:"To move closer/approach"},
        {w:"SHUKA",sw:"Kushuka chini — kutoka juu kwa hatua au kwa haraka",en:"To descend/alight"},
        {w:"UMEME",sw:"Inafikia kabla ya sauti — kasi yake ni ya ajabu sana",en:"Lightning/Electricity"},
        {w:"PWANI",sw:"Ardhi na maji vinakutana hapa — mgawanyo ni mstari tu",en:"Coast/Shore/Beach"},
        {w:"JESHI",sw:"Wanajeshi wa nchi — wanakilinda kutoka kwa maadui wote",en:"Army/Military"},
        {w:"ULAYA",sw:"Bara la kaskazini magharibi — la baridi na theluji nyingi",en:"Europe"},
        {w:"PEMBA",sw:"Kisiwa cha Tanzania — au kona ya ukuta wa nyumba",en:"Pemba island/Corner"},
        {w:"SHABA",sw:"Madini ya rangi ya kahawia — ya zamani na ya thamani",en:"Copper/Bronze"},
        {w:"DHANA",sw:"Wazo au taswira akilini — kabla haijawa kweli halisi",en:"Concept/Notion/Idea"},
        {w:"MAONI",sw:"Mawazo ya mtu — yanaweza kubadilisha ulimwengu mzima",en:"Opinions/Views"},
        {w:"LABDA",sw:"Pengine ndiyo pengine hapana — usiwe na uhakika kamwe",en:"Maybe/Perhaps"},
        {w:"LAINI",sw:"Kinyume cha gumu — kupendeza kugusa na kuona sana",en:"Soft/Gentle/Smooth"},
        {w:"SIKIO",sw:"Kiungo cha kusikia — kinasikia hata unapolala fofofo",en:"Ear"},
        {w:"ULIMI",sw:"Kiungo cha ladha mdomoni — kinaongea lugha nyingi",en:"Tongue"},
        {w:"TUMBO",sw:"Sehemu ya mwili inayoshikilia chakula — inalalamika ukikaa njaa",en:"Stomach"},
        {w:"BWANA",sw:"Cheo cha heshima — au mume wa mke wake wa ndoa",en:"Mister/Husband"},
        {w:"TANGU",sw:"Kuanzia wakati fulani hadi sasa — historia ndefu ya mambo",en:"Since/From"},
        {w:"FUNGA",sw:"Kufunga mlango — au kumaliza mchezo — au kufunga safari",en:"To close/lock/fast"},
        {w:"PANDA",sw:"Kupanda juu ya mti au mlima — hatua moja kwa moja mbele",en:"To climb/go up"},
        {w:"VUNJA",sw:"Kuvunja kitu — ni rahisi zaidi kuliko kujenga upya",en:"To break/destroy"},
        {w:"CHUKI",sw:"Mzigo mzito unaobebwa moyoni bila faida yoyote kamwe",en:"Hatred/Hostility"}
        ,
        {w:"UPEPO",sw:"Haionekani lakini unajua ipo unapoona mti ukipinda nguvu",en:"Wind"},
        {w:"NDIZI",sw:"Tunda la njano tofauti na embe — nyani anakipenda zaidi",en:"Banana"},
        {w:"MKATE",sw:"Chakula kilichotengenezwa kwa unga — tamu na cha kawaida sana",en:"Bread"},
        {w:"TWIGA",sw:"Mrefu zaidi duniani — anakula majani ya mti wa juu kabisa",en:"Giraffe"},
        {w:"NYATI",sw:"Hatari zaidi ya simba — hasamehe anapokukimbia mbele yako",en:"Buffalo"},
        {w:"PUNDA",sw:"Mnyama wa kubeba mizigo — ana masikio marefu kupindukia",en:"Donkey"},
        {w:"MBUNI",sw:"Ndege mkubwa asiyeruka — anakimbia haraka sana msituni",en:"Ostrich"},
        {w:"TAUSI",sw:"Ndege mzuri sana mwenye mkia wa rangi nyingi za kupendeza",en:"Peacock"},
        {w:"NYUKI",sw:"Wadudu wanaofanya asali kwa bidii — wanajua kazi yao",en:"Bees"},
        {w:"PWEZA",sw:"Ana mikono minane — anaweza kubadilisha rangi yake mwenyewe",en:"Octopus"},
        {w:"MVUTO",sw:"Nguvu inayovuta vitu kuelekea chini — duniani ina hii",en:"Gravity/Attraction"},
        {w:"CHAKI",sw:"Unaandika kwenye bodi — mvua inafuta kila kitu ulichoandika",en:"Chalk"}
        ,
        {w:"NYIGU",sw:"Wadudu wanaoduma — wanajenga viota vya asali pia",en:"Wasp"},
        {w:"NZIGE",sw:"Wadudu wanaoruka kwa makundi — wanaangamiza mazao yote",en:"Locust"},
        {w:"KENGE",sw:"Reptile kubwa anayetambaa polepole — ana ulimi mrefu",en:"Monitor lizard"},
        {w:"NGEGE",sw:"Samaki wa maji baridi — maarufu sana Tanzania pwani",en:"Tilapia fish"},
        {w:"NYANI",sw:"Anapanda miti kwa wepesi — anapiga kelele msituni",en:"Baboon/Monkey"},
        {w:"CHATU",sw:"Nyoka mkubwa anayemeza mawindo yake yote bila kuuma",en:"Python/Boa"}
        ,
        {w:"MDOMO",sw:"Unatoa maneno na chakula kupitia hapa — muhimu sana",en:""},
        {w:"UBAVU",sw:"Mifupa ya pande — inalinda moyo na mapafu yako",en:"Rib/Side"},
        {w:"JASHO",sw:"Mwili unatoa hiki ukiwa na joto au hofu kubwa",en:"Sweat"},
        {w:"UGALI",sw:"Chakula cha unga wa mahindi — kikuu sana Afrika",en:"Ugali/Stiff porridge"},
        {w:"NYAMA",sw:"Mwili wa mnyama unaoliwa — siku ya nyama ni furaha",en:"Meat"},
        {w:"MBOGA",sw:"Kijani na yenye afya — watoto hawaikipendi ila ni muhimu",en:"Vegetable"},
        {w:"PAPAI",sw:"Tunda kubwa la rangi ya njano — tamu na laini sana",en:"Papaya"},
        {w:"VIAZI",sw:"Wingi wa kiazi — vya ardhini na vya kukaanga pia",en:"Potatoes"},
        {w:"DENGU",sw:"Mbegu ndogo ndogo za kupikia — chakula cha bei nafuu",en:""},
        {w:"NGANO",sw:"Nafaka ya kutengenezea mkate — ya kaskazini mwa dunia",en:""},
        {w:"JEMBE",sw:"Chombo cha kulimia shambani — jasho linatoka nacho",en:"Hoe/Farm tool"},
        {w:"MWIKO",sw:"Kijiti cha kupikia — unakoroga nacho jikoni kila siku",en:"Wooden spoon/Ladle"},
        {w:"CHUPA",sw:"Kioo cha kuhifadhi vinywaji — inaweza kuvunjika haraka",en:"Bottle"},
        {w:"NAULI",sw:"Pesa unayolipa kupanda gari au meli — bei ya safari",en:"Fare/Ticket price"},
        {w:"UKAME",sw:"Mvua hainyeshi — ardhi inakauka sana",en:"Drought"},
        {w:"NEEMA",sw:"Huruma ya Mungu usiyostahili — bado anakupa daima",en:"Grace/Blessing"},
        {w:"IBADA",sw:"Kumkaribia Mungu kwa moyo wote — kila dini ina njia",en:"Worship"},
        {w:"AMINI",sw:"Kuwa na imani ya mtu — ni thamani inayojengwa polepole",en:"To trust/believe"}
        ,
        {w:"DHIKI",sw:"Hali ngumu ya maumivu ya moyo — inabeba mtu chini",en:"Distress/Affliction"},
        {w:"MWEZI",sw:"Mwanga wa usiku — au kipindi cha siku thelathini kamili",en:"Month/Moon"},
        {w:"MWAKA",sw:"Siku mia tatu sitini na tano — inapita bila huruma",en:"Year"},
        {w:"MKOPO",sw:"Pesa unayokopeshwa — utairejesha na riba juu yake",en:"Loan/Credit"},
        {w:"BENKI",sw:"Mahali pa kuhifadhi pesa salama — na kukopa ukihitaji",en:"Bank"},
        {w:"SANAA",sw:"Ubunifu wa kuchora kupiga picha au kufanya kitu kizuri",en:"Art/Craft"},
        {w:"AHADI",sw:"Maneno ya kujitolea — yakivunjwa yanabeba uzito mkubwa",en:"Promise/Covenant"},
        {w:"SWALI",sw:"Linahitaji jibu — lakini maswali mazuri ni ya thamani",en:"Question"},
        {w:"UONGO",sw:"Unasema kwa haraka — lakini ukweli unakufuatia daima",en:"Lie/Falsehood"},
        {w:"NDUGU",sw:"Mtu wa damu yako — au mtu unayempenda kwa dhati",en:"Sibling/Relative/Fellow"}
        ,
        {w:"MZIZI",sw:"Sehemu ya mmea chini ya ardhi — inashikilia na kulisha",en:"Root"},
        {w:"MZIGO",sw:"Kitu kizito unachobeba — au tatizo unalolibeba maishani",en:"Load/Burden"},
        {w:"MWIGO",sw:"Kufuata mfano wa mtu mwingine — si ubunifu wa kweli",en:"Imitation/Copy"},
        {w:"MFANO",sw:"Kitu kinachoonyesha jinsi kingine kinavyofanana nacho",en:"Example/Model"},
        {w:"HATUA",sw:"Mwendo wa mguu mmoja — au hatua ya kufanya jambo",en:"Step/Stride/Measure"},
        {w:"MWIZI",sw:"Mtu anayeiba — anachukua mali ya wengine bila ruhusa",en:"Thief"},
        {w:"USAWA",sw:"Hali ya kila kitu kuwa sawa — bila ubaguzi wala upendeleo",en:"Equality/Balance"},
        {w:"URAIA",sw:"Hali ya kuwa raia — una haki na wajibu kwa nchi yako",en:"Citizenship"}
        ,
        {w:"NDIYO",sw:"Kukubaliana — kinyume cha hapana — jibu la kutarajiwa sana",en:"Yes"},
        {w:"MFUPA",sw:"Muundo wa ndani wa mwili — unabeba uzito wote wa mwili",en:"Bone"},
        {w:"ONDOA",sw:"Kuondoa kitu mahali — au kuondoa tatizo la muda mrefu",en:"To remove"},
        {w:"KUBWA",sw:"Ukubwa wa kitu — kinachozidi wastani wa vitu vingine",en:"Big/Large"},
        {w:"NDOGO",sw:"Ukidogo wa kitu — kinyume cha kubwa — si muhimu daima",en:"Small/Little"},
        {w:"BICHI",sw:"Kitu ambacho bado hakijaiva — au mtu bila uzoefu wa kazi",en:"Raw/Inexperienced"},
        {w:"TUNZA",sw:"Kutunza kitu au mtu — kwa upendo na makini kila wakati",en:"To take care of"},
        {w:"ELEWA",sw:"Kuelewa kitu — akili inashika maana yake vizuri kabisa",en:"To understand"},
        {w:"ULIZA",sw:"Kuuliza swali — kwa mdomo au kwa maandishi ili ujifunze",en:"To ask/inquire"},
        {w:"PANGA",sw:"Kupanga mipango — au kisu kirefu cha shambani cha mazao",en:"To plan/Machete"},
        {w:"AMBIA",sw:"Kumwambia mtu kitu — au kumtumia ujumbe muhimu wake",en:"To tell/inform"},
        {w:"NJAMA",sw:"Mipango ya siri ya kudhuru mtu — hufanywa na watu wachache",en:"Conspiracy/Plot"},
        {w:"UWEZO",sw:"Nguvu au uhalisi wa kufanya kitu — mtu ana uwezo wake",en:"Ability/Capacity"},
        {w:"MVUVI",sw:"Anavua samaki — maisha yake yanategemea maji na bahati",en:"Fisherman"},
        {w:"BWAWA",sw:"Maji yaliyokusanywa mahali — ya kunywa au kutilia samaki",en:"Pond/Dam"}
    ]

    property var bank6: [
        {w:"BAHARI",sw:"Maji makubwa ya chumvi",en:"Ocean / Sea"},
        {w:"BARIDI",sw:"Kinyume cha joto",en:"Cold"},
        {w:"DARASA",sw:"Chumba cha kujifunza shuleni",en:"Classroom"},
        {w:"HABARI",sw:"Taarifa za hali ya mambo",en:"News"},
        {w:"HUDUMA",sw:"Kazi ya kusaidia wengine",en:"Service"},
        {w:"JIRANI",sw:"Mtu anayeishi karibu nawe",en:"Neighbour"},
        {w:"KALAMU",sw:"Chombo cha kuandikia",en:"Pen"},
        {w:"KILIMO",sw:"Kazi ya kulima ardhi",en:"Farming"},
        {w:"MAISHA",sw:"Hali ya kuwa hai",en:"Life"},
        {w:"MAPEMA",sw:"Wakati wa awali; kabla ya kuchelewa",en:"Early"},
        {w:"PAMOJA",sw:"Kwa pamoja; sio peke yako",en:"Together"},
        {w:"RAFIKI",sw:"Mtu unayempenda na kumwamini",en:"Friend"},
        {w:"SALAMU",sw:"Maneno ya kukaribishana",en:"Greetings"},
        {w:"SHAMBA",sw:"Ardhi ya kulimia",en:"Farm"},
        {w:"UJUMBE",sw:"Habari inayotumwa kwa mtu",en:"Message"},
        {w:"ZAWADI",sw:"Kitu kinachopewa kwa upendo",en:"Gift"},
        {w:"CHANZO",sw:"Mahali ambapo kitu kinaanza",en:"Source / Origin"},
        {w:"FURAHA",sw:"Hisia ya kufurahi na raha",en:"Joy"},
        {w:"KIBURI",sw:"Kujisikia bora kuliko wengine",en:"Pride / Arrogance"},
        {w:"SEHEMU",sw:"Kipande cha kitu kikubwa",en:"Part / Section"},
        {w:"TATIZO",sw:"Jambo gumu linalohitaji suluhisho",en:"Problem"},
        {w:"UKWELI",sw:"Ukweli halisi",en:"Truth"},
        {w:"WAZIRI",sw:"Kiongozi wa wizara serikalini",en:"Minister"},
        {w:"POLISI",sw:"Watu wa kudumisha amani",en:"Police"},
        {w:"KANUNI",sw:"Sheria au taratibu za kufuata",en:"Rules"},
        {w:"SHERIA",sw:"Kanuni za nchi",en:"Law"},
        {w:"HESABU",sw:"Sayansi ya nambari",en:"Mathematics"},
        {w:"BAJETI",sw:"Mpango wa matumizi ya pesa",en:"Budget"},
        {w:"HASARA",sw:"Kupoteza zaidi ya faida",en:"Loss"},
        {w:"ADHABU",sw:"Matokeo mabaya ya kosa",en:"Punishment"},
        {w:"BARAKA",sw:"Nema ya Mungu",en:"Blessing"},
        {w:"UPENDO",sw:"Hisia ya kupenda mtu",en:"Love"},
        {w:"HUZUNI",sw:"Hali ya masikitiko",en:"Sadness"},
        {w:"ZAMANI",sw:"Nyakati zilizopita",en:"Long ago"},
        {w:"KIJIJI",sw:"Makazi madogo vijijini",en:"Village"},
        {w:"DAKIKA",sw:"Sekunde sitini",en:"Minute"},
        {w:"KONDOO",sw:"Mnyama mwenye sufu nyeupe",en:"Sheep"},
        {w:"FARASI",sw:"Mnyama wa kupanda",en:"Horse"},
        {w:"SAMAKI",sw:"Kiumbe cha majini kinachoogelea",en:"Fish"},
        {w:"WATOTO",sw:"Wingi wa mtoto",en:"Children"},
        {w:"KIJANA",sw:"Mtu mdogo wa umri wa ujana",en:"Youth"},
        {w:"HARUSI",sw:"Sherehe ya ndoa",en:"Wedding"},
        {w:"NYUMBA",sw:"Mahali pa kuishi",en:"House"},
        {w:"DARAJA",sw:"Muundo unaounganisha maeneo mawili",en:"Bridge"},
        {w:"KANISA",sw:"Jengo la ibada ya Wakristo",en:"Church"},
        {w:"SAFARI",sw:"Msafara wa kwenda mbali",en:"Journey"},
        {w:"LIKIZO",sw:"Mapumziko ya kazi au shule",en:"Holiday"},
        {w:"MSAADA",sw:"Kusaidia mtu",en:"Help"},
        {w:"KIVULI",sw:"Linakufuata kila mahali lakini halikusumbui kamwe",en:"Shadow"},
        {w:"KISASI",sw:"Kulipiza — lakini hakuna anayeshinda mwishowe",en:"Revenge"},
        {w:"FITINA",sw:"Maneno matamu yanayolipuka kama baruti ndani ya jamii",en:"Intrigue/Mischief"},
        {w:"DHARAU",sw:"Kumwona mtu si kitu — hata yeye ana damu kama wewe",en:"Contempt"},
        {w:"UJANJA",sw:"Akili ya mwepesi — wakati mwingine inakudanganya wewe mwenyewe",en:"Cleverness/Cunning"},
        {w:"GHUSHI",sw:"Inajifanya ya kweli lakini ukigusa inaporomoka",en:"Fake/Fraud"},
        {w:"MAJUTO",sw:"Inakuja baada ya tendo — si kabla — kila wakati",en:"Regret/Remorse"},
        {w:"HASIRA",sw:"Moto unaowaka haraka — unaweza kuchoma nyumba yako yote",en:"Anger/Rage"},
        {w:"LAWAMA",sw:"Kidole kinaelekeza nje lakini vidole vingine vitatu vinakuelekea wewe",en:"Blame"},
        {w:"MSONGO",sw:"Mzigo usioeonekana lakini unalemea kuliko jiwe",en:"Mental stress"},
        {w:"UPWEKE",sw:"Wakati mwingine ni baraka — wakati mwingine ni adhabu",en:"Solitude/Loneliness"},
        {w:"MGANGA",sw:"Anajua dawa lakini hata yeye anaumia wakati mwingine",en:"Healer/Doctor/Herbalist"},
        {w:"KIZAZI",sw:"Watu wa umri mmoja — wataandika historia yao wenyewe",en:"Generation"},
        {w:"SAMEHE",sw:"Ni nguvu kubwa — wanyonge hawakuweza kamwe",en:"To forgive"},
        {w:"KARAMU",sw:"Chakula cha furaha — tumbo linashangilia",en:"Feast/Banquet"},
        {w:"KATAZO",sw:"Kinakuzuia kufanya unachopenda — lakini kina sababu",en:"Prohibition/Ban"},
        {w:"SUBIRA",sw:"Silaha ya wenye nguvu wanyonge hukata tamaa mapema sana",en:"Patience"},
        {w:"BAHATI",sw:"Inakuja bila kukualika na kuondoka bila kusema kwa heri",en:"Luck/Fortune"},
        {w:"UCHOVU",sw:"Mwili unasema acha hata akili inakubaliana naye leo hii",en:"Fatigue"},
        {w:"BUSARA",sw:"Hekima ya vitendo inakuja baada ya makosa mengi si vitabuni",en:"Wisdom"},
        {w:"UELEWA",sw:"Uwezo wa kuelewa kwa undani si kujua tu bali kugusa maana",en:"Comprehension"},
        {w:"MWANZO",sw:"Hatua ya kwanza ndiyo ngumu zaidi baadaye inakuwa rahisi",en:"Beginning"},
        {w:"NGUONO",sw:"Nguvu ya ujana inayowaka ghafla na kuzimika haraka sana",en:"Youth energy"},
        {w:"MWISHO",sw:"Kila kitu kina hii maisha yana hii safari ina hii pia",en:"End/Conclusion"},
        {w:"AMBAPO",sw:"Mahali ambapo kitu kilikotokea kiashiria muhimu cha lugha",en:"Where/Whereby"},
        {w:"ANGUKA",sw:"Kushuka chini bila kukusudia — hata watu wakubwa wanaanguka",en:"To fall down"},
        {w:"CHOMBO",sw:"Kitu cha kufanyia kazi — bila yake kazi inakuwa ngumu",en:"Tool/Vessel/Instrument"},
        {w:"FANANA",sw:"Kufanana na kitu kingine — lakini si kitu kimoja halisi",en:"To resemble/be similar"},
        {w:"JARIBU",sw:"Kujaribu kitu kipya bila kujua matokeo yake kabla yake",en:"To try/attempt"},
        {w:"KATIKA",sw:"Ndani ya sehemu fulani — au kwa wakati fulani maalum",en:"In/Within/During"},
        {w:"LAZIMA",sw:"Hakuna jinsi nyingine — ni wajibu usioepukika kamwe",en:"Must/Necessary/Obligatory"}
        ,
        {w:"ACHANA",sw:"Kuacha uhusiano au kufarakana — wakati mwingine ni bora sana",en:"To separate/part ways"},
        {w:"MPANGO",sw:"Hatua za kufuata kufikia lengo — bila mpango hauna mwelekeo",en:"Plan/Programme/Strategy"},
        {w:"MUUNDO",sw:"Jinsi kitu kilivyoundwa ndani — msingi wa jengo au shirika",en:"Structure/Design/Architecture"},
        {w:"BIDHAA",sw:"Vitu vinavyouzwa — biashara yake ni kununua na kuuza kila siku",en:"Goods/Products/Commodities"},
        {w:"MWENDO",sw:"Mwelekeo wa safari — au jinsi unavyoendelea maishani yako",en:"Pace/Progress/Journey"},
        {w:"RIPOTI",sw:"Taarifa iliyoandikwa — inasema kilichotokea bila kupinda maneno",en:"Report/Record"},
        {w:"MAPATO",sw:"Pesa inayoingia — kila familia inahitaji hii kuishi vizuri",en:"Income/Revenue/Earnings"},
        {w:"UWANJA",sw:"Eneo wazi la michezo — au ndege zinapaa na kutua hapa",en:"Field/Stadium/Airport/Ground"},
        {w:"SANAMU",sw:"Picha au mfano wa binadamu au mnyama uliotengenezwa",en:"Statue/Image/Idol"},
        {w:"BARAZA",sw:"Mkutano wa wazee au viongozi — au ukumbi wa kukusanyika",en:"Council/Meeting place/Veranda"}
        ,
        {w:"SUKARI",sw:"Inaongeza utamu — lakini mengi yanakudhuru sana mwilini",en:"Sugar"},
        {w:"MLANGO",sw:"Unaoingiwa na kutoka nawo nyumbani — unafungua fursa nyingi",en:"Door/Gate/Entrance"},
        {w:"KIBOKO",sw:"Mwogopaji wa mto — anakula nyasi usiku kwa siri kabisa",en:"Hippo"},
        {w:"KASUKU",sw:"Ndege anayeiga maneno ya binadamu — mzuri wa kipekee sana",en:"Parrot"},
        {w:"BUIBUI",sw:"Anatanda wavu wake wa uzi — anangoja kwa uvumilivu mkubwa",en:"Spider"},
        {w:"VITABU",sw:"Wingi wa kitabu — hazina ya maarifa ya watu waliokwisha kufa",en:"Books"},
        {w:"DAFTAR",sw:"Kurasa nyingi tupu za kuandikia mawazo na masomo ya shule",en:"Notebook/Exercise book"},
        {w:"NANASI",sw:"Tunda lenye miiba nje — tamu ndani kama maisha ya kweli",en:"Pineapple"}
        ,
        {w:"NYUMBU",sw:"Wildebeest — wanaohama Serengeti kwa makundi makubwa sana",en:"Wildebeest/GNU"}
        ,
        {w:"KICHWA",sw:"Sehemu ya juu ya mwili — akili iko hapa ndani yake",en:"Head"},
        {w:"KIDOLE",sw:"Una kumi vya mkono na kumi vya mguu — muhimu sana",en:"Finger/Toe"},
        {w:"MGONGO",sw:"Nyuma ya mwili — unabeba mizigo ya wengine kwa muda",en:"Back/Spine"},
        {w:"NYWELE",sw:"Zinakua kichwani bila kukuomba idhini yako kamwe",en:"Hair"},
        {w:"CHUMVI",sw:"Kidogo inaongeza ladha — mengi yanakuua polepole sana",en:"Salt"},
        {w:"ZABIBU",sw:"Matunda madogo yanayokusanywa — yanatengenezea divai",en:"Grapes"},
        {w:"TIKITI",sw:"Tunda kubwa jekundu ndani kijani nje — maji mengi ndani",en:"Watermelon"},
        {w:"MCHELE",sw:"Mbegu ndogo nyeupe za kupika wali — zinahitaji maji mengi",en:"Rice uncooked"},
        {w:"MUHOGO",sw:"Mmea wa mizizi unaoliwa Afrika — unastawi ukame mzuri",en:"Cassava"},
        {w:"NYANYA",sw:"Tunda jekundu la kupikia — au la saladi ya kawaida",en:"Tomato"},
        {w:"KAROTI",sw:"Mboga ya chungwa — nzuri kwa macho yako ya kuona sana",en:"Carrot"},
        {w:"BAKULI",sw:"Unaweka supu au uji ndani yake — la mviringo sana",en:"Bowl"},
        {w:"TIKETI",sw:"Karatasi ya ruhusa ya kusafiri — lazima uiwe nawe",en:"Ticket"},
        {w:"MWANGA",sw:"Giza linakimbia punde tu unapoanza kuwaka ndani yake",en:"Light/Illumination"},
        {w:"HOTELI",sw:"Mahali pa kulala ukisafiri — ya bei nafuu au ya starehe",en:"Hotel/Lodge"}
        ,
        {w:"KIJITO",sw:"Mto mdogo — unaotiririka kimya kimya msituni bila kelele",en:"Stream/Brook"},
        {w:"UFUNDI",sw:"Ujuzi wa kufanya kazi kwa mikono — fundi ni muhimu",en:"Craftsmanship/Skill"},
        {w:"UJENZI",sw:"Kazi ya kujenga majengo — inahitaji nguvu na akili pia",en:"Construction/Building"},
        {w:"WAJIBU",sw:"Kitu unachopaswa kukifanya — si chaguo bali lazima yako",en:"Duty/Responsibility"},
        {w:"HUKUMU",sw:"Uamuzi wa korti au Mungu — unaathiri maisha ya mtu",en:"Judgment/Verdict"},
        {w:"UCHUMI",sw:"Mfumo wa pesa na bidhaa — unaathiri maisha ya kila mtu",en:"Economy"},
        {w:"MUZIKI",sw:"Sanaa ya sauti iliyopangwa — inafikia moyo bila ruhusa",en:""},
        {w:"HEKALU",sw:"Jengo la ibada ya Wayahudi — la historia ya zamani sana",en:"Temple/Shrine"},
        {w:"CHANJO",sw:"Sindano ya kuzuia ugonjwa — inakuokoa kabla ya ugonjwa",en:"Vaccine/Vaccination"},
        {w:"GAZETI",sw:"Karatasi ya taarifa za kila siku — unasoma habari zake",en:"Newspaper"}
        ,
        {w:"UMANDE",sw:"Maji madogo yanayotua usiku kwenye majani asubuhi yake",en:"Dew"},
        {w:"MTINDO",sw:"Namna ya kufanya kitu — au mwenendo wa mavazi yako",en:"Style/Fashion/Method"},
        {w:"UAMUZI",sw:"Chaguo unalofanya — lina matokeo mazuri au mabaya",en:"Decision/Choice"},
        {w:"UZOEFU",sw:"Kile ulichojifunza kwa kuishi — si vitabuni tu kabisa",en:""},
        {w:"UNDUGU",sw:"Hali ya kuwa ndugu — upendo wa kweli wa familia yote",en:""},
        {w:"UTAIFA",sw:"Kuwa raia wa nchi — hisia za kupenda nchi yako mwenyewe",en:""},
        {w:"MBUNGE",sw:"Mwakilishi wa wananchi bungeni — anayepigania haki zao",en:"Member of Parliament"},
        {w:"GAVANA",sw:"Kiongozi wa mkoa — anatekeleza sera za serikali kuu",en:"Governor"},
        {w:"ASKARI",sw:"Mlinzi wa amani — anabeba silaha na jukumu kubwa sana",en:"Soldier/Guard"},
        {w:"WAKILI",sw:"Mtu anayesimamia haki za mwingine mahakamani kwa ujuzi",en:"Lawyer/Advocate"},
        {w:"SAKAFU",sw:"Sehemu ya chini ya chumba — tunaikanyaga kila siku bila shukrani",en:"Floor"}
        ,
        {w:"ASANTE",sw:"Neno la shukrani — linafurahi moyo wa mpewa na mtoa",en:"Thank you"},
        {w:"KARIBU",sw:"Neno la kukukaribisha — linafungua milango mingi maishani",en:"Welcome"},
        {w:"HAPANA",sw:"Kukataa — kinyume cha ndiyo — jibu zito wakati mwingine",en:"No"},
        {w:"ANDIKA",sw:"Kuandika — maneno yanayoandikwa hubaki muda mrefu zaidi",en:"To write"},
        {w:"ANGAZA",sw:"Kuangaza — kutoa mwanga katika giza ili uone njia yako",en:"To illuminate"},
        {w:"FUNIKA",sw:"Kufunika kitu — ili kisione wala kisichukuliwe kabla",en:"To cover"},
        {w:"OTESHA",sw:"Kulisha mnyama au mtoto — kutoa chakula bila kuomba",en:"To feed/nourish"},
        {w:"SILAHA",sw:"Chombo cha vita — linachookoa au kuua — ni hatari sana",en:"Weapon"},
        {w:"KIPAWA",sw:"Uwezo wa pekee uliombiwa na Mungu — si kila mtu ana hii",en:"Gift/Talent"}
    ]

    property var bank7: [
        {w:"HESHIMA",sw:"Kuheshimu na kuthamini mtu",en:"Respect"},
        {w:"FALSAFA",sw:"Taaluma ya hekima na maswali ya maisha",en:"Philosophy"},
        {w:"SAYANSI",sw:"Taaluma ya kuchunguza asili",en:"Science"},
        {w:"UJASIRI",sw:"Kutokuogopa hatari",en:"Courage"},
        {w:"USALAMA",sw:"Hali ya kuwa salama",en:"Safety / Security"},
        {w:"UONGOZI",sw:"Uwezo wa kuongoza wengine",en:"Leadership"},
        {w:"UTAJIRI",sw:"Hali ya kuwa na mali nyingi",en:"Wealth"},
        {w:"USHAURI",sw:"Maoni yanayotolewa kusaidia",en:"Advice"},
        {w:"MATOKEO",sw:"Kile kinachofika baada ya juhudi",en:"Results"},
        {w:"MAELEZO",sw:"Maelezo ya kina ya kitu",en:"Explanation"},
        {w:"MAAMUZI",sw:"Wingi wa uamuzi",en:"Decisions"},
        {w:"MAFUNZO",sw:"Mafunzo ya kazi au ujuzi",en:"Training"},
        {w:"MANUFAA",sw:"Faida za kitu au kitendo",en:"Benefits"},
        {w:"MKAKATI",sw:"Mpango wa kina wa kufuata",en:"Strategy"},
        {w:"TAKWIMU",sw:"Nambari za takwimu za utafiti",en:"Statistics"},
        {w:"GHARAMA",sw:"Bei ya kitu au huduma",en:"Cost / Expense"},
        {w:"ALASIRI",sw:"Wakati wa mchana baada ya adhuhuri",en:"Afternoon"},
        {w:"ASUBUHI",sw:"Wakati wa mapema wa siku",en:"Morning"},
        {w:"BAADAYE",sw:"Wakati unaokuja mbele",en:"Later"},
        {w:"MWALIMU",sw:"Mtu anayefundisha shuleni",en:"Teacher"},
        {w:"FAMILIA",sw:"Wazazi na watoto wao",en:"Family"},
        {w:"MKULIMA",sw:"Mtu anayefanya kazi shambani",en:"Farmer"},
        {w:"MUUGUZI",sw:"Mtu anayehudumia wagonjwa",en:"Nurse"},
        {w:"KUMBUKA",sw:"Kuleta mawazo ya zamani akilini",en:"To remember"},
        {w:"HONGERA",sw:"Maneno ya kufurahia mafanikio",en:"Congratulations"},
        {w:"DAKTARI",sw:"Mtu aliyesomea tiba ya binadamu",en:"Doctor"},
        {w:"MPENDWA",sw:"Mtu unayempenda sana",en:"Dear / Beloved"},
        {w:"SHEREHE",sw:"Sikukuu ya kufurahia",en:"Celebration"},
        {w:"SHANGWE",sw:"Kelele za furaha kubwa",en:"Jubilation"},
        {w:"MALAIKA",sw:"Kiumbe cha kiroho cha Mungu",en:"Angel"},
        {w:"NYEPESI",sw:"Kinyume cha nzito",en:"Light (weight)"},
        {w:"UGONJWA",sw:"Hali ya mwili kutokuwa na afya",en:"Illness"},
        {w:"BUSTANI",sw:"Shamba la maua na miti ya mapambo",en:"Garden"},
        {w:"BANDARI",sw:"Mahali pa kuingia na kutoka kwa meli",en:"Port"},
        {w:"MKUTANO",sw:"Kukusanyika kwa watu kuzungumza",en:"Meeting"},
        {w:"MSIKITI",sw:"Jengo la ibada ya Waislamu",en:"Mosque"},
        {w:"DIRISHA",sw:"Tundu la glasi ukutani",en:"Window"},
        {w:"KIWANDA",sw:"Jengo la kutengeneza bidhaa",en:"Factory"},
        {w:"SURUALI",sw:"Mavazi ya miguu miwili",en:"Trousers"},
        {w:"THELUJI",sw:"Mvua ya baridi kama pamba nyeupe",en:"Snow"},
        {w:"DHAHABU",sw:"Madini ya thamani ya rangi ya njano",en:"Gold"},
        {w:"NIDHAMU",sw:"Utaratibu na kufuata sheria",en:"Discipline"},
        {w:"JAMHURI",sw:"Mfumo wa serikali inayochaguliwa",en:"Republic"},
        {w:"SHANGAZI",sw:"Dada ya baba yako",en:"Aunt"},
        {w:"NADHANI",sw:"Kufikiri au kushangazwa",en:"I think"},
        {w:"PUMZIKA",sw:"Kupumzika baada ya kazi",en:"To rest"},
        {w:"KUCHEZA",sw:"Kufanya mchezo",en:"To play"},
        {w:"KUOGOPA",sw:"Kuwa na woga",en:"To fear"},
        {w:"KUPENDA",sw:"Kuwa na hisia za upendo",en:"To love"},
        {w:"KUELEWA",sw:"Kupata maana ya kitu",en:"To understand"},
        {w:"KUCHEKA",sw:"Kuonyesha furaha kwa kicheko",en:"To laugh"},
        {w:"UHALISI",sw:"Hali halisi ya mambo",en:"Reality"},
        {w:"MBINGWA",sw:"Mshindi bingwa",en:"Champion"},
        {w:"SIKUKUU",sw:"Siku maalum ya sherehe ya kitaifa",en:"Public holiday"},
        {w:"DHAMIRA",sw:"Inakuchochea hata ndoto zako zinapofikia mbali sana",en:"Determination/Purpose"},
        {w:"UBUNIFU",sw:"Kuumba kitu kipya kutoka mahali pasipo kitu",en:"Creativity/Innovation"},
        {w:"USHUJAA",sw:"Kukabiliana na jambo gumu wakati wengine wanakimbia",en:"Bravery/Heroism"},
        {w:"UNYOOFU",sw:"Kuwa wazi na wa moja kwa moja — bila uso wa pili",en:"Straightforwardness"},
        {w:"MSAMAHA",sw:"Kuachilia mtu aliyekukosea — ni nguvu kubwa si udhaifu",en:"Forgiveness"},
        {w:"UTABIRI",sw:"Kusema kitakachotokea kabla ya kutokea",en:"Prophecy/Prediction"},
        {w:"DHARURA",sw:"Hali ya hatari inayohitaji hatua za haraka sana",en:"Emergency"},
        {w:"UNAFIKI",sw:"Uso mmoja mbele yako na mwingine nyuma yako",en:"Hypocrisy"},
        {w:"UFISADI",sw:"Kutumia mamlaka vibaya kwa faida yako bila kujali wengine",en:"Corruption"},
        {w:"MAJONZI",sw:"Huzuni nzito inayobeba mtu chini bila yeye kujua sababu",en:"Grief/Sorrow"},
        {w:"STAREHE",sw:"Mwili unapumzika lakini akili bado inafanya kazi yake usiku",en:"Comfort/Ease"},
        {w:"MAARIFA",sw:"Unayoyajua lakini kujua tu hakutoshi bila kutenda kweli",en:"Knowledge"},
        {w:"NGURUWE",sw:"Mnyama wa shambani mwenye pua ndefu anajua njia ya kuchimba",en:"Pig"},
        {w:"UTAYARI",sw:"Hali ya kuwa tayari — umejitayarisha kabla ya wakati",en:"Readiness/Preparedness"},
        {w:"MKAGUZI",sw:"Mtu anayekagua hesabu au kazi kwa makini na usahihi",en:"Auditor/Inspector"}
        ,
        {w:"KIZUIZI",sw:"Kitu kinachozuia maendeleo — lakini kinafundisha uvumilivu sana",en:"Obstacle/Barrier/Hindrance"},
        {w:"MSIMAMO",sw:"Mtazamo thabiti wa mtu — asibadilishwe na upepo wowote wa maisha",en:"Position/Stance/Stand"},
        {w:"USAFIRI",sw:"Njia ya kwenda mahali — kila safari ina mwanzo na mwisho wake",en:"Transport/Travel/Journey"},
        {w:"UTAFITI",sw:"Kuchunguza kwa makini kupata ukweli uliofichwa sana ndani",en:"Research/Investigation/Study"}
        ,
        {w:"KIPEPEO",sw:"Anaanza kama kiwavi — kisha anakuwa mzuri sana duniani",en:"Butterfly"},
        {w:"PENSELI",sw:"Unaweza kufuta kile ulichoandika — tofauti na kalamu kabisa",en:"Pencil"},
        {w:"MSALABA",sw:"Alama ya mateso na ukombozi — inamaanisha mengi duniani",en:"Cross/Crucifix"}
        ,
        {w:"KORONGO",sw:"Ndege mrefu wa miguu mirefu anayeishi mtoni kwa starehe",en:"Crane/Heron"},
        {w:"NGEDERE",sw:"Nyani mkubwa mwenye nguvu — anafanana na binadamu kidogo",en:"Chimpanzee/Ape"},
        {w:"WATALII",sw:"Watu wanaokuja Tanzania kuona maajabu ya asili yake",en:"Tourists/Visitors"}
        ,
        {w:"MATUKIO",sw:"Wingi wa tukio — yanabadilika historia ya nchi na dunia",en:"Events/Occurrences"},
        {w:"MASLAHI",sw:"Manufaa au faida ya mtu au jamii — muhimu kuzingatia",en:"Interests/Benefits/Welfare"},
        {w:"KUPANDA",sw:"Kwenda juu kwa hatua — mlima au mti au ngazi ndefu",en:"To climb/ascend"},
        {w:"KUSHUKA",sw:"Kwenda chini kutoka juu — pole pole au kwa haraka sana",en:"To descend"},
        {w:"KUNUNUA",sw:"Kutoa pesa kupata bidhaa unayoihitaji au unayoitaka",en:"To buy/purchase"},
        {w:"KULINDA",sw:"Kulinda kitu au mtu kutoka hatari — kazi ya upendo",en:"To protect/guard"},
        {w:"KUJENGA",sw:"Kuunda jengo au kitu kimara cha kudumu maisha yote",en:"To build/construct"},
        {w:"KUAMINI",sw:"Kuwa na imani ya kitu au mtu — nguvu inayosaidia",en:"To believe/trust"},
        {w:"KUTULIA",sw:"Kuwa na utulivu wa moyo baada ya dhoruba kubwa yoyote",en:"To calm down"}
        ,
        {w:"UHALIFU",sw:"Kitendo cha kukiuka sheria — kinachodhuru jamii nzima",en:""},
        {w:"MSOMAJI",sw:"Mtu anayesoma — anafungua ulimwengu mpya kila ukurasa",en:""},
        {w:"MTANDAO",sw:"Unganiko wa mawasiliano duniani kote — internet ya kisasa",en:""},
        {w:"MAZOEZI",sw:"Kufanya kazi za mwili kwa makusudi — afya inashukuri",en:"Exercise/Workout"},
        {w:"URAFIKI",sw:"Uhusiano wa upendo na heshima — unaojengwa polepole sana",en:""}
        ,
        {w:"SHAHIDI",sw:"Mtu aliyeona tukio — ushuhuda wake ni muhimu mahakamani",en:""},
        {w:"MICHEZO",sw:"Shughuli za mwili za kupumzika — au ushindani wa nchi",en:"Sports/Games"},
        {w:"TOFAUTI",sw:"Kutofautiana na kitu kingine — kila mtu ana tofauti yake",en:"Difference/Diversity"}
        ,
        {w:"HIFADHI",sw:"Kuhifadhi kitu salama mahali — au hifadhi ya asili yake",en:"Conservation/Preserve"}
    ]

    // ── Settings ──────────────────────────────────────────────────────────────
    property string screen:        "setup"
    property int    roundCount:    10
    property var    lengthChoices: [4,5,6,7]  // zote zimechaguliwa

    // ── Game state ────────────────────────────────────────────────────────────
    property var    wordList:     []
    property var    playedWords:  []  // maneno yaliyochezwa — hayarudi

    // Pakia playedWords kutoka Settings ukianza app
    Component.onCompleted: {
        try {
            var loaded = JSON.parse(gameSettings.playedWordsJson);
            if(Array.isArray(loaded)){ playedWords = loaded; }
        } catch(e) {
            playedWords = [];
        }
    }
    property int    wordIndex:    0
    property var    currentEntry: ({w:"",sw:"",en:""})
    property string currentWord:  ""
    property string hiddenWord:   ""
    property int    score:        0
    property int    displayScore: 0   // animated count-up on results
    property bool   clueCardTrigger: false  // toggles to trigger clue animation

    // Floating score animation
    property int    lastPtsDelta: 0   // +N or -N to show
    property bool   ptsVisible:   false
    property bool   ptsPositive:  true
    property int    timeLeft:     30
    property bool   hintUsed:     false
    property bool   roundOver:    false
    property var    blanks:       []
    property var    filled:       []
    property string resultMsg:    ""
    property bool   resultGood:   true

    Timer {
        id: countdownTimer
        interval: 1000; repeat: true
        onTriggered: {
            if(timeLeft>0){ timeLeft--; }
            else { revealAnswer(false); }
        }
    }

    function bankForLen(len) {
        if(len===4){ return bank4; }
        if(len===5){ return bank5; }
        if(len===6){ return bank6; }
        if(len===7){ return bank7; }
        return bank5;
    }

    function shuffle(arr) {
        var a=arr.slice();
        for(var i=a.length-1;i>0;i--){
            var j=Math.floor(Math.random()*(i+1));
            var t=a[i]; a[i]=a[j]; a[j]=t;
        }
        return a;
    }

    function buildWordList() {
        var all=[];
        for(var i=0;i<lengthChoices.length;i++){
            var b=bankForLen(lengthChoices[i]);
            for(var j=0;j<b.length;j++){
                if(b[j].w.length===lengthChoices[i]){ all.push(b[j]); }
            }
        }
        // Toa maneno yaliyochezwa tayari
        var fresh = all.filter(function(entry){
            return playedWords.indexOf(entry.w) === -1;
        });
        // Kama maneno mapya hayatoshi, futa kumbukumbu na uanze upya
        if(fresh.length < roundCount){
            playedWords = [];
            gameSettings.playedWordsJson = "[]";
            fresh = all;
        }
        return shuffle(fresh).slice(0, Math.min(roundCount, fresh.length));
    }

    function makeHidden(word) {
        var len = word.length;
        // Decide how many letters to SHOW (reveal), rest become blanks
        // Short word (4): show 2, blank 2
        // Medium (5-6):   show 2, blank rest
        // Long (7+):      show 3, blank rest
        var showCount = len <= 4 ? 2 : len <= 6 ? 2 : 3;

        // Pick which positions to SHOW — always include at least one
        // from the first half and one from the second half (so word is not all blanks one side)
        var allPos = [];
        for(var x=0; x<len; x++){ allPos.push(x); }

        // Shuffle positions
        var shuffled = allPos.slice();
        for(var s=shuffled.length-1; s>0; s--){
            var r=Math.floor(Math.random()*(s+1));
            var tmp=shuffled[s]; shuffled[s]=shuffled[r]; shuffled[r]=tmp;
        }

        // Pick showCount positions to reveal, ensuring spread
        // Force one from first half, one from second half
        var firstHalf  = allPos.filter(function(i){ return i < Math.floor(len/2); });
        var secondHalf = allPos.filter(function(i){ return i >= Math.floor(len/2); });

        // Shuffle each half
        for(var a=firstHalf.length-1;a>0;a--){
            var ra=Math.floor(Math.random()*(a+1));
            var ta=firstHalf[a]; firstHalf[a]=firstHalf[ra]; firstHalf[ra]=ta;
        }
        for(var b2=secondHalf.length-1;b2>0;b2--){
            var rb=Math.floor(Math.random()*(b2+1));
            var tb=secondHalf[b2]; secondHalf[b2]=secondHalf[rb]; secondHalf[rb]=tb;
        }

        // Reveal: 1 from each half guaranteed, rest random from remaining
        var revealed = {};
        revealed[firstHalf[0]]  = true;
        revealed[secondHalf[0]] = true;

        // Fill remaining showCount slots from shuffled full list
        var remaining = showCount - 2;
        for(var i2=0; remaining>0 && i2<shuffled.length; i2++){
            if(!revealed[shuffled[i2]]){ revealed[shuffled[i2]]=true; remaining--; }
        }

        // Build output
        var out=[]; var blankArr=[];
        for(var i3=0; i3<len; i3++){
            if(revealed[i3]){ out.push(word[i3]); }
            else{ out.push("_"); blankArr.push(i3); }
        }
        blanks=blankArr; filled=[];
        return out.join("");
    }

    function startGame() {
        wordList=buildWordList(); wordIndex=0; score=0;
        // Hifadhi maneno haya kama yaliyochezwa
        var played=playedWords.slice();
        for(var i=0;i<wordList.length;i++){ played.push(wordList[i].w); }
        playedWords=played;
        // Hifadhi kwenye Settings — itabaki hata ukifunga app
        gameSettings.playedWordsJson = JSON.stringify(played);
        screen="playing"; loadWord();
    }

    function loadWord() {
        if(wordIndex>=wordList.length){
            screen="results";
            countdownTimer.stop();
            app.ad();
            return;
        }
        currentEntry=wordList[wordIndex];
        currentWord=currentEntry.w;
        hiddenWord=makeHidden(currentWord);
        filled=[]; hintUsed=false; roundOver=false;
        timeLeft=10+currentWord.length*3;
        countdownTimer.restart();
        displayModel.rebuild();
        // Trigger clue card slide-in
        clueCardTrigger = !clueCardTrigger;
    }

    function typeLetter(l) {
        if(roundOver){ return; }
        if(filled.length>=blanks.length){ return; }
        var f=filled.slice(); f.push(l); filled=f;
        displayModel.rebuild();
        if(filled.length===blanks.length){ checkAnswer(); }
    }

    function deleteLetter() {
        if(roundOver){ return; }
        if(filled.length===0){ return; }
        var f=filled.slice(); f.pop(); filled=f;
        displayModel.rebuild();
    }

    function checkAnswer() {
        var chars=hiddenWord.split("");
        for(var i=0;i<blanks.length;i++){ chars[blanks[i]]=filled[i]||"_"; }
        var guess=chars.join("");
        if(guess===currentWord){
            var wordPts=Math.round(100/roundCount);
            var maxTime=10+currentWord.length*3;
            var timePenalty=Math.round(wordPts*0.3*(1-timeLeft/maxTime));
            var pts=Math.max(1,wordPts-timePenalty);
            score+=pts;
            lastPtsDelta=pts; ptsPositive=true; ptsVisible=true; ptsHideTimer.restart();
            roundOver=true; countdownTimer.stop();
            resultMsg="✓ Sahihi! +"+pts+" pointi"; resultGood=true;
            displayModel.rebuild(); resultTimer.start();
        } else {
            var f=filled.slice(); f.pop(); filled=f;
            displayModel.rebuild(); wrongFlash.start();
        }
    }

    function revealAnswer(isHint) {
        if(roundOver){ return; }
        roundOver=true; hintUsed=true; countdownTimer.stop();
        var deduct=Math.round(100/roundCount);
        score=Math.max(0,score-deduct);
        lastPtsDelta=deduct; ptsPositive=false; ptsVisible=true; ptsHideTimer.restart();
        resultMsg=(isHint?"Jibu: ":"Muda kwisha! ")+currentWord+" −"+deduct+" pointi";
        resultGood=false;
        var f=[];
        for(var i=0;i<blanks.length;i++){ f.push(currentWord[blanks[i]]); }
        filled=f; displayModel.rebuild(); resultTimer.start();
    }

    function showMsg(m){ message=m; msgVisible=true; msgTimer.restart(); }

    Timer { id: resultTimer; interval:1600; onTriggered:{ wordIndex++; loadWord(); } }
    Timer { id: ptsHideTimer; interval:1000; onTriggered:{ ptsVisible=false; } }

    ListModel {
        id: displayModel
        function rebuild() {
            displayModel.clear();
            if(currentWord===""){ return; }
            var chars=hiddenWord.split("");
            var bi=0;
            for(var i=0;i<chars.length;i++){
                if(chars[i]!=="_"){
                    displayModel.append({ch:chars[i],kind:"fixed"});
                } else {
                    if(bi<filled.length){
                        var ok=roundOver&&filled[bi]===currentWord[blanks[bi]];
                        var bad=roundOver&&filled[bi]!==currentWord[blanks[bi]];
                        displayModel.append({ch:filled[bi],kind:ok?"correct":(bad?"wrong":"filled")});
                    } else {
                        displayModel.append({ch:"_",kind:"blank"});
                    }
                    bi++;
                }
            }
        }
    }

    SequentialAnimation {
        id: wrongFlash
        NumberAnimation{target:wordRow;property:"x";to: dp(8);duration:40}
        NumberAnimation{target:wordRow;property:"x";to:-dp(8);duration:40}
        NumberAnimation{target:wordRow;property:"x";to: dp(4);duration:30}
        NumberAnimation{target:wordRow;property:"x";to:0;     duration:30}
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ── SETUP SCREEN ─────────────────────────────────────────────────────────
    // ─────────────────────────────────────────────────────────────────────────
    Item {
        anchors.fill: parent
        opacity: screen==="setup" ? 1 : 0
        visible: opacity > 0
        enabled: screen==="setup"
        Behavior on opacity { NumberAnimation { duration: 320; easing.type: Easing.InOutQuad } }

        Column {
            anchors.centerIn: parent
            width: parent.width * 0.85
            spacing: dp(20)

            // ── Logo block — design ya zamani, rangi mpya ─────────────────
            Item {
                width: parent.width
                height: dp(110)

                // Glow nyuma ya jina
                Rectangle {
                    anchors.centerIn: parent
                    width: dp(200); height: dp(70)
                    radius: dp(35)
                    color: accent
                    opacity: 0.07
                }

                Column {
                    anchors.centerIn: parent
                    spacing: dp(8)

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "NENO"
                        font.pixelSize: dp(52); font.bold: true
                        font.letterSpacing: dp(14)
                        color: accent
                    }
                    // Underline accent bar
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: dp(52); height: dp(2); radius: dp(1)
                        color: accent; opacity: 0.6
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Jaza nafasi — Pata pointi"
                        font.pixelSize: dp(12)
                        color: textDim
                        font.letterSpacing: dp(0.5)
                    }
                }
            }

            // ── Maneno card — IQTest style ────────────────────────────────
            Rectangle {
                width: parent.width
                height: dp(90)
                radius: dp(14)
                color: bgCard
                border.color: Qt.rgba(0,0.9,1,0.15); border.width: dp(1)

                Column {
                    anchors.fill: parent
                    anchors.margins: dp(14)
                    spacing: dp(10)

                    Text {
                        text: "MANENO KWA MCHEZO"
                        font.pixelSize: dp(10); font.bold: true
                        font.letterSpacing: dp(2); color: textDim
                    }

                    Row {
                        spacing: dp(8)
                        Repeater {
                            model: [5, 10, 15, 20]
                            delegate: Rectangle {
                                property bool sel: roundCount === modelData
                                width: dp(58); height: dp(36); radius: dp(10)
                                color: sel ? Qt.rgba(0,0.9,1,0.18) : bgInput
                                border.color: sel ? accent : Qt.rgba(0,0.9,1,0.12)
                                border.width: sel ? dp(1.5) : dp(1)
                                Behavior on color { ColorAnimation { duration: 150 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: dp(17); font.bold: true
                                    color: sel ? accent : textDim
                                }
                                MouseArea { anchors.fill: parent; onClicked: { roundCount = modelData; } }
                            }
                        }
                    }
                }
            }

            // ── ANZA button — IQTest style ────────────────────────────────
            Rectangle {
                width: parent.width; height: dp(54); radius: dp(14)
                color: Qt.rgba(0,0.9,1,0.12)
                border.color: accent; border.width: dp(1.5)

                // Glow effect
                Rectangle {
                    anchors.fill: parent
                    radius: dp(14)
                    color: "transparent"
                    border.color: goldGlow; border.width: dp(1)
                    opacity: 0.2
                }

                Row {
                    anchors.centerIn: parent; spacing: dp(10)
                    Text {
                        text: "▶"
                        font.pixelSize: dp(14); color: accent
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "ANZA MCHEZO"
                        font.pixelSize: dp(14); font.bold: true
                        font.letterSpacing: dp(3); color: accent
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed:  { parent.color = Qt.rgba(0,0.9,1,0.22); }
                    onReleased: { parent.color = Qt.rgba(0,0.9,1,0.12); }
                    onClicked:  { startGame(); }
                }
            }

            // ── FUNGA button ──────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: dp(44); radius: dp(14)
                color: "transparent"
                border.color: "#ff4444"; border.width: dp(1)

                Row {
                    anchors.centerIn: parent; spacing: dp(8)
                    //Text { text: "X"; font.pixelSize: dp(13); color: "#ff4444"; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "FUNGA"; font.pixelSize: dp(13); font.bold: true; font.letterSpacing: dp(2); color: "#ff4444"; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed:  { parent.color = "#1a0808"; }
                    onReleased: { parent.color = "transparent"; }
                    onClicked:  { app.close(); }
                }
            }

            // ── BY MAGABE LAB — music beat ────────────────────────────────
            Item {
                id: mgbBrandN
                width: parent.width
                height: dp(54)

                property int beatIdx: 0
                property var beatAmp: [1.0, 0.4, 0.7, 0.3, 1.0, 0.5, 0.0, 0.9, 0.4, 1.0]
                property int activeLetter: -1

                Timer {
                    interval: 90; repeat: true; running: true
                    onTriggered: {
                        mgbBrandN.activeLetter = mgbBrandN.beatIdx;
                        mgbBrandN.beatIdx = (mgbBrandN.beatIdx + 1) % 10;
                    }
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: dp(100); height: dp(1)
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: Qt.rgba(0,0.9,1,0.3) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: dp(2)

                    Rectangle {
                        width: dp(10); height: dp(1); radius: dp(1)
                        color: Qt.rgba(0,1,1,0.25); anchors.verticalCenter: parent.verticalCenter
                    }

                    Repeater {
                        model: ["M","A","G","A","B","E","·","L","A","B"]
                        delegate: Item {
                            id: nLtr
                            property int idx: index
                            property bool isSpace: modelData === "·"
                            property bool active: !isSpace && (mgbBrandN.activeLetter === idx)
                            property real amp: mgbBrandN.beatAmp[idx]
                            width: isSpace ? dp(6) : nTxt.implicitWidth + dp(3)
                            height: dp(38)
                            anchors.verticalCenter: parent.verticalCenter

                            property real lift: active ? -(amp * dp(8)) : 0
                            Behavior on lift { NumberAnimation { duration: 60; easing.type: Easing.OutBack } }

                            Text {
                                id: nTxt
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: nLtr.lift
                                text: modelData
                                font.pixelSize: dp(10)
                                font.bold: true
                                visible: !nLtr.isSpace
                                color: nLtr.active ? Qt.rgba(0,1,0.9,1.0) : Qt.rgba(0,0.75,0.65,0.65)
                                Behavior on color { ColorAnimation { duration: 80 } }
                                scale: nLtr.active ? (1.0 + nLtr.amp * 0.35) : 1.0
                                Behavior on scale { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                            }

                            Rectangle {
                                visible: !nLtr.isSpace
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width - dp(2)
                                height: nLtr.active ? (nLtr.amp * dp(5) + dp(1)) : dp(1)
                                radius: dp(1)
                                color: nLtr.active ? accent : Qt.rgba(0,1,1,0.18)
                                Behavior on height { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                Behavior on color { ColorAnimation { duration: 80 } }
                            }
                        }
                    }

                    Rectangle {
                        width: dp(10); height: dp(1); radius: dp(1)
                        color: Qt.rgba(0,1,1,0.25); anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ── PLAYING SCREEN ───────────────────────────────────────────────────────
    // ─────────────────────────────────────────────────────────────────────────
    Item {
        anchors.fill: parent
        opacity: screen==="playing" ? 1 : 0
        visible: opacity > 0
        enabled: screen==="playing"
        Behavior on opacity { NumberAnimation { duration: 320; easing.type: Easing.InOutQuad } }

        // ── 1. TOPBAR — locked to top ─────────────────────────────────────────
        Rectangle {
            id: topBar
            anchors.top:   parent.top
            anchors.left:  parent.left
            anchors.right: parent.right
            height: dp(52); color: bgCard
            Rectangle { anchors.bottom:parent.bottom; width:parent.width; height:dp(1); color: Qt.rgba(0,0.9,1,0.15) }

            // ── Quit button — pill with icon ─────────────────────────────
            Rectangle {
                id: quitBtn
                anchors.left:           parent.left; anchors.leftMargin: dp(10)
                anchors.verticalCenter: parent.verticalCenter
                width: dp(52); height: dp(28); radius: dp(6)
                color: Qt.rgba(1,0.15,0.15,0.0)
                border.color: Qt.rgba(1,0.25,0.25,0.35)
                border.width: dp(1)
                Behavior on color        { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Row {
                    anchors.centerIn: parent
                    spacing: dp(4)
                    // Left arrow icon ‹‹
                    Text {
                        text: "‹"
                        font.pixelSize: dp(18); font.bold: true
                        color: Qt.rgba(1,0.35,0.35,0.85)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "ACHA"
                        font.pixelSize: dp(9); font.bold: true
                        font.letterSpacing: dp(1)
                        color: Qt.rgba(1,0.35,0.35,0.75)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed:  {
                        quitBtn.color        = Qt.rgba(1,0.15,0.15,0.18);
                        quitBtn.border.color = Qt.rgba(1,0.3,0.3,0.7);
                    }
                    onReleased: {
                        quitBtn.color        = Qt.rgba(1,0.15,0.15,0.0);
                        quitBtn.border.color = Qt.rgba(1,0.25,0.25,0.35);
                    }
                    onClicked: { quitConfirm.visible = true; }
                }
            }

            Text {
                anchors.left:parent.left; anchors.leftMargin:dp(72)
                anchors.verticalCenter:parent.verticalCenter
                text:(wordIndex+1)+" / "+wordList.length; font.pixelSize:dp(13); color:textDim
            }
            Row {
                anchors.centerIn:parent; spacing:dp(6)
                Text { text:"★"; font.pixelSize:dp(16); color:accentYlw }

                Item {
                    width: scoreText.width
                    height: dp(32)

                    Text {
                        id: scoreText
                        anchors.centerIn: parent
                        text: score
                        font.pixelSize:dp(20); font.bold:true; color:textMain

                        // Scale pop when score changes
                        onTextChanged: { scorePop.restart(); }
                        SequentialAnimation {
                            id: scorePop
                            NumberAnimation { target:scoreText; property:"scale"; to:1.4; duration:120; easing.type:Easing.OutBack }
                            NumberAnimation { target:scoreText; property:"scale"; to:1.0; duration:200; easing.type:Easing.InOutQuad }
                        }
                    }

                    // Floating +/- label that flies upward
                    Text {
                        id: floatingPts
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: ptsPositive ? "+"+lastPtsDelta+" pointi" : "−"+lastPtsDelta+" pointi"
                        font.pixelSize: dp(12); font.bold: true
                        color: ptsPositive ? accentGrn : accentRed
                        visible: ptsVisible
                        opacity: ptsVisible ? 1.0 : 0.0
                        y: ptsVisible ? -dp(28) : 0

                        Behavior on opacity { NumberAnimation { duration: 400 } }
                        Behavior on y      { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                    }
                }
            }
            // ── Timer — horizontal bar + number ──────────────────────────────
            Item {
                anchors.right: parent.right; anchors.rightMargin: dp(10)
                anchors.verticalCenter: parent.verticalCenter
                width: dp(64); height: dp(34)

                // Background pill
                Rectangle {
                    anchors.fill: parent
                    radius: dp(8)
                    color: bgInput
                    border.color: timeLeft > 10
                                  ? Qt.rgba(0,0.9,1,0.2)
                                  : Qt.rgba(1,0.2,0.2,0.35)
                    border.width: dp(1)
                    Behavior on border.color { ColorAnimation { duration: 400 } }
                }

                // Drain bar — shrinks left to right as time runs out
                Rectangle {
                    anchors.top:    parent.top;    anchors.topMargin:    dp(1)
                    anchors.bottom: parent.bottom; anchors.bottomMargin: dp(1)
                    anchors.left:   parent.left;   anchors.leftMargin:   dp(1)
                    radius: dp(7)

                    // Width proportional to timeLeft
                    property int maxTime: 10 + currentWord.length * 3
                    width: Math.max(dp(8),
                                    (parent.width - dp(2)) * (timeLeft / Math.max(maxTime, 1)))
                    Behavior on width { NumberAnimation { duration: 900; easing.type: Easing.Linear } }

                    color: timeLeft > 10 ? accent : accentRed
                    opacity: 0.3
                    Behavior on color   { ColorAnimation { duration: 400 } }
                    Behavior on opacity { NumberAnimation { duration: 400 } }
                }

                // Number
                Row {
                    anchors.centerIn: parent
                    spacing: dp(2)

                    Text {
                        text: timeLeft
                        font.pixelSize: dp(14); font.bold: true
                        color: timeLeft > 10 ? accent : accentRed
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 400 } }

                        // Pulse when time is low
                        SequentialAnimation on scale {
                            running: timeLeft <= 5 && timeLeft > 0
                            loops: Animation.Infinite
                            NumberAnimation { to: 1.25; duration: 300; easing.type: Easing.OutQuad }
                            NumberAnimation { to: 1.0;  duration: 300; easing.type: Easing.InQuad }
                        }
                    }
                    Text {
                        text: "s"
                        font.pixelSize: dp(10)
                        color: textDim
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.bottomMargin: dp(1)
                    }
                }
            }
        }

        // ── 2. PROGRESS BAR ───────────────────────────────────────────────────
        Rectangle {
            id: progressBar
            anchors.top:   topBar.bottom
            anchors.left:  parent.left
            anchors.right: parent.right
            height: dp(3); color: Qt.rgba(0,0.9,1,0.08)
            Rectangle {
                width: wordList.length>0 ? parent.width*(wordIndex/wordList.length) : 0
                height: parent.height; color: accent
                Behavior on width { NumberAnimation { duration:400 } }
            }
        }

        // ── 3. KEYBOARD — locked to bottom ────────────────────────────────────
        Item {
            id: keyboard
            anchors.bottom: parent.bottom
            anchors.left:   parent.left
            anchors.right:  parent.right
            height: dp(46)*3 + dp(6)*2 + dp(18)

            // Row 0
            Row {
                id: kbRow0
                anchors.top:              parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: dp(5)
                Repeater {
                    model: ["Q","W","E","R","T","Y","U","I","O","P"]
                    delegate: Rectangle {
                        id: k0
                        width: (sw - dp(12) - dp(5)*9) / 10
                        height: dp(46); radius: dp(6)
                        color: bgCard; border.color: Qt.rgba(0,0.9,1,0.1); border.width: dp(1)
                        transformOrigin: Item.Center
                        Text { anchors.centerIn:parent; text:modelData; font.pixelSize:dp(14); font.bold:true; color:textSec }
                        SequentialAnimation {
                            id: kp0
                            NumberAnimation { target:k0; property:"scale"; to:0.80; duration:55; easing.type:Easing.InQuad }
                            NumberAnimation { target:k0; property:"scale"; to:1.0;  duration:100; easing.type:Easing.OutBack }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked:  { typeLetter(modelData); }
                            onPressed:  { kp0.restart(); k0.color = Qt.rgba(0,0.9,1,0.2); }
                            onReleased: { k0.color = bgCard; }
                        }
                    }
                }
            }

            // Row 1
            Row {
                id: kbRow1
                anchors.top:              kbRow0.bottom; anchors.topMargin: dp(6)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: dp(5)
                Repeater {
                    model: ["A","S","D","F","G","H","J","K","L"]
                    delegate: Rectangle {
                        id: k1
                        width: (sw - dp(12) - dp(5)*9) / 10
                        height: dp(46); radius: dp(6)
                        color: bgCard; border.color: Qt.rgba(0,0.9,1,0.1); border.width: dp(1)
                        transformOrigin: Item.Center
                        Text { anchors.centerIn:parent; text:modelData; font.pixelSize:dp(14); font.bold:true; color:textSec }
                        SequentialAnimation {
                            id: kp1
                            NumberAnimation { target:k1; property:"scale"; to:0.80; duration:55; easing.type:Easing.InQuad }
                            NumberAnimation { target:k1; property:"scale"; to:1.0;  duration:100; easing.type:Easing.OutBack }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked:  { typeLetter(modelData); }
                            onPressed:  { kp1.restart(); k1.color = Qt.rgba(0,0.9,1,0.2); }
                            onReleased: { k1.color = bgCard; }
                        }
                    }
                }
            }

            // Row 2
            Row {
                id: kbRow2
                anchors.top:              kbRow1.bottom; anchors.topMargin: dp(6)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: dp(5)

                // ⌫
                Rectangle {
                    id: bkspKey
                    width: (sw - dp(12) - dp(5)*9) / 10 * 1.55
                    height: dp(46); radius: dp(6)
                    color: bgCard; border.color: Qt.rgba(0,0.9,1,0.1); border.width: dp(1)
                    transformOrigin: Item.Center
                    Text {
                        anchors.centerIn:parent;
                        text: (Qt.platform.os === "android") ? "<" : "⌫"
                        font.pixelSize:dp(14);
                        font.bold:true;
                        color:textMain
                    }
                    SequentialAnimation {
                        id: bkspPop
                        NumberAnimation { target:bkspKey; property:"scale"; to:0.82; duration:60; easing.type:Easing.InQuad }
                        NumberAnimation { target:bkspKey; property:"scale"; to:1.0;  duration:100; easing.type:Easing.OutBack }
                    }
                    MouseArea {
                        anchors.fill:parent
                        onClicked:{ deleteLetter(); }
                        onPressed:{ bkspPop.restart(); bkspKey.color = Qt.rgba(1,0.3,0.3,0.2); }
                        onReleased:{ bkspKey.color = bgCard; }
                    }
                }

                Repeater {
                    model: ["Z","X","C","V","B","N","M"]
                    delegate: Rectangle {
                        id: k2
                        width: (sw - dp(12) - dp(5)*9) / 10
                        height: dp(46); radius: dp(6)
                        color: bgCard; border.color: Qt.rgba(0,0.9,1,0.1); border.width: dp(1)
                        transformOrigin: Item.Center
                        Text { anchors.centerIn:parent; text:modelData; font.pixelSize:dp(14); font.bold:true; color:textSec }
                        SequentialAnimation {
                            id: kp2
                            NumberAnimation { target:k2; property:"scale"; to:0.80; duration:55; easing.type:Easing.InQuad }
                            NumberAnimation { target:k2; property:"scale"; to:1.0;  duration:100; easing.type:Easing.OutBack }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked:  { typeLetter(modelData); }
                            onPressed:  { kp2.restart(); k2.color = Qt.rgba(0,0.9,1,0.2); }
                            onReleased: { k2.color = bgCard; }
                        }
                    }
                }

                // OK
                Rectangle {
                    id: okKey
                    width: (sw - dp(12) - dp(5)*9) / 10 * 1.55
                    height: dp(46); radius: dp(6)
                    color: Qt.rgba(0,0.9,1,0.18); border.color: accent; border.width: dp(1.5)
                    transformOrigin: Item.Center
                    Text { anchors.centerIn:parent; text:"OK"; font.pixelSize:dp(12); font.bold:true; color:accent }
                    SequentialAnimation {
                        id: okPop
                        NumberAnimation { target:okKey; property:"scale"; to:0.82; duration:60; easing.type:Easing.InQuad }
                        NumberAnimation { target:okKey; property:"scale"; to:1.0;  duration:120; easing.type:Easing.OutBack }
                    }
                    MouseArea {
                        anchors.fill:parent
                        onClicked:{ if(roundOver){ wordIndex++; loadWord(); } }
                        onPressed:{ okPop.restart(); okKey.color = Qt.rgba(0,0.9,1,0.3); }
                        onReleased:{ okKey.color = accent; }
                    }
                }
            }
        }

        // ── QUIT CONFIRMATION DIALOG ─────────────────────────────────────────
        Rectangle {
            id: quitConfirm
            anchors.fill: parent
            color: "#CC000000"
            visible: false
            z: 10

            // Backdrop blur effect
            Rectangle {
                anchors.centerIn: parent
                width: dp(280)
                height: dp(220)
                radius: dp(20)
                color: bgDark
                border.color: accent
                border.width: dp(1.5)

                // Cyan glow top bar
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: dp(52)
                    radius: dp(20)
                    color: accent

                    // Square bottom corners only on top bar
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: dp(20)
                        color: accent
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: dp(8)
                        Text {
                            text: "⚠"
                            font.pixelSize: dp(18)
                            color: bgDark
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Acha Mchezo?"
                            font.pixelSize: dp(16)
                            font.bold: true
                            font.letterSpacing: dp(1)
                            color: bgDark
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Score row
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: dp(68)
                    spacing: dp(6)

                    Text {
                        text: "★"
                        font.pixelSize: dp(15)
                        color: accent
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Pointi zako sasa:"
                        font.pixelSize: dp(12)
                        color: textDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: score
                        font.pixelSize: dp(15)
                        font.bold: true
                        color: accent
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Divider
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: dp(100)
                    width: parent.width - dp(40)
                    height: dp(1)
                    color: borderCol
                }

                // Buttons row
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: dp(118)
                    spacing: dp(14)

                    // Endelea button
                    Rectangle {
                        width: dp(110); height: dp(42); radius: dp(10)
                        color: "transparent"
                        border.color: accent; border.width: dp(1.5)

                        Row {
                            anchors.centerIn: parent
                            spacing: dp(5)
                            Text { text: "▶"; font.pixelSize: dp(11); color: accent; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "Endelea"; font.pixelSize: dp(13); font.bold: true; color: accent; anchors.verticalCenter: parent.verticalCenter }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed:  { parent.color = "#0a3333"; }
                            onReleased: { parent.color = "transparent"; }
                            onClicked:  { quitConfirm.visible = false; }
                        }
                    }

                    // Acha button
                    Rectangle {
                        width: dp(110); height: dp(42); radius: dp(10)
                        color: accentRed

                        Row {
                            anchors.centerIn: parent
                            spacing: dp(5)
                            Text { text: "X"; font.pixelSize: dp(12); color: "#ffffff"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "Acha"; font.pixelSize: dp(13); font.bold: true; color: "#ffffff"; anchors.verticalCenter: parent.verticalCenter }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed:  { parent.opacity = 0.75; }
                            onReleased: { parent.opacity = 1.0; }
                            onClicked: {
                                quitConfirm.visible = false;
                                countdownTimer.stop();
                                screen = "results";
                            }
                        }
                    }
                }
            }
        }

        // ── 4. MIDDLE CONTENT — spread across full available space ─────────────
        Item {
            id: middleArea
            anchors.top:    progressBar.bottom
            anchors.bottom: keyboard.top
            anchors.left:   parent.left;  anchors.leftMargin:  dp(12)
            anchors.right:  parent.right; anchors.rightMargin: dp(12)

            // ── Clue card — IQTest style ─────────────────────────────────────
            Rectangle {
                id: clueCard
                anchors.top:   parent.top; anchors.topMargin: dp(10)
                anchors.left:  parent.left
                anchors.right: parent.right
                height: clueCol.height + dp(24)
                radius: dp(14)
                color: bgCard
                border.color: Qt.rgba(0,0.9,1,0.18); border.width: dp(1)
                opacity: 0
                y: 0

                // Slide-in + fade on each new word via clueCardTrigger
                Connections {
                    target: app
                    function onClueCardTriggerChanged() {
                        clueCard.opacity = 0;
                        clueCard.y = -dp(14);
                        ccFade.restart();
                        ccSlide.restart();
                    }
                }
                NumberAnimation on opacity {
                    id: ccFade
                    from: 0; to: 1; duration: 350
                    easing.type: Easing.OutCubic; running: false
                }
                NumberAnimation on y {
                    id: ccSlide
                    from: -dp(14); to: 0; duration: 350
                    easing.type: Easing.OutCubic; running: false
                }

                // Left accent bar
                Rectangle {
                    anchors.left:   parent.left;  anchors.leftMargin:  dp(0)
                    anchors.top:    parent.top;   anchors.topMargin:   dp(10)
                    anchors.bottom: parent.bottom; anchors.bottomMargin: dp(10)
                    width: dp(3); radius: dp(2)
                    color: accent; opacity: 0.9
                }

                Column {
                    id: clueCol
                    anchors.left:   parent.left;  anchors.leftMargin:  dp(16)
                    anchors.right:  parent.right; anchors.rightMargin: dp(12)
                    anchors.top:    parent.top;   anchors.topMargin:   dp(12)
                    spacing: dp(7)

                    // Swahili clue
                    Text {
                        width: parent.width
                        text: screen==="playing" ? currentEntry.sw : ""
                        font.pixelSize: dp(13); color: textSec
                        wrapMode: Text.WordWrap
                        lineHeight: 1.3
                    }

                    // Divider
                    Rectangle {
                        width: parent.width - dp(4); height: dp(1)
                        color: borderCol; opacity: 0.6
                    }

                    // English clue
                    Text {
                        text: screen==="playing" ? currentEntry.en : ""
                        font.pixelSize: dp(12); color: accentYlw
                        font.italic: true; font.bold: false
                    }
                }
            }

            // ── Word tiles ────────────────────────────────────────────────────
            Row {
                id: wordRow
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter:   parent.verticalCenter
                spacing: dp(7)

                Repeater {
                    model: displayModel
                    delegate: Item {
                        property string ch:   model.ch
                        property string kind: model.kind
                        width: dp(46); height: dp(56)

                        // Bounce on "filled" — ukiandika herufi
                        onKindChanged: {
                            if(kind === "filled") { bounceAnim.restart(); }
                        }
                        SequentialAnimation {
                            id: bounceAnim
                            NumberAnimation { target:tileInner; property:"scale"; to:1.2; duration:70; easing.type:Easing.OutBack }
                            NumberAnimation { target:tileInner; property:"scale"; to:1.0; duration:110; easing.type:Easing.InOutQuad }
                        }

                        // Flip-reveal ukijibu sahihi au vibaya
                        onChChanged: {
                            if(kind === "correct" || kind === "wrong") { flipAnim.restart(); }
                        }
                        SequentialAnimation {
                            id: flipAnim
                            NumberAnimation { target:tileInner; property:"scale"; to:0.0; duration:90; easing.type:Easing.InQuad }
                            NumberAnimation { target:tileInner; property:"scale"; to:1.0; duration:180; easing.type:Easing.OutBack }
                        }

                        // Shadow
                        Rectangle {
                            anchors.fill: parent; anchors.topMargin: dp(3)
                            radius: dp(10); color: "#000000"; opacity: 0.3
                        }

                        Rectangle {
                            id: tileInner
                            anchors.fill: parent; anchors.bottomMargin: dp(3)
                            radius: dp(10)
                            transformOrigin: Item.Center

                            property color tileBg: {
                                if(kind==="fixed")  { return bgCard; }
                                if(kind==="correct"){ return accentGrn; }
                                if(kind==="wrong")  { return accentRed; }
                                if(kind==="filled") { return accent; }
                                return bgInput;
                            }
                            property color tileBd: {
                                if(kind==="correct"){ return accentGrn; }
                                if(kind==="wrong")  { return accentRed; }
                                if(kind==="blank"||kind==="filled"){ return accent; }
                                return borderCol;
                            }
                            property color tileTx: {
                                if(kind==="correct"||kind==="wrong"){ return "#ffffff"; }
                                if(kind==="filled"){ return bgDark; }
                                return textMain;
                            }

                            color:        tileBg
                            border.color: tileBd
                            border.width: kind==="blank" ? dp(1.5) : dp(2)
                            Behavior on color        { ColorAnimation { duration: 120 } }
                            Behavior on border.color { ColorAnimation { duration: 120 } }

                            Rectangle {
                                visible: kind==="fixed" || kind==="filled" || kind==="correct"
                                anchors.top: parent.top; anchors.topMargin: dp(1)
                                anchors.left: parent.left; anchors.leftMargin: dp(6)
                                anchors.right: parent.right; anchors.rightMargin: dp(6)
                                height: dp(1); radius: dp(1)
                                color: "#ffffff"; opacity: 0.18
                            }

                            Text {
                                anchors.centerIn: parent
                                text: ch==="_" ? "" : ch
                                font.pixelSize: dp(22); font.bold: true
                                color: parent.tileTx
                            }

                            Rectangle {
                                visible: kind==="blank" && !roundOver
                                anchors.bottom: parent.bottom; anchors.bottomMargin: dp(5)
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: dp(16); height: dp(2); radius: dp(1)
                                color: accent
                                SequentialAnimation on opacity {
                                    running: kind==="blank" && !roundOver
                                    loops: Animation.Infinite
                                    NumberAnimation { to:0; duration:500 }
                                    NumberAnimation { to:1; duration:500 }
                                }
                            }
                        }
                    }
                }
            }

            // ── Result message ────────────────────────────────────────────────
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: wordRow.top; anchors.bottomMargin: dp(10)
                visible: resultMsg !== "" && resultTimer.running
                width: rTxt.width + dp(28); height: dp(32); radius: dp(16)
                color: resultGood ? accentGrn : accentRed

                // Shine
                Rectangle {
                    anchors.top: parent.top; anchors.topMargin: dp(1)
                    anchors.left: parent.left; anchors.leftMargin: dp(12)
                    anchors.right: parent.right; anchors.rightMargin: dp(12)
                    height: dp(1); radius: dp(1); color: "#ffffff"; opacity: 0.3
                }
                Text { id:rTxt; anchors.centerIn:parent; text:resultMsg; font.pixelSize:dp(12); font.bold:true; color:"#ffffff" }
            }

            // ── Hint button ───────────────────────────────────────────────────
            Rectangle {
                anchors.bottom: parent.bottom; anchors.bottomMargin: dp(10)
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !roundOver && !hintUsed
                width: dp(190); height: dp(38); radius: dp(19)
                color: "transparent"
                border.color: Qt.rgba(0,0.7,0.8,0.5); border.width: dp(1.5)
                Row {
                    anchors.centerIn: parent; spacing: dp(6)
                    Text { text:"💡"; font.pixelSize:dp(13) }
                    Text {
                        text: "Nisaidie (−"+Math.round(100/roundCount)+" pointi)"
                        font.pixelSize:dp(12); font.bold:true; color:hintColor
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed:  { parent.color = Qt.rgba(0,0.7,0.8,0.1); }
                    onReleased: { parent.color = "transparent"; }
                    onClicked:  { revealAnswer(true); }
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ── RESULTS SCREEN ───────────────────────────────────────────────────────
    // ─────────────────────────────────────────────────────────────────────────
    NumberAnimation {
        id: scoreCountUp
        target: app; property: "displayScore"
        from: 0; duration: 1200
        easing.type: Easing.OutCubic
        running: false
    }

    Item {
        anchors.fill: parent
        opacity: screen==="results" ? 1 : 0
        visible: opacity > 0
        enabled: screen==="results"
        Behavior on opacity { NumberAnimation { duration: 320; easing.type: Easing.InOutQuad } }
        onEnabledChanged: {
            if(enabled){
                displayScore = 0;
                scoreCountUp.to = score;
                scoreCountUp.restart();
                // Confetti ukifanya vizuri (score >= 65)
                if(score >= 65){
                    confettiCanvas.particles = [];
                    confettiCanvas.spawnAll();
                    confettiCanvas.visible = true;
                    confettiTimer.restart();
                } else {
                    confettiCanvas.visible = false;
                }
            }
        }

        // ── Confetti canvas ───────────────────────────────────────────────
        Canvas {
            id: confettiCanvas
            anchors.fill: parent
            z: 10
            visible: false
            property var particles: []

            // Rangi 8 za confetti — za sherehe
            property var colors: [
                "#00e5ff","#ffffff","#22c55e","#ffd700",
                "#ff6b6b","#a78bfa","#fb923c","#34d399"
            ]

            function spawnAll() {
                particles = [];
                var count = 120;
                for(var i = 0; i < count; i++){
                    particles.push({
                                       x:      Math.random() * width,
                                       y:      -Math.random() * height * 0.5,   // inaanza juu
                                       vx:     (Math.random() - 0.5) * dp(4),
                                       vy:     dp(2) + Math.random() * dp(4),
                                       rot:    Math.random() * 360,
                                       vrot:   (Math.random() - 0.5) * 8,
                                       w:      dp(7) + Math.random() * dp(6),
                                       h:      dp(4) + Math.random() * dp(3),
                                       color:  colors[Math.floor(Math.random() * colors.length)],
                                       alpha:  1.0,
                                       life:   1.0   // 1.0 → 0.0
                                   });
                }
                requestPaint();
            }

            function step() {
                var alive = false;
                for(var i = 0; i < particles.length; i++){
                    var p = particles[i];
                    p.x   += p.vx;
                    p.y   += p.vy;
                    p.vy  += dp(0.12);          // gravity
                    p.rot += p.vrot;
                    p.life -= 0.007;
                    p.alpha = Math.max(0, p.life);
                    if(p.life > 0) alive = true;
                }
                if(!alive){ confettiCanvas.visible = false; confettiTimer.stop(); }
                requestPaint();
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                for(var i = 0; i < particles.length; i++){
                    var p = particles[i];
                    if(p.alpha <= 0) continue;
                    ctx.save();
                    ctx.globalAlpha = p.alpha;
                    ctx.translate(p.x + p.w/2, p.y + p.h/2);
                    ctx.rotate(p.rot * Math.PI / 180);
                    ctx.fillStyle = p.color;
                    ctx.fillRect(-p.w/2, -p.h/2, p.w, p.h);
                    ctx.restore();
                }
            }
        }

        Timer {
            id: confettiTimer
            interval: 16    // ~60fps
            repeat: true
            running: false
            onTriggered: confettiCanvas.step()
        }

        Column {
            anchors.centerIn: parent
            width: parent.width * 0.82
            spacing: dp(20)

            // ── Header ────────────────────────────────────────────────────
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "MCHEZO UMEKWISHA!"
                font.pixelSize: dp(22); font.bold: true
                font.letterSpacing: dp(4); color: accent
            }

            // ── Score card ────────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: dp(110); radius: dp(16)
                color: bgCard
                border.color: Qt.rgba(0,0.9,1,0.18); border.width: dp(1)

                Column {
                    anchors.centerIn: parent; spacing: dp(6)
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Pointi Zako"
                        font.pixelSize: dp(13); color: textDim
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: dp(8)
                        Text {
                            text: "★"; font.pixelSize: dp(32); color: accent
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: score; font.pixelSize: dp(52); font.bold: true
                            color: textMain
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "/ 100"; font.pixelSize: dp(16); color: textDim
                            anchors.bottom: parent.bottom; anchors.bottomMargin: dp(10)
                        }
                    }
                }
            }

            // ── Grade ─────────────────────────────────────────────────────
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: score>=85 ? "🏆 Bora Sana!" : score>=65 ? "👏 Vizuri!" : score>=40 ? "💪 Jaribu Tena!" : "📚 Endelea Kujifunza!"
                font.pixelSize: dp(18); font.bold: true; color: textMain
                opacity: 0
                NumberAnimation on opacity {
                    id: gradeFadeIn
                    from: 0; to: 1; duration: 600
                    easing.type: Easing.OutCubic; running: false
                }
                NumberAnimation on font.pixelSize {
                    id: gradeGrow
                    from: dp(10); to: dp(18); duration: 600
                    easing.type: Easing.OutBack; running: false
                }
                Timer {
                    interval: 900; running: screen==="results"
                    onTriggered: { gradeFadeIn.restart(); gradeGrow.restart(); }
                }
            }

            // ── CHEZA TENA ────────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: dp(52); radius: dp(12)
                color: Qt.rgba(0,0.9,1,0.12)
                border.color: accent; border.width: dp(1.5)

                Row {
                    anchors.centerIn: parent; spacing: dp(10)
                    Text { text:"▶"; font.pixelSize:dp(14); color:accent; anchors.verticalCenter:parent.verticalCenter }
                    Text { text:"CHEZA TENA"; font.pixelSize:dp(16); font.bold:true; font.letterSpacing:dp(3); color:accent; anchors.verticalCenter:parent.verticalCenter }
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed:  { parent.color = Qt.rgba(0,0.9,1,0.22); }
                    onReleased: { parent.color = Qt.rgba(0,0.9,1,0.12); }
                    onClicked:  { startGame(); }
                }
            }

            // ── FUNGA ─────────────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: dp(44); radius: dp(12)
                color: "transparent"
                border.color: accentRed; border.width: dp(1.5)
                Row {
                    anchors.centerIn: parent; spacing: dp(8)
                    //Text { text:"X"; font.pixelSize:dp(14); font.bold:true; color:accentRed; anchors.verticalCenter:parent.verticalCenter }
                    Text { text:"FUNGA"; font.pixelSize:dp(14); font.bold:true; font.letterSpacing:dp(2); color:accentRed; anchors.verticalCenter:parent.verticalCenter }
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed:  { parent.color = "#1a0000"; }
                    onReleased: { parent.color = "transparent"; }
                    onClicked:  { app.close(); }
                }
            }

            // ── MAGABE LAB branding — music beat ──────────────────────────
            Item {
                id: mgbBrandR
                width: parent.width
                height: dp(54)

                property int beatIdx: 0
                property var beatAmp: [1.0, 0.4, 0.7, 0.3, 1.0, 0.5, 0.0, 0.9, 0.4, 1.0]
                property int activeLetter: -1

                Timer {
                    interval: 90; repeat: true; running: screen === "results"
                    onTriggered: {
                        mgbBrandR.activeLetter = mgbBrandR.beatIdx;
                        mgbBrandR.beatIdx = (mgbBrandR.beatIdx + 1) % 10;
                    }
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: dp(100); height: dp(1)
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: Qt.rgba(0,0.9,1,0.3) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: dp(2)

                    Rectangle {
                        width: dp(10); height: dp(1); radius: dp(1)
                        color: Qt.rgba(0,1,1,0.25); anchors.verticalCenter: parent.verticalCenter
                    }

                    Repeater {
                        model: ["M","A","G","A","B","E","·","L","A","B"]
                        delegate: Item {
                            id: rLtr
                            property int idx: index
                            property bool isSpace: modelData === "·"
                            property bool active: !isSpace && (mgbBrandR.activeLetter === idx)
                            property real amp: mgbBrandR.beatAmp[idx]
                            width: isSpace ? dp(6) : rTxt.implicitWidth + dp(3)
                            height: dp(38)
                            anchors.verticalCenter: parent.verticalCenter

                            property real lift: active ? -(amp * dp(8)) : 0
                            Behavior on lift { NumberAnimation { duration: 60; easing.type: Easing.OutBack } }

                            Text {
                                id: rTxt
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: rLtr.lift
                                text: modelData
                                font.pixelSize: dp(10)
                                font.bold: true
                                visible: !rLtr.isSpace
                                color: rLtr.active ? Qt.rgba(0,1,0.9,1.0) : Qt.rgba(0,0.75,0.65,0.65)
                                Behavior on color { ColorAnimation { duration: 80 } }
                                scale: rLtr.active ? (1.0 + rLtr.amp * 0.35) : 1.0
                                Behavior on scale { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                            }

                            Rectangle {
                                visible: !rLtr.isSpace
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width - dp(2)
                                height: rLtr.active ? (rLtr.amp * dp(5) + dp(1)) : dp(1)
                                radius: dp(1)
                                color: rLtr.active ? accent : Qt.rgba(0,1,1,0.18)
                                Behavior on height { NumberAnimation { duration: 70; easing.type: Easing.OutBack } }
                                Behavior on color { ColorAnimation { duration: 80 } }
                            }
                        }
                    }

                    Rectangle {
                        width: dp(10); height: dp(1); radius: dp(1)
                        color: Qt.rgba(0,1,1,0.25); anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
