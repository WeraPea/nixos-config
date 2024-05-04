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
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixvim,
      self,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages = import ./pkgs nixpkgs.legacyPackages.${system};
      formatter.${system} = pkgs.nixfmt-rfc-style;
      overlays = import ./overlays { inherit inputs; };

      # homeManagerConfigurations = {
      #   "wera@nixos" = home-manager.lib.homeManagerConfiguration {
      #     inherit pkgs;
      #     modules = [
      #       ./home
      #       ./home/nixos.nix
      #       nixvim.homeManagerModules.nixvim
      #     ];
      #   };
      #   "wera@nixos-laptop" = home-manager.lib.homeManagerConfiguration {
      #     inherit pkgs;
      #     modules = [
      #       ./home
      #       ./home/nixos-laptop.nix
      #       nixvim.homeManagerModules.nixvim
      #     ];
      #   };
      # };

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            inputs.stylix.nixosModules.stylix
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
            ./home/nixos-laptop.nix
            ./stylix
            ./system
            ./system/nixos-laptop.nix
            ./system/hardware-configuration-nixos-laptop.nix
          ];
        };
      };
    };
}
