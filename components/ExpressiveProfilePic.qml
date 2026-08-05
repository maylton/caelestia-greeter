import QtQuick
import QtQuick.Effects
import M3Shapes
import "../design"

Item {
    id: root

    property int centerWidth: 320
    property string avatarSource: ""
    property string fallbackText: "C"
    property real revealProgress: 1
    readonly property color backgroundColour: Theme.colorSurfacePressed

    implicitWidth: Math.round(centerWidth * 0.7)
    implicitHeight: {
        shape.height; // Keep the implicit height in sync with MaterialShape.
        return Math.ceil(shape.pathBounds().height);
    }
    opacity: revealProgress
    scale: 0.68 + revealProgress * 0.32
    transformOrigin: Item.Center

    transform: Translate {
        y: (1 - root.revealProgress) * 36
    }

    Behavior on opacity {
        Anim { type: Motion.defaultEffects }
    }

    Behavior on scale {
        Anim { type: Motion.fastSpatial }
    }

    MaterialShape {
        id: shape

        anchors.centerIn: parent
        implicitSize: root.implicitWidth
        shape: MaterialShape.ClamShell
        color: Qt.alpha(root.backgroundColour, 1)
        opacity: root.backgroundColour.a
        layer.enabled: true

        Behavior on color {
            CAnim { type: Motion.defaultEffects }
        }
    }

    Text {
        anchors.centerIn: shape
        anchors.verticalCenterOffset: 2
        visible: avatarImage.status !== Image.Ready
        text: root.fallbackText || "C"
        color: Theme.colorTextMuted
        font.family: Theme.fontDisplay
        font.pixelSize: Math.round(root.centerWidth / 4)
        font.weight: Font.DemiBold
    }

    Image {
        id: avatarImage

        anchors.fill: shape
        source: root.avatarSource
        fillMode: Image.PreserveAspectCrop
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        sourceSize.width: width
        sourceSize.height: height
        asynchronous: false
        cache: true
        visible: status === Image.Ready

        layer.enabled: visible
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: shape
            maskSpreadAtMin: 1
            maskThresholdMin: 0.5
        }

        onStatusChanged: {
            if (status === Image.Error && root.avatarSource)
                console.warn("Caelestia Greeter: failed to load avatar:", root.avatarSource);
        }
    }
}
