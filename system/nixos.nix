{ pkgs, ... }:
{
  gaming.enable = true;
  user.hostname = "nixos";
  sql.enable = true;
  services.ddccontrol.enable = true;
  networking.interfaces.enp10s0.wakeOnLan.enable = true;
  system.stateVersion = "23.11";
  hardware.graphics = {
    extraPackages = with pkgs; [
      amdvlk
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };
}
