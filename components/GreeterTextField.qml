import QtQuick
import "../design"

Rectangle {
    id: root

    property alias text: input.text
    property string placeholderText: ""
    property bool passwordMode: false
    signal accepted()

    implicitHeight: 54
    radius: input.activeFocus ? 14 : 18
    scale: input.activeFocus ? 1.012 : 1
    color: input.activeFocus ? Theme.colorFieldActive : Theme.colorField
    border.width: input.activeFocus ? 2 : 1
    border.color: input.activeFocus ? Theme.colorPrimary : Theme.colorOutline
    opacity: root.enabled ? 1 : 0.55

    function focusInput(reason) {
        input.forceActiveFocus(reason ?? Qt.OtherFocusReason);
    }

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

    Behavior on border.width {
        Anim { type: Motion.defaultEffects }
    }

    Behavior on opacity {
        Anim { type: Motion.defaultEffects }
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
        text: root.placeholderText
        color: Theme.colorTextMuted
        font.family: Theme.fontBody
        font.pixelSize: 15
        opacity: input.text.length === 0 && !input.activeFocus ? 1 : 0
        scale: opacity > 0 ? 1 : 0.96

        Behavior on opacity {
            Anim { type: Motion.defaultEffects }
        }

        Behavior on scale {
            Anim { type: Motion.fastSpatial }
        }
    }
}
