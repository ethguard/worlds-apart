import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "."

PanelWindow {
    id: root
    property bool open: false
    property var entries: []
    property var targetScreen: null
    screen: targetScreen
    visible: open
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "teigu-shortcut-guide"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    readonly property var filtered: entries.filter(e =>
        (e.keys + " " + e.action + " " + e.section).toLowerCase().includes(search.text.toLowerCase()))

    function close() { open = false }
    function toggle() {
        if (open) { close(); return }
        const monitor = Hyprland.focusedMonitor
        targetScreen = monitor ? (Quickshell.screens.find(s => s.name === monitor.name) ?? null) : null
        search.text = ""
        scan.running = true
        open = true
        list.positionViewAtBeginning()
        Qt.callLater(() => search.forceActiveFocus())
    }
    Process {
        id: scan
        command: ["python3", Quickshell.env("HOME") + "/.config/world80-gallery/shortcuts.py"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.entries = JSON.parse(text) } catch (e) { console.warn("Shortcut guide:", e) }
            }
        }
    }
    IpcHandler {
        target: "shortcutGuide"
        function toggle(): void { root.toggle() }
        function close(): void { root.close() }
    }

    Rectangle { anchors.fill: parent; color: "#99000000" }
    MouseArea { anchors.fill: parent; onClicked: root.close() }
    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(1080, root.width - 64)
        height: Math.min(880, root.height - 96)
        radius: 24
        color: ThemeConfig.glass
        border.width: 1
        border.color: Qt.alpha(Theme.accent, 0.6)
        MouseArea { anchors.fill: parent; onClicked: {} }
        Text {
            id: title
            x: 32; y: 28
            text: "Keyboard shortcuts"
            font.family: Theme.mono
            font.pixelSize: 27
            font.weight: Font.Medium
            color: Theme.textBright
        }
        Text {
            x: 32; y: 66
            text: "Super is your Windows key  ·  " + root.entries.length + " shortcuts and controls"
            font.family: Theme.mono
            font.pixelSize: 12
            color: Theme.textSecondary
        }
        Rectangle {
            x: parent.width - 72; y: 28
            width: 40; height: 40; radius: 12
            color: closeMouse.containsMouse ? Qt.alpha(Theme.accent, 0.2) : Qt.alpha(Theme.textBright, 0.05)
            Text { anchors.centerIn: parent; text: "×"; font.pixelSize: 25; color: Theme.textBright }
            MouseArea { id: closeMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.close() }
        }
        Rectangle {
            id: searchBox
            x: 32; y: 104; width: parent.width - 64; height: 52; radius: 13
            color: Qt.alpha(Theme.textBright, 0.06)
            border.width: 1
            border.color: search.activeFocus ? Theme.accent : Theme.glassBorder
            Text {
                x: 16; anchors.verticalCenter: parent.verticalCenter
                visible: search.text.length === 0
                text: "Search keys, actions, or sections…"
                font.family: Theme.mono; font.pixelSize: 14
                color: Theme.textMuted
            }
            TextInput {
                id: search
                anchors.fill: parent; anchors.margins: 16
                verticalAlignment: TextInput.AlignVCenter
                font.family: Theme.mono; font.pixelSize: 14
                color: Theme.textBright; selectionColor: Theme.accent
                clip: true
                Keys.onEscapePressed: root.close()
                Keys.onDownPressed: list.flick(0, -550)
                Keys.onUpPressed: list.flick(0, 550)
            }
        }
        ListView {
            id: list
            x: 32; y: 176; width: parent.width - 64; height: parent.height - y - 54
            clip: true
            model: root.filtered
            spacing: 4
            boundsBehavior: Flickable.StopAtBounds
            section.property: "section"
            section.delegate: Text {
                required property string section
                width: list.width; height: 46
                text: section.toUpperCase()
                font.family: Theme.mono; font.pixelSize: 11; font.letterSpacing: 1.5
                font.weight: Font.Bold; color: Theme.accent
                verticalAlignment: Text.AlignVCenter
            }
            delegate: Rectangle {
                id: shortcutRow
                required property var modelData
                required property int index
                width: list.width - 14
                height: Math.max(48, description.implicitHeight + 20, keyText.implicitHeight + 20)
                radius: 10
                color: index % 2 === 0 ? Qt.alpha(Theme.textBright, 0.035) : "transparent"
                Rectangle {
                    x: 10; anchors.verticalCenter: parent.verticalCenter
                    width: 300; height: keyText.implicitHeight + 14; radius: 8
                    color: Qt.alpha(Theme.accent, 0.1)
                    Text {
                        id: keyText
                        x: 12; y: 7; width: parent.width - 24
                        text: shortcutRow.modelData.keys
                        wrapMode: Text.WordWrap
                        font.family: Theme.mono; font.pixelSize: 12; font.weight: Font.Medium
                        color: Theme.accent
                    }
                }
                Text {
                    id: description
                    x: 328; anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - x - 14
                    text: shortcutRow.modelData.action
                    wrapMode: Text.WordWrap
                    font.family: Theme.mono; font.pixelSize: 13
                    color: Theme.textPrimary
                }
            }
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
        }
        Text {
            anchors.centerIn: list
            visible: root.filtered.length === 0
            text: scan.running ? "Reading your shortcuts…" : "No matching shortcuts"
            font.family: Theme.mono; font.pixelSize: 14; color: Theme.textMuted
        }
        Text {
            x: 32; anchors.bottom: parent.bottom; anchors.bottomMargin: 20
            text: "Type to filter  ·  Scroll to browse  ·  Esc or Super + / to close"
            font.family: Theme.mono; font.pixelSize: 11; color: Theme.textMuted
        }
    }
}
