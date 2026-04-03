{
  lib,
  writers,
  imagemagick,
  screenshot,
  ankiUrl ? "http://127.0.0.1:8765",
  ankiField ? "Picture",
  maxHeight ? 480,
}:
writers.writePython3Bin "anki-helper"
  {
    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      "${lib.makeBinPath [
        imagemagick
        screenshot
      ]}"
    ];
  }
  ''
    import json
    import subprocess
    import sys
    import tempfile
    import urllib.request
    import time
    from pathlib import Path
    import base64

    ANKI_URL = "${ankiUrl}"
    FIELD = "${ankiField}"
    MAX_HEIGHT = ${toString maxHeight}


    def anki(action, **params):
        req = json.dumps(
            {"action": action, "version": 6, "params": params}
        ).encode()
        res = json.load(
            urllib.request.urlopen(urllib.request.Request(ANKI_URL, req))
        )
        if res.get("error"):
            print(f"anki error: {res['error']}", file=sys.stderr)
            sys.exit(1)
        return res["result"]


    def main():
        args = sys.argv[1:]
        screenshot_arg = ""

        if args and args[0] == "show":
            ids = anki("findNotes", query="added:2")
            note_id = max(ids) if ids else None
            if note_id:
                anki("guiBrowse", query=f"nid:{note_id}")
            return

        if args and args[0] == "print":
            field = args[1] if len(args) > 1 else None
            if not field:
                return
            ids = anki("findNotes", query="added:2")
            note_id = max(ids) if ids else None
            if note_id:
                info = anki("notesInfo", notes=[note_id])[0]
                if field in info["fields"]:
                    print(info["fields"][field]["value"])
                else:
                    print(
                        f"field '{field}' not found"
                        f" (model: {info['modelName']})",
                        file=sys.stderr,
                    )
                    sys.exit(1)
            return

        if args:
            screenshot_arg = args[0]

        ids = anki("findNotes", query="added:2")
        if not ids:
            print("no notes added in last 2 days", file=sys.stderr)
            sys.exit(1)
        note_id = max(ids)

        info = anki("notesInfo", notes=[note_id])[0]
        if FIELD not in info["fields"]:
            print(
                f"field '{FIELD}' not found on note {note_id}"
                f" (model: {info['modelName']})",
                file=sys.stderr,
            )
            sys.exit(1)

        with tempfile.TemporaryDirectory() as tmp:
            raw = Path(tmp) / "screen.png"
            result = subprocess.run(
                ["screenshot", screenshot_arg, str(raw)],
                capture_output=True,
            )

            if result.returncode != 0:
                print("screenshot failed", file=sys.stderr)
                sys.exit(1)

            scaled = Path(tmp) / "scaled.png"
            result = subprocess.run(
                ["convert", str(raw), "-resize", f"x{MAX_HEIGHT}>", str(scaled)],
                capture_output=True,
            )
            if result.returncode != 0:
                print("imagemagick convert failed", file=sys.stderr)
                sys.exit(1)

            filename = f"ankiclip_{note_id}_{round(time.time())}.png"
            anki(
                "storeMediaFile",
                filename=filename,
                data=base64.b64encode(scaled.read_bytes()).decode(),
            )

        anki(
            "updateNoteFields",
            note={"id": note_id, "fields": {FIELD: f'<img src="{filename}">'}},
        )
        print(f"ok: set {FIELD} on note {note_id}")


    if __name__ == "__main__":
        main()
  ''
