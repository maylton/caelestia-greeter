import QtQuick
import "../design"
import "../services"

Rectangle {
    id: root

    property string defaultUser: ""
    property var sessions: []
    property int selectedSessionIndex: 0
    readonly property var selectedSession: sessions.length > 0
        ? sessions[Math.min(selectedSessionIndex, sessions.length - 1)]
        : ({ "name": qsTr("Sessão"), "command": [] })

    signal closeRequested()

    implicitHeight: content.implicitHeight + 56
    radius: Tokens.radiusExtraLarge
    color: Tokens.surface
    border.width: 1
    border.color: Tokens.outline

    Component.onCompleted: {
        usernameField.text = root.defaultUser;
        if (root.defaultUser.length > 0)
            passwordField.forceActiveFocus();
        else
            usernameField.forceActiveFocus();
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

    Connections {
        target: AuthService

        function onAwaitingResponseChanged() {
            if (AuthService.awaitingResponse)
                passwordField.forceActiveFocus();
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

            Rectangle {
                width: 54
                height: 54
                radius: 20
                color: Tokens.primaryContainer

                Text {
                    anchors.centerIn: parent
                    text: usernameField.text.length > 0
                        ? usernameField.text.charAt(0).toUpperCase()
                        : "L"
                    color: Tokens.onPrimaryContainer
                    font.family: Tokens.displayFontFamily
                    font.pixelSize: 24
                    font.weight: Font.DemiBold
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: qsTr("Bem-vindo ao Lumina")
                    color: Tokens.onSurface
                    font.family: Tokens.displayFontFamily
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                }

                Text {
                    text: AuthService.previewMode
                        ? qsTr("Demonstração local — nenhuma sessão será iniciada")
                        : qsTr("Entre para iniciar sua sessão")
                    color: Tokens.onSurfaceMuted
                    font.family: Tokens.fontFamily
                    font.pixelSize: 13
                }
            }
        }

        LuminaTextField {
            id: usernameField
            width: parent.width
            placeholderText: qsTr("Nome de usuário")
            enabled: !AuthService.busy && !AuthService.awaitingResponse
            onAccepted: passwordField.forceActiveFocus()
        }

        LuminaTextField {
            id: passwordField
            width: parent.width
            placeholderText: AuthService.prompt.length > 0
                ? AuthService.prompt
                : qsTr("Senha")
            passwordMode: !AuthService.echoResponse
            enabled: !AuthService.busy
            onAccepted: root.submit()
        }

        Column {
            width: parent.width
            spacing: 9

            Text {
                text: qsTr("Sessão")
                color: Tokens.onSurfaceMuted
                font.family: Tokens.fontFamily
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
                ? Tokens.error
                : Tokens.onSurfaceMuted
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            font.family: Tokens.fontFamily
            font.pixelSize: 13
            font.weight: Font.Medium
        }

        Row {
            anchors.right: parent.right
            spacing: 10

            ActionChip {
                text: qsTr("Voltar")
                enabled: !AuthService.busy
                onClicked: root.closeRequested()
            }

            Rectangle {
                width: 142
                height: 48
                radius: 18
                color: submitMouse.pressed
                    ? Tokens.primaryPressed
                    : Tokens.primary
                opacity: AuthService.busy ? 0.65 : 1

                Text {
                    anchors.centerIn: parent
                    text: AuthService.busy ? qsTr("Entrando…") : qsTr("Entrar")
                    color: Tokens.onPrimary
                    font.family: Tokens.fontFamily
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
