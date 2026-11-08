# Privacy

This describes the code shipped in this repository.

CurioTV stores named collections, custom channel links, per-collection tiers and limits, the selected collection, favorites, saved video links, successfully opened video links, and the Shorts preference locally in UserDefaults. Structured records are JSON-encoded. Collections use a separate storage key so the existing saved-library format remains unchanged. Settings can clear the opened links or reset all local-library data after confirmation. An opened link is not proof of playback. There is no cloud synchronization or developer-operated backend.

The app fetches public channel feeds from YouTube and video thumbnails from YouTube's image servers. Adding a custom handle may also fetch its public YouTube channel page using an ephemeral network session to discover the advertised RSS link. No account or private API is used. Those services receive normal network-request information, including the device's public IP address and the requested channel or video identifiers. Feeds are cached in memory for ten minutes; platform networking and image components may also cache responses. Catalog data is bundled with the app, so basic browsing does not need a feed response.

Choosing a video or channel opens a YouTube link in the official app. The active account, viewing history, ads, and Premium behavior are handled there under YouTube's settings and policies. If handoff fails, a QR code offers the public link for another device.

CurioTV has no Google sign-in, account tokens, analytics SDK, advertising SDK, playback telemetry, or history-writing service. The separate bridge design note does not change the behavior of this build.
