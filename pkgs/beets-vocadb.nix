{
  lib,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "beets-vocadb";
  version = "unstable-2025-10-19";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "prTopi";
    repo = "beets-vocadb";
    rev = "293a933327b188b75826d457e0864e18c97df2a3";
    hash = "sha256-uGKIw3w5kGdQ3jzogOz3mWhmo6myIaocateZXPMVjcA=";
  };

  patches = [ ./beets-vocadb-purl.patch ];

  preBuild = ''
    substituteInPlace beetsplug/vocadb/mapper.py \
      --replace-fail "# track_id=track_id," "track_id=track_id,";
  '';

  build-system = [
    python3.pkgs.poetry-core
  ];
  nativeBuildInputs = [
    python3.pkgs.pythonRelaxDepsHook
  ];
  pythonRelaxDeps = [
    "typing-extensions"
  ];

  buildInputs = with python3.pkgs; [
    beets
    httpx.optional-dependencies.http2
    msgspec
    mutagen
  ];

  propagatedBuildInputs = with python3.pkgs; [
    httpx.optional-dependencies.http2
    msgspec
    typing-extensions
    mutagen
  ];

  meta = {
    description = "Plugin for beets to use VocaDB, UtaiteDB and TouhouDB as an autotagger source";
    homepage = "https://github.com/prTopi/beets-vocadb/tree/experimental";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "beets-vocadb";
  };
}
