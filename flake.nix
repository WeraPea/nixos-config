{
  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:nix-community/stylix";
    nur.url = "github:nix-community/NUR";
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
    pinenote-nixos.url = "github:WeraPea/pinenote-nixos";
    pinenote-usb-tablet = {
      url = "github:WeraPea/pinenote-usb-tablet";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mobile-nixos = {
      url = "github:mobile-nixos/mobile-nixos";
      flake = false;
    };
    fcitx-virtualkeyboard-adapter = {
      url = "github:horriblename/fcitx-virtualkeyboard-adapter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mango = {
      url = "github:WeraPea/mangowc/combined";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    glide = {
      url = "github:glide-browser/glide.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-extensions-declarative = {
      url = "github:firefox-extensions-declarative/firefox-extensions-declarative";
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
      overlays = with inputs; [
        fcitx-virtualkeyboard-adapter.overlays.default
        glide.overlays.default
        pinenote-usb-tablet.overlays.default
        nur.overlays.default
      ];
      foreachSystem = nixpkgs.lib.genAttrs systems;
      pkgsBySystem = foreachSystem (
        system:
        import inputs.nixpkgs {
          inherit system overlays;
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
        home-manager.nixosModules.home-manager
        mango.nixosModules.mango
        nixpkgs-xr.nixosModules.nixpkgs-xr
        nur.modules.nixos.default
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        {
          home-manager = {
            useUserPackages = true;
            useGlobalPkgs = true;
            extraSpecialArgs = {
              inherit inputs outputs;
            };
            sharedModules = [
              mango.hmModules.mango
              nix-index-database.homeModules.nix-index
              nixvim.homeModules.nixvim
              sops-nix.homeManagerModules.sops
              ({ config, ... }: import ./sops.nix { username = config.home.username; })
            ];
          };
        }
        { nixpkgs.overlays = overlays; }
        (
          { pkgs, lib, ... }:
          {
            options.buildSystem = lib.mkOption { default = pkgs.stdenv.hostPlatform.system; }; # this is a mess and i probably don't need it
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
