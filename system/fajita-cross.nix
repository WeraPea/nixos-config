{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  releaseTools = import "${inputs.mobile-nixos}/lib/release-tools.nix" { inherit pkgs; };
  inherit (releaseTools.withPkgs pkgs) knownSystems;
  pkgsCross =
    (releaseTools.evalWith {
      device = "oneplus-fajita";
      modules = [ ];
      additionalConfiguration = {
        nixpkgs.localSystem = knownSystems.x86_64-linux;
        nixpkgs.crossSystem = knownSystems.aarch64-linux // {
          system = "aarch64-linux";
          isAarch32 = false;
        };
        mobile.kernel.structuredConfig = config.mobile.kernel.structuredConfig;
      };
    }).pkgs;

  # cant just wrap in all in an mkIf as that causes an infinite recursion so below is needed for each override
  useCross = value: fallback: if config.buildSystem == "x86_64-linux" then value else fallback;
in
{
  nixpkgs.overlays = lib.mkAfter [
    (final: prev: {
      # adbd = useCross pkgsCross.adbd prev.adbd;
      mkbootimg = useCross pkgsCross.mkbootimg prev.mkbootimg;
      # dtbTool = useCross pkgsCross.dtbTool prev.dtbTool;
      # qc-image-unpacker = useCross pkgsCross.qc-image-unpacker prev.qc-image-unpacker;

      # android-partition-tools = useCross pkgsCross.android-partition-tools prev.android-partition-tools;
      # qmic = useCross pkgsCross.qmic prev.qmic;
      # rmtfs = useCross pkgsCross.rmtfs prev.rmtfs;
      # pd-mapper = useCross pkgsCross.pd-mapper prev.pd-mapper;
      # tqftpserv = useCross pkgsCross.tqftpserv prev.tqftpserv;
      mobile-nixos = prev.mobile-nixos // {
        kernel-builder = useCross pkgsCross.mobile-nixos.kernel-builder prev.mobile-nixos.kernel-builder;
        # kernel-builder-clang = useCross pkgsCross.mobile-nixos.kernel-builder-clang prev.mobile-nixos.kernel-builder-clang;
        stage-1 = prev.mobile-nixos.stage-1 // {
          script-loader = useCross pkgsCross.mobile-nixos.stage-1.script-loader prev.mobile-nixos.stage-1.script-loader;
          boot-recovery-menu = useCross pkgsCross.mobile-nixos.stage-1.boot-recovery-menu prev.mobile-nixos.stage-1.boot-recovery-menu;
          boot-error = useCross pkgsCross.mobile-nixos.stage-1.boot-error prev.mobile-nixos.stage-1.boot-error;
          boot-splash = useCross pkgsCross.mobile-nixos.stage-1.boot-splash prev.mobile-nixos.stage-1.boot-splash;
        };
        # android-flashable-zip-binaries = useCross pkgsCross.mobile-nixos.android-flashable-zip-binaries prev.mobile-nixos.android-flashable-zip-binaries;
        # autoport = useCross pkgsCross.mobile-nixos.autoport prev.mobile-nixos.autoport;
        # boot-control = useCross pkgsCross.mobile-nixos.boot-control prev.mobile-nixos.boot-control;
        # fdt-forward = useCross pkgsCross.mobile-nixos.fdt-forward prev.mobile-nixos.fdt-forward;
        gui-assets = useCross pkgsCross.mobile-nixos.gui-assets prev.mobile-nixos.gui-assets;
        # make-flashable-zip = useCross pkgsCross.mobile-nixos.make-flashable-zip prev.mobile-nixos.make-flashable-zip;
        # map-dtbs = useCross pkgsCross.mobile-nixos.map-dtbs prev.mobile-nixos.map-dtbs;
        # mkLVGUIApp = useCross pkgsCross.mobile-nixos.mkLVGUIApp prev.mobile-nixos.mkLVGUIApp;
      };
      # vboot_reference = useCross pkgsCross.vboot_reference prev.vboot_reference;
      # lk2ndMsm8953 = useCross pkgsCross.lk2ndMsm8953 prev.lk2ndMsm8953;
      mruby = useCross pkgsCross.mruby prev.mruby;
    })
  ];

  mobile.boot.stage-1.kernel.package = lib.mkIf (config.buildSystem == "x86_64-linux") (
    lib.mkForce (
      pkgsCross.callPackage "${inputs.mobile-nixos}/devices/families/sdm845-mainline/kernel" { }
    )
  );
}
