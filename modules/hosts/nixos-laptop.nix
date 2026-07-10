{
  flake,
  lib,
  ...
}:
let
  moduleName = "_nixos-laptop";
in
{
  flake.nixosConfigurations.${lib.removePrefix "_" moduleName} = flake.lib.mkNixosConfig moduleName;
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      werapi = {
        hostname = "nixos-laptop";
        defaultModules.enable = true;

        jack-detection-fix.enable = true;
        packages.desktop.enable = true;
        quickshell.enable = true;
        streamlink.enable = true;
      };

      environment.systemPackages = with pkgs; [
        brightnessctl
      ];

      wrappers.mango = {
        mainDisplay = "eDP-1";
        settings = {
          monitorrule = "name:eDP-1,x:0,y:0,width:1920,height:1080,refresh:60";
          middle_button_emulation = 1;
        };
      };

      hm.home.stateVersion = "23.11";
      system.stateVersion = "23.11";
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      boot = {
        initrd.availableKernelModules = [
          "ahci"
          "ehci_pci"
          "sdhci_pci"
          "sd_mod"
          "usbhid"
          "usb_storage"
          "xhci_pci"
        ];
        initrd.kernelModules = [ ];
        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];
      };

      hardware = {
        enableRedistributableFirmware = true;
        cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-uuid/e99664dc-a15a-463a-bda1-cfd904726b9c";
          fsType = "xfs";
        };
        "/boot" = {
          device = "/dev/disk/by-uuid/F96D-2B11";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };
      };

      swapDevices = [ { device = "/dev/disk/by-uuid/6a676cc9-325d-4347-b13a-42838a3cc2b6"; } ];
    };
}
