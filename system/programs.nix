{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    gaming.enable = lib.mkEnableOption "Enables gaming programs";
  };

  config = {
    fonts = lib.mkIf config.graphics.enable {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
      ];
    };
    programs = lib.mkMerge [
      {
        adb.enable = true;
        dconf.enable = lib.mkIf config.graphics.enable true;
        fuse.userAllowOther = true;
        gnupg.agent = {
          enable = true;
          enableSSHSupport = true;
        };
        mtr.enable = true;
      }
      (lib.mkIf config.gaming.enable {
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
      })
    ];
    systemd.user.services.gamemoded = lib.mkIf config.gaming.enable {
      restartTriggers = [ pkgs.gamemode ];
      stopIfChanged = false;
    }; # fix for authentication prompts appearing after update
  };
}
