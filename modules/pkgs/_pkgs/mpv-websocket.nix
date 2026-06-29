{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "mpv-websocket";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "kuroahna";
    repo = "mpv_websocket";
    rev = version;
    hash = "sha256-UIfz9WwH3hFRs84N5+27ttPhksKC45lkVa+X7Qlwg0o=";
  };

  cargoHash = "sha256-k8YCjgPrpfuzRtVI9yDqgsWXf/ryuFZ151NyrL4BmgE=";

  meta = {
    description = "A WebSocket plugin for mpv";
    homepage = "https://github.com/kuroahna/mpv_websocket";
    changelog = "https://github.com/kuroahna/mpv_websocket/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "mpv-websocket";
  };
}
