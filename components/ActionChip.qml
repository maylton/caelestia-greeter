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
            return Tokens.colorDisabled;
        if (mouse.pressed)
            return root.destructive ? Tokens.colorErrorContainerPressed : Tokens.colorSurfacePressed;
        if (root.selected)
            return Tokens.colorSecondaryContainer;
        return root.destructive ? Tokens.colorErrorContainer : Tokens.colorSurfaceContainer;
    }
    border.width: root.selected ? 0 : 1
    border.color: root.destructive ? Tokens.colorErrorOutline : Tokens.colorOutline
    opacity: root.enabled ? 1 : 0.55

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: {
            if (root.destructive)
                return Tokens.colorErrorContainerText;
            return root.selected ? Tokens.colorSecondaryContainerText : Tokens.colorText;
        }
        font.family: Tokens.fontBody
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
