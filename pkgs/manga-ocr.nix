{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "manga-ocr";
  version = "0.1.14";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kha-white";
    repo = "manga-ocr";
    rev = "v${version}";
    hash = "sha256-fCLgFeo6GYPSpCX229TK2MXTKt3p1tQV06phZYD6UeE=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.setuptools-scm
  ];

  dependencies = with python3.pkgs; [
    fire
    fugashi
    jaconv
    loguru
    numpy
    pillow
    pyperclip
    torch
    transformers
    unidic-lite
  ];

  optional-dependencies = with python3.pkgs; {
    dev = [
      pytest
      ruff
    ];
  };

  pythonImportsCheck = [
    "manga_ocr"
  ];

  meta = {
    description = "Optical character recognition for Japanese text, with the main focus being Japanese manga";
    homepage = "https://github.com/kha-white/manga-ocr";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "manga-ocr";
  };
}
