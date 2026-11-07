# Contributing

Changes to remote navigation, readability, catalog maintenance, accessibility, and local library behavior are welcome. Keep the app buildable without a server or account credentials. The bridge document is a proposal, not an invitation to add an unofficial account integration to the default app.

Run `swift test`, `python3 Scripts/check_public_export.py`, and an unsigned simulator build before proposing changes. Check remote focus in the simulator for UI work. Include what changed and how you verified it; record meaningful project progress in `CurioTV.md`.

Do not commit device configuration, account material, private viewing data, signing assets, Xcode user state, or raw test-result bundles. Use synthetic data for reproducible bugs. Changes to the catalog must preserve its source attribution.
