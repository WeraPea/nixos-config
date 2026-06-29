{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  profiles ? { },
}:
stdenvNoCC.mkDerivation {
  pname = "anki-koplugin";
  version = "unstable-2025-09-11";
  src = fetchFromGitHub {
    owner = "Ajatt-Tools";
    repo = "anki.koplugin";
    rev = "15a188b5bdd936ae82f59ed2d8adeffc5a80980a";
    hash = "sha256-n+VIOoD1l90PVvO2vAExtvyf8Ii7a4ilZH47D9KNO7s=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r * $out/

    ${builtins.concatStringsSep "\n" (
      lib.mapAttrsToList (name: path: "ln -s ${path} $out/profiles/${name}.lua") profiles
    )}

    runHook postInstall
  '';
}
