{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  options = {
    spicetify.enable = lib.mkEnableOption "enables spicetify";
  };
  config =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    in
    lib.mkIf config.spicetify.enable {
      stylix.targets.spicetify.enable = false;
      programs.spicetify = {
        enable = true;
        windowManagerPatch = true;
        theme = spicePkgs.themes.default;
        colorScheme = "custom";
        customColorScheme = with config.lib.stylix.colors; {
          highlight = "${base03}";
          button = "${base0B}";
          button-active = "${base0B}";
          sidebar = "${base00}";
          main = "${base00}";
          text = "${base07}";
          notification = "${base0C}";
          notification-error = "${base08}";
        };

        enabledCustomApps = with spicePkgs.apps; [
          betterLibrary
          historyInSidebar
          localFiles
          lyricsPlus
        ];

        enabledExtensions = with spicePkgs.extensions; [
          adblock
          autoSkip
          beautifulLyrics
          betterGenres
          bookmark
          copyLyrics
          copyToClipboard
          fullAlbumDate
          fullAppDisplay
          hidePodcasts
          history
          keyboardShortcut
          listPlaylistsWithSong
          loopyLoop
          oldSidebar
          playlistIcons
          playlistIntersection
          popupLyrics
          savePlaylists
          seekSong
          shuffle
          skipStats
          volumePercentage
          wikify
        ];
      };
    };
}
