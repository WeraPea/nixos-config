{
  lib,
  blender,
  python3Packages,
  pkgs,
  fetchurl,
}:

let
  py-slvs = python3Packages.buildPythonPackage rec {
    pname = "py-slvs";
    version = "1.0.6";

    src = python3Packages.fetchPypi {
      pname = "py_slvs";
      version = "1.0.6";
      sha256 = "sha256-U6T/aXy0JTC1ptL5oBmch0ytSPmIkRA8XOi31NpArnI=";
    };

    pyproject = true;

    nativeBuildInputs = with pkgs; [ swig ];

    propagatedBuildInputs = with python3Packages; [
      cmake
      ninja
      setuptools
      scikit-build
    ];

    dontUseCmakeConfigure = true;

    meta = with pkgs.lib; {
      description = "Python binding of SOLVESPACE geometry constraint solver";
      homepage = "https://github.com/realthunder/slvs_py";
      license = licenses.gpl3;
    };
  };

  blenderWithPySlvs = pkgs.blender-hip.withPackages (p: [ py-slvs ]);
in
blenderWithPySlvs
