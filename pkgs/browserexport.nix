{
  lib,
  python3,
  fetchFromGitHub,
  kompress,
  sqlite-backup,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "browserexport";
  version = "0.4.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "purarue";
    repo = "browserexport";
    rev = "v${version}";
    hash = "sha256-RDT6NcKdgDFexHpE3/BY1dpHKfFHZbvCyv/nGn4A7cY=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    click
    kompress
    logzero
    sqlite-backup
    ipython
  ];

  optional-dependencies = with python3.pkgs; {
    testing = [
      flake8
      mypy
      pytest
    ];
  };

  pythonImportsCheck = [
    "browserexport"
  ];

  meta = {
    description = "Backup and parse your browser history databases (chrome, firefox, safari, and other chrome/firefox derivatives";
    homepage = "https://github.com/purarue/browserexport";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "browserexport";
  };
}
