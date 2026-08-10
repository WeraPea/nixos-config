{
  lib,
  pkgs,
}:
let
  pinnedPkgs =
    import
      (fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/d407951447dcd00442e97087bf374aad70c04cea.tar.gz";
        sha256 = "1jgfnvi57n79zsfljh2i4b77yj6wh028z4r3wf223am8wznzqbzj";
      })
      {
        system = pkgs.stdenv.hostPlatform.system;
        inherit (pkgs) config;
      };
in
pinnedPkgs.stdenvNoCC.mkDerivation rec {
  pname = "udev-gothic-hs-nf";
  version = "2.1.0";
  src = pinnedPkgs.fetchFromGitHub {
    owner = "yuru7";
    repo = "udev-gothic";
    rev = "v${version}";
    hash = "sha256-l5d15kR4F5rzmTO4rDWWz9C5zP5TNFnmyz9HHg6Fvy4=";
  };

  nativeBuildInputs = [
    pinnedPkgs.python3
    pinnedPkgs.fontforge
    pinnedPkgs.python3Packages.fonttools
    pinnedPkgs.python3Packages.ttfautohint-py
  ];

  patches = [ ./udev-gothic-fontforge-20251009-workaround.patch ];

  # ttfautohint: unrecognized option '--epoch'
  postPatch = ''
    substituteInPlace fonttools_script.py \
      --replace-fail 'print("exec hinting", options_)' 'options_.pop("epoch", None)'
  '';

  buildPhase = ''
    runHook preBuild
    common_flags="--hidden-zenkaku-space --nerd-font"

    declare -a variants=(
      # ""
      # "--35"
      # "--jpdoc"
      # "--liga"
      # "--dot-zero"
      # "--35 --jpdoc"
      # "--35 --liga"
      # "--35 --dot-zero"
      # "--jpdoc --liga"
      # "--jpdoc --dot-zero"
      # "--liga --dot-zero"
      # "--35 --jpdoc --liga"
      # "--35 --jpdoc --dot-zero"
      "--35 --liga --dot-zero"
      # "--jpdoc --liga --dot-zero"
      "--35 --jpdoc --liga --dot-zero"
    )

    for flags in "''${variants[@]}"; do
      suffix=$(echo "$flags" | tr ' ' '_' | tr -d '-')
      [ -z "$suffix" ] && suffix="default"
      python ./fontforge_script.py $common_flags $flags
      python ./fonttools_script.py
      mv build build_$suffix
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    for dir in build_*; do
      install -Dm644 "$dir"/*.ttf -t "$out/share/fonts/udev-gothic-hs-nf/"
    done
    runHook postInstall
  '';

  meta = with lib; {
    description = "Programming font that combines BIZ UD Gothic, JetBrains Mono, and nerd-fonts. Full-width space invisible version";
    homepage = "https://github.com/yuru7/udev-gothic";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
