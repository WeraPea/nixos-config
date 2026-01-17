{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

let
  version = "1.24.6";

  selectSystem =
    attrs:
    attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  arch = selectSystem {
    "x86_64-linux" = "desktop";
    "aarch64-linux" = "aarch64";
  };
  src = fetchurl {
    url = "https://github.com/tachibana-shin/rakuyomi/releases/download/v${version}/rakuyomi-${arch}.zip";
    hash = selectSystem {
      "x86_64-linux" = "sha256-/qn3xGexwYTZJ56WluguEKbEIK9EdXpTGtkH/jxwykY=";
      "aarch64-linux" = "sha256-lXr8j9pG3aUPpIQEXtCE0P+NKXkO/wUqQX40iAp6/UE=";
    };
  };
in

stdenv.mkDerivation {
  pname = "rakuyomi";
  inherit version src;

  buildInputs = [ unzip ];
  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir $out
    cp -r rakuyomi.koplugin/* $out/
  '';

  meta = {
    description = "A manga reader plugin for KOReader. (This fork adds new features and backward compatibility)";
    homepage = "https://github.com/tachibana-shin/rakuyomi";
    license = lib.licenses.agpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
