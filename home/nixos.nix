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
          stateVersion = "23.11";
        };
        # quickshell.enable = true;
        mango.enable = true;
      }
    ];
    users.wera = import ./home.nix;
  };
}
