import QtQuick
import Quickshell
import M3Shapes
import "../design"

Item {
    id: root

    property string buffer: ""
    property color glyphColor: Theme.colorText
    property real glyphSize: 18

    readonly property var shapeQueue: {
        const shapes = [
            MaterialShape.Slanted,
            MaterialShape.Arch,
            MaterialShape.Fan,
            MaterialShape.Arrow,
            MaterialShape.SemiCircle,
            MaterialShape.Triangle,
            MaterialShape.Diamond,
            MaterialShape.ClamShell,
            MaterialShape.Pentagon,
            MaterialShape.Gem,
            MaterialShape.Sunny,
            MaterialShape.VerySunny,
            MaterialShape.Cookie4Sided,
            MaterialShape.Ghostish,
            MaterialShape.SoftBurst
        ];

        for (let i = shapes.length - 1; i > 0; --i) {
            const j = Math.floor(Math.random() * (i + 1));
            const value = shapes[i];
            shapes[i] = shapes[j];
            shapes[j] = value;
        }

        return shapes;
    }

    clip: true

    ListView {
        id: charList

        readonly property real fullWidth: {
            let width = Math.max(0, count - 1) * spacing;
            for (let i = 0; i < count; ++i) {
                const item = itemAtIndex(i);
                width += (item ? item.nonAnimWidthScale : 1) * implicitHeight;
            }
            return width + implicitHeight;
        }

        anchors.centerIn: parent
        anchors.horizontalCenterOffset: implicitWidth > root.width
            ? -(implicitWidth - root.width) / 2
            : 0

        implicitWidth: fullWidth
        implicitHeight: root.glyphSize
        orientation: Qt.Horizontal
        spacing: 4
        interactive: false

        model: ScriptModel {
            values: root.buffer.split("")
        }

        delegate: CharItem {}

        Behavior on implicitWidth {
            Anim { type: Motion.defaultSpatial }
        }
    }

    component CharItem: Item {
        id: char

        required property int index
        property real nonAnimWidthScale: 1

        implicitWidth: charList.implicitHeight
        implicitHeight: charList.implicitHeight

        ListView.onRemove: {
            initAnimation.stop();
            removeAnimation.start();
        }

        MaterialShape {
            id: shape

            anchors.centerIn: parent
            implicitSize: charList.implicitHeight * 1.5
            shape: root.shapeQueue[char.index % root.shapeQueue.length]
                ?? MaterialShape.Circle
            color: root.glyphColor

            Behavior on color {
                CAnim { type: Motion.defaultEffects }
            }

            SequentialAnimation {
                id: initAnimation
                running: true

                ParallelAnimation {
                    Anim {
                        target: shape
                        property: "opacity"
                        from: 0
                        to: 1
                        type: Motion.defaultEffects
                    }

                    Anim {
                        target: shape
                        property: "scale"
                        from: 0
                        to: 1
                        type: Motion.fastSpatial
                    }

                    Anim {
                        target: char
                        property: "implicitWidth"
                        from: charList.implicitHeight
                        to: charList.implicitHeight * 1.3
                        type: Motion.defaultEffects
                    }

                    PropertyAction {
                        target: char
                        property: "nonAnimWidthScale"
                        value: 1.5
                    }
                }

                PauseAnimation { duration: 180 }

                PropertyAction {
                    target: shape
                    property: "shape"
                    value: MaterialShape.Circle
                }

                ParallelAnimation {
                    Anim {
                        target: shape
                        property: "scale"
                        to: 2 / 3
                        type: Motion.fastSpatial
                    }

                    Anim {
                        target: char
                        property: "implicitWidth"
                        to: charList.implicitHeight
                        type: Motion.defaultEffects
                    }

                    PropertyAction {
                        target: char
                        property: "nonAnimWidthScale"
                        value: 1
                    }
                }
            }

            SequentialAnimation {
                id: removeAnimation

                PropertyAction {
                    target: char
                    property: "ListView.delayRemove"
                    value: true
                }

                ParallelAnimation {
                    Anim {
                        target: shape
                        property: "opacity"
                        to: 0
                        type: Motion.defaultEffects
                    }

                    Anim {
                        target: shape
                        property: "scale"
                        to: 0.5
                        type: Motion.fastSpatial
                    }
                }

                PropertyAction {
                    target: char
                    property: "ListView.delayRemove"
                    value: false
                }
            }
        }
    }
}
