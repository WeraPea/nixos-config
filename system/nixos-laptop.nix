{
  imports = [
    ./boot.nix
    ./jack-detection.nix
  ];
  user.hostname = "nixos-laptop";
  system.stateVersion = "23.11";
}
