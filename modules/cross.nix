{
  inputs,
  ...
}:
let
  moduleName = "cross";
in
{
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};
      pkgsX86_64 = import inputs.nixpkgs {
        system = "x86_64-linux";
      };
      pkgsCross = import inputs.nixpkgs {
        system = "x86_64-linux";
        crossSystem = {
          config = "aarch64-unknown-linux-gnu";
        };
      };
      cross =
        config.werapi.buildSystem == "x86_64-linux" && pkgs.stdenv.hostPlatform.system != "x86_64-linux";
      manPackage =
        if cross then
          pkgs.symlinkJoin {
            name = "man-with-x86_64-mandb";
            paths = [
              pkgs.man
              pkgsX86_64.man
            ];

            postBuild = ''
              rm -f $out/bin/mandb
              ln -s ${pkgsX86_64.man}/bin/mandb $out/bin/mandb
            '';
          }
        else
          pkgs.man;

      mango-pkg =
        if cross then
          (pkgsCross.callPackage "${inputs.mango}/nix/default.nix" {
            cjson = pkgs.cjson;
            libdrm = pkgs.libdrm;
            libGL = pkgs.libGL;
            libinput = pkgs.libinput;
            libX11 = pkgs.libX11;
            libxcb = pkgs.libxcb;
            libxcb-wm = pkgs.libxcb-wm;
            libxkbcommon = pkgs.libxkbcommon;
            pango = pkgs.pango;
            pcre2 = pkgs.pcre2;
            pixman = pkgs.pixman;
            scenefx = inputs.mango.inputs.scenefx.packages.${pkgs.stdenv.hostPlatform.system}.scenefx;
            wayland = pkgs.wayland;
            wayland-protocols = pkgs.wayland-protocols;
            wlroots_0_19 = pkgs.wlroots_0_19;
            xwayland = pkgs.xwayland;
          }).overrideAttrs
            (old: {
              nativeBuildInputs = old.nativeBuildInputs ++ [ pkgsCross.autoPatchelfHook ];
            })
        else
          inputs.mango.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = config.werapi.defaultModules.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        hm.programs.man.package = manPackage;
        documentation.man.man-db.package = manPackage;
        documentation.man.cache.generateAtRuntime = !cross;
        wrappers.mango.package = mango-pkg;
        nixpkgs.overlays = lib.mkOrder 2000 [
          # overlays.nix is 1500 from mkAfter
          (final: prev: {
            werapi = prev.werapi or { } // {
              yuru =
                if cross then
                  ((pkgsCross.callPackage ../pkgs/yuru.nix { }).overrideAttrs (old: {
                    preBuild = (old.preBuild or "") + ''
                      export CC_x86_64_unknown_linux_gnu=${pkgsCross.buildPackages.stdenv.cc}/bin/cc
                      export CXX_x86_64_unknown_linux_gnu=${pkgsCross.buildPackages.stdenv.cc}/bin/c++
                    '';
                  }))
                else
                  prev.werapi.yuru;
            };
          })
        ];
      };
    };
}
