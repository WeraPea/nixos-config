{ pkgs, ... }:
{
  boot.kernelPackages =
    let
      linux_pinenote_pkg =
        { fetchurl, buildLinux, ... }@args:
        buildLinux (
          args
          // rec {
            version = "pinenote-6.6.3";
            modDirVersion = version;

            src = fetchurl {
              url = "https://github.com/m-weigand/linux/archive/refs/tags/v20240510.tar.gz";
              hash = "";
            };
            kernelPatches = [ ];

            extraMeta.branch = "6.6";
          }
          // (args.argsOverride or { })
        );
      linux_pinenote = pkgs.callPackage linux_pinenote_pkg { };
    in
    pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_pinenote);
}
