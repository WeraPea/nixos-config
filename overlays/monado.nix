final: prev: {
  monado-custom = prev.monado.overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [
      (prev.lib.cmakeBool "XRT_HAVE_OPENCV" false)
    ];
    src = final.fetchFromGitHub {
      owner = "ToasterUwU";
      repo = "monado";
      rev = "8f85280c406ce2e23939c58bc925cf939f36e1e8";
      hash = "sha256-ZeSmnAZ2gDiLTdlVAKQeS3cc6fcRBcSjYZf/M6eI8j4=";
    };
    patches = [];
  });
}
