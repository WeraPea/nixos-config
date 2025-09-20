final: prev: {
  opentabletdriver = prev.opentabletdriver.overrideAttrs (old: {
    src = final.fetchFromGitHub {
      owner = "WeraPea";
      repo = "OpenTabletDriver";
      rev = "863b78041e25efcb7b4bde69175f4e03ee02a642";
      hash = "sha256-GB0Dzvw80W1Jo03J4x3gkPimD58cnUlTCOqh8u1kKu4=";
    };
  });
}
