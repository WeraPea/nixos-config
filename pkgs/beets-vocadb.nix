{
  lib,
  python3,
  fetchFromGitHub,
  httpx-retries,
}:
python3.pkgs.buildPythonApplication {
  pname = "beets-vocadb";
  version = "unstable-2026-02-01";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "prTopi";
    repo = "beets-vocadb";
    rev = "f2b033eb4249193fe658f8d17bf2e5740060adbc"; # newest for 2.5.1
    hash = "sha256-Y5aw8Wo3Z9vveDf3Lo7SkMT0JGtM1UjNnhfIkuMdUC0=";
  };

  patches = [ ./beets-vocadb-purl.patch ];

  preBuild = ''
    substituteInPlace pyproject.toml \
      --replace-fail "ruff (>=0.14.14,<0.15.0)" "ruff (>=0.14.14)" \
      --replace-fail "msgspec (>=0.19.0,<0.20.0)" "msgspec (>=0.19.0)";
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
    httpx-retries
    msgspec
    mutagen
    ruff
  ];

  propagatedBuildInputs = with python3.pkgs; [
    httpx.optional-dependencies.http2
    httpx-retries
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
