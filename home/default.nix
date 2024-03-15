{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    sharedModules = [inputs.nixvim.homeManagerModules.nixvim];
    users.wera = import ./home.nix;
    useUserPackages = true;
  };
}
