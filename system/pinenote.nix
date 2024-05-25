{ lib, ... }:
{
  user.hostname = "pinenote";
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  hardware.opengl.driSupport32Bit = lib.mkForce false;
}
