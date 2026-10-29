pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    property var palette: ({})
    property FileView paletteFile: FileView {
        path: Quickshell.env("HOME") + "/.cache/wal/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try { root.palette = JSON.parse(text()) } catch (e) {}
        }
    }
    readonly property bool cyber: false
    readonly property color accent: palette.colors?.color4 ?? "#b7afa2"
    readonly property color accent2: palette.colors?.color6 ?? "#8eaaa7"
    readonly property color accent3: palette.colors?.color5 ?? "#b28d9d"
    readonly property color accentWarn: palette.colors?.color3 ?? "#d2ad72"
    readonly property color glass: palette.special?.background ?? "#171719"
    readonly property color text: palette.special?.foreground ?? "#dad9dc"
    readonly property string fontMono: "JetBrainsMono Nerd Font"
}
