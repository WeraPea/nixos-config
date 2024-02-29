{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs outputs;};
    users.wera = import ./home.nix;
    sharedModules = [inputs.nur.hmModules.nur];
  };
}
