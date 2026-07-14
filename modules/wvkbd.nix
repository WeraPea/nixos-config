{
  inputs,
  ...
}:
let
  moduleName = "wvkbd";
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
      wvkbd-filter-activate = pkgs.writeShellScript "wvkbd-filter-activate" ''
        if [ "$1" = "activate" ]; then
          grep -Fxq "$(mmsg get all-monitors | ${lib.getExe pkgs.jq} -r 'monitors[] | select(.active) | .active_client.appid')" ~/.config/wvkbd/blacklist && exit
          ${lib.getExe wvkbd-state-set} 0
        elif [ "$1" = "deactivate" ]; then
          ${lib.getExe wvkbd-state-set} 1
        else
          echo "Usage: $0 [activate|deactivate]"
          exit 1
        fi
      '';
      wvkbd-state-set = pkgs.writeShellScriptBin "wvkbd-state-set" ''
         read rate delay < ~/.config/wvkbd/repeat_info
         if [ "$#" != 1 ]; then
          active=$(cat /tmp/wvkbd-active || tee 1 /tmp/wvkbd-active)
        else
          active="$1"
        fi
        if [ "$active" = 0 ]; then
          pkill -SIGUSR2 -x ${pkgs.wvkbd.meta.mainProgram}
          mmsg dispatch setoption,repeat_rate,$rate
          mmsg dispatch setoption,repeat_delay,$delay
          echo 1 > /tmp/wvkbd-active
        else
          echo 0 > /tmp/wvkbd-active
          pkill -SIGUSR1 -x ${pkgs.wvkbd.meta.mainProgram}
          mmsg dispatch setoption,repeat_rate,${toString config.wrappers.mango.settings.repeat_rate}
          mmsg dispatch setoption,repeat_delay,${toString config.wrappers.mango.settings.repeat_delay}
        fi
      '';
      repeat_delay = if cfg.fake_repeat_delay then 1000 / cfg.repeat_rate else cfg.repeat_delay;
    in
    {
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = false;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
        blacklist = lib.mkOption {
          default = [ "KOReader" ];
          description = "List of client appids for which the virtual keyboard will not automatically show. Not used during deactivation.";
          type = lib.types.listOf lib.types.str;
        };
        auto.enable = lib.mkOption {
          default = true;
          type = lib.types.bool;
        };
        popups.enable = lib.mkOption {
          default = true;
          type = lib.types.bool;
        };
        repeat_rate = lib.mkOption {
          default = 10;
          type = lib.types.int;
        };
        repeat_delay = lib.mkOption {
          default = 500;
          type = lib.types.int;
        };
        fake_repeat_delay = lib.mkOption {
          default = true;
          type = lib.types.bool;
          description = "Uses wvkbd delay as if it was key repeat delay";
        };
      };
      config = {
        nixpkgs.overlays = [
          (final: prev: {
            werapi = prev.werapi or { } // {
              inherit wvkbd-state-set;
            };
          })
        ];
        hm = lib.mkIf cfg.enable {
          i18n.inputMethod = lib.mkIf cfg.auto.enable {
            enable = true;
            type = "fcitx5";
            fcitx5 = {
              addons = [
                (pkgs.callPackage "${inputs.fcitx-virtualkeyboard-adapter}/virtualkeyboard-adapter.nix" { }) # no aarch64-linux in flake
              ];
              settings.addons.virtualkeyboardadapter.globalSection = {
                ActivateCmd = ''"${wvkbd-filter-activate} activate"'';
                DeactivateCmd = ''"${wvkbd-filter-activate} deactivate"'';
              };
            };
          };
          xdg.configFile."wvkbd/blacklist".text = lib.concatStringsSep "\n" cfg.blacklist;
          xdg.configFile."wvkbd/repeat_info".text = lib.concatStringsSep " " (
            map toString [
              cfg.repeat_rate
              repeat_delay
            ]
          );
          systemd.user.services.wvkbd = {
            Unit = {
              Description = "wvkbd";
              Wants = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart =
                with config.lib.stylix.colors;
                pkgs.writeShellScript "wvkbd-hidden" (
                  ''
                    ${lib.getExe pkgs.wvkbd} --hidden \
                        --bg ${base00}\
                        --fg ${base02}\
                        --fg-sp ${base01}\
                        --press ${base03}\
                        --press-sp ${base03}\
                        --text ${base07}\
                        --text-sp ${base07}\
                        --fn "${config.stylix.fonts.sansSerif.name}"\
                        -R 0 -H 500 ''
                  + lib.optionalString (!cfg.popups.enable) "--hide-popups "
                  + lib.optionalString (cfg.fake_repeat_delay) "--long-press-ms ${toString cfg.repeat_delay} "
                );
              Restart = "on-failure";
              RestartSec = 1;
              TimeoutStopSec = 10;
            };
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
          };
        };
      };
    };
}
