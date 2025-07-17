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
    "iommu=soft" # smth amd
    # "pcie_aspm=off" # this both/only for nvme and amd? just nvme ??, nvme wise did not fix it
    # "nvme_core.default_ps_max_latency_us=0" # kingstone A2000 maybe workaround, 2025-01-30 applied, check journal, did not fix it
    # "pcie_port_pm=off" # ssd kingstone A2000 workaround?, did not fix it # updated the firmware to S5Z42109 on 2025-05-25, check journal # did not fix it either
  ];
  networking.interfaces.enp10s0.wakeOnLan.enable = true;
  hardware.amdgpu.initrd.enable = true;
  hardware.amdgpu.amdvlk = {
    enable = true;
    support32Bit.enable = true;
  };
  hardware.amdgpu.opencl.enable = true;
  environment.variables.AMD_VULKAN_ICD = "RADV";

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/383C-A45C";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-uuid/14a0ea77-23dc-46aa-9565-a520bb458c5d";
      fsType = "btrfs";
      options = [
        "subvol=root"
        "compress=zstd"
      ];
    };
    "/home" = {
      device = "/dev/disk/by-uuid/14a0ea77-23dc-46aa-9565-a520bb458c5d";
      fsType = "btrfs";
      options = [
        "subvol=home"
        "compress=zstd"
      ];
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/14a0ea77-23dc-46aa-9565-a520bb458c5d";
      fsType = "btrfs";
      options = [
        "subvol=nix"
        "compress=zstd"
        "noatime"
      ];
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
