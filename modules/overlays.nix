{
  config,
  lib,
  ...
}:
let
  moduleName = "overlays";
  cfg = config.werapi.${moduleName};
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
    nixpkgs.overlays = lib.mkAfter [
      (final: prev: {
        opentabletdriver = prev.opentabletdriver.overrideAttrs (old: {
          src = final.fetchFromGitHub {
            owner = "WeraPea";
            repo = "OpenTabletDriver";
            rev = "4afdee7cc6543193740f6511de8a3242f23c48d2";
            hash = "sha256-kegHYOXBY1K4Q7rfIryZ64Rr028DGp19J+ZNzfIfQ6k=";
          };
        });

        mpvScripts = prev.mpvScripts // {
          autosubsync-mpv = prev.mpvScripts.autosubsync-mpv.overrideAttrs (old: {
            src = final.fetchFromGitHub {
              owner = "WeraPea";
              repo = "autosubsync-mpv";
              rev = "0216bd95a39cf51e059b25d918a087cc402df72e";
              hash = "sha256-IrlyzzoRMdP6/kQBR+1S6WsMZnDozuu0n8oGFei3cNM=";
            };
          });
          webtorrent-mpv-hook = prev.mpvScripts.webtorrent-mpv-hook.overrideAttrs (old: {
            src = final.fetchFromGitHub {
              owner = "WeraPea";
              repo = "webtorrent-mpv-hook";
              rev = "d5c04a770ad22f166b65793da1abe99f36a21610";
              hash = "sha256-8ifGLsh+qlP/itsDbP/5K9q8/j6jgbbatDJCaL+sZQo=";
            };
          });
        };

        ffsubsync = prev.ffsubsync.overrideAttrs (old: {
          patches = old.patches or [ ] ++ [
            (final.fetchpatch {
              url = "https://github.com/WeraPea/ffsubsync/commit/be3691f5134db3b665035061acb1f7d79ca5aa91.patch";
              hash = "sha256-9UJtwVxrjoN1O7bseWDOuvaqEARaEVyTY1Y9qO+B/ys=";
            })
          ]; # can't easily override src as ffsubsync uses versioneer
        });

        bs-manager = prev.bs-manager.overrideAttrs (old: {
          desktopItems = [
            (final.makeDesktopItem {
              desktopName = "BSManager";
              name = "BSManager";
              exec = "bs-manager %u"; # add %u
              terminal = false;
              type = "Application";
              icon = "bs-manager";
              mimeTypes = [
                "x-scheme-handler/bsmanager"
                "x-scheme-handler/beatsaver"
                "x-scheme-handler/bsplaylist"
                "x-scheme-handler/modelsaber"
                "x-scheme-handler/web+bsmap"
              ];
              categories = [
                "Utility"
                "Game"
              ];
            })
          ];
        });

        # fixes controllers in No Man's Sky and more
        opencomposite-priorities = prev.opencomposite.overrideAttrs (old: {
          src = prev.fetchFromGitLab {
            fetchSubmodules = true;
            owner = "OrionMoonclaw";
            repo = "OpenOVR";
            rev = "81d4363a6533276d4726f2191d7a30835faf60d1"; # https://gitlab.com/OrionMoonclaw/OpenOVR/-/tree/81d4363a6533276d4726f2191d7a30835faf60d1/      hash = "sha256-Td18yRpwxnM9ir2fB2RRijsYdeSW48zXojNivAkgaeA=";
            hash = "sha256-Td18yRpwxnM9ir2fB2RRijsYdeSW48zXojNivAkgaeA=";
          };
        });

        xrizer-custom = prev.xrizer.overrideAttrs (old: rec {
          src = final.fetchFromGitHub {
            owner = "RinLovesYou";
            repo = "xrizer";
            rev = "f491eddd0d9839d85dbb773f61bd1096d5b004ef";
            hash = "sha256-12M7rkTMbIwNY56Jc36nC08owVSPOr1eBu0xpJxikdw=";
          };
          cargoDeps = final.rustPlatform.fetchCargoVendor {
            inherit src;
            hash = "sha256-87JcULH1tAA487VwKVBmXhYTXCdMoYM3gOQTkM53ehE=";
          };
          patches = [ ];
          doCheck = false;
        });

        lutris = prev.lutris.override {
          # Intercept buildFHSEnv to modify target packages
          buildFHSEnv =
            args:
            final.buildFHSEnv (
              args
              // {
                multiPkgs =
                  envPkgs:
                  let
                    # Fetch original package list
                    originalPkgs = args.multiPkgs envPkgs;

                    # Disable tests for openldap
                    customLdap = envPkgs.openldap.overrideAttrs (_: {
                      doCheck = false;
                    });
                  in
                  # Replace broken openldap with the custom one
                  builtins.filter (p: (p.pname or "") != "openldap") originalPkgs ++ [ customLdap ];
              }
            );
        };
      })
    ];
  };
}
