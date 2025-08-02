import QtQuick 2.6
import QtWebView 1.14

Rectangle {
    color: "transparent"

    function getUrl() {
        if(typeof n3ctaApp !== "undefined"){
            return n3ctaApp.getConfig("CLASSIC_VERSION_SITE_URL");
        }else if(typeof loader !== "undefined"){
            return loader.getData("CLASSIC_VERSION_SITE_URL");
        }else {
		    return "";
		}
    }

    WebView {
        id: webView
        anchors.fill: parent
        url: getUrl()
    }

    Button {
        id: closeButton
        text: typeof n3ctaApp !== "undefined" ? "Funga" : "Close"
        width: 150
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20

        onClicked: {
            if(typeof n3ctaApp !== "undefined"){
                n3ctaApp.closeQMLDialog();;
                n3ctaApp.onUrlVisited("#showGoogleAd");
              }else if(typeof loader !== "undefined"){
                nectaMainResultsPageDownloaderHtmlToXmlConveterAndSaver.closeQMLDialog();
                loader.onUrlVisited("#showGoogleAd");
             }
        }
    }
}
