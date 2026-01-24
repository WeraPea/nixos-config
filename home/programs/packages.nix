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
          fastfetch
          ffmpeg
          file
          gdu
          imagemagick
          jq
          lm_sensors
          lsof
          mkvtoolnix-cli
          newsboat
          nh
          nix-output-monitor
          onefetch
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.rename-torrents
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.yt-sub-converter
          picocom
          progress
          python3
          ripgrep
          ripgrep-all
          rsync
          sops
          sshfs
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
          dragon-drop
          outputs.packages.${pkgs.stdenv.hostPlatform.system}._0x0
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.aria2dl
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.browserexport
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.nyaasi
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.screenshot
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.search
          playerctl
          pwvucontrol
          tigervnc
          wayvnc
          wev
          wlr-randr
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
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.launch-osu
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.osu-scrobbler
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
          # freecad-wayland
          helvum
          krita
          mecab # for anki plugin
          nmap
          ntfs3g
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
