{
  inputs,
  outputs,
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
        home = {
          username = "wera";
          homeDirectory = "/home/wera";
          stateVersion = "23.11";
        };
      }
    ];
    users.wera = import ./home.nix;
    useUserPackages = true;
  };
}
