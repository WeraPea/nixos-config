{
  flake,
  lib,
  ...
}:
let
  treefmtEval = flake.lib.foreachSystem (
    system:
    flake.inputs.treefmt-nix.lib.evalModule flake.lib.pkgsBySystem.${system} {
      projectRootFile = "flake.nix";
      programs = {
        nixfmt.enable = true;
        shellcheck.enable = true;
        shfmt.enable = true;
      };
    }
  );
in
{
  options.flake.formatter = lib.mkOption { };
  config.flake.formatter = flake.lib.foreachSystem (
    system: treefmtEval.${system}.config.build.wrapper
  );
}
