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
          lm_sensors
          lsof
          neofetch
          nh
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
          xdg-utils
          xdragon
          yt-dlp
          libxml2
          nixfmt-rfc-style
          valent
        ])
        (lib.mkIf osConfig.gaming.enable [
          lutris
          prismlauncher
          alsa-oss
          protontricks
          protonup-qt
          winetricks
          wineWowPackages.stagingFull
          # wineWowPackages.waylandFull
        ])
        (lib.mkIf config.desktopPackages.enable [
          openscad
          steam-run
          helvum
          ntfs3g
          usbutils
          vesktop
          outputs.packages.${pkgs.system}.blender
        ])
      ];
  };
}
