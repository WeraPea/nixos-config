{
  modulesPath,
  pkgs,
  lib,
  inputs,
  outputs,
  config,
  ...
}:
let
  pkgsX86_64 = import inputs.nixpkgs {
    system = "x86_64-linux";
  };
in
{
  imports = [
    # Minimize the build to produce a smaller closure
    "${modulesPath}/profiles/minimal.nix"
    ./mango.nix
    ./fajita-cross.nix
  ];
  mobile.hardware.ram = 1024 * 10;
  mobile.boot.boot-control.enable = false;
  user.hostname = "fajita";
  hardware.opentabletdriver.enable = lib.mkForce false;
  system.stateVersion = "25.11";
  networking.networkmanager.wifi.macAddress = "stable";
  # programs.calls.enable = true;
  hardware.sensor.iio.enable = true;
  virtualisation.waydroid.enable = true;
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  stylix.fonts.monospace.package = lib.mkForce (
    if (config.buildSystem == "x86_64-linux") then
      pkgsX86_64.callPackage ../pkgs/udev-gothic-hs-nf.nix { }
    else
      outputs.packages.${pkgs.stdenv.hostPlatform.system}.udev-gothic-hs-nf
  );

  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
  };
  users.users.wera.extraGroups = [
    "feedbackd"
    "plugdev"
    "audio"
  ]; # TODO: ????

  zramSwap.enable = true;
}
