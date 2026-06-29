let
  moduleName = "packages";
in
{
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
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
              picocom
              progress
              python3
              ripgrep
              ripgrep-all
              rsync
              sops
              sshfs
              tldr
              werapi.flake-source
              werapi.rename-torrents
              werapi.yt-sub-converter
              werapi.yuru
              wget
              wol
              yazi
              yt-dlp
            ])
            (lib.mkIf cfg.graphical.enable [
              anki
              playerctl
              pwvucontrol
              tigervnc
              wayvnc
              werapi.browserexport
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
              prismlauncher
              protonup-qt
              rpcs3
              ryubing
              steamtinkerlaunch
              werapi.launch-osu
              werapi.osu-scrobbler
              winetricks
              wineWow64Packages.stable
            ])
            (lib.mkIf cfg.desktop.enable [
              (pkgs.werapi.sony-headphones-client.overrideAttrs (old: {
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
              (pkgs.symlinkJoin {
                name = "krita-xcb";
                paths = [ krita ];
                nativeBuildInputs = [ makeWrapper ];
                postBuild = ''
                  wrapProgram $out/bin/krita --set QT_QPA_PLATFORM xcb
                '';
              }) # krita crashes under wayland when using eraser with opentabletdriver
              legcord
              mecab # for anki plugin
              ntfs3g
              openjdk17
              openscad
              orca-slicer
              prusa-slicer
              qmk
              rofi
              scrcpy
              steam-run
              usbutils
              werapi.anki-helper
              werapi.aria2dl
              werapi.nyaasi
              werapi.pinenote-vnc
              werapi.screenshot
              werapi.search
            ])
          ];
      };
    };
}
