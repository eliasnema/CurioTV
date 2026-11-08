# CurioTV: taking a curated corner of YouTube to Apple TV

Draft — repository link and publication pending.

[Andrej Karpathy's post about TristanTube](https://x.com/karpathy/status/2119114537442189652) sent me back to [Tristan Hume's YouTube tier list](https://thume.ca/2026/11/01/youtube-tier-list-2026/). I wanted that collection on the television: something I could browse with an Apple TV remote, pick a starting point, and watch.

So I built CurioTV with Codex. It is a native SwiftUI app for tvOS, with all 156 channels, the original S–D tiers, and 136 videos suggested in the article. There is channel search, favorites, saved videos, and recent uploads when YouTube's public feeds are available. You can also make personal or family collections, add your own channels, copy groups, and change tiers using the remote or iPhone keyboard. Optional per-tier channel limits keep a shortlist small. The original curation is Tristan's; the interface inspiration is Karpathy's.

The interesting work was making it comfortable from the sofa. Remote focus, readable cards, and navigation matter more there than another dense grid of links. Keeping a small local library also makes it easy to come back to something without turning the app into another recommendation feed.

The public version has a straightforward playback boundary: choose in CurioTV, watch in the official YouTube app. Your account, history settings, and Premium benefits stay with YouTube. CurioTV does not ask for Google credentials, and a successfully opened link is labeled as an opened link rather than watched time.

I have also written up a [possible separate playback bridge](possible-playback-bridge.md): a local helper could supply native playback and report actual viewing through an authorized provider integration. That is an experimental architecture note, not a shipped feature. YouTube's public API does not provide the history interface it would need, so the provider integration remains unresolved.

The source candidate includes the app, offline core tests, remote UI tests, and setup notes. It is a small example of turning a useful piece of human curation into a native interface for the place I wanted to use it.

[Project overview and build instructions](../README.md).
