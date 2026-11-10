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
    requests,
  }:

  buildPythonPackage (finalAttrs: {
    pname = "beets-getlrc";
    version = "0.1.15";
    pyproject = true;
    __structuredAttrs = true;

    src = fetchFromGitHub {
      owner = "jaedonswanson";
      repo = "beets-getlrc";
      tag = "v${finalAttrs.version}";
      hash = "sha256-OVZcBSN3S2VCST+HJvTdJKzPtrmo1sPfEmfVDpFnXtw=";
    };

    build-system = [
      setuptools
    ];

    buildInputs = [
      beets-minimal
    ];

    dependencies = [
      requests
    ];

    meta = {
      description = "A beets plugin that downloads synced (and non-synced) .lrc lyric files for your music library.";
      homepage = "https://github.com/jaedonswanson/beets-getlrc";
      license = lib.licenses.unfree; # not specified
    };
  })
) pythonOverrides
