{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatch-vcs,
  hatchling,
  typing-extensions,
  lz4,
  zstandard,
}:

buildPythonPackage rec {
  pname = "kompress";
  version = "0.3.20241214";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "karlicoss";
    repo = "kompress";
    rev = "v${version}";
    hash = "sha256-9RADSAnOr8GOLv7VJUDNumpe+8Lxu3r8g1/DEiqXshA=";
  };

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    typing-extensions
  ];

  optional-dependencies = {
    lz4 = [
      lz4
    ];
    zstd = [
      zstandard
    ];
  };

  pythonImportsCheck = [
    "kompress"
  ];

  meta = {
    description = "Helper to allow accessing compressed files/directories via pathlib.Path";
    homepage = "https://github.com/karlicoss/kompress";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
