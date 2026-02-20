{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  python,

  pillow,
  requests,
  betterproto,
}:
buildPythonPackage rec {
  pname = "glensv2";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "rtr46";
    repo = "meikipop";
    rev = "v${version}";
    hash = "sha256-zbpyf/1E45lsMp92Nli2V1r1dHxBZT+mL5lk2O4+mvU=";
  };

  installPhase = ''
    mkdir -p $out/${python.sitePackages}/glensv2
    cp -r src/* $out/${python.sitePackages}/glensv2
  '';

  postPatch = ''
    for file in $(find src -type f -name "*.py"); do
      substituteInPlace "$file" \
        --replace "from src." "from glensv2." \
        --replace "import src." "import glensv2."
    done

    # disable japanese only filtering
    substituteInPlace src/ocr/providers/glensv2/provider.py \
      --replace '                        if not line_has_japanese:' '                        # if not line_has_japanese:' \
      --replace '                            continue' '                            # continue'
  '';

  format = false;
  doNotInstall = true;

  propagatedBuildInputs = [
    pillow
    requests
    betterproto
  ];

  meta = with lib; {
    description = "Google Lens OCR v2 (glensv2) yoinked from Meikipop.";
    homepage = "https://github.com/rtr46/meikipop";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
