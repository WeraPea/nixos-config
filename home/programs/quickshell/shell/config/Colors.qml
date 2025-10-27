pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    // Assign Properties from the read in palette.json (stylix generated file)
    readonly property color base00: json.base00 ? `#${json.base00}` : "#121212"
    readonly property color base01: json.base01 ? `#${json.base01}` : "#303030"
    readonly property color base02: json.base02 ? `#${json.base02}` : "#505050"
    readonly property color base03: json.base03 ? `#${json.base03}` : "#707070"
    readonly property color base04: json.base04 ? `#${json.base04}` : "#909090"
    readonly property color base05: json.base05 ? `#${json.base05}` : "#c0c0c0"
    readonly property color base06: json.base06 ? `#${json.base06}` : "#e0e0e0"
    readonly property color base07: json.base07 ? `#${json.base07}` : "#f9f9f9"
    readonly property color base08: json.base08 ? `#${json.base08}` : "#fa2772"
    readonly property color base09: json.base09 ? `#${json.base09}` : "#fc9620"
    readonly property color base0A: json.base0A ? `#${json.base0A}` : "#d4c96e"
    readonly property color base0B: json.base0B ? `#${json.base0B}` : "#a7e22e"
    readonly property color base0C: json.base0C ? `#${json.base0C}` : "#56b7a5"
    readonly property color base0D: json.base0D ? `#${json.base0D}` : "#55bcce"
    readonly property color base0E: json.base0E ? `#${json.base0E}` : "#ae82ff"
    readonly property color base0F: json.base0F ? `#${json.base0F}` : "#cc6633"
    readonly property string author: json.author ? json.author : "untitled"
    readonly property string scheme: json.scheme ? json.scheme : "Molokai"
    readonly property string slug: json.slug ? json.slug : "untitled"

    property color background: base00
    property color foreground: base06
    property color foregroundSecondary: base02
    property color accent: base0C

    FileView {
        path: `${Quickshell.env("HOME")}/.config/stylix/palette.json`
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        JsonAdapter {
            id: json
            property string base00
            property string base01
            property string base02
            property string base03
            property string base04
            property string base05
            property string base06
            property string base07
            property string base08
            property string base09
            property string base0A
            property string base0B
            property string base0C
            property string base0D
            property string base0E
            property string base0F
            property string author
            property string scheme
            property string slug
        }
    }
}
