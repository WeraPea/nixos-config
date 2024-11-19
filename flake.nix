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
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";
    nur.url = "github:nix-community/NUR";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    erosanix.url = "github:emmanuelrosa/erosanix";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
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
        }
      );
      commonModules = with inputs; [
        erosanix.nixosModules.protonvpn
        stylix.nixosModules.stylix
        nur.nixosModules.nur
        { nixpkgs.overlays = [ nur.overlay ]; }
        ./overlays
        ./stylix
        ./system
      ];
    in
    {
      packages = foreachSystem (system: import ./pkgs pkgsBySystem.${system});

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = commonModules ++ [
            ./home/nixos.nix
            ./system/nixos.nix
            ./system/hardware-configuration-nixos.nix
          ];
        };
        nixos-laptop = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = commonModules ++ [
            ./home/nixos-laptop.nix
            ./system/nixos-laptop.nix
            ./system/hardware-configuration-nixos-laptop.nix
          ];
        };
        server = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = commonModules ++ [
            ./home/server.nix
            ./system/server.nix
            ./system/hardware-configuration-server.nix
          ];
        };
        pinenote = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = commonModules ++ [
            ./home/pinenote.nix
            ./system/pinenote.nix
            ./system/hardware-configuration-pinenote.nix
          ];
        };
      };
    };
}
