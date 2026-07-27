pragma Singleton

import Quickshell
import Quickshell.Services.Greetd
import QtQuick
import "../i18n"

Singleton {
    id: root

    property string username: ""
    property string prompt: I18n.t("login.password")
    property string errorMessage: ""
    property string statusMessage: ""
    property string pendingResponse: ""
    property var launchCommand: []
    property bool busy: false
    property bool awaitingResponse: false
    property bool echoResponse: false

    readonly property bool previewMode: {
        const forced = Quickshell.env("LUMINA_GREETER_PREVIEW") || "";
        return forced === "1" || forced.toLowerCase() === "true" || !Greetd.available;
    }

    function authenticate(user, response, command) {
        const normalizedUser = user.trim();
        if (normalizedUser.length === 0) {
            root.errorMessage = I18n.t("auth.usernameRequired");
            return;
        }
        if (!command || command.length === 0) {
            root.errorMessage = I18n.t("auth.invalidSession");
            return;
        }

        root.username = normalizedUser;
        root.pendingResponse = response;
        root.launchCommand = command;
        root.errorMessage = "";
        root.statusMessage = I18n.t("auth.authenticating");
        root.awaitingResponse = false;
        root.busy = true;

        if (root.previewMode) {
            previewTimer.restart();
            return;
        }

        Greetd.createSession(root.username);
    }

    function provideResponse(response) {
        if (!root.awaitingResponse || root.previewMode)
            return;

        root.errorMessage = "";
        root.statusMessage = I18n.t("auth.authenticating");
        root.awaitingResponse = false;
        root.busy = true;
        Greetd.respond(response);
    }

    function cancel() {
        root.pendingResponse = "";
        root.busy = false;
        root.awaitingResponse = false;
        root.statusMessage = "";
        root.errorMessage = "";

        if (!root.previewMode && Greetd.user.length > 0)
            Greetd.cancelSession();
    }

    Timer {
        id: previewTimer
        interval: 650
        repeat: false
        onTriggered: {
            root.busy = false;
            root.statusMessage = I18n.t("auth.previewSuccess");
        }
    }

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            root.prompt = message && message.length > 0
                ? message
                : I18n.t("login.password");
            root.echoResponse = echoResponse;

            if (error) {
                root.errorMessage = message;
                root.statusMessage = "";
                root.busy = false;
                return;
            }

            if (!responseRequired)
                return;

            if (root.pendingResponse.length > 0) {
                const response = root.pendingResponse;
                root.pendingResponse = "";
                Greetd.respond(response);
                return;
            }

            root.awaitingResponse = true;
            root.busy = false;
            root.statusMessage = root.prompt;
        }

        function onAuthFailure(message) {
            root.pendingResponse = "";
            root.busy = false;
            root.awaitingResponse = false;
            root.statusMessage = "";
            root.errorMessage = message && message.length > 0
                ? message
                : I18n.t("auth.failed");
        }

        function onReadyToLaunch() {
            root.statusMessage = I18n.t("auth.startingSession");
            if (root.launchCommand.length > 0)
                Greetd.launch(root.launchCommand, [], true);
            else {
                root.busy = false;
                root.errorMessage = I18n.t("auth.missingCommand");
            }
        }

        function onError(error) {
            root.busy = false;
            root.awaitingResponse = false;
            root.statusMessage = "";
            root.errorMessage = error;
        }
    }
}
