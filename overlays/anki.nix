final: prev: {
  anki = prev.anki.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./i18n.patch # https://github.com/NixOS/nixpkgs/pull/437041
    ];
  });
}
