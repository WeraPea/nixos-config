{
  lib,
  buildLua,
  fetchFromGitHub,
  mitmproxy,
}:

buildLua {
  pname = "mpv-http-mitmytproxy";
  version = "unstable-2025-08-10";

  src = fetchFromGitHub {
    owner = "piyushgarg";
    repo = "mpv-http-mitmytproxy";
    rev = "26a66e1bd6ba013df09beb80b82f87217549ce22";
    hash = "sha256-mfQEaitDCUNWkvqdE/XbIt9oSy9DDNNENSVEazHjnmY=";
  };

  postPatch = ''
    substituteInPlace main.lua \
      --replace-fail 'os.getenv("HOME") .. "/venv/bin/mitmdump"' '"${lib.getExe' mitmproxy "mitmdump"}"' \
      --replace-fail 'mp.get_script_directory() .. "/mitmplugin.py"' "\"$out/share/mpv/scripts/mitmplugin.py\""
  '';
  scriptPath = "main.lua";
  extraScriptsToCopy = [ "mitmplugin.py" ];

  meta = {
    description = "";
    homepage = "https://github.com/piyushgarg/mpv-http-mitmytproxy";
    license = lib.licenses.asl20;
    mainProgram = "mpv-http-mitmytproxy";
    platforms = lib.platforms.all;
  };
}
