{
  inputs = {
    audiorelay.url = "github:niscolas/audiorelay-flake-fork";
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
    hyprland.url = "github:hyprwm/Hyprland";
    hyprgrass = {
      url = "github:horriblename/hyprgrass";
      inputs.hyprland.follows = "hyprland";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
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
    pinenote-nixos-follows = {
      # for python version to be the same
      url = "github:WeraPea/pinenote-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rakuyomi.url = "github:hanatsumi/rakuyomi";
    pinenote-service.url = "github:WeraPea/pinenote-service";
    mobile-nixos = {
      url = "github:mobile-nixos/mobile-nixos";
      flake = false;
    };
    fcitx-virtualkeyboard-adapter = {
      url = "github:WeraPea/fcitx-virtualkeyboard-adapter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
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
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useUserPackages = true;
            useGlobalPkgs = true;
            extraSpecialArgs = {
              inherit inputs outputs;
            };
            sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
              inputs.nix-index-database.homeModules.nix-index
              inputs.nixvim.homeModules.nixvim
              ({ config, ... }: import ./sops.nix { username = config.home.username; })
            ];
          };
        }
        { nixpkgs.overlays = [ nur.overlays.default ]; }
        (
          { pkgs, lib, ... }:
          {
            options.buildSystem = lib.mkOption { default = pkgs.system; }; # this is a mess and i probably don't need it
          }
        )
        ./overlays
        ./stylix
        ./system
        ({ config, ... }: import ./sops.nix { username = config.user.username; })
      ];
    in
    {
      packages = foreachSystem (system: import ./pkgs pkgsBySystem.${system});
      formatter = foreachSystem (system: treefmtEval.${system}.config.build.wrapper);

      nixosConfigurations = rec {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = commonModules ++ [
            inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
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
        pinenote-from-x86_64 = pinenote.extendModules {
          modules = [
            { config.buildSystem = "x86_64-linux"; }
          ];
        };
        fajita = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs outputs;
          };
          modules = commonModules ++ [
            (import "${inputs.mobile-nixos}/lib/configuration.nix" { device = "oneplus-fajita"; })
            ./home/fajita.nix
            ./system/fajita.nix
          ];
        };
      };
    };
}
