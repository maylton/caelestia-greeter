import QtQuick
import "../design"

Rectangle {
    id: root

    property alias text: input.text
    property string placeholderText: ""
    property bool passwordMode: false
    property real revealProgress: 1
    readonly property bool passwordHasText: input.text.length > 0
    readonly property int passwordSideSize: 40
    readonly property int passwordSpacing: 14
    readonly property real compactPasswordWidth: placeholder.implicitWidth
        + passwordSideSize * 2
        + passwordSpacing * 2
        + 32
    signal accepted()

    implicitHeight: 54
    radius: passwordMode ? height / 2 : input.activeFocus ? 12 : 18
    scale: (0.78 + revealProgress * 0.22)
        * (input.activeFocus ? 1.028 : 1)
    color: passwordMode
        ? Theme.colorSurfaceContainer
        : input.activeFocus ? Theme.colorFieldActive : Theme.colorField
    border.width: passwordMode ? 0 : input.activeFocus ? 2 : 1
    border.color: input.activeFocus ? Theme.colorPrimary : Theme.colorOutline
    opacity: (root.enabled ? 1 : 0.55) * revealProgress
    clip: true

    function focusInput(reason) {
        input.forceActiveFocus(reason ?? Qt.OtherFocusReason);
    }

    Behavior on width {
        Anim { type: Motion.defaultSpatial }
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
            fill: parent
            margins: root.passwordMode ? 8 : 18
        }
        enabled: root.enabled
        opacity: root.passwordMode ? 0 : 1
        color: Theme.colorText
        selectionColor: Theme.colorPrimaryContainer
        selectedTextColor: Theme.colorPrimaryContainerText
        horizontalAlignment: root.passwordMode ? TextInput.AlignHCenter : TextInput.AlignLeft
        verticalAlignment: TextInput.AlignVCenter
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

    Item {
        id: passwordLeft

        x: 8
        anchors.verticalCenter: parent.verticalCenter
        width: root.passwordSideSize
        height: root.passwordSideSize
        visible: root.passwordMode

        Text {
            anchors.centerIn: parent
            text: "lock"
            color: Theme.colorTextMuted
            font.family: Theme.fontIcon
            font.pixelSize: 18
        }
    }

    Item {
        id: passwordRight

        anchors {
            right: parent.right
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }
        width: root.passwordSideSize
        height: root.passwordSideSize
        visible: root.passwordMode

        Loader {
            id: actionLoader

            anchors.fill: parent
            active: root.passwordMode
            source: "PasswordAction.qml"
            visible: status === Loader.Ready

            onLoaded: {
                item.active = Qt.binding(() => root.passwordHasText);
                item.enabled = Qt.binding(() => root.enabled);
                item.clicked.connect(() => root.accepted());
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 34
            height: 34
            radius: root.passwordHasText ? 11 : width / 2
            scale: root.passwordHasText ? 0.82 : 1
            color: root.passwordHasText ? Theme.colorPrimary : Theme.colorSurfacePressed
            visible: actionLoader.status !== Loader.Ready

            Behavior on radius {
                Anim { type: Motion.fastSpatial }
            }

            Behavior on scale {
                Anim { type: Motion.fastSpatial }
            }

            Behavior on color {
                CAnim { type: Motion.defaultEffects }
            }

            Text {
                anchors.centerIn: parent
                text: "arrow_forward"
                color: root.passwordHasText ? Theme.colorPrimaryText : Theme.colorTextMuted
                font.family: Theme.fontIcon
                font.pixelSize: 18
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.enabled && root.passwordHasText
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.accepted()
            }
        }
    }

    Item {
        id: passwordCenter

        anchors {
            left: passwordLeft.right
            right: passwordRight.left
            top: parent.top
            bottom: parent.bottom
            leftMargin: root.passwordSpacing
            rightMargin: root.passwordSpacing
        }
        visible: root.passwordMode
    }

    Loader {
        id: passwordGlyphLoader

        anchors.fill: passwordCenter
        active: root.passwordMode
        source: "PasswordGlyphs.qml"
        visible: active && root.passwordHasText && status === Loader.Ready

        onLoaded: {
            item.buffer = Qt.binding(() => input.text);
            item.glyphColor = Qt.binding(() => Theme.colorText);
            item.glyphSize = 18;
        }
    }

    Row {
        anchors.centerIn: passwordCenter
        spacing: 5
        visible: root.passwordMode
            && root.passwordHasText
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
            ? passwordCenter.x + Math.round((passwordCenter.width - implicitWidth) / 2)
            : input.x
        anchors.verticalCenter: parent.verticalCenter
        text: root.placeholderText
        color: Theme.colorTextMuted
        font.family: Theme.fontBody
        font.pixelSize: 15
        opacity: input.text.length === 0
            && (root.passwordMode || !input.activeFocus)
            ? 1
            : 0
        scale: opacity > 0 ? 1 : 0.90

        Behavior on opacity {
            Anim { type: Motion.defaultEffects }
        }

        Behavior on scale {
            Anim { type: Motion.fastSpatial }
        }
    }
}
