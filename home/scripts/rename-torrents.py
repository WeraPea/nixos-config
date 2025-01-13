import os
import bencodepy
import argparse


def get_torrent_name(file_path):
    with open(file_path, "rb") as f:
        torrent_data = bencodepy.decode(f.read())
        info = torrent_data[b"info"]
        name = info[b"name"].decode("utf-8")

        return name


def rename_torrent_file(file_path, verbose=False):
    try:
        torrent_name = get_torrent_name(file_path)
        directory, original_name = os.path.split(file_path)
        new_file_name = f"{torrent_name}-{original_name}"
        new_file_path = os.path.join(directory, new_file_name)
        os.rename(file_path, new_file_path)
        if verbose:
            print(f"Renamed {original_name} to {new_file_name}")
    except Exception as e:
        print(f"Error processing {file_path}: {e}")


def rename_torrents_in_directory(directory_path, verbose=False):
    torrent_files = [f for f in os.listdir(
        directory_path) if f.endswith(".torrent")]

    for torrent_file in torrent_files:
        file_path = os.path.join(directory_path, torrent_file)
        rename_torrent_file(file_path, verbose)


def main():
    parser = argparse.ArgumentParser(
        description="rename .torrent files to <name>-<org-name>.torrent"
    )
    parser.add_argument("path", help="path to directory or file")
    parser.add_argument("-v", "--verbose",
                        action="store_true", help="verbose mode")
    args = parser.parse_args()

    if os.path.isdir(args.path):
        rename_torrents_in_directory(args.path)
    elif os.path.isfile(args.path) and args.path.endswith(".torrent"):
        rename_torrent_file(args.path)
    else:
        print(f"Error: {args.path} is not a valid .torrent file or directory")


if __name__ == "__main__":
    main()
