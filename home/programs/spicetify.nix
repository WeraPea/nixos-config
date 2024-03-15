{
  config,
  inputs,
  lib,
  pkgs,
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
      localFiles
      lyrics-plus
      new-releases
      reddit
    ];

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      autoSkip
      bookmark
      copyToClipboard
      fullAlbumDate
      fullAppDisplay
      hidePodcasts
      history
      keyboardShortcut
      loopyLoop
      playlistIcons
      savePlaylists
      seekSong
      shuffle
      skipStats
      volumePercentage
      # fullAppDisplayMod
      # genre # doesn't work??
    ];
  };
}
