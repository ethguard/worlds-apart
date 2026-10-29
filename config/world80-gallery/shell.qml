import QtQuick
import Quickshell

ShellRoot {
    ThemeSwitcher {}
    ShortcutGuide {}
    Variants {
        model: Quickshell.screens
        VideoWall {}
    }
}
