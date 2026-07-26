import QtQuick
import "../design/Tokens.js" as Tokens

Rectangle {
    id: root

    property alias text: input.text
    property string placeholderText: ""
    property bool passwordMode: false
    signal accepted()

    implicitHeight: 54
    radius: 18
    color: input.activeFocus ? Tokens.colorFieldActive : Tokens.colorField
    border.width: input.activeFocus ? 2 : 1
    border.color: input.activeFocus ? Tokens.colorPrimary : Tokens.colorOutline

    Behavior on color {
        ColorAnimation { duration: Tokens.durationShort }
    }

    TextInput {
        id: input
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 18
        }
        color: Tokens.colorText
        selectionColor: Tokens.colorPrimaryContainer
        selectedTextColor: Tokens.colorPrimaryContainerText
        font.family: Tokens.fontBody
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
        color: Tokens.colorTextMuted
        font.family: Tokens.fontBody
        font.pixelSize: 15
    }
}
