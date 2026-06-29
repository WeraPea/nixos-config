{
  lib,
  python3,
  fetchFromGitHub,
  werapi,
}:
python3.pkgs.buildPythonPackage {
  pname = "beets-vocadb";
  version = "unstable-2026-05-15";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "prTopi";
    repo = "beets-vocadb";
    rev = "71a0e1f625a8292d537229e6dc2d2a1b2d92d3e4";
    hash = "sha256-Q/TiyiyxRX3HPZRgKzqMYPpTw9SHzKuvDnaT1UrnsV0=";
  };

  patches = [ ./beets-vocadb-purl.patch ];

  preBuild = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.11.1,<0.12.0" "uv_build<0.12.0";
  '';

  build-system = [
    python3.pkgs.uv-build
  ];
  nativeBuildInputs = [
    python3.pkgs.pythonRelaxDepsHook
  ];
  pythonRelaxDeps = [
    "typing-extensions"
    "ruff"
    "msgspec"
  ];

  postInstall = ''
    rm $out/lib/python${python3.pythonVersion}/site-packages/beetsplug/__init__.py
    mv $out/lib/python${python3.pythonVersion}/site-packages/beetsplug/_utils \
       $out/lib/python${python3.pythonVersion}/site-packages/beetsplug/_vocadb_utils
    sed -i 's/from \._utils/from ._vocadb_utils/' \
      $out/lib/python${python3.pythonVersion}/site-packages/beetsplug/vocadb.py \
      $out/lib/python${python3.pythonVersion}/site-packages/beetsplug/utaitedb.py \
      $out/lib/python${python3.pythonVersion}/site-packages/beetsplug/touhoudb.py
  '';

  buildInputs = with python3.pkgs; [
    beets-minimal
    msgspec
    mutagen
    niquests
    ruff
    werapi.strip-markdown
    typing-extensions
  ];

  propagatedBuildInputs = with python3.pkgs; [
    msgspec
    mutagen
    niquests
    werapi.strip-markdown
    typing-extensions
  ];

  meta = {
    description = "Plugin for beets to use VocaDB, UtaiteDB and TouhouDB as an autotagger source";
    homepage = "https://github.com/prTopi/beets-vocadb/tree/experimental";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "beets-vocadb";
  };
}
