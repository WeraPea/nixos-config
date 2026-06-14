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
    wheel,
    beautifulsoup4,
    build,
    flake8,
    markdown,
    nix-update-script,
  }:

  buildPythonPackage (finalAttrs: {
    pname = "strip-markdown";
    version = "1.3";
    pyproject = true;
    __structuredAttrs = true;

    src = fetchFromGitHub {
      owner = "D3r3k23";
      repo = "strip_markdown";
      tag = "v${finalAttrs.version}";
      hash = "sha256-Do0dUhe4xBeH3PY5dGksH4kwb7ubBCf9uP3/QOLBy2I=";
    };

    build-system = [
      setuptools
      wheel
    ];

    dependencies = [
      beautifulsoup4
      build
      flake8
      markdown
    ];

    pythonImportsCheck = [
      "strip_markdown"
    ];

    passthru.updateScript = nix-update-script { };

    meta = {
      description = "Converts markdown to plain text";
      homepage = "https://github.com/D3r3k23/strip_markdown";
      changelog = "https://github.com/D3r3k23/strip_markdown/releases/tag/${finalAttrs.src.tag}";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ ];
    };
  })
) pythonOverrides
