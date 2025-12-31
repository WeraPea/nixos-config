final: prev: {
  opentabletdriver = prev.opentabletdriver.overrideAttrs (old: {
    src = final.fetchFromGitHub {
      owner = "WeraPea";
      repo = "OpenTabletDriver";
      rev = "a5ced396059003dff0379984bab1810383204020";
      hash = "sha256-DvE9LLAWcnUDg9PylLeruNw5/5X0jS1D1RCCZ/4RJ+Y=";
    };
  });
}
