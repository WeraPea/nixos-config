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
    sharedModules = [ inputs.nixvim.homeManagerModules.nixvim ];
    users.wera = import ./home.nix {
      home.username = "wera";
      home.homeDirectory = "/home/wera";
    };
    useUserPackages = true;
  };
}
