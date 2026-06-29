{ writers, python3Packages }:
writers.writePython3Bin "prusa-status"
  {
    libraries = [ python3Packages.requests ];
    doCheck = false;
  }
  # python
  ''
    import os
    import time
    import requests
    from pathlib import Path
    from datetime import datetime, timedelta
    from requests.auth import HTTPDigestAuth

    config_dir = os.getenv("XDG_CONFIG_HOME", str(Path.home() / ".config"))
    auth_file_path = Path(config_dir) / "prusa_auth"

    try:
      with open(auth_file_path, "r") as f:
          lines = f.readlines()
          username = lines[0].strip()
          password = lines[1].strip()
          host = lines[2].strip()

    except FileNotFoundError:
      raise FileNotFoundError(f"Auth file not found at {auth_file_path}")
    except IndexError:
      raise ValueError("Auth file is missing username or password.")

    url = host + "/api/v1/job"

    while True:
      try:
          response = requests.get(url, auth=HTTPDigestAuth(username, password))
      except requests.exceptions.RequestException:
          print("", flush=True)
          time.sleep(60)
          continue

      if response.status_code == 200:
          data = response.json()

          time_remaining = data.get('time_remaining', 0)
          file = data.get('file', {}).get('display_name', "")

          current_time = datetime.now()
          expected_end_time = current_time + timedelta(seconds=time_remaining)

          remaining_time_delta = timedelta(seconds=time_remaining)
          human_readable_parts = []

          time_delta = timedelta(seconds=time_remaining)
          days = time_delta.days
          hours, remainder = divmod(time_delta.seconds, 3600)
          minutes = remainder // 60

          if days > 0:
              human_readable_parts.append(f"{days}d")
          if hours > 0:
              human_readable_parts.append(f"{hours}h")
          if minutes > 0:
              human_readable_parts.append(f"{minutes}m")

          human_readable = " ".join(human_readable_parts) \
              if human_readable_parts else "0m"

          expected_end_delta = timedelta(seconds=time_remaining)
          end_days = expected_end_delta.days

          expected_end_days = f"in {end_days} days " if end_days > 0 else ""

          print(f"ETA: {human_readable} {expected_end_days}at "
                f"{expected_end_time.strftime('%H:%M')}", flush=True)
      else:
          print("", flush=True)
      time.sleep(60)
  ''
