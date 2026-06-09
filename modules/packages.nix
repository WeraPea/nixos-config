{
  config,
  lib,
  outputs,
  pkgs,
  ...
}:
let
  moduleName = "packages";
  cfg = config.werapi.${moduleName};
  hmConfig = config.home-manager.users.${config.werapi.username};
in
{
  options.werapi.${moduleName} = {
    enable = lib.mkOption {
      default = config.werapi.defaultModules.enable;
      description = "Whether to enable ${moduleName} module.";
      type = lib.types.bool;
    };
    default.enable = lib.mkOption {
      default = config.werapi.defaultModules.enable;
      description = "Whether to enable default packages.";
      type = lib.types.bool;
    };
    graphical.enable = lib.mkOption {
      default = config.werapi.graphics.enable;
      description = "Whether to enable graphical packages.";
      type = lib.types.bool;
    };
    desktop.enable = lib.mkOption {
      default = false;
      description = "Whether to enable desktop packages.";
      type = lib.types.bool;
    };
    gaming.enable = lib.mkOption {
      default = false;
      description = "Whether to enable gaming packages.";
      type = lib.types.bool;
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      lib.mkMerge [
        (lib.mkIf cfg.default.enable [
          (_7zz.override { enableUnfree = true; })
          appimage-run
          bc
          catimg
          cloc
          dnsutils
          fastfetch
          ffmpeg
          file
          gallery-dl
          gdu
          imagemagick
          jq
          lm_sensors
          lsof
          mkvtoolnix-cli
          newsboat
          nh
          nix-output-monitor
          nmap
          onefetch
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.flake-source
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.rename-torrents
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.yt-sub-converter
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.yuru
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
          wol
          yazi
          yt-dlp
        ])
        (lib.mkIf cfg.graphical.enable [
          anki
          outputs.packages.${pkgs.stdenv.hostPlatform.system}._0x0
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.browserexport
          playerctl
          pwvucontrol
          tigervnc
          wayvnc
          wev
          wl-clipboard
          wlr-randr
          xdg-utils
        ])
        (lib.mkIf cfg.gaming.enable [
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
          wineWow64Packages.stable
        ])
        (lib.mkIf cfg.desktop.enable [
          (outputs.packages.${pkgs.stdenv.hostPlatform.system}.sony-headphones-client.overrideAttrs (old: {
            nativeBuildInputs = old.nativeBuildInputs ++ [ makeWrapper ];
            postInstall = ''
              wrapProgram $out/bin/SonyHeadphonesClient --set-default SONYHEADPHONESCLIENT_CONFIG_PATH ${hmConfig.home.homeDirectory}/.config/sony-headphones-client.toml
            ''; # have to touch it first - otherwise it assumes it is incorrect and uses default path
          }))
          android-tools
          chatterino7
          dragon-drop
          flatpak
          crosspipe
          krita
          legcord
          mecab # for anki plugin
          ntfs3g
          openjdk17
          openscad
          orca-slicer
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.anki-helper
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.aria2dl
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.nyaasi
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.screenshot
          outputs.packages.${pkgs.stdenv.hostPlatform.system}.search
          prusa-slicer
          qmk
          rofi
          scrcpy
          steam-run
          usbutils
        ])
      ];
  };
}
