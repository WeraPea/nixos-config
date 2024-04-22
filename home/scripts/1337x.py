import os
import sys
from rofi import Rofi

r = Rofi()

torrent = " ".join(sys.argv[1:])

torrent = torrent.replace(" ", "+")
html = os.popen(
    '''curl -s "https://1337x.to/search/{}/1/"'''.format(torrent)).read()
html_orginal = html
# get all search results and put them in a list
torrents = []
offset = 18
while html.find("<a href=\"/torrent/") != -1:
    start = html.find("<a href=\"/torrent/")
    end = html.find(">", start + 1)
    torrents.append(html[start + offset:end-2])
    html = html[end:]

# get seeders and leechers
formated_torrents = []
for torrent in torrents:
    html = html_orginal
    location = html.find(torrent)
    html = html[location:]
    start = html.find("seeds")
    end = html.find("</td>", start)
    seeders = html[start + 7:end]
    start = html.find("leeches")
    end = html.find("</td>", start)
    leechers = html[start + 9:end]
    start = html.find("size mob-")
    start = html.find(">", start)
    end = html.find("<span", start)
    size = html[start + 1:end]
    formated_torrents.append([torrent, seeders, leechers, size])

# sort by seeders
formated_torrents.sort(key=lambda x: int(x[1]), reverse=True)
# convert torrents to string
string_torrents = []
for torrent in formated_torrents:
    # show torrent name without numbers
    torrent_name = torrent[0].split("/")[-1]
    # [seeds] [leechers] torrent_name
    string_torrents.append("[{}] [{}] [{}] {}".format(
        torrent[1], torrent[2], torrent[3], torrent_name))

torrent_choice = r.select("Torrents", string_torrents)
if torrent_choice == ([], -1):
    exit()
torrent_choice = formated_torrents[torrent_choice[0][0]][0]

html = os.popen(
    '''curl -s "https://1337x.to/torrent/{}/"'''.format(torrent_choice)).read()
start = html.find("magnet:?")
end = html.find("\"", start + 1)
magnet = html[start:end]

os.chdir('@videoPath@')
os.system('''mpv "{}" --slang=eng'''.format(magnet))
