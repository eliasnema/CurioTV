# CurioTV

## Current status

- Status: Standalone open-source candidate prepared and validated for local review. Not published.
- Last updated: 2026-11-07.
- Current objective: Export the native curated browser with official YouTube handoff, document a possible playback bridge separately, and prepare a short write-up.
- Current branch or relevant revision: main; public candidate 0.4.0, build 4.

## Completed

- Selected app, core library, catalog, original artwork, generators, and tests for the export.
- Excluded the experimental bridge runtime, account integration, private verification files, and device configuration.
- Removed bridge UI, account polling, native player actions, and helper-based feed fallback from the public app.
- Added README, license and attribution, privacy notes, contribution guidance, a short write-up, a separate bridge proposal, export guard, and CI workflow.
- Passed ten core tests, all three simulator UI tests, and unsigned physical-device Release compilation.
- Initialized a fresh local Git repository on main and passed the exact staged-blob scan for all 91 public files.

## In progress

- No required export implementation remains. The write-up is a draft; publication is a later step.

## Decisions

- Decision: The public app opens videos in the official YouTube app.
  - Rationale: It can run without a server, account credentials, or an unofficial playback integration.
  - Evidence: The existing PlaybackCoordinator supports YouTube handoff and a QR fallback.
- Decision: Describe a possible bridge in a separate document, with no bridge implementation in this repository.
  - Rationale: The requested public scope is the native browser plus an explicitly experimental design proposal.
  - Evidence: The project owner's export instruction on 2026-11-07.
- Decision: Use the example bundle identifier com.example.CurioTV.
  - Rationale: Contributors must supply their own identifier for device signing; the example does not replace an existing private installation.
- Decision: License original code and artwork under MIT and keep third-party attribution explicit.
  - Rationale: Make the original implementation reusable without asserting rights over the curation, thumbnails, or videos.
  - Evidence: LICENSE and NOTICE.md define the public candidate's scope.

## Learnings

- The catalog contains 156 channels and 136 article picks from Tristan Hume's November 2026 list.
- Public channel feeds are an external dependency; article picks and YouTube handoff remain usable if feeds fail.
- Live upload selection succeeded during the clean export's remote UI run. The full test command finalized successfully after stopping its stalled post-test diagnostic collector.

## Blockers and risks

- Publication and a GitHub remote remain pending.
- The proposed bridge's account, service-policy, and media-access questions remain unresolved for public distribution.
- The exported variant has not been installed on physical hardware; official YouTube account/history behavior is outside the simulator test.
- The configured GitHub-hosted CI has not run. Local validation used Xcode 27.

## Next actions

- Review the write-up and choose a GitHub destination when ready to publish.
- Run the configured hosted workflow after uploading; validate official-app handoff on a physical Apple TV for this exported variant.

## Work log

### 2026-11-07

- Work completed: Created a fresh public staging tree from an explicit file allowlist; removed the playback experiment and account feature directories.
- Evidence: The selected tree contains the native app, CurioCore package, catalog, tests, and maintenance scripts; no helper runtime or private evidence bundle was copied.
- Decisions: Official YouTube handoff is the public playback behavior. A bridge will be documented only as a possible implementation.
- Learnings: Account-session and hardware-test evidence are outside the public export.
- Next actions: Complete edits and validate the independent app.
- Work completed: Finished the handoff-only app and documentation. Added a focused export guard and a read-only CI workflow. Reviewed fresh simulator screenshots for the public candidate.
- Evidence: Ten Swift tests passed; three remote UI cases passed without skips (45.4 seconds), including live recent-upload selection; the simulator test command and unsigned device Release build exited 0. The working-tree export scan passed, and five synthetic private/runtime examples were rejected.
- Decisions: Use the MIT license for original code and artwork, with third-party material expressly excluded from that grant. No inherited private Git history will be copied.
- Learnings: Xcode's post-test simulator diagnostics stalled; stopping only that child collector allowed successful result finalization. The raw result also reports UIKit hosting runtime warnings, documented in `docs/validation.md`.
- Next actions: Create and inspect the clean local repository; leave the remote and publication pending.
- Work completed: Created the new local repository on main with a repository-specific GitHub noreply commit identity. Reviewed all 91 staged file paths and scanned their exact blobs.
- Evidence: The staged export guard and Git whitespace check passed; no remote is configured. Relative Markdown links and Python source syntax checks passed.
- Decisions: Keep this preparation local; no GitHub repository or post has been published.
- Next actions: Owner review of the draft and repository before publication.
