import Qt 4.7
import "DrumMachine"

Rectangle {
    id: ui

    // Signals for TurnTable
    signal diskSpeed(variant speed)
    signal diskAimSpeed(variant speed)
    signal start()
    signal stop()

    signal cutOff(variant value)
    signal resonance(variant value)
    signal volumeUp()
    signal volumeDown()

    function inclination(deg) { diskReflection.rotation = -deg + 45}

    anchors.fill: parent
    width: 640; height: 360
    color: "black"

    focus: true

    Keys.onDownPressed: flickable.state = "DrumMachine"
    Keys.onUpPressed: flickable.state = ""
    Keys.onSpacePressed: powerbutton.press()
    Keys.onVolumeUpPressed: ui.volumeUp()
    Keys.onVolumeDownPressed: ui.volumeDown()

    Text {
        id: d
        z: 100
        font.bold: true
        color: "white"

    }

    Component.onCompleted: playTimer.start()

    Flickable {
        id: flickable

        anchors.left: sidepanel.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top

        contentWidth: parent.width
        contentHeight: parent.height * 2
        interactive: false

        Image {
            id: turntable

            property bool playing: false

            width:  flickable.width - mixerpanel.width
            height: flickable.height
            source: "turntable.png"
            fillMode: Image.PreserveAspectFit

            Image {
                id: disk

                // speed are Hz values of the disk
                property real targetSpeed: turntable.playing ? speedslider.value : 0.0
                property real currentSpeed: 0

                width: parent.paintedWidth * 0.80; height: width
                source: "disk.png"

                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -0.095 * parent.paintedWidth
                anchors.verticalCenterOffset: -0.0055 * parent.paintedHeight

                onCurrentSpeedChanged: playTimer.running ? ui.diskSpeed(disk.currentSpeed) : ui.diskAimSpeed(disk.currentSpeed)

                Timer {
                    id: playTimer

                    interval: 16  // 60 fps
                    repeat: true
                    onTriggered: {
                        disk.rotation = (disk.rotation + 0.36 * disk.currentSpeed * interval) % 360
                        if(Math.abs(disk.currentSpeed - disk.targetSpeed) <= 0.01) {
                            disk.currentSpeed = disk.targetSpeed
                        }
                        else {
                            disk.currentSpeed += (disk.targetSpeed - disk.currentSpeed) * 0.10
                        }
                    }
                }
            }

            Image {
                id: diskReflection

                anchors.top: disk.top; anchors.bottom: disk.bottom
                anchors.horizontalCenter: disk.horizontalCenter
                source: "diskreflection.png"
                rotation: 45
                Behavior on rotation { RotationAnimation {} }
            }

            MouseArea {
                // Don't place this as child of disk because the
                // coordination will change when disk is rotated

                property real centerx: width / 2
                property real centery: height / 2

                property int previousX: 0
                property int previousY: 0
                property variant previousTime

                anchors.fill: disk

                onPressed: {
                    var xlength = Math.abs(mouse.x - centerx)
                    var ylength = Math.abs(mouse.y - centery)

                    if(Math.sqrt(xlength * xlength + ylength * ylength) > centerx) {
                        // mouse press did not hit on the disk, the disk is actually
                        // rectangle shaped and the mouse was pressed one of the corners
                        mouse.accepted = false
                        return
                    }

                    playTimer.stop()
                    disk.currentSpeed = 0.0

                    previousX = mouse.x
                    previousY = mouse.y
                    previousTime = new Date().getTime()
                }

                onReleased: playTimer.start()

                onPositionChanged: {
                    var now = new Date().getTime()

                    var ax = mouse.x - centerx
                    var ay = centery - mouse.y
                    var bx = previousX - centerx
                    var by = centery - previousY

                    var angledelta = (Math.atan2(by, bx) - Math.atan2(ay, ax)) * 57.2957795
                    if(angledelta > 180)       { angledelta -= 360 }
                    else if(angledelta < -180) { angledelta += 360 }

                    disk.rotation = (disk.rotation + angledelta) % 360

                    if(now - previousTime > 0) { disk.currentSpeed = angledelta * 2.77778 / (now - previousTime) }

                    previousX = mouse.x
                    previousY = mouse.y
                    previousTime = now
                }
            }


            Arm {
                id: arm

                width: parent.paintedWidth * 0.1518; height: parent.paintedHeight * 0.8927
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 0.275 * parent.paintedWidth
                anchors.verticalCenterOffset: -0.03 * parent.paintedHeight

                onArmdownChanged: armdown ? ui.start() : ui.stop()
                onAngleChanged: angle < 14 ? armdown = false : armdown = true
            }

            SpeedSlider {
                id: speedslider

                width: parent.paintedWidth * 0.085; height: parent.paintedHeight * 0.4
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 0.4 * parent.paintedWidth
                anchors.verticalCenterOffset: 0.25 * parent.paintedHeight
                maximum: 1.5; minimum: 0.0; value: 1.0; defaultValue: 1.0
                mouseAreaScale: 2
            }
        }

        Rectangle {
            id: mixerpanel

            x: flickable.width - mixerpanel.width - 10
            y: flickable.height - mixerpanel.height - 10
            width: 130; height: flickable.height - 70
            color: "#858585"
            radius: 12

            Text {
                text: "Resonance"
                color: "#505050"
                anchors.left: parent.left; anchors.leftMargin: 7
                anchors.top: parent.top; anchors.topMargin: 6
                font.pixelSize: 10
            }

            KnobDial {
                id: resonance

                width: 95; height: 95
                anchors.top: parent.top; anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                smooth: true

                maximumvalue: 1.0; minimumvalue: 0; value: 0
                onValueChanged: ui.resonance(maximumvalue - value)
            }

            Text {
                text: "Cutoff"
                color: "#505050"
                anchors.left: parent.left; anchors.leftMargin: 7
                anchors.top: resonance.bottom; anchors.topMargin: 3
                font.pixelSize: 10
            }

            KnobDial {
                id: cutoff

                width: 95; height: 95
                anchors.top: resonance.bottom; anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                smooth: true

                maximumvalue: 1.0; minimumvalue: 0.0; value: 0
                onValueChanged: ui.cutOff(maximumvalue - value)
            }

            Text {
                text: "Power"
                color: "#505050"
                anchors.left: parent.left; anchors.leftMargin: 7
                anchors.top: cutoff.bottom; anchors.topMargin: 3
                font.pixelSize: 10
            }

            Item {
                id: powerbutton

                function press() {
                    turntable.playing = !turntable.playing
                    if(turntable.playing) { arm.moveIn()  }
                    else                  { arm.moveOut() }
                }

                width: 50; height: 50
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: cutoff.bottom; anchors.topMargin: 10

                Rectangle {
                    anchors.fill: parent; anchors.margins: 10
                    color: turntable.playing ? "#AA00FF00" : "#AAFF0000"
                }

                Image {
                    anchors.fill: parent
                    source: "powerbutton.png"
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: powerbutton.scale = 0.95
                    onReleased: powerbutton.scale = 1.00
                    onClicked: powerbutton.press()
                }
            }
        }

        DrumMachine {
            id: drumMachine

            y: flickable.height
            width: flickable.width; height: flickable.height
        }

        states: State {
            name: "DrumMachine"
            PropertyChanges { target: flickable; contentY: ui.height }
        }

        transitions: Transition {
            from: ""
            to: "DrumMachine"
            reversible: true
            PropertyAnimation { property: "contentY"; easing.type: Easing.InOutQuart }
        }
    }

    SidePanel {
        id: sidepanel

        width: 60; height: ui.height
        onTurnTableClicked: flickable.state = ""
        onDrumMachineClicked: flickable.state = "DrumMachine"
    }

    Button {
        width: 40; height: 40
        anchors.top: parent.top; anchors.topMargin: 10
        anchors.right: parent.right; anchors.rightMargin: 10
        source: "closemark.png"
        smooth: true
        onClicked: Qt.quit()
    }
}
