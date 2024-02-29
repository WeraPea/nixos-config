{
  boot = {
    loader = {
      systemd-boot.enable = true; # TODO: change to grub
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = ["ntfs"];
  };
}
