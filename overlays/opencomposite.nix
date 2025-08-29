final: prev: {
  # fixes controllers in No Man's Sky and more
  opencomposite-priorities = prev.opencomposite.overrideAttrs (old: {
    src = prev.fetchFromGitLab {
      fetchSubmodules = true;
      owner = "OrionMoonclaw";
      repo = "OpenOVR";
      rev = "81d4363a6533276d4726f2191d7a30835faf60d1"; # https://gitlab.com/OrionMoonclaw/OpenOVR/-/tree/81d4363a6533276d4726f2191d7a30835faf60d1/      hash = "sha256-Td18yRpwxnM9ir2fB2RRijsYdeSW48zXojNivAkgaeA=";
      hash = "sha256-Td18yRpwxnM9ir2fB2RRijsYdeSW48zXojNivAkgaeA=";
    };
  });
}
