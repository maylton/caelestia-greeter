import QtQuick
import "../design"

Rectangle {
    id: root

    property alias text: input.text
    property string placeholderText: ""
    property bool passwordMode: false
    signal accepted()

    implicitHeight: 54
    radius: 18
    color: input.activeFocus ? Tokens.fieldActive : Tokens.field
    border.width: input.activeFocus ? 2 : 1
    border.color: input.activeFocus ? Tokens.primary : Tokens.outline

    Behavior on color {
        ColorAnimation { duration: Tokens.motionShort }
    }

    TextInput {
        id: input
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 18
        }
        color: Tokens.onSurface
        selectionColor: Tokens.primaryContainer
        selectedTextColor: Tokens.onPrimaryContainer
        font.family: Tokens.fontFamily
        font.pixelSize: 15
        echoMode: root.passwordMode ? TextInput.Password : TextInput.Normal
        passwordCharacter: "●"
        clip: true
        onAccepted: root.accepted()
    }

    Text {
        anchors {
            left: input.left
            verticalCenter: parent.verticalCenter
        }
        visible: input.text.length === 0 && !input.activeFocus
        text: root.placeholderText
        color: Tokens.onSurfaceMuted
        font.family: Tokens.fontFamily
        font.pixelSize: 15
    }
}
