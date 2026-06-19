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
    wl-find-cursor = {
      url = "github:cjacker/wl-find-cursor";
      flake = false; # flake only provides x86_64-linux
    };
    bs-scrobbler = {
      url = "github:WeraPea/bs-scrobbler";
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
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      foreachSystem = nixpkgs.lib.genAttrs systems;
      pkgsBySystem = foreachSystem (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ self.overlays.default ];
        }
      );
      treefmtEval = foreachSystem (
        system:
        inputs.treefmt-nix.lib.evalModule pkgsBySystem.${system} {
          projectRootFile = "flake.nix";
          programs = {
            nixfmt.enable = true;
            shellcheck.enable = true;
            shfmt.enable = true;
          };
        }
      );
      specialArgs = { inherit inputs outputs self; };
      overlay = (
        final: prev: { werapi = prev.werapi or { } // (importPackages final) // { flake = self; }; }
      );

      isNixModule = file: file.hasExt "nix" && file.name != "flake.nix";
      importTree =
        path:
        builtins.filter (p: !lib.any (lib.hasPrefix "_") (lib.splitString "/" (toString p))) (
          lib.fileset.toList (lib.fileset.fileFilter isNixModule path)
        );
      underscorePrefix = s: if builtins.match "[0-9].*" s != null then "_${s}" else s;
      nameFromPath = path: underscorePrefix (lib.removeSuffix ".nix" (baseNameOf path));
      pathsToAttrs =
        mapFunc: paths:
        builtins.listToAttrs (
          map (path: {
            name = nameFromPath path;
            value = mapFunc path;
          }) paths
        );
      mkNixConfig =
        host: module:
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ module ] ++ importTree ./modules;
        };
      mkNixConfigs = paths: pathsToAttrs (path: mkNixConfig (nameFromPath path) path) paths;
      importPackages = pkgs: pathsToAttrs (path: pkgs.callPackage path { }) (importTree ./pkgs);
    in
    {
      formatter = foreachSystem (system: treefmtEval.${system}.config.build.wrapper);
      overlays.default = overlay;
      packages = foreachSystem (system: importPackages pkgsBySystem.${system});
      nixosConfigurations = mkNixConfigs (importTree ./hosts);
    };
}
