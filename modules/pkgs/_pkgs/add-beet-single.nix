{
  bashInteractive,
  ffmpeg,
  lib,
  makeWrapper,
  mkvtoolnix-cli,
  stdenv,
  werapi,
}:
stdenv.mkDerivation {
  pname = "add-beet-single";
  version = "1.0";

  src = builtins.toFile "add-beet-single.sh" /* bash */ ''
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob dotglob

    cd /mnt/mnt3/youtube/archive/
    url=""
    beet=""
    beet_skip=""

    while [[ $# -gt 0 ]]; do
      case "$1" in
      --beet | -b)
        beet="yes"
        shift
        ;;
      --beet-skip | -bs)
        beet_skip="yes"
        shift
        ;;
      -*)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
      *)
        url="$1"
        shift
        ;;
      esac
    done
    [[ -z "$url" ]] && {
      echo "Usage: $0 [--beet,--beet-skip] <video_url>"
      exit 1
    }

    histfile=~/.add-beet-single_history
    [[ -f "$histfile" ]] || touch "$histfile"
    history -r "$histfile"

    downloaded_archive_main="download-archive-main"
    download_archive_srv3="download-archive-srv3"
    converted_archive="converted-srv3"
    merged_archive="mkv-merged"
    video_store="video_store"

    hi=$(tput setaf 6)$(tput bold)
    r=$(tput sgr0)

    retry_yt_dlp() {
      while true; do
        yt-dlp "$@" && return 0
        read -erp "Retry? (''${hi}Y''${r}/n): " ans
        history -s "$ans"
        history -a "$histfile"
        ans="''${ans,,}"
        if [[ ! ( -z "$ans" || "$ans" == "y" ) ]]; then
          exit 1
        fi
      done
    }

    args=(
      --embed-chapters
      --embed-metadata
      --embed-thumbnail
      --embed-info-json
      --download-archive ./"$downloaded_archive_main"
      --no-post-overwrites
      -N 5
      --write-description
      --merge-output-format mkv
      --remux-video mkv
      --write-subs
      --write-link
      --sub-langs all,-live_chat
      --embed-subs
      --sponsorblock-mark all
      --output "$video_store/%(id)s/%(title).200B [%(id)s].%(ext)s"
      --compat-options no-youtube-unavailable-videos
    )

    retry_yt_dlp "''${args[@]}" "$url" # retries probably only needed here and not elsewhere

    args=(
      --download-archive ./"$download_archive_srv3"
      --no-post-overwrites
      --force-write-archive
      -N 5
      --skip-download
      --write-subs
      --sub-langs all,-live_chat
      --sub-format srv3
      --output "$video_store/%(id)s/%(title).200B [%(id)s].%(ext)s"
      --compat-options no-youtube-unavailable-videos
    )

    retry_yt_dlp "''${args[@]}" "$url"

    id=$(retry_yt_dlp --print "%(id)s" --skip-download "$url")
    video_dir=$video_store/$id

    function vid-convert() {
      mkv_files=("$video_dir"/*.mkv)
      srv3_files=("$video_dir"/*.srv3)

      [[ ''${#mkv_files[@]} -eq 0 || ''${#srv3_files[@]} -eq 0 ]] && return
      [[ -f "$merged_archive" ]] && grep -Fxq "$video_dir" "$merged_archive" && return

      srv3_files=("$video_dir"/*.srv3)
      for sub in "''${srv3_files[@]}"; do
        [[ -f "$converted_archive" ]] && grep -Fxq "$sub" "$converted_archive" && return
        YTSubConverter "$sub" &&
          echo "$sub" >>"$converted_archive"
      done

      mkv_file=("$video_dir"/*.mkv)
      [[ ! -f "''${mkv_file[0]}" ]] && return
      mkv="''${mkv_file[0]}"
      base="''${mkv%.mkv}"

      ass_subs=()
      for sub in "$base".*.ass; do
        ass_subs+=("$sub")
      done

      if [[ ''${#ass_subs[@]} -eq 0 ]]; then
        echo "$video_dir" >>"$merged_archive"
        return
      fi

      temp_mkv="''${base}.temp.mkv"
      args=(-o "$temp_mkv" "$mkv")

      for sub in "''${ass_subs[@]}"; do
        lang_code="''${sub##*.}"
        args+=("--language" "0:''${lang_code}" "--track-name" "0:''${lang_code}" "$sub")
      done

      echo "''${args[@]}"
      if mkvmerge "''${args[@]}"; then
        mv "$temp_mkv" "$mkv"
        echo "$video_dir" >>"$merged_archive"
      else
        echo "Failed to merge subs into $mkv"
        rm -f "$temp_mkv"
      fi
    }
    vid-convert

    audio_archive="./audio-archive"
    audio_dir="./manual-audio"
    mkdir -p "$audio_dir"

    file=$(printf '%s' ./"$video_store/$id"/*.mkv)
    base_name="$(basename "''${file%.mkv}")"
    out_file="$audio_dir/''${base_name}.opus"

    function audio-convert() {
      [[ -e "$out_file" ]] && return
      codec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name \
        -of default=noprint_wrappers=1:nokey=1 "$file")

      [[ -f "$audio_archive" ]] && grep -Fxq "$id" "$audio_archive" && return

      echo "$file ($codec)"

      if [[ "$codec" == "opus" ]]; then
        ffmpeg -i "$file" -vn -c:a copy "$out_file"
      else
        ffmpeg -i "$file" -vn -c:a libopus -ar 48000 -ac 2 "$out_file"
      fi

      echo "$id" >>"$audio_archive"
    }
    audio-convert

    if [[ -z "$beet" ]]; then
      exit
    fi

    purl=$(retry_yt_dlp --print "%(webpage_url)s" --skip-download "$url")

    if [[ ! ( -n "$beet_skip" || -n "$(beet ls purl:"$purl")" ) ]]; then
      beet import -st --set=purl="$purl" "$out_file"
    fi
    while true; do
      read -erp "''${hi}→''${r} ''${hi}D''${r}one, rerun ''${hi}[B]''${r}eet, ''${hi}R''${r}etag, enter ''${hi}V''${r}ocadb id, enter ''${hi}U''${r}taitedb id, ''${hi}T''${r}ouhoudb id, ''${hi}P''${r}rint beet path, ''${hi}E''${r}dit, ''${hi}S''${r}ubmit listen, ''${hi}A''${r}dd another? " ans
      history -s "$ans"
      history -a "$histfile"
      org_ans="$ans"
      ans="''${ans,,}"

      case "$ans" in
      d) break ;;
      b | "") beet import -st --set=purl="$purl" "$out_file" ;;
      r) beet import -st -L purl:"$purl" ;;
      v)
        read -erp "vocadb_track_id: " vocadb_track_id
        history -s "$vocadb_track_id"
        history -a "$histfile"
        if [[ -n "$vocadb_track_id" ]]; then
          beet mod -M purl:"$purl" data_source=VocaDB vocadb_track_id="$vocadb_track_id"
          beet vdbsync -m purl:"$purl"
        fi
        ;;
      u)
        read -erp "utaitedb_track_id: " utaitedb_track_id
        history -s "$utaitedb_track_id"
        history -a "$histfile"
        if [[ -n "$utaitedb_track_id" ]]; then
          beet mod -M purl:"$purl" data_source=UtaiteDB utaitedb_track_id="$utaitedb_track_id"
          beet udbsync -m purl:"$purl"
        fi
        ;;
      t)
        read -erp "touhoudb_track_id: " touhoudb_track_id
        history -s "$touhoudb_track_id"
        history -a "$histfile"
        if [[ -n "$touhoudb_track_id" ]]; then
          beet mod -M purl:"$purl" data_source=TouhouDB touhoudb_track_id="$touhoudb_track_id"
          beet tdbsync -m purl:"$purl"
        fi
        ;;
      https://vocadb.net/s/*)
        vocadb_track_id=''${ans#https://vocadb.net/s/}
        beet mod -M purl:"$purl" data_source=VocaDB vocadb_track_id="$vocadb_track_id"
        beet vdbsync -m purl:"$purl"
        ;;
      https://utaitedb.net/s/*)
        utaitedb_track_id=''${ans#https://utaitedb.net/s/}
        beet mod -M purl:"$purl" data_source=UtaiteDB utaitedb_track_id="$utaitedb_track_id"
        beet udbsync -m purl:"$purl"
        ;;
      https://touhoudb.com/s/*)
        touhoudb_track_id=''${ans#https://touhoudb.com/s/}
        beet mod -M purl:"$purl" data_source=TouhouDB touhoudb_track_id="$touhoudb_track_id"
        beet tdbsync -m purl:"$purl"
        ;;
      p) beet list purl:"$purl" ;;
      e) beet edit --all purl:"$purl" ;;
      s)
        listenbrainz-manual-submit "$(beet ls purl:"$purl" -f '$path')"
        ;;
      a)
        read -erp "url: " url
        history -s "$url"
        history -a "$histfile"
        args=("$url")
        [[ -n "$beet" ]] && args+=("-b")
        [[ -n "$beet_skip" ]] && args+=("-bs")
        exec "$0" "''${args[@]}"
        ;;
      https://*)
        args=("$org_ans")
        [[ -n "$beet" ]] && args+=("-b")
        [[ -n "$beet_skip" ]] && args+=("-bs")
        exec "$0" "''${args[@]}"
        ;;
      esac
    done
  '';

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    install -m755 $src $out/bin/add-beet-single
    substituteInPlace $out/bin/add-beet-single \
      --replace-fail "#!/usr/bin/env bash" "#!${bashInteractive}/bin/bash"
    wrapProgram $out/bin/add-beet-single \
      --prefix PATH : ${
        lib.makeBinPath [
          werapi.yt-sub-converter
          ffmpeg
          mkvtoolnix-cli
          # rest omitted on purpose
        ]
      }
  '';

  meta = {
    mainProgram = "add-beet-single";
    platforms = lib.platforms.linux;
  };
}
