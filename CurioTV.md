# CurioTV

## Current status

- Status: Published on GitHub with native personal curation and passing hosted CI. Not installed on physical TV.
- Last updated: 2026-11-08.
- Current objective: Published the reviewed standalone source at https://github.com/eliasnema/CurioTV; the bridge remains a separate experimental proposal.
- Current branch or relevant revision: main; CurioTV 0.5.0, build 5.

## Completed

- Selected app, core library, catalog, original artwork, generators, and tests for the export.
- Excluded the experimental bridge runtime, account integration, private verification files, and device configuration.
- Removed bridge UI, account polling, native player actions, and helper-based feed fallback from the public app.
- Added README, license and attribution, privacy notes, contribution guidance, a short write-up, a separate bridge proposal, export guard, and CI workflow.
- Passed ten core tests, all three simulator UI tests, and unsigned physical-device Release compilation.
- Initialized a fresh local Git repository on main and passed the exact staged-blob scan for all 91 public files.
- Added named personal collections, create/rename/duplicate/delete, custom channel links and handles, group copying, single/bulk tier moves, removals, and optional per-tier channel-count caps including custom values.
- Added collection switching in Discover and Channels and direct assignment from channel pages. The bundled source list remains intact.
- Validated 0.5 with sixteen core tests, two new native curation UI scenarios, two existing UI passes, one explicit external-feed skip, and unsigned device Release compilation.
- Updated the curation guide, privacy notes, screenshots, and draft write-up.

- Published the clean main branch at https://github.com/eliasnema/CurioTV and verified its first hosted export check, core tests, and unsigned simulator build.

## In progress

- No required implementation or repository-publication work remains. Hardware validation and publication of the accompanying article are separate future steps.

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
- Decision: Edit collections inside CurioTV using native controls and text fields; limits count channels per tier.
  - Rationale: The owner confirmed remote/iPhone-keyboard editing and channel-count limits.
  - Evidence: The two new curation remote UI scenarios passed, including typed fields and limit rejection.
- Decision: Persist personal curation separately from the existing library, preserving the original source catalog.
  - Rationale: Existing favorites, saved videos, and openings must survive; each collection needs independent tiers.
  - Evidence: Backward-compatible library decode, independent-ranking, and persistence tests pass.
- Decision: Reject over-cap changes atomically; never evict or demote automatically.
  - Rationale: A shortlist limit should not silently change the user's other rankings.
  - Evidence: Core and UI cap tests verify unchanged channels after rejection.

## Learnings

- The catalog contains 156 channels and 136 article picks from Tristan Hume's November 2026 list.
- Public channel feeds are an external dependency; article picks and YouTube handoff remain usable if feeds fail.
- Live upload selection succeeded during the clean export's remote UI run. The full test command finalized successfully after stopping its stalled post-test diagnostic collector.
- The 0.5 live-feed selection check skipped when public RSS failed; collection editing and offline feed parsing passed independently.
- Native public-page lookups can receive Google's consent page. Handle additions therefore retain a working channel link even when RSS discovery is unavailable; canonical channel IDs skip discovery.

## Blockers and risks

- The proposed bridge's account, service-policy, and media-access questions remain unresolved for public distribution.
- The current variant has not been installed on physical hardware; iPhone keyboard handoff and official YouTube account/history behavior are outside the simulator test.
- Hosted CI passed on the configured macOS 26/Xcode 26.2 runner. Physical-TV validation remains separate.

## Next actions

- Review the draft write-up before publishing an accompanying article.
- Validate official-app handoff and iPhone keyboard use on a physical Apple TV for this exported variant.
- Try Collections → New collection and set up personal groups. A physical-TV update remains separate from this local source delivery.

## Work log

### 2026-11-08 — GitHub publication

- Work completed: Created the public [eliasnema/CurioTV](https://github.com/eliasnema/CurioTV) repository and pushed main. Added origin and upstream tracking; the app and curation source are public.
- Evidence: Scanned both source commits and all 129 distinct file versions before upload; the export guard passed. GitHub confirmed PUBLIC visibility and main as default branch. [Hosted validation run](https://github.com/eliasnema/CurioTV/actions/runs/42529435708) passed for source revision `7c9c3af591c3bdf72de935093ff15f4240587ab8`: export check, core tests, and unsigned tvOS simulator build.
- Decisions: Published the reviewed standalone app only. The bridge remains a separate design proposal, and the accompanying article remains a draft. No account integration, private evidence, signing assets, or inherited private history was uploaded.
- Learnings: The GitHub connector cannot create repositories or push local history; the authenticated GitHub CLI completed those operations.
- Next actions: Review the accompanying write-up and perform hardware validation when requested.

### 2026-11-08 — Native curation validation

- Work completed: Added a custom numeric tier-limit editor and a native curation guide. Updated the README, privacy notes, and draft write-up for personal collections.
- Evidence: Channel-link discovery was checked against a public channel page's advertised RSS link. No account, bridge runtime, or private service was used.
- Learnings: tvOS confirmation sheets can expose nested accessibility buttons with the same label. The remote test now scopes those matches and recognizes focus on their nested button.
- Next actions: Complete the remote test and regression suite, inspect screenshots, and finish the local integration.
- Work completed: Finished native editing and the curation guide, reviewed three fresh screenshots, and completed the full simulator regression on a dedicated fresh Apple TV simulator. Preserved the original library format and the private installed implementation.
- Evidence: Sixteen core tests passed. The complete UI command exited 0 with four passes, one explicit external-RSS skip, and no failures (127.0 seconds). Both new curation cases passed, including typed custom-channel entry, a single tier move, bulk copying, cap rejection, and relaunch persistence. The final unsigned physical-device Release build exited 0.
- Learnings: A native @handle metadata probe was redirected to Google consent. The safe channel-only fallback remains intentional and documented; canonical IDs work without lookup. No account or consent action was submitted.
- Next actions: Commit and integrate the validated local change, then review on hardware when requested. GitHub upload remains pending.

### 2026-11-07 — Personal curation

- Work completed: Read the current progress file, source, clean Git state, and applicable SwiftUI guidance. Checked the ProjectControl registry; the repository remains unregistered. Created an isolated feature worktree from the clean main branch.
- Evidence: The existing library stores favorites, saved videos, and opened links in UserDefaults; channels and their tiers are immutable bundled catalog data. There is no collection or custom-channel editor yet.
- Decisions: Keep the original curator's collection intact and store personal curation separately. Existing library data must survive the update. The playback bridge remains documentation only.
- Next actions: Implement and test collection operations before connecting them to editing screens.
- Decisions: The owner confirmed channel-count limits per tier and native CurioTV editing with the remote or iPhone keyboard. Collections are browsing groups, not access-control profiles.
- Work completed: Added separate collection persistence, custom channel-link validation, per-collection rankings and caps, atomic bulk changes, original-list preservation, named collection create/rename/copy/delete, a collection switcher, multi-select editing, and public RSS-link discovery for handles.
- Evidence: Sixteen offline core tests passed. The native simulator app and UI-test target compile. A public @handle page advertised a valid RSS link without account access. Initial UI attempts exposed incorrect test navigation across horizontal button rows; the test now uses accessibility frames to guide actual remote presses.
- Next actions: Finish remote validation, refresh screenshots and public documentation, then integrate the tested change into the local repository.

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
