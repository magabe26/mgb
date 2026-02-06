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

    // --- IQ CATEGORY LOGIC ---
    function getCategory(iq) {
        if (iq >= 140) return "GENIUS (Gwiji)";
        if (iq >= 120) return "SUPERIOR (Upeo wa Juu)";
        if (iq >= 110) return "ABOVE AVERAGE (Zaidi ya Wastani)";
        if (iq >= 90)  return "AVERAGE (Wastani)";
        return "LOW (Unahitaji Mazoezi)";
    }

    // --- QUESTION MODEL (Maswali 26) ---
    ListModel {
        id: iqModel
        // HESABU & LOGIC
        ListElement { q: "Ni namba gani inafuata?\n2, 5, 11, 23, ..."; a: "35"; b: "47"; c: "46"; d: "50"; correct: "47" }
        ListElement { q: "Tafuta thamani ya 'x' kama:\n2x + 10 = 30"; a: "5"; b: "15"; c: "10"; d: "20"; correct: "10" }
        ListElement { q: "Kama 3 ni 9, na 4 ni 16, basi 6 ni nini?"; a: "36"; b: "24"; c: "12"; d: "30"; correct: "36" }
        ListElement { q: "Nusu ya robo ya 400 ni ngapi?"; a: "100"; b: "50"; c: "25"; d: "200"; correct: "50" }

        // MARAIS WA TZ
        ListElement { q: "Nani alikuwa Rais wa awamu ya pili wa Tanzania?"; a: "Nyerere"; b: "Mwinyi"; c: "Mkapa"; d: "Kikwete"; correct: "Mwinyi" }
        ListElement { q: "Rais gani wa Tanzania alizaliwa Chato?"; a: "Mkapa"; b: "Mwinyi"; c: "Magufuli"; d: "Samia"; correct: "Magufuli" }
        ListElement { q: "Samia Suluhu Hassan alikula kiapo kuwa Rais mwaka gani?"; a: "2020"; b: "2021"; c: "2019"; d: "2022"; correct: "2021" }

        // HISTORIA YA TZ
        ListElement { q: "Muungano wa Tanganyika na Zanzibar uliundwa mwaka gani?"; a: "1961"; b: "1964"; c: "1962"; d: "1963"; correct: "1964" }
        ListElement { q: "Zanzibar ilipata Mapinduzi yake mwezi gani?"; a: "Januari"; b: "Aprili"; c: "Desemba"; d: "Machi"; correct: "Januari" }
        ListElement { q: "Mji mkuu wa kwanza wa Tanganyika ulikuwa?"; a: "Dodoma"; b: "Bagamoyo"; c: "Dar es Salaam"; d: "Tanga"; correct: "Bagamoyo" }

        // UTALII WA TZ
        ListElement { q: "Hifadhi gani inajulikana kwa uhamiaji wa nyumbu?"; a: "Mikumi"; b: "Serengeti"; c: "Ruaha"; d: "Tarangire"; correct: "Serengeti" }
        ListElement { q: "Kilele kirefu zaidi cha Mlima Kilimanjaro kinaitwa?"; a: "Mawenzi"; b: "Uhuru"; c: "Shira"; d: "Kibo"; correct: "Uhuru" }
        ListElement { q: "Hifadhi ya Ngorongoro ipo mkoa gani?"; a: "Manyara"; b: "Arusha"; c: "Mara"; d: "Tabora"; correct: "Arusha" }
        ListElement { q: "Zanzibar inajulikana duniani kama visiwa vya?"; a: "Dhahabu"; b: "Viungo (Spice)"; c: "Chumvi"; d: "Almasi"; correct: "Viungo (Spice)" }

        // MIKOA YA TZ
        ListElement { q: "Mkoa gani unaongoza kwa ukubwa wa eneo Tanzania?"; a: "Tabora"; b: "Morogoro"; c: "Dodoma"; d: "Lindi"; correct: "Tabora" }
        ListElement { q: "Mkoa gani unaitwa mji wa miamba (Rock City)?"; a: "Mbeya"; b: "Mwanza"; c: "Arusha"; d: "Kigoma"; correct: "Mwanza" }
        ListElement { q: "Mkoa wa Geita ulimegwa kutoka mikoa ipi?"; a: "Mwanza/Shinyanga"; b: "Kagera/Mara"; c: "Mwanza/Kagera"; d: "Shinyanga/Mara"; correct: "Mwanza/Shinyanga" }
        ListElement { q: "Makao makuu ya nchi (Dodoma) yapo kanda gani?"; a: "Kaskazini"; b: "Kati"; c: "Magharibi"; d: "Kusini"; correct: "Kati" }

        // SAYANSI
        ListElement { q: "Ni gesi gani binadamu anahitaji ili kuishi?"; a: "Nitrogen"; b: "Oxygen"; c: "Carbon"; d: "Hydrogen"; correct: "Oxygen" }
        ListElement { q: "Sayari ya karibu zaidi na Jua inaitwa?"; a: "Dunia"; b: "Mercury"; c: "Mars"; d: "Venus"; correct: "Mercury" }
        ListElement { q: "Maji huganda (Freezing point) kwenye nyuzi ngapi Celsius?"; a: "100"; b: "0"; c: "50"; d: "-10"; correct: "0" }
        ListElement { q: "Sehemu ya seli inayohusika na nishati (Powerhouse) ni?"; a: "Nucleus"; b: "Mitochondria"; c: "Ribosome"; d: "Wall"; correct: "Mitochondria" }

        // ZIADA
        ListElement { q: "Kama utageuza neno 'KILIMANJARO', herufi ya tatu itakuwa?"; a: "A"; b: "R"; c: "O"; d: "J"; correct: "R" }
        ListElement { q: "Tanzania imepakana na nchi ngapi?"; a: "6"; b: "8"; c: "10"; d: "7"; correct: "8" }
        ListElement { q: "Rangi za bendera ya Tanzania ni ngapi?"; a: "3"; b: "4"; c: "5"; d: "2"; correct: "4" }
        ListElement { q: "Nchi ya Tanzania ipo upande gani wa bara la Afrika?"; a: "Magharibi"; b: "Kaskazini"; c: "Mashariki"; d: "Kati"; correct: "Mashariki" }
    }

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
        if (selected === iqModel.get(currentIdx).correct) {
            totalScore += (timerValue * 3) + 10;
        }
        if (currentIdx < iqModel.count - 1) {
            currentIdx++;
            timerValue = 15;
        } else {
            mainTimer.stop();
            viewState = "END";
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
                text: "MAGABE IQ LAB"
                color: "#00ffff"
                font.pixelSize: 32
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Pima uwezo wa akili yako sasa."
                color: "#88ffffff"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignHCenter
            }

            Button {
                text: "ANZA JARIBIO"
                Layout.preferredWidth: app.width * 0.8
                Layout.preferredHeight: 55
                onClicked: {
                    viewState = "QUIZ";
                    mainTimer.start();
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
        }


        // --- QUIZ VIEW ---
        ColumnLayout {
            visible: viewState === "QUIZ"
            anchors.fill: parent
            spacing: 25

            // Circular Timer Placeholder (Progress Bar)
            Rectangle {
                Layout.fillWidth: true
                height: 10
                radius: 5
                color: "#111"
                Rectangle {
                    width: (timerValue / 10) * parent.width
                    height: parent.height
                    radius: 5
                    color: timerValue < 4 ? "red" : "#00ffff"
                    Behavior on width { NumberAnimation { duration: 500 } }
                }
            }

            Text {
                text: "Swali " + (currentIdx + 1) + " kati ya " + iqModel.count
                color: "#00ffff"
                font.pixelSize: 14
            }

            Text {
                text: iqModel.get(currentIdx).q
                color: "white"
                font.pixelSize: 24
                font.bold: true
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.preferredHeight: 120
            }

            // Options list
            ColumnLayout {
                Layout.fillWidth: true; spacing: 12
                Repeater {
                    model: [iqModel.get(currentIdx).a, iqModel.get(currentIdx).b, iqModel.get(currentIdx).c, iqModel.get(currentIdx).d]
                    delegate: Button {
                        text: modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        onClicked: processAnswer(modelData)
                        background: Rectangle {
                            color: parent.pressed ? "#00ffff" : "#121a1d"
                            border.color: "#22ffffff"
                            radius: 12
                        }
                        contentItem: Text {
                            text: parent.text;
                            color: "white"
                            font.pixelSize: 18
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
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                id: finalScoreDisplay
                property int finalIQ: (totalScore / 8) + 70
                text: "IQ SCORE: " + finalIQ
                color: "#00ffff"
                font.pixelSize: 48
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.preferredWidth: 320
                Layout.preferredHeight: 70
                color: "#121a1d"
                radius: 10
                border.color: "#3300ffff"
                Text {
                    anchors.centerIn: parent
                    text: getCategory(finalScoreDisplay.finalIQ)
                    color: "white"
                    font.bold: true
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                }
            }



            Button {
                text: "SHARE KWA WHATSAPP"
                Layout.preferredWidth: app.width * 0.8
                Layout.preferredHeight: 50
                background: Rectangle {
                    color: "#25D366"
                    radius: 10
                }
                onClicked: {
                    let msg = "Nimepata IQ ya " + finalScoreDisplay.finalIQ + " (" + getCategory(finalScoreDisplay.finalIQ) + ") kwenye Magabe IQ Lab! \n\nImeundwa na Edwin Magabe Ngosso.";
                    Qt.openUrlExternally("whatsapp://send?text=" + encodeURIComponent(msg));
                }
            }

            // Text { text: "Developer: Edwin Magabe Ngosso"; color: "#44ffffff"; Layout.alignment: Qt.AlignHCenter }

            Button {
                text: "JARIBU TENA"
                Layout.alignment: Qt.AlignHCenter

                onClicked: {
                    currentIdx = 0;
                    totalScore = 0;
                    timerValue = 15;
                    viewState = "START"
                }
            }
        }
    }
}
