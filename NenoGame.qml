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
        {w:"KOBO",sw:"Sarafu ndogo — hata ukikusanya nyingi zinakuwa kidogo",en:"Small coin"},
        {w:"POVO",sw:"Hali ya kukosa hata mahitaji ya msingi",en:"Poverty"},
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
        {w:"BOGI",sw:"Sanduku zito la treni linalotumiwa kubeba abiria",en:"Train carriage"},
        {w:"GEGO",sw:"Meno mazito ya nyuma — yanasaga chakula kigumu",en:"Molar"},
        {w:"WAVI",sw:"Wavuvi wanaotumia hiki baharini",en:"Net (fishing)"},
        {w:"PAGO",sw:"Malipo ya fidia — unalipa ukikosea",en:"Payment/Fine"},
        {w:"KOPO",sw:"Chombo cha chuma kilichofungwa — unakishangilia ukifungua",en:"Tin can"},
        {w:"JIPU",sw:"Uvimbe wenye siri ndani unauma ukiguswa kidogo tu",en:"Abscess/Boil"},
        {w:"BOGA",sw:"Mboga ya mviringo unayokata haikuumia wala kulia",en:"Pumpkin/Gourd"},
        {w:"PORI",sw:"Mahali binadamu hawaiishi wanyama wanamiliki kila kitu",en:"Wilderness"},
        {w:"TUTA",sw:"Kilima kidogo cha ardhi si mlima wala bonde kabisa",en:"Mound"},
        {w:"MELE",sw:"Kelele nyingi amani inakimbia bila kuagana",en:"Noise/Uproar"},
        {w:"GOGO",sw:"Shina la mti lililowekwa chini bado lina nguvu ndani",en:"Log/Trunk"},
        {w:"LELE",sw:"Wimbo wa kulaza mtoto upole wake ni wa kipekee duniani",en:"Lullaby"},
        {w:"BUSU",sw:"Onyesho la upendo kwa midomo hakuna bei yake",en:"Kiss"},
        {w:"LOGO",sw:"Alama inayotambulisha kampuni kidogo lakini inabeba mengi",en:"Logo/Symbol"},
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
        {w:"IMRIKA",sw:"Kujaza kwa nguvu — kufurika hadi kutoka nje ya chombo",en:"To overflow/be full"},
        {w:"JARIBU",sw:"Kujaribu kitu kipya bila kujua matokeo yake kabla yake",en:"To try/attempt"},
        {w:"KATIKA",sw:"Ndani ya sehemu fulani — au kwa wakati fulani maalum",en:"In/Within/During"},
        {w:"LAZIMA",sw:"Hakuna jinsi nyingine — ni wajibu usioepukika kamwe",en:"Must/Necessary/Obligatory"}
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
                    Text { text: "X"; font.pixelSize: dp(13); color: "#ff4444"; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "FUNGA"; font.pixelSize: dp(13); font.bold: true; font.letterSpacing: dp(2); color: "#ff4444"; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed:  { parent.color = "#1a0808"; }
                    onReleased: { parent.color = "transparent"; }
                    onClicked:  { app.close(); }
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
            }
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
                    Text { text:"X"; font.pixelSize:dp(14); font.bold:true; color:accentRed; anchors.verticalCenter:parent.verticalCenter }
                    Text { text:"FUNGA"; font.pixelSize:dp(14); font.bold:true; font.letterSpacing:dp(2); color:accentRed; anchors.verticalCenter:parent.verticalCenter }
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed:  { parent.color = "#1a0000"; }
                    onReleased: { parent.color = "transparent"; }
                    onClicked:  { app.close(); }
                }
            }
        }
    }
}
