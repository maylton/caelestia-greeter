import QtQuick
import M3Shapes
import "../design"

Item {
    id: root

    property bool active: false
    signal clicked()

    implicitWidth: 40
    implicitHeight: 40

    MaterialShape {
        anchors.fill: parent
        shape: root.active ? MaterialShape.Arrow : MaterialShape.Circle
        color: root.active ? Theme.colorPrimary : Theme.colorSurfacePressed
        scale: root.active
            ? (mouse.pressed ? 0.60 : mouse.containsMouse ? 0.80 : 0.70)
            : 1
        rotation: 90

        Behavior on scale {
            Anim { type: Motion.fastSpatial }
        }

        Behavior on color {
            CAnim { type: Motion.defaultEffects }
        }

        MouseArea {
            id: mouse

            anchors.fill: parent
            enabled: root.enabled && root.active
            hoverEnabled: true
            cursorShape: root.active ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.clicked()
        }
    }

    Text {
        anchors.centerIn: parent
        text: "arrow_forward"
        color: Theme.colorTextMuted
        font.family: Theme.fontIcon
        font.pixelSize: 20
        opacity: root.active ? 0 : 1

        Behavior on opacity {
            Anim { type: Motion.defaultEffects }
        }
    }
}
