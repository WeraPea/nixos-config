final: prev: {
  opentabletdriver = prev.opentabletdriver.overrideAttrs (old: {
    src = final.fetchFromGitHub {
      owner = "WeraPea";
      repo = "OpenTabletDriver";
      rev = "db6a6a31418d5fd15a473cc2ec095af800e0c44f";
      hash = "sha256-bXcat3uLZt5jtluAQ39CiI/uwpfUHcOuktYVCUy+cRU=";
    };
  });
}
