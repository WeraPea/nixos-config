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
          file
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
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.yt-sub-converter
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
          (outputs.packages.${pkgs.stdenv.hostPlatform.system}.sony-headphones-client.overrideAttrs (old: {
            nativeBuildInputs = old.nativeBuildInputs ++ [ makeWrapper ];
            postInstall = ''
              wrapProgram $out/bin/SonyHeadphonesClient --set-default SONYHEADPHONESCLIENT_CONFIG_PATH ${config.home.homeDirectory}/.config/sony-headphones-client.toml
            ''; # have to touch it first - otherwise it assumes it is incorrect and uses default path
          }))
          playerctl
          pwvucontrol
          tigervnc
          wayvnc
          dragon-drop
        ])
        (lib.mkIf osConfig.gaming.enable [
          alsa-oss
          bs-manager
          ckan
          # kaon # broken?
          lutris
          mangohud
          nvtopPackages.amd
          osu-lazer-bin
          osu-scrobbler
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.launch-osu
          prismlauncher
          protonup-qt
          rpcs3
          ryubing
          steamtinkerlaunch
          winetricks
          wineWowPackages.stable
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
          # outputs.packages.${pkgs.stdenv.hostPlatform.system}.blender
          prusa-slicer
          qmk
          rofi
          scrcpy
          steam-run
          usbutils
          vesktop
        ])
      ];
  };
}
