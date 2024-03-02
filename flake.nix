{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    stylix.url = "github:danth/stylix";
    # spicetify-nix.url = "github:the-argus/spicetify-nix";
    spicetify-nix.url = "github:A1ca7raz/spicetify-nix";
    base16Styles = {
      url = "github:samme/base16-styles";
      flake = false;
    };
    audiorelay.url = "github:niscolas/audiorelay-flake-fork";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    packages = import ./pkgs nixpkgs.legacyPackages.${system};
    formatter.${system} = pkgs.alejandra;

    overlays = import ./overlays {inherit inputs;};

    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          inputs.stylix.nixosModules.stylix
          ./stylix
          ./system
          ./home
        ];
      };
    };
  };
}
