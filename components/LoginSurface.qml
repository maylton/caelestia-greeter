import QtQuick
import Quickshell.Widgets
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
    property int selectedSessionIndex: 0
    readonly property var selectedSession: sessions.length > 0
        ? sessions[Math.min(selectedSessionIndex, sessions.length - 1)]
        : ({ "name": I18n.t("login.session"), "command": [] })
    readonly property string profileLabel: displayName.length > 0
        ? displayName
        : defaultUser
    readonly property string welcomeLabel: profileLabel.length > 0
        ? I18n.t("login.welcomeUser").replace("%1", profileLabel)
        : I18n.t("login.welcome")

    signal closeRequested()

    implicitHeight: content.implicitHeight + 56
    radius: Theme.radiusXL
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

        if (root.defaultUser.length > 0)
            passwordField.focusInput(Qt.ActiveWindowFocusReason);
        else
            usernameField.focusInput(Qt.ActiveWindowFocusReason);
    }

    function submit() {
        if (AuthService.awaitingResponse) {
            AuthService.provideResponse(passwordField.text);
            passwordField.text = "";
            return;
        }

        const command = root.selectedSession.command || [];
        AuthService.authenticate(usernameField.text, passwordField.text, command);
        passwordField.text = "";
    }

    Component.onCompleted: root.focusInitialField()
    onActiveChanged: root.focusInitialField()
    onDefaultUserChanged: root.focusInitialField()

    Timer {
        id: initialFocusTimer

        interval: 60
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

        Row {
            width: parent.width
            spacing: 16

            ClippingRectangle {
                id: avatarFrame

                width: 64
                height: 64
                radius: 22
                color: Theme.colorPrimaryContainer
                border.width: 1
                border.color: Theme.colorOutline

                Image {
                    id: avatarImage

                    anchors.fill: parent
                    source: root.avatarSource
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: width
                    sourceSize.height: height
                    asynchronous: false
                    cache: true
                    visible: status === Image.Ready

                    onStatusChanged: {
                        if (status === Image.Error && root.avatarSource.length > 0)
                            console.warn("Caelestia Greeter: failed to load avatar:", root.avatarSource);
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: avatarImage.status !== Image.Ready
                    text: root.profileLabel.length > 0
                        ? root.profileLabel.charAt(0).toUpperCase()
                        : "C"
                    color: Theme.colorPrimaryContainerText
                    font.family: Theme.fontDisplay
                    font.pixelSize: 26
                    font.weight: Font.DemiBold
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - avatarFrame.width - parent.spacing
                spacing: 3

                Text {
                    width: parent.width
                    text: root.welcomeLabel
                    color: Theme.colorText
                    elide: Text.ElideRight
                    font.family: Theme.fontDisplay
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                }

                Text {
                    width: parent.width
                    text: root.defaultUser.length > 0
                        ? root.defaultUser
                        : (AuthService.previewMode
                            ? I18n.t("preview.description")
                            : I18n.t("login.subtitle"))
                    color: Theme.colorTextMuted
                    elide: Text.ElideRight
                    font.family: Theme.fontBody
                    font.pixelSize: 13
                }
            }
        }

        LuminaTextField {
            id: usernameField

            width: parent.width
            visible: root.defaultUser.length === 0
            placeholderText: I18n.t("login.username")
            enabled: visible && !AuthService.busy && !AuthService.awaitingResponse
            onAccepted: passwordField.focusInput(Qt.TabFocusReason)
        }

        LuminaTextField {
            id: passwordField

            width: parent.width
            placeholderText: AuthService.prompt.length > 0
                ? AuthService.prompt
                : I18n.t("login.password")
            passwordMode: !AuthService.echoResponse
            enabled: !AuthService.busy
            onAccepted: root.submit()
        }

        Column {
            width: parent.width
            spacing: 9

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
            width: parent.width
            visible: AuthService.errorMessage.length > 0
                || AuthService.statusMessage.length > 0
            text: AuthService.errorMessage.length > 0
                ? AuthService.errorMessage
                : AuthService.statusMessage
            color: AuthService.errorMessage.length > 0
                ? Theme.colorErrorText
                : Theme.colorTextMuted
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.fontBody
            font.pixelSize: 13
            font.weight: Font.Medium
        }

        Row {
            anchors.right: parent.right
            spacing: 10

            ActionChip {
                text: I18n.t("login.back")
                enabled: !AuthService.busy
                onClicked: root.closeRequested()
            }

            Rectangle {
                width: 142
                height: 48
                radius: 18
                color: submitMouse.pressed
                    ? Theme.colorPrimaryPressed
                    : Theme.colorPrimary
                opacity: AuthService.busy ? 0.65 : 1

                Behavior on color {
                    ColorAnimation { duration: Theme.durationShort }
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
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.submit()
                }
            }
        }
    }
}
