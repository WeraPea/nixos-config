{
  pkgs,
  config,
  inputs,
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
        noto-fonts-cjk
        noto-fonts-emoji
      ];
    };
    programs =
      {
        adb.enable = true;
        dconf.enable = lib.mkIf config.graphics.enable true;
        gnupg.agent = {
          enable = true;
          enableSSHSupport = true;
        };
        hyprland = lib.mkIf config.graphics.enable {
          enable = true;
          package = inputs.hyprland.packages.${pkgs.system}.default;
          portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
        };
        mtr.enable = true;
      }
      // lib.mkIf config.gaming.enable {
        corectrl.enable = true;
        corectrl.gpuOverclock.enable = true;
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
          extest.enable = true;
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };
      };
    hardware.xpadneo.enable = lib.mkIf config.gaming.enable true;
  };
}
