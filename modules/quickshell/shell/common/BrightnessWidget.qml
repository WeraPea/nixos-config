import QtQuick
import Quickshell.Io
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets
import "config"

Item {
    id: root
    required property string device
    required property string icon

    property int max_brightness: 255
    property int min_brightness: 0
    property int brightness
    property int prev_brightness

    onBrightnessChanged: {
        setBrightnessProc.command = ["brightnessctl", "--device", root.device, "set", root.brightness];
        setBrightnessProc.running = true;
    }

    property int slider_width: 200

    implicitWidth: brightnessText.implicitWidth + 30
    implicitHeight: 30

    TextObject {
        id: brightnessText
        anchors.centerIn: parent
        text: root.icon
        color: Colors.foreground
    }

    MouseArea {
        id: mouseArea
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        property real press_time

        property real press_x
        property bool wasHeld

        onPressed: mouse => {
            press_x = mouse.x;
            wasHeld = false;

            press_time = Date.now();

            getBrightnessProc.running = true;
        }
        onClicked: mouse => {
            // console.log(mouse.wasHeld) // lier
            if (!wasHeld) {
                popup.visible = !popup.visible;
            }
        }
        onMouseXChanged: mouse => {
            let delta = mouse.x - press_x;
            if (wasHeld || Math.abs(delta) > 10 || Date.now() - press_time > pressAndHoldInterval) {
                wasHeld = true;
                root.brightness = Math.max(min_brightness, Math.min(max_brightness, prev_brightness + delta * ((max_brightness - min_brightness) / slider_width)));
            }
        }
    }

    PopupWidget {
        id: popup
        anchor.item: root
        anchor.edges: Qt.BottomEdge
        anchor.gravity: Qt.BottomEdge | Qt.HCenter
        // margin: 10
        // border.width: 1
        // border.color: Colors.foreground
        // backgroundColor: Colors.background
        backgroundColor: "transparent"
        content: Component {
            Slider {
                id: slider
                from: root.min_brightness
                to: root.max_brightness
                value: root.brightness

                onMoved: root.brightness = value

                implicitWidth: root.slider_width

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                background: Item {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: slider.implicitWidth
                    implicitHeight: slider.handle.height
                    width: slider.availableWidth
                    height: slider.handle.height

                    Rectangle {
                        width: parent.width
                        height: parent.height
                        radius: height / 2
                        color: Colors.background
                    }

                    Rectangle {
                        width: slider.handle.x + slider.handle.width
                        height: parent.height
                        radius: height / 2
                        color: Colors.foreground
                    }

                    Rectangle {
                        width: parent.width
                        height: parent.height
                        radius: height / 2
                        color: "transparent"
                        border.color: Colors.foreground
                        border.width: 1
                    }
                }

                handle: Rectangle {
                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: 30
                    implicitHeight: 30
                    radius: width / 2
                    color: Colors.background
                    border.color: Colors.foreground
                    border.width: 1
                }
            }
        }
    }

    Process {
        id: setBrightnessProc
        // stdout: SplitParser {
        //     onRead: line => {
        //         if (line.includes("Current brightness")) {
        //             let match = line.match(/\d+/);
        //             if (match) {
        //                 root.brightness = parseInt(match[0]);
        //             }
        //         }
        //     }
        // }
    }
    Process {
        id: getBrightnessProc
        command: ["brightnessctl", "--device", root.device, "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.brightness = parseInt(this.text);
                root.prev_brightness = root.brightness;
            }
        }
    }
}
