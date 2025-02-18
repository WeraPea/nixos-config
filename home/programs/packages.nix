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
          cloc
          cmake
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
          rpcs3
          ryujinx
          steamtinkerlaunch
          winetricks
          wineWowPackages.stagingFull
        ])
        (lib.mkIf config.desktopPackages.enable [
          android-tools
          anki
          chatterino7
          flatpak
          freecad-wayland
          helvum
          krita
          nmap
          ntfs3g
          openjdk17
          openscad
          orca-slicer
          outputs.packages.${pkgs.system}.blender
          pavucontrol
          playerctl
          prusa-slicer
          rofi-wayland # TODO: move to module
          scrcpy
          steam-run
          usbutils
          vesktop
          xdragon
        ])
      ];
  };
}
