{
  stdenv,
  werapi,
  writeShellScript,
}:
stdenv.mkDerivation {
  pname = "flake-source";
  version = "0";
  src = werapi.flake.sourceInfo.outPath;
  installPhase = ''
    mkdir -p $out/flake-source
    mkdir -p $out/bin

    cp -r . $out/flake-source

    cp ${writeShellScript "echo flake-source dir" "echo OUT"} $out/bin/flake-source

    substituteInPlace $out/bin/flake-source \
      --replace-fail "OUT" $out/flake-source
  '';
}
