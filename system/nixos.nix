{
  imports = [ ./boot.nix ];
  gaming.enable = true;
  user.hostname = "nixos";
  services.ddccontrol.enable = true;
  system.stateVersion = "23.11";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
