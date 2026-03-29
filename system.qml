import QtQuick 2.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

// ── Palette reference (Palette.qml) ───────────────────────────────────────
// inputTextColor            : #1fb8ba
// buttonPrimaryGradStop     : #004040
// buttonSecondaryGradStop   : #168485
// textfieldBorderColor      : #063a3b
// textfieldBGColor          : #182222
// navigatorPageIconColor    : #001413
// resultsPageIconColor      : #02c6db
// selectedItemTextColor     : white
// unselectedItemTextColor   : #05c6c8
// selectedItemBGColor       : #003333
// unselectedItemBGColor     : #001413
// selectedItemBorderColor   : #001413
// inactiveItemTextColor     : #055152

Rectangle {
    id: app
    width: parent.width
    height: parent.height
    color: "#001413"

    // ── helpers ───────────────────────────────────────────────────────────
    function mainText() {
        if (typeof n3ctaApp !== "undefined") {
            return "Tunaboresha\nHuduma Yako";
        } else {
            return "We're Improving\nYour Experience";
        }
    }

    function subText() {
        if (typeof n3ctaApp !== "undefined") {
            return "Mfumo unafanyiwa ukarabati ili kukupa\nhuduma bora zaidi. Utaarifu utakapokuwa tayari.";
        } else {
            return "Our team is working hard to bring you\na better experience. Please check back soon.";
        }
    }

    function executeCommand(url) {
        if (typeof n3ctaApp !== "undefined") {
            n3ctaApp.onUrlVisited(url);
        } else if (typeof loader !== "undefined") {
            n3ctaQmlConnectionsPipe.onUrlVisited(url);
        }
    }

    function showToast() {
        if (typeof n3ctaApp !== "undefined") {
            n3ctaApp.showToastMessage("Tunafanya kazi. Tafadhali subiri kidogo.");
        } else if (typeof loader !== "undefined") {
            nectaMainResultsPageDownloaderHtmlToXmlConveterAndSaver.showToastMessage("Hang tight — we're almost done.");
        }
    }

    // ── background gradient ───────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#001413" }
            GradientStop { position: 0.5; color: "#182222" }
            GradientStop { position: 1.0; color: "#001413" }
        }
    }

    // ── grid overlay ──────────────────────────────────────────────────────
    Item {
        anchors.fill: parent
        opacity: 0.07
        Repeater {
            model: 14
            Rectangle {
                width: 1; height: parent.height
                x: index * (app.width / 13)
                color: "#1fb8ba"
            }
        }
        Repeater {
            model: 22
            Rectangle {
                height: 1; width: parent.width
                y: index * (app.height / 21)
                color: "#1fb8ba"
            }
        }
    }

    // ── orb top-right ─────────────────────────────────────────────────────
    Rectangle {
        width: app.width * 0.58
        height: width
        radius: width / 2
        anchors {
            right: parent.right; rightMargin: -width * 0.38
            top: parent.top;    topMargin:   -width * 0.38
        }
        color: "#168485"
        opacity: 0.22
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.10; duration: 3400; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.25; duration: 3400; easing.type: Easing.InOutSine }
        }
    }

    // ── orb bottom-left ───────────────────────────────────────────────────
    Rectangle {
        width: app.width * 0.46
        height: width
        radius: width / 2
        anchors {
            left: parent.left;     leftMargin:   -width * 0.36
            bottom: parent.bottom; bottomMargin: -width * 0.32
        }
        color: "#004040"
        opacity: 0.28
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.12; duration: 4200; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.30; duration: 4200; easing.type: Easing.InOutSine }
        }
    }

    // ── main content ──────────────────────────────────────────────────────
    Column {
        id: contentCol
        anchors.centerIn: parent
        width: parent.width * 0.82
        spacing: 0

        // ── animated rings ───────────────────────────────────────────────
        Item {
            id: gearContainer
            width: parent.width
            height: app.height * 0.23
            anchors.horizontalCenter: parent.horizontalCenter

            // outer ring
            Rectangle {
                id: outerRing
                width: Math.min(gearContainer.width, gearContainer.height) * 0.54
                height: width
                radius: width / 2
                anchors.centerIn: parent
                color: "transparent"
                border.color: "#02c6db"
                border.width: 3
                opacity: 0.75
                RotationAnimation on rotation {
                    from: 0; to: 360; duration: 11000
                    loops: Animation.Infinite
                    direction: RotationAnimation.Clockwise
                }
            }

            // mid ring
            Rectangle {
                id: midRing
                width: outerRing.width * 0.76
                height: width
                radius: width / 2
                anchors.centerIn: parent
                color: "transparent"
                border.color: "#1fb8ba"
                border.width: 2
                opacity: 0.85
                RotationAnimation on rotation {
                    from: 0; to: -360; duration: 7500
                    loops: Animation.Infinite
                    direction: RotationAnimation.Counterclockwise
                }
            }

            // inner ring
            Rectangle {
                width: outerRing.width * 0.54
                height: width
                radius: width / 2
                anchors.centerIn: parent
                color: "transparent"
                border.color: "#05c6c8"
                border.width: 1
                opacity: 0.60
                RotationAnimation on rotation {
                    from: 0; to: 360; duration: 5000
                    loops: Animation.Infinite
                    direction: RotationAnimation.Clockwise
                }
            }

            // core
            Rectangle {
                id: core
                width: outerRing.width * 0.38
                height: width
                radius: width / 2
                anchors.centerIn: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#168485" }
                    GradientStop { position: 1.0; color: "#004040" }
                }
                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.08; duration: 1500; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.94; duration: 1500; easing.type: Easing.InOutSine }
                }
            }

            // wrench bar
            Rectangle {
                width: core.width * 0.54; height: core.height * 0.11
                radius: height / 2
                anchors.centerIn: parent
                color: "#1fb8ba"
                rotation: 45
            }
            // wrench stem
            Rectangle {
                width: core.width * 0.11; height: core.height * 0.48
                radius: width / 2
                anchors.centerIn: parent
                anchors.verticalCenterOffset: core.height * 0.07
                color: "#1fb8ba"
                rotation: 45
            }

            // orbit dots
            Repeater {
                model: 8
                Rectangle {
                    property real angle: (index * 45) * Math.PI / 180
                    property real orbitR: outerRing.width * 0.63
                    width: 5; height: 5; radius: 2.5
                    color: index % 2 === 0 ? "#02c6db" : "#1fb8ba"
                    x: gearContainer.width  / 2 + orbitR * Math.cos(angle) - 2.5
                    y: gearContainer.height / 2 + orbitR * Math.sin(angle) - 2.5
                    opacity: 0.80
                }
            }
        }

        Item { width: 1; height: app.height * 0.030 }

        // ── headline ─────────────────────────────────────────────────────
        Text {
            text: app.mainText()
            font.pixelSize: Qt.platform.os === "android" ? app.width * 0.072 : app.width * 0.065
            font.bold: true
            font.letterSpacing: 1.4
            color: "#1fb8ba"
            lineHeight: 1.30
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            width: parent.width
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.68; duration: 2800; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0;  duration: 2800; easing.type: Easing.InOutSine }
            }
        }

        Item { width: 1; height: app.height * 0.016 }

        // ── divider ───────────────────────────────────────────────────────
        Item {
            height: 2
            anchors.horizontalCenter: parent.horizontalCenter
            property real divW: parent.width * 0.38
            SequentialAnimation on divW {
                loops: Animation.Infinite
                NumberAnimation { to: parent.width * 0.60; duration: 2000; easing.type: Easing.InOutSine }
                NumberAnimation { to: parent.width * 0.28; duration: 2000; easing.type: Easing.InOutSine }
            }
            width: divW

            Rectangle {
                width: parent.width * 0.25; height: parent.height
                anchors.left: parent.left
                color: "#063a3b"
            }
            Rectangle {
                width: parent.width * 0.50; height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#02c6db"
            }
            Rectangle {
                width: parent.width * 0.25; height: parent.height
                anchors.right: parent.right
                color: "#063a3b"
            }
        }

        Item { width: 1; height: app.height * 0.020 }

        // ── subtitle ──────────────────────────────────────────────────────
        Text {
            text: app.subText()
            font.pixelSize: Qt.platform.os === "android" ? app.width * 0.038 : app.width * 0.033
            color: "#05c6c8"
            opacity: 0.90
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            width: parent.width * 0.88
            lineHeight: 1.55
        }

        Item { width: 1; height: app.height * 0.040 }

        // ── progress bar ──────────────────────────────────────────────────
        Item {
            width: parent.width * 0.76
            height: 5
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                anchors.fill: parent
                radius: 3
                color: "#182222"
                border.color: "#063a3b"
                border.width: 1
            }

            Rectangle {
                id: progressFill
                height: parent.height
                radius: 3
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#003333" }
                    GradientStop { position: 1.0; color: "#02c6db" }
                }
                SequentialAnimation on width {
                    loops: Animation.Infinite
                    NumberAnimation { from: 0; to: parent.parent.width * 0.76; duration: 2400; easing.type: Easing.InOutCubic }
                    PauseAnimation  { duration: 350 }
                    NumberAnimation { to: 0; duration: 550; easing.type: Easing.InCubic }
                    PauseAnimation  { duration: 280 }
                }
            }
        }

        Item { width: 1; height: app.height * 0.030 }

        // ── status badge ──────────────────────────────────────────────────
        Rectangle {
            width: statusRow.width + 30
            height: statusRow.height + 16
            radius: height / 2
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#003333"
            border.color: "#063a3b"
            border.width: 1

            Row {
                id: statusRow
                anchors.centerIn: parent
                spacing: 9

                Rectangle {
                    width: 8; height: 8; radius: 4
                    color: "#1fb8ba"
                    anchors.verticalCenter: parent.verticalCenter
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.15; duration: 650 }
                        NumberAnimation { to: 1.0;  duration: 650 }
                    }
                }

                Text {
                    text: typeof n3ctaApp !== "undefined" ? "Ukarabati Unaendelea..." : "Upgrade In Progress"
                    color: "#05c6c8"
                    font.pixelSize: app.width * 0.030
                    font.letterSpacing: 0.8
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    // ── version tag ───────────────────────────────────────────────────────
    Text {
        text: "ML"
        color: "#055152"
        font.pixelSize: app.width * 0.026
        anchors { bottom: parent.bottom; right: parent.right; margins: 14 }
    }

    // ── tap handler ───────────────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        onClicked: {
            app.showToast();
            app.executeCommand("#showGoogleAd");
        }
    }
}
