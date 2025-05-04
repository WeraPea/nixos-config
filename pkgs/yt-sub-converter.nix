{
  lib,
  stdenv,
  fetchzip,
  makeWrapper,
  wrapGAppsHook3,
  mono,
  gtk3,
}:

stdenv.mkDerivation rec {
  pname = "yt-sub-converter";
  version = "1.6.3";

  src = fetchzip {
    url = "https://github.com/arcusmaximus/YTSubConverter/releases/download/${version}/YTSubConverter-Linux.tar.xz";
    sha256 = "sha256-r247RIvZBJGb74VZw9F94u46KQiQoLmkeeatpPcLpbk=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
  ];
  buildInputs = [ mono ];

  libraries = lib.makeLibraryPath [
    gtk3
  ];

  buildPhase = "true";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/${pname}
    cp -r $src/* $out/share/${pname}
    runHook postInstall
  '';
  postFixup = ''
    makeWrapper ${mono}/bin/mono $out/bin/YTSubConverter \
      --add-flags $out/share/${pname}/YTSubConverter.exe \
      --set LD_LIBRARY_PATH $libraries \
      "''${gappsWrapperArgs[@]}"
  '';

  meta = with lib; {
    description = "A tool for creating styled YouTube subtitles ";
    mainProgram = "YTSubConverter";
    homepage = "https://github.com/arcusmaximus/YTSubConverter";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
