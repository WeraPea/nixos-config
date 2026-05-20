{
  config,
  lib,
  ...
}:
{
  imports = [ ./_router.nix ];

  werapi = {
    hostname = "server";
    domain = "werapi.duckdns.org";
    defaultModules.enable = true;
    graphics.enable = false;

    caddy.enable = true;
    linkwarden.enable = true;
    vaultwarden.enable = true;
    yomitan-ultimate-audio.enable = true;
  };

  services.openssh.settings.PasswordAuthentication = false;
  services.tailscale = {
    useRoutingFeatures = "server";
    extraSetFlags = [
      "--advertise-routes=192.168.1.0/24"
      "--advertise-exit-node"
    ];
  };
  # ps2 samba server
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        # settings mostly from https://github.com/toolboc/psx-pi-smbshare
        "server min protocol" = "NT1";
        "server signing" = "disabled";
        "smb encrypt" = "disabled";
        "map to guest" = "bad user";
        "usershare allow guests" = "yes";
        "keepalive" = 0;
        "strict sync" = "no";
      };
      ps2 = {
        comment = "PS2 SMB";
        path = "/ps2samba";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        public = "yes";
        available = "yes";
        "force user" = config.werapi.username;
      };
    };
  };

  system.stateVersion = "24.11";
  hm.home.stateVersion = "23.11"; # ???
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    kernelParams = [
      # amdgpu fixing black screen thingy
      "amdgpu.noretry=0"
      "amdgpu.lockup_timeout=1000"
      "amdgpu.gpu_recovery=1"
      "iommu=soft"
      "pcie_aspm=off"
    ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/ccf2cb5f-ac3f-43ae-89a4-7301b32be0a2";
      fsType = "xfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/12CE-A600";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };
}
