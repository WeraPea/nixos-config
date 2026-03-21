{
  writers,
  python3Packages,
}:
writers.writePython3Bin "pinenote-screenshot"
  {
    libraries = [
      python3Packages.numpy
      python3Packages.pillow
    ];
  }
  # python
  ''
    from datetime import datetime
    from PIL import Image
    import numpy as np
    import os
    import re
    import shutil
    import subprocess
    import sys
    import time

    W, H = 1872, 1404

    BUSCTL_CMD = [
        "busctl", "--user", "call",
        "org.pinenote.PineNoteCtl",
        "/org/pinenote/PineNoteCtl",
        "org.pinenote.Ebc1",
        "DumpFramebuffers", "s",
    ]

    DUMP_BASE_DIR = os.path.expanduser("~/pinenote_dumps")
    TIMEOUT = 10


    def dump_framebuffers():
        os.makedirs(DUMP_BASE_DIR, exist_ok=True)
        existing_files = set(os.listdir(DUMP_BASE_DIR))

        result = subprocess.run(BUSCTL_CMD + [DUMP_BASE_DIR], capture_output=True)
        if result.returncode != 0:
            print("busctl error:", result.stderr.strip())
            sys.exit(1)

        deadline = time.monotonic() + TIMEOUT
        while time.monotonic() < deadline:
            new = [d for d in os.listdir(DUMP_BASE_DIR)
                   if re.match(r"dump_\d+", d) and d not in existing_files]
            if new:
                dump_dir = os.path.join(DUMP_BASE_DIR, new[-1])
                target = os.path.join(dump_dir, "buf_prelim_target.bin")
                while time.monotonic() < deadline:
                    if os.path.exists(target) and os.path.getsize(target) == W * H:
                        return dump_dir
                    time.sleep(0.1)
            time.sleep(0.1)

        print(f"Timed out after {TIMEOUT}s of waiting for dump")
        sys.exit(1)


    def screenshot(dump_dir):
        path = os.path.join(dump_dir, "buf_prelim_target.bin")
        data = np.frombuffer(open(path, "rb").read(), dtype=np.uint8)
        arr = data.reshape(H, W)[:, ::-1]
        norm = ((arr & 0x0F) * 17).astype(np.uint8)
        return Image.fromarray(norm, "L")


    def main():
        dump_dir = dump_framebuffers()
        try:
            img = screenshot(dump_dir)
        finally:
            shutil.rmtree(dump_dir)

        out_png = sys.argv[1] if len(sys.argv) > 1 else \
            f"screenshot_{datetime.now().strftime('%Y%m%d_%H%M%S')}.png"
        img.save(out_png)
        print(out_png)


    if __name__ == "__main__":
        main()
  ''
