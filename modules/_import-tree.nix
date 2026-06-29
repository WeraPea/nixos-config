lib: path:
let
  isNixModule = file: file.hasExt "nix" && file.name != "flake.nix";
  rel = p: lib.removePrefix (toString path + "/") (toString p);
in
builtins.filter (p: !lib.any (lib.hasPrefix "_") (lib.splitString "/" (rel p))) (
  lib.fileset.toList (lib.fileset.fileFilter isNixModule path)
)
