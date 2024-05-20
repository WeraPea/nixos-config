{ pkgs, config, ... }:
{
  imports = [
    ./dual-function-keys.nix
    ./polkit.nix
    ./sql.nix
  ];
  services = {
    ddccontrol.enable = true;
    fstrim.enable = true;
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "Hyprland";
          user = config.user.username;
        };
        default_session = initial_session;
      };
    };
    openssh.enable = true;
    pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      enable = true;
      jack.enable = true;
      pulse.enable = true;
    };
    udev.packages = with pkgs; [
      android-udev-rules
      platformio-core
    ];
    vnstat.enable = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    configPackages = [ pkgs.xdg-desktop-portal-gtk ];
    xdgOpenUsePortal = true;
  };
  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = false;
    keyboard.qmk.enable = true;
  };
  sound.enable = true;
}
