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
  mobile.hardware.ram = 1024 * 10;
  user.hostname = "fajita";
  hardware.opentabletdriver.enable = lib.mkForce false;
  system.stateVersion = "25.11";
  hardware.graphics.enable32Bit = lib.mkForce false;
  networking.networkmanager.wifi.macAddress = "stable";
  systemd.user.services.wvkbd = {
    description = "wvkbd";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = pkgs.writeShellScript "wvkbd-hidden" "${lib.getExe pkgs.wvkbd} --hidden";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
  programs.calls.enable = true;
  hardware.sensor.iio.enable = true;
  virtualisation.waydroid.enable = true;
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';
  users.users.wera.extraGroups = [ "feedbackd" ]; # TODO: ????

  zramSwap.enable = true;
}
