final: prev: {
  monado = prev.monado.overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [
      (prev.lib.cmakeBool "XRT_HAVE_OPENCV" false)
    ];
    src = prev.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "monado";
      repo = "monado";
      rev = "e57d5411f53ab72e715b4ce91d26ff96c80ac711"; # https://gitlab.freedesktop.org/monado/monado/-/merge_requests/2425?diff_id=5029493
      hash = "sha256-lXLSE1WwyoN2dU5OrhMKho+xreJZjAnnOUhSA3lRVOs=";
    };
  });
}
