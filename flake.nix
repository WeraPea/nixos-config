{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.url = "github:nix-community/nixvim";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rycee = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    erosanix = {
      url = "github:emmanuelrosa/erosanix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pinenote-nixos.url = "github:WeraPea/pinenote-nixos";
    pinenote-usb-tablet = {
      url = "github:WeraPea/pinenote-usb-tablet";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mobile-nixos = {
      url = "github:WeraPea/mobile-nixos/sdm845";
      flake = false;
    };
    fcitx-virtualkeyboard-adapter = {
      url = "github:horriblename/fcitx-virtualkeyboard-adapter";
      flake = false; # flake has no aarch64-linux
    };
    mango = {
      url = "github:WeraPea/mangowc/combined";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    glide = {
      url = "github:glide-browser/glide.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-extensions-declarative.url = "github:firefox-extensions-declarative/firefox-extensions-declarative";
    qocr = {
      url = "github:WeraPea/qocr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bs-scrobbler = {
      url = "github:WeraPea/bs-scrobbler";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
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
      inherit (nixpkgs) lib;
      specialArgs = {
        inherit inputs outputs;
        flake = self;
      };

      flakeModules = lib.evalModules {
        modules = (import ./modules/_import-tree.nix lib ./modules);
        inherit specialArgs;
      };
    in
    {
      inherit flakeModules;
      flake = self;
    }
    // flakeModules.config.flake;
}
