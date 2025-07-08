{
  modulesPath,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    # Minimize the build to produce a smaller closure
    "${modulesPath}/profiles/minimal.nix"
    ./hyprland.nix
  ];
  # programs.hyprland = {
  #   # no aarch64-linux in hyprland cachix :(
  #   package = lib.mkForce pkgs.hyprland;
  #   portalPackage = lib.mkForce pkgs.xdg-desktop-portal-hyprland;
  # };
  mobile.hardware.ram = 1024 * 10;
  user.hostname = "fajita";
  hardware.opentabletdriver.enable = lib.mkForce false;
  system.stateVersion = "25.11";
  hardware.graphics.enable32Bit = lib.mkForce false;
  networking.networkmanager.wifi.macAddress = "stable";

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';
  users.users.wera.extraGroups = [ "feedbackd" ]; # TODO: ????

  zramSwap.enable = true;
}
