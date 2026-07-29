import Quickshell
import Quickshell.Wayland
import QtQuick
import "../config"
import "../design"
import "../i18n"
import "../services"

PanelWindow {
    id: window

    required property var modelData
    readonly property bool interactiveScreen: modelData === Quickshell.screens[0]
    property bool loginOpen: Config.loginStartsOpen
    property real loginSpatial: loginOpen ? 1 : 0
    property real loginEffects: loginOpen ? 1 : 0
    property real exitSpatial: AuthService.launching ? 1 : 0
    property real exitEffects: AuthService.launching ? 1 : 0
    property int selectedUserIndex: 0
    property int selectedSessionIndex: 0
    property string openSelector: ""

    readonly property var userChoices: {
        const result = [];
        const users = Array.isArray(CatalogService.users) ? CatalogService.users : [];
        for (const user of users) {
            result.push({
                "username": String(user.username || ""),
                "displayName": String(user.displayName || user.username || ""),
                "avatar": String(user.avatar || ""),
                "manual": false
            });
        }
        result.push({
            "username": "",
            "displayName": I18n.t("login.otherUser"),
            "avatar": "",
            "manual": true
        });
        return result;
    }

    readonly property var sessionChoices: {
        const result = [];
        const sessions = Array.isArray(CatalogService.sessions) ? CatalogService.sessions : [];
        for (const session of sessions) {
            result.push({
                "name": String(session.name || I18n.t("login.session")),
                "command": Array.isArray(session.command) ? session.command : [],
                "type": session.type === "x11" ? "x11" : "wayland",
                "detail": session.type === "x11"
                    ? I18n.t("session.x11")
                    : I18n.t("session.wayland"),
                "desktopFile": String(session.desktopFile || "")
            });
        }
        return result;
    }

    readonly property var selectedUser: userChoices.length > 0
        ? userChoices[Math.max(0, Math.min(selectedUserIndex, userChoices.length - 1))]
        : null
    readonly property var selectedSession: sessionChoices.length > 0
        ? sessionChoices[Math.max(0, Math.min(selectedSessionIndex, sessionChoices.length - 1))]
        : null
    readonly property bool manualUserSelected: selectedUser && selectedUser.manual === true

    function commandKey(session) {
        return session && Array.isArray(session.command)
            ? JSON.stringify(session.command)
            : "";
    }

    function alignUserSelection() {
        if (userChoices.length === 0) {
            selectedUserIndex = 0;
            return;
        }

        if (selectedUser && selectedUser.manual) {
            selectedUserIndex = userChoices.length - 1;
            return;
        }

        const currentUsername = selectedUser ? selectedUser.username : "";
        const preferredUsername = currentUsername || Config.defaultUser;
        let index = preferredUsername
            ? userChoices.findIndex(user => !user.manual && user.username === preferredUsername)
            : -1;
        if (index < 0)
            index = userChoices.length > 1 ? 0 : userChoices.length - 1;
        selectedUserIndex = index;
    }

    function alignSessionSelection() {
        if (sessionChoices.length === 0) {
            selectedSessionIndex = 0;
            return;
        }

        const currentKey = commandKey(selectedSession);
        let index = currentKey
            ? sessionChoices.findIndex(session => commandKey(session) === currentKey)
            : -1;
        if (index < 0)
            index = 0;
        selectedSessionIndex = index;
    }

    Component.onCompleted: {
        alignUserSelection();
        alignSessionSelection();
    }

    Connections {
        target: CatalogService

        function onUsersChanged() {
            window.alignUserSelection();
        }

        function onSessionsChanged() {
            window.alignSessionSelection();
        }
    }

    screen: modelData
    color: "transparent"
    focusable: interactiveScreen
    aboveWindows: true

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: interactiveScreen
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None
    WlrLayershell.namespace: "caelestia-greeter"

    Behavior on loginSpatial {
        Anim { type: Motion.defaultSpatial }
    }

    Behavior on loginEffects {
        Anim { type: Motion.defaultEffects }
    }

    Behavior on exitSpatial {
        Anim { type: Motion.defaultSpatial }
    }

    Behavior on exitEffects {
        Anim { type: Motion.slowEffects }
    }

    Item {
        id: scene

        property real backgroundProgress: 0
        property real spatialProgress: 0
        property real effectProgress: 0

        anchors.fill: parent
        focus: window.interactiveScreen

        Keys.onPressed: event => {
            if (!window.interactiveScreen || AuthService.launching)
                return;

            if (event.key === Qt.Key_Escape && window.openSelector) {
                window.openSelector = "";
                event.accepted = true;
                return;
            }

            if (event.key === Qt.Key_Escape && window.loginOpen) {
                AuthService.cancel();
                window.loginOpen = false;
                event.accepted = true;
                return;
            }

            if (!window.loginOpen) {
                window.openSelector = "";
                window.loginOpen = true;
                event.accepted = true;
            }
        }

        ParallelAnimation {
            running: true

            Anim {
                target: scene
                property: "backgroundProgress"
                from: 0
                to: 1
                type: Motion.standardLarge
            }

            Anim {
                target: scene
                property: "spatialProgress"
                from: 0
                to: 1
                type: Motion.defaultSpatial
            }

            SequentialAnimation {
                PauseAnimation { duration: 120 }

                Anim {
                    target: scene
                    property: "effectProgress"
                    from: 0
                    to: 1
                    type: Motion.slowEffects
                }
            }
        }

        Image {
            id: wallpaper

            anchors.fill: parent
            source: Config.wallpaperSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            opacity: scene.backgroundProgress
            scale: 1.10
                - scene.spatialProgress * 0.10
                + window.exitSpatial * 0.08
        }

        Rectangle {
            anchors.fill: parent
            opacity: scene.backgroundProgress

            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.scrimTop }
                GradientStop { position: 0.52; color: Theme.scrimMiddle }
                GradientStop { position: 1.0; color: Theme.scrimBottom }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(
                Theme.loginScrim,
                Theme.loginScrim.a * window.loginEffects * scene.effectProgress
            )
        }

        MouseArea {
            anchors.fill: parent
            enabled: window.interactiveScreen
                && !window.loginOpen
                && !AuthService.launching
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                window.openSelector = "";
                window.loginOpen = true;
            }
        }

        ExpressiveClock {
            id: clock

            readonly property real closedY: Math.round((scene.height - height) / 2 - 26)
            readonly property real openY: Math.max(
                76,
                Math.min(150, scene.height * 0.15)
            )

            baseSize: Math.max(112, Math.min(scene.width * 0.16, scene.height * 0.25))
            x: Math.round((scene.width - width) / 2)
            y: closedY
                + (openY - closedY) * window.loginSpatial
                + (1 - scene.spatialProgress) * 86
                - window.exitSpatial * 34
            opacity: scene.effectProgress * (1 - window.exitEffects)
            scale: (0.54 + scene.spatialProgress * 0.46)
                * (1 - window.loginSpatial * 0.02)
                * (1 - window.exitSpatial * 0.30)
            rotation: -6 * (1 - scene.spatialProgress)
                + window.exitSpatial * 4
            transformOrigin: Item.Center
        }

        Column {
            id: selectors

            anchors {
                left: parent.left
                top: parent.top
                margins: 24
            }
            spacing: 10
            visible: window.interactiveScreen
            enabled: !window.loginOpen && !AuthService.launching
            opacity: scene.effectProgress
                * (1 - window.loginEffects)
                * (1 - window.exitEffects)
            scale: 0.80 + scene.spatialProgress * 0.20
            transform: Translate {
                x: (1 - scene.spatialProgress) * -42
            }

            SelectionMenu {
                label: I18n.t("login.user")
                options: window.userChoices
                selectedIndex: window.selectedUserIndex
                nameRole: "displayName"
                detailRole: "username"
                open: window.openSelector === "user"
                interactive: selectors.enabled

                onToggleRequested: {
                    window.openSelector = window.openSelector === "user" ? "" : "user";
                }

                onSelected: index => {
                    window.selectedUserIndex = index;
                    window.openSelector = "";
                }
            }

            SelectionMenu {
                label: I18n.t("login.session")
                options: window.sessionChoices
                selectedIndex: window.selectedSessionIndex
                nameRole: "name"
                detailRole: "detail"
                open: window.openSelector === "session"
                interactive: selectors.enabled

                onToggleRequested: {
                    window.openSelector = window.openSelector === "session" ? "" : "session";
                }

                onSelected: index => {
                    window.selectedSessionIndex = index;
                    window.openSelector = "";
                }
            }
        }

        LoginSurface {
            id: loginSurface

            readonly property real targetY: Math.min(
                scene.height - height - 64,
                clock.y + clock.height + 60
            )

            visible: window.interactiveScreen
            width: Math.min(540, scene.width - 40)
            x: Math.round((scene.width - width) / 2)
            y: targetY
                + (1 - scene.spatialProgress) * 116
                + (1 - window.loginSpatial) * 72
                + window.exitSpatial * 94
            opacity: scene.effectProgress
                * window.loginEffects
                * (1 - window.exitEffects)
            scale: (0.68 + scene.spatialProgress * 0.32)
                * (0.88 + window.loginSpatial * 0.12)
                * (1 - window.exitSpatial * 0.44)
            rotation: -5 * (1 - scene.spatialProgress)
                - 2 * (1 - window.loginSpatial)
                + window.exitSpatial * 7
            transformOrigin: Item.Center
            presentationProgress: scene.spatialProgress
                * window.loginSpatial
                * (1 - window.exitSpatial)
            enabled: window.loginOpen && !AuthService.launching
            active: window.loginOpen
            defaultUser: window.manualUserSelected || !window.selectedUser
                ? ""
                : window.selectedUser.username
            displayName: window.manualUserSelected || !window.selectedUser
                ? ""
                : window.selectedUser.displayName
            avatarSource: window.manualUserSelected || !window.selectedUser
                ? ""
                : window.selectedUser.avatar
            sessions: window.selectedSession
                ? [window.selectedSession]
                : CatalogService.sessions

            onCloseRequested: {
                AuthService.cancel();
                window.loginOpen = false;
                scene.forceActiveFocus();
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 48 - (1 - window.loginSpatial) * 12
            text: I18n.t("idle.prompt")
            color: Theme.colorTextMuted
            font.family: Theme.fontBody
            font.pixelSize: 14
            font.weight: Font.Medium
            opacity: scene.effectProgress
                * (1 - window.loginEffects)
                * (1 - window.exitEffects)
            scale: 0.82 + (1 - window.loginSpatial) * 0.18
        }

        Row {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 24
            spacing: 10
            visible: window.interactiveScreen
            enabled: !AuthService.launching
            opacity: scene.effectProgress * (1 - window.exitEffects)
            scale: 0.84 + scene.spatialProgress * 0.16
            transform: Translate {
                y: (1 - scene.spatialProgress) * 42
                    + window.exitSpatial * 32
            }

            ActionChip {
                text: I18n.t("power.restart")
                onClicked: PowerService.reboot()
            }

            ActionChip {
                text: I18n.t("power.powerOff")
                destructive: true
                onClicked: PowerService.powerOff()
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 24
            width: previewLabel.implicitWidth + 28
            height: 38
            radius: height / 2
            color: Theme.colorSurfaceContainer
            border.color: Theme.colorOutline
            visible: AuthService.previewMode && window.interactiveScreen
            opacity: scene.effectProgress * (1 - window.exitEffects)
            scale: (0.72 + scene.spatialProgress * 0.28)
                * (1 - window.exitSpatial * 0.20)
            transform: Translate {
                y: (1 - scene.spatialProgress) * 34
                    + window.exitSpatial * 26
            }

            Text {
                id: previewLabel

                anchors.centerIn: parent
                text: I18n.t("preview.badge")
                color: Theme.colorText
                font.family: Theme.fontBody
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }
        }
    }
}
