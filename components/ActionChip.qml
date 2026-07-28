import QtQuick
import "../design"

Rectangle {
    id: root

    property string text: ""
    property bool selected: false
    property bool destructive: false
    property real defaultRadius: height / 2
    property real pressedRadius: 10
    property real hoverScale: 1.035
    property real pressedScale: 0.88
    signal clicked()

    implicitWidth: label.implicitWidth + 28
    implicitHeight: 42
    radius: mouse.pressed ? pressedRadius : defaultRadius
    scale: mouse.pressed ? pressedScale : mouse.containsMouse ? hoverScale : 1
    color: {
        if (!root.enabled)
            return Theme.colorDisabled;
        if (mouse.pressed)
            return root.destructive ? Theme.colorErrorContainerPressed : Theme.colorSurfacePressed;
        if (root.selected)
            return Theme.colorSecondaryContainer;
        return root.destructive ? Theme.colorErrorContainer : Theme.colorSurfaceContainer;
    }
    border.width: root.selected ? 0 : 1
    border.color: root.destructive ? Theme.colorErrorOutline : Theme.colorOutline
    opacity: root.enabled ? 1 : 0.55

    Behavior on radius {
        Anim { type: Motion.defaultEffects }
    }

    Behavior on scale {
        Anim { type: Motion.fastSpatial }
    }

    Behavior on color {
        CAnim { type: Motion.defaultEffects }
    }

    Behavior on border.color {
        CAnim { type: Motion.defaultEffects }
    }

    Behavior on opacity {
        Anim { type: Motion.defaultEffects }
    }

    Text {
        id: label

        anchors.centerIn: parent
        text: root.text
        color: {
            if (root.destructive)
                return Theme.colorErrorContainerText;
            return root.selected ? Theme.colorSecondaryContainerText : Theme.colorText;
        }
        font.family: Theme.fontBody
        font.pixelSize: 13
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
