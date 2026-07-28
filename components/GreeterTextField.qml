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
    color: input.activeFocus ? Theme.colorFieldActive : Theme.colorField
    border.width: input.activeFocus ? 2 : 1
    border.color: input.activeFocus ? Theme.colorPrimary : Theme.colorOutline

    function focusInput(reason) {
        input.forceActiveFocus(reason ?? Qt.OtherFocusReason);
    }

    Behavior on color {
        ColorAnimation { duration: Theme.durationShort }
    }

    TextInput {
        id: input

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 18
        }
        enabled: root.enabled
        color: Theme.colorText
        selectionColor: Theme.colorPrimaryContainer
        selectedTextColor: Theme.colorPrimaryContainerText
        font.family: Theme.fontBody
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
        color: Theme.colorTextMuted
        font.family: Theme.fontBody
        font.pixelSize: 15
    }
}
