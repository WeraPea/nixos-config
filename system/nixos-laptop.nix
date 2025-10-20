{
  imports = [
    ./boot.nix
    ./jack-detection.nix
    ./mango.nix
  ];
  roc = {
    enable = true;
    source = true;
    source-ip = "nixos-laptop";
  };
  user.hostname = "nixos-laptop";
  system.stateVersion = "23.11";
}
