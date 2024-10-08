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
      extraConfig.pipewire = {
        "10-clock-rate" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
          };
        };
      };
    };
    udev.packages = with pkgs; [
      android-udev-rules
      platformio-core.udev
    ];
    vnstat.enable = true;
    protonvpn = {
      enable = true;
      autostart = false;
      interface.privateKeyFile = "/etc/protonvpn";
      endpoint = {
        publicKey = "agoivyLoPqor8MxA/s6UWJSMcA2pMl+ajO3vy/q3oWQ=";
        ip = "103.125.235.18";
        port = 51820;
      };
    };
  };
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
      # pkgs.xdg-desktop-portal-kde
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
      # pkgs.xdg-desktop-portal-kde
    ];
  };
  hardware = {
    bluetooth.enable = true;
    keyboard.qmk.enable = true;
    xpadneo.enable = true;
  };
}
