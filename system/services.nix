{pkgs, ...}: {
  imports = [
    ./polkit.nix
    ./dual-function-keys.nix
  ];
  services = {
    xserver = {
      layout = "pl";
      autoRepeatDelay = 150;
      autoRepeatInterval = 300;
      videoDrivers = ["amdgpu"];
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    getty.autologinUser = "wera";
    openssh.enable = true;
    vnstat.enable = true;
    fstrim.enable = true;
    ddccontrol.enable = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
  hardware = {
    pulseaudio.enable = false;
    bluetooth.enable = true;
  };
  sound.enable = true;
}
