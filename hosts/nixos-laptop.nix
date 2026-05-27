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

    jackDetectionFix.enable = true;
    mango.mainDisplay = "eDP-1";
    packages.desktop.enable = true;
    quickshell.enable = true;
    streamlink.enable = true;
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  hm = {
    home.stateVersion = "23.11";
    wayland.windowManager.mango.settings.monitorrule =
      "name:eDP-1,x:0,y:0,width:1920,height:1080,refresh:60";
  };

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
}
