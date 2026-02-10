{
  pkgs,
  osConfig,
  inputs,
  ...
}:
let
  pkgsX86_64 = import inputs.nixpkgs {
    system = "x86_64-linux";
  };
  cross = osConfig.buildSystem == "x86_64-linux" && pkgs.stdenv.hostPlatform.system != "x86_64-linux";
in
{
  # saves a minute on rebuilds
  programs.man.package =
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
}
