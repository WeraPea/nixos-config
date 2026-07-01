{
  flake,
  inputs,
  lib,
  ...
}:
let
  moduleName = "_fajita";
in
{
  flake.nixosConfigurations.${lib.removePrefix "_" moduleName} = flake.lib.mkNixosConfig moduleName;
  flake.modules.${moduleName}.nixos =
    {
      modulesPath,
      pkgs,
      lib,
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
        mpd.enable = true;
        mpv.enable = false;
        quickshell.enable = true;
        wvkbd.enable = true;
      };

      wrappers.mango =
        { config, ... }:
        let
          inherit (config) mango-lib;
        in
        {
          mainDisplay = "DSI-1";
          defaultLayout = "scroller";
          bindModes.power = mango-lib.mkLongPressBind {
            name = "power";
            bind = "NONE,XF86PowerOff";
            enter.bind = "NONE,XF86PowerOff";
            longCommand = "spawn,"; # TODO: power menu
            shortCommand = {
              name = "lock";
              onEntry = "disable_monitor,DSI-1"; # watcher for mon turning on in other ways?
              binds.bind = {
                "NONE,XF86PowerOff" = mango-lib.mkLongPressBind {
                  recSubmodeOf = "lock";
                  name = "voldown";
                  bind = "NONE,XF86PowerOff";
                  shortCommand = [
                    "enable_monitor,DSI-1"
                    "setkeymode,default"
                  ];
                  longCommand = "spawn,mpc toggle";
                };
                "NONE,XF86AudioLowerVolume" = mango-lib.mkLongPressBind {
                  recSubmodeOf = "lock";
                  name = "voldown";
                  bind = "NONE,XF86AudioLowerVolume";
                  shortCommand = "spawn,${lib.getExe pkgs.pamixer} -d 1";
                  longCommand = "spawn,mpc prev";
                };
                "NONE,XF86AudioRaiseVolume" = mango-lib.mkLongPressBind {
                  recSubmodeOf = "lock";
                  name = "volup";
                  bind = "NONE,XF86AudioRaiseVolume";
                  shortCommand = "spawn,${lib.getExe pkgs.pamixer} -i 1";
                  longCommand = "spawn,mpc next";
                };
              };
            };
          };
          settings.monitorrule = "name:DSI-1,scale:1.5,x:0,y:0,width:1080,height:2340,refresh:60";
        };

      environment.systemPackages = with pkgs; [
        # chatty
        brightnessctl
        legcord
      ];

      hm = {
        home.stateVersion = "25.11";
        programs.zathura.enable = false;
      };

      stylix.fonts.monospace.package = lib.mkForce (
        if (config.werapi.buildSystem == "x86_64-linux") then
          pkgsX86_64.callPackage "${flake}/modules/pkgs/_pkgs/udev-gothic-hs-nf.nix" { }
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
    };
}
