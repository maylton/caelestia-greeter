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
    property string clockLayout: Config.clockLayout
    property real loginSpatial: loginOpen ? 1 : 0
    property real loginEffects: loginOpen ? 1 : 0

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

    Item {
        id: scene

        property real backgroundProgress: 0
        property real spatialProgress: 0
        property real effectProgress: 0

        anchors.fill: parent
        focus: window.interactiveScreen

        Keys.onPressed: event => {
            if (!window.interactiveScreen)
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
                type: Motion.fastSpatial
            }

            SequentialAnimation {
                PauseAnimation { duration: 60 }

                Anim {
                    target: scene
                    property: "effectProgress"
                    from: 0
                    to: 1
                    type: Motion.defaultEffects
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
            scale: 1.035 - scene.spatialProgress * 0.035
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
            enabled: window.interactiveScreen && !window.loginOpen
            cursorShape: Qt.PointingHandCursor
            onClicked: window.loginOpen = true
        }

        ExpressiveClock {
            id: clock

            readonly property real closedY: Math.round((scene.height - height) / 2 - 26)
            readonly property real openY: Math.max(52, scene.height * 0.10)

            layoutMode: window.clockLayout
            baseSize: Math.max(112, Math.min(scene.width * 0.16, scene.height * 0.25))
            x: Math.round((scene.width - width) / 2)
            y: closedY + (openY - closedY) * window.loginSpatial
            opacity: scene.effectProgress
            scale: (0.78 + scene.spatialProgress * 0.22)
                * (1 - window.loginSpatial * 0.02)
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
            y: targetY + (1 - window.loginSpatial) * 28
            opacity: scene.effectProgress * window.loginEffects
            scale: 0.92 + scene.spatialProgress * window.loginSpatial * 0.08
            enabled: window.loginOpen
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
            anchors.bottomMargin: 48 - (1 - window.loginSpatial) * 4
            text: I18n.t("idle.prompt")
            color: Theme.colorTextMuted
            font.family: Theme.fontBody
            font.pixelSize: 14
            font.weight: Font.Medium
            opacity: scene.effectProgress * (1 - window.loginEffects)
            scale: 0.96 + (1 - window.loginSpatial) * 0.04
        }

        Row {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 24
            spacing: 10
            visible: window.interactiveScreen
            opacity: scene.effectProgress
            transform: Translate {
                y: (1 - scene.spatialProgress) * 16
            }

            ActionChip {
                text: window.clockLayout === "stacked"
                    ? I18n.t("clock.stacked")
                    : I18n.t("clock.horizontal")
                selected: true
                onClicked: window.clockLayout = window.clockLayout === "stacked"
                    ? "horizontal"
                    : "stacked"
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
            opacity: scene.effectProgress
            scale: 0.9 + scene.spatialProgress * 0.1

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
