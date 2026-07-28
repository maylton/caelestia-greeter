//@ pragma ShellId caelestia-greeter
//@ pragma AppId io.github.maylton.caelestia.greeter
//@ pragma DropExpensiveFonts

import Quickshell
import QtQuick
import "components"

ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: Component {
            GreeterScreen {}
        }
    }
}
