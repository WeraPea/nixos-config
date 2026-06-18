{
  modulesPath,
  pkgs,
  lib,
  inputs,
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
    (import "${inputs.mobile-nixos}/lib/configuration.nix" { device = "oneplus-fajita"; })
    # Minimize the build to produce a smaller closure
    "${modulesPath}/profiles/minimal.nix"
    ./_fajita-cross.nix
  ];
  nixpkgs.hostPlatform = "aarch64-linux";
  werapi = {
    hostname = "fajita";
    defaultModules.enable = true;

    firefox = {
      mobile.enable = true;
      minimal.enable = true;
    };
    koreader.enable = true;
    mango = {
      mainDisplay = "DSI-1";
      defaultLayout = "scroller";
      bindModes.default.binds.bind = {
        "NONE,XF86PowerOff" = ''spawn,${lib.getExe pkgs.wlopm} --toggle "*"'';
      };
    };
    mpv.enable = false;
    quickshell.enable = true;
    wvkbd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # chatty
    brightnessctl
    legcord
  ];

  hm = {
    home.stateVersion = "25.11";
    programs.zathura.enable = false;
    wayland.windowManager.mango.settings.monitorrule =
      "name:DSI-1,scale:1.5,x:0,y:0,width:1080,height:2340,refresh:60";
  };

  stylix.fonts.monospace.package = lib.mkForce (
    if (config.werapi.buildSystem == "x86_64-linux") then
      pkgsX86_64.callPackage ../pkgs/udev-gothic-hs-nf.nix { }
    else
      pkgs.werapi.udev-gothic-hs-nf
  );

  # programs.calls.enable = true;

  services.udev.packages = [
    (pkgs.writeTextDir "lib/udev/rules.d/83-backlight.rules" ''
      SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
    '')
  ];
  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
  };

  networking.networkmanager.wifi.macAddress = "stable";

  virtualisation.waydroid.enable = true;
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  users.users.${config.werapi.username}.extraGroups = [
    "feedbackd"
    "plugdev"
    "audio"
  ]; # TODO: ????

  hardware.opentabletdriver.enable = lib.mkForce false;
  hardware.sensor.iio.enable = true;

  system.stateVersion = "25.11";
}
