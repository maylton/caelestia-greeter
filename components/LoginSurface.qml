import QtQuick
import "../design"
import "../i18n"
import "../services"

Rectangle {
    id: root

    property string defaultUser: ""
    property string displayName: ""
    property string avatarSource: ""
    property var sessions: []
    property bool active: true
    property real presentationProgress: 1
    property real headerProgress: 0
    property real fieldsProgress: 0
    property real actionsProgress: 0
    property int selectedSessionIndex: 0
    readonly property var selectedSession: sessions.length > 0
        ? sessions[Math.min(selectedSessionIndex, sessions.length - 1)]
        : ({ "name": I18n.t("login.session"), "command": [] })
    readonly property string profileLabel: displayName || defaultUser
    readonly property string welcomeLabel: profileLabel
        ? I18n.t("login.welcomeUser").replace("%1", profileLabel)
        : I18n.t("login.welcome")
    readonly property bool hasMessage: AuthService.errorMessage.length > 0
        || AuthService.statusMessage.length > 0
    readonly property int actionButtonWidth: 142
    readonly property int actionButtonHeight: 48

    signal closeRequested()

    implicitHeight: content.implicitHeight + 56
    radius: 48 - presentationProgress * 14
    color: Theme.colorSurface
    border.width: 1
    border.color: Theme.colorOutline

    function focusInitialField() {
        usernameField.text = root.defaultUser;
        initialFocusTimer.stop();
        if (root.active)
            initialFocusTimer.start();
    }

    function applyInitialFocus() {
        if (!root.active)
            return;

        (root.defaultUser ? passwordField : usernameField).focusInput(Qt.ActiveWindowFocusReason);
    }

    function resetReveal() {
        revealAnimation.stop();
        headerProgress = 0;
        fieldsProgress = 0;
        actionsProgress = 0;
    }

    function startReveal() {
        resetReveal();
        revealAnimation.start();
    }

    function submit() {
        if (AuthService.awaitingResponse) {
            AuthService.provideResponse(passwordField.text);
            passwordField.text = "";
            return;
        }

        AuthService.authenticate(
            usernameField.text,
            passwordField.text,
            root.selectedSession.command || []
        );
        passwordField.text = "";
    }

    Component.onCompleted: {
        root.focusInitialField();
        if (root.active)
            root.startReveal();
    }

    onActiveChanged: {
        root.focusInitialField();
        if (root.active)
            root.startReveal();
        else
            root.resetReveal();
    }

    onDefaultUserChanged: root.focusInitialField()

    Behavior on color {
        CAnim { type: Motion.slowEffects }
    }

    Behavior on border.color {
        CAnim { type: Motion.slowEffects }
    }

    ParallelAnimation {
        id: revealAnimation

        Anim {
            target: root
            property: "headerProgress"
            from: 0
            to: 1
            type: Motion.fastSpatial
        }

        SequentialAnimation {
            PauseAnimation { duration: 90 }

            Anim {
                target: root
                property: "fieldsProgress"
                from: 0
                to: 1
                type: Motion.defaultSpatial
            }
        }

        SequentialAnimation {
            PauseAnimation { duration: 190 }

            Anim {
                target: root
                property: "actionsProgress"
                from: 0
                to: 1
                type: Motion.fastSpatial
            }
        }
    }

    Timer {
        id: initialFocusTimer

        interval: 260
        repeat: false
        onTriggered: root.applyInitialFocus()
    }

    Connections {
        target: AuthService

        function onAwaitingResponseChanged() {
            if (AuthService.awaitingResponse)
                passwordField.focusInput(Qt.ActiveWindowFocusReason);
        }
    }

    Column {
        id: content

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 28
        }
        spacing: 18

        Column {
            id: profileHeader

            width: parent.width
            spacing: 10
            opacity: root.headerProgress
            scale: 0.68 + root.headerProgress * 0.32
            transformOrigin: Item.Center
            transform: Translate {
                y: (1 - root.headerProgress) * 42
            }

            ExpressiveProfilePic {
                id: avatarFrame

                anchors.horizontalCenter: parent.horizontalCenter
                centerWidth: Math.min(320, profileHeader.width)
                avatarSource: root.avatarSource
                fallbackText: root.profileLabel
                    ? root.profileLabel.charAt(0).toUpperCase()
                    : "C"
            }

            Column {
                width: parent.width
                spacing: 3

                Text {
                    width: parent.width
                    text: root.welcomeLabel
                    color: Theme.colorText
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Theme.fontDisplay
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                }

                Text {
                    width: parent.width
                    text: root.defaultUser
                        || (AuthService.previewMode
                            ? I18n.t("preview.description")
                            : I18n.t("login.subtitle"))
                    color: Theme.colorTextMuted
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Theme.fontBody
                    font.pixelSize: 13
                }
            }
        }

        GreeterTextField {
            id: usernameField

            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width, 420)
            visible: !root.defaultUser
            revealProgress: root.fieldsProgress
            transform: Translate {
                y: (1 - root.fieldsProgress) * 52
            }
            placeholderText: I18n.t("login.username")
            enabled: visible && !AuthService.busy && !AuthService.awaitingResponse
            onAccepted: passwordField.focusInput(Qt.TabFocusReason)
        }

        GreeterTextField {
            id: passwordField

            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width, 390)
            revealProgress: root.fieldsProgress
            transform: Translate {
                y: (1 - root.fieldsProgress) * 64
            }
            placeholderText: AuthService.prompt || I18n.t("login.password")
            passwordMode: !AuthService.echoResponse
            enabled: !AuthService.busy
            onAccepted: root.submit()
        }

        Column {
            width: parent.width
            spacing: 9
            visible: root.sessions.length > 1
            opacity: root.actionsProgress
            scale: 0.82 + root.actionsProgress * 0.18
            transform: Translate {
                y: (1 - root.actionsProgress) * 34
            }

            Text {
                text: I18n.t("login.session")
                color: Theme.colorTextMuted
                font.family: Theme.fontBody
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }

            Row {
                spacing: 8

                Repeater {
                    model: root.sessions

                    delegate: ActionChip {
                        required property int index
                        required property var modelData

                        text: modelData.name
                        selected: index === root.selectedSessionIndex
                        enabled: !AuthService.busy
                        onClicked: root.selectedSessionIndex = index
                    }
                }
            }
        }

        Text {
            id: statusText

            width: parent.width
            height: root.hasMessage ? implicitHeight : 0
            visible: height > 0
            text: AuthService.errorMessage || AuthService.statusMessage
            color: AuthService.errorMessage ? Theme.colorErrorText : Theme.colorTextMuted
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.fontBody
            font.pixelSize: 13
            font.weight: Font.Medium
            opacity: (root.hasMessage ? 1 : 0) * root.actionsProgress
            scale: (root.hasMessage ? 1 : 0.90)
                * (0.84 + root.actionsProgress * 0.16)

            Behavior on height {
                Anim { type: Motion.fastSpatial }
            }

            Behavior on opacity {
                Anim { type: Motion.defaultEffects }
            }

            Behavior on scale {
                Anim { type: Motion.fastSpatial }
            }

            Behavior on color {
                CAnim { type: Motion.defaultEffects }
            }
        }

        Row {
            anchors.right: parent.right
            spacing: 10
            opacity: root.actionsProgress
            scale: 0.78 + root.actionsProgress * 0.22
            transform: Translate {
                y: (1 - root.actionsProgress) * 44
            }

            ActionChip {
                width: root.actionButtonWidth
                height: root.actionButtonHeight
                defaultRadius: 18
                pressedRadius: 10
                text: I18n.t("login.back")
                enabled: !AuthService.busy
                onClicked: root.closeRequested()
            }

            Rectangle {
                width: root.actionButtonWidth
                height: root.actionButtonHeight
                radius: submitMouse.pressed ? 10 : 18
                scale: submitMouse.pressed ? 0.88 : 1
                color: submitMouse.pressed ? Theme.colorPrimaryPressed : Theme.colorPrimary
                opacity: AuthService.busy ? 0.65 : 1

                Behavior on radius {
                    Anim { type: Motion.defaultEffects }
                }

                Behavior on scale {
                    Anim { type: Motion.fastSpatial }
                }

                Behavior on color {
                    CAnim { type: Motion.defaultEffects }
                }

                Behavior on opacity {
                    Anim { type: Motion.defaultEffects }
                }

                Text {
                    anchors.centerIn: parent
                    text: AuthService.busy
                        ? I18n.t("login.signingIn")
                        : I18n.t("login.signIn")
                    color: Theme.colorPrimaryText
                    font.family: Theme.fontBody
                    font.pixelSize: 14
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: submitMouse

                    anchors.fill: parent
                    enabled: !AuthService.busy
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.submit()
                }
            }
        }
    }
}
