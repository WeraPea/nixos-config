# only tested for usage of glensv2 and screenai
{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  python,

  pillow,
  requests,
  betterproto,
  protobuf,
}:
buildPythonPackage rec {
  pname = "meikipop";
  version = "1.10.2";

  src = fetchFromGitHub {
    owner = "rtr46";
    repo = "meikipop";
    rev = "v${version}";
    hash = "sha256-lkiyYuUni8VVyEPgviD5w2f+thodJP9I0YPaM7YjWXY=";
  };

  installPhase = ''
    mkdir -p $out/${python.sitePackages}/meikipop
    cp -r src/* $out/${python.sitePackages}/meikipop
  '';

  postPatch = ''
    for file in $(find src -type f -name "*.py"); do
      substituteInPlace "$file" \
        --replace "from src." "from meikipop." \
        --replace "import src." "import meikipop."
    done

    # disable japanese only filtering
    substituteInPlace src/ocr/providers/glensv2/provider.py \
      --replace-fail '                        if not line_has_japanese:' '                        # if not line_has_japanese:' \
      --replace-fail '                            continue' '                            # continue'

    substituteInPlace src/ocr/providers/screenai/provider.py \
      --replace-fail '            if not line_has_japanese:' '            # if not line_has_japanese:' \
      --replace-fail '                continue' '                # continue'
  '';

  format = false;
  doNotInstall = true;

  propagatedBuildInputs = [
    pillow
    requests
    betterproto
    protobuf
  ];

  meta = with lib; {
    description = "meikipop - universal japanese ocr popup dictionary for windows, linux and macos";
    homepage = "https://github.com/rtr46/meikipop";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
