{
  writers,
  python3Packages,
}:
writers.writePython3Bin "listenbrainz-manual-submit"
  {
    libraries = [
      python3Packages.requests
      python3Packages.mutagen
    ];
    doCheck = false;
  }
  /* python */ ''
    # logic taken from listenbrainz-mpd
    import argparse, os, re, sys, time
    from datetime import datetime, timezone
    import requests
    from mutagen import File as MutagenFile

    API_URL = os.environ.get("LISTENBRAINZ_API_URL", "https://api.listenbrainz.org")
    SUBMIT_PATH = "/1/submit-listens"

    MBID_RE = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", re.I)
    MAX_TAGS = 50
    MAX_TAG_LEN = 64

    def get1(tags, *keys):
        for k in keys:
            v = tags.get(k)
            if v:
                return str(v[0])
        return None

    def getlist(tags, *keys):
        for k in keys:
            v = tags.get(k)
            if v:
                return [str(x) for x in v]
        return []

    def valid_mbid(m):
        return bool(m and MBID_RE.match(m))

    def concat_artists(names):
        if len(names) == 1:
            return names[0]
        return ", ".join(names[:-1]) + f" & {names[-1]}"

    def build_track_metadata(tags, duration_s, genre_separator=None):
        title = get1(tags, "title", "TITLE")
        if not title:
            sys.exit("file has no title tag")

        artist_names = getlist(tags, "artist", "ARTIST")
        if not artist_names:
            sys.exit("file has no artist tag")
        artist_name = concat_artists(artist_names)

        release_name = get1(tags, "album", "ALBUM")

        artist_mbids = [m for m in getlist(tags, "musicbrainz_artistid", "MUSICBRAINZ_ARTISTID") if valid_mbid(m)]
        release_mbid = get1(tags, "musicbrainz_albumid", "MUSICBRAINZ_ALBUMID")
        if not valid_mbid(release_mbid):
            release_mbid = None
        recording_mbid = get1(tags, "musicbrainz_trackid", "MUSICBRAINZ_TRACKID")
        if not valid_mbid(recording_mbid):
            recording_mbid = None
        track_mbid = get1(tags, "musicbrainz_releasetrackid", "MUSICBRAINZ_RELEASETRACKID")
        if not valid_mbid(track_mbid):
            track_mbid = None
        work_mbids = [m for m in getlist(tags, "musicbrainz_workid", "MUSICBRAINZ_WORKID") if valid_mbid(m)]

        tracknumber = get1(tags, "tracknumber", "TRACKNUMBER")

        genres = getlist(tags, "genre", "GENRE")
        if genre_separator:
            split = []
            for g in genres:
                split.extend(p.strip() for p in g.split(genre_separator) if p.strip())
            genres = split
        genres = [g for g in genres if len(g) < MAX_TAG_LEN][:MAX_TAGS]

        additional_info = {
            "media_player": "manual-submit",
            "submission_client": "listenbrainz-manual-submit",
            "submission_client_version": "0.1",
        }
        if artist_mbids: additional_info["artist_mbids"] = artist_mbids
        if artist_names: additional_info["artist_names"] = artist_names
        if release_mbid: additional_info["release_mbid"] = release_mbid
        if recording_mbid: additional_info["recording_mbid"] = recording_mbid
        if track_mbid: additional_info["track_mbid"] = track_mbid
        if work_mbids: additional_info["work_mbids"] = work_mbids
        if tracknumber: additional_info["tracknumber"] = tracknumber
        if duration_s and duration_s > 0:
            additional_info["duration_ms"] = int(duration_s * 1000)
        if genres: additional_info["tags"] = genres

        meta = {"artist_name": artist_name, "track_name": title, "additional_info": additional_info}
        if release_name: meta["release_name"] = release_name
        return meta

    def submit(payload, token):
        headers = {"Authorization": f"Token {token}", "Content-Type": "application/json"}
        while True:
            r = requests.post(API_URL + SUBMIT_PATH, json=payload, headers=headers, timeout=30)
            if r.status_code == 200:
                return
            if r.status_code == 429:
                wait = int(r.headers.get("X-RateLimit-Reset-In", "10"))
                print(f"rate limited, sleeping {wait}s", file=sys.stderr)
                time.sleep(wait)
                continue
            r.raise_for_status()

    def resolve_token(args) -> str:
        token = os.environ.get("LISTENBRAINZ_TOKEN")
        if token:
            return token.strip()

        token_file = args.token_file or os.environ.get("LISTENBRAINZ_TOKEN_FILE")
        if token_file:
            try:
                with open(token_file) as f:
                    return f.read().strip()
            except OSError as e:
                sys.exit(f"couldn't read --token-file {token_file}: {e}")

        sys.exit("no token: set LISTENBRAINZ_TOKEN or pass --token-file")

    def main():
        ap = argparse.ArgumentParser()
        ap.add_argument("file")
        ap.add_argument("--timestamp", type=int, default=None, help="unix ts, defaults to now")
        ap.add_argument("--no-timestamp-minus", action="store_true", help="should song duration be subtracted from the timestamp (default is true)")
        ap.add_argument("--genre-separator", default=None)
        ap.add_argument("--token-file", default=None)
        args = ap.parse_args()

        f = MutagenFile(args.file, easy=True)
        if f is None:
            sys.exit(f"couldn't read tags from {args.file}")

        tags = f.tags or {}
        duration = getattr(f.info, "length", None)

        meta = build_track_metadata(tags, duration, args.genre_separator)
        ts = args.timestamp or int(datetime.now(timezone.utc).timestamp())
        if not args.no_timestamp_minus and duration:
            ts -= int(duration)

        payload = {"listen_type": "single", "payload": [{"listened_at": ts, "track_metadata": meta}]}

        token=resolve_token(args)
        submit(payload, token)
        print(f"submitted: {meta['artist_name']} - {meta['track_name']}")

    if __name__ == "__main__":
        main()''
