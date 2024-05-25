{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./dual-function-keys.nix
    ./polkit.nix
    ./sql.nix
  ];
  services = {
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
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-kde
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-kde
    ];
  };
  hardware = {
    bluetooth.enable = true;
    keyboard.qmk.enable = true;
    xpadneo.enable = true;
  };
  sound.enable = true;
}
