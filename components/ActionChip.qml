import QtQuick
import "../design"

Rectangle {
    id: root

    property string text: ""
    property bool selected: false
    property bool destructive: false
    signal clicked()

    implicitWidth: label.implicitWidth + 28
    implicitHeight: 42
    radius: height / 2
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

    Behavior on color {
        ColorAnimation { duration: Theme.durationShort }
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
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
