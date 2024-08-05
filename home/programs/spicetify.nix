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
      programs.spicetify = {
        enable = true;
        windowManagerPatch = true;
        theme = spicePkgs.themes.text;
        colorScheme = "Spotify";

        enabledCustomApps = with spicePkgs.apps; [
          betterLibrary
          historyInSidebar
          localFiles
          lyricsPlus
          newReleases
          reddit
        ];

        enabledExtensions = with spicePkgs.extensions; [
          adblock
          autoSkip
          beautifulLyrics
          betterGenres
          bookmark
          copyToClipboard
          featureShuffle
          fullAlbumDate
          fullAppDisplay
          groupSession
          hidePodcasts
          history
          keyboardShortcut
          listPlaylistsWithSong
          loopyLoop
          playlistIcons
          playlistIntersection
          popupLyrics
          powerBar
          savePlaylists
          seekSong
          seekSong
          shuffle
          skipStats
          volumePercentage
          wikify
        ];
      };
    };
}
