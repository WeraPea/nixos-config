{
  imports = [
    ./boot.nix
    ./jack-detection.nix
    ./mango.nix
  ];
  user.hostname = "nixos-laptop";
  system.stateVersion = "23.11";
}
