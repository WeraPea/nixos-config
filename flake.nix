{
  description = "Nixos config flake";

  inputs = {
    audiorelay.url = "github:niscolas/audiorelay-flake-fork";
    base16Styles = {
      url = "github:samme/base16-styles";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix.url = "github:A1ca7raz/spicetify-nix";
    stylix.url = "github:danth/stylix";
  };

  outputs =
    { nixpkgs, self, ... }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages = import ./pkgs nixpkgs.legacyPackages.${system};
      formatter.${system} = pkgs.nixfmt-rfc-style;
      overlays = import ./overlays { inherit inputs; };

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            inputs.stylix.nixosModules.stylix
            ./home
            ./stylix
            ./system
          ];
        };
      };
    };
}
