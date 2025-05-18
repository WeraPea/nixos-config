{ lib, config, ... }:
{
  user.hostname = "pinenote";
  pinenote.config.enable = true;
  pinenote.sway-dbus-integration.enable = true;
  hardware.graphics.enable32Bit = lib.mkForce false; # shouldnt be needed?
  system.stateVersion = "25.05";
  fileSystems."/" = {
    label = "nixos";
    fsType = "ext4";
  };
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = lib.mkForce {
        command = "sway";
        user = config.user.username;
      };
      default_session = initial_session;
    };
  };
}
