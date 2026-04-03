{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatch-fancy-pypi-readme,
  hatchling,
  httpx,
}:

buildPythonPackage (finalAttrs: {
  pname = "httpx-retries";
  version = "0.4.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "will-ockmore";
    repo = "httpx-retries";
    tag = finalAttrs.version;
    hash = "sha256-zJ3ExSEWxlHFluSdYA8/XZ3zb4KBelU+IOFyUu4ezvo=";
  };

  build-system = [
    hatch-fancy-pypi-readme
    hatchling
  ];

  dependencies = [
    httpx
  ];

  pythonImportsCheck = [
    "httpx_retries"
  ];

  meta = {
    description = "A retry layer for HTTPX";
    homepage = "https://github.com/will-ockmore/httpx-retries";
    changelog = "https://github.com/will-ockmore/httpx-retries/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
