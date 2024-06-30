{
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
    nur.url = "github:nix-community/NUR";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixvim,
      flake-utils,
      nur,
      self,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      foreachSystem = nixpkgs.lib.genAttrs systems;
      pkgsBySystem = foreachSystem (
        system:
        import inputs.nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          # overlays = self.overlays."${system}";
        }
      );
    in
    {
      packages = foreachSystem (system: import ./pkgs nixpkgs.legacyPackages.${system});

      # overlays = import ./overlays { inherit inputs; };

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            inputs.stylix.nixosModules.stylix
            { nixpkgs.overlays = [ nur.overlay ]; }
            nur.nixosModules.nur
            ./home/nixos.nix
            ./stylix
            ./system
            ./system/nixos.nix
            ./system/hardware-configuration-nixos.nix
          ];
        };
        nixos-laptop = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            inputs.stylix.nixosModules.stylix
            { nixpkgs.overlays = [ nur.overlay ]; }
            nur.nixosModules.nur
            ./home/nixos-laptop.nix
            ./stylix
            ./system
            ./system/nixos-laptop.nix
            ./system/hardware-configuration-nixos-laptop.nix
          ];
        };
        pinenote = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            inputs.stylix.nixosModules.stylix
            { nixpkgs.overlays = [ nur.overlay ]; }
            nur.nixosModules.nur
            ./home/pinenote.nix
            ./stylix
            ./system
            ./system/pinenote.nix
            ./system/hardware-configuration-pinenote.nix
          ];
        };
      };
    };
}
