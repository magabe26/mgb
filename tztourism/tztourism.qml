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
		contextMenu.frontPageBtnText = lag === "sw" ? "Nyuma" : "Back";
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

                Image {
                    source: "./TZmap.png"
                    Layout.preferredWidth: app.width * 0.8
                    Layout.alignment: Qt.AlignHCenter

                }


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
                    text: "Tanzania imebarikiwa kuwa na vivutio vingi vya utalii ambavyo ni vigumu kuvitaja vyote hapa. Ili kuvifahamu na kuvishuhudia kwa undani zaidi, tunakushauri kufuatilia Tanzania Safari Channel inayopatikana kupitia DStv (292), Azam TV (401), Zuku (27), StarTimes Antenna (331), StarTimes Dish (542), na Zmux (46). Huu ni mlango wako wa kidijitali wa kutembelea mbuga za wanyama, fukwe, na urithi wa kitamaduni wa nchi yetu ukiwa nyumbani kwako.
<br><br><br> 
(<font color=\"#dadada\">
Tanzania is home to an overwhelming number of tourist attractions that cannot be fully listed here. For a more immersive experience and to explore these wonders in detail, we highly recommend watching the Tanzania Safari Channel, available on DStv (292), Azam TV (401), Zuku (27), StarTimes Antenna (331), StarTimes Dish (542), and Zmux (46). It is your ultimate window to the country's breathtaking landscapes, wildlife, and rich cultural heritage.
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
                    text: app.selectedLanguage === "en" ? "<- Back" : "<- Nyuma"
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
