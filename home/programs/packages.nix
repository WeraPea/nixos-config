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
          cachix
          catimg
          cloc
          cmake
          fastfetch
          ffmpeg
          gdu
          gnumake
          imagemagick
          jq
          libxml2
          lm_sensors
          lsof
          mkvtoolnix-cli
          newsboat
          nextcloud-client
          nh
          nix-output-monitor
          onefetch
          outputs.packages.${pkgs.system}.yt-sub-converter
          picocom
          progress
          python3
          rsync
          sops
          sshfs
          tig
          tldr
          wget
          wl-clipboard
          wol
          xdg-utils
          yazi
          yt-dlp
        ]
        (lib.mkIf osConfig.graphics.enable [
          playerctl
          pwvucontrol
          tigervnc
          wayvnc
          xdragon
        ])
        (lib.mkIf osConfig.gaming.enable [
          alsa-oss
          bs-manager
          ckan
          inputs.osu-scrobbler.defaultPackage.${pkgs.system}
          lutris
          mangohud
          nvtopPackages.amd
          osu-lazer-bin
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
          obsidian
          openjdk17
          openscad
          orca-slicer
          outputs.packages.${pkgs.system}.blender
          prusa-slicer
          rofi-wayland # TODO: move to module
          scrcpy
          steam-run
          usbutils
          vesktop
        ])
      ];
  };
}
