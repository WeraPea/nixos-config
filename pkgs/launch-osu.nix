{
  writeShellApplication,
  dotool,
  osu-scrobbler,
  ...
}:
writeShellApplication {
  name = "launch-osu";
  runtimeInputs = [
    dotool
    osu-scrobbler
  ];
  text = ''
    kitty -e osu-scrobbler &
    if [[ "$1" = "hack-build" ]]; then
      new_tag_name="$(curl -s "https://api.github.com/repos/ppy/osu/releases/latest" | jq -r '.name')"
      new_version="''${new_tag_name%-lazer}"
      if [[ "$2" != "" ]]; then
        hash=$2
      else
        prefetch_output=$(nix --extra-experimental-features nix-command store prefetch-file --json --hash-type sha256 "https://github.com/ppy/osu/releases/download/$new_tag_name/osu.AppImage")
        hash=$(jq -r '.hash' <<<"$prefetch_output")
        echo "hash = $hash"
      fi
      # copied from nixpkgs
      nix-build -E "with import <nixpkgs> {}; callPackage (
        {
          lib,
          appimageTools,
          fetchurl,
          makeWrapper,
          nativeWayland ? false,
        }:

        let
          pname = \"osu-lazer-bin\";
          version = \"$new_version\";
          src = fetchurl {
            url = \"https://github.com/ppy/osu/releases/download/\''${version}-lazer/osu.AppImage\";
            hash = \"$hash\";
          };
        in
        appimageTools.wrapType2 {
          inherit
            pname
            version
            src
            ;

          extraPkgs = pkgs: with pkgs; [ icu ];

          extraInstallCommands =
            let
              contents = appimageTools.extract { inherit pname version src; };
            in
            '''
              . \''${makeWrapper}/nix-support/setup-hook
              mv -v \$out/bin/\''${pname} \$out/bin/osu!

              wrapProgram \$out/bin/osu! \
                \''${lib.optionalString nativeWayland \"--set SDL_VIDEODRIVER wayland\"} \
                --set OSU_EXTERNAL_UPDATE_PROVIDER 1

              install -m 444 -D \''${contents}/osu!.desktop -t \$out/share/applications
              for i in 16 32 48 64 96 128 256 512 1024; do
                install -D \''${contents}/osu.png \$out/share/icons/hicolor/'''\''${i}x\$i/apps/osu.png
              done
            ''';
        }) { }" --impure -o ~/osu-lazer-bin-from-hack
      ~/osu-lazer-bin-from-hack/bin/osu! &
    elif [[ "$1" = "hack" ]]; then
      ~/osu-lazer-bin-from-hack/bin/osu! &
    else
      osu! &
    fi

    sleep 5
    mmsg -g | grep "$(mmsg -g -o | grep "selmon 1" | cut -d' ' -f1)" | grep "fullscreen 0" && mmsg -d togglefullscreen
    # navigates to settings->mouse->high precision input, double clicks it (fixes tablet input stopping to work if game changes fullscreen state), and then straight to solo beatmap selection, delay timing may be a bit tight
    dotoold &
    dotoolpid=$!
    sleep 0.1
    echo keydelay 100 | dotoolc
    echo type " s" | dotoolc
    echo type "precision" | dotoolc
    sleep 1.5
    echo mouseto 0.4727 0.4727 | dotoolc
    echo mouseto 0.4728 0.4728 | dotoolc
    echo click left | dotoolc
    sleep 0.2
    echo click left | dotoolc
    sleep 0.2
    echo key esc | dotoolc
    echo key esc | dotoolc
    echo type "  " | dotoolc
    sleep 1
    kill "$dotoolpid"
    wait
  '';
}
