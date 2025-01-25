{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    # amdgpu fixing black screen thingy
    "amdgpu.noretry=0"
    "amdgpu.lockup_timeout=1000"
    "amdgpu.gpu_recovery=1"
    "iommu=soft"
    "pcie_aspm=off"
  ];
  networking.interfaces.enp10s0.wakeOnLan.enable = true;
  hardware.amdgpu.amdvlk = {
    enable = true;
    support32Bit.enable = true;
  };
  hardware.amdgpu.opencl.enable = true;
  environment.variables.AMD_VULKAN_ICD = "RADV";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/8cf4f902-7e83-4c3d-86af-5424e65e4103";
      fsType = "xfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/80D8-0B06";
      fsType = "vfat";
    };
    "/mnt/2tb-mnt".label = "Linux\\x20Data";
    "/mnt/win" = {
      label = "Windows";
      options = [
        "rw"
        "uid=1000"
      ];
    };
    "/mnt/mnt2" = {
      label = "Windows\\x20Data";
      options = [
        "rw"
        "uid=1000"
      ];
    };
  };

  zramSwap.enable = true;

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
