{
  flake,
  inputs,
  ...
}:
let
  moduleName = "cross";
in
{
  flake.nixpkgs-patches.expose-nixpkgsFun = pkgs: ./expose-nixpkgsFun.patch;
  flake.overlays = {
    cross = (
      final: prev: {
        werapi = (prev.werapi or { }) // {
          pkgsX86_64 = final.nixpkgsFun {
            localSystem = "x86_64-linux";
          };
          pkgsCrossFromX86 = final.nixpkgsFun {
            localSystem = "x86_64-linux";
            crossSystem = {
              inherit (final.stdenv.hostPlatform) config;
            };
          };
        };
      }
    );
    _cross-pkgs-post = (
      final: prev:
      if prev.stdenv.buildPlatform.system == "x86_64-linux" then
        { }
      else
        {
          werapi = prev.werapi or { } // {
            udev-gothic-hs-nf = final.werapi.pkgsX86_64.werapi.udev-gothic-hs-nf;
            yuru = final.werapi.pkgsCrossFromX86.werapi.yuru.overrideAttrs (old: {
              preBuild = (old.preBuild or "") + ''
                export CC_x86_64_unknown_linux_gnu=${final.werapi.pkgsCrossFromX86.buildPackages.stdenv.cc}/bin/cc
                export CXX_x86_64_unknown_linux_gnu=${final.werapi.pkgsCrossFromX86.buildPackages.stdenv.cc}/bin/c++
              '';
            });
          };
        }
    );
    _cross-pkgs-pre = (
      final: prev:
      if prev.stdenv.buildPlatform.system == "x86_64-linux" then
        { }
      else
        {
          mpd = final.werapi.pkgsCrossFromX86.mpd.override (
            final.lib.genAttrs [
              "glib"
              "fmt"
              "curl"
              "libcdio"
              "libcdio-paranoia"
              "libmms"
              "libnfs"
              "liburing"
              "samba"
              # Archive support"
              "bzip2"
              "zziplib"
              # Codecs
              "audiofile"
              "faad2"
              "ffmpeg"
              "flac"
              "fluidsynth"
              "game-music-emu"
              "libmad"
              "libmikmod"
              "mpg123"
              "libopus"
              "libvorbis"
              "lame"
              # Filters
              "libsamplerate"
              "soxr"
              # Outputs
              "alsa-lib"
              "libao"
              "libjack2"
              "libpulseaudio"
              "libshout"
              "pipewire"
              # Misc
              "icu"
              "sqlite"
              "dbus"
              "pcre2"
              "libgcrypt"
              "expat"
              "nlohmann_json"
              "zlib"
              "libupnp"
              # Client support
              "libmpdclient"
              # Tag support
              "libid3tag"
              # For documentation
              "doxygen"
            ] (name: final.${name})
            // {
              avahi = final.werapi.pkgsCrossFromX86.avahi.override (
                final.lib.genAttrs [
                  "libdaemon"
                  "dbus"
                  "libpcap"
                  "expat"
                  "gettext"
                  "glib"
                  "autoconf-archive"
                  "libiconv"
                  "libevent"
                ] (name: final.${name})
              );
            }
          );
        }
    );
  };
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};
      cross =
        config.werapi.buildSystem == "x86_64-linux" && config.nixpkgs.hostPlatform.system != "x86_64-linux";
      manPackage =
        if cross then
          pkgs.symlinkJoin {
            name = "man-with-x86_64-mandb";
            paths = [
              pkgs.man
              pkgs.werapi.pkgsX86_64.man
            ];

            postBuild = ''
              rm -f $out/bin/mandb
              ln -s ${pkgs.werapi.pkgsX86_64.man}/bin/mandb $out/bin/mandb
            '';
          }
        else
          pkgs.man;

      mango-pkg =
        if cross then
          (pkgs.werapi.pkgsCrossFromX86.callPackage "${inputs.mango}/nix/default.nix" {
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
            scenefx = inputs.mango.inputs.scenefx.packages.${pkgs.stdenv.hostPlatform.system}.default;
            wayland = pkgs.wayland;
            wayland-protocols = pkgs.wayland-protocols;
            wlroots_0_20 = pkgs.wlroots_0_20;
            xwayland = pkgs.xwayland;
          }).overrideAttrs
            (old: {
              nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.werapi.pkgsCrossFromX86.autoPatchelfHook ];
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
        nixpkgs.overlays = lib.optionals cross (
          lib.mkMerge [
            # overlays/default.nix is 1500 from mkAfter
            (lib.mkOrder 2000 [ flake.overlays._cross-pkgs-post ])
            (lib.mkOrder 100 [ flake.overlays._cross-pkgs-pre ])
          ]
        );
      };
    };
}
