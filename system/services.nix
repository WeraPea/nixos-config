{ pkgs, ... }:
{
  imports = [
    ./dual-function-keys.nix
    ./polkit.nix
  ];
  services = {
    ddccontrol.enable = true;
    fstrim.enable = true;
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "Hyprland";
          user = "wera";
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
    monado = {
      enable = true;
      defaultRuntime = true;
    };
  };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = false;
    keyboard.qmk.enable = true;
  };
  sound.enable = true;
}
