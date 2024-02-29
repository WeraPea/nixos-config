{
  description = "Nixos config flake";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nur.url = "github:nix-community/NUR";
    stylix.url = "github:danth/stylix/release-23.11";
    spicetify-nix.url = "github:the-argus/spicetify-nix";
    base16Styles = {
      url = "github:samme/base16-styles";
      flake = false;
    };
    audiorelay.url = "github:niscolas/audiorelay-flake-fork";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
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
