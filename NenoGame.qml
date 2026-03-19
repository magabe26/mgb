import QtQuick 2.14
import QtQuick.Controls 2.14

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

    // ── Palette ───────────────────────────────────────────────────────────────
    readonly property color bgDark:    "#0d1117"
    readonly property color bgCard:    "#161b22"
    readonly property color bgInput:   "#1c2128"
    readonly property color accent:    "#58a6ff"
    readonly property color accentGrn: "#3fb950"
    readonly property color accentYlw: "#d29922"
    readonly property color accentRed: "#f85149"
    readonly property color borderCol: "#30363d"
    readonly property color textMain:  "#e6edf3"
    readonly property color textDim:   "#8b949e"
    readonly property color hintColor: "#ffa657"
    color: bgDark

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
        {w:"JANA",sw:"Siku iliyopita",en:"Yesterday"}
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
        {w:"NYUMA",sw:"Kinyume cha mbele",en:"Behind"}
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
        {w:"MSAADA",sw:"Kusaidia mtu",en:"Help"}
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
        {w:"SIKUKUU",sw:"Siku maalum ya sherehe ya kitaifa",en:"Public holiday"}
    ]

    // ── Settings ──────────────────────────────────────────────────────────────
    property string screen:        "setup"
    property int    roundCount:    10
    property var    lengthChoices: [4,5,6,7]  // zote zimechaguliwa

    // ── Game state ────────────────────────────────────────────────────────────
    property var    wordList:     []
    property int    wordIndex:    0
    property var    currentEntry: ({w:"",sw:"",en:""})
    property string currentWord:  ""
    property string hiddenWord:   ""
    property int    score:        0

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
        return shuffle(all).slice(0, Math.min(roundCount, all.length));
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
        screen="playing"; loadWord();
    }

    function loadWord() {
        if(wordIndex>=wordList.length){ screen="results"; countdownTimer.stop(); return; }
        currentEntry=wordList[wordIndex];
        currentWord=currentEntry.w;
        hiddenWord=makeHidden(currentWord);
        filled=[]; hintUsed=false; roundOver=false;
        timeLeft=10+currentWord.length*3;
        countdownTimer.restart();
        displayModel.rebuild();
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
        visible: screen==="setup"

        Column {
            anchors.centerIn: parent
            width: parent.width * 0.85
            spacing: dp(22)

            Column {
                width: parent.width; spacing: dp(4)
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"NENO"; font.pixelSize:dp(48); font.bold:true
                    font.letterSpacing:dp(12); color:accent
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"Jaza nafasi — Pata pointi"
                    font.pixelSize:dp(13); color:textDim
                }
            }

            Column {
                width: parent.width; spacing: dp(10)
                Text { text:"Maneno kwa kila mchezo"; font.pixelSize:dp(13); font.bold:true; color:textDim }
                Row {
                    spacing: dp(8)
                    Repeater {
                        model: [5,10,15,20]
                        delegate: Rectangle {
                            property bool sel: roundCount===modelData
                            width:dp(62); height:dp(44); radius:dp(8)
                            color:sel?accent:bgCard
                            border.color:sel?accent:borderCol; border.width:dp(1.5)
                            Text { anchors.centerIn:parent; text:modelData; font.pixelSize:dp(18); font.bold:true; color:sel?bgDark:textMain }
                            MouseArea { anchors.fill:parent; onClicked:{ roundCount=modelData; } }
                        }
                    }
                }
            }



            Rectangle {
                width: parent.width; height:dp(52); radius:dp(12)
                color: accent
                Text { anchors.centerIn:parent; text:"ANZA MCHEZO"; font.pixelSize:dp(16); font.bold:true; font.letterSpacing:dp(3); color:bgDark }
                MouseArea { anchors.fill:parent; onClicked:{ startGame(); } }
            }

            // Funga button
            Rectangle {
                width: parent.width; height:dp(44); radius:dp(12)
                color: "transparent"
                border.color: accentRed; border.width: dp(1.5)
                Row {
                    anchors.centerIn: parent
                    spacing: dp(8)
                    Text { text:"X"; font.pixelSize:dp(14); font.bold:true; color:accentRed; anchors.verticalCenter:parent.verticalCenter }
                    Text { text:"FUNGA"; font.pixelSize:dp(14); font.bold:true; font.letterSpacing:dp(2); color:accentRed; anchors.verticalCenter:parent.verticalCenter }
                }
                MouseArea { anchors.fill:parent; onClicked:{ app.close(); } }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ── PLAYING SCREEN ───────────────────────────────────────────────────────
    // ─────────────────────────────────────────────────────────────────────────
    Item {
        anchors.fill: parent
        visible: screen==="playing"

        // ── 1. TOPBAR — locked to top ─────────────────────────────────────────
        Rectangle {
            id: topBar
            anchors.top:   parent.top
            anchors.left:  parent.left
            anchors.right: parent.right
            height: dp(52); color: bgCard
            Rectangle { anchors.bottom:parent.bottom; width:parent.width; height:dp(1); color:borderCol }

            // Quit button
            Rectangle {
                anchors.left:            parent.left; anchors.leftMargin: dp(12)
                anchors.verticalCenter:  parent.verticalCenter
                width: dp(32); height: dp(32); radius: dp(16)
                color: "transparent"
                border.color: accentRed; border.width: dp(1.5)
                Text { anchors.centerIn:parent; text:"X"; font.pixelSize:dp(14); font.bold:true; color:accentRed }
                MouseArea {
                    anchors.fill: parent
                    onClicked: { quitConfirm.visible = true; }
                }
            }

            Text {
                anchors.left:parent.left; anchors.leftMargin:dp(56)
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
            Item {
                anchors.right:parent.right; anchors.rightMargin:dp(16)
                anchors.verticalCenter:parent.verticalCenter
                width:dp(36); height:dp(36)
                Rectangle {
                    anchors.fill:parent; radius:dp(18); color:"transparent"
                    border.color:timeLeft>10?accentGrn:accentRed; border.width:dp(2)
                }
                Text { anchors.centerIn:parent; text:timeLeft; font.pixelSize:dp(13); font.bold:true; color:timeLeft>10?accentGrn:accentRed }
            }
        }

        // ── 2. PROGRESS BAR ───────────────────────────────────────────────────
        Rectangle {
            id: progressBar
            anchors.top:   topBar.bottom
            anchors.left:  parent.left
            anchors.right: parent.right
            height: dp(3); color: borderCol
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
                        width: (sw - dp(12) - dp(5)*9) / 10
                        height: dp(46); radius: dp(6)
                        color: bgCard; border.color: borderCol; border.width: dp(1)
                        Text { anchors.centerIn:parent; text:modelData; font.pixelSize:dp(14); font.bold:true; color:textMain }
                        MouseArea { anchors.fill:parent; onClicked:{ typeLetter(modelData); } onPressed:{ parent.opacity=0.6; } onReleased:{ parent.opacity=1.0; } }
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
                        width: (sw - dp(12) - dp(5)*9) / 10
                        height: dp(46); radius: dp(6)
                        color: bgCard; border.color: borderCol; border.width: dp(1)
                        Text { anchors.centerIn:parent; text:modelData; font.pixelSize:dp(14); font.bold:true; color:textMain }
                        MouseArea { anchors.fill:parent; onClicked:{ typeLetter(modelData); } onPressed:{ parent.opacity=0.6; } onReleased:{ parent.opacity=1.0; } }
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
                    width: (sw - dp(12) - dp(5)*9) / 10 * 1.55
                    height: dp(46); radius: dp(6)
                    color: bgCard; border.color: borderCol; border.width: dp(1)
                    Text { anchors.centerIn:parent; text:"⌫"; font.pixelSize:dp(14); font.bold:true; color:textMain }
                    MouseArea { anchors.fill:parent; onClicked:{ deleteLetter(); } onPressed:{ parent.opacity=0.6; } onReleased:{ parent.opacity=1.0; } }
                }

                Repeater {
                    model: ["Z","X","C","V","B","N","M"]
                    delegate: Rectangle {
                        width: (sw - dp(12) - dp(5)*9) / 10
                        height: dp(46); radius: dp(6)
                        color: bgCard; border.color: borderCol; border.width: dp(1)
                        Text { anchors.centerIn:parent; text:modelData; font.pixelSize:dp(14); font.bold:true; color:textMain }
                        MouseArea { anchors.fill:parent; onClicked:{ typeLetter(modelData); } onPressed:{ parent.opacity=0.6; } onReleased:{ parent.opacity=1.0; } }
                    }
                }

                // OK
                Rectangle {
                    width: (sw - dp(12) - dp(5)*9) / 10 * 1.55
                    height: dp(46); radius: dp(6)
                    color: accent; border.color: borderCol; border.width: dp(1)
                    Text { anchors.centerIn:parent; text:"OK"; font.pixelSize:dp(12); font.bold:true; color:bgDark }
                    MouseArea {
                        anchors.fill:parent
                        onClicked:{ if(roundOver){ wordIndex++; loadWord(); } }
                        onPressed:{ parent.opacity=0.6; }
                        onReleased:{ parent.opacity=1.0; }
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

            Rectangle {
                anchors.centerIn: parent
                width: dp(260); height: dp(160); radius: dp(16)
                color: bgCard; border.color: borderCol; border.width: dp(1)

                Column {
                    anchors.centerIn: parent
                    spacing: dp(16)
                    width: parent.width - dp(40)

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Acha mchezo?"
                        font.pixelSize: dp(16); font.bold: true; color: textMain
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Pointi zako: " + score
                        font.pixelSize: dp(13); color: textDim
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: dp(12)

                        // Endelea
                        Rectangle {
                            width: dp(100); height: dp(38); radius: dp(8)
                            color: bgInput; border.color: borderCol; border.width: dp(1)
                            Text { anchors.centerIn:parent; text:"Endelea"; font.pixelSize:dp(13); font.bold:true; color:textMain }
                            MouseArea { anchors.fill:parent; onClicked:{ quitConfirm.visible=false; } }
                        }

                        // Acha
                        Rectangle {
                            width: dp(100); height: dp(38); radius: dp(8)
                            color: accentRed
                            Text { anchors.centerIn:parent; text:"Acha"; font.pixelSize:dp(13); font.bold:true; color:"#ffffff" }
                            MouseArea {
                                anchors.fill:parent
                                onClicked:{
                                    quitConfirm.visible=false;
                                    countdownTimer.stop();
                                    screen="results";
                                }
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
            anchors.left:   parent.left;  anchors.leftMargin:  dp(14)
            anchors.right:  parent.right; anchors.rightMargin: dp(14)

            // Clue card — pinned to top of middle area
            Rectangle {
                id: clueCard
                anchors.top:   parent.top; anchors.topMargin: dp(12)
                anchors.left:  parent.left
                anchors.right: parent.right
                height: clueCol.height + dp(20)
                radius: dp(10); color: bgCard
                border.color: borderCol; border.width: dp(1)

                Column {
                    id: clueCol
                    anchors.left:   parent.left;  anchors.leftMargin:  dp(14)
                    anchors.right:  parent.right; anchors.rightMargin: dp(14)
                    anchors.top:    parent.top;   anchors.topMargin:   dp(10)
                    spacing: dp(6)
                    Row {
                        spacing: dp(6)
                        Text { text:"🔵"; font.pixelSize:dp(13) }
                        Text {
                            width: clueCol.width - dp(28)
                            text: screen==="playing" ? currentEntry.sw : ""
                            font.pixelSize:dp(14); color:textMain
                            wrapMode: Text.WordWrap
                        }
                    }
                    Row {
                        spacing: dp(6)
                        Text { text:"🟡"; font.pixelSize:dp(13) }
                        Text {
                            text: screen==="playing" ? currentEntry.en : ""
                            font.pixelSize:dp(13); color:accentYlw; font.italic:true
                        }
                    }
                }
            }

            // Word tiles — centred vertically in remaining space
            Row {
                id: wordRow
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter:   parent.verticalCenter
                spacing: dp(6)

                Repeater {
                    model: displayModel
                    delegate: Rectangle {
                        property string ch:   model.ch
                        property string kind: model.kind
                        property color tileBg: {
                            if(kind==="fixed")  { return bgCard; }
                            if(kind==="correct"){ return accentGrn; }
                            if(kind==="wrong")  { return accentRed; }
                            if(kind==="filled") { return accent; }
                            return bgInput;
                        }
                        property color tileBd: (kind==="blank"||kind==="filled") ? accent : borderCol
                        property color tileTx: {
                            if(kind==="correct"||kind==="wrong"){ return "#ffffff"; }
                            if(kind==="filled"){ return bgDark; }
                            return textMain;
                        }
                        width:dp(46); height:dp(54); radius:dp(8)
                        color:        tileBg
                        border.color: tileBd
                        border.width: dp(2)
                        Text {
                            anchors.centerIn:parent; text:ch==="_"?"":ch
                            font.pixelSize:dp(22); font.bold:true; color:tileTx
                        }
                        Rectangle {
                            visible: kind==="blank"&&!roundOver
                            anchors.bottom:parent.bottom; anchors.bottomMargin:dp(6)
                            anchors.horizontalCenter:parent.horizontalCenter
                            width:dp(14); height:dp(2); radius:dp(1); color:accent
                            SequentialAnimation on opacity {
                                running: kind==="blank"&&!roundOver; loops:Animation.Infinite
                                NumberAnimation{to:0;duration:500}
                                NumberAnimation{to:1;duration:500}
                            }
                        }
                    }
                }
            }

            // Result message — just above word tiles
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: wordRow.top; anchors.bottomMargin: dp(10)
                visible: resultMsg!==""&&resultTimer.running
                width: rTxt.width+dp(24); height:dp(30); radius:dp(15)
                color: resultGood?accentGrn:accentRed
                Text { id:rTxt; anchors.centerIn:parent; text:resultMsg; font.pixelSize:dp(12); font.bold:true; color:"#ffffff" }
            }

            // Hint button — pinned to bottom of middle area
            Rectangle {
                anchors.bottom: parent.bottom; anchors.bottomMargin: dp(12)
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !roundOver&&!hintUsed
                width:dp(180); height:dp(40); radius:dp(20)
                color:"transparent"; border.color:hintColor; border.width:dp(1.5)
                Row {
                    anchors.centerIn:parent; spacing:dp(6)
                    Text { text:"💡"; font.pixelSize:dp(14) }
                    Text { text:"Nisaidie (−"+Math.round(100/roundCount)+" pointi)"; font.pixelSize:dp(12); font.bold:true; color:hintColor }
                }
                MouseArea { anchors.fill:parent; onClicked:{ revealAnswer(true); } }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ── RESULTS SCREEN ───────────────────────────────────────────────────────
    // ─────────────────────────────────────────────────────────────────────────
    Item {
        anchors.fill: parent
        visible: screen==="results"

        Column {
            anchors.centerIn: parent
            width: parent.width*0.82
            spacing: dp(20)

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text:"MCHEZO UMEKWISHA!"
                font.pixelSize:dp(22); font.bold:true; font.letterSpacing:dp(4); color:accent
            }

            Rectangle {
                width: parent.width; height:dp(110); radius:dp(16)
                color:bgCard; border.color:borderCol; border.width:dp(1)
                Column {
                    anchors.centerIn:parent; spacing:dp(6)
                    Text { anchors.horizontalCenter:parent.horizontalCenter; text:"Pointi Zako"; font.pixelSize:dp(13); color:textDim }
                    Row {
                        anchors.horizontalCenter:parent.horizontalCenter; spacing:dp(8)
                        Text { text:"★"; font.pixelSize:dp(32); color:accentYlw }
                        Text { text:score; font.pixelSize:dp(52); font.bold:true; color:textMain }
                        Text { text:"/ 100"; font.pixelSize:dp(16); color:textDim; anchors.bottom:parent.bottom; anchors.bottomMargin:dp(10) }
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: score>=85 ? "🏆 Bora Sana!" : score>=65 ? "👏 Vizuri!" : score>=40 ? "💪 Jaribu Tena!" : "📚 Endelea Kujifunza!"
                font.pixelSize:dp(18); font.bold:true; color:textMain
            }

            Rectangle {
                width: parent.width; height:dp(52); radius:dp(12); color:accent
                Text { anchors.centerIn:parent; text:"CHEZA TENA"; font.pixelSize:dp(16); font.bold:true; font.letterSpacing:dp(3); color:bgDark }
                MouseArea { anchors.fill:parent; onClicked:{ screen="setup"; } }
            }

            Rectangle {
                width: parent.width; height:dp(44); radius:dp(12)
                color: "transparent"
                border.color: accentRed; border.width: dp(1.5)
                Row {
                    anchors.centerIn: parent; spacing: dp(8)
                    Text { text:"X"; font.pixelSize:dp(14); font.bold:true; color:accentRed; anchors.verticalCenter:parent.verticalCenter }
                    Text { text:"FUNGA"; font.pixelSize:dp(14); font.bold:true; font.letterSpacing:dp(2); color:accentRed; anchors.verticalCenter:parent.verticalCenter }
                }
                MouseArea { anchors.fill:parent; onClicked:{ app.close(); } }
            }
        }
    }
}
