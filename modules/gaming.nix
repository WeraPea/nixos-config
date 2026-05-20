{
  config,
  lib,
  pkgs,
  ...
}:
let
  moduleName = "gaming";
  cfg = config.werapi.${moduleName};
in
{
  options.werapi.${moduleName} = {
    enable = lib.mkOption {
      default = false;
      description = "Whether to enable ${moduleName}.";
      type = lib.types.bool;
    };
  };
  config = lib.mkIf cfg.enable {
    users.users.${config.werapi.username}.extraGroups = [
      "gamemode"
    ];

    programs = {
      corectrl.enable = true;
      gamescope.enable = true;
      gamemode = {
        enable = true;
        settings = {
          general = {
            renice = 10;
          };
          gpu = {
            apply_gpu_optimisations = "accept-responsibility";
            gpu_device = 0;
            amd_performance_level = "high";
          };
        };
      };
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        protontricks.enable = true;
        extraPackages = with pkgs; [
          # for steamtinkerlaunch
          unzip
          xdotool
          xprop
          xrandr
          xwininfo
          xxd
          yad
        ];
      };
    };

    systemd.user.services.gamemoded = {
      restartTriggers = [ pkgs.gamemode ];
      stopIfChanged = false;
    }; # fix for authentication prompts appearing after update
  };
}
