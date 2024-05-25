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
      inputs.nixvim.homeManagerModules.nixvim
      {
        home.username = "wera";
        home.homeDirectory = "/home/wera";
        home.packages = with pkgs; [ inputs.audiorelay.packages.${system}.audio-relay ];
      }
    ];
    users.wera = import ./home.nix;
    useUserPackages = true;
  };
}
