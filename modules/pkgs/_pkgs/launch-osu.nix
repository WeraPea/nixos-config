{
  writeShellApplication,
  werapi,
  opentabletdriver,
  ...
}:
writeShellApplication {
  name = "launch-osu";
  runtimeInputs = [
    werapi.osu-scrobbler
  ];
  text = ''
    export OSU_SCROBBLER_CONFIG_PATH=$HOME/.config/osu-scrobbler/config.toml
    kitty -e osu-scrobbler &
    if [[ "$1" = "hack-build" ]]; then
      new_tag_name="$(curl -s "https://api.github.com/repos/ppy/osu/releases/latest" | jq -r '.name')"
      new_version="''${new_tag_name%-lazer}"
      if [[ "''${2:-}" != "" ]]; then
        hash=$2
      else
        prefetch_output=$(nix --extra-experimental-features nix-command store prefetch-file --json --hash-type sha256 "https://github.com/ppy/osu/releases/download/$new_tag_name/osu.AppImage")
        hash=$(jq -r '.hash' <<<"$prefetch_output")
        echo "hash = $hash"
      fi
      # copied from nixpkgs + otd patched
      nix-build -E "with import <nixpkgs> {}; callPackage (
        {
          lib,
          appimageTools,
          fetchurl,
          makeWrapper,
          runCommand,
          nativeWayland ? false,
        }:

        let
          pname = \"osu-lazer-bin\";
          version = \"$new_version\";
          src = fetchurl {
            url = \"https://github.com/ppy/osu/releases/download/\''${version}-lazer/osu.AppImage\";
            hash = \"$hash\";
          };
          otd = builtins.storePath \"${opentabletdriver}\";
          extracted = appimageTools.extract { inherit pname version src; };
          patched = runCommand \"osu-lazer-bin-patched-\''${version}\" { } '''
            cp -r \''${extracted} \$out
            chmod -R u+w \$out
            for f in \$out/usr/bin/OpenTabletDriver*.dll \$out/usr/bin/HidSharpCore.dll; do
              new=\''${otd}/lib/OpenTabletDriver/\$(basename \$f)
              if [ -e \$new ]; then
                install -m 644 \$new \$f
              else
                echo \"missing \$new\" >&2
              fi
            done
          ''';
        in
        appimageTools.wrapAppImage {
          inherit
            pname
            version
            ;
          src = patched;

          extraPkgs = pkgs: with pkgs; [ icu ];

          extraInstallCommands =
            let
              contents = patched;
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
  '';
}
