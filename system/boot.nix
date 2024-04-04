{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true; # TODO: change to grub
    };
    supportedFilesystems = [ "ntfs" ];
  };
}
