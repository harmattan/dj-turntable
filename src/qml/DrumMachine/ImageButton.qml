import Qt 4.7

Image {
    id: button

    signal clicked(variant button, int index)

    property int index: -1
    property bool pressed: false
    property alias buttonCenterImage: buttonCenter.source
    property alias glowColor: glowColor.color

    width: 50; height: 50
    smooth: true
    source: "../images/buttonedge.png"

    Rectangle {
        id: glowColor
        anchors.fill: parent; anchors.margins: parent.width * 0.8
        z: -1
        color: button.pressed ? "#AAFF0000" : "#AA202020"
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    Image {
        id: buttonCenter

        anchors.fill: parent
        scale: button.pressed ? 0.85 : 0.98
        Behavior on scale { PropertyAnimation { duration: 100 } }

        source: "../images/button1.png"
        smooth: true
    }

    MouseArea {
        anchors.fill: parent
        onPressed: button.clicked(button, button.index)
    }
}
