{
  boot = {
    loader = {
      systemd-boot.enable = true; # TODO: change to grub
      efi.canTouchEfiVariables = true;
    };
    initrd.kernelModules = ["amdgpu"];
    supportedFilesystems = ["ntfs"];
  };
}
