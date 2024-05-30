{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      systemd-boot.graceful = true; # fix for refind
    };
    supportedFilesystems = [ "ntfs" ];
  };
}
