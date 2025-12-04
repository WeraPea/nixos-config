{ lib, pkgs, ... }:
pkgs.writers.writePython3Bin "usb-tablet"
  {
    doCheck = false;
  }
  ''
    import os
    import sys
    import signal
    import subprocess
    from pathlib import Path


    class USBTablet:
        def __init__(self):
            self.usb_proc = None
            self.monitor_proc = None
            self.orig_warm = None
            self.orig_cool = None
            self.orig_vt = 1
            self.running = True


        def read_file(self, path):
            return Path(path).read_text().strip()


        def cleanup(self):
            print("cleaning...")

            if self.orig_warm is not None:
                try:
                    Path("/sys/class/backlight/backlight_warm/brightness").write_text(str(self.orig_warm))
                except: pass

            if self.orig_cool is not None:
                try:
                    Path("/sys/class/backlight/backlight_cool/brightness").write_text(str(self.orig_cool))
                except: pass

            try:
                subprocess.run(["chvt", str(self.orig_vt)], check=False)
            except: pass

            if self.usb_proc:
                try:
                    self.usb_proc.send_signal(signal.SIGINT)
                    self.usb_proc.wait(timeout=5)
                except:
                    try:
                        self.usb_proc.kill()
                    except: pass

            if self.monitor_proc:
                try:
                    self.monitor_proc.terminate()
                    self.monitor_proc.wait(timeout=2)
                except:
                    try:
                        self.monitor_proc.kill()
                    except: pass

            print("clean")


        def check_charger_status(self):
            try:
                status = Path("/sys/class/power_supply/rk817-charger/online").read_text().strip()
                return status == "1"
            except:
                return False


        def monitor_charger(self):
            self.monitor_proc = subprocess.Popen(
                ["udevadm", "monitor", "--udev", "--subsystem-match=power_supply"],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True
            )

            print("activated")

            while self.running:
                if self.monitor_proc.poll() is not None:
                    break

                line = self.monitor_proc.stdout.readline()
                if line and "rk817-charger" in line:
                    if not self.check_charger_status():
                        print("charger disconnected")
                        self.running = False
                        break


        def run(self):
            if os.geteuid() != 0:
                print("error: this script must be run as root", file=sys.stderr)
                return 1

            if not self.check_charger_status():
                print("quiting: device not connected")
                return 0

            def signal_handler(sig, frame):
                self.running = False

            signal.signal(signal.SIGINT, signal_handler)
            signal.signal(signal.SIGTERM, signal_handler)

            try:
                self.orig_warm = Path("/sys/class/backlight/backlight_warm/brightness").read_text().strip()
                self.orig_cool = Path("/sys/class/backlight/backlight_cool/brightness").read_text().strip()

                subprocess.run(
                    ["openvt", "-f", "-c", "3", "--",
                     "bash", "-c", "echo 0 > /sys/class/graphics/fbcon/cursor_blink"],
                    check=False
                )
                subprocess.run(["chvt", "3"], check=False)

                Path("/sys/class/backlight/backlight_warm/brightness").write_text(str(0))
                Path("/sys/class/backlight/backlight_cool/brightness").write_text(str(0))

                subprocess.run(["modprobe", "libcomposite"], check=False)
                self.usb_proc = subprocess.Popen(["${lib.getExe' pkgs.pinenote-usb-tablet "pinenote-usb-tablet"}"])

                self.monitor_charger()

            finally:
                self.cleanup()

            return 0


    if __name__ == "__main__":
        tablet = USBTablet()
        sys.exit(tablet.run())
  ''
