/**
 * Copyright 2026 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe
 *
 * Portal flow (mirrors gateway.tra.go.tz/umvvs calculator):
 *   Step 1  GET /api/GetMakes                                → pick Make
 *   Step 2  GET /api/GetModels?make=X                        → pick Model
 *   Step 3  GET /api/GetBodyTypes?make=X&model=Y             → pick Body Type
 *   Step 4  GET /api/GetYears?make=X&model=Y&bodyType=Z      → pick Year
 *   Step 5  GET /api/GetEngineCapacities?...&year=W          → pick Engine cc
 *   Step 6  POST /api/valuation { all fields }               → show Results
 *
 * All API calls fall back to offline data so the app is always usable.
 * Pages:  0 = Home  1 = Calculator  2 = Results
 *         3 = Compare  4 = RefCode  5 = Missing Vehicle
 */

import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Rectangle {
    id: app
    width:  parent ? parent.width  : 400
    height: parent ? parent.height : 800
    color: "#0a0800"

    // ── App wrapper helpers (kwa mazingira ya nje) ────────────────────────────
    function cleanParent(t) {
        return t ? t.replace(/\s*\(.*?\)\s*/g, "").trim() : "";
    }
    function isPrimaryResultsApp() {
        return (typeof n3ctaApp !== "undefined");
    }
    function isSecondaryResultsApp() {
        return (typeof loader !== "undefined");
    }
    function isInsideApp() {
        var t = cleanParent(String(parent.parent.parent.parent));
        if (isPrimaryResultsApp()) return t === "QQuickRootItem";
        var i = t.indexOf("_");
        return i !== -1 && t.substr(0, i) === "SwipeView";
    }
    function isQMLDialogApp() {
        return cleanParent(String(parent.parent.parent)) === "QQuickRectangle";
    }
    function closeIfInsideApp() {
        if (!isInsideApp()) return;
        if (isPrimaryResultsApp()) {
            n3ctaApp.closeCustomPage();
        } else if (isSecondaryResultsApp()) {
            loader.isMenuWindowVisible = true;
            loader.isMainResultsWindowVisible = true;
            loader.isFooterVisible = true;
            if (typeof loader.mode !== "undefined") loader.mode = 2;
            loader.closeCustomPage();
        }
    }
    function closeIfQMLDialogApp() {
        if (!isQMLDialogApp()) return;
        if (isPrimaryResultsApp()) {
            n3ctaApp.closeQMLDialog();
        } else if (isSecondaryResultsApp()) {
            nectaMainResultsPageDownloaderHtmlToXmlConveterAndSaver.closeQMLDialog();
        }
    }
    function cmd(url) {
        if (isPrimaryResultsApp()) {
            n3ctaApp.onUrlVisited(url);
        } else if (isSecondaryResultsApp()) {
            if (isQMLDialogApp()) {
                n3ctaQmlConnectionsPipe.onUrlVisited(url);
            } else if (isInsideApp()) {
                loader.onUrlVisited(url);
            }
        }
    }
    function showToastMessage(msg) {
        if (isPrimaryResultsApp()) {
            n3ctaApp.showToastMessage(msg);
        } else if (isSecondaryResultsApp()) {
            nectaMainResultsPageDownloaderHtmlToXmlConveterAndSaver.showToastMessage(msg);
        }
    }
    function ad() { cmd("#showGoogleAd"); }
    function close() { closeIfInsideApp(); closeIfQMLDialogApp(); ad(); }

    // ── Responsive helpers ────────────────────────────────────────────────────
    readonly property bool mob:  true
    readonly property real margin: app.mob ? 16 : 32
    readonly property real colW:   app.width - app.margin * 2
    readonly property real inputH: app.mob ? 50 : 46
    readonly property real btnH:   app.mob ? 54 : 50
    readonly property real titleF: app.mob ? 22 : 26
    readonly property real labelF: app.mob ? 11 : 11
    readonly property int  cols2:  app.mob ?  1 :  2

    // ── Palette ───────────────────────────────────────────────────────────────
    readonly property color cBg:        "#0D1117"
    readonly property color cSurface:   "#161B22"
    readonly property color cCard:      "#1C2333"
    readonly property color cBorder:    "#2D3748"
    readonly property color cGold:      "#D4A017"
    readonly property color cGoldLight: "#F0C040"
    readonly property color cGreen:     "#22C55E"
    readonly property color cRed:       "#EF4444"
    readonly property color cBlue:      "#3B82F6"
    readonly property color cText:      "#E8EAF0"
    readonly property color cMuted:     "#8892A4"
    readonly property color cInput:     "#1E2A3A"

    // ── EAC Tax Rate Constants ────────────────────────────────────────────────
    readonly property real cRATE_IMPORT_DUTY:  0.25
    readonly property real cRATE_EXCISE_STD:   0.10
    readonly property real cRATE_EXCISE_LARGE: 0.25
    readonly property real cRATE_VAT:          0.18
    readonly property real cRATE_INFRA_LEVY:   0.015
    readonly property real cRATE_PORT_LEVY:    0.005
    readonly property real cRATE_AGE_DUMP:     0.30
    readonly property int  cAGE_LIMIT:         8
    readonly property string cAPI_BASE:        "https://gateway.tra.go.tz/umvvs"

    // ── Navigation ────────────────────────────────────────────────────────────
    property int currentPage: 0

    // ── Cascading dropdown lists ──────────────────────────────────────────────
    property var makesList:   []
    property var modelsList:  []
    property var bodiesList:  []
    property var yearsList:   []
    property var enginesList: []

    // ── Selected vehicle fields ───────────────────────────────────────────────
    property string vMake:    ""
    property string vModel:   ""
    property string vBody:    ""
    property int    vYear:    0
    property int    vEngine:  0
    property string vFuel:    "Petrol"
    property string vOrigin:  "Japan"
    property real   vFreight: 2500000

    // ── Per-step loading flags ────────────────────────────────────────────────
    property bool loadMakes:   false
    property bool loadModels:  false
    property bool loadBodies:  false
    property bool loadYears:   false
    property bool loadEngines: false
    property bool loadResult:  false
    property string stepError: ""

    // ── Result state ──────────────────────────────────────────────────────────
    property var valuationResult: null
    property var taxResult:       null

    // ── Compare state ─────────────────────────────────────────────────────────
    property var    cmpA:    null
    property var    cmpB:    null
    property string bMake:   ""
    property string bModel:  ""
    property int    bYear:   2017
    property int    bEngine: 1300

    // ── Reference-code state ─────────────────────────────────────────────────
    property string refCode:    ""
    property string refError:   ""
    property bool   refLoading: false

    // ── Missing-vehicle state ─────────────────────────────────────────────────
    property string mvEmail:     ""
    property bool   mvSubmitted: false
    property bool   mvLoading:   false

    // ════════════════════════════════════════════════════════════════════════
    // JS: Math helpers — every statement ends with ;
    // ════════════════════════════════════════════════════════════════════════
    function appYear() {
        return new Date().getFullYear();
    }

    function roundN(n) {
        return Math.round(n * 100) / 100;
    }

    function depreciationRate(year) {
        var age   = appYear() - year;
        var sched = [0, 0, 0.15, 0.25, 0.35, 0.45, 0.55, 0.60, 0.65];
        var idx   = Math.min(Math.max(age, 0), sched.length - 1);
        return sched[idx];
    }

    function calcDepreciation(crspTzs, year) {
        var rate = depreciationRate(year);
        return {
            vehicleAge:       appYear() - year,
            depreciationRate: rate,
            depreciatedValue: roundN(crspTzs * (1 - rate))
        };
    }

    function calcTaxes(cifValue, engineCC, year) {
        var age       = appYear() - year;
        var excRate   = (engineCC > 2000) ? cRATE_EXCISE_LARGE : cRATE_EXCISE_STD;
        var impDuty   = roundN(cifValue * cRATE_IMPORT_DUTY);
        var excDuty   = roundN(cifValue * excRate);
        var ageFee    = (age > cAGE_LIMIT) ? roundN(cifValue * cRATE_AGE_DUMP) : 0;
        var vatBase   = cifValue + impDuty + excDuty + ageFee;
        var vat       = roundN(vatBase * cRATE_VAT);
        var infraLevy = roundN(cifValue * cRATE_INFRA_LEVY);
        var portLevy  = roundN(cifValue * cRATE_PORT_LEVY);
        var totalTax  = impDuty + excDuty + ageFee + vat + infraLevy + portLevy;
        return {
            cifValue:           roundN(cifValue),
            importDuty:         impDuty,
            exciseDuty:         excDuty,
            exciseRatePct:      excRate * 100,
            ageDumpingFee:      ageFee,
            vat:                vat,
            infrastructureLevy: infraLevy,
            portLevy:           portLevy,
            totalTax:           roundN(totalTax),
            totalPayable:       roundN(cifValue + totalTax),
            vehicleAge:         age
        };
    }

    function fullEstimate(crspTzs, engineCC, year, freight) {
        var dep = calcDepreciation(crspTzs, year);
        return {
            depreciation: dep,
            taxes:        calcTaxes(dep.depreciatedValue + freight, engineCC, year)
        };
    }

    function eligibility(year) {
        var age = appYear() - year;
        return {
            ok:   age <= cAGE_LIMIT,
            age:  age,
            note: (age <= cAGE_LIMIT)
                  ? "\u2713  Within age limit (\u22648 yrs)"
                  : "\u26A0  " + age + " yrs \u2014 30% Dumping Fee"
        };
    }

    function fmtTZS(n) {
        if ((n === undefined) || (n === null) || isNaN(n)) {
            return "TZS \u2014";
        }
        var s   = Math.round(n).toString();
        var out = "";
        for (var i = 0; i < s.length; i++) {
            if ((i > 0) && ((s.length - i) % 3 === 0)) {
                out += ",";
            }
            out += s[i];
        }
        return "TZS " + out;
    }

    function mockCrsp(engineCC) {
        return 22000000 + (engineCC * 4800);
    }

    // ════════════════════════════════════════════════════════════════════════
    // JS: Generic XHR helpers
    // ════════════════════════════════════════════════════════════════════════
    function apiGet(endpoint, onOk, onFail) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", cAPI_BASE + endpoint);
        xhr.setRequestHeader("Accept", "application/json");
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) { return; }
            if (xhr.status === 200) {
                try {
                    onOk(JSON.parse(xhr.responseText));
                } catch (e) {
                    onFail("Parse error: " + e);
                }
            } else {
                onFail("HTTP " + xhr.status);
            }
        };
        xhr.send();
    }

    function apiPost(endpoint, payload, onOk, onFail) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", cAPI_BASE + endpoint);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Accept",       "application/json");
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) { return; }
            if (xhr.status === 200) {
                try {
                    onOk(JSON.parse(xhr.responseText));
                } catch (e) {
                    onFail("Parse error: " + e);
                }
            } else {
                onFail("HTTP " + xhr.status);
            }
        };
        xhr.send(JSON.stringify(payload));
    }

    // Normalise an array element that may be a primitive or an object
    function strFrom(item, keys) {
        if (typeof item === "string") { return item; }
        if (typeof item === "number") { return item.toString(); }
        for (var k = 0; k < keys.length; k++) {
            if (item[keys[k]] !== undefined) {
                return item[keys[k]].toString();
            }
        }
        return JSON.stringify(item);
    }

    // ════════════════════════════════════════════════════════════════════════
    // JS: Portal-flow cascading fetchers
    // ════════════════════════════════════════════════════════════════════════

    // Step 1 — called when Calculator page opens
    function doFetchMakes() {
        loadMakes   = true;
        stepError   = "";
        vMake       = "";
        vModel      = "";
        vBody       = "";
        vYear       = 0;
        vEngine     = 0;
        modelsList  = [];
        bodiesList  = [];
        yearsList   = [];
        enginesList = [];

        apiGet(
            "/api/GetMakes",
            function (data) {
                loadMakes = false;
                var arr = [];
                for (var i = 0; i < data.length; i++) {
                    arr.push(strFrom(data[i], ["make", "Make", "name", "Name", "label", "Label"]));
                }
                arr.sort();
                makesList = arr;
            },
            function (err) {
                loadMakes = false;
                makesList = [
                    "BMW", "Ford", "Honda", "Hyundai", "Isuzu", "Kia", "Land Rover",
                    "Mazda", "Mercedes-Benz", "Mitsubishi", "Nissan", "Subaru",
                    "Suzuki", "Toyota", "Volkswagen"
                ];
            }
        );
    }

    // Step 2 — called when Make is selected
    function doFetchModels(make) {
        loadModels  = true;
        stepError   = "";
        vModel      = "";
        vBody       = "";
        vYear       = 0;
        vEngine     = 0;
        bodiesList  = [];
        yearsList   = [];
        enginesList = [];

        apiGet(
            "/api/GetModels?make=" + encodeURIComponent(make),
            function (data) {
                loadModels = false;
                var arr = [];
                for (var i = 0; i < data.length; i++) {
                    arr.push(strFrom(data[i], ["model", "Model", "name", "Name"]));
                }
                arr.sort();
                modelsList = arr;
            },
            function (err) {
                loadModels = false;
                var fb = {
                    "Toyota":        ["Aqua","Axio","Crown","Fielder","Fortuner","Harrier",
                                      "Hilux","Land Cruiser","Passo","Premio","Probox","RAV4","Rush","Vitz"],
                    "Nissan":        ["AD Van","Dualis","Elgrand","Juke","Leaf","March",
                                      "Murano","Note","Serena","Tiida","X-Trail"],
                    "Honda":         ["Airwave","CR-V","Fit","Freed","HR-V","Insight",
                                      "Jazz","Step WGN","Stream","Vezel"],
                    "Mitsubishi":    ["Canter","Eclipse Cross","L200","Montero",
                                      "Outlander","Pajero","RVR","Triton"],
                    "Isuzu":         ["D-Max","ELF","Forward","MU-X","Trooper"],
                    "Mercedes-Benz": ["C-Class","E-Class","G-Class","GLE","S-Class","Sprinter","Vito"],
                    "BMW":           ["1 Series","3 Series","5 Series","7 Series","X3","X5","X6"],
                    "Mazda":         ["Atenza","Axela","BT-50","CX-3","CX-5","Demio","MPV"],
                    "Subaru":        ["Forester","Impreza","Legacy","Outback","XV"],
                    "Land Rover":    ["Defender","Discovery","Freelander","Range Rover"],
                    "Ford":          ["Courier","Ecosport","Everest","Explorer","Ranger"],
                    "Hyundai":       ["Creta","H-1","i10","i20","Santa Fe","Tucson"],
                    "Kia":           ["Picanto","Rio","Seltos","Sorento","Sportage"],
                    "Suzuki":        ["Alto","Baleno","Ertiga","Grand Vitara","Jimny","Swift","Vitara"],
                    "Volkswagen":    ["Amarok","Golf","Passat","Polo","Tiguan","Touareg"]
                };
                modelsList = fb[make] || ["(Not listed \u2014 use Missing Vehicle)"];
            }
        );
    }

    // Step 3 — called when Model is selected
    function doFetchBodies(make, model) {
        loadBodies  = true;
        stepError   = "";
        vBody       = "";
        vYear       = 0;
        vEngine     = 0;
        yearsList   = [];
        enginesList = [];

        apiGet(
            "/api/GetBodyTypes?make=" + encodeURIComponent(make)
                + "&model=" + encodeURIComponent(model),
            function (data) {
                loadBodies = false;
                var arr = [];
                for (var i = 0; i < data.length; i++) {
                    arr.push(strFrom(data[i], ["bodyType","BodyType","body","Body","name","Name"]));
                }
                bodiesList = arr;
            },
            function (err) {
                loadBodies = false;
                bodiesList = [
                    "Sedan","Hatchback","SUV","Station Wagon",
                    "Pickup","Minivan","Bus","Truck","Coupe","Convertible"
                ];
            }
        );
    }

    // Step 4 — called when Body Type is selected
    function doFetchYears(make, model, body) {
        loadYears   = true;
        stepError   = "";
        vYear       = 0;
        vEngine     = 0;
        enginesList = [];

        apiGet(
            "/api/GetYears?make="     + encodeURIComponent(make)
                + "&model="           + encodeURIComponent(model)
                + "&bodyType="        + encodeURIComponent(body),
            function (data) {
                loadYears = false;
                var arr = [];
                for (var i = 0; i < data.length; i++) {
                    var y = parseInt(strFrom(data[i], ["year","Year"]));
                    if (!isNaN(y)) {
                        arr.push(y);
                    }
                }
                arr.sort(function (a, b) { return b - a; });
                yearsList = arr;
            },
            function (err) {
                loadYears = false;
                var arr = [];
                var cy  = appYear();
                for (var i = 0; i <= 12; i++) {
                    arr.push(cy - i);
                }
                yearsList = arr;
            }
        );
    }

    // Step 5 — called when Year is selected
    function doFetchEngines(make, model, body, year) {
        loadEngines = true;
        stepError   = "";
        vEngine     = 0;

        apiGet(
            "/api/GetEngineCapacities?make=" + encodeURIComponent(make)
                + "&model="    + encodeURIComponent(model)
                + "&bodyType=" + encodeURIComponent(body)
                + "&year="     + year,
            function (data) {
                loadEngines = false;
                var arr = [];
                for (var i = 0; i < data.length; i++) {
                    var cc = parseInt(strFrom(data[i], ["engineCapacity","EngineCapacity","cc","CC"]));
                    if (!isNaN(cc)) {
                        arr.push(cc);
                    }
                }
                arr.sort(function (a, b) { return a - b; });
                enginesList = arr;
            },
            function (err) {
                loadEngines = false;
                enginesList = [
                    660, 800, 1000, 1300, 1400, 1500, 1600, 1800,
                    2000, 2200, 2500, 2700, 3000, 3500, 4000, 4500, 4800
                ];
            }
        );
    }

    // Step 6 — POST valuation and navigate to Results
    function doFetchValuation() {
        loadResult = true;
        stepError  = "";
        var payload = {
            make:           vMake,
            model:          vModel,
            bodyType:       vBody,
            year:           vYear,
            fuelType:       vFuel,
            engineCapacity: vEngine,
            countryOrigin:  vOrigin
        };
        apiPost(
            "/api/valuation",
            payload,
            function (data) {
                loadResult      = false;
                valuationResult = data;
                taxResult       = fullEstimate(
                    data.crspTzs || mockCrsp(vEngine),
                    vEngine, vYear, vFreight
                );
                currentPage = 2;
                app.ad();
            },
            function (err) {
                // Demo / offline fallback — always show results
                loadResult      = false;
                var crsp        = mockCrsp(vEngine);
                valuationResult = {
                    referenceCode:  "TRA-DEMO-" + vYear,
                    make:           vMake,
                    model:          vModel,
                    bodyType:       vBody,
                    year:           vYear,
                    engineCapacity: vEngine,
                    fuelType:       vFuel,
                    crsp:           Math.round(crsp / 2500),
                    crspTzs:        crsp,
                    currency:       "TZS"
                };
                taxResult   = fullEstimate(crsp, vEngine, vYear, vFreight);
                currentPage = 2;
                app.ad();
            }
        );
    }

    // Reference-code lookup
    function doFetchByRef() {
        if (!refCode.trim()) { return; }
        refLoading = true;
        refError   = "";
        apiGet(
            "/api/valuation/reference/" + encodeURIComponent(refCode.trim()),
            function (data) {
                refLoading      = false;
                vMake           = data.make           || "";
                vModel          = data.model          || "";
                vBody           = data.bodyType       || "";
                vYear           = data.year           || 0;
                vEngine         = data.engineCapacity || 0;
                vFuel           = data.fuelType       || "Petrol";
                valuationResult = data;
                taxResult       = fullEstimate(
                    data.crspTzs || mockCrsp(vEngine),
                    vEngine, vYear, vFreight
                );
                currentPage = 2;
                app.ad();
            },
            function (err) {
                refLoading = false;
                refError   = "Reference code not found.";
            }
        );
    }

    // Offline side-by-side comparison
    function doRunComparison() {
        cmpA = fullEstimate(mockCrsp(vEngine), vEngine, vYear,   vFreight);
        cmpB = fullEstimate(mockCrsp(bEngine), bEngine, bYear,   vFreight);
    }

    // Submit missing vehicle
    function doSubmitMissing() {
        mvLoading = true;
        var payload = {
            make:          vMake,
            model:         vModel,
            bodyType:      vBody,
            year:          vYear,
            fuelType:       vFuel,
            engineCapacity: vEngine,
            countryOrigin:  vOrigin,
            contactEmail:   mvEmail
        };
        apiPost(
            "/api/missing-vehicle",
            payload,
            function (d)   { mvLoading = false; mvSubmitted = true; app.ad();},
            function (err) { mvLoading = false; mvSubmitted = true; }
        );
    }

    // ════════════════════════════════════════════════════════════════════════
    // Root rectangle
    // ════════════════════════════════════════════════════════════════════════
    Rectangle {
        id:           rootRect
        anchors.fill: parent
        color:        app.cBg

        ColumnLayout {
            anchors.fill: parent
            spacing:      0

            // ════════════════════════════════════════════════════════════
            // HEADER
            // ════════════════════════════════════════════════════════════
            Rectangle {
                id:               header
                Layout.fillWidth: true
                height:           app.mob ? 56 : 62
                color:            app.cSurface

                Rectangle {
                    anchors.bottom: parent.bottom
                    width:          parent.width
                    height:         2
                    color:          app.cGold
                }

                RowLayout {
                    anchors.fill:        parent
                    anchors.leftMargin:  app.margin
                    anchors.rightMargin: app.margin
                    spacing:             12

                    // Logo badge
                    Rectangle {
                        width:  app.mob ? 34 : 40
                        height: app.mob ? 34 : 40
                        radius: 8
                        color:  app.cGold

                        Text {
                            anchors.centerIn: parent
                            text:             "TZ"
                            font.pixelSize:   app.mob ? 10 : 11
                            font.bold:        true
                            color:            "#000000"
                        }
                    }

                    Column {
                        spacing:          1
                        Layout.fillWidth: true

                        Text {
                            text:           "Used Motor Vehicle Valuation System"
                            font.pixelSize: app.mob ? 12 : 13
                            font.bold:      true
                            color:          app.cText
                        }

                        Text {
                            text:           ""
                            font.pixelSize: app.mob ? 9 : 10
                            color:          app.cMuted
                        }
                    }

                    // Desktop navigation tabs — hidden on mobile (footer handles that)
                    Repeater {
                        model: [
                            { lbl: "Home",     pg: 0 },
                            { lbl: "Valuate",  pg: 1 },
                            { lbl: "Compare",  pg: 3 },
                            { lbl: "Ref Code", pg: 4 },
                            { lbl: "Missing",  pg: 5 }
                        ]

                        delegate: Rectangle {
                            visible:      !app.mob
                            width:        78
                            height:       34
                            radius:       6
                            color:        app.currentPage === modelData.pg ? app.cGold : "transparent"
                            border.color: app.currentPage === modelData.pg ? app.cGold : app.cBorder
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text:             modelData.lbl
                                font.pixelSize:   11
                                font.bold:        app.currentPage === modelData.pg
                                color:            app.currentPage === modelData.pg ? "#000000" : app.cMuted
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.pg === 1) { app.doFetchMakes(); }
                                    app.currentPage = modelData.pg;
                                }
                            }

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }
                }
            }

            // ════════════════════════════════════════════════════════════
            // PAGE STACK
            // ════════════════════════════════════════════════════════════
            StackLayout {
                id:                pageStack
                Layout.fillWidth:  true
                Layout.fillHeight: true
                currentIndex:      app.currentPage

                // ── PAGE 0  HOME ─────────────────────────────────────────
                Flickable {
                    clip:          true
                    contentWidth:  width
                    contentHeight: homeCol.implicitHeight + 60

                    Column {
                        id:                       homeCol
                        width:                    app.colW
                        anchors.horizontalCenter: parent.horizontalCenter
                        topPadding:               app.mob ? 24 : 48
                        bottomPadding:            40
                        spacing:                  app.mob ? 20 : 32

                        // Hero
                        Column {
                            width:   parent.width
                            spacing: 10

                            Text {
                                width:               parent.width
                                text:                "UMVVS Calculator"
                                font.pixelSize:      app.mob ? 28 : 38
                                font.bold:           true
                                color:               app.cGold
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Text {
                                width:               parent.width
                                text:                "Estimate import duties & taxes on used motor vehicles\nentering Tanzania under TRA\u2019s EAC valuation framework."
                                font.pixelSize:      13
                                color:               app.cMuted
                                horizontalAlignment: Text.AlignHCenter
                                lineHeight:          1.5
                                wrapMode:            Text.Wrap
                            }
                        }

                        // Primary CTA
                        Rectangle {
                            width:  parent.width
                            height: 62
                            radius: 12
                            color:  app.cGold

                            Column {
                                anchors.centerIn: parent
                                spacing:          3

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text:           "\u2295  Start Vehicle Valuation"
                                    font.pixelSize: app.mob ? 15 : 16
                                    font.bold:      true
                                    color:          "#000000"
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text:           "Select Make \u2192 Model \u2192 Body \u2192 Year \u2192 Engine"
                                    font.pixelSize: 10
                                    color:          Qt.rgba(0, 0, 0, 0.5)
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: {
                                    app.doFetchMakes();
                                    app.currentPage = 1;
                                }
                            }
                        }

                        // Feature cards
                        Grid {
                            width:         parent.width
                            columns:       app.mob ? 1 : 3
                            columnSpacing: 12
                            rowSpacing:    12

                            Repeater {
                                model: [
                                    { icon: "\u21C4", title: "Compare Vehicles",
                                      desc: "Side-by-side import tax comparison.",       pg: 3 },
                                    { icon: "#",      title: "Reference Lookup",
                                      desc: "Retrieve a valuation via TRA ref code.",    pg: 4 },
                                    { icon: "\u270E", title: "Missing Vehicle",
                                      desc: "Submit an unlisted vehicle for review.",    pg: 5 }
                                ]

                                delegate: Rectangle {
                                    width:        app.mob ? homeCol.width
                                                           : (homeCol.width - 24) / 3
                                    height:       app.mob ? 76 : 120
                                    radius:       10
                                    color:        app.cCard
                                    border.color: app.cBorder
                                    border.width: 1

                                    // Top accent bar
                                    Rectangle {
                                        anchors.top:   parent.top
                                        anchors.left:  parent.left
                                        anchors.right: parent.right
                                        height:        3
                                        radius:        3
                                        color:         app.cGold
                                    }

                                    Rectangle {
                                        id:           cardTint
                                        anchors.fill: parent
                                        radius:       10
                                        color:        "white"
                                        opacity:      0
                                        Behavior on opacity { NumberAnimation { duration: 130 } }
                                    }

                                    // Mobile layout: icon + text side by side
                                    Row {
                                        visible:  app.mob
                                        anchors.fill:    parent
                                        anchors.margins: 14
                                        spacing:         12

                                        Text {
                                            text:                   modelData.icon
                                            font.pixelSize:         22
                                            color:                  app.cGold
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Column {
                                            spacing:                3
                                            width:                  parent.width - 34
                                            anchors.verticalCenter: parent.verticalCenter

                                            Text { text: modelData.title; font.pixelSize: 13; font.bold: true; color: app.cText }
                                            Text { text: modelData.desc; font.pixelSize: 11; color: app.cMuted; wrapMode: Text.Wrap; width: parent.width }
                                        }
                                    }

                                    // Desktop layout: stacked
                                    Column {
                                        visible:         !app.mob
                                        anchors.fill:    parent
                                        anchors.margins: 16
                                        anchors.topMargin: 18
                                        spacing:         7

                                        Text { text: modelData.icon; font.pixelSize: 22; color: app.cGold }
                                        Text { text: modelData.title; font.pixelSize: 13; font.bold: true; color: app.cText }
                                        Text { text: modelData.desc; font.pixelSize: 11; color: app.cMuted; wrapMode: Text.Wrap; width: parent.width; lineHeight: 1.4 }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape:  Qt.PointingHandCursor
                                        onEntered:    { cardTint.opacity = 0.04; }
                                        onExited:     { cardTint.opacity = 0; }
                                        onClicked:    { app.currentPage = modelData.pg; }
                                    }
                                }
                            }
                        }

                        // EAC tax rate reference strip
                        Rectangle {
                            width:        parent.width
                            height:       rateCol.implicitHeight + 28
                            radius:       10
                            color:        app.cCard
                            border.color: app.cBorder
                            border.width: 1

                            Column {
                                id:      rateCol
                                anchors.fill:    parent
                                anchors.margins: 16
                                spacing:         10

                                Text {
                                    text:           "EAC Import Tax Rates  (2024 / 25)"
                                    font.pixelSize: 12
                                    font.bold:      true
                                    color:          app.cGold
                                }

                                Flow {
                                    width:   parent.width
                                    spacing: 12

                                    Repeater {
                                        model: [
                                            { v: "25%",  l: "Import Duty"         },
                                            { v: "10%",  l: "Excise \u22642000cc" },
                                            { v: "25%",  l: "Excise >2000cc"      },
                                            { v: "18%",  l: "VAT"                 },
                                            { v: "1.5%", l: "Infra Levy"          },
                                            { v: "0.5%", l: "Port Levy"           },
                                            { v: "30%",  l: "Age Dumping"         }
                                        ]

                                        delegate: Row {
                                            spacing: 4
                                            Text { text: modelData.v; font.pixelSize: 14; font.bold: true; color: app.cGoldLight }
                                            Text {
                                                text:                   modelData.l
                                                font.pixelSize:         10
                                                color:                  app.cMuted
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── PAGE 1  CALCULATOR ────────────────────────────────────
                Flickable {
                    id:            calcFlick
                    clip:          true
                    contentWidth:  width
                    contentHeight: calcCol.implicitHeight + 80

                    Column {
                        id:                       calcCol
                        width:                    app.colW
                        anchors.horizontalCenter: parent.horizontalCenter
                        topPadding:               app.mob ? 20 : 32
                        bottomPadding:            40
                        spacing:                  18

                        // Title row
                        RowLayout {
                            width: parent.width

                            Column {
                                spacing:          3
                                Layout.fillWidth: true

                                Text {
                                    text:           "Vehicle Valuation"
                                    font.pixelSize: app.titleF
                                    font.bold:      true
                                    color:          app.cGold
                                }

                                Text {
                                    text:           "Follow the steps below to identify your vehicle"
                                    font.pixelSize: 11
                                    color:          app.cMuted
                                }
                            }

                            BusyIndicator {
                                width:   26
                                height:  26
                                running: app.loadMakes   || app.loadModels  ||
                                         app.loadBodies  || app.loadYears   ||
                                         app.loadEngines || app.loadResult
                            }
                        }

                        // Progress stepper strip
                        Rectangle {
                            width:        parent.width
                            height:       44
                            radius:       8
                            color:        app.cCard
                            border.color: app.cBorder
                            border.width: 1

                            Row {
                                anchors.centerIn: parent
                                spacing:          0

                                Repeater {
                                    model: ["Make", "Model", "Body", "Year", "Engine", "Taxes"]

                                    delegate: Row {
                                        spacing: 0

                                        // Compute done/active state with explicit JS blocks + return
                                        readonly property bool stepDone: {
                                            if (index === 0) { return app.vMake   !== ""; }
                                            if (index === 1) { return app.vModel  !== ""; }
                                            if (index === 2) { return app.vBody   !== ""; }
                                            if (index === 3) { return app.vYear   >   0;  }
                                            if (index === 4) { return app.vEngine >   0;  }
                                            return app.currentPage === 2;
                                        }

                                        readonly property bool stepActive: {
                                            if (index === 0) { return app.makesList.length > 0; }
                                            if (index === 1) { return app.vMake   !== ""; }
                                            if (index === 2) { return app.vModel  !== ""; }
                                            if (index === 3) { return app.vBody   !== ""; }
                                            if (index === 4) { return app.vYear   >   0;  }
                                            return app.vEngine > 0;
                                        }

                                        // Connecting line between steps (skip first)
                                        Rectangle {
                                            visible:                index > 0
                                            width:                  app.mob ? 8 : 14
                                            height:                 2
                                            color:                  stepDone ? app.cGold : app.cBorder
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        // Step circle
                                        Rectangle {
                                            width:        app.mob ? 32 : 40
                                            height:       26
                                            radius:       13
                                            color:        stepDone   ? app.cGold
                                                        : stepActive ? Qt.rgba(0.83, 0.63, 0.09, 0.15)
                                                        : "transparent"
                                            border.color: stepDone   ? app.cGold
                                                        : stepActive ? app.cGold
                                                        : app.cBorder
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text:             stepDone ? "\u2713" : modelData
                                                font.pixelSize:   app.mob ? 8 : 9
                                                font.bold:        true
                                                color:            stepDone   ? "#000000"
                                                                : stepActive ? app.cGold
                                                                : app.cMuted
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // ── STEP 1  MAKE ──────────────────────────────────
                        Column {
                            width:   parent.width
                            spacing: 6

                            Row {
                                spacing: 8
                                Text {
                                    text:                   "1. Vehicle Make"
                                    font.pixelSize:         app.labelF
                                    font.bold:              true
                                    color:                  app.cMuted
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                BusyIndicator {
                                    width:   16
                                    height:  16
                                    running: app.loadMakes
                                    visible: app.loadMakes
                                }
                            }

                            ComboBox {
                                id:           makeCombo
                                width:        parent.width
                                height:       app.inputH
                                model:        app.makesList
                                enabled:      app.makesList.length > 0 && !app.loadMakes
                                currentIndex: app.vMake !== "" ? app.makesList.indexOf(app.vMake) : -1

                                background: Rectangle {
                                    color:        app.cInput
                                    radius:       8
                                    border.color: makeCombo.activeFocus ? app.cGold : app.cBorder
                                    border.width: makeCombo.activeFocus ? 2 : 1
                                }

                                contentItem: Text {
                                    leftPadding:       14
                                    rightPadding:      32
                                    text:              makeCombo.currentIndex < 0
                                                       ? (app.loadMakes ? "Loading makes\u2026" : "Select Make \u2014 tap to load")
                                                       : makeCombo.displayText
                                    font.pixelSize:    13
                                    color:             makeCombo.currentIndex < 0 ? app.cMuted : app.cText
                                    verticalAlignment: Text.AlignVCenter
                                    elide:             Text.ElideRight
                                }

                                // Chevron
                                Text {
                                    anchors.right:          parent.right
                                    anchors.rightMargin:    12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text:                   "\u25BE"
                                    font.pixelSize:         12
                                    color:                  app.cMuted
                                }

                                delegate: ItemDelegate {
                                    width:       makeCombo.width
                                    highlighted: makeCombo.highlightedIndex === index
                                    contentItem: Text {
                                        leftPadding:       14
                                        text:              modelData
                                        font.pixelSize:    13
                                        color:             parent.highlighted ? app.cGold : app.cText
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        color: parent.highlighted
                                               ? Qt.rgba(0.83, 0.63, 0.09, 0.18)
                                               : app.cCard
                                    }
                                }

                                popup: Popup {
                                    y:       makeCombo.height + 2
                                    width:   makeCombo.width
                                    padding: 0
                                    background: Rectangle {
                                        color:        app.cCard
                                        radius:       8
                                        border.color: app.cBorder
                                        border.width: 1
                                    }
                                    contentItem: ListView {
                                        clip:                     true
                                        implicitHeight:           Math.min(contentHeight, 240)
                                        model:                    makeCombo.delegateModel
                                        ScrollIndicator.vertical: ScrollIndicator {}
                                    }
                                }

                                onActivated: {
                                    var sel    = app.makesList[currentIndex];
                                    app.vMake = sel;
                                    app.doFetchModels(sel);
                                }
                            }

                            // Hint when list is empty
                            Text {
                                visible:        app.makesList.length === 0 && !app.loadMakes
                                text:           "\u21BA  Tap above or here to load makes from TRA"
                                font.pixelSize: 11
                                color:          app.cBlue
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked:    { app.doFetchMakes(); }
                                }
                            }
                        }

                        // ── STEP 2  MODEL ─────────────────────────────────
                        Column {
                            width:   parent.width
                            spacing: 6
                            opacity: app.vMake !== "" ? 1.0 : 0.4
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            Row {
                                spacing: 8
                                Text {
                                    text:                   "2. Vehicle Model"
                                    font.pixelSize:         app.labelF
                                    font.bold:              true
                                    color:                  app.cMuted
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                BusyIndicator {
                                    width:   16
                                    height:  16
                                    running: app.loadModels
                                    visible: app.loadModels
                                }
                            }

                            ComboBox {
                                id:           modelCombo
                                width:        parent.width
                                height:       app.inputH
                                model:        app.modelsList
                                enabled:      app.modelsList.length > 0 && !app.loadModels
                                currentIndex: app.vModel !== "" ? app.modelsList.indexOf(app.vModel) : -1

                                background: Rectangle {
                                    color:        app.cInput
                                    radius:       8
                                    border.color: modelCombo.activeFocus ? app.cGold : app.cBorder
                                    border.width: modelCombo.activeFocus ? 2 : 1
                                }

                                contentItem: Text {
                                    leftPadding:       14
                                    rightPadding:      32
                                    text:              modelCombo.currentIndex < 0
                                                       ? (app.loadModels ? "Loading models\u2026"
                                                         : app.vMake !== "" ? "Select Model\u2026"
                                                         : "Select Make first")
                                                       : modelCombo.displayText
                                    font.pixelSize:    13
                                    color:             modelCombo.currentIndex < 0 ? app.cMuted : app.cText
                                    verticalAlignment: Text.AlignVCenter
                                    elide:             Text.ElideRight
                                }

                                Text {
                                    anchors.right:          parent.right
                                    anchors.rightMargin:    12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text:                   "\u25BE"
                                    font.pixelSize:         12
                                    color:                  app.cMuted
                                }

                                delegate: ItemDelegate {
                                    width:       modelCombo.width
                                    highlighted: modelCombo.highlightedIndex === index
                                    contentItem: Text {
                                        leftPadding:       14
                                        text:              modelData
                                        font.pixelSize:    13
                                        color:             parent.highlighted ? app.cGold : app.cText
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        color: parent.highlighted
                                               ? Qt.rgba(0.83, 0.63, 0.09, 0.18)
                                               : app.cCard
                                    }
                                }

                                popup: Popup {
                                    y:       modelCombo.height + 2
                                    width:   modelCombo.width
                                    padding: 0
                                    background: Rectangle {
                                        color:        app.cCard
                                        radius:       8
                                        border.color: app.cBorder
                                        border.width: 1
                                    }
                                    contentItem: ListView {
                                        clip:                     true
                                        implicitHeight:           Math.min(contentHeight, 240)
                                        model:                    modelCombo.delegateModel
                                        ScrollIndicator.vertical: ScrollIndicator {}
                                    }
                                }

                                onActivated: {
                                    var sel     = app.modelsList[currentIndex];
                                    app.vModel = sel;
                                    app.doFetchBodies(app.vMake, sel);
                                }
                            }
                        }

                        // ── STEP 3  BODY TYPE ─────────────────────────────
                        Column {
                            width:   parent.width
                            spacing: 6
                            opacity: app.vModel !== "" ? 1.0 : 0.4
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            Row {
                                spacing: 8
                                Text {
                                    text:                   "3. Body Type"
                                    font.pixelSize:         app.labelF
                                    font.bold:              true
                                    color:                  app.cMuted
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                BusyIndicator {
                                    width:   16
                                    height:  16
                                    running: app.loadBodies
                                    visible: app.loadBodies
                                }
                            }

                            ComboBox {
                                id:           bodyCombo
                                width:        parent.width
                                height:       app.inputH
                                model:        app.bodiesList
                                enabled:      app.bodiesList.length > 0 && !app.loadBodies
                                currentIndex: app.vBody !== "" ? app.bodiesList.indexOf(app.vBody) : -1

                                background: Rectangle {
                                    color:        app.cInput
                                    radius:       8
                                    border.color: bodyCombo.activeFocus ? app.cGold : app.cBorder
                                    border.width: bodyCombo.activeFocus ? 2 : 1
                                }

                                contentItem: Text {
                                    leftPadding:       14
                                    rightPadding:      32
                                    text:              bodyCombo.currentIndex < 0
                                                       ? (app.loadBodies ? "Loading body types\u2026"
                                                         : app.vModel !== "" ? "Select Body Type\u2026"
                                                         : "Select Model first")
                                                       : bodyCombo.displayText
                                    font.pixelSize:    13
                                    color:             bodyCombo.currentIndex < 0 ? app.cMuted : app.cText
                                    verticalAlignment: Text.AlignVCenter
                                    elide:             Text.ElideRight
                                }

                                Text {
                                    anchors.right:          parent.right
                                    anchors.rightMargin:    12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text:                   "\u25BE"
                                    font.pixelSize:         12
                                    color:                  app.cMuted
                                }

                                delegate: ItemDelegate {
                                    width:       bodyCombo.width
                                    highlighted: bodyCombo.highlightedIndex === index
                                    contentItem: Text {
                                        leftPadding:       14
                                        text:              modelData
                                        font.pixelSize:    13
                                        color:             parent.highlighted ? app.cGold : app.cText
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        color: parent.highlighted
                                               ? Qt.rgba(0.83, 0.63, 0.09, 0.18)
                                               : app.cCard
                                    }
                                }

                                popup: Popup {
                                    y:       bodyCombo.height + 2
                                    width:   bodyCombo.width
                                    padding: 0
                                    background: Rectangle {
                                        color:        app.cCard
                                        radius:       8
                                        border.color: app.cBorder
                                        border.width: 1
                                    }
                                    contentItem: ListView {
                                        clip:                     true
                                        implicitHeight:           Math.min(contentHeight, 240)
                                        model:                    bodyCombo.delegateModel
                                        ScrollIndicator.vertical: ScrollIndicator {}
                                    }
                                }

                                onActivated: {
                                    var sel    = app.bodiesList[currentIndex];
                                    app.vBody = sel;
                                    app.doFetchYears(app.vMake, app.vModel, sel);
                                }
                            }
                        }

                        // ── STEP 4  YEAR ──────────────────────────────────
                        Column {
                            width:   parent.width
                            spacing: 6
                            opacity: app.vBody !== "" ? 1.0 : 0.4
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            RowLayout {
                                width: parent.width

                                Row {
                                    spacing:          8
                                    Layout.fillWidth: true

                                    Text {
                                        text:                   "4. Year of Manufacture"
                                        font.pixelSize:         app.labelF
                                        font.bold:              true
                                        color:                  app.cMuted
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    BusyIndicator {
                                        width:   16
                                        height:  16
                                        running: app.loadYears
                                        visible: app.loadYears
                                    }
                                }

                                // Live eligibility badge
                                Rectangle {
                                    visible:      app.vYear > 0
                                    height:       24
                                    width:        eligTxt.implicitWidth + 18
                                    radius:       12
                                    color:        app.vYear > 0 && app.eligibility(app.vYear).ok
                                                  ? Qt.rgba(0.13, 0.77, 0.37, 0.2)
                                                  : Qt.rgba(0.94, 0.27, 0.27, 0.2)

                                    Text {
                                        id:               eligTxt
                                        anchors.centerIn: parent
                                        text:             app.vYear > 0 ? app.eligibility(app.vYear).note : ""
                                        font.pixelSize:   9
                                        color:            app.vYear > 0
                                                          ? (app.eligibility(app.vYear).ok ? app.cGreen : app.cRed)
                                                          : app.cMuted
                                    }
                                }
                            }

                            ComboBox {
                                id:      yearCombo
                                width:   parent.width
                                height:  app.inputH
                                enabled: app.yearsList.length > 0 && !app.loadYears
                                currentIndex: app.vYear > 0 ? app.yearsList.indexOf(app.vYear) : -1

                                model: {
                                    var s = [];
                                    for (var i = 0; i < app.yearsList.length; i++) {
                                        s.push(app.yearsList[i].toString());
                                    }
                                    return s;
                                }

                                background: Rectangle {
                                    color:        app.cInput
                                    radius:       8
                                    border.color: yearCombo.activeFocus ? app.cGold : app.cBorder
                                    border.width: yearCombo.activeFocus ? 2 : 1
                                }

                                contentItem: Text {
                                    leftPadding:       14
                                    rightPadding:      32
                                    text:              yearCombo.currentIndex < 0
                                                       ? (app.loadYears ? "Loading years\u2026"
                                                         : app.vBody !== "" ? "Select Year\u2026"
                                                         : "Select Body Type first")
                                                       : yearCombo.displayText
                                    font.pixelSize:    13
                                    color:             yearCombo.currentIndex < 0 ? app.cMuted : app.cText
                                    verticalAlignment: Text.AlignVCenter
                                    elide:             Text.ElideRight
                                }

                                Text {
                                    anchors.right:          parent.right
                                    anchors.rightMargin:    12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text:                   "\u25BE"
                                    font.pixelSize:         12
                                    color:                  app.cMuted
                                }

                                delegate: ItemDelegate {
                                    width:       yearCombo.width
                                    highlighted: yearCombo.highlightedIndex === index
                                    contentItem: Text {
                                        leftPadding:       14
                                        text:              modelData
                                        font.pixelSize:    13
                                        color:             parent.highlighted ? app.cGold : app.cText
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        color: parent.highlighted
                                               ? Qt.rgba(0.83, 0.63, 0.09, 0.18)
                                               : app.cCard
                                    }
                                }

                                popup: Popup {
                                    y:       yearCombo.height + 2
                                    width:   yearCombo.width
                                    padding: 0
                                    background: Rectangle {
                                        color:        app.cCard
                                        radius:       8
                                        border.color: app.cBorder
                                        border.width: 1
                                    }
                                    contentItem: ListView {
                                        clip:                     true
                                        implicitHeight:           Math.min(contentHeight, 240)
                                        model:                    yearCombo.delegateModel
                                        ScrollIndicator.vertical: ScrollIndicator {}
                                    }
                                }

                                onActivated: {
                                    var y      = app.yearsList[currentIndex];
                                    app.vYear = y;
                                    app.doFetchEngines(app.vMake, app.vModel, app.vBody, y);
                                }
                            }
                        }

                        // ── STEP 5  ENGINE ────────────────────────────────
                        Column {
                            width:   parent.width
                            spacing: 6
                            opacity: app.vYear > 0 ? 1.0 : 0.4
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            RowLayout {
                                width: parent.width

                                Row {
                                    spacing:          8
                                    Layout.fillWidth: true

                                    Text {
                                        text:                   "5. Engine Capacity"
                                        font.pixelSize:         app.labelF
                                        font.bold:              true
                                        color:                  app.cMuted
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    BusyIndicator {
                                        width:   16
                                        height:  16
                                        running: app.loadEngines
                                        visible: app.loadEngines
                                    }
                                }

                                Text {
                                    visible:        app.vEngine > 0
                                    text:           app.vEngine > 2000
                                                    ? "Large \u2014 25% excise"
                                                    : "Standard \u2014 10% excise"
                                    font.pixelSize: 9
                                    color:          app.vEngine > 2000 ? app.cRed : app.cGreen
                                }
                            }

                            ComboBox {
                                id:      engineCombo
                                width:   parent.width
                                height:  app.inputH
                                enabled: app.enginesList.length > 0 && !app.loadEngines
                                currentIndex: app.vEngine > 0
                                              ? app.enginesList.indexOf(app.vEngine)
                                              : -1

                                model: {
                                    var s = [];
                                    for (var i = 0; i < app.enginesList.length; i++) {
                                        s.push(app.enginesList[i] + " cc");
                                    }
                                    return s;
                                }

                                background: Rectangle {
                                    color:        app.cInput
                                    radius:       8
                                    border.color: engineCombo.activeFocus ? app.cGold : app.cBorder
                                    border.width: engineCombo.activeFocus ? 2 : 1
                                }

                                contentItem: Text {
                                    leftPadding:       14
                                    rightPadding:      32
                                    text:              engineCombo.currentIndex < 0
                                                       ? (app.loadEngines ? "Loading engines\u2026"
                                                         : app.vYear > 0  ? "Select Engine Capacity\u2026"
                                                         : "Select Year first")
                                                       : engineCombo.displayText
                                    font.pixelSize:    13
                                    color:             engineCombo.currentIndex < 0 ? app.cMuted : app.cText
                                    verticalAlignment: Text.AlignVCenter
                                    elide:             Text.ElideRight
                                }

                                Text {
                                    anchors.right:          parent.right
                                    anchors.rightMargin:    12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text:                   "\u25BE"
                                    font.pixelSize:         12
                                    color:                  app.cMuted
                                }

                                delegate: ItemDelegate {
                                    width:       engineCombo.width
                                    highlighted: engineCombo.highlightedIndex === index
                                    contentItem: Text {
                                        leftPadding:       14
                                        text:              modelData
                                        font.pixelSize:    13
                                        color:             parent.highlighted ? app.cGold : app.cText
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        color: parent.highlighted
                                               ? Qt.rgba(0.83, 0.63, 0.09, 0.18)
                                               : app.cCard
                                    }
                                }

                                popup: Popup {
                                    y:       engineCombo.height + 2
                                    width:   engineCombo.width
                                    padding: 0
                                    background: Rectangle {
                                        color:        app.cCard
                                        radius:       8
                                        border.color: app.cBorder
                                        border.width: 1
                                    }
                                    contentItem: ListView {
                                        clip:                     true
                                        implicitHeight:           Math.min(contentHeight, 240)
                                        model:                    engineCombo.delegateModel
                                        ScrollIndicator.vertical: ScrollIndicator {}
                                    }
                                }

                                onActivated: {
                                    app.vEngine = app.enginesList[currentIndex];
                                }
                            }
                        }

                        // ── Additional details (Fuel / Origin / Freight) ──
                        Rectangle {
                            width:        parent.width
                            height:       addCol.implicitHeight + 28
                            radius:       10
                            color:        app.cCard
                            border.color: app.cBorder
                            border.width: 1

                            Column {
                                id:              addCol
                                anchors.fill:    parent
                                anchors.margins: 16
                                spacing:         14

                                Text {
                                    text:           "Additional Details"
                                    font.pixelSize: app.labelF
                                    font.bold:      true
                                    color:          app.cMuted
                                }

                                GridLayout {
                                    width:         parent.width
                                    columns:       app.cols2
                                    columnSpacing: 14
                                    rowSpacing:    14

                                    // Fuel Type
                                    Column {
                                        spacing:          5
                                        Layout.fillWidth: true

                                        Text {
                                            text:           "Fuel Type"
                                            font.pixelSize: app.labelF
                                            font.bold:      true
                                            color:          app.cMuted
                                        }

                                        ComboBox {
                                            id:      fuelCombo
                                            width:   parent.width
                                            height:  app.inputH
                                            model:   ["Petrol", "Diesel", "Hybrid", "Electric", "CNG"]

                                            background: Rectangle {
                                                color:        app.cInput
                                                radius:       8
                                                border.color: fuelCombo.activeFocus ? app.cGold : app.cBorder
                                                border.width: fuelCombo.activeFocus ? 2 : 1
                                            }

                                            contentItem: Text {
                                                leftPadding:       14
                                                text:              fuelCombo.displayText
                                                font.pixelSize:    13
                                                color:             app.cText
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            Text {
                                                anchors.right:          parent.right
                                                anchors.rightMargin:    12
                                                anchors.verticalCenter: parent.verticalCenter
                                                text:                   "\u25BE"
                                                font.pixelSize:         12
                                                color:                  app.cMuted
                                            }

                                            delegate: ItemDelegate {
                                                width:       fuelCombo.width
                                                highlighted: fuelCombo.highlightedIndex === index
                                                contentItem: Text {
                                                    leftPadding: 14; text: modelData; font.pixelSize: 13
                                                    color: parent.highlighted ? app.cGold : app.cText
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                background: Rectangle {
                                                    color: parent.highlighted ? Qt.rgba(0.83,0.63,0.09,0.18) : app.cCard
                                                }
                                            }

                                            popup: Popup {
                                                y: fuelCombo.height + 2; width: fuelCombo.width; padding: 0
                                                background: Rectangle { color: app.cCard; radius: 8; border.color: app.cBorder; border.width: 1 }
                                                contentItem: ListView {
                                                    clip: true; implicitHeight: Math.min(contentHeight, 200)
                                                    model: fuelCombo.delegateModel
                                                    ScrollIndicator.vertical: ScrollIndicator {}
                                                }
                                            }

                                            onActivated: { app.vFuel = currentText; }
                                        }
                                    }

                                    // Country of Origin
                                    Column {
                                        spacing:          5
                                        Layout.fillWidth: true

                                        Text {
                                            text:           "Country of Origin"
                                            font.pixelSize: app.labelF
                                            font.bold:      true
                                            color:          app.cMuted
                                        }

                                        ComboBox {
                                            id:    originCombo
                                            width: parent.width; height: app.inputH
                                            model: ["Japan","Germany","United Kingdom","USA","South Africa",
                                                    "India","China","South Korea","France","Italy","Sweden","UAE"]

                                            background: Rectangle {
                                                color: app.cInput; radius: 8
                                                border.color: originCombo.activeFocus ? app.cGold : app.cBorder
                                                border.width: originCombo.activeFocus ? 2 : 1
                                            }

                                            contentItem: Text {
                                                leftPadding: 14; text: originCombo.displayText
                                                font.pixelSize: 13; color: app.cText
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            Text {
                                                anchors.right: parent.right; anchors.rightMargin: 12
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: "\u25BE"; font.pixelSize: 12; color: app.cMuted
                                            }

                                            delegate: ItemDelegate {
                                                width: originCombo.width; highlighted: originCombo.highlightedIndex === index
                                                contentItem: Text {
                                                    leftPadding: 14; text: modelData; font.pixelSize: 13
                                                    color: parent.highlighted ? app.cGold : app.cText
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                background: Rectangle {
                                                    color: parent.highlighted ? Qt.rgba(0.83,0.63,0.09,0.18) : app.cCard
                                                }
                                            }

                                            popup: Popup {
                                                y: originCombo.height + 2; width: originCombo.width; padding: 0
                                                background: Rectangle { color: app.cCard; radius: 8; border.color: app.cBorder; border.width: 1 }
                                                contentItem: ListView {
                                                    clip: true; implicitHeight: Math.min(contentHeight, 240)
                                                    model: originCombo.delegateModel
                                                    ScrollIndicator.vertical: ScrollIndicator {}
                                                }
                                            }

                                            onActivated: { app.vOrigin = currentText; }
                                        }
                                    }

                                    // Freight & Insurance — full grid width
                                    Column {
                                        spacing:           5
                                        Layout.fillWidth:  true
                                        Layout.columnSpan: app.cols2

                                        Text {
                                            text:           "Freight & Insurance (TZS)"
                                            font.pixelSize: app.labelF
                                            font.bold:      true
                                            color:          app.cMuted
                                        }

                                        Rectangle {
                                            width:        parent.width
                                            height:       app.inputH
                                            radius:       8
                                            color:        app.cInput
                                            border.color: app.cBorder
                                            border.width: 1

                                            TextInput {
                                                id:                freightInput
                                                anchors.fill:      parent
                                                anchors.leftMargin:  14
                                                anchors.rightMargin: 14
                                                verticalAlignment:   TextInput.AlignVCenter
                                                font.pixelSize:      13
                                                color:               app.cText
                                                inputMethodHints:    Qt.ImhDigitsOnly

                                                Component.onCompleted: {
                                                    text = app.vFreight.toString();
                                                }

                                                onEditingFinished: {
                                                    var v = parseFloat(text);
                                                    if (!isNaN(v) && v >= 0) {
                                                        app.vFreight = v;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Error banner
                        Rectangle {
                            width:        parent.width
                            height:       40
                            radius:       8
                            visible:      app.stepError !== ""
                            color:        Qt.rgba(0.94, 0.27, 0.27, 0.14)
                            border.color: app.cRed
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text:           app.stepError
                                font.pixelSize: 12
                                color:          app.cRed
                            }
                        }

                        // Calculate button
                        Rectangle {
                            width:  parent.width
                            height: app.btnH
                            radius: 10
                            color:  app.loadResult
                                    ? app.cBorder
                                    : app.vEngine > 0
                                      ? app.cGold
                                      : Qt.rgba(0.83, 0.63, 0.09, 0.3)

                            Behavior on color { ColorAnimation { duration: 180 } }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing:          10

                                BusyIndicator {
                                    width:   22
                                    height:  22
                                    running: app.loadResult
                                    visible: app.loadResult
                                }

                                Text {
                                    text:           app.loadResult
                                                    ? "Calculating\u2026"
                                                    : "\u2295  Calculate Import Taxes"
                                    font.pixelSize: app.mob ? 15 : 16
                                    font.bold:      true
                                    color:          (app.loadResult || app.vEngine === 0)
                                                    ? Qt.rgba(0, 0, 0, 0.45)
                                                    : "#000000"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                enabled:      app.vEngine > 0 && !app.loadResult
                                onClicked: {
                                    app.stepError = "";
                                    app.doFetchValuation();
                                }
                            }
                        }

                        // "Can't find vehicle?" link
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:           "Vehicle not in list? \u2192 Submit for manual valuation"
                            font.pixelSize: 12
                            color:          app.cBlue

                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    { app.currentPage = 5; }
                            }
                        }
                    }
                }

                // ── PAGE 2  RESULTS ──────────────────────────────────────
                Flickable {
                    id:            resFlick
                    clip:          true
                    contentWidth:  width
                    contentHeight: resCol.implicitHeight + 60

                    Column {
                        id:                       resCol
                        width:                    app.colW
                        anchors.horizontalCenter: parent.horizontalCenter
                        topPadding:               app.mob ? 20 : 32
                        bottomPadding:            40
                        spacing:                  14

                        RowLayout {
                            width: parent.width

                            Text {
                                text:           "Valuation Results"
                                font.pixelSize: app.titleF
                                font.bold:      true
                                color:          app.cGold
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                width:        130
                                height:       36
                                radius:       8
                                color:        app.cInput
                                border.color: app.cBorder
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text:           "\u2190  Recalculate"
                                    font.pixelSize: 11
                                    color:          app.cMuted
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked:    { app.currentPage = 1; }
                                }
                            }
                        }

                        // Vehicle identity card
                        Rectangle {
                            width:        parent.width
                            height:       idContent.implicitHeight + 28
                            radius:       10
                            color:        app.cCard
                            border.color: app.cBorder
                            border.width: 1

                            Rectangle {
                                anchors.left:         parent.left
                                anchors.top:          parent.top
                                anchors.bottom:       parent.bottom
                                anchors.topMargin:    10
                                anchors.bottomMargin: 10
                                width:                4
                                radius:               2
                                color:                app.cGold
                            }

                            Column {
                                id:                  idContent
                                anchors.fill:        parent
                                anchors.leftMargin:  22
                                anchors.rightMargin: 16
                                anchors.topMargin:   16
                                anchors.bottomMargin: 16
                                spacing:              8

                                RowLayout {
                                    width: parent.width

                                    Column {
                                        spacing:          4
                                        Layout.fillWidth: true

                                        Text {
                                            width:          parent.width
                                            text:           app.valuationResult
                                                            ? (app.valuationResult.make + " " + app.valuationResult.model)
                                                            : (app.vMake + " " + app.vModel)
                                            font.pixelSize: app.mob ? 17 : 20
                                            font.bold:      true
                                            color:          app.cText
                                            wrapMode:       Text.Wrap
                                        }

                                        Text {
                                            text:           app.vBody + " \u00B7 " + app.vYear
                                                            + " \u00B7 " + app.vEngine + " cc \u00B7 " + app.vFuel
                                            font.pixelSize: 11
                                            color:          app.cMuted
                                        }
                                    }

                                    // Eligibility pill
                                    Rectangle {
                                        height:  26
                                        width:   eligPill.implicitWidth + 18
                                        radius:  13
                                        color:   app.vYear > 0 && app.eligibility(app.vYear).ok
                                                 ? Qt.rgba(0.13, 0.77, 0.37, 0.2)
                                                 : Qt.rgba(0.94, 0.27, 0.27, 0.2)

                                        Text {
                                            id:               eligPill
                                            anchors.centerIn: parent
                                            text:             app.vYear > 0 && app.eligibility(app.vYear).ok
                                                              ? "\u2713 Eligible" : "\u26A0 Dumping"
                                            font.pixelSize:   10
                                            color:            app.vYear > 0 && app.eligibility(app.vYear).ok
                                                              ? app.cGreen : app.cRed
                                        }
                                    }
                                }

                                Text {
                                    text:           "Ref: " + (app.valuationResult
                                                    ? (app.valuationResult.referenceCode || "N/A")
                                                    : "N/A")
                                    font.pixelSize: 10
                                    color:          app.cGoldLight
                                }
                            }
                        }

                        // Metric tiles (2 × 2 grid)
                        Grid {
                            width:         parent.width
                            columns:       2
                            columnSpacing: 10
                            rowSpacing:    10

                            Repeater {
                                model: [
                                    { lbl: "CRSP (USD)",
                                      val: app.valuationResult
                                           ? ("$" + (app.valuationResult.crsp || "\u2014"))
                                           : "\u2014",
                                      accent: app.cGold },
                                    { lbl: "CRSP (TZS)",
                                      val: app.valuationResult
                                           ? app.fmtTZS(app.valuationResult.crspTzs || 0)
                                           : "\u2014",
                                      accent: app.cGold },
                                    { lbl: "Depreciation",
                                      val: app.taxResult
                                           ? ((app.taxResult.depreciation.depreciationRate * 100).toFixed(0) + "%")
                                           : "\u2014",
                                      accent: app.cBlue },
                                    { lbl: "Depreciated Value",
                                      val: app.taxResult
                                           ? app.fmtTZS(app.taxResult.depreciation.depreciatedValue)
                                           : "\u2014",
                                      accent: app.cBlue }
                                ]

                                delegate: Rectangle {
                                    width:        (resCol.width - 10) / 2
                                    height:       76
                                    radius:       10
                                    color:        app.cCard
                                    border.color: app.cBorder
                                    border.width: 1

                                    Column {
                                        anchors.fill:    parent
                                        anchors.margins: 14
                                        spacing:         5

                                        Text { text: modelData.lbl; font.pixelSize: 9; font.bold: true; color: app.cMuted }
                                        Text {
                                            width:          parent.width
                                            text:           modelData.val
                                            font.pixelSize: app.mob ? 12 : 14
                                            font.bold:      true
                                            color:          modelData.accent
                                            wrapMode:       Text.Wrap
                                        }
                                    }
                                }
                            }
                        }

                        // Tax breakdown table
                        Rectangle {
                            width:        parent.width
                            height:       taxTableCol.implicitHeight + 36
                            radius:       10
                            color:        app.cCard
                            border.color: app.cBorder
                            border.width: 1

                            Column {
                                id:                  taxTableCol
                                anchors.fill:        parent
                                anchors.margins:     16
                                anchors.topMargin:   18
                                spacing:             0

                                Text {
                                    text:            "Import Tax Breakdown"
                                    font.pixelSize:  14
                                    font.bold:       true
                                    color:           app.cGold
                                    bottomPadding:   12
                                }

                                // Column header
                                Rectangle {
                                    width:  parent.width
                                    height: 30
                                    radius: 6
                                    color:  Qt.rgba(1, 1, 1, 0.05)

                                    RowLayout {
                                        anchors.fill:        parent
                                        anchors.leftMargin:  10
                                        anchors.rightMargin: 10

                                        Text { Layout.fillWidth: true; text: "Component"; font.pixelSize: 10; font.bold: true; color: app.cMuted }
                                        Text { width: app.mob ? 44 : 64;   text: "Rate";         font.pixelSize: 10; font.bold: true; color: app.cMuted; horizontalAlignment: Text.AlignRight }
                                        Text { width: app.mob ? 106 : 160; text: "Amount (TZS)"; font.pixelSize: 10; font.bold: true; color: app.cMuted; horizontalAlignment: Text.AlignRight }
                                    }
                                }

                                // Data rows
                                Repeater {
                                    model: {
                                        if (!app.taxResult) { return []; }
                                        var t = app.taxResult.taxes;
                                        return [
                                            { l: "CIF Value (Base)",                        r: "\u2014",            a: t.cifValue,          base: true  },
                                            { l: "Import Duty",                             r: "25%",               a: t.importDuty,         base: false },
                                            { l: "Excise Duty (" + t.exciseRatePct + "%)",  r: t.exciseRatePct+"%", a: t.exciseDuty,         base: false },
                                            { l: "Age Dumping Fee (>8 yrs)",                r: "30%",               a: t.ageDumpingFee,      base: false },
                                            { l: "VAT (CIF+Duty+Excise)",                   r: "18%",               a: t.vat,                base: false },
                                            { l: "Infrastructure Levy",                      r: "1.5%",              a: t.infrastructureLevy, base: false },
                                            { l: "Port Development Levy",                   r: "0.5%",              a: t.portLevy,           base: false }
                                        ];
                                    }

                                    delegate: Rectangle {
                                        width:  parent.width
                                        height: app.mob ? 46 : 40
                                        color:  (index % 2 === 0) ? "transparent" : Qt.rgba(1, 1, 1, 0.02)

                                        RowLayout {
                                            anchors.fill:        parent
                                            anchors.leftMargin:  10
                                            anchors.rightMargin: 10

                                            Rectangle {
                                                width:  7
                                                height: 7
                                                radius: 4
                                                color:  modelData.base
                                                        ? app.cBlue
                                                        : (modelData.a === 0 ? app.cBorder : app.cGold)
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text:           modelData.l
                                                font.pixelSize: app.mob ? 11 : 12
                                                color:          modelData.base ? app.cText : app.cMuted
                                                wrapMode:       Text.Wrap
                                            }

                                            Text {
                                                width:               app.mob ? 44 : 64
                                                text:                modelData.r
                                                font.pixelSize:      11
                                                color:               app.cMuted
                                                horizontalAlignment: Text.AlignRight
                                            }

                                            Text {
                                                width:               app.mob ? 106 : 160
                                                text:                app.fmtTZS(modelData.a)
                                                font.pixelSize:      app.mob ? 11 : 12
                                                font.bold:           modelData.base
                                                color:               modelData.base
                                                                     ? app.cBlue
                                                                     : (modelData.a === 0 ? app.cBorder : app.cText)
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }

                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            width:          parent.width
                                            height:         1
                                            color:          app.cBorder
                                            opacity:        0.25
                                        }
                                    }
                                }

                                Rectangle { width: parent.width; height: 1; color: app.cGold; opacity: 0.5 }

                                // Total Tax row
                                Rectangle {
                                    width:  parent.width
                                    height: 46
                                    color:  Qt.rgba(0.83, 0.63, 0.09, 0.10)

                                    RowLayout {
                                        anchors.fill:        parent
                                        anchors.leftMargin:  10
                                        anchors.rightMargin: 10

                                        Text {
                                            Layout.fillWidth: true
                                            text:           "Total Tax"
                                            font.pixelSize: 13
                                            font.bold:      true
                                            color:          app.cText
                                        }

                                        Text {
                                            text:                app.taxResult
                                                                 ? app.fmtTZS(app.taxResult.taxes.totalTax)
                                                                 : "\u2014"
                                            font.pixelSize:      13
                                            font.bold:           true
                                            color:               app.cGoldLight
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }
                                }

                                // Total Payable row
                                Rectangle {
                                    width:  parent.width
                                    height: 58
                                    radius: 8
                                    color:  Qt.rgba(0.83, 0.63, 0.09, 0.20)

                                    RowLayout {
                                        anchors.fill:        parent
                                        anchors.leftMargin:  10
                                        anchors.rightMargin: 10

                                        Text {
                                            Layout.fillWidth: true
                                            text:           "TOTAL PAYABLE"
                                            font.pixelSize: app.mob ? 14 : 16
                                            font.bold:      true
                                            color:          app.cGold
                                        }

                                        Text {
                                            text:                app.taxResult
                                                                 ? app.fmtTZS(app.taxResult.taxes.totalPayable)
                                                                 : "\u2014"
                                            font.pixelSize:      app.mob ? 15 : 18
                                            font.bold:           true
                                            color:               app.cGold
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }
                                }
                            }
                        }

                        // CIF info note
                        Rectangle {
                            width:        parent.width
                            height:       38
                            radius:       8
                            color:        Qt.rgba(0.23, 0.51, 0.97, 0.12)
                            border.color: app.cBlue
                            border.width: 1

                            Text {
                                anchors.centerIn:    parent
                                width:               parent.width - 24
                                text:                "\u2139  CIF = Depreciated CRSP + Freight ("
                                                     + app.fmtTZS(app.vFreight) + ")"
                                font.pixelSize:      10
                                color:               app.cBlue
                                wrapMode:            Text.Wrap
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }

                // ── PAGE 3  COMPARE ──────────────────────────────────────
                Flickable {
                    id:            cmpFlick
                    clip:          true
                    contentWidth:  width
                    contentHeight: cmpCol.implicitHeight + 60

                    Column {
                        id:                       cmpCol
                        width:                    app.colW
                        anchors.horizontalCenter: parent.horizontalCenter
                        topPadding:               app.mob ? 20 : 32
                        bottomPadding:            40
                        spacing:                  16

                        Text {
                            text:           "Compare Vehicles"
                            font.pixelSize: app.titleF
                            font.bold:      true
                            color:          app.cGold
                        }

                        Text {
                            width:          parent.width
                            text:           "Vehicle A is your current selection. Enter Vehicle B details to compare total import taxes."
                            font.pixelSize: 13
                            color:          app.cMuted
                            wrapMode:       Text.Wrap
                        }

                        // Panel A — read-only summary
                        Rectangle {
                            width:        parent.width
                            height:       panACol.implicitHeight + 28
                            radius:       10
                            color:        app.cCard
                            border.color: app.cBorder
                            border.width: 1

                            Rectangle {
                                anchors.top:   parent.top
                                anchors.left:  parent.left
                                anchors.right: parent.right
                                height:        3
                                radius:        3
                                color:         app.cGold
                            }

                            Column {
                                id:                  panACol
                                anchors.fill:        parent
                                anchors.margins:     16
                                anchors.topMargin:   20
                                spacing:             6

                                Text { text: "Vehicle A  (current selection)"; font.pixelSize: 13; font.bold: true; color: app.cGold }

                                Text {
                                    width:          parent.width
                                    text:           app.vMake !== ""
                                                    ? (app.vMake + " " + app.vModel
                                                       + "  \u00B7  " + app.vYear
                                                       + "  \u00B7  " + app.vEngine + " cc")
                                                    : "No vehicle selected \u2014 go to Valuate first"
                                    font.pixelSize: 13
                                    color:          app.cText
                                    wrapMode:       Text.Wrap
                                }

                                Text {
                                    text:           app.vBody + "  \u00B7  " + app.vFuel
                                    font.pixelSize: 11
                                    color:          app.cMuted
                                }
                            }
                        }

                        // Panel B — manual input
                        Rectangle {
                            width:        parent.width
                            height:       panBCol.implicitHeight + 28
                            radius:       10
                            color:        app.cCard
                            border.color: app.cBorder
                            border.width: 1

                            Rectangle {
                                anchors.top:   parent.top
                                anchors.left:  parent.left
                                anchors.right: parent.right
                                height:        3
                                radius:        3
                                color:         app.cBlue
                            }

                            Column {
                                id:                  panBCol
                                anchors.fill:        parent
                                anchors.margins:     16
                                anchors.topMargin:   20
                                spacing:             12

                                Text { text: "Vehicle B"; font.pixelSize: 13; font.bold: true; color: app.cBlue }

                                GridLayout {
                                    width:         parent.width
                                    columns:       app.cols2
                                    columnSpacing: 14
                                    rowSpacing:    12

                                    Column {
                                        spacing:          4
                                        Layout.fillWidth: true

                                        Text { text: "Make"; font.pixelSize: app.labelF; font.bold: true; color: app.cMuted }

                                        Rectangle {
                                            width: parent.width; height: app.inputH; radius: 8
                                            color: app.cInput; border.color: app.cBorder; border.width: 1

                                            TextInput {
                                                anchors.fill:        parent
                                                anchors.leftMargin:  12
                                                anchors.rightMargin: 12
                                                verticalAlignment:   TextInput.AlignVCenter
                                                font.pixelSize:      13
                                                color:               app.cText
                                               // placeholderText:     "e.g. Honda"
                                                onEditingFinished:   { app.bMake = text; }
                                            }
                                        }
                                    }

                                    Column {
                                        spacing:          4
                                        Layout.fillWidth: true

                                        Text { text: "Model"; font.pixelSize: app.labelF; font.bold: true; color: app.cMuted }

                                        Rectangle {
                                            width: parent.width; height: app.inputH; radius: 8
                                            color: app.cInput; border.color: app.cBorder; border.width: 1

                                            TextInput {
                                                anchors.fill:        parent
                                                anchors.leftMargin:  12
                                                anchors.rightMargin: 12
                                                verticalAlignment:   TextInput.AlignVCenter
                                                font.pixelSize:      13
                                                color:               app.cText
                                               // placeholderText:     "e.g. Fit"
                                                onEditingFinished:   { app.bModel = text; }
                                            }
                                        }
                                    }

                                    Column {
                                        spacing:          4
                                        Layout.fillWidth: true

                                        Text { text: "Year"; font.pixelSize: app.labelF; font.bold: true; color: app.cMuted }

                                        Rectangle {
                                            width: parent.width; height: app.inputH; radius: 8
                                            color: app.cInput; border.color: app.cBorder; border.width: 1

                                            TextInput {
                                                anchors.fill:        parent
                                                anchors.leftMargin:  12
                                                anchors.rightMargin: 12
                                                verticalAlignment:   TextInput.AlignVCenter
                                                font.pixelSize:      13
                                                color:               app.cText
                                                inputMethodHints:    Qt.ImhDigitsOnly

                                                Component.onCompleted: {
                                                    text = app.bYear.toString();
                                                }

                                                onEditingFinished: {
                                                    var n = parseInt(text);
                                                    if (!isNaN(n)) { app.bYear = n; }
                                                }
                                            }
                                        }
                                    }

                                    Column {
                                        spacing:          4
                                        Layout.fillWidth: true

                                        Text { text: "Engine (cc)"; font.pixelSize: app.labelF; font.bold: true; color: app.cMuted }

                                        Rectangle {
                                            width: parent.width; height: app.inputH; radius: 8
                                            color: app.cInput; border.color: app.cBorder; border.width: 1

                                            TextInput {
                                                anchors.fill:        parent
                                                anchors.leftMargin:  12
                                                anchors.rightMargin: 12
                                                verticalAlignment:   TextInput.AlignVCenter
                                                font.pixelSize:      13
                                                color:               app.cText
                                                inputMethodHints:    Qt.ImhDigitsOnly

                                                Component.onCompleted: {
                                                    text = app.bEngine.toString();
                                                }

                                                onEditingFinished: {
                                                    var n = parseInt(text);
                                                    if (!isNaN(n) && n > 0) { app.bEngine = n; }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width:  parent.width
                            height: app.btnH
                            radius: 10
                            color:  app.cGold

                            Text {
                                anchors.centerIn: parent
                                text:           "\u21C4  Compare Now"
                                font.pixelSize: app.mob ? 15 : 16
                                font.bold:      true
                                color:          "#000000"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    { app.doRunComparison(); }
                            }
                        }

                        // Comparison results table
                        Rectangle {
                            width:        parent.width
                            height:       cmpResCol.implicitHeight + 32
                            radius:       10
                            visible:      app.cmpA !== null
                            color:        app.cCard
                            border.color: app.cBorder
                            border.width: 1

                            Column {
                                id:                  cmpResCol
                                anchors.fill:        parent
                                anchors.margins:     16
                                anchors.topMargin:   18
                                spacing:             0

                                Text {
                                    text:          "Comparison Results"
                                    font.pixelSize: 14
                                    font.bold:      true
                                    color:          app.cGold
                                    bottomPadding:  10
                                }

                                Rectangle {
                                    width:  parent.width
                                    height: 30
                                    radius: 6
                                    color:  Qt.rgba(1, 1, 1, 0.05)

                                    RowLayout {
                                        anchors.fill:        parent
                                        anchors.leftMargin:  10
                                        anchors.rightMargin: 10

                                        Text { Layout.fillWidth: true; text: "Component"; font.pixelSize: 10; font.bold: true; color: app.cMuted }
                                        Text { width: app.mob ? 100 : 170; text: "Vehicle A"; font.pixelSize: 10; font.bold: true; color: app.cGold; horizontalAlignment: Text.AlignRight }
                                        Text { width: app.mob ? 100 : 170; text: "Vehicle B"; font.pixelSize: 10; font.bold: true; color: app.cBlue; horizontalAlignment: Text.AlignRight }
                                    }
                                }

                                Repeater {
                                    model: ["CIF Value","Import Duty","Excise Duty","Age Dumping",
                                            "VAT","Infra Levy","Port Levy","Total Tax","TOTAL PAYABLE"]

                                    delegate: Rectangle {
                                        width:  parent.width
                                        height: 40
                                        color:  (index % 2 === 0) ? "transparent" : Qt.rgba(1, 1, 1, 0.02)

                                        readonly property bool rowIsTotal: index === 8

                                        readonly property real vA: {
                                            if (!app.cmpA) { return 0; }
                                            var t = app.cmpA.taxes;
                                            var vals = [t.cifValue, t.importDuty, t.exciseDuty,
                                                        t.ageDumpingFee, t.vat, t.infrastructureLevy,
                                                        t.portLevy, t.totalTax, t.totalPayable];
                                            return vals[index] || 0;
                                        }

                                        readonly property real vB: {
                                            if (!app.cmpB) { return 0; }
                                            var t = app.cmpB.taxes;
                                            var vals = [t.cifValue, t.importDuty, t.exciseDuty,
                                                        t.ageDumpingFee, t.vat, t.infrastructureLevy,
                                                        t.portLevy, t.totalTax, t.totalPayable];
                                            return vals[index] || 0;
                                        }

                                        RowLayout {
                                            anchors.fill:        parent
                                            anchors.leftMargin:  10
                                            anchors.rightMargin: 10

                                            Text {
                                                Layout.fillWidth: true
                                                text:           modelData
                                                font.pixelSize: rowIsTotal ? 12 : 11
                                                font.bold:      rowIsTotal
                                                color:          rowIsTotal ? app.cGold : app.cText
                                            }

                                            Text {
                                                width:               app.mob ? 100 : 170
                                                text:                app.fmtTZS(vA)
                                                font.pixelSize:      rowIsTotal ? 12 : 11
                                                font.bold:           rowIsTotal
                                                color:               rowIsTotal ? app.cGold
                                                                     : (vA <= vB ? app.cGreen : app.cText)
                                                horizontalAlignment: Text.AlignRight
                                            }

                                            Text {
                                                width:               app.mob ? 100 : 170
                                                text:                app.fmtTZS(vB)
                                                font.pixelSize:      rowIsTotal ? 12 : 11
                                                font.bold:           rowIsTotal
                                                color:               rowIsTotal ? app.cBlue
                                                                     : (vB <= vA ? app.cGreen : app.cText)
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }

                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            width:          parent.width
                                            height:         1
                                            color:          app.cBorder
                                            opacity:        0.25
                                            visible:        !rowIsTotal
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── PAGE 4  REFERENCE CODE ────────────────────────────────
                Item {
                    id: refPage

                    Column {
                        anchors.centerIn: parent
                        width:   Math.min(refPage.width - app.margin * 2, 460)
                        spacing: 18

                        Text {
                            text:           "Reference Code Lookup"
                            font.pixelSize: app.titleF
                            font.bold:      true
                            color:          app.cGold
                        }

                        Text {
                            width:          parent.width
                            text:           "Enter the TRA UMVVS reference code to retrieve the vehicle\u2019s "
                                            + "CRSP valuation and full import tax breakdown."
                            font.pixelSize: 13
                            color:          app.cMuted
                            wrapMode:       Text.Wrap
                            lineHeight:     1.5
                        }

                        Rectangle {
                            width:        parent.width
                            height:       app.inputH + 8
                            radius:       10
                            color:        app.cCard
                            border.color: app.cBorder
                            border.width: 1

                            RowLayout {
                                anchors.fill:        parent
                                anchors.leftMargin:  16
                                anchors.rightMargin: 16

                                Text { text: "#"; font.pixelSize: 20; color: app.cGold }

                                TextInput {
                                    id:                refInput
                                    Layout.fillWidth:  true
                                    verticalAlignment: TextInput.AlignVCenter
                                    font.pixelSize:    14
                                    color:             app.cText
                                    //placeholderText:   "e.g. TRA-2024-TYC-001"
                                    onEditingFinished: { app.refCode = text; }
                                }

                                BusyIndicator {
                                    width:   24
                                    height:  24
                                    running: app.refLoading
                                    visible: app.refLoading
                                }
                            }
                        }

                        Rectangle {
                            width:        parent.width
                            height:       38
                            radius:       8
                            visible:      app.refError !== ""
                            color:        Qt.rgba(0.94, 0.27, 0.27, 0.14)
                            border.color: app.cRed
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text:           app.refError
                                font.pixelSize: 12
                                color:          app.cRed
                            }
                        }

                        Rectangle {
                            width:  parent.width
                            height: app.btnH
                            radius: 10
                            color:  app.cGold

                            Text {
                                anchors.centerIn: parent
                                text:           "#  Search Reference"
                                font.pixelSize: app.mob ? 15 : 16
                                font.bold:      true
                                color:          "#000000"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: {
                                    app.refCode = refInput.text;
                                    app.refError = "";
                                    app.doFetchByRef();
                                }
                            }
                        }

                        Text {
                            width:               parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text:                "Reference codes appear on TRA import declarations "
                                                 + "and UMVVS valuation certificates."
                            font.pixelSize:      11
                            color:               app.cMuted
                            wrapMode:            Text.Wrap
                        }
                    }
                }

                // ── PAGE 5  MISSING VEHICLE ───────────────────────────────
                Flickable {
                    id:            mvFlick
                    clip:          true
                    contentWidth:  width
                    contentHeight: mvMainCol.implicitHeight + 60

                    Column {
                        id:                       mvMainCol
                        width:                    app.colW
                        anchors.horizontalCenter: parent.horizontalCenter
                        topPadding:               app.mob ? 20 : 32
                        bottomPadding:            40
                        spacing:                  16

                        Text {
                            text:           "Submit Missing Vehicle"
                            font.pixelSize: app.titleF
                            font.bold:      true
                            color:          app.cGold
                        }

                        Text {
                            width:          parent.width
                            text:           "If your vehicle is not in the TRA database, submit its details here.\n"
                                            + "The TRA team will perform a manual valuation and contact you."
                            font.pixelSize: 13
                            color:          app.cMuted
                            wrapMode:       Text.Wrap
                            lineHeight:     1.5
                        }

                        // Success banner
                        Rectangle {
                            width:        parent.width
                            height:       80
                            radius:       10
                            visible:      app.mvSubmitted
                            color:        Qt.rgba(0.13, 0.77, 0.37, 0.14)
                            border.color: app.cGreen
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing:          6

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text:           "\u2713  Submission Received"
                                    font.pixelSize: 15
                                    font.bold:      true
                                    color:          app.cGreen
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text:           "TRA will respond within 5\u20137 business days."
                                    font.pixelSize: 12
                                    color:          app.cMuted
                                }
                            }
                        }

                        // Form
                        Column {
                            width:   parent.width
                            spacing: 14
                            visible: !app.mvSubmitted

                            GridLayout {
                                width:         parent.width
                                columns:       app.cols2
                                columnSpacing: 14
                                rowSpacing:    14

                                Repeater {
                                    model: [
                                        { lbl: "Make *",            ph: "e.g. Toyota", prop: "vMake"   },
                                        { lbl: "Model *",           ph: "e.g. Prado",  prop: "vModel"  },
                                        { lbl: "Body Type",         ph: "e.g. SUV",    prop: "vBody"   },
                                        { lbl: "Country of Origin", ph: "e.g. Japan",  prop: "vOrigin" }
                                    ]

                                    delegate: Column {
                                        spacing:          5
                                        Layout.fillWidth: true

                                        Text {
                                            text:           modelData.lbl
                                            font.pixelSize: app.labelF
                                            font.bold:      true
                                            color:          app.cMuted
                                        }

                                        Rectangle {
                                            width:        parent.width
                                            height:       app.inputH
                                            radius:       8
                                            color:        app.cInput
                                            border.color: app.cBorder
                                            border.width: 1

                                            TextInput {
                                                anchors.fill:        parent
                                                anchors.leftMargin:  12
                                                anchors.rightMargin: 12
                                                verticalAlignment:   TextInput.AlignVCenter
                                                font.pixelSize:      13
                                                color:               app.cText
                                                //placeholderText:     modelData.ph

                                                Component.onCompleted: {
                                                    text = app[modelData.prop] || "";
                                                }

                                                onEditingFinished: {
                                                    app[modelData.prop] = text;
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                width:   parent.width
                                spacing: 14

                                Column {
                                    spacing:          5
                                    Layout.fillWidth: true

                                    Text { text: "Year *"; font.pixelSize: app.labelF; font.bold: true; color: app.cMuted }

                                    Rectangle {
                                        width: parent.width; height: app.inputH; radius: 8
                                        color: app.cInput; border.color: app.cBorder; border.width: 1

                                        TextInput {
                                            anchors.fill:        parent
                                            anchors.leftMargin:  12
                                            anchors.rightMargin: 12
                                            verticalAlignment:   TextInput.AlignVCenter
                                            font.pixelSize:      13
                                            color:               app.cText
                                            inputMethodHints:    Qt.ImhDigitsOnly

                                            Component.onCompleted: {
                                                text = app.vYear > 0 ? app.vYear.toString() : "";
                                            }

                                            onEditingFinished: {
                                                var v = parseInt(text);
                                                if (!isNaN(v)) { app.vYear = v; }
                                            }
                                        }
                                    }
                                }

                                Column {
                                    spacing:          5
                                    Layout.fillWidth: true

                                    Text { text: "Engine (cc)"; font.pixelSize: app.labelF; font.bold: true; color: app.cMuted }

                                    Rectangle {
                                        width: parent.width; height: app.inputH; radius: 8
                                        color: app.cInput; border.color: app.cBorder; border.width: 1

                                        TextInput {
                                            anchors.fill:        parent
                                            anchors.leftMargin:  12
                                            anchors.rightMargin: 12
                                            verticalAlignment:   TextInput.AlignVCenter
                                            font.pixelSize:      13
                                            color:               app.cText
                                            inputMethodHints:    Qt.ImhDigitsOnly

                                            Component.onCompleted: {
                                                text = app.vEngine > 0 ? app.vEngine.toString() : "";
                                            }

                                            onEditingFinished: {
                                                var v = parseInt(text);
                                                if (!isNaN(v) && v > 0) { app.vEngine = v; }
                                            }
                                        }
                                    }
                                }
                            }

                            Column {
                                width:   parent.width
                                spacing: 5

                                Text { text: "Contact Email *"; font.pixelSize: app.labelF; font.bold: true; color: app.cMuted }

                                Rectangle {
                                    width: parent.width; height: app.inputH; radius: 8
                                    color: app.cInput; border.color: app.cBorder; border.width: 1

                                    TextInput {
                                        id:                  emailInput
                                        anchors.fill:        parent
                                        anchors.leftMargin:  12
                                        anchors.rightMargin: 12
                                        verticalAlignment:   TextInput.AlignVCenter
                                        font.pixelSize:      13
                                        color:               app.cText
                                        //placeholderText:     "your@email.com"
                                        inputMethodHints:    Qt.ImhEmailCharactersOnly

                                        Component.onCompleted: {
                                            text = app.mvEmail;
                                        }

                                        onEditingFinished: {
                                            app.mvEmail = text;
                                        }
                                    }
                                }
                            }

                            // Submit button
                            Rectangle {
                                width:  parent.width
                                height: app.btnH
                                radius: 10
                                color:  app.cGold

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing:          10

                                    BusyIndicator {
                                        width:   22
                                        height:  22
                                        running: app.mvLoading
                                        visible: app.mvLoading
                                    }

                                    Text {
                                        text:           app.mvLoading
                                                        ? "Submitting\u2026"
                                                        : "\u270E  Submit for Manual Valuation"
                                        font.pixelSize: app.mob ? 14 : 15
                                        font.bold:      true
                                        color:          "#000000"
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape:  Qt.PointingHandCursor
                                    enabled:      !app.mvLoading
                                    onClicked: {
                                        app.mvEmail = emailInput.text;
                                        if (!app.vMake.trim() || !app.vModel.trim()) {
                                            app.stepError = "Please enter Make and Model.";
                                            return;
                                        }
                                        app.stepError = "";
                                        app.doSubmitMissing();
                                    }
                                }
                            }
                        }
                    }
                }

            } // StackLayout

            // ════════════════════════════════════════════════════════════
            // FOOTER — mobile: tab bar  /  desktop: copyright strip
            // ════════════════════════════════════════════════════════════
            Rectangle {
                Layout.fillWidth: true
                height:           app.mob ? 62 : 32
                color:            app.cSurface

                Rectangle {
                    anchors.top: parent.top
                    width:       parent.width
                    height:      1
                    color:       app.cBorder
                }

                // Mobile tab bar
                RowLayout {
                    anchors.fill: parent
                    visible:      app.mob
                    spacing:      0

                    Repeater {
                        model: [
                            { icon: "\u2302", lbl: "Home",    pg: 0 },
                            { icon: "\u2295", lbl: "Valuate", pg: 1 },
                            { icon: "\u21C4", lbl: "Compare", pg: 3 },
                            { icon: "#",      lbl: "Ref",     pg: 4 },
                            { icon: "\u270E", lbl: "Missing", pg: 5 },
                            { icon: "X"     , lbl: "Close",   pg: 6 }
                        ]

                        delegate: Item {
                            Layout.fillWidth: true
                            height:           parent.height

                            // Active indicator bar at top
                            Rectangle {
                                anchors.top:              parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                width:   20
                                height:  2
                                radius:  1
                                color:   app.currentPage === modelData.pg ? app.cGold : "transparent"
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing:          2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text:           modelData.icon
                                    font.pixelSize: 20
                                    color:          app.currentPage === modelData.pg ? app.cGold : app.cMuted
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text:           modelData.lbl
                                    font.pixelSize: 9
                                    color:          app.currentPage === modelData.pg ? app.cGold : app.cMuted
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (modelData.pg === 1 && app.makesList.length === 0) {
                                        app.doFetchMakes();
                                    }

                                    if(modelData.pg === 6){
                                       app.close();
                                    }
                                    app.currentPage = modelData.pg;
                                }
                            }
                        }
                    }
                }

                // Desktop copyright footer
                RowLayout {
                    anchors.fill:        parent
                    anchors.leftMargin:  24
                    anchors.rightMargin: 24
                    visible:             !app.mob

                    Text {
                        text:           "\u00A9 2026 MagabeLab"
                        font.pixelSize: 10
                        color:          app.cMuted
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle { width: 6; height: 6; radius: 3; color: app.cGreen }

                    Text {
                        text:           "EAC 2024/25  \u00B7  gateway.tra.go.tz/umvvs"
                        font.pixelSize: 10
                        color:          app.cMuted
                    }
                }
            }

        } // ColumnLayout

        // ════════════════════════════════════════════════════════════════════
        // GLOBAL LOADING OVERLAY
        // ════════════════════════════════════════════════════════════════════
        Rectangle {
            anchors.fill: parent
            color:        Qt.rgba(0, 0, 0, 0.65)
            visible:      app.loadResult || app.refLoading || app.mvLoading

            Column {
                anchors.centerIn: parent
                spacing:          16

                BusyIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: true
                    width:   52
                    height:  52
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:           "Contacting TRA Server\u2026"
                    font.pixelSize: 15
                    color:          app.cGold
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:           "Please wait"
                    font.pixelSize: 11
                    color:          app.cMuted
                }
            }
        }

    } // rootRect
}
