{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
in {
  imports = [inputs.spicetify-nix.homeManagerModule];

  home.packages = [
    (pkgs.writeShellScriptBin "spotify" ''
      export -n NIXOS_OZONE_WL
      ${config.programs.spicetify.spicedSpotify}/bin/spotify
    '')
  ];

  programs.spicetify = {
    enable = true;
    dontInstall = true;
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
