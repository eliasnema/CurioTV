# Validation

## GitHub publication — 8 November 2026

The public [eliasnema/CurioTV](https://github.com/eliasnema/CurioTV) repository now contains the reviewed standalone app. The [first hosted CI run](https://github.com/eliasnema/CurioTV/actions/runs/42529435708) passed for `7c9c3af591c3bdf72de935093ff15f4240587ab8` on the configured macOS 26/Xcode 26.2 runner: exact tracked-file export scan, offline core tests, and unsigned Apple TV simulator compilation.

The prior local test results below remain the evidence for remote UI behavior. No physical-TV installation or account/history test was performed during publication.

## 0.5.0 — Personal curation, 8 November 2026

Validated the native collection editor with Xcode 27.0, Swift 6.2, and a fresh tvOS 27 Apple TV simulator at 1080p.

| Check | Result |
| --- | --- |
| Offline core suite | 16 tests in 4 suites passed |
| Complete remote UI suite | 4 passed, 1 external-RSS skip, 0 failures; command exited 0 |
| Unsigned physical-tvOS Release build | Build succeeded; command exited 0 |
| Public export and whitespace checks | Passed |

The new UI cases passed group copying, a per-tier cap, rejection of a bulk change above that cap, persistence across relaunch, native keyboard entry of a custom channel name and URL, and a single-channel tier move. Existing saved-library, fallback, and settings cases also passed. Tier filtering and channel navigation completed before live upload selection explicitly skipped because YouTube RSS was unavailable. The complete suite took 127.0 seconds.

Core coverage includes independent rankings, preservation of the bundled collection, atomic bulk limits, duplicate matching, copying limits, rename conflicts, delete/selection fallback, custom-link validation, feed-link parsing, curation round trips, and compatibility with the existing library format.

Fresh simulator screenshots were visually reviewed. The UIKit hosting runtime warnings described in the initial validation below also appeared; no associated assertion failed. Earlier test iterations corrected horizontal remote navigation, nested dialog accessibility matches, native dialog button styling, and the Add button's focus area. The final run uses supported accessibility attributes to guide actual remote presses and disables verbose diagnostic collection.

An independent native network probe received a Google consent page for a public @handle. It correctly returned the channel-only fallback rather than inventing a feed ID. A separate public-page fetch exposed the expected advertised RSS link, whose parser is tested offline. Canonical channel IDs avoid this lookup. Live handle discovery is therefore best effort, not a guaranteed network feature.

This version was compiled but not installed on physical Apple TV. iPhone-to-TV keyboard handoff has not been hardware-tested. Google sign-in, account history, bridge playback, and hosted CI were not part of this validation.

## 0.4.0 — Initial export, 7 November 2026

Validated on 7 November 2026 using Xcode 27.0 (27A266a), the Swift 6.2 tools, and a tvOS 27 Apple TV 4K simulator at 1080p. The deployment target is tvOS 26. This public candidate uses the example bundle identifier `com.example.CurioTV`.

| Check | Result |
| --- | --- |
| `swift test` | 10 tests across 3 suites passed |
| Simulator build and remote UI run | 3 tests passed, 0 failed, 0 skipped; `xcodebuild` exited 0 |
| Physical-tvOS Release compilation, signing disabled | Build succeeded; `xcodebuild` exited 0 |
| Public working-tree scan | Passed |
| Guard behavior | Rejected five synthetic examples covering runtime paths, signing files, personal paths, tokens, and account code |

The UI run verified tier filtering, opening a channel and a live recent upload, saving a video across relaunch, honest QR fallback when YouTube is absent, and account guidance that points to the official YouTube app. The three test cases took 45.4 seconds. Public feed availability is not guaranteed by this run.

Xcode's post-test diagnostic collector stalled after all cases had passed. Stopping only that collector allowed the test command to finalize successfully. The result bundle reports three passes. It also contains UIKit `_UIReplicantView`/`UIHostingController` runtime warnings during the run; no associated assertion failed. Raw diagnostics and machine-specific logs are intentionally outside this repository.

The Release build was compiled for a physical Apple TV, but this exported variant was not installed or tested on hardware. Playback in the official YouTube app and its account-history behavior were not exercised by the simulator, which has no YouTube app installed. No Google account or account-history write was used for export validation.

## Reproduce

```sh
swift test
python3 Scripts/check_public_export.py

# Use a booted Apple TV simulator's identifier from `xcrun simctl list devices`.
xcodebuild -project CurioTV.xcodeproj -scheme CurioTV \
  -destination 'platform=tvOS Simulator,id=YOUR_SIMULATOR_UDID' \
  -collect-test-diagnostics never CODE_SIGNING_ALLOWED=NO test

xcodebuild -project CurioTV.xcodeproj -scheme CurioTV \
  -configuration Release -destination 'generic/platform=tvOS' \
  CODE_SIGNING_ALLOWED=NO build

# After staging changes, inspect the exact blobs that would be committed.
python3 Scripts/check_public_export.py --staged
```

The export guard checks selected known sensitive patterns and excluded runtime paths; it is not a universal secret detector. Review staged changes before publication. The repository contains no inherited private Git history.

## Hosted CI

The workflow runs offline core tests, scans tracked files, and builds for the tvOS simulator. It requests read-only repository permissions, disables checkout credential persistence, and pins checkout v6.1.0 by commit.

The configured [macOS 26 runner image](https://github.com/actions/runner-images/blob/main/images/macos/macos-26-Readme.md) lists Xcode 26.2, which the workflow selects explicitly. The GitHub-hosted workflow has not run yet because the repository has not been uploaded. Local results above use Xcode 27, not the hosted image. Runner-image contents can change.
