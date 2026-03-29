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

    // ── ANIMATION 1: scan line sweeping down the screen ───────────────────
    Rectangle {
        id: scanLine
        width: parent.width
        height: 2
        color: "#1fb8ba"
        opacity: 0
        y: 0

        SequentialAnimation {
            loops: Animation.Infinite
            running: true
            NumberAnimation { target: scanLine; property: "opacity"; to: 0.18; duration: 200 }
            NumberAnimation {
                target: scanLine; property: "y"
                from: 0; to: app.height
                duration: 3000; easing.type: Easing.InOutSine
            }
            NumberAnimation { target: scanLine; property: "opacity"; to: 0; duration: 200 }
            PauseAnimation { duration: 1400 }
        }
    }

    // ── orb top-right with scale breathe ──────────────────────────────────
    Rectangle {
        width: app.width * 0.58
        height: width
        radius: width / 2
        anchors {
            right: parent.right; rightMargin: -width * 0.38
            top: parent.top;    topMargin:   -width * 0.38
        }
        color: "#168485"
        opacity: 0.0
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.22; duration: 1200; easing.type: Easing.OutCubic }
            NumberAnimation { to: 0.10; duration: 3400; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.25; duration: 3400; easing.type: Easing.InOutSine }
        }
        SequentialAnimation on scale {
            loops: Animation.Infinite
            NumberAnimation { to: 1.06; duration: 4200; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.96; duration: 4200; easing.type: Easing.InOutSine }
        }
    }

    // ── orb bottom-left with scale breathe ────────────────────────────────
    Rectangle {
        width: app.width * 0.46
        height: width
        radius: width / 2
        anchors {
            left: parent.left;     leftMargin:   -width * 0.36
            bottom: parent.bottom; bottomMargin: -width * 0.32
        }
        color: "#004040"
        opacity: 0.0
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.28; duration: 1600; easing.type: Easing.OutCubic }
            NumberAnimation { to: 0.12; duration: 4200; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.30; duration: 4200; easing.type: Easing.InOutSine }
        }
        SequentialAnimation on scale {
            loops: Animation.Infinite
            NumberAnimation { to: 1.08; duration: 5200; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.94; duration: 5200; easing.type: Easing.InOutSine }
        }
    }

    // ── ANIMATION 2: floating rising particles ────────────────────────────
    Repeater {
        model: 12
        Item {
            id: ptcl
            property real startX: (index / 12.0) * app.width + (index % 3) * 20
            property real riseH:  app.height * (0.45 + (index % 5) * 0.10)
            property int  riseMs: 4600 + index * 500

            x: startX
            y: app.height + 10
            opacity: 0

            Rectangle {
                width:  index % 3 === 0 ? 4 : (index % 3 === 1 ? 3 : 2)
                height: width; radius: width / 2
                color:  index % 2 === 0 ? "#02c6db" : "#1fb8ba"
                anchors.centerIn: parent
            }

            SequentialAnimation {
                loops: Animation.Infinite
                running: true
                PauseAnimation { duration: index * 400 }
                ParallelAnimation {
                    NumberAnimation {
                        target: ptcl; property: "y"
                        from: app.height + 10; to: app.height - riseH
                        duration: riseMs; easing.type: Easing.OutCubic
                    }
                    SequentialAnimation {
                        NumberAnimation { target: ptcl; property: "opacity"; to: 0.75; duration: 500 }
                        PauseAnimation  { duration: riseMs - 900 }
                        NumberAnimation { target: ptcl; property: "opacity"; to: 0;    duration: 400 }
                    }
                }
                PropertyAction { target: ptcl; property: "y";       value: app.height + 10 }
                PropertyAction { target: ptcl; property: "opacity"; value: 0 }
                PauseAnimation { duration: 300 }
            }
        }
    }

    // ── main content ──────────────────────────────────────────────────────
    Column {
        id: contentCol
        anchors.centerIn: parent
        width: parent.width * 0.82
        spacing: 0

        // ANIMATION 3: entrance slide-up + fade-in on load
        opacity: 0
        anchors.verticalCenterOffset: app.height * 0.06

        ParallelAnimation {
            running: true
            NumberAnimation {
                target: contentCol; property: "opacity"
                to: 1; duration: 950; easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: contentCol; property: "anchors.verticalCenterOffset"
                to: 0; duration: 950; easing.type: Easing.OutCubic
            }
        }

        // ── animated rings ───────────────────────────────────────────────
        Item {
            id: gearContainer
            width: parent.width
            height: app.height * 0.23
            anchors.horizontalCenter: parent.horizontalCenter

            // ANIMATION 4: expanding glow ring that pulses outward
            Rectangle {
                id: glowRing
                width: outerRing.width
                height: width
                radius: width / 2
                anchors.centerIn: parent
                color: "transparent"
                border.color: "#02c6db"
                border.width: 1
                opacity: 0

                SequentialAnimation {
                    loops: Animation.Infinite
                    running: true
                    ParallelAnimation {
                        NumberAnimation {
                            target: glowRing; property: "width"
                            to: outerRing.width * 1.35; duration: 1100; easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: glowRing; property: "height"
                            to: outerRing.width * 1.35; duration: 1100; easing.type: Easing.OutCubic
                        }
                        SequentialAnimation {
                            NumberAnimation { target: glowRing; property: "opacity"; to: 0.30; duration: 250 }
                            NumberAnimation { target: glowRing; property: "opacity"; to: 0;    duration: 850 }
                        }
                    }
                    PropertyAction { target: glowRing; property: "width";  value: outerRing.width }
                    PropertyAction { target: glowRing; property: "height"; value: outerRing.width }
                    PauseAnimation { duration: 1000 }
                }
            }

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

            // ML brand text inside core
            Text {
                anchors.centerIn: parent
                text: "ML"
                color: "#1fb8ba"
                font.pixelSize: core.width * 0.38
                font.bold: true
                font.letterSpacing: 1.5
            }

            // ANIMATION 5: orbit dots that actually travel in a circle
            Item {
                id: orbitTrack
                width: outerRing.width * 1.26
                height: width
                anchors.centerIn: parent

                RotationAnimation on rotation {
                    from: 0; to: 360; duration: 5500
                    loops: Animation.Infinite
                    direction: RotationAnimation.Clockwise
                }

                Repeater {
                    model: 8
                    Rectangle {
                        property real ang: (index * 45) * Math.PI / 180
                        property real r:   orbitTrack.width / 2
                        width:  index % 2 === 0 ? 6 : 4
                        height: width; radius: width / 2
                        color:  index % 2 === 0 ? "#02c6db" : "#1fb8ba"
                        x: r + r * Math.cos(ang) - width / 2
                        y: r + r * Math.sin(ang) - height / 2
                        opacity: index % 2 === 0 ? 0.90 : 0.55
                    }
                }
            }
        }

        Item { width: 1; height: app.height * 0.030 }

        // ── headline with scale breathe ───────────────────────────────────
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
                NumberAnimation { to: 0.65; duration: 3200; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0;  duration: 3200; easing.type: Easing.InOutSine }
            }
            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { to: 1.02; duration: 3200; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.99; duration: 3200; easing.type: Easing.InOutSine }
            }
        }

        Item { width: 1; height: app.height * 0.016 }

        // ── divider with center brightness pulse ──────────────────────────
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
                // ANIMATION 6: divider flicker
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.45; duration: 900; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0;  duration: 900; easing.type: Easing.InOutSine }
                }
            }
            Rectangle {
                width: parent.width * 0.25; height: parent.height
                anchors.right: parent.right
                color: "#063a3b"
            }
        }

        Item { width: 1; height: app.height * 0.020 }

        // ── subtitle slow fade wave ───────────────────────────────────────
        Text {
            text: app.subText()
            font.pixelSize: Qt.platform.os === "android" ? app.width * 0.038 : app.width * 0.033
            color: "#05c6c8"
            lineHeight: 1.55
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            width: parent.width * 0.88
            // ANIMATION 7: subtitle slow opacity wave
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                PauseAnimation { duration: 900 }
                NumberAnimation { to: 0.50; duration: 2800; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.92; duration: 2800; easing.type: Easing.InOutSine }
            }
        }

        Item { width: 1; height: app.height * 0.040 }

        // ── progress bar with shimmer tip dot ─────────────────────────────
        Item {
            id: progressBarItem
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
                    NumberAnimation { from: 0; to: progressBarItem.width; duration: 2400; easing.type: Easing.InOutCubic }
                    PauseAnimation  { duration: 350 }
                    NumberAnimation { to: 0; duration: 550; easing.type: Easing.InCubic }
                    PauseAnimation  { duration: 280 }
                }
            }

            // ANIMATION 8: shimmer dot riding the progress tip
            Rectangle {
                id: shimmerDot
                width: 9; height: 9; radius: 4.5
                color: "#02c6db"
                anchors.verticalCenter: parent.verticalCenter
                x: progressFill.width > 6 ? progressFill.width - 5 : -20
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.25; duration: 380 }
                    NumberAnimation { to: 1.0;  duration: 380 }
                }
            }
        }

        Item { width: 1; height: app.height * 0.030 }

        // ── status badge with expanding glow ──────────────────────────────
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: badgeRect.width + 30
            height: badgeRect.height + 30

            // ANIMATION 9: badge glow ring that expands and fades
            Rectangle {
                id: badgeGlow
                anchors.centerIn: parent
                width: badgeRect.width
                height: badgeRect.height
                radius: height / 2
                color: "transparent"
                border.color: "#02c6db"
                border.width: 1
                opacity: 0

                SequentialAnimation {
                    loops: Animation.Infinite
                    running: true
                    ParallelAnimation {
                        NumberAnimation {
                            target: badgeGlow; property: "width"
                            to: badgeRect.width + 20; duration: 1000; easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: badgeGlow; property: "height"
                            to: badgeRect.height + 20; duration: 1000; easing.type: Easing.OutCubic
                        }
                        SequentialAnimation {
                            NumberAnimation { target: badgeGlow; property: "opacity"; to: 0.35; duration: 250 }
                            NumberAnimation { target: badgeGlow; property: "opacity"; to: 0;    duration: 750 }
                        }
                    }
                    PropertyAction { target: badgeGlow; property: "width";  value: badgeRect.width }
                    PropertyAction { target: badgeGlow; property: "height"; value: badgeRect.height }
                    PauseAnimation { duration: 900 }
                }
            }

            Rectangle {
                id: badgeRect
                anchors.centerIn: parent
                width: statusRow.width + 30
                height: statusRow.height + 16
                radius: height / 2
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
    }

    // ── version tag ───────────────────────────────────────────────────────
    Text {
        text: typeof n3ctaApp !== "undefined" ? "v" + n3ctaApp.versionName() : ""
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
