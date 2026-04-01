{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage (finalAttrs: {
  pname = "yomitan-ultimate-audio";
  version = "0-unstable-2026-01-15";

  src = fetchFromGitHub {
    owner = "L-M-Sherlock";
    repo = "yomitan-ultimate-audio";
    rev = "6d4e0d3ee1ad49ac8f52965cda614e72c9fc33c3";
    hash = "sha256-UrET0wHOplJHt9hXNSyHNCeR8LrEskEU64+QbmmGOWs=";
  };

  npmDepsHash = "sha256-VVyrG9TcMhV8refdeynPTzYiu5URePE8vqHTqaGHxfA=";
  dontNpmBuild = true;

  postPatch = ''
    npm pkg set dependencies.tsx="$(npm pkg get devDependencies.tsx --json | tr -d '"')"
    npm pkg delete devDependencies.tsx
  '';

  meta = {
    description = "";
    homepage = "https://github.com/L-M-Sherlock/yomitan-ultimate-audio";
    license = lib.licenses.unfree; # no licensee
    mainProgram = "yomitan-ultimate-audio";
    platforms = lib.platforms.all;
  };
})
