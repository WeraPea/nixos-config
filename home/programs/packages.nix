{
  pkgs,
  lib,
  config,
  osConfig,
  outputs,
  ...
}:
{
  options = {
    desktopPackages.enable = lib.mkEnableOption {
      description = "Desktop packages";
    };
  };
  config = {
    home.packages =
      with pkgs;
      lib.mkMerge [
        [
          (_7zz.override { enableUnfree = true; })
          appimage-run
          bc
          catimg
          comma
          ffmpeg
          gdu
          gnumake
          imagemagick
          jq
          libxml2
          lm_sensors
          lsof
          neofetch
          nh
          nixfmt-rfc-style
          onefetch
          picocom
          progress
          python3
          rsync
          tig
          tldr
          wget
          wl-clipboard
          wol
          xdg-utils
          yt-dlp
        ]
        (lib.mkIf osConfig.gaming.enable [
          alsa-oss
          lutris
          mangohud
          nvtopPackages.amd
          prismlauncher
          protontricks
          protonup-qt
          winetricks
          wineWowPackages.stagingFull
          # wineWowPackages.waylandFull
        ])
        (lib.mkIf config.desktopPackages.enable [
          android-tools
          chatterino2
          flatpak
          helvum
          krita
          ntfs3g
          openjdk17
          openscad
          orca-slicer
          outputs.packages.${pkgs.system}.blender
          pavucontrol
          playerctl
          prusa-slicer
          rofi-wayland # TODO: move to module
          ryujinx
          steam-run
          streamlink
          streamlink-twitch-gui-bin
          usbutils
          vesktop
          xdragon
        ])
      ];
  };
}
