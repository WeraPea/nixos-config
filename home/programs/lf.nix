{ pkgs, ... }:
{
  home.packages = [
    pkgs.pistol
    pkgs.ffmpegthumbnailer
    pkgs.file
  ];
  xdg.configFile."lf/icons".source = ./lf-icons;
  programs.lf = {
    enable = true;
    keybindings = {
      D = "trash";
      U = "!du -sh";
    };
    settings = {
      hidden = true;
      icons = true;
    };
    previewer.source =
      let
        vidthumb = pkgs.writeShellScript "vidthumb" ''

          if ! [ -f "$1" ]; then
              exit 1
          fi

          cache="$HOME/.cache/vidthumb"
          index="$cache/index.json"
          movie="$(realpath "$1")"

          mkdir -p "$cache"

          if [ -f "$index" ]; then
              thumbnail="$(jq -r ". \"$movie\"" <"$index")"
              if [[ "$thumbnail" != "null" ]]; then
                  if [[ ! -f "$cache/$thumbnail" ]]; then
                      exit 1
                  fi
                  echo "$cache/$thumbnail"
                  exit 0
              fi
          fi

          thumbnail="$(uuidgen).jpg"

          if ! ffmpegthumbnailer -i "$movie" -o "$cache/$thumbnail" -s 0 2>/dev/null; then
              exit 1
          fi

          if [[ ! -f "$index" ]]; then
              echo "{\"$movie\": \"$thumbnail\"}" >"$index"
          fi
          json="$(jq -r --arg "$movie" "$thumbnail" ". + {\"$movie\": \"$thumbnail\"}" <"$index")"
          echo "$json" >"$index"

          echo "$cache/$thumbnail"
        '';
        ltKittyPreview = pkgs.writeShellScript "lf_kitty_preview.sh" ''
          file=$1
          w=$2
          h=$3
          x=$4
          y=$5

          filetype="$( file -Lb --mime-type "$file")"

          if [[ "$filetype" =~ ^image ]]; then
              kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file" < /dev/null > /dev/tty
              exit 1
          fi

          if [[ "$filetype" =~ ^video ]]; then
              kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$(${vidthumb} "$file")" < /dev/null > /dev/tty
              exit 1
          fi

          pistol "$file"
        '';
      in
      ltKittyPreview;
    extraConfig = ''
      set cleaner ${pkgs.writeShellScript "lf_kitty_clean.sh" ''

        kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
      ''}
    '';
  };
}
