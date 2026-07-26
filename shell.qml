//@ pragma ShellId lumina-greeter
//@ pragma AppId io.github.maylton.lumina.greeter
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
