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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    osu-scrobbler.url = "github:WeraPea/osu-scrobbler";
    pinenote-nixos.url = "github:WeraPea/pinenote-nixos"; # not changing nixpkgs so that kernel derivation from cachix can be used
    # pinenote-nixos.url = "git+file:///home/wera/pinenote/pinenote-nixos";
    pinenote-nixos-follows = {
      # for python version to be the same
      url = "github:WeraPea/pinenote-nixos";
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
      treefmtEval = foreachSystem (
        system: inputs.treefmt-nix.lib.evalModule pkgsBySystem.${system} ./treefmt.nix
      );
      commonModules = with inputs; [
        erosanix.nixosModules.protonvpn
        nur.modules.nixos.default
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        { nixpkgs.overlays = [ nur.overlays.default ]; }
        ./overlays
        ./stylix
        ./system
        ./sops.nix
      ];
    in
    {
      packages = foreachSystem (system: import ./pkgs pkgsBySystem.${system});
      formatter = foreachSystem (system: treefmtEval.${system}.config.build.wrapper);

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
            inputs.pinenote-nixos.nixosModules.default
            ./home/pinenote.nix
            ./system/pinenote.nix
          ];
        };
      };
    };
}
