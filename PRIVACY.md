# Privacy

This describes the code shipped in this repository.

CurioTV stores favorites, saved video links, successfully opened video links, and the Shorts preference in a local JSON library in its application container. Settings can clear the opened links or reset the library. An opened link is not proof of playback. There is no cloud synchronization or developer-operated backend.

The app fetches public channel feeds from YouTube and video thumbnails from YouTube's image servers. Those services receive normal network-request information, including the device's public IP address and the requested channel or video identifiers. Feeds are cached in memory for ten minutes; platform networking and image components may also cache responses. Catalog data is bundled with the app, so basic browsing does not need a feed response.

Choosing a video or channel opens a YouTube link in the official app. The active account, viewing history, ads, and Premium behavior are handled there under YouTube's settings and policies. If handoff fails, a QR code offers the public link for another device.

CurioTV has no Google sign-in, account tokens, analytics SDK, advertising SDK, playback telemetry, or history-writing service. The separate bridge design note does not change the behavior of this build.
