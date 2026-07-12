{
  flake,
  lib,
  ...
}:
let
  moduleName = "overlays";
in
{
  options.flake.overlays = lib.mkOption { };
  config = {
    flake.overlays = {
      flake = (
        final: prev: {
          werapi = prev.werapi or { } // {
            inherit flake;
          };
        }
      );
      mkRemoteWrapper = (
        final: prev: {
          werapi = (prev.werapi or { }) // {
            mkRemoteWrapper = final.callPackage (
              {
                lib,
                openssh,
                writeShellScriptBin,
              }:
              {
                hostname,
                targetHostname,
                targetSsh ? targetHostname,
                package ? null, # the derivation that we have to assume the target machine has in store
                name ?
                  if (package != null) then
                    package.meta.mainProgram or (lib.getName package)
                  else
                    lib.tail (lib.splitString "/" exe),
                exe ? lib.getExe' package name,
              }:
              writeShellScriptBin "${name}-remote-wrapped" (
                if hostname == targetHostname then # sh
                  ''
                    exec "${exe}" "$@"
                  '' # sh
                else
                  ''
                    exe="${builtins.unsafeDiscardStringContext exe}"
                    remote_cmd=$(printf '%q ' "$exe" "$@")
                    ${lib.getExe openssh} ${targetSsh} "sh -c $(printf '%q ' "$remote_cmd")"
                  ''
              )
            ) { };
          };
        }
      );
      my-forks = (
        final: prev: {
          opentabletdriver = prev.opentabletdriver.overrideAttrs (old: {
            src = final.fetchFromGitHub {
              owner = "WeraPea";
              repo = "OpenTabletDriver";
              rev = "415b3ba87c52f8e8d0aa0ebde6065ccea0c830ee";
              hash = "sha256-fMy08nuyXVSBvhKj2D7ozbRFIRKetPaoVrdtgUo/Ynk=";
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

          wvkbd = prev.wvkbd.overrideAttrs (old: {
            src = final.fetchFromGitHub {
              owner = "WeraPea";
              repo = "wvkbd";
              rev = "58d153d40bd5ab852dffa6cda5ae5db330cf0204";
              hash = "sha256-6I+aozymoWk+OrT8pCOn+g1MY12QkQZaV1O/16rMbdU=";
            };
          }); # touch_cancel support and disabling popups
        }
      );
      forks = (
        final: prev: {
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
        }
      );
      fixes = (
        final: prev: {
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

          libinput-arbitration-ignore-all = prev.libinput.overrideAttrs (old: {
            patches = old.patches or [ ] ++ [
              ./arbitration-ignore-all.patch # makes touch arbitration ignore all touches instead of ones only inside an unreliable rect area
            ];
          });

          nh-unwrapped = prev.nh-unwrapped.overrideAttrs (old: {
            patches =
              old.patches or [ ]
              ++
                lib.optionals (final.stdenv.hostPlatform.system == "x86_64-linux") # not needed on machines that aren't used for building
                  [
                    ./nh-no-spinner-yes-progress.patch # gives actual info about remote copy progress instead of a fancy useless spinner
                  ];
          });
        }
      );
    };
    flake.modules.${moduleName}.nixos =
      {
        config,
        lib,
        ...
      }:
      let
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
          nixpkgs.overlays = lib.mkAfter (flake.lib.publicAttrValues flake.overlays);
        };
      };
  };
}
