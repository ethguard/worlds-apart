// Standalone adapter for world80's muted video-wallpaper behavior.
import QtQuick
import QtMultimedia
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: root
    required property var modelData
    screen: modelData
    WlrLayershell.namespace: "world80-gallery-video"
    WlrLayershell.layer: WlrLayer.Bottom
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {}
    visible: videoPath !== ""
    property string videoPath: ""
    FileView {
        path: Quickshell.env("HOME") + "/.cache/teigu-rice/active-video"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.videoPath = text().trim()
    }
    readonly property var hyprMon: Hyprland.monitorFor(root.modelData)
    readonly property bool covered: Hyprland.toplevels.values.some(t =>
        t.wayland && t.wayland.fullscreen && t.monitor === root.hyprMon
        && t.workspace && t.workspace.active)
    readonly property bool shouldPlay: root.videoPath !== "" && !covered
    onShouldPlayChanged: shouldPlay ? player.play() : player.pause()
    MediaPlayer {
        id: player
        source: root.videoPath !== "" ? "file://" + root.videoPath.split("/").map(encodeURIComponent).join("/") : ""
        videoOutput: output
        loops: MediaPlayer.Infinite
        onSourceChanged: if (root.shouldPlay) play()
        onErrorOccurred: (error, message) => console.warn("Video wallpaper:", message)
    }
    VideoOutput {
        id: output
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
    }
}
