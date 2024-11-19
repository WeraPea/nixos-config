{
  inputs,
  outputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs;
    };
    sharedModules = [
      inputs.hyprland.homeManagerModules.default
      inputs.nix-index-database.hmModules.nix-index
      inputs.nixvim.homeManagerModules.nixvim
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
    useUserPackages = true;
  };
}
