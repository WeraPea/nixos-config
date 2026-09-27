{
  python3,
  pythonOverrides ? { },
}:
python3.pkgs.callPackage (
  {
    lib,
    buildPythonPackage,
    fetchFromGitHub,
    setuptools,
    beets-minimal,
    nix-update-script,
  }:

  buildPythonPackage (finalAttrs: {
    pname = "beets-multivalue";
    version = "0-unstable-2026-03-11";
    pyproject = true;
    __structuredAttrs = true;

    src = fetchFromGitHub {
      owner = "Morikko";
      repo = "beets-multivalue";
      rev = "a8331513de63712c97a882453ba2e9e8f055bcdd";
      hash = "sha256-u9dr+kEC4qentrjQKoefZDX5Je55UiTfhyrvlzUEqxA=";
    };

    build-system = [
      setuptools
    ];

    buildInputs = [
      beets-minimal
    ];

    passthru.updateScript = nix-update-script { };

    meta = {
      description = "A beets plugin with a boosted modify command to add/remove values in multi-value tags";
      homepage = "https://github.com/Morikko/beets-multivalue";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ ];
    };
  })
) pythonOverrides
