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
            return Tokens.disabled;
        if (mouse.pressed)
            return root.destructive ? Tokens.errorContainerPressed : Tokens.surfacePressed;
        if (root.selected)
            return Tokens.secondaryContainer;
        return root.destructive ? Tokens.errorContainer : Tokens.surfaceContainer;
    }
    border.width: root.selected ? 0 : 1
    border.color: root.destructive ? Tokens.errorOutline : Tokens.outline
    opacity: root.enabled ? 1 : 0.55

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: {
            if (root.destructive)
                return Tokens.onErrorContainer;
            return root.selected ? Tokens.onSecondaryContainer : Tokens.onSurface;
        }
        font.family: Tokens.fontFamily
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
