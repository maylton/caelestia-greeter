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

            if (event.key === Qt.Key_Escape && window.loginOpen) {
                AuthService.cancel();
                window.loginOpen = false;
                event.accepted = true;
                return;
            }

            if (!window.loginOpen) {
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
            onClicked: window.loginOpen = true
        }

        ExpressiveClock {
            id: clock

            readonly property real closedY: Math.round((scene.height - height) / 2 - 26)
            readonly property real openY: Math.max(52, scene.height * 0.10)

            baseSize: Math.max(150, Math.min(scene.width * 0.13, scene.height * 0.22))
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

        LoginSurface {
            id: loginSurface

            readonly property real targetY: Math.min(
                scene.height - height - 84,
                clock.y + clock.height + 34
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
            defaultUser: Config.defaultUser
            displayName: Config.displayName
            avatarSource: Config.avatarSource
            sessions: Config.sessions

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
