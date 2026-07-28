import QtQuick
import "../design"

Rectangle {
    id: root

    property alias text: input.text
    property string placeholderText: ""
    property bool passwordMode: false
    property real revealProgress: 1
    signal accepted()

    implicitHeight: 54
    radius: input.activeFocus ? 12 : 18
    scale: (0.78 + revealProgress * 0.22)
        * (input.activeFocus ? 1.028 : 1)
    color: input.activeFocus ? Theme.colorFieldActive : Theme.colorField
    border.width: input.activeFocus ? 2 : 1
    border.color: input.activeFocus ? Theme.colorPrimary : Theme.colorOutline
    opacity: (root.enabled ? 1 : 0.55) * revealProgress

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
        opacity: root.passwordMode ? 0 : 1
        color: Theme.colorText
        selectionColor: Theme.colorPrimaryContainer
        selectedTextColor: Theme.colorPrimaryContainerText
        horizontalAlignment: root.passwordMode ? TextInput.AlignHCenter : TextInput.AlignLeft
        font.family: Theme.fontBody
        font.pixelSize: 15
        echoMode: root.passwordMode ? TextInput.NoEcho : TextInput.Normal
        cursorVisible: !root.passwordMode && activeFocus
        inputMethodHints: root.passwordMode
            ? Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
            : Qt.ImhNone
        clip: true
        onAccepted: root.accepted()
    }

    Loader {
        id: passwordGlyphLoader

        anchors {
            left: input.left
            right: input.right
            verticalCenter: parent.verticalCenter
        }
        height: 28
        active: root.passwordMode
        source: "PasswordGlyphs.qml"
        visible: active && input.text.length > 0 && status === Loader.Ready

        onLoaded: {
            item.buffer = Qt.binding(() => input.text);
            item.glyphColor = Qt.binding(() => Theme.colorText);
            item.glyphSize = 18;
        }
    }

    Row {
        anchors.centerIn: passwordGlyphLoader
        spacing: 5
        visible: root.passwordMode
            && input.text.length > 0
            && passwordGlyphLoader.status !== Loader.Ready

        Repeater {
            model: input.text.length

            delegate: Rectangle {
                required property int index

                width: 10
                height: 10
                radius: width / 2
                color: Theme.colorText
            }
        }
    }

    Text {
        id: placeholder

        x: root.passwordMode
            ? Math.round((root.width - implicitWidth) / 2)
            : input.x
        anchors.verticalCenter: parent.verticalCenter
        text: root.placeholderText
        color: Theme.colorTextMuted
        font.family: Theme.fontBody
        font.pixelSize: 15
        opacity: input.text.length === 0 && !input.activeFocus ? 1 : 0
        scale: opacity > 0 ? 1 : 0.90

        Behavior on opacity {
            Anim { type: Motion.defaultEffects }
        }

        Behavior on scale {
            Anim { type: Motion.fastSpatial }
        }
    }

    Rectangle {
        id: passwordCaret

        x: Math.round((root.width - width) / 2)
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: 20
        radius: 1
        color: Theme.colorPrimary
        visible: root.passwordMode
            && input.activeFocus
            && input.text.length === 0

        SequentialAnimation {
            running: passwordCaret.visible
            loops: Animation.Infinite

            NumberAnimation {
                target: passwordCaret
                property: "opacity"
                from: 1
                to: 0.18
                duration: 450
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                target: passwordCaret
                property: "opacity"
                from: 0.18
                to: 1
                duration: 450
                easing.type: Easing.InOutQuad
            }
        }
    }
}
