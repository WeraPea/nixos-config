{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  outputs,
  ...
}:
{
  options = {
    desktopPackages.enable = lib.mkEnableOption {
      description = "Desktop packages";
      default = true;
    };
  };
  config = {
    home.packages =
      with pkgs;
      lib.mkMerge [
        ([
          appimage-run
          catimg
          comma
          gdu
          gnumake
          imagemagick
          jq
          krita
          libxml2
          lm_sensors
          lsof
          neofetch
          nh
          nixfmt-rfc-style
          onefetch
          openjdk17
          p7zip
          pavucontrol
          playerctl
          progress
          python3
          rofi-wayland # TODO: move to module
          rsync
          tldr
          wget
          wl-clipboard
          wol
          xdg-utils
          xdragon
          yt-dlp
        ])
        (lib.mkIf osConfig.gaming.enable [
          alsa-oss
          lutris
          mangohud
          prismlauncher
          protontricks
          protonup-qt
          winetricks
          wineWowPackages.stagingFull
          # wineWowPackages.waylandFull
        ])
        (lib.mkIf config.desktopPackages.enable [
          chatterino2
          flatpak
          helvum
          ntfs3g
          openscad
          orca-slicer
          outputs.packages.${pkgs.system}.blender
          prusa-slicer
          ryujinx
          steam-run
          streamlink
          streamlink-twitch-gui-bin
          usbutils
          vesktop
        ])
      ];
  };
}
