{
  inputs,
  pkgs,
  ...
}:
{
  home-manager = {
    sharedModules = [
      inputs.hyprland.homeManagerModules.default
      {
        home = {
          username = "wera";
          homeDirectory = "/home/wera";
          packages = with pkgs; [ brightnessctl ];
          stateVersion = "23.11";
        };
      }
    ];
    users.wera = import ./home.nix;
  };
}
