{
  pkgs,
  lib,
  inputs,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
in {
  imports = [inputs.spicetify-nix.homeManagerModule];

  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.text;
    colorScheme = "Spotify";

    enabledCustomApps = with spicePkgs.apps; [
      new-releases
      lyrics-plus
      reddit
      localFiles
    ];

    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      shuffle
      hidePodcasts
      keyboardShortcut
      loopyLoop
      bookmark
      playlistIcons
      seekSong
      fullAlbumDate
      skipStats
      copyToClipboard
      history
      adblock
      savePlaylists
      autoSkip
      volumePercentage
      # fullAppDisplayMod
      # genre # doesn't work??
    ];
  };
}
