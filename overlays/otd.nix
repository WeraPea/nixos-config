final: prev: {
  opentabletdriver = prev.opentabletdriver.overrideAttrs (old: {
    src = final.fetchFromGitHub {
      owner = "WeraPea";
      repo = "OpenTabletDriver";
      rev = "7635b073f6da3e2bb976765f93fab40f10b4483d";
      hash = "sha256-rnrYrkzCtjhvFemMT3n0lBz/BE5upc7KU7xASKxVH3I=";
    };
  });
}
