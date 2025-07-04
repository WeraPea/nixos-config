final: prev: {
  waybar = prev.waybar.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./waybar.patch # add titleRaw and artistRaw for tooltip formating
    ];
  });
}
