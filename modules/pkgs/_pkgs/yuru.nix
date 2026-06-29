{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  fetchurl,
  jq,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "yuru";
  version = "0.1.10";
  __structuredAttrs = true;

  ipadic-src = fetchurl {
    url = "https://Lindera.dev/mecab-ipadic-2.7.0-20250920.tar.gz";
    hash = "sha256-p7qfZF/+cJTlauHEqB0QDfj7seKLvheSYi6XKOFi2z0=";
  };

  src = fetchFromGitHub {
    owner = "Ameyanagi";
    repo = "yuru";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uf1AFdRSYxAgMHb7Q/8psiMZW4ktiTMfD9Ni3C4fCMU=";
  };

  cargoHash = "sha256-+6lv9fqt/BbWPFNRUDuCLMliiZfyfxepSH4KGOd4fZI=";

  preBuild = ''
    export LINDERA_DICTIONARIES_PATH=$TMPDIR/lindera-cache
    LINDERA_IPADIC_VERSION=$(cargo metadata --format-version 1 | ${lib.getExe jq} -r '.packages[] | select(.name=="lindera-ipadic") | .version')
    mkdir -p "$LINDERA_DICTIONARIES_PATH/$LINDERA_IPADIC_VERSION"
    cp ${finalAttrs.ipadic-src} "$LINDERA_DICTIONARIES_PATH/$LINDERA_IPADIC_VERSION/mecab-ipadic-2.7.0-20250920.tar.gz"
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast CJK-aware fuzzy finder with Japanese romaji and Chinese pinyin search";
    homepage = "https://github.com/Ameyanagi/yuru";
    changelog = "https://github.com/Ameyanagi/yuru/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "yuru";
  };
})
