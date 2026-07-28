pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Greetd
import QtQuick
import "../i18n"

Singleton {
    id: root

    property string prompt: I18n.t("login.password")
    property string errorMessage: ""
    property string statusMessage: ""
    property string pendingResponse: ""
    property var launchCommand: []
    property bool busy: false
    property bool awaitingResponse: false
    property bool echoResponse: false
    property bool markerPending: false

    readonly property string launchMarkerPath: `${Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"}/caelestia-greeter-launch-requested`
    readonly property bool previewMode: {
        const value = Quickshell.env("CAELESTIA_GREETER_PREVIEW") || "";
        return value === "1" || value.toLowerCase() === "true" || !Greetd.available;
    }

    function authenticate(user, response, command) {
        const username = user.trim();
        if (!username) {
            root.errorMessage = I18n.t("auth.usernameRequired");
            return;
        }
        if (!command || command.length === 0) {
            root.errorMessage = I18n.t("auth.invalidSession");
            return;
        }

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

        Greetd.createSession(username);
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
        root.launchCommand = [];
        root.busy = false;
        root.awaitingResponse = false;
        root.markerPending = false;
        root.statusMessage = "";
        root.errorMessage = "";

        if (launchMarkerProcess.running)
            launchMarkerProcess.running = false;
        if (!root.previewMode && Greetd.user)
            Greetd.cancelSession();
    }

    function requestSessionLaunch() {
        if (!root.launchCommand.length) {
            root.busy = false;
            root.errorMessage = I18n.t("auth.missingCommand");
            return;
        }

        root.markerPending = true;
        launchMarkerProcess.exec(["/usr/bin/touch", root.launchMarkerPath]);
    }

    Process {
        id: launchMarkerProcess

        onExited: exitCode => {
            if (!root.markerPending)
                return;

            root.markerPending = false;
            if (exitCode !== 0) {
                root.busy = false;
                root.statusMessage = "";
                root.errorMessage = I18n.t("auth.handoffFailed");
                return;
            }

            Greetd.launch(root.launchCommand, [], true);
        }
    }

    Timer {
        id: previewTimer

        interval: 650
        onTriggered: {
            root.busy = false;
            root.statusMessage = I18n.t("auth.previewSuccess");
        }
    }

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            root.prompt = message || I18n.t("login.password");
            root.echoResponse = echoResponse;

            if (error) {
                root.errorMessage = message;
                root.statusMessage = "";
                root.busy = false;
                return;
            }
            if (!responseRequired)
                return;

            if (root.pendingResponse) {
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
            root.launchCommand = [];
            root.busy = false;
            root.awaitingResponse = false;
            root.markerPending = false;
            root.statusMessage = "";
            root.errorMessage = message || I18n.t("auth.failed");
        }

        function onReadyToLaunch() {
            root.statusMessage = I18n.t("auth.startingSession");
            root.requestSessionLaunch();
        }

        function onError(error) {
            root.busy = false;
            root.awaitingResponse = false;
            root.markerPending = false;
            root.statusMessage = "";
            root.errorMessage = error;
        }
    }
}
