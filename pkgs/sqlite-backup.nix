{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  click,
  logzero,
  flake8,
  mypy,
  pytest,
  pytest-reraise,
}:

buildPythonPackage rec {
  pname = "sqlite-backup";
  version = "0.1.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "purarue";
    repo = "sqlite_backup";
    rev = "v${version}";
    hash = "sha256-e/IkHOZ1TzQN2gTOA7+t56rjWI8BwzGozeRigi8CjH8=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    click
    logzero
  ];

  optional-dependencies = {
    testing = [
      flake8
      mypy
      pytest
      pytest-reraise
    ];
  };

  pythonImportsCheck = [
    "sqlite_backup"
  ];

  meta = {
    description = "A tool to snapshot sqlite databases you don't own";
    homepage = "https://github.com/purarue/sqlite_backup";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
