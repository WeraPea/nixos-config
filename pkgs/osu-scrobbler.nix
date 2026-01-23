{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "osu-scrobbler";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "flazepe";
    repo = "osu-scrobbler";
    rev = "v${version}";
    hash = "sha256-bf6xNoUEJASIVhp2KvbDfuWOSSx0nOXKGDML72hXn90=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  cargoLock = {
    lockFile = ./osu-scrobbler-Cargo.lock;
  };

  postPatch = ''
    ln -s ${./osu-scrobbler-Cargo.lock} Cargo.lock
  '';

  meta = {
    description = "An osu! Last.fm and ListenBrainz scrobbler";
    homepage = "https://github.com/flazepe/osu-scrobbler";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "osu-scrobbler";
  };
}
