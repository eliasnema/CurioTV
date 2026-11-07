#!/usr/bin/env python3
"""Import factual channel names, tiers and video links; do not copy reviews.

Usage: python3 Scripts/import_catalog.py /path/to/saved-article.html
The importer reads local HTML and never makes network requests.
"""
import collections
import datetime
import html.parser
import json
import pathlib
import re
import sys
import urllib.parse

SOURCE = "https://thume.ca/2026/11/01/youtube-tier-list-2026/"
RESOLVED = json.loads(pathlib.Path(__file__).with_name("resolved_channel_ids.json").read_text())


class CatalogParser(html.parser.HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.tier = None
        self.current = None
        self.in_channel_link = False
        self.channels = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        classes = attrs.get("class", "").split()
        if tag == "section":
            self.tier = next((c[-1] for c in classes if re.fullmatch(r"yt-tier-[SABCD]", c)), self.tier)
        if tag == "article" and "yt-ch" in classes:
            self.current = {"tier": self.tier, "name": ""}
        if self.current is None:
            return
        if tag == "a" and "yt-thumb" in classes:
            self.current["videoID"] = urllib.parse.parse_qs(urllib.parse.urlsplit(attrs["href"]).query).get("v", [None])[0]
            self.current["videoTitle"] = attrs.get("title", "")
        if tag == "a" and re.match(r"https://www\.youtube\.com/(channel/|user/|c/|@)", attrs.get("href", "")):
            self.current["url"] = attrs["href"]
            self.in_channel_link = True

    def handle_data(self, data):
        if self.in_channel_link and self.current is not None:
            self.current["name"] += data

    def handle_endtag(self, tag):
        if tag == "a":
            self.in_channel_link = False
        if tag == "article" and self.current is not None:
            raw = self.current
            self.current = None
            path = urllib.parse.urlsplit(raw["url"]).path
            channel_id = path.removeprefix("/channel/") if path.startswith("/channel/") else None
            channel_id = channel_id or RESOLVED.get(raw["url"], {}).get("youtubeChannelID")
            username = path.removeprefix("/user/") if path.startswith("/user/") else None
            stable_id = channel_id or path.lstrip("/")
            channel = {
                "id": stable_id, "name": raw["name"].strip(), "tier": raw["tier"],
                "url": raw["url"], "youtubeChannelID": channel_id, "username": username,
                "featuredVideo": None,
            }
            if raw.get("videoID"):
                assert re.fullmatch(r"[A-Za-z0-9_-]{11}", raw["videoID"]), raw
                channel["featuredVideo"] = {
                    "id": raw["videoID"], "title": raw["videoTitle"],
                    "channelID": stable_id, "channelName": channel["name"], "isShort": "#shorts" in raw["videoTitle"].lower(),
                }
            self.channels.append(channel)


def main():
    parser = CatalogParser()
    parser.feed(pathlib.Path(sys.argv[1]).read_text())
    channels = parser.channels
    counts = dict(collections.Counter(c["tier"] for c in channels))
    assert counts == {"S": 5, "A": 14, "B": 12, "C": 33, "D": 92}, counts
    assert len({c["id"] for c in channels}) == len(channels)
    destination = pathlib.Path(__file__).resolve().parents[1] / "Sources/CurioCore/Resources/channels.json"
    destination.write_text(json.dumps({
        "sourceURL": SOURCE, "attribution": "Channel selection and tiers by Tristan Hume",
        "importedAt": datetime.date.today().isoformat(), "channels": channels,
    }, indent=2, ensure_ascii=False) + "\n")
    print(json.dumps({"channels": len(channels), "tiers": counts,
                      "article_picks": sum(c["featuredVideo"] is not None for c in channels),
                      "channel_id_feeds": sum(c["youtubeChannelID"] is not None for c in channels),
                      "username_feeds": sum(c["username"] is not None for c in channels)}, indent=2))


if __name__ == "__main__":
    main()
