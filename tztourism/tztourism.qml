import QtQuick 2.14
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Shapes 1.14

Rectangle {
    id: app
    width: parent.width
    height: parent.height
    color: "transparent"

    property string selectedLanguage: "" // "en" or "sw"
    property int currentAttractionIndex: 0
    property int appMode: 2

    

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
            desc_en: "An island sanctuary on Lake Victoria, home to elephats, chimpanzees, sitatunga, and a diverse birdlife, ideal for walking safaris."
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

    onSelectedLanguageChanged: {
        if (selectedLanguage !== "") {
            if(app.appMode === 1){
                viewComponentLoader.sourceComponent = attractionViewComponent1;
            } else if(app.appMode === 2){
                viewComponentLoader.sourceComponent = attractionViewComponent2;
            }
        }
    }

    Loader {
        id: viewComponentLoader
        anchors.fill: parent
        sourceComponent: languageSelectionComponent
    }

    Dialog {
        id: modeSelectionDialog
        property string lag
        property real dialogWidth: app.width * 0.6
        property color btnColor: "#003333"
        property string btn1Text
        property string btn2Text
        property string btnCloseText

        contentItem: Rectangle {
            color: "#001413"
            border.color: "cyan"
            border.width: 1
            implicitWidth: modeSelectionDialog.dialogWidth
            implicitHeight: dialogTitle.paintedHeight + dialogTitle.anchors.topMargin + btn1.height + btn1.anchors.topMargin + btn2.height + btn2.anchors.topMargin + btnClose.height +  btnClose.anchors.topMargin + btnClose.anchors.bottomMargin;

            Text {
                id: dialogTitle
                anchors.top: parent.top
                anchors.topMargin: 4
                color: "cyan"
                font.pointSize: Qt.platform.os === "android" ? 14 : 12
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Button {
                id: btn1
                anchors.top: dialogTitle.bottom
                anchors.topMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                text: modeSelectionDialog.btn1Text
                font.pointSize: Qt.platform.os === "android" ? 14 : 12
                background: Rectangle {
                    implicitWidth: modeSelectionDialog.dialogWidth * 0.8
                    implicitHeight: 40
                    color: modeSelectionDialog.btnColor
                    radius: 5
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    modeSelectionDialog.setMode1();
                }

            }


            Button {
                id: btn2
                anchors.top: btn1.bottom
                anchors.topMargin: 12
                anchors.horizontalCenter: parent.horizontalCenter
                text: modeSelectionDialog.btn2Text
                font.pointSize: Qt.platform.os === "android" ? 14 : 12

                background: Rectangle {
                    implicitWidth: modeSelectionDialog.dialogWidth * 0.8
                    implicitHeight: 40
                    color: modeSelectionDialog.btnColor
                    radius: 5
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    modeSelectionDialog.setMode2();
                }
            }

            Button {
                id: btnClose
                anchors.top: btn2.bottom
                anchors.topMargin: 12
                anchors.bottomMargin: 18
                anchors.horizontalCenter: parent.horizontalCenter
                text: modeSelectionDialog.btnCloseText
                font.pointSize: Qt.platform.os === "android" ? 14 : 12

                background: Rectangle {
                    implicitWidth: modeSelectionDialog.dialogWidth * 0.8
                    implicitHeight: 40
                    color: "red"
                    radius: 5
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    modeSelectionDialog.close();
                }
            }

        }

        function doOpen(lag,btnColor){
            modeSelectionDialog.lag = lag;
            modeSelectionDialog.btnColor = btnColor;
            dialogTitle.text = lag === "sw" ? "Chagua mpangilio" : "Select layout";
            modeSelectionDialog.btn1Text = lag === "sw" ? "Kawaida" : "Default";
            modeSelectionDialog.btn2Text = lag === "sw" ? "Orodha" : "List";
            modeSelectionDialog.btnCloseText = lag === "sw" ? "Funga" : "Close";
            open();
        }

        function setMode1(){
            app.appMode = 1;
            close();
            app.selectedLanguage = modeSelectionDialog.lag;
        }

        function setMode2(){
            app.appMode = 2;
            close();
            app.selectedLanguage = modeSelectionDialog.lag;

if(app.selectedLanguage === "sw"){
   app.showToastMessage("Bonyeza mara mbili -> Kurudi nyuma");
} else {
   app.showToastMessage("Double click -> To go back");
}

        }


    }



Dialog {
	id: contextMenu
	property real dialogWidth: app.width * 0.6
	property string frontPageBtnText
	property string closeAppBtnText
	property color frontPageBtnColor: "blue"

	contentItem: Rectangle {
		color: "#001413"
		border.color: "cyan"
		border.width: 1
		implicitWidth: modeSelectionDialog.dialogWidth
		implicitHeight: frontPageBtn.height + frontPageBtn.anchors.topMargin + closeAppBtn.height + closeAppBtn.anchors.topMargin + closeAppBtn.anchors.bottomMargin;

		Button {
			id: frontPageBtn
			anchors.top: parent.top
			anchors.topMargin: 8
			anchors.horizontalCenter: parent.horizontalCenter
			text: contextMenu.frontPageBtnText
			font.pointSize: Qt.platform.os === "android" ? 14 : 12
			background: Rectangle {
				implicitWidth: contextMenu.dialogWidth * 0.8
				implicitHeight: 40
				color: contextMenu.frontPageBtnColor
				radius: 5
			}

			contentItem: Text {
				text: parent.text
				color: "white"
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
			}

			onClicked: {
				viewComponentLoader.sourceComponent = languageSelectionComponent;
				app.selectedLanguage = "";
				contextMenu.close();
			}

		}


		Button {
			id: closeAppBtn
			anchors.top: frontPageBtn.bottom
			anchors.topMargin: 12
			anchors.bottomMargin: 18
			anchors.horizontalCenter: parent.horizontalCenter
			text: contextMenu.closeAppBtnText
			font.pointSize: Qt.platform.os === "android" ? 14 : 12

			background: Rectangle {
				implicitWidth: contextMenu.dialogWidth * 0.8
				implicitHeight: 40
				color: "red"
				radius: 5
			}

			contentItem: Text {
				text: parent.text
				color: "white"
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
			}

			onClicked: {
				contextMenu.close();
			}
		}
	}

	function doOpen(lag){
		contextMenu.frontPageBtnColor = lag === "sw" ? "green" : "blue";
		contextMenu.frontPageBtnText = lag === "sw" ? "Rudi Nyuma" : "Go Back";
		contextMenu.closeAppBtnText = lag === "sw" ? "Funga" : "Close";
		open();
	}

}




    Component {
        id: languageSelectionComponent

        Flickable {
            anchors.fill: parent
            contentWidth: frontPageColumn.width
            contentHeight: frontPageColumn.height

            Rectangle { // Background
                anchors.fill: parent
                color: "transparent"
            }

            ColumnLayout {
                id: frontPageColumn
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
                        text: "<font color=\"green\">Utalii wa Tanzania</font> (<font color=\"blue\">Tanzania Tourism</font>)"
                        anchors.top: parent.top
                        font.pointSize: Qt.platform.os === "android" ? 16 : 14
                        font.bold: true
                        // font.underline: true
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

                // ── Tanzania Interactive Map ─────────────────────────────────
                Item {
                    id: tzMap
                    Layout.preferredWidth: app.width * 0.95
                    Layout.preferredHeight: app.width * 0.95
                    Layout.alignment: Qt.AlignHCenter

                    // Coordinate space: all paths stored in 0..1000 x 0..1000
                    readonly property real msx: tzMap.width  / 1000.0
                    readonly property real msy: tzMap.height / 1000.0

                    property string selectedRegion: ""
                    property var    selectedData:   ({})
                    property string hoveredRegion:  ""

                    // ── Region coordinate arrays (flat: x0,y0,x1,y1,...) ──
                    property var regionData: ({
                        "Kagera": [460.7,0.0,268.4,0.0,253.6,15.0,247.6,31.2,250.0,52.3,160.0,55.0,160.3,87.7,172.1,109.6,177.2,146.2,173.6,167.3,160.3,172.7,161.5,220.7,179.6,221.0,182.1,211.4,189.6,209.6,203.8,235.7,205.3,252.6,217.7,251.7,225.8,242.3,244.9,245.6,259.4,236.9,267.2,238.4,271.1,219.2,250.6,200.3,251.8,168.2,244.3,164.3,246.1,144.1,241.5,139.3,262.1,56.5,431.5,54.4,444.4,60.7,453.8,41.4,443.5,25.2,453.2,8.1,463.2,4.2],
                        "Mwanza": [225.8,240.2,230.1,258.6,233.7,255.6,240.3,255.6,248.5,259.2,260.0,260.1,262.1,263.1,262.1,272.1,273.6,274.8,280.8,287.7,293.2,291.3,298.6,289.5,301.9,291.3,316.1,291.9,321.6,290.1,324.0,291.9,327.3,288.0,338.2,285.6,343.6,291.6,365.6,290.1,369.6,291.9,371.4,279.3,369.3,276.9,369.3,272.1,375.9,269.1,376.5,261.0,381.0,258.3,376.2,256.8,364.7,258.9,350.2,249.2,333.3,247.4,329.4,255.3,324.0,257.7,317.6,253.8,317.0,247.7,312.5,243.2,307.7,243.5,300.1,248.6,287.7,242.9,272.3,242.9,262.4,237.5,240.0,246.5,233.7,242.9,233.7,239.0,237.0,236.3,238.2,231.2,231.6,231.5],
                        "Mara": [372.3,146.2,372.9,152.0,380.1,151.1,386.2,154.7,406.7,155.6,411.5,152.3,413.3,146.5,419.4,145.6,425.4,153.5,432.1,153.8,440.2,159.2,440.8,172.4,442.3,162.8,450.5,160.7,463.5,163.1,484.0,179.6,538.0,180.2,547.4,114.4,478.9,76.9,458.3,62.8,448.4,58.0,442.0,58.6,436.3,61.6,436.0,66.7,430.9,73.0,431.2,81.7,420.0,87.1,419.7,96.7,412.4,100.6,413.6,110.8,405.8,113.2,405.2,119.8,391.6,131.5,385.3,140.5,376.8,139.0],
                        "Simiyu": [536.5,183.5,485.2,183.2,480.1,181.4,477.4,174.8,463.8,163.4,440.2,159.2,439.9,170.6,423.0,183.8,406.1,184.7,404.6,192.5,409.7,196.1,409.1,203.0,397.0,210.5,391.3,245.3,382.5,254.7,377.1,255.6,373.2,260.7,373.8,267.0,366.8,269.7,372.0,280.5,369.9,287.4,364.1,289.5,356.0,283.5,352.1,301.8,335.1,303.0,364.1,304.2,377.4,300.9,409.1,300.6,426.6,306.6,428.7,311.1,444.7,314.1,451.1,321.3,460.7,321.0,469.2,314.4,473.4,304.8,490.9,300.9,494.3,285.9,514.2,279.3,514.5,224.6,520.8,221.9,526.3,225.8,531.4,222.5,535.0,211.4],
                        "Shinyanga": [228.6,333.6,229.8,364.6,225.5,376.0,231.6,393.1,234.3,429.7,240.9,428.2,244.0,390.4,266.6,402.7,287.1,404.2,290.2,411.4,284.1,416.2,290.2,418.6,295.9,430.6,306.8,427.0,334.2,430.0,338.5,420.4,349.0,429.4,355.4,424.6,366.2,425.8,370.2,433.9,369.0,454.7,376.2,470.6,403.7,476.6,408.2,505.4,424.5,506.9,429.0,512.3,437.5,502.1,437.5,456.5,454.1,430.9,453.8,412.9,439.6,402.1,433.6,390.4,435.1,359.2,450.2,330.0,460.4,325.8,463.8,317.7,453.8,322.5,443.8,313.2,410.0,301.2,335.4,304.5,325.8,328.8,305.3,339.3,287.1,335.4,271.7,341.1,266.6,321.9],
                        "Geita": [205.6,253.5,207.1,277.8,216.8,296.4,219.8,316.2,222.2,319.2,222.2,335.4,226.8,340.2,229.8,333.3,244.3,330.6,247.3,326.7,255.7,323.7,267.2,326.4,269.3,343.5,272.0,345.0,285.6,336.0,298.6,340.2,307.1,338.7,312.5,333.6,324.9,330.9,337.0,304.2,360.8,303.6,365.0,301.5,363.5,297.3,354.5,295.2,353.0,287.1,339.7,283.2,305.6,285.6,301.0,282.0,298.9,286.2,293.2,289.5,281.7,288.0,276.0,281.4,274.5,274.5,265.7,274.2,262.1,271.5,261.8,259.8,251.8,260.1,229.2,253.5,228.0,233.6,216.2,251.7],
                        "Tabora": [222.8,376.6,204.7,401.2,204.7,433.0,190.5,446.8,203.2,463.4,246.7,465.8,254.5,459.8,276.0,461.9,286.8,493.4,316.7,518.6,328.5,521.0,330.9,569.1,347.2,569.4,360.2,560.1,397.6,564.0,409.7,544.4,400.7,540.5,401.0,535.1,424.2,517.7,428.1,506.6,409.4,506.3,404.9,476.3,386.8,474.8,377.1,468.5,370.5,453.5,370.2,427.6,346.9,424.0,343.3,418.9,330.3,425.8,306.5,422.5,302.5,430.0,296.5,430.6,288.9,403.9,264.2,401.5,252.1,395.5,248.8,388.9,241.2,389.8,241.5,413.5,234.6,417.7,231.0,413.8,231.0,391.9],
                        "Kigoma": [177.5,454.4,180.3,458.3,180.3,473.9,176.0,484.1,176.6,504.8,190.2,518.3,212.9,518.9,219.5,521.9,257.5,519.2,260.9,522.8,260.3,530.6,255.1,533.3,245.5,533.3,237.6,538.1,237.3,547.1,248.5,545.6,252.4,540.8,301.9,540.5,305.9,547.1,313.1,549.8,314.0,562.5,324.0,564.9,327.3,568.2,330.9,546.2,330.9,530.0,327.6,519.5,316.7,518.6,306.2,509.9,304.0,504.2,298.6,503.6,289.3,495.8,284.4,489.2,277.2,461.9,253.9,460.4,247.3,465.5,228.0,466.7,205.3,464.0,198.7,454.7,193.8,459.5,187.2,460.1],
                        "Rukwa": [241.5,620.4,240.9,634.5,234.3,636.9,233.7,644.4,212.6,663.7,202.9,664.3,202.9,672.1,199.0,676.9,200.2,682.0,196.0,684.7,202.0,692.2,202.0,700.3,204.4,706.6,230.1,715.0,234.6,720.7,234.9,727.3,245.8,734.5,261.5,734.2,264.5,736.9,264.8,743.8,277.8,743.2,276.0,717.7,279.0,715.0,284.4,716.2,289.3,710.8,294.7,700.0,292.6,686.2,296.2,682.3,303.4,680.8,309.5,674.2,310.7,663.4,301.3,660.7,291.4,649.8,287.1,649.5,277.2,654.1,265.4,650.8,263.3,648.0,263.3,637.5,251.2,629.4,253.6,622.2],
                        "Katavi": [329.7,550.2,328.8,560.7,324.3,563.7,314.0,560.4,313.1,549.2,306.8,546.8,304.3,541.1,250.0,541.4,241.5,546.2,234.9,538.7,223.4,538.7,221.3,544.4,211.7,542.9,206.8,548.0,193.5,543.2,193.8,549.2,189.3,552.9,189.9,566.4,179.6,576.3,173.9,574.2,172.1,562.8,167.0,562.5,166.7,588.6,160.0,620.1,170.6,633.3,172.1,643.2,186.9,666.7,189.0,678.7,194.7,684.1,200.5,684.1,204.1,664.0,213.8,663.4,229.8,647.7,240.6,647.4,243.1,620.7,274.5,621.3,278.7,611.1,289.6,604.5,294.1,589.2,317.9,579.9,322.2,570.6,346.6,570.0,330.6,567.6],
                        "Singida": [511.8,300.9,482.5,301.8,469.8,307.2,463.5,322.8,452.6,326.7,435.7,358.3,433.9,391.0,439.9,402.7,452.9,411.7,454.4,430.0,449.3,440.8,438.7,444.1,437.5,501.5,423.3,518.9,396.7,539.6,404.3,544.7,405.5,551.4,398.2,565.2,410.0,567.9,420.0,576.6,436.3,612.3,444.7,606.9,456.5,606.9,490.3,583.5,492.5,573.0,515.4,558.3,529.6,560.7,530.2,546.5,545.3,522.2,539.3,497.6,542.0,469.4,549.5,451.1,535.9,433.6,534.7,415.9,537.1,407.5,549.8,402.4,549.5,384.7,536.8,373.9,535.9,364.3,528.1,362.5,522.6,351.1,512.1,346.8,519.6,318.3,528.4,309.0],
                        "Dodoma": [629.5,329.1,603.0,338.7,593.6,337.5,592.4,344.1,580.3,350.8,576.4,365.2,565.2,380.2,544.4,380.2,549.2,384.1,550.7,397.6,538.0,403.0,535.0,434.2,549.5,451.4,542.6,469.1,539.9,497.6,545.6,521.9,530.8,545.9,529.0,559.8,522.6,563.7,530.5,564.0,533.8,569.1,546.5,561.9,558.6,561.9,565.5,566.1,566.4,572.1,580.0,579.3,621.7,579.3,630.1,592.2,647.6,599.1,651.6,594.9,650.1,580.8,662.1,569.7,660.0,548.6,664.9,535.1,676.6,520.1,676.3,491.3,691.1,480.8,690.2,477.2,668.8,474.2,630.1,439.3,632.5,425.5,626.5,418.9,626.5,400.9,630.4,397.3,635.6,364.6],
                        "Manyara": [493.7,285.6,491.5,300.9,512.7,300.6,525.7,307.5,512.1,348.3,534.7,365.5,543.8,379.6,564.3,381.7,583.6,347.1,590.3,347.1,596.6,338.4,624.7,329.4,631.9,331.5,636.2,369.4,629.2,382.9,625.9,421.0,632.9,424.9,631.3,441.1,667.6,473.6,694.7,476.9,703.5,467.9,703.8,454.4,724.3,404.5,756.3,398.5,769.0,389.8,765.1,361.6,754.2,362.8,735.5,351.1,736.7,335.1,727.4,316.2,726.4,293.1,710.4,267.3,695.7,261.0,690.2,248.0,677.2,258.9,663.3,256.2,636.5,280.8,606.6,279.9,605.1,255.6,597.5,249.8,583.9,250.8,580.9,264.6,591.2,268.5,584.5,290.1,577.0,286.2,576.7,269.1,570.7,276.3,550.7,274.2,543.2,269.4,541.1,260.4,531.4,261.6,511.2,282.6],
                        "Arusha": [478.6,176.6,479.8,181.4,534.1,182.9,537.1,185.6,531.7,221.9,525.4,224.3,519.3,216.8,514.8,217.1,514.8,279.3,530.8,261.6,539.6,259.8,543.5,273.3,563.1,273.9,580.0,291.3,588.8,284.4,590.0,260.4,593.0,257.7,605.1,264.9,605.1,279.9,637.1,280.2,660.9,257.7,679.0,258.3,687.8,254.1,689.6,247.1,683.9,243.5,683.9,218.3,694.7,215.3,706.5,205.7,613.8,152.9,606.9,143.5,595.7,141.7,549.8,115.9,542.6,119.5,542.0,157.7,536.8,179.9,487.0,180.5],
                        "Kilimanjaro": [702.3,207.5,696.9,210.8,694.7,215.3,684.5,216.5,684.5,243.8,693.8,251.1,696.6,261.9,702.9,262.8,711.1,267.9,727.1,294.0,727.4,328.5,731.9,329.4,736.4,336.0,735.8,351.7,753.0,362.5,762.7,361.3,767.8,367.6,769.0,385.6,769.6,364.0,782.0,360.7,788.3,348.6,811.0,321.0,762.1,286.2,753.3,277.2,750.9,268.2,741.5,265.8,740.9,255.0,746.7,243.8,744.9,227.6,717.1,210.8],
                        "Tanga": [872.3,364.0,867.5,363.1,809.8,321.6,782.3,360.1,769.6,362.5,769.6,388.9,767.5,391.9,724.9,403.6,713.5,424.3,711.4,444.1,704.4,453.8,704.1,467.3,690.8,476.3,686.9,482.3,710.1,484.1,723.4,479.9,729.2,471.8,779.9,470.9,785.6,474.5,796.8,475.1,810.7,470.6,832.7,475.4,837.3,479.6,840.3,478.4,845.7,453.5,851.8,449.5,854.5,441.4,853.9,432.1,857.5,427.0,859.6,413.2,866.2,402.4,867.5,388.6,872.0,385.0],
                        "Morogoro": [756.0,474.8,726.8,471.2,718.6,482.3,685.7,483.2,677.2,489.5,677.2,520.1,669.1,524.9,660.6,547.1,662.7,569.7,652.8,579.0,649.5,605.1,667.0,621.0,687.2,626.7,675.7,648.9,638.6,650.8,624.7,668.8,610.2,673.9,576.4,715.6,549.2,717.4,558.0,749.5,578.5,764.6,577.3,772.4,583.0,774.5,591.8,767.6,598.4,770.9,596.9,786.5,579.7,808.1,587.6,821.3,596.6,820.1,614.1,798.8,637.7,793.1,644.3,801.5,642.5,824.9,651.6,824.9,699.0,795.2,720.7,748.0,713.2,729.7,719.5,695.5,754.5,652.9,768.4,620.7,800.7,621.9,802.2,595.2,814.9,589.2,820.0,575.4,804.6,573.6,804.6,550.5,772.9,532.7,772.6,503.6,758.5,492.2],
                        "Pwani": [842.1,513.8,840.3,513.8,839.4,526.4,827.3,540.2,797.4,543.5,802.8,551.7,803.1,572.1,815.5,574.2,818.8,577.8,817.6,586.5,802.8,593.7,800.7,620.4,796.5,622.8,782.6,620.1,766.6,621.0,757.5,644.4,758.8,648.6,768.1,653.8,771.1,660.4,817.0,684.4,819.7,690.1,826.1,694.0,840.6,683.5,863.8,681.4,875.3,676.9,883.5,677.8,886.5,665.8,890.4,661.6,889.8,641.1,880.7,630.3,878.6,622.2,883.5,605.4,881.6,595.5,871.4,581.7,872.9,565.8,865.0,559.2,862.9,539.0,868.1,533.6,848.1,522.8],
                        "Dar es Salaam": [738.8,472.4,749.4,475.4,754.5,475.4,757.2,477.5,758.8,492.2,768.1,503.6,771.1,504.2,772.9,506.3,773.6,533.3,780.2,538.4,789.3,538.7,798.3,544.1,808.0,543.2,812.2,540.5,826.7,540.2,837.3,529.7,840.0,522.5,839.7,515.0,841.2,513.2,840.6,491.9,835.7,488.3,836.7,478.4,834.8,476.0,827.6,475.7,819.7,472.4,805.6,471.2,793.8,475.4,785.6,475.1,782.0,471.5],
                        "Mbeya": [319.7,571.2,315.5,581.7,292.9,587.4,289.9,604.8,279.0,610.8,274.2,620.7,250.9,624.3,253.6,632.1,263.6,637.5,264.8,650.2,277.2,653.5,291.1,649.5,310.4,669.7,303.4,680.8,293.2,685.9,294.4,701.5,285.0,714.4,276.6,716.2,277.2,740.2,270.8,743.8,266.0,734.8,266.6,746.2,305.6,753.8,316.4,766.1,329.7,766.4,363.5,784.4,380.1,784.7,391.0,795.2,419.4,793.4,430.0,800.6,433.9,784.7,442.9,777.5,422.4,734.8,477.4,722.5,490.0,705.4,490.3,690.4,511.8,674.8,521.1,647.7,512.1,645.6,492.8,629.1,463.8,626.1,452.6,617.7,450.8,608.1,435.1,609.6,417.9,573.9,397.0,563.1,359.3,560.7,345.4,570.6],
                        "Njombe": [506.3,678.1,490.9,689.8,490.6,705.1,477.1,722.5,462.3,728.2,438.4,728.5,435.1,732.7,420.9,733.3,421.2,739.9,428.1,744.7,449.3,791.0,458.3,796.1,481.6,828.5,484.0,847.4,487.9,853.2,487.6,863.1,484.9,866.7,486.7,875.1,502.1,870.0,510.0,861.3,519.6,856.8,523.2,844.7,533.8,840.8,543.5,818.0,536.5,811.1,536.5,806.0,571.6,776.0,582.4,774.5,577.6,763.4,557.4,747.4,551.0,733.3,548.9,713.8,554.6,709.3,548.6,706.0,546.8,697.3,540.2,691.6,533.8,694.0,527.2,688.9,507.9,688.3,504.8,685.6],
                        "Iringa": [444.7,607.5,449.3,608.1,454.4,619.8,459.8,620.4,464.1,626.1,491.2,628.8,505.1,637.5,508.5,644.4,520.5,648.6,520.2,657.7,503.9,682.6,504.2,697.0,509.1,688.6,514.8,687.7,521.7,697.0,529.0,693.7,545.0,697.3,549.2,709.0,545.3,715.6,546.5,722.2,553.1,714.4,569.1,714.1,579.7,718.3,580.3,705.4,607.5,680.5,610.8,673.3,627.7,666.1,638.6,650.5,674.5,651.1,680.9,636.9,692.6,630.0,677.5,621.3,667.6,620.7,664.9,609.3,656.7,611.7,650.4,606.0,653.4,577.2,650.7,578.7,651.0,595.2,646.1,598.2,629.5,591.6,622.9,579.9,580.6,579.9,561.9,563.4,545.9,562.5,537.7,566.4,532.9,559.5,507.5,561.6,491.2,575.1,491.5,582.3,477.1,594.6,460.4,600.3,457.1,606.3],
                        "Ruvuma": [490.0,874.2,494.3,884.7,491.5,922.2,514.8,944.1,523.2,962.5,571.3,965.8,597.2,949.5,619.6,961.9,621.4,974.8,663.0,975.4,673.9,960.4,726.8,973.3,754.8,962.5,761.2,939.0,784.4,936.9,776.6,893.4,759.7,875.1,748.2,874.2,678.4,841.4,680.3,819.8,696.3,800.6,644.0,825.5,639.5,822.5,644.0,802.1,635.0,791.9,616.5,797.0,597.5,819.8,583.9,818.9,580.0,809.3,596.3,787.1,596.3,764.6,571.6,776.3,537.1,805.4,543.5,821.3,536.2,836.9,522.0,844.7,517.8,858.6],
                        "Lindi": [757.2,646.2,718.6,697.9,719.8,710.5,713.8,730.6,721.3,747.4,709.8,764.6,709.8,775.7,701.4,792.2,686.3,800.6,690.2,807.8,680.9,818.3,676.6,841.7,714.1,855.3,747.0,873.6,759.4,874.8,777.5,894.6,779.6,918.3,779.9,898.5,793.8,894.0,801.3,882.3,844.5,873.3,870.8,860.1,895.2,855.6,900.4,859.8,902.2,873.9,913.3,876.3,914.3,860.4,920.3,857.7,923.3,848.6,917.0,842.0,923.0,821.6,912.7,804.2,908.2,757.7,896.4,750.5,893.4,727.3,883.8,717.1,879.5,677.5,837.3,684.4,823.1,692.2,818.2,684.7,772.0,661.6,765.7,650.5],
                        "Mtwara": [780.2,897.3,780.2,919.5,783.8,924.3,782.6,937.5,790.8,939.3,809.8,948.6,814.9,946.8,831.5,934.8,837.9,933.6,839.7,931.5,847.5,928.8,859.6,927.0,869.6,927.0,873.8,929.1,877.4,928.2,884.1,921.6,895.5,914.1,904.6,912.0,890.4,912.3,876.5,902.7,872.9,897.3,862.9,897.6,864.1,903.6,859.6,906.6,854.2,904.2,853.3,900.0,846.3,901.8,842.4,897.6,839.4,897.0,829.7,901.5,825.2,901.5,822.5,899.4,820.4,894.3,814.6,891.0,811.3,883.2,800.4,882.3,795.6,888.3,793.5,894.3],
                    })

                    property var lakeVictoria: [440.8,58.9,424.5,55.3,263.6,55.9,261.5,80.8,243.4,136.3,249.1,143.5,242.8,168.8,251.2,165.8,255.7,175.1,250.0,186.2,262.7,191.9,268.4,188.9,271.1,180.5,279.3,180.2,274.8,176.9,276.6,171.2,283.5,170.9,289.9,161.9,298.3,162.5,304.0,173.9,321.0,181.7,324.6,174.2,342.4,181.1,348.1,171.8,360.5,170.6,369.3,180.5,389.5,184.1,398.2,169.7,421.5,158.3,420.6,150.2,405.5,156.2,387.4,155.9,372.3,150.5,371.1,143.5,385.9,136.6,377.4,134.2,383.8,120.7,394.0,124.9,399.8,121.3,399.5,111.1,409.1,109.6,409.7,95.5,417.6,92.8,424.8,73.6]
                    property var lakeTanganyika: [64.6,439.3,62.2,445.6,54.0,446.5,51.3,467.3,39.9,476.3,40.2,489.2,49.5,499.1,59.8,525.8,65.2,528.8,65.5,544.4,84.5,564.9,87.9,573.3,102.7,576.6,119.9,594.3,125.0,609.9,124.4,628.8,129.2,633.3,130.7,642.6,145.8,654.1,155.5,670.3,163.3,671.8,167.0,668.2,162.1,653.5,141.6,621.3,140.1,606.9,130.7,583.8,115.3,562.2,81.2,537.5,76.7,524.3,64.9,508.1,61.6,480.5,73.7,459.8]

                    property var regionColors: ({
                        "Kagera":"#87c874","Mwanza":"#fff93f","Mara":"#aca6d6","Simiyu":"#d8e860",
                        "Shinyanga":"#d0e45e","Geita":"#fff93f","Tabora":"#ffd3ee","Kigoma":"#e3b083",
                        "Rukwa":"#ffd3ee","Katavi":"#86d7f2","Singida":"#c0e393","Dodoma":"#cfcd76",
                        "Manyara":"#d8cdef","Arusha":"#d8cdef","Kilimanjaro":"#cda8d4","Tanga":"#a5d75e",
                        "Morogoro":"#ffd3ec","Pwani":"#bee0fc","Dar es Salaam":"#bfe1e3","Mbeya":"#cfcd76",
                        "Njombe":"#88c975","Iringa":"#88c975","Ruvuma":"#e5fafd","Lindi":"#fea376",
                        "Mtwara":"#fde024",
                    })

                    property var regionInfo: ({
                        "Kagera":        {capital:"Bukoba",        area:"28,388 km²", attractions:"Ziwa Viktoria, Misitu ya Kagera, Rubondo Island NP, Makao ya TANU Bukoba"},
                        "Mwanza":        {capital:"Mwanza",        area:"9,467 km²",  attractions:"Ziwa Viktoria, Bismarck Rock, Saa Nane Island NP, Bwiru Palace"},
                        "Mara":          {capital:"Musoma",        area:"21,760 km²", attractions:"Serengeti NP (Kaskazini), Ziwa Viktoria, Mugumu Cultural Centre"},
                        "Simiyu":        {capital:"Bariadi",       area:"24,575 km²", attractions:"Serengeti NP (Mipaka), Mto Mara, Utamaduni wa Wasukuma"},
                        "Shinyanga":     {capital:"Shinyanga",     area:"18,914 km²", attractions:"Mgodi wa Dhahabu Williamson, Ziwa Mwadui, Utamaduni Wasukuma"},
                        "Geita":         {capital:"Geita",         area:"20,054 km²", attractions:"Mgodi Mkubwa wa Dhahabu GGML, Ziwa Viktoria, Msitu wa Buyagu"},
                        "Tabora":        {capital:"Tabora",        area:"76,151 km²", attractions:"Nyumba ya Livingstone, Makao ya Mirambo, Tembo Msitu wa Ugalla"},
                        "Kigoma":        {capital:"Kigoma",        area:"45,066 km²", attractions:"Gombe Stream NP (Sokwe), Mahale Mountains NP, Ziwa Tanganyika, Ujiji"},
                        "Rukwa":         {capital:"Sumbawanga",    area:"22,825 km²", attractions:"Ziwa Rukwa, Milima ya Ufipa, Msitu wa Lwafi, Ndege Wengi"},
                        "Katavi":        {capital:"Mpanda",        area:"45,840 km²", attractions:"Katavi NP (Tembo & Viboko Wengi), Ziwa Katavi, Ziwa Chada"},
                        "Singida":       {capital:"Singida",       area:"49,341 km²", attractions:"Ziwa Singida, Ziwa Kindai, Milima ya Bereko, Nyumba za Kale Wanyaturu"},
                        "Dodoma":        {capital:"Dodoma",        area:"41,311 km²", attractions:"Bunge la Tanzania, Bustani ya Helu, Mlima wa Dodoma, Shamba la Zabibu"},
                        "Manyara":       {capital:"Babati",        area:"44,522 km²", attractions:"Tarangire NP, Ziwa Manyara NP, Bonde la Ufa, Mlima Hanang"},
                        "Arusha":        {capital:"Arusha",        area:"37,576 km²", attractions:"Ngorongoro Crater, Serengeti NP, Olduvai Gorge, Longido, Mt Meru"},
                        "Kilimanjaro":   {capital:"Moshi",         area:"13,250 km²", attractions:"Mlima Kilimanjaro (5,895m), Chagga Caves, Marangu, Mandhari ya Kahawa"},
                        "Tanga":         {capital:"Tanga",         area:"26,808 km²", attractions:"Mapango ya Amboni, Tongoni Ruins, Toten Island, Misitu ya Amani"},
                        "Morogoro":      {capital:"Morogoro",      area:"70,799 km²", attractions:"Udzungwa Mountains NP, Mikumi NP, Bwawa la Mtera, Uluguru Mountains"},
                        "Pwani":         {capital:"Kibaha",        area:"32,407 km²", attractions:"Saadani NP, Kisiwa cha Mafia, Mikoko ya Rufiji, Ufukwe wa Bahari"},
                        "Dar es Salaam": {capital:"Dar es Salaam", area:"1,393 km²",  attractions:"Kisiwa cha Bongoyo, Msasani Beach, National Museum, Village Museum"},
                        "Mbeya":         {capital:"Mbeya",         area:"60,350 km²", attractions:"Kitulo NP (Bustani ya Mungu), Msitu wa Poroto, Ziwa Ngozi, Daraja la Mungu"},
                        "Njombe":        {capital:"Njombe",        area:"21,347 km²", attractions:"Maporomoko ya Kihansi, Misitu ya Udzungwa, Uzalishaji wa Chai, Mlima Rungwe"},
                        "Iringa":        {capital:"Iringa",        area:"35,743 km²", attractions:"Ruaha NP (Kubwa Zaidi TZ), Isimila Stone Age Site, Bwawa la Mtera"},
                        "Ruvuma":        {capital:"Songea",        area:"63,669 km²", attractions:"Selous GR (Kusini), Mbamba Bay, Ziwa Nyasa, Makaburi ya Wangoni"},
                        "Lindi":         {capital:"Lindi",         area:"66,046 km²", attractions:"Msitu wa Litipo, Mikindani Old Town, Ufukwe wa Mnazi Bay, Dinosaur Fossils"},
                        "Mtwara":        {capital:"Mtwara",        area:"16,707 km²", attractions:"Mnazi Bay-Ruvuma Marine Park, Mikindani Fort, Ufukwe wa Msimbati"},
                    })

                    // ── Build SVG path string from flat array ──────────────────────
                    function buildPath(arr) {
                        if (!arr || arr.length < 4) return ""
                        var s = "M " + (arr[0]*msx).toFixed(1) + "," + (arr[1]*msy).toFixed(1)
                        for (var i = 2; i < arr.length; i += 2)
                            s += " L " + (arr[i]*msx).toFixed(1) + "," + (arr[i+1]*msy).toFixed(1)
                        return s + " Z"
                    }

                    // ── Point-in-polygon (ray casting) ─────────────────────────────
                    function pointInPoly(px, py, arr) {
                        var n = arr.length / 2
                        var inside = false
                        var j = n - 1
                        for (var i = 0; i < n; i++) {
                            var xi = arr[i*2], yi = arr[i*2+1]
                            var xj = arr[j*2], yj = arr[j*2+1]
                            if (((yi > py) !== (yj > py)) &&
                                (px < (xj - xi) * (py - yi) / (yj - yi) + xi))
                                inside = !inside
                            j = i
                        }
                        return inside
                    }

                    // ── Centroid of flat array ──────────────────────────────────────
                    function mCentroid(arr) {
                        var n = arr.length / 2
                        var tx = 0, ty = 0
                        for (var i = 0; i < n; i++) { tx += arr[i*2]; ty += arr[i*2+1] }
                        return Qt.point(tx/n * msx, ty/n * msy)
                    }

                    // ── Hit test: find which region contains the point ──────────────
                    function hitRegion(mx, my) {
                        var px = mx / msx
                        var py = my / msy
                        var names = Object.keys(regionData)
                        for (var i = 0; i < names.length; i++) {
                            if (pointInPoly(px, py, regionData[names[i]]))
                                return names[i]
                        }
                        var best = "", bestD = 1e9
                        for (var i = 0; i < names.length; i++) {
                            var arr = regionData[names[i]]
                            var n2 = arr.length / 2
                            var cx = 0, cy2 = 0
                            for (var k = 0; k < n2; k++) { cx += arr[k*2]; cy2 += arr[k*2+1] }
                            cx /= n2; cy2 /= n2
                            var dx = px-cx, dy = py-cy2, d = dx*dx+dy*dy
                            if (d < bestD) { bestD = d; best = names[i] }
                        }
                        return best
                    }

                    // ── Ocean background ───────────────────────────────────────────
                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#1e4d7a" }
                            GradientStop { position: 1.0; color: "#162e4a" }
                        }
                    }

                    // ── Lake Victoria ──────────────────────────────────────────────
                    Shape {
                        anchors.fill: parent
                        vendorExtensionsEnabled: false
                        ShapePath {
                            fillColor: "#5ab4d8"; strokeColor: "#2a6a90"; strokeWidth: 1.2
                            PathSvg { path: tzMap.buildPath(tzMap.lakeVictoria) }
                        }
                    }
                    Text {
                        property point c: tzMap.mCentroid(tzMap.lakeVictoria)
                        x: c.x - width/2; y: c.y - height/2
                        text: "Ziwa Victoria"; font.pixelSize: 8; font.bold: true; color: "#1a3a5a"
                    }

                    // ── Lake Tanganyika ────────────────────────────────────────────
                    Shape {
                        anchors.fill: parent
                        vendorExtensionsEnabled: false
                        ShapePath {
                            fillColor: "#5ab4d8"; strokeColor: "#2a6a90"; strokeWidth: 1.2
                            PathSvg { path: tzMap.buildPath(tzMap.lakeTanganyika) }
                        }
                    }
                    Text {
                        property point c: tzMap.mCentroid(tzMap.lakeTanganyika)
                        x: c.x - width/2; y: c.y - height/2
                        text: "Ziwa
Tanganyika"; font.pixelSize: 7; font.italic: true
                        color: "#1a3a5a"; horizontalAlignment: Text.AlignHCenter
                    }

                    // ── Neighbour country labels ───────────────────────────────────
                    Repeater {
                        model: [
                            {t:"UGANDA",    x:48,  y:10},  {t:"KENYA",      x:712, y:45},
                            {t:"RWANDA",    x:5,   y:90},  {t:"BURUNDI",    x:0,   y:185},
                            {t:"DR CONGO",  x:0,   y:372}, {t:"ZAMBIA",     x:55,  y:742},
                            {t:"MALAWI",    x:228, y:788}, {t:"MOZAMBIQUE", x:482, y:820},
                            {t:"INDIAN",    x:742, y:320}, {t:"OCEAN",      x:748, y:555},
                        ]
                        delegate: Text {
                            x: modelData.x * tzMap.msx; y: modelData.y * tzMap.msy
                            text: modelData.t; font.pixelSize: 7; font.italic: true
                            color: "#4488aa"; opacity: 0.75
                        }
                    }

                    // ── Region shapes ──────────────────────────────────────────────
                    Repeater {
                        model: Object.keys(tzMap.regionData)
                        delegate: Shape {
                            anchors.fill: parent
                            vendorExtensionsEnabled: false
                            property string rname: modelData
                            ShapePath {
                                fillColor: {
                                    var b = tzMap.regionColors[rname] || "#aaa"
                                    if (tzMap.selectedRegion === rname) return Qt.lighter(b, 1.45)
                                    if (tzMap.hoveredRegion  === rname) return Qt.lighter(b, 1.18)
                                    return b
                                }
                                strokeColor: tzMap.selectedRegion === rname ? "#ffffff" : "#1a1830"
                                strokeWidth: tzMap.selectedRegion === rname ? 2.5 : 0.8
                                PathSvg { path: tzMap.buildPath(tzMap.regionData[rname]) }
                            }
                        }
                    }

                    // ── Region name labels ─────────────────────────────────────────
                    Repeater {
                        model: Object.keys(tzMap.regionData)
                        delegate: Text {
                            property var arr: tzMap.regionData[modelData]
                            property point c: tzMap.mCentroid(arr)
                            x: c.x - width/2; y: c.y - height/2
                            text: modelData === "Dar es Salaam" ? "DSM" :
                                  modelData === "Kilimanjaro"   ? "Kilim." : modelData
                            font.pixelSize: 8; font.bold: true
                            color: "#0e0e22"; opacity: 0.88
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    // ── Selection glow ─────────────────────────────────────────────
                    Shape {
                        anchors.fill: parent
                        vendorExtensionsEnabled: false
                        visible: tzMap.selectedRegion !== ""
                        ShapePath {
                            fillColor: "transparent"
                            strokeColor: "#00e5ff"; strokeWidth: 3.5
                            PathSvg { path: tzMap.buildPath(tzMap.regionData[tzMap.selectedRegion] || []) }
                        }
                    }

                    // ── Info popup anchored inside the map ─────────────────────────
                    Rectangle {
                        id: mapInfoPopup
                        visible: tzMap.selectedRegion !== ""
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: visible ? mapInfoCol.implicitHeight + 20 : 0
                        color: "#e8f8f8"
                        radius: 6
                        border.color: "#00e5ff"
                        border.width: 1.5
                        opacity: 0.96

                        Column {
                            id: mapInfoCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
                            spacing: 4

                            Row {
                                spacing: 8
                                Rectangle {
                                    width: 14; height: 14; radius: 3
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: tzMap.regionColors[tzMap.selectedRegion] || "#888"
                                    border.color: "#00e5ff"; border.width: 1
                                }
                                Text {
                                    text: tzMap.selectedRegion
                                    font.pixelSize: 14; font.bold: true; color: "#003344"
                                }
                                Item { width: 1; height: 1; Layout.fillWidth: true }
                                Text {
                                    text: "✕"
                                    font.pixelSize: 14; color: "#cc3333"
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: tzMap.selectedRegion = ""
                                    }
                                }
                            }

                            Text {
                                width: parent.width
                                text: "🏛 " + (tzMap.selectedData["capital"] || "—") +
                                      "   📐 " + (tzMap.selectedData["area"] || "—")
                                font.pixelSize: 11; color: "#004455"
                            }
                            Text {
                                width: parent.width
                                text: "🌍 " + (tzMap.selectedData["attractions"] || "—")
                                font.pixelSize: 11; color: "#004455"
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    // ── Mouse interaction ──────────────────────────────────────────
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: tzMap.hoveredRegion !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: function(mouse) {
                            var hit = tzMap.hitRegion(mouse.x, mouse.y)
                            if (hit) {
                                tzMap.selectedRegion = hit
                                tzMap.selectedData   = tzMap.regionInfo[hit] || {}
                            }
                        }
                        onPositionChanged: function(mouse) {
                            tzMap.hoveredRegion = tzMap.hitRegion(mouse.x, mouse.y)
                        }
                        onExited: tzMap.hoveredRegion = ""
                    }
                }
                // ── End Tanzania Interactive Map ────────────────────────────────


                Text {
                    text: "Kusafiri ni elimu. Tembelea hifadhi za Tanzania, jifunze thamani ya mazingira ya Tanzania, na uwe balozi wa uzuri wa Tanzania.<br><br>(<font color=\"#dadada\"> Travel is a form of learning. Explore Tanzania's national parks, discover the value of our environment, and become an ambassador for the beauty of Tanzania. </font>)"

                    font.pointSize: Qt.platform.os === "android" ? 13 : 11
                    font.bold: true
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    textFormat: Text.RichText
                    
                }


                Image {
                    id: imgNo1
                    source: "./wanyama-tz-3.png"
                    width: app.width
                    height: 320
                    Layout.alignment: Qt.AlignHCenter
                }

                Image {
                    source: "wanyama-tz-3-b.png"
                    width: imgNo1.width
                    height: imgNo1.height
                    Layout.alignment: Qt.AlignHCenter
                }


                Text {
                    text: "Idadi ya vivutio vilivyoorodheshwa (Number of listed attractions) : <font color=\"white\">"+ attractionModel.count + "</font>"
                    font.pointSize: Qt.platform.os === "android" ? 13 : 11
                    Layout.alignment: Qt.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    textFormat: Text.RichText
                    font.bold: true
                    color: "#dadada"
                }

                Button {
                    text: "Furahia upekee wa Tanzania"
                    font.pointSize: Qt.platform.os === "android" ? 14 : 12
                    Layout.preferredWidth: app.width * 0.8
                    Layout.preferredHeight: 68
                    Layout.alignment: Qt.AlignHCenter

                    background: Rectangle {
                        implicitHeight: 40
                        color: "green"
                        radius: 5
                    }

                    contentItem: Text {
font.pointSize: Qt.platform.os === "android" ? 13 : 11
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        modeSelectionDialog.doOpen("sw","green");
                    }

                }


                Button {
                    text: "Experience the uniqueness of Tanzania"
                    font.pointSize: Qt.platform.os === "android" ? 14 : 12
                    Layout.preferredWidth: app.width * 0.8
                    Layout.preferredHeight: 68
                    Layout.alignment: Qt.AlignHCenter

                    background: Rectangle {
                        implicitHeight: 40
                        color: "blue"
                        radius: 5
                    }

                    contentItem: Text {
font.pointSize: Qt.platform.os === "android" ? 13 : 11
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        modeSelectionDialog.doOpen("en","blue");
                    }
                }



                Rectangle {
                    width: app.width
                    height: 1
                    color: "#dadada"
                }

                

                Text {
                    text: "Tanzania imebarikiwa kuwa na vivutio vingi vya utalii ambavyo ni vigumu kuvitaja vyote hapa. Ili kuvifahamu na kuvishuhudia kwa undani zaidi, tunakushauri kufuatilia Tanzania Safari Channel inayopatikana kupitia DStv (292), Azam TV (401), Zuku (27), StarTimes Antenna (331), StarTimes Dish (542), Zmux (46) na Continental (7). Huu ni mlango wako wa kidijitali wa kutembelea mbuga za wanyama, fukwe, na urithi wa kitamaduni wa nchi yetu ukiwa nyumbani kwako.
<br><br><br> 
(<font color=\"#dadada\">
Tanzania is home to an overwhelming number of tourist attractions that cannot be fully listed here. For a more immersive experience and to explore these wonders in detail, we highly recommend watching the Tanzania Safari Channel, available on DStv (292), Azam TV (401), Zuku (27), StarTimes Antenna (331), StarTimes Dish (542), Zmux (46) and Continental (7). It is your ultimate window to the country's breathtaking landscapes, wildlife, and rich cultural heritage.
</font>)
<br><br>

 "
                    font.pointSize: Qt.platform.os === "android" ? 13 : 11
                    font.bold: true
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    textFormat: Text.RichText

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
return;
                            if(typeof n3ctaApp !== "undefined"){
                                n3ctaApp.pasteToClipboard("8647491");
                                n3ctaApp.showToastMessage("Namba ya changisha imenakiliwa.");
                            }else if(typeof loader !== "undefined"){
                                loader.pasteToClipboard("8647491");
                                loader.showToastMessage("Changisha number copied.");
                            }

                        }
                    }

                }



Button {
                    text: "Funga (Close)"
                    font.pointSize: Qt.platform.os === "android" ? 12 : 10
                    Layout.preferredWidth: app.width * 0.4
                    Layout.preferredHeight: 60
                    Layout.alignment: Qt.AlignHCenter

                    background: Rectangle {

                        implicitHeight: 40
                        color: "red"
                        radius: 5
                    }

                    contentItem: Text {
font.pointSize: Qt.platform.os === "android" ? 13 : 11
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        app.close();
                    }
                }


Rectangle {
                    width: app.width
                    height: 1
                    color: "#dadada"
                }

Rectangle {
                    width: app.width
                    height: 1
                    color: "#dadada"
                }




            }
        }
    }

    // Attraction View Component 1
    Component {
        id: attractionViewComponent1
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

    // Attraction View Component 2
    Component {
        id: attractionViewComponent2

        Rectangle{
            anchors.fill: parent
            color: "transparent"

            ListView{
                id: attractionList
                anchors.fill: parent
                anchors.margins: 2
                model: attractionModel
                clip: true

                header: Rectangle{
                    width: parent.width
                    height: header.height + flag.height
                    color: "white"

MouseArea {
                        anchors.fill: parent
                        onDoubleClicked: {
                            contextMenu.doOpen(app.selectedLanguage);
                        }
                    }

                    Component.onCompleted: {
                        header.text =  app.selectedLanguage === "sw" ? "<font color=\"green\">Utalii wa Tanzania</font>" : "<font color=\"blue\">Tanzania Tourism</font>"
                    }

                    Text {
                        id: header
                        anchors.top: parent.top
                        font.pointSize: Qt.platform.os === "android" ? 16 : 14
                        font.bold: true
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

                delegate: Rectangle{
                    id: delegate
                    color: "transparent"
                    width: parent.width
                    height:delegateTitle.height + delegateDesc.height + delegateImg.height
                    anchors.topMargin: 2

                    property string name: ""
                    property string desc: ""
                    property string path: imageFile


MouseArea {
                        anchors.fill: parent
                        onDoubleClicked: {
                            contextMenu.doOpen(app.selectedLanguage);
                        }
                    }

                    Component.onCompleted: {
                        delegate.name = app.selectedLanguage === "en" ? name_en : name_sw;
                        delegate.desc = app.selectedLanguage === "en" ? desc_en : desc_sw;
                    }

                    Text {
                        id:delegateTitle
                        width: parent.width
                        anchors.top: parent.top
                        text: String(index + 1) + ": "+ delegate.name
                        font.pointSize: Qt.platform.os === "android" ? 14 : 12
                        font.bold: true
                        font.underline: true
                        color: "white"
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        textFormat: Text.RichText
                    }

                    Text {
                        id:delegateDesc
                        width: parent.width
                        anchors.top: delegateTitle.bottom
                        text: delegate.desc
                        font.pointSize: Qt.platform.os === "android" ? 12 : 10
                        font.bold: true
                        color: "white"
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        textFormat: Text.RichText
                    }

                    Image {
                        id: delegateImg
                        anchors.top: delegateDesc.bottom
                        anchors.topMargin: 2
                        source: delegate.path
                        width: parent.width * 0.92
                        height: width * 0.8
                        fillMode: Image.PreserveAspectFit
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                }

                footer: Button {
                    id: backButton
                    text: app.selectedLanguage === "en" ? "<- Go Back" : "<- Rudi Nyuma"
                    anchors.topMargin: 4
                    font.pointSize: Qt.platform.os === "android" ? 18 : 16

                    background: Rectangle {
                        anchors.topMargin: 4
                        implicitHeight: 40
                        color: "transparent"
                        radius: 5
                    }

                    contentItem: Text {
                        anchors.topMargin: 4
                        text: parent.text
                        color: "black"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        viewComponentLoader.sourceComponent = languageSelectionComponent;
                        app.selectedLanguage = "";
                    }
                }

            }

        }
    }
}
