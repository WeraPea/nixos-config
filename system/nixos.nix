{
  imports = [
    ./boot.nix
    ./hyprland.nix
  ];
  roc = {
    enable = true;
    sink = true;
    source-ip = "nixos-laptop";
  };
  gaming.enable = true;
  user.hostname = "nixos";
  services.ddccontrol.enable = true;
  system.stateVersion = "23.11";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware.amdgpu.overdrive.enable = true;
  hardware.amdgpu.overdrive.ppfeaturemask = "0xffffffff";
}
