# Export validation

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
