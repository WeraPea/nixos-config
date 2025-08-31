{
  lib,
  pkgs,
  outputs,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./hyprland.nix
  ];
  programs.hyprland = {
    # no aarch64-linux in hyprland cachix :(
    package = lib.mkForce pkgs.hyprland;
    portalPackage = lib.mkForce pkgs.xdg-desktop-portal-hyprland;
  };
  user.hostname = "pinenote";
  pinenote.config.enable = true;
  pinenote.pinenote-service.hyprland.enable = true;
  pinenote.pinenote-service.package =
    if config.buildSystem != "aarch64-linux" then
      inputs.pinenote-service.packages.${config.buildSystem}.cross
    else
      inputs.pinenote-service.packages.${pkgs.system}.default;
  hardware.graphics.enable32Bit = lib.mkForce false;
  hardware.opentabletdriver.enable = lib.mkForce false;
  system.stateVersion = "25.05";
  fileSystems."/" = {
    label = "nixos";
    fsType = "ext4";
  };
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandlePowerKeyLongPress = "poweroff";
  };

  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = lib.getExe outputs.packages.${pkgs.system}.usb-tablet;
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];

  systemd.services.dummy-mouse = {
    description = "dummy-mouse";
    wantedBy = [ "multi-user.target" ];
    wants = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = (
        pkgs.writers.writePython3 "dummy-mouse" { libraries = [ pkgs.python3Packages.evdev ]; } ''
          from evdev import UInput, ecodes as e
          import time

          capabilities = {
              e.EV_KEY: [e.BTN_LEFT, e.BTN_RIGHT],
              e.EV_REL: [e.REL_X, e.REL_Y],
          }

          with UInput(capabilities, name="dummy-mouse", version=0x3) as ui:
              while True:
                  time.sleep(1)
        ''
      );
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  }; # workaround: hyprland does not recognize stylus touch as clicks without it

  services.journald.storage = "volatile";
  # zramSwap.enable = true;
  stylix = lib.mkForce {
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/grayscale-light.yaml";
    base16Scheme = {
      scheme = "eink-light";
      base00 = "#ffffff";
      base01 = "#e3e3e3";
      base02 = "#b9b9b9";
      base03 = "#ababab";
      base04 = "#525252";
      base05 = "#464646";
      base06 = "#252525";
      base07 = "#000000";
      base08 = "#7c7c7c";
      base09 = "#999999";
      base0A = "#a0a0a0";
      base0B = "#8e8e8e";
      base0C = "#868686";
      base0D = "#686868";
      base0E = "#747474";
      base0F = "#5e5e5e";
    };
  };
}
