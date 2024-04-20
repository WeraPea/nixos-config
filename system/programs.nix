{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];
  };
  programs = {
    adb.enable = true;
    corectrl.enable = true;
    corectrl.gpuOverclock.enable = true;
    dconf.enable = true;
    droidcam.enable = true;
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
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    hyprland.enable = true;
    mtr.enable = true;
    steam = {
      extest.enable = true;
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };
  hardware.xpadneo.enable = true;
}
